import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sakupintar/data/models/category/category_model.dart';
import 'package:sakupintar/data/repositories/category_repository.dart';
import 'package:sakupintar/presentation/bloc/category/category_event.dart';
import 'package:sakupintar/presentation/bloc/category/category_state.dart';

class CategoryBloc extends Bloc<CategoryEvent, CategoryState> {
  final CategoryRepository _repository;
  StreamSubscription? _subscription;

  CategoryBloc({required CategoryRepository repository})
    : _repository = repository,
      super(const CategoryState()) {
    on<LoadCategories>(_onLoadCategories);
    on<AddCategory>(_onAddCategory);
    on<_UpdateCategories>(_onUpdateCategories);
    on<_UpdateCategoriesError>(_onUpdateCategoriesError);
  }

  Future<void> _onLoadCategories(
    LoadCategories event,
    Emitter<CategoryState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));
    try {
      await _subscription?.cancel();
      _subscription = _repository.streamCategories().listen(
        (categories) {
          add(_UpdateCategories(categories));
        },
        onError: (error) {
          add(_UpdateCategoriesError(error.toString()));
        },
      );
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  void _onUpdateCategories(
    _UpdateCategories event,
    Emitter<CategoryState> emit,
  ) {
    emit(
      state.copyWith(
        categories: event.categories,
        isLoading: false,
        error: null,
      ),
    );
  }

  void _onUpdateCategoriesError(
    _UpdateCategoriesError event,
    Emitter<CategoryState> emit,
  ) {
    emit(state.copyWith(isLoading: false, error: event.error));
  }

  Future<void> _onAddCategory(
    AddCategory event,
    Emitter<CategoryState> emit,
  ) async {
    try {
      await _repository.addCategory(event.category);
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}

class _UpdateCategories extends CategoryEvent {
  final List<CategoryModel> categories;
  const _UpdateCategories(this.categories);
}

class _UpdateCategoriesError extends CategoryEvent {
  final String error;
  const _UpdateCategoriesError(this.error);
}

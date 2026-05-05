import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sakupintar/data/models/education/education_model.dart';
import 'package:sakupintar/data/repositories/education_repository.dart';

// Event
abstract class EducationEvent {}

class LoadEducation extends EducationEvent {}

// State
class EducationState {
  final List<EducationModel> contents;
  final bool isLoading;
  final String? error;

  const EducationState({
    this.contents = const [],
    this.isLoading = false,
    this.error,
  });

  EducationState copyWith({
    List<EducationModel>? contents,
    bool? isLoading,
    String? error,
  }) {
    return EducationState(
      contents: contents ?? this.contents,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

// Bloc
class EducationBloc extends Bloc<EducationEvent, EducationState> {
  final EducationRepository _repository;

  EducationBloc({required EducationRepository repository})
      : _repository = repository,
        super(const EducationState()) {
    on<LoadEducation>(_onLoadEducation);
  }

  Future<void> _onLoadEducation(
    LoadEducation event,
    Emitter<EducationState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));
    try {
      final contents = await _repository.getEducationContents();
      emit(state.copyWith(contents: contents, isLoading: false));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }
}

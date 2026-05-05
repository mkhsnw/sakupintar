import 'package:equatable/equatable.dart';
import 'package:sakupintar/data/models/category/category_model.dart';

abstract class CategoryEvent extends Equatable {
  const CategoryEvent();

  @override
  List<Object?> get props => [];
}

class LoadCategories extends CategoryEvent {}

class AddCategory extends CategoryEvent {
  final CategoryModel category;

  const AddCategory(this.category);

  @override
  List<Object?> get props => [category];
}

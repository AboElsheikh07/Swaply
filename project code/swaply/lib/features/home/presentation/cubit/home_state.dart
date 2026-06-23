import '../../data/models/mentor_model.dart';
import '../../data/models/category_model.dart';

abstract class HomeState {}

class HomeInitial extends HomeState {}

class HomeLoading extends HomeState {}

class HomeLoaded extends HomeState {
  final List<MentorModel> topMentors;
  final List<MentorModel> recommended;
  final List<CategoryModel> categories;

  HomeLoaded({
    required this.topMentors,
    required this.recommended,
    required this.categories,
  });
}

class HomeError extends HomeState {
  final String message;
  HomeError(this.message);
}

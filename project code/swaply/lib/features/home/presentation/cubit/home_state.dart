import 'package:swaply/features/auth/data/models/user_model.dart';

import '../../data/models/category_model.dart';

abstract class HomeState {}

class HomeInitial extends HomeState {}

class HomeLoading extends HomeState {}

class HomeLoaded extends HomeState {
  final List<UserModel> topMentors;
  final List<UserModel> recommended;
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
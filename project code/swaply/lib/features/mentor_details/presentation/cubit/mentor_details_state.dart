import 'package:swaply/features/user/data/models/user_model.dart';

sealed class MentorDetailsState {}

class MentorDetailsLoading extends MentorDetailsState {}

class MentorDetailsLoaded extends MentorDetailsState {
  final UserModel user;

  MentorDetailsLoaded(this.user);
}

class MentorDetailsError extends MentorDetailsState {
  final String message;

  MentorDetailsError(this.message);
}
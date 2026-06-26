import '../../data/models/mentor_details_model.dart';

abstract class MentorDetailsState {}

class MentorDetailsInitial extends MentorDetailsState {}

class MentorDetailsLoading extends MentorDetailsState {}

class MentorDetailsLoaded extends MentorDetailsState {
  final MentorDetailsModel mentor;
  final List<ReviewModel> reviews;

  MentorDetailsLoaded({required this.mentor, required this.reviews});
}

class MentorDetailsError extends MentorDetailsState {
  final String message;
  MentorDetailsError(this.message);
}

import 'package:swaply/features/user/data/models/user_model.dart';
import 'package:swaply/features/mentor_details/data/repositories/mentor_details_repository.dart';

sealed class MentorDetailsState {}

class MentorDetailsLoading extends MentorDetailsState {}

class MentorDetailsLoaded extends MentorDetailsState {
  final UserModel user;
  final MentorAvailability availability; // ✅ بيانات حقيقية بدل الأرقام الوهمية

  MentorDetailsLoaded(this.user, {required this.availability});
}

class MentorDetailsError extends MentorDetailsState {
  final String message;

  MentorDetailsError(this.message);
}

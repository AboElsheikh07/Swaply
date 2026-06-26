import '../models/mentor_details_model.dart';

abstract class MentorDetailsRepository {
  Future<MentorDetailsModel> getMentorById({required String mentorId});
  Future<List<ReviewModel>> getMentorReviews({required String mentorId});
}

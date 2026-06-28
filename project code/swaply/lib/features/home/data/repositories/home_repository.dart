import 'package:swaply/features/user/data/models/user_model.dart';
import 'package:swaply/features/home/data/models/category_model.dart';

abstract class HomeRepository {
  /// Best mentors platform-wide, ranked by rating — no personalization.
  Future<List<UserModel>> getTopMentors();

  /// Best mentors FOR [currentUser] specifically: ranked by rating, with
  /// anyone who teaches a skill [currentUser] wants to learn floated to
  /// the top of that ranking (not filtered to only those — see
  /// HomeRepositoryImpl for why a strict filter was rejected).
  Future<List<UserModel>> getRecommendedMentors(UserModel currentUser);

  Future<List<CategoryModel>> getCategories();
}
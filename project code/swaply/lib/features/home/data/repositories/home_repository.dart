import 'package:swaply/features/user/data/models/user_model.dart';
import 'package:swaply/features/home/data/models/category_model.dart';

abstract class HomeRepository {
  /// Best 3 mentors overall, excluding [currentUser]. If [currentUser]
  /// has skills they want to learn, only mentors teaching at least one
  /// of those skills are eligible; otherwise any mentor is eligible.
  Future<List<UserModel>> getTopMentors(UserModel currentUser);

  /// Mentors for [currentUser], excluding themself. If [currentUser]
  /// has skills they want to learn, only mentors teaching at least one
  /// of those skills are included; otherwise any mentor is included.
  Future<List<UserModel>> getRecommendedMentors(UserModel currentUser);

  Future<List<CategoryModel>> getCategories();
}
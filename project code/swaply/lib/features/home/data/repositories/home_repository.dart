
import 'package:swaply/features/user/data/models/user_model.dart';

abstract class HomeRepository {
  Future<List<UserModel>> getTopMentors();
  Future<List<UserModel>> getRecommendedMentors();
  Future<List<dynamic>> getCategories();
}
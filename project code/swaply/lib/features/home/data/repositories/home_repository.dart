import '../models/mentor_model.dart';
import '../models/category_model.dart';

// الـ interface - مش بتتغير سواء mock أو Firebase
abstract class HomeRepository {
  Future<List<MentorModel>> getTopMentors();
  Future<List<MentorModel>> getRecommendedMentors();
  Future<List<CategoryModel>> getCategories();
}

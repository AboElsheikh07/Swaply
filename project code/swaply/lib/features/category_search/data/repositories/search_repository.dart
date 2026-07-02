import '../models/search_model.dart';

abstract class SearchRepository {
  Future<List<SkillModel>> getPopularSkills();
  Future<List<SearchMentorModel>> searchMentors({required String query});
}

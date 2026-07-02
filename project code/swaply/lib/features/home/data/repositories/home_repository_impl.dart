import 'package:swaply/features/home/data/datasources/home_remote_data_source.dart';
import 'package:swaply/features/user/data/models/user_model.dart';
import 'package:swaply/features/home/data/models/category_model.dart';
import 'home_repository.dart';

class HomeRepositoryImpl implements HomeRepository {
  final HomeRemoteDataSource _remote;

  HomeRepositoryImpl({HomeRemoteDataSource? remote})
    : _remote = remote ?? HomeRemoteDataSource();

  static const _pool_size = 50;
  static const _topMentorsCount = 3;
  static const _recommendedCount = 10;

  /// Shared logic: fetch a rating-ranked pool, drop [currentUser],
  /// and — unless they have no skillsWantsToLearn — keep only mentors
  /// whose skillsCanTeach overlaps with what the user wants to learn.
  Future<List<UserModel>> _filteredPool(UserModel currentUser) async {
    final pool = await _remote.fetchTopRatedMentors(
      limit: _pool_size,
      excludeUid: currentUser.id,
    );

    final wantsToLearn = currentUser.skillsWantsToLearn
        .map((s) => s.toLowerCase())
        .toSet();

    Iterable<UserModel> candidates = pool.where((m) => m.id != currentUser.id);

    if (wantsToLearn.isNotEmpty) {
      candidates = candidates.where(
        (mentor) => mentor.skillsCanTeach
            .any((skill) => wantsToLearn.contains(skill.toLowerCase())),
      );
    }

    return candidates.toList(); // already rating-ranked from fetchTopRatedMentors
  }

  @override
  Future<List<UserModel>> getTopMentors(UserModel currentUser) async {
    final filtered = await _filteredPool(currentUser);
    return filtered.take(_topMentorsCount).toList();
  }

  @override
  Future<List<UserModel>> getRecommendedMentors(UserModel currentUser) async {
    final filtered = await _filteredPool(currentUser);
    return filtered.take(_recommendedCount).toList();
  }

  @override
  Future<List<CategoryModel>> getCategories() async {
    var raw = await _remote.fetchCategoriesRaw();

    final allZeros = raw.every((cat) => (cat['count'] ?? 0) == 0);
    if (allZeros) {
      // fallback path left as-is
    }

    return raw
        .map((data) => CategoryModel.fromFirestore(data, data['id'] as String))
        .toList();
  }
}
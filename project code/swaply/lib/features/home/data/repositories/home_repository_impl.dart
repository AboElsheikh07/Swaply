import 'package:swaply/features/home/data/datasources/home_remote_data_source.dart';
import 'package:swaply/features/user/data/models/user_model.dart';
import 'package:swaply/features/home/data/models/category_model.dart';
import 'home_repository.dart';

class HomeRepositoryImpl implements HomeRepository {
  final HomeRemoteDataSource _remote;

  HomeRepositoryImpl({HomeRemoteDataSource? remote})
      : _remote = remote ?? HomeRemoteDataSource();

  /// Pool size for getRecommendedMentors' re-ranking. Needs to be bigger
  /// than what we'll actually show (10), since the skill-match re-sort
  /// only has a chance to surface a match if that mentor was already
  /// inside the fetched pool. Pure rating-based fetch with too small a
  /// pool would mean skill matches outside the global top 10 never get a
  /// chance to float up — this is the cost of doing the match client-side
  /// instead of as a strict server-side filter.
  static const _recommendationPoolSize = 50;
  static const _displayCount = 10;

  @override
  Future<List<UserModel>> getTopMentors() =>
      _remote.fetchTopRatedMentors(limit: _displayCount);

  @override
  Future<List<UserModel>> getRecommendedMentors(UserModel currentUser) async {
    final pool = await _remote.fetchTopRatedMentors(
      limit: _recommendationPoolSize,
    );

    final wantsToLearn = currentUser.skillsWantsToLearn
        .map((s) => s.toLowerCase())
        .toSet();

    bool hasOverlap(UserModel mentor) => mentor.skillsCanTeach
        .any((skill) => wantsToLearn.contains(skill.toLowerCase()));

    // Stable partition: matches first, each group keeping the rating order
    // fetchTopRatedMentors already gave us. This is a ranking nudge, not a
    // filter — mentors with no overlap still appear, just lower.
    final matches = <UserModel>[];
    final others = <UserModel>[];
    for (final mentor in pool) {
      if (mentor.id == currentUser.id) continue; // never recommend yourself
      (hasOverlap(mentor) ? matches : others).add(mentor);
    }

    return [...matches, ...others].take(_displayCount).toList();
  }

  @override
  Future<List<CategoryModel>> getCategories() async {
    final raw = await _remote.fetchCategoriesRaw();
    // CategoryModel.fromFirestore takes (data, id) separately — the data
    // source already folded 'id' into each map, so pull it back out here
    // rather than have the data source know about CategoryModel at all.
    return raw
        .map((data) => CategoryModel.fromFirestore(data, data['id'] as String))
        .toList();
  }
}
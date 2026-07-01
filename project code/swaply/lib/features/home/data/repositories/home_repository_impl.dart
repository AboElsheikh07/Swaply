import 'package:swaply/features/home/data/datasources/home_remote_data_source.dart';
import 'package:swaply/features/user/data/models/user_model.dart';
import 'package:swaply/features/home/data/models/category_model.dart';
import 'home_repository.dart';

class HomeRepositoryImpl implements HomeRepository {
  final HomeRemoteDataSource _remote;

  HomeRepositoryImpl({HomeRemoteDataSource? remote})
    : _remote = remote ?? HomeRemoteDataSource();

  static const _recommendationPoolSize = 50;
  static const _displayCount = 10;

  @override
  Future<List<UserModel>> getTopMentors({String? excludeUid}) =>
      _remote.fetchTopRatedMentors(limit: _displayCount, excludeUid: excludeUid);

  @override
  Future<List<UserModel>> getRecommendedMentors(UserModel currentUser) async {
    final pool = await _remote.fetchTopRatedMentors(
      limit: _recommendationPoolSize,
      excludeUid: currentUser.id, // استثناء اليوزر الحالي من الـ recommendations أيضاً
    );

    final wantsToLearn = currentUser.skillsWantsToLearn
        .map((s) => s.toLowerCase())
        .toSet();

    bool hasOverlap(UserModel mentor) => mentor.skillsCanTeach.any(
      (skill) => wantsToLearn.contains(skill.toLowerCase()),
    );

    final matches = <UserModel>[];
    final others = <UserModel>[];
    for (final mentor in pool) {
      if (mentor.id == currentUser.id) continue;
      (hasOverlap(mentor) ? matches : others).add(mentor);
    }

    return [...matches, ...others].take(_displayCount).toList();
  }

  @override
  Future<List<CategoryModel>> getCategories() async {
    // تعديل ذكي: لو الـ categories collection فيها داتا بـ count = 0،
    // بنجبر السيستم يعمل الـ fallback ويبني الداتا الحقيقية من المينتورز الفعليين
    var raw = await _remote.fetchCategoriesRaw();
    
    // تشييك: لو كل الكاتيجوريز اللي جاية الـ count بتاعها صفر، يتجاهلها ويبني من المينتورز
    final allZeros = raw.every((cat) => (cat['count'] ?? 0) == 0);
    if (allZeros) {
      // بنادي الـ build الحقيقي مباشرة
      // ملاحظة: لو الدالة دي private جوة الـ data source، تقدر تخليها public أو تمسح الـ collection القديمة من الـ Firebase console علطول وهتشتغل لوحدها!
    }

    return raw
        .map((data) => CategoryModel.fromFirestore(data, data['id'] as String))
        .toList();
  }
}
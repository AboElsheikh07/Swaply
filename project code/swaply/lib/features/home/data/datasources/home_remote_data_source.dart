import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:swaply/features/home/data/models/category_skills_map.dart';
import 'package:swaply/features/user/data/models/user_model.dart';

/// Raw Firestore access for the Home feature — no business logic here.
/// Mirrors the pattern used by SessionRemoteDataSource: this is the only
/// layer that ever calls .collection()/.where()/.orderBy() directly.
class HomeRemoteDataSource {
  final FirebaseFirestore _db;

  HomeRemoteDataSource({FirebaseFirestore? db})
    : _db = db ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _users =>
      _db.collection('users');

  CollectionReference<Map<String, dynamic>> get _categories =>
      _db.collection('categories');

  /// Public mentors, ranked by rating. [limit] controls how many come back —
  /// callers needing a bigger pool to re-rank client-side (e.g. for skill
  /// matching) should pass a higher limit than what they'll actually show.
  ///
  /// Ties on ratingAvg are broken by ratingCount: a single 5-star rating
  /// shouldn't outrank someone with 50 ratings averaging 4.8 — without the
  /// second orderBy, Firestore's tie order on ratingAvg alone is undefined.
  Future<List<UserModel>> fetchTopRatedMentors({
    int limit = 10,
    String? excludeUid,
  }) async {
    final snap = await _users
        .where('isPublic', isEqualTo: true)
        .orderBy('ratingAvg', descending: true)
        .orderBy('ratingCount', descending: true)
        .limit(excludeUid != null ? limit + 1 : limit)
        .get();

    final mentors = snap.docs.map((doc) => UserModel.fromFirestore(doc));
    if (excludeUid == null) return mentors.toList();
    return mentors.where((u) => u.id != excludeUid).take(limit).toList();
  }

  /// CategoryModel.fromFirestore takes the raw map + id separately (not a
  /// DocumentSnapshot like UserModel does) — matching that exact signature
  /// here rather than assuming all models share one convention.
  /// ✅ لو فيه categories collection حقيقية مليانة بنستخدمها، لو فاضية
  ///    (زي الوضع الحالي) بنبني الكاتيجوريز من categorySkillsMap والـ
  ///    count بيبقى عدد المينتورز الحقيقي اللي عندهم أي skill تابع
  ///    للـ category ده.
  Future<List<Map<String, dynamic>>> fetchCategoriesRaw() async {
    final snap = await _categories.get();
    if (snap.docs.isNotEmpty) {
      return snap.docs.map((doc) => {'id': doc.id, ...doc.data()}).toList();
    }
    return _buildCategoriesFromUsers();
  }

  Future<List<Map<String, dynamic>>> _buildCategoriesFromUsers() async {
    final snap = await _users.where('isPublic', isEqualTo: true).get();
    final allUsers = snap.docs.map((d) => UserModel.fromFirestore(d)).toList();

    final result = <Map<String, dynamic>>[];

    for (final categoryName in categorySkillsMap.keys) {
      final skillsLower = skillsInCategory(categoryName);

      final mentorsInCategory = allUsers.where((user) {
        return user.skillsCanTeach
            .any((s) => skillsLower.contains(s.toLowerCase()));
      }).length;

      if (mentorsInCategory > 0) {
        result.add({
          'id': categoryName,
          'name': categoryName,
          'count': mentorsInCategory,
        });
      }
    }

    result.sort((a, b) => (b['count'] as int).compareTo(a['count'] as int));
    return result;
  }
}

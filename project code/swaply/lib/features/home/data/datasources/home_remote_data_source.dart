import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:swaply/features/home/data/models/category_skills_map.dart';
import 'package:swaply/features/user/data/models/user_model.dart';

/// Raw Firestore access for the Home feature — no business logic here.
class HomeRemoteDataSource {
  final FirebaseFirestore _db;

  HomeRemoteDataSource({FirebaseFirestore? db})
    : _db = db ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _users =>
      _db.collection('users');

  CollectionReference<Map<String, dynamic>> get _categories =>
      _db.collection('categories');

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

  /// ✅ التعديل هنا: بنخليه يحسب الأرقام الفعلية من اليوزرز علطول
  /// وبيتخطى الـ collection الفاضية أو اللي أرقامها أصفار عشان تضمن داتا حقيقية
  Future<List<Map<String, dynamic>>> fetchCategoriesRaw() async {
    // 1. بنجيب الكاتيجوريز المحسوبة ديناميكياً وفورياً من المينتورز المتاحين
    final dynamicCategories = await _buildCategoriesFromUsers();

    // 2. لو مفيش يوزرز خالص في الأبلكيشن لسه، كخطة احتياطية بنرجع الكاتيجوريز من الـ Collection (لو موجودة)
    if (dynamicCategories.isEmpty) {
      final snap = await _categories.get();
      if (snap.docs.isNotEmpty) {
        return snap.docs.map((doc) => {'id': doc.id, ...doc.data()}).toList();
      }
    }

    // دايماً بنفضل الأرقام الديناميكية الحقيقية
    return dynamicCategories;
  }

  Future<List<Map<String, dynamic>>> _buildCategoriesFromUsers() async {
    final snap = await _users.where('isPublic', isEqualTo: true).get();
    final allUsers = snap.docs.map((d) => UserModel.fromFirestore(d)).toList();

    final result = <Map<String, dynamic>>[];

    for (final categoryName in categorySkillsMap.keys) {
      final skillsLower = skillsInCategory(categoryName);

      // بنجيب لستة بأسماء المينتورز المقبولين في الكاتيجوري ده عشان نطبعهم ونشوفهم
      final matchedMentorsNames = allUsers
          .where(
            (user) => user.skillsCanTeach.any(
              (s) => skillsLower.contains(s.toLowerCase()),
            ),
          )
          .map((user) => user.username) // أو user.id
          .toList();

      print(
        "Category: $categoryName | Mentors Found: $matchedMentorsNames | Count: ${matchedMentorsNames.length}",
      );

      result.add({
        'id': categoryName,
        'name': categoryName,
        'count': matchedMentorsNames.length,
      });
    }

    result.sort((a, b) => (b['count'] as int).compareTo(a['count'] as int));
    return result;
  }
}

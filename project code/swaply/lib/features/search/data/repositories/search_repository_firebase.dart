import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:swaply/features/home/data/models/category_skills_map.dart';
import 'package:swaply/features/search/data/models/search_model.dart';
import 'package:swaply/features/search/data/repositories/search_repository.dart';

class FirebaseSearchRepository implements SearchRepository {
  final _db = FirebaseFirestore.instance;

  // Popular skills = أكتر skills موجودة في skillsCanTeach عند اليوزرز
  @override
  Future<List<SkillModel>> getPopularSkills() async {
    final snap = await _db
        .collection('users')
        .where('isPublic', isEqualTo: true)
        .get();

    final Map<String, int> skillCount = {};
    for (final doc in snap.docs) {
      final skills = List<String>.from(doc.data()['skillsCanTeach'] ?? []);
      for (final skill in skills) {
        skillCount[skill] = (skillCount[skill] ?? 0) + 1;
      }
    }

    final sorted = skillCount.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return sorted.take(8).toList().asMap().entries.map((entry) {
      final i = entry.key;
      final skill = entry.value;
      final tag = i == 0
          ? SkillTag.hot
          : i < 3
          ? SkillTag.newSkill
          : SkillTag.popular;

      return SkillModel(
        id: skill.key,
        name: skill.key,
        count: '${skill.value} mentor${skill.value == 1 ? '' : 's'}',
        tag: tag,
      );
    }).toList();
  }

  // البحث في username + skillsCanTeach
  // البحث في username + skillsCanTeach + دعم البحث الذكي عن الكاتيجوريز
  @override
  Future<List<SearchMentorModel>> searchMentors({required String query}) async {
    final q = query.trim().toLowerCase();

    // Firestore مش بيدعم full-text search ← بنجيب الـ public users وبنفلتر locally
    final snap = await _db
        .collection('users')
        .where('isPublic', isEqualTo: true)
        .get();

    // 1. تشييك ذكي: هل الكلمة اللي بنبحث عنها هي اسم كاتيجوري موجود في الـ map؟
    final isCategoryQuery = categorySkillsMap.keys.any(
      (key) => key.toLowerCase() == q,
    );

    List<String> allowedSkillsLower = [];
    if (isCategoryQuery) {
      // بنجيب اسم الكاتيجوري الأصلي بحالته الصحيحة (Capitalization)
      final matchedCategoryName = categorySkillsMap.keys.firstWhere(
        (key) => key.toLowerCase() == q,
      );
      // بنجيب الـ skillsLower الخاصة بيها باستخدام الـ helper method اللي عندكم
      allowedSkillsLower = skillsInCategory(matchedCategoryName);
    }

    final results = snap.docs
        .map((doc) => SearchMentorModel.fromUserDoc(doc.data(), doc.id))
        .where((m) {
          if (isCategoryQuery) {
            // لو بحث عن كاتيجوري: بنشوف هل الـ skill بتاعة الـ SearchMentorModel تنتمي للكاتيجوري دي؟
            return allowedSkillsLower.contains(m.skill.toLowerCase());
          } else {
            // الـ Logic القديم بتاعكم لو بحث عادي عن كلمة أو سكيل محددة
            return m.name.toLowerCase().contains(q) ||
                m.skill.toLowerCase().contains(q);
          }
        })
        .toList();

    // ترتيب: اللي اسمه يبدأ بالـ query الأول (بيشتغل في البحث العادي)
    if (!isCategoryQuery) {
      results.sort((a, b) {
        final aName = a.name.toLowerCase().startsWith(q) ? 0 : 1;
        final bName = b.name.toLowerCase().startsWith(q) ? 0 : 1;
        final aSkill = a.skill.toLowerCase().startsWith(q) ? 0 : 1;
        final bSkill = b.skill.toLowerCase().startsWith(q) ? 0 : 1;
        return (aName + aSkill).compareTo(bName + bSkill);
      });
    }

    return results;
  }
}

import '../models/search_model.dart';
import 'search_repository.dart';

class MockSearchRepository implements SearchRepository {
  @override
  Future<List<SkillModel>> getPopularSkills() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return const [
      SkillModel(id: 's1', name: 'UI/UX Design',     count: '48 mentors', tag: SkillTag.hot),
      SkillModel(id: 's2', name: 'Flutter & Mobile', count: '31 mentors', tag: SkillTag.newSkill),
      SkillModel(id: 's3', name: 'Spanish Tutoring', count: '22 mentors', tag: SkillTag.popular),
      SkillModel(id: 's4', name: 'Guitar Lessons',   count: '17 mentors', tag: SkillTag.popular),
      SkillModel(id: 's5', name: 'Data Science',     count: '40 mentors', tag: SkillTag.hot),
    ];
  }

  @override
  Future<List<SearchMentorModel>> searchMentors({required String query}) async {
    await Future.delayed(const Duration(milliseconds: 400));
    const all = [
      SearchMentorModel(id: 'm1', name: 'Sarah Chen',    skill: 'UI/UX Design',     rate: '60 pts/hr', rating: 4.9, online: true),
      SearchMentorModel(id: 'm2', name: 'James Wilson',  skill: 'Flutter & Mobile', rate: '75 pts/hr', rating: 4.8, online: true),
      SearchMentorModel(id: 'm3', name: 'Maria Lopez',   skill: 'Spanish Tutoring', rate: '40 pts/hr', rating: 5.0),
      SearchMentorModel(id: 'm4', name: 'Derek Knight',  skill: 'Guitar Lessons',   rate: '50 pts/hr', rating: 4.7),
      SearchMentorModel(id: 'm5', name: 'Priya Patel',   skill: 'Yoga & Meditation',rate: '45 pts/hr', rating: 4.9, online: true),
      SearchMentorModel(id: 'm6', name: 'Kenji Tanaka',  skill: 'React & TypeScript',rate: '70 pts/hr', rating: 4.8),
    ];
    final q = query.toLowerCase();
    return all.where((m) =>
      m.name.toLowerCase().contains(q) ||
      m.skill.toLowerCase().contains(q),
    ).toList();
  }
}

// 🔥 لما Firebase يتجهز
// class FirebaseSearchRepository implements SearchRepository {
//   final _db = FirebaseFirestore.instance;
//
//   @override
//   Future<List<SkillModel>> getPopularSkills() async {
//     final snap = await _db.collection('skills').orderBy('count', descending: true).limit(5).get();
//     return snap.docs.map((d) => SkillModel.fromFirestore(d.data(), d.id)).toList();
//   }
//
//   @override
//   Future<List<SearchMentorModel>> searchMentors({required String query}) async {
//     final snap = await _db.collection('mentors')
//       .where('searchTerms', arrayContains: query.toLowerCase()).get();
//     return snap.docs.map((d) => SearchMentorModel.fromFirestore(d.data(), d.id)).toList();
//   }
// }

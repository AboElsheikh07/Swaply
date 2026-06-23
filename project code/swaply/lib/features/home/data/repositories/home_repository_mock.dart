import '../models/mentor_model.dart';
import '../models/category_model.dart';
import 'home_repository.dart';

// ✅ دي الـ mock - بتشيلها وتحط FirebaseHomeRepository لما Auth يخلص
class MockHomeRepository implements HomeRepository {
  @override
  Future<List<MentorModel>> getTopMentors() async {
    await Future.delayed(const Duration(milliseconds: 500)); // simulate network
    return const [
      MentorModel(id: 'm1', name: 'Sarah Chen',    skill: 'UI/UX Design',      rate: '60 pts/hr', rating: 4.9, reviews: 142, online: true),
      MentorModel(id: 'm2', name: 'James Wilson',  skill: 'Flutter & Mobile',  rate: '75 pts/hr', rating: 4.8, reviews: 98,  online: true),
      MentorModel(id: 'm3', name: 'Maria Lopez',   skill: 'Spanish Tutoring',  rate: '40 pts/hr', rating: 5.0, reviews: 211),
      MentorModel(id: 'm4', name: 'Derek Knight',  skill: 'Guitar Lessons',    rate: '50 pts/hr', rating: 4.7, reviews: 74),
    ];
  }

  @override
  Future<List<MentorModel>> getRecommendedMentors() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return const [
      MentorModel(id: 'm5', name: 'Priya Patel',   skill: 'Yoga & Meditation', rate: '45 pts/hr', rating: 4.9, reviews: 163, online: true),
      MentorModel(id: 'm6', name: 'Kenji Tanaka',  skill: 'React & TypeScript',rate: '70 pts/hr', rating: 4.8, reviews: 119),
      MentorModel(id: 'm7', name: 'Amelia Clarke', skill: 'Public Speaking',   rate: '55 pts/hr', rating: 4.9, reviews: 88),
      MentorModel(id: 'm8', name: 'Omar Haddad',   skill: 'Photography',       rate: '50 pts/hr', rating: 4.7, reviews: 66),
    ];
  }

  @override
  Future<List<CategoryModel>> getCategories() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return const [
      CategoryModel(id: 'c1', name: 'Design & Creative',    count: 124),
      CategoryModel(id: 'c2', name: 'Development & Tech',   count: 238),
      CategoryModel(id: 'c3', name: 'Languages',            count: 86),
      CategoryModel(id: 'c4', name: 'Music & Audio',        count: 54),
      CategoryModel(id: 'c5', name: 'Wellness & Fitness',   count: 72),
      CategoryModel(id: 'c6', name: 'Business & Marketing', count: 91),
      CategoryModel(id: 'c7', name: 'Photography',          count: 48),
      CategoryModel(id: 'c8', name: 'Cooking & Lifestyle',  count: 63),
    ];
  }
}

// 🔥 لما Firebase يتجهز، اعمل الكلاس ده وبدّله في الـ cubit
// class FirebaseHomeRepository implements HomeRepository {
//   final _db = FirebaseFirestore.instance;
//
//   @override
//   Future<List<MentorModel>> getTopMentors() async {
//     final snap = await _db.collection('mentors').orderBy('rating', descending: true).limit(4).get();
//     return snap.docs.map((d) => MentorModel.fromFirestore(d.data(), d.id)).toList();
//   }
//   ...
// }

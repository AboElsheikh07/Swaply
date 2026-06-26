import '../models/mentor_details_model.dart';
import 'mentor_details_repository.dart';

class MockMentorDetailsRepository implements MentorDetailsRepository {
  @override
  Future<MentorDetailsModel> getMentorById({required String mentorId}) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return const MentorDetailsModel(
      id: 'm1',
      name: 'Sarah Chen',
      skill: 'UI/UX Design',
      rate: '60 pts/hr',
      rating: 4.9,
      reviews: 142,
      online: true,
      pricePerHour: 60,
      bio: 'Senior product designer with 6+ years crafting intuitive mobile and web experiences. '
          'I love breaking down complex design systems and helping learners build their eye for great UI.',
      skills: ['Figma', 'Design Systems', 'Prototyping', 'User Research', 'Accessibility'],
    );
  }

  @override
  Future<List<ReviewModel>> getMentorReviews({required String mentorId}) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return const [
      ReviewModel(name: 'Emma K.', text: 'Super clear explanations and patient. Booked another session already!', rating: 5.0),
      ReviewModel(name: 'David L.', text: 'Exactly what I needed. Walked me through Figma tokens end-to-end.', rating: 5.0),
    ];
  }
}

// 🔥 لما Firebase يتجهز
// class FirebaseMentorDetailsRepository implements MentorDetailsRepository {
//   final _db = FirebaseFirestore.instance;
//
//   @override
//   Future<MentorDetailsModel> getMentorById({required String mentorId}) async {
//     final doc = await _db.collection('mentors').doc(mentorId).get();
//     return MentorDetailsModel.fromFirestore(doc.data()!, doc.id);
//   }
//
//   @override
//   Future<List<ReviewModel>> getMentorReviews({required String mentorId}) async { ... }
// }

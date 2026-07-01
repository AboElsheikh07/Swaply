import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:swaply/features/user/data/datasources/user_remote_data_source.dart';
import 'package:swaply/features/user/data/models/user_model.dart';

// ✅ حطينا الـ Class هنا عشان السيستم كله يشوفه علطول وميطلعش Error
class MentorAvailability {
  final List<String> upcomingSlots; // أقرب 3 مواعيد متاحة بصيغة قابلة للعرض
  final int totalSessions; // عدد الـ sessions المكتملة فعلياً

  const MentorAvailability({
    required this.upcomingSlots,
    required this.totalSessions,
  });

  factory MentorAvailability.empty() =>
      const MentorAvailability(upcomingSlots: [], totalSessions: 0);
}

class MentorDetailsRepository {
  final UserRemoteDataSource _remote = UserRemoteDataSource();
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<UserModel> getMentor(String uid) async {
    final user = await _remote.fetchUser(uid);
    if (user == null) throw Exception("Mentor not found");
    return user;
  }

  // ✅ بيحسب الـ sessions المكتملة الفردية + بيجيب أقرب المواعيد المتاحة
  Future<MentorAvailability> getAvailability(String mentorId) async {
    int totalCompleted = 0;
    List<String> slots = [];

    // 1. حساب الـ sessions المكتملة
    try {
      final completedSnap = await _db
          .collection('sessions')
          .where('teacherId', isEqualTo: mentorId)
          .where('status', isEqualTo: 'completed')
          .get();
      totalCompleted = completedSnap.docs.length;
    } catch (e) {
      print("Error fetching completed sessions: $e");
    }

    // 2. جلب المواعيد القادمة (pending/accepted)
    try {
      final upcomingSnap = await _db
          .collection('sessions')
          .where('teacherId', isEqualTo: mentorId)
          .where('status', whereIn: ['accepted', 'pending'])
          .orderBy('scheduledAt')
          .limit(3)
          .get();

      slots = upcomingSnap.docs
          .map((doc) {
            final ts = doc.data()['scheduledAt'] as Timestamp?;
            if (ts == null) return null;
            return _formatSlot(ts.toDate());
          })
          .whereType<String>()
          .toList();
    } catch (e) {
      print("Firestore Index required for upcoming slots: $e");
    }

    return MentorAvailability(
      upcomingSlots: slots,
      totalSessions: totalCompleted, // هيرجع الرقم الفعلي الحقيقي هنا دايماً
    );
  }

  String _formatSlot(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(date.year, date.month, date.day);
    final diff = target.difference(today).inDays;

    final hour = date.hour % 12 == 0 ? 12 : date.hour % 12;
    final minute = date.minute.toString().padLeft(2, '0');
    final period = date.hour >= 12 ? 'PM' : 'AM';
    final time = '$hour:$minute $period';

    if (diff == 0) return 'Today $time';
    if (diff == 1) return 'Tomorrow $time';

    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return '${days[date.weekday - 1]} $time';
  }
}

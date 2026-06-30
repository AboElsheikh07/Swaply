import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:swaply/features/user/data/datasources/user_remote_data_source.dart';
import 'package:swaply/features/user/data/models/user_model.dart';

// ✅ بيانات إضافية محسوبة، مش مخزنة جاهزة في الـ user doc
class MentorAvailability {
  final List<String> upcomingSlots; // أقرب 3 مواعيد متاحة بصيغة قابلة للعرض
  final int totalSessions;          // عدد الـ sessions المكتملة فعلياً

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

    if (user == null) {
      throw Exception("Mentor not found");
    }

    return user;
  }

  // ✅ بيحسب الـ sessions المكتملة + بيجيب أقرب المواعيد المتاحة (pending/accepted)
  //    للمينتور ده من sessions collection بدل الأرقام الوهمية
  Future<MentorAvailability> getAvailability(String mentorId) async {
    try {
      final sessionsRef = _db.collection('sessions');

      final completedSnap = await sessionsRef
          .where('teacherId', isEqualTo: mentorId)
          .where('status', isEqualTo: 'completed')
          .get();

      final upcomingSnap = await sessionsRef
          .where('teacherId', isEqualTo: mentorId)
          .where('status', whereIn: ['accepted', 'pending'])
          .orderBy('scheduledAt')
          .limit(3)
          .get();

      final slots = upcomingSnap.docs.map((doc) {
        final ts = doc.data()['scheduledAt'] as Timestamp?;
        if (ts == null) return null;
        return _formatSlot(ts.toDate());
      }).whereType<String>().toList();

      return MentorAvailability(
        upcomingSlots: slots,
        totalSessions: completedSnap.docs.length,
      );
    } catch (_) {
      // لو الـ index لسه مش متعمول أو فيه مشكلة، نرجع قيم فاضية بدل ما نكسر الشاشة
      return MentorAvailability.empty();
    }
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

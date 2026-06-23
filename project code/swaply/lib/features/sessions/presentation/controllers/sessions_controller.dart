import 'dart:async';
import 'package:get/get.dart';
import '../../data/models/session_model.dart';
import '../../data/repositories/session_repository.dart';

/// Drives both SessionsPage and RequestSessionPage.
class SessionsController extends GetxController {
  final SessionRepository _repo;
  final String currentUid;

  SessionsController({
    required this.currentUid,
    SessionRepository? repo,
  }) : _repo = repo ?? SessionRepository();

  // ── Streams ──────────────────────────────────
  final incoming = <SessionItem>[].obs;
  final myRequests = <SessionItem>[].obs;

  StreamSubscription? _incomingSub;
  StreamSubscription? _myRequestsSub;

  // ── Request-Session form state ───────────────
  final selectedSkill   = ''.obs;
  final selectedDate    = Rx<DateTime?>(null);
  final selectedTime    = ''.obs;
  final selectedMinutes = 60.obs;

  final isLoading  = false.obs;
  final errorMsg   = Rx<String?>(null);
  final confirmed  = false.obs;    // true after successful request

  // ── Lifecycle ────────────────────────────────

  @override
  void onInit() {
    super.onInit();
    // _listenIncoming();
    // _listenMyRequests();
  }

  @override
  void onClose() {
    _incomingSub?.cancel();
    _myRequestsSub?.cancel();
    super.onClose();
  }

  // void _listenIncoming() {
  //   _incomingSub = _repo
  //       .watchIncomingRequests(currentUid)
  //       .listen((list) => incoming.assignAll(list));
  }

  // void _listenMyRequests() {
  //   _myRequestsSub = _repo
  //       .watchMyRequests(currentUid)
  //       .listen((list) => myRequests.assignAll(list));
  // }

  // ── Accept / Decline ─────────────────────────

  Future<void> accept(String sessionId) async {
    try {
      // await _repo.acceptSession(sessionId);
    } catch (e) {
      // errorMsg.value = 'Could not accept session. Try again.';
    }
  }

  Future<void> decline(String sessionId) async {
    try {
      // await _repo.declineSession(sessionId);
    } catch (e) {
      // errorMsg.value = 'Could not decline session. Try again.';
    }
  }

  // ── Request new session ──────────────────────

  /// Called from RequestSessionPage after user taps Confirm.
  Future<void> requestSession({
    required String teacherId,
    required String teacherName,
    required String teacherAvatar,
    required String studentName,
    required String studentAvatar,
    required int pricePerHour,
    required String? message,
  }) async {
    // final date = selectedDate.value;
    // final time = selectedTime.value;

    // if (date == null || time.isEmpty || selectedSkill.value.isEmpty) {
      // errorMsg.value = 'Please fill in all fields.';
    //   return;
    // }

    // isLoading.value = true;
    // errorMsg.value  = null;

  //   try {
  //     final scheduledAt = _mergeDateTime(date, time);
  //     final points = ((pricePerHour * selectedMinutes.value) / 60).round();

  //     await _repo.requestSession(
  //       studentId:       currentUid,
  //       teacherId:       teacherId,
  //       studentName:     studentName,
  //       teacherName:     teacherName,
  //       studentAvatar:   studentAvatar,
  //       teacherAvatar:   teacherAvatar,
  //       skill:           selectedSkill.value,
  //       scheduledAt:     scheduledAt,
  //       durationMinutes: selectedMinutes.value,
  //       points:            points,
  //       message:         message,
  //     );

  //     confirmed.value = true;
  //   } catch (e) {
  //     errorMsg.value = 'Failed to send request. Please try again.';
  //   } finally {
  //     isLoading.value = false;
  //   }
  // }

  // void resetForm() {
  //   selectedSkill.value   = '';
  //   selectedDate.value    = null;
  //   selectedTime.value    = '';
  //   selectedMinutes.value = 60;
  //   confirmed.value       = false;
  //   errorMsg.value        = null;
  // }

  // ── Helpers ──────────────────────────────────

  /// Parses "2:30 PM" and merges with a date.
  DateTime _mergeDateTime(DateTime date, String timeStr) {
    final parts = timeStr.split(RegExp(r'[:\s]'));
    var hour    = int.parse(parts[0]);
    final min   = int.parse(parts[1]);
    final pm    = parts[2].toUpperCase() == 'PM';
    if (pm && hour != 12) hour += 12;
    if (!pm && hour == 12) hour = 0;
    return DateTime(date.year, date.month, date.day, hour, min);
  }

  /// Cost based on current form selection and teacher's hourly rate.
  // int computeCost(int pricePerHour) =>
      // ((pricePerHour * selectedMinutes.value) / 60).round();
}

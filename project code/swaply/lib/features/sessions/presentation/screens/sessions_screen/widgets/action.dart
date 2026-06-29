import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:swaply/features/sessions/presentation/controllers/cubit/sessions_cubit.dart';
import 'package:swaply/features/sessions/presentation/screens/scheduled_session_screen/scheduled_session_screen.dart';
import 'package:swaply/features/sessions/presentation/screens/sessions_screen/widgets/rate_dialog.dart';
import '../../../../data/models/session_model.dart';
import 'package:flutter/cupertino.dart';
import 'buttons.dart';
import '../../../../../../core/constants/app_colors.dart';

class ActionWidget extends StatelessWidget {
  final SessionItem session;
  const ActionWidget({super.key, required this.session});

  String get _currentUid => FirebaseAuth.instance.currentUser!.uid;

  @override
  Widget build(BuildContext context) {
    // ── Join window takes priority over everything ──
    // When scheduledAt arrives (±5 min buffer), always show Join regardless
    // of which tab the user is on or what other status the session has.
    if (session.isTimeToJoin) {
      return PrimaryBtn(
        icon: CupertinoIcons.videocam_fill,
        label: 'Join Session',
        onTap: () {
          // session.id == the Firestore doc ID == the Zego callID
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ScheduledCallPage(
                callID: session.id,
                currentUserId: _currentUid,
                currentUserName: session.isOutgoing
                    ? session.studentName
                    : session.teacherName,
              ),
            ),
          );
        },
      );
    }

    switch (session.status) {
      // ── Accepted but not time yet → show countdown ─
      case SessionStatus.accepted:
      case SessionStatus.ongoing:
        return _quietLabel(context, 'Starts ${session.formattedTime}');

      // ── Pending ───────────────────────────────
      case SessionStatus.pending:
        // Incoming request (I am the teacher) → Accept / Decline
        if (!session.isOutgoing) {
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              OutlineBtn(
                label: 'Decline',
                icon: Icons.close,
                onTap: () =>
                    context.read<SessionsCubit>().decline(session.id),
              ),
              const SizedBox(width: 8),
              PrimaryBtn(
                icon: Icons.check_rounded,
                label: 'Accept',
                onTap: () =>
                    context.read<SessionsCubit>().accept(session.id),
              ),
            ],
          );
        }

        // Outgoing request (I am the student) → Cancel
        return OutlineBtn(
          label: 'Cancel',
          icon: Icons.close,
          onTap: () => _confirmCancel(context),
        );

      // ── Rejected ──────────────────────────────
      case SessionStatus.rejected:
        return _quietLabel(context, 'Declined');

      // ── Cancelled → show label + Delete button ─
      case SessionStatus.cancelled:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _quietLabel(context, 'Cancelled'),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () => _confirmDelete(context),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFEDED),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.delete_outline, color: Colors.red.shade400, size: 15),
                    const SizedBox(width: 5),
                    Text(
                      'Delete',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.red.shade400,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );

      // ── Completed ─────────────────────────────
      case SessionStatus.completed:
        return _buildCompletedAction(context);
    }
  }

  // ── Cancel confirmation dialog ────────────────

  void _confirmCancel(BuildContext context) {
    final cubit = context.read<SessionsCubit>();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Cancel Session'),
        content: const Text(
            'Are you sure you want to cancel this session request?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              cubit.cancel(session.id);
            },
            child: const Text(
              'Yes, Cancel',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  // ── Delete confirmation dialog ────────────────

  void _confirmDelete(BuildContext context) {
    final cubit = context.read<SessionsCubit>();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Session'),
        content: const Text(
            'This will permanently remove the session. This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              cubit.delete(session.id);
            },
            child: const Text(
              'Yes, Delete',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  // ── Quiet status label ────────────────────────

  Widget _quietLabel(BuildContext context, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: Theme.of(context).extension<AppColorTheme>()!.muted,
        ),
      ),
    );
  }

  // ── Completed: rate action ────────────────────

  Widget _buildCompletedAction(BuildContext context) {
    final colors = Theme.of(context).extension<AppColorTheme>()!;
    final uid = _currentUid;

    if (session.hasRated(uid)) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFFF3F4F6),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_circle_outline, color: colors.muted, size: 16),
            const SizedBox(width: 6),
            Text(
              'Rated',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: colors.muted,
              ),
            ),
          ],
        ),
      );
    }

    final isTeacher = session.roleFor(uid) == SessionRole.teacher;
    final otherName = session.personNameFor(uid);
    final myRole = isTeacher ? 'teacher' : 'student';
    final rateeId = isTeacher ? session.studentId : session.teacherId;
    final label = isTeacher ? 'Rate Student' : 'Rate Teacher';

    return GestureDetector(
      onTap: () => RateDialog.show(
        context,
        name: otherName,
        skill: session.skill,
        role: isTeacher ? 'student' : 'teacher',
        onSubmit: (stars, review) {
          context.read<SessionsCubit>().submitRating(
                sessionId: session.id,
                rateeId: rateeId,
                role: myRole,
                stars: stars,
                review: review,
              );
        },
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: colors.amberBg,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.star_outline_rounded, color: colors.amber, size: 16),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: colors.amber,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
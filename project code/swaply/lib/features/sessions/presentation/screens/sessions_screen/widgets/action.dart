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
import 'package:swaply/l10n/app_localizations.dart';

class ActionWidget extends StatelessWidget {
  final SessionItem session;
  const ActionWidget({super.key, required this.session});

  String get _currentUid => FirebaseAuth.instance.currentUser!.uid;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    // ── Join window takes priority over everything ──
    // When scheduledAt arrives (±5 min buffer), always show Join regardless
    // of which tab the user is on or what other status the session has.
    if (session.isTimeToJoin) {
      return PrimaryBtn(
        icon: CupertinoIcons.videocam_fill,
        label: l10n.joinSession,
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
        return _quietLabel(context, l10n.startsAt(session.formattedTime));

      // ── Pending ───────────────────────────────
      case SessionStatus.pending:
        // Incoming request (I am the teacher) → Accept / Decline
        if (!session.isOutgoing) {
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              OutlineBtn(
                label: l10n.btnDecline,
                icon: Icons.close,
                onTap: () =>
                    context.read<SessionsCubit>().decline(session.id),
              ),
              const SizedBox(width: 8),
              PrimaryBtn(
                icon: Icons.check_rounded,
                label: l10n.btnAccept,
                onTap: () =>
                    context.read<SessionsCubit>().accept(session.id),
              ),
            ],
          );
        }

        // Outgoing request (I am the student) → Cancel
        return OutlineBtn(
          label: l10n.cancel,
          icon: Icons.close,
          onTap: () => _confirmCancel(context),
        );

      // ── Rejected ──────────────────────────────
      case SessionStatus.rejected:
        return _quietLabel(context, l10n.actionDeclined);

      // ── Cancelled → show label + Delete button ─
      case SessionStatus.cancelled:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _quietLabel(context, l10n.statusCancelled),
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
                      l10n.btnDelete,
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
    final l10n = AppLocalizations.of(context)!;
    final cubit = context.read<SessionsCubit>();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(l10n.cancelSession),
        content: Text(l10n.cancelSessionConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.btnNo),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              cubit.cancel(session.id);
            },
            child: Text(
              l10n.btnYesCancel,
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  // ── Delete confirmation dialog ────────────────

  void _confirmDelete(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final cubit = context.read<SessionsCubit>();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(l10n.deleteSession),
        content: Text(l10n.deleteSessionConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.btnNo),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              cubit.delete(session.id);
            },
            child: Text(
              l10n.btnYesDelete,
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
    final l10n = AppLocalizations.of(context)!;
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
              l10n.rated,
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
    final label = isTeacher ? l10n.rateStudent : l10n.rateTeacher;

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
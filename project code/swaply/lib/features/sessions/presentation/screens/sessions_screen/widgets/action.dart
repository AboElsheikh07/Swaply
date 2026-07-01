import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:swaply/features/sessions/presentation/controllers/cubit/sessions_cubit.dart';
import 'package:swaply/features/sessions/presentation/controllers/cubit/sessions_state.dart';
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
    // ✅ watch cubit state so widget rebuilds on every emit
    return BlocBuilder<SessionsCubit, SessionsState>(
      builder: (context, state) {
        // get the latest version of this session from state
        final current = _latestSession(state) ?? session;
        return _buildAction(context, current);
      },
    );
  }

  // ── Find the latest version of this session in state ──
  SessionItem? _latestSession(SessionsState state) {
    List<SessionItem> incoming = [];
    List<SessionItem> myRequests = [];

    if (state is SessionsLoaded) {
      incoming = state.incoming;
      myRequests = state.myRequests;
    } else if (state is SessionsActionLoading) {
      incoming = state.incoming;
      myRequests = state.myRequests;
    }

    final all = [...incoming, ...myRequests];
    try {
      return all.firstWhere((s) => s.id == session.id);
    } catch (_) {
      return null; // session was deleted
    }
  }

  Widget _buildAction(BuildContext context, SessionItem current) {
    final l10n = AppLocalizations.of(context)!;

    if (current.isTimeToJoin) {
      return PrimaryBtn(
        icon: CupertinoIcons.videocam_fill,
        label: l10n.joinSession,
        onTap: () {
          context.read<SessionsCubit>().notifyJoined(current);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ScheduledCallPage(
                callID: current.id,
                currentUserId: _currentUid,
                currentUserName: current.isOutgoing
                    ? current.studentName
                    : current.teacherName,
              ),
            ),
          );
        },
      );
    }

    switch (current.status) {
      case SessionStatus.accepted:
      case SessionStatus.ongoing:
        return _quietLabel(context, l10n.startsAt(current.formattedTime));

      case SessionStatus.pending:
        if (!current.isOutgoing) {
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              OutlineBtn(
                label: l10n.btnDecline,
                icon: Icons.close,
                onTap: () => context.read<SessionsCubit>().decline(current.id),
              ),
              const SizedBox(width: 6),
              PrimaryBtn(
                icon: Icons.check_rounded,
                label: l10n.btnAccept,
                onTap: () => context.read<SessionsCubit>().accept(current.id),
              ),
            ],
          );
        }
        return OutlineBtn(
          label: l10n.cancel,
          icon: Icons.close,
          onTap: () => _confirmCancel(context, current),
        );

      case SessionStatus.rejected:
      case SessionStatus.cancelled:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _quietLabel(context, l10n.statusCancelled),
            const SizedBox(width: 6),
            GestureDetector(
              onTap: () => _confirmDelete(context, current),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFEDED),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.delete_outline,
                        color: Colors.red.shade400, size: 15),
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

      case SessionStatus.completed:
        return _buildCompletedAction(context, current);
    }
  }

  void _confirmCancel(BuildContext context, SessionItem current) {
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
              cubit.cancel(current.id);
            },
            child: Text(l10n.btnYesCancel,
                style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, SessionItem current) {
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
              cubit.delete(current.id);
            },
            child: Text(l10n.btnYesDelete,
                style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

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

  Widget _buildCompletedAction(BuildContext context, SessionItem current) {
    final l10n = AppLocalizations.of(context)!;
    final colors = Theme.of(context).extension<AppColorTheme>()!;
    final uid = _currentUid;

    if (current.hasRated(uid)) {
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
    final otherName = current.personNameFor(uid);
    final myRole    = isTeacher ? 'teacher' : 'student';
    final rateeId   = isTeacher ? current.studentId : current.teacherId;
    final label     = isTeacher ? l10n.rateStudent : l10n.rateTeacher;

    return GestureDetector(
      onTap: () => RateDialog.show(
        context,
        name: otherName,
        skill: current.skill,
        role: isTeacher ? 'student' : 'teacher',
        onSubmit: (stars, review) {
          context.read<SessionsCubit>().submitRating(
            sessionId: current.id,
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
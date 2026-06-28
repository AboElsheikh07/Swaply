import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:swaply/features/sessions/presentation/controllers/cubit/sessions_cubit.dart';
import 'package:swaply/features/sessions/presentation/widgets/rate_dialog.dart';
import '../../data/models/session_model.dart';
import 'package:flutter/cupertino.dart';
import 'buttons.dart';
import '../../../../core/constants/app_colors.dart';

class ActionWidget extends StatelessWidget {
  final SessionItem session;
  const ActionWidget({super.key, required this.session});

  // Swap this for however your app exposes the logged-in user (e.g. an
  // AuthCubit) if you have one — using FirebaseAuth directly to match the
  // pattern already used elsewhere (e.g. OnboardingRemoteDataSourceImpl).
  String get _currentUid => FirebaseAuth.instance.currentUser!.uid;

  @override
  Widget build(BuildContext context) {
    switch (session.status) {
      case SessionStatus.accepted:
      case SessionStatus.ongoing:
        return PrimaryBtn(
          icon: CupertinoIcons.videocam_fill,
          label: 'Join Session',
          onTap: () {},
        );

      case SessionStatus.pending:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            OutlineBtn(label: 'Decline', icon: Icons.close, onTap: () {}),
            const SizedBox(width: 8),
            PrimaryBtn(
              icon: Icons.check_rounded,
              label: 'Accept',
              onTap: () {},
            ),
          ],
        );
      case SessionStatus.rejected:
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFFF3F4F6),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            'Cancelled',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).extension<AppColorTheme>()!.muted,
            ),
          ),
        );

      case SessionStatus.completed:
        return _buildCompletedAction(context);
    }
  }

  Widget _buildCompletedAction(BuildContext context) {
    final colors = Theme.of(context).extension<AppColorTheme>()!;
    final uid = _currentUid;

    // Already rated — show a quiet confirmation instead of the action.
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
    // I'm rating the *other* participant — a teacher rates the student
    // and vice versa.
    final otherName = session.personNameFor(uid);
    final myRole = isTeacher ? 'teacher' : 'student';
    final rateeId = isTeacher ? session.studentId : session.teacherId;
    final label = isTeacher ? 'Rate Student' : 'Rate Teacher';

    return GestureDetector(
      onTap: () => RateDialog.show(
        context,
        name: otherName,
        skill: session.skill,
        role: isTeacher ? 'student' : 'teacher', // who's being rated
        onSubmit: (stars, review) {
          context.read<SessionsCubit>().submitRating(
                sessionId: session.id,
                rateeId: rateeId,
                role: myRole, // who's doing the rating
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
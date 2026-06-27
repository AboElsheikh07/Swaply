import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:swaply/core/constants/app_colors.dart';
import 'package:swaply/features/sessions/data/models/session_model.dart';
import 'package:swaply/features/sessions/presentation/controllers/cubit/sessions_cubit.dart';
import 'package:swaply/features/sessions/presentation/widgets/action.dart';
import 'package:swaply/features/sessions/presentation/widgets/buttons.dart';
import 'package:swaply/features/sessions/presentation/widgets/points_label.dart';
import 'package:swaply/features/sessions/presentation/widgets/session_status_badge.dart';

class SessionCard extends StatelessWidget {
  final SessionItem session;
  const SessionCard({super.key, required this.session});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColorTheme>()!;
    final cubit  = context.read<SessionsCubit>(); // ✅ captured before any async

    // Show the other party's name depending on direction
    final otherName = session.isOutgoing
        ? session.teacherName
        : session.studentName;

    return Container(
      decoration: BoxDecoration(
        color:        Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(18),
        border:       Border.all(color: colors.border),
        boxShadow: [
          BoxShadow(
            color:      Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset:     const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // ── Top section ───────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Avatar
                Container(
                  width:  52,
                  height: 52,
                  decoration: BoxDecoration(
                    color:        colors.primarySoft,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    CupertinoIcons.person_fill,
                    color: colors.primary,
                    size:  26,
                  ),
                ),
                const SizedBox(width: 12),

                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        otherName,
                        style: TextStyle(
                          fontSize:   15,
                          fontWeight: FontWeight.bold,
                          color:      colors.text,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        session.skill,
                        style: TextStyle(fontSize: 13, color: colors.muted),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing:            4,
                        runSpacing:         4,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Icon(CupertinoIcons.calendar,
                              size: 13, color: colors.muted),
                          Text(
                            session.formattedDate, // ✅ uses model helper
                            style: TextStyle(fontSize: 12, color: colors.muted),
                          ),
                          const SizedBox(width: 6),
                          Icon(CupertinoIcons.clock,
                              size: 13, color: colors.muted),
                          Text(
                            session.formattedDuration, // ✅ uses model helper
                            style: TextStyle(fontSize: 12, color: colors.muted),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                StatusBadge(status: session.status),
              ],
            ),
          ),

          // ── Divider ───────────────────────
          Divider(height: 1, color: colors.border),

          // ── Bottom section ────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
            child: session.status == SessionStatus.pending && !session.isOutgoing
                // ✅ Only incoming pending sessions show Accept/Decline
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      PointsLabel(session: session),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: OutlineBtn(
                              label: 'Decline',
                              icon:  Icons.close,
                              onTap: () => cubit.decline(session.id),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: PrimaryBtn(
                              icon:  Icons.check_rounded,
                              label: 'Accept',
                              onTap: () => cubit.accept(session.id),
                            ),
                          ),
                        ],
                      ),
                    ],
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      PointsLabel(session: session),
                      ActionWidget(session: session),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}
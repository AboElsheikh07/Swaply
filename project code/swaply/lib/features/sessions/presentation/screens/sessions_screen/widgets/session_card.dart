import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:swaply/core/constants/app_colors.dart';
import 'package:swaply/features/sessions/data/models/session_model.dart';
import 'package:swaply/features/sessions/presentation/screens/sessions_screen/widgets/action.dart';
import 'package:swaply/features/sessions/presentation/screens/sessions_screen/widgets/points_label.dart';
import 'package:swaply/features/sessions/presentation/screens/sessions_screen/widgets/session_status_badge.dart';

class SessionCard extends StatelessWidget {
  final SessionItem session;
  const SessionCard({super.key, required this.session});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColorTheme>()!;

    final otherName = session.isOutgoing
        ? session.teacherName
        : session.studentName;

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
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
                // ── Avatar ───────────────────────────
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: colors.primarySoft,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: () {
                    final avatarUrl = session.isOutgoing
                        ? session.teacherAvatar
                        : session.studentAvatar;

                    if (avatarUrl.isNotEmpty) {
                      return Image.network(
                        avatarUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => Icon(
                          CupertinoIcons.person_fill,
                          color: colors.primary,
                          size: 26,
                        ),
                      );
                    }

                    return Icon(
                      CupertinoIcons.person_fill,
                      color: colors.primary,
                      size: 26,
                    );
                  }(),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        otherName,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: colors.text,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        session.skill,
                        style: TextStyle(fontSize: 13, color: colors.muted),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 4,
                        runSpacing: 4,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Icon(
                            CupertinoIcons.calendar,
                            size: 13,
                            color: colors.muted,
                          ),
                          Text(
                            session.formattedDate,
                            style: TextStyle(fontSize: 12, color: colors.muted),
                          ),
                          const SizedBox(width: 6),
                          Icon(
                            CupertinoIcons.clock,
                            size: 13,
                            color: colors.muted,
                          ),
                          Text(
                            session.formattedDuration,
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
            child: Row(
              children: [
                PointsLabel(session: session),
                const SizedBox(width: 8),
                Expanded(
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: ActionWidget(session: session),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

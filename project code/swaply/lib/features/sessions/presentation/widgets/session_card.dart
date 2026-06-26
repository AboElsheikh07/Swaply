import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:swaply/features/sessions/presentation/widgets/action.dart';
import 'session_status_badge.dart';
import 'points_label.dart';
import 'package:swaply/features/sessions/data/models/session_model.dart';
import 'package:swaply/core/constants/app_colors.dart';
import 'package:swaply/features/sessions/presentation/widgets/buttons.dart';

class SessionCard extends StatelessWidget {
  final SessionItem session;
  const SessionCard({super.key, required this.session});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Theme.of(context).extension<AppColorTheme>()!.border),
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
          // ── Top section ──────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Avatar
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEEECFB),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    CupertinoIcons.person_fill,
                    color: Theme.of(context).extension<AppColorTheme>()!.primary,
                    size: 26,
                  ),
                ),
                const SizedBox(width: 12),
                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        session.teacherName,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).extension<AppColorTheme>()!.text,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        session.skill,
                        style: TextStyle(
                          fontSize: 13,
                          color: Theme.of(context).extension<AppColorTheme>()!.muted,
                        ),
                      ),
                      const SizedBox(height: 8),
                      // AFTER — wraps to next line if needed
                      Wrap(
                        spacing: 4,
                        runSpacing: 4,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Icon(
                            CupertinoIcons.calendar,
                            size: 13,
                            color: Theme.of(context).extension<AppColorTheme>()!.muted,
                          ),
                          Text(
                            session.skill,
                            style: TextStyle(
                              fontSize: 12,
                              color: Theme.of(context).extension<AppColorTheme>()!.muted,
                            ),
                          ),
                          SizedBox(width: 6),
                          Icon(
                            CupertinoIcons.clock,
                            size: 13,
                            color: Theme.of(context).extension<AppColorTheme>()!.muted,
                          ),
                          Text(
                            session.durationMinutes.toString(),
                            style: TextStyle(
                              fontSize: 12,
                              color: Theme.of(context).extension<AppColorTheme>()!.muted,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Status badge
                StatusBadge(status: session.status),
              ],
            ),
          ),

          // ── Divider ──────────────────────
          Divider(height: 1, color: Theme.of(context).extension<AppColorTheme>()!.border),

          // ── Bottom section ───────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
            child: session.status == SessionStatus.pending
                // Pending: stack points on top, buttons on bottom full-width
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      PointsLabel(session: session),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: Center(
                              child: OutlineBtn(
                                label: 'Decline',
                                icon: Icons.close,
                                onTap: () {
                                  
                                },
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Center(
                              child: PrimaryBtn(
                                icon: Icons.check_rounded,
                                label: 'Accept',
                                onTap: () {},
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  )
                // All other statuses: points left, action right
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

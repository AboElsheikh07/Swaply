import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../data/models/session_model.dart';
import '../controllers/sessions_controller.dart';
import 'session_status_badge.dart';
import 'session_action_buttons.dart';
import '../../../../core/constants/app_colors.dart';

class SessionCard extends StatelessWidget {
  final SessionModel session;
  final String currentUid;

  const SessionCard({
    super.key,
    required this.session,
    required this.currentUid,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<SessionsController>();
    final role = session.roleFor(currentUid);
    final isIncoming = role == SessionRole.teacher;
    final personName = session.personNameFor(currentUid);
    final personAvatar = session.personAvatarFor(currentUid);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // ── Top Row ─────────────────────────
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Avatar(name: personName, avatarUrl: personAvatar),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  personName,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.text,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 1),
                                Text(
                                  session.skill,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppColors.muted,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          SessionStatusBadge(
                            status: session.status,
                            isIncoming: isIncoming,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(
                            Icons.calendar_month_outlined,
                            size: 13,
                            color: AppColors.muted,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${session.formattedDate} · ${session.formattedTime}',
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.muted,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Icon(
                            Icons.access_time_outlined,
                            size: 13,
                            color: AppColors.muted,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            session.formattedDuration,
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.muted,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),
            const Divider(color: AppColors.border, height: 1),
            const SizedBox(height: 12),

            // ── Bottom Row ───────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _CostLabel(cost: session.cost, isIncoming: isIncoming),
                SessionActionButtons(
                  session: session,
                  isIncoming: isIncoming,
                  onAccept: () => controller.accept(session.id),
                  onDecline: () => controller.decline(session.id),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── Private sub-widgets ──────────────────────────

class _Avatar extends StatelessWidget {
  final String name;
  final String avatarUrl;

  const _Avatar({required this.name, required this.avatarUrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: avatarUrl.isNotEmpty
          ? ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(avatarUrl, fit: BoxFit.cover),
            )
          : Center(
              child: Text(
                name.isNotEmpty ? name[0].toUpperCase() : '?',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ),
    );
  }
}

class _CostLabel extends StatelessWidget {
  final int cost;
  final bool isIncoming;

  const _CostLabel({required this.cost, required this.isIncoming});

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: isIncoming ? '+$cost pts' : '$cost pts',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: isIncoming ? AppColors.green : AppColors.text,
            ),
          ),
          TextSpan(
            text: isIncoming ? ' earnings' : ' total',
            style: const TextStyle(fontSize: 12, color: AppColors.muted),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../../data/models/session_model.dart';
import '../../../../core/constants/app_colors.dart';



class StatusBadge extends StatelessWidget {
  final SessionStatus status;
  const StatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final cfg = _badgeConfig(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: cfg.bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (status == SessionStatus.ongoing) ...[
            Container(
              width: 7,
              height: 7,
              decoration: const BoxDecoration(
                color: AppColors.green,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 5),
          ],
          Text(
            cfg.label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: cfg.fg,
            ),
          ),
        ],
      ),
    );
  }

  _BadgeCfg _badgeConfig(SessionStatus s) {
    switch (s) {
      case SessionStatus.accepted:
        return _BadgeCfg(AppColors.skyBg, AppColors.sky, 'Accepted');
      case SessionStatus.ongoing:
        return _BadgeCfg(AppColors.greenBg, AppColors.green, 'Ongoing');
      case SessionStatus.pending:
        return _BadgeCfg(AppColors.amberBg, AppColors.amber, 'Pending');
      case SessionStatus.completed:
        return _BadgeCfg(const Color(0xFFF3F4F6), AppColors.muted, 'Completed');

      case SessionStatus.rejected:
        return _BadgeCfg(const Color(0xFFF3F4F6), AppColors.rose, 'Rejected');  

    }
  }
}

class _BadgeCfg {
  final Color bg, fg;
  final String label;
  const _BadgeCfg(this.bg, this.fg, this.label);
}

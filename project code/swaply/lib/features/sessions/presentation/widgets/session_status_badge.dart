import 'package:flutter/material.dart';
import '../../data/models/session_model.dart';
import '../../../../core/constants/app_colors.dart';

class SessionStatusBadge extends StatelessWidget {
  final SessionStatus status;
  final bool isIncoming;

  const SessionStatusBadge({
    super.key,
    required this.status,
    required this.isIncoming,
  });

  @override
  Widget build(BuildContext context) {
    final config = _badgeConfig(status, isIncoming);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: config.bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: config.showPulse
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _PulseDot(color: config.fg),
                const SizedBox(width: 4),
                Text(
                  config.label,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: config.fg,
                  ),
                ),
              ],
            )
          : Text(
              config.label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: config.fg,
              ),
            ),
    );
  }

  _BadgeConfig _badgeConfig(SessionStatus status, bool isIncoming) {
    // Student-side shows "Waiting" instead of "Pending"
    if (!isIncoming && status == SessionStatus.pending) {
      return _BadgeConfig(
        label: 'Waiting',
        bg: AppColors.amberBg,
        fg: AppColors.amber,
      );
    }

    switch (status) {
      case SessionStatus.pending:
        return _BadgeConfig(
          label: 'Pending',
          bg: AppColors.amberBg,
          fg: AppColors.amber,
        );
      case SessionStatus.accepted:
        return _BadgeConfig(
          label: 'Accepted',
          bg: AppColors.skyBg,
          fg: AppColors.sky,
        );
      case SessionStatus.rejected:
      case SessionStatus.cancelled:
        return _BadgeConfig(
          label: 'Rejected',
          bg: AppColors.roseBg,
          fg: AppColors.rose,
        );
      case SessionStatus.completed:
        return _BadgeConfig(
          label: 'Completed',
          bg: const Color(0xFFF3F4F6),
          fg: AppColors.muted,
        );
      case SessionStatus.ongoing:
        return _BadgeConfig(
          label: 'Ongoing',
          bg: AppColors.greenBg,
          fg: AppColors.green,
          showPulse: true,
        );
    }
  }
}

class _BadgeConfig {
  final String label;
  final Color bg;
  final Color fg;
  final bool showPulse;

  const _BadgeConfig({
    required this.label,
    required this.bg,
    required this.fg,
    this.showPulse = false,
  });
}

/// Animated pulsing dot for "Ongoing" status.
class _PulseDot extends StatefulWidget {
  final Color color;
  const _PulseDot({required this.color});

  @override
  State<_PulseDot> createState() => _PulseDotState();
}

class _PulseDotState extends State<_PulseDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _anim = Tween<double>(begin: 0.3, end: 1.0).animate(_ctrl);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => FadeTransition(
    opacity: _anim,
    child: Container(
      width: 7,
      height: 7,
      decoration: BoxDecoration(color: widget.color, shape: BoxShape.circle),
    ),
  );
}

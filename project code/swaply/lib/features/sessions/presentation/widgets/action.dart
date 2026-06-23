import 'package:flutter/material.dart';
import '../../data/models/session_model.dart';
import 'package:flutter/cupertino.dart';
import 'buttons.dart';
import '../../../../core/constants/app_colors.dart';

class ActionWidget extends StatelessWidget {
  final SessionItem session;
  const ActionWidget({super.key, required this.session});

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

      case SessionStatus.waiting:
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFFF3F4F6),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Text(
            'Waiting',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.muted,
            ),
          ),
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
          child: const Text(
            'Rejected',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.rose,
            ),
          ),
        );

      case SessionStatus.completed:
        return GestureDetector(
          onTap: () {},
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.amberBg,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.star_outline_rounded,
                  color: AppColors.amber,
                  size: 16,
                ),
                SizedBox(width: 6),
                Text(
                  'Rate Student',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.amber,
                  ),
                ),
              ],
            ),
          ),
        );
    }
  }
}

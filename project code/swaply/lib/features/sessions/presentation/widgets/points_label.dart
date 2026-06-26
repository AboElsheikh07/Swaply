import 'package:flutter/material.dart';
import '../../data/models/session_model.dart';
import '../../../../core/constants/app_colors.dart';

class PointsLabel extends StatelessWidget {
  final SessionItem session;
  const PointsLabel({super.key, required this.session});

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: session.isOutgoing
                ? '${session.points} pts'
                : '+${session.points} pts',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: session.isOutgoing ? Theme.of(context).extension<AppColorTheme>()!.text : Theme.of(context).extension<AppColorTheme>()!.green,
            ),
          ),
          TextSpan(
            text: session.isOutgoing ? ' total' : ' earnings',
            style: TextStyle(
              fontSize: 13,
              color: Theme.of(context).extension<AppColorTheme>()!.muted,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}


import 'package:flutter/material.dart';
import 'package:swaply/core/constants/extensions/theme_extention.dart';

class Header extends StatelessWidget {
  final String mentorName;
  const Header({super.key, required this.mentorName});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 12, 20, 0),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: Icon(Icons.arrow_back, color: colors.text),
          ),
          const SizedBox(width: 4),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Request Session',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: colors.text,
                ),
              ),
              Text(
                'with $mentorName',
                style: TextStyle(fontSize: 12, color: colors.muted),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
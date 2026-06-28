
import 'package:flutter/material.dart';
import 'package:swaply/core/constants/extensions/theme_extention.dart';


class BigBtn extends StatelessWidget {
  final String label;
  final bool filled;
  final VoidCallback onTap;
  const BigBtn({super.key, 
    required this.label,
    required this.filled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 52,
        width: double.infinity,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: filled ? colors.primary : colors.background,
          borderRadius: BorderRadius.circular(26),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: filled ? Colors.white : colors.text,
          ),
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:swaply/core/constants/extensions/theme_extention.dart';

class CostRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const CostRow({super.key, 
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(icon, size: 15, color: colors.muted),
            const SizedBox(width: 6),
            Text(label, style: TextStyle(fontSize: 13, color: colors.muted)),
          ],
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: colors.text,
          ),
        ),
      ],
    );
  }
}

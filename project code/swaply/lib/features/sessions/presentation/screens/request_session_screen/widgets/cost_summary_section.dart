
import 'package:flutter/material.dart';
import 'package:swaply/core/constants/extensions/theme_extention.dart';
import 'package:swaply/features/sessions/presentation/screens/request_session_screen/shared_atoms/cost_raw.dart';

class CostSummary extends StatelessWidget {
  final int pricePerHour;
  final int userPoints;
  final int cost;
  final bool canAfford;
  final bool isLoadingBalance;
  final int selectedMinutes;

  const CostSummary({super.key, 
    required this.pricePerHour,
    required this.userPoints,
    required this.cost,
    required this.canAfford,
    required this.isLoadingBalance,
    required this.selectedMinutes,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        children: [
          CostRow(
            icon: Icons.monetization_on_outlined,
            label: 'Price per hour',
            value: '$pricePerHour pts',
          ),
          const SizedBox(height: 8),
          CostRow(
            icon: Icons.access_time_outlined,
            label: 'Duration',
            value: '$selectedMinutes min',
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Divider(color: colors.border, height: 1),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total cost',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: colors.text,
                ),
              ),
              Text(
                '$cost pts',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: colors.primary,
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Divider(color: colors.border, height: 1),
          ),
          Row(
            children: [
              Text(
                'Your balance: ',
                style: TextStyle(fontSize: 12, color: colors.muted),
              ),
              if (isLoadingBalance)
                SizedBox(
                  width: 12,
                  height: 12,
                  child: CircularProgressIndicator(
                    strokeWidth: 1.5,
                    color: colors.muted,
                  ),
                )
              else
                Text(
                  '$userPoints pts',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: colors.text,
                  ),
                ),
              if (!isLoadingBalance && !canAfford) ...[
                const SizedBox(width: 8),
                Text(
                  'Not enough points',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: colors.rose,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

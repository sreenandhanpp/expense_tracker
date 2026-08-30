import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../utils/app_spacing.dart';
import '../utils/app_typography.dart';
import 'weekly_bar_chart.dart';

class SpendingSummaryCard extends StatelessWidget {
  final double totalSpending;
  final List<double> dailyTotals;
  final String currencySymbol;

  const SpendingSummaryCard({
    super.key,
    required this.totalSpending,
    required this.dailyTotals,
    this.currencySymbol = '₹',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: AppSpacing.cardPadding,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24.0),
        border: Border.all(color: AppColors.border, width: 1.0),
        boxShadow: const [
          BoxShadow(
            color: Color(0x05000000),
            blurRadius: 12.0,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Total Spending',
            style: AppTypography.titleSmall.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '$currencySymbol${totalSpending.toStringAsFixed(2)}',
            style: AppTypography.displayLarge,
          ),
          const SizedBox(height: 16),
          WeeklyBarChart(
            dailyTotals: dailyTotals,
          ),
        ],
      ),
    );
  }
}

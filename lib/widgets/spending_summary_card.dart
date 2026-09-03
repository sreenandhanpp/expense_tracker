import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../utils/app_spacing.dart';
import '../utils/app_typography.dart';
import '../utils/date_formatter.dart';
import 'weekly_bar_chart.dart';

class SpendingSummaryCard extends StatelessWidget {
  final double displayedSpending;
  final List<double> dailyTotals;
  final String currencySymbol;
  final int? selectedIndex;
  final ValueChanged<int>? onDayTap;
  final VoidCallback? onTotalSpendingTap;
  final String? weekRangeText;

  const SpendingSummaryCard({
    super.key,
    required this.displayedSpending,
    required this.dailyTotals,
    this.currencySymbol = '₹',
    this.selectedIndex,
    this.onDayTap,
    this.onTotalSpendingTap,
    this.weekRangeText,
  });

  @override
  Widget build(BuildContext context) {
    final titleText = selectedIndex != null
        ? '${DateFormatter.getWeekdayName(selectedIndex!)} Spending'
        : 'Total Spending';

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
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onTotalSpendingTap,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          titleText,
                          style: AppTypography.titleSmall.copyWith(
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        if (selectedIndex != null) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.textPrimary.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'Tap to reset',
                              style: AppTypography.labelSmall.copyWith(
                                fontSize: 9,
                                color: AppColors.textMuted,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 6),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 250),
                      transitionBuilder: (child, animation) {
                        return FadeTransition(
                          opacity: animation,
                          child: SlideTransition(
                            position: Tween<Offset>(
                              begin: const Offset(0.0, 0.1),
                              end: Offset.zero,
                            ).animate(animation),
                            child: child,
                          ),
                        );
                      },
                      child: Text(
                        '$currencySymbol${displayedSpending.toStringAsFixed(2)}',
                        key: ValueKey<String>('$titleText-$displayedSpending'),
                        style: AppTypography.displayLarge,
                      ),
                    ),
                  ],
                ),
                if (weekRangeText != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Text(
                      weekRangeText!,
                      style: AppTypography.labelSmall.copyWith(
                        fontSize: 10,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          WeeklyBarChart(
            dailyTotals: dailyTotals,
            selectedIndex: selectedIndex,
            onDayTap: onDayTap,
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../data/expense_repository.dart';
import '../utils/app_colors.dart';
import '../utils/app_spacing.dart';
import '../utils/app_typography.dart';

class InsightsScreen extends StatelessWidget {
  final ExpenseRepository repository;

  const InsightsScreen({
    super.key,
    required this.repository,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: repository,
      builder: (context, _) {
        final weekTotal = repository.totalSpendingThisWeek;
        final monthTotal = repository.totalSpendingThisMonth;
        final yearTotal = repository.totalSpendingThisYear;
        final topCat = repository.topCategory;

        return Scaffold(
          backgroundColor: AppColors.background,
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Trends',
                    style: AppTypography.titleLarge.copyWith(fontSize: 24),
                  ),
                  const SizedBox(height: 16),

                  // Card 1: This Week
                  _buildInsightCard('This Week', '₹${weekTotal.toStringAsFixed(2)}'),
                  const SizedBox(height: 16),

                  // Card 2: This Month
                  _buildInsightCard('This Month', '₹${monthTotal.toStringAsFixed(2)}'),
                  const SizedBox(height: 16),

                  // Card 3: This Year
                  _buildInsightCard('This Year', '₹${yearTotal.toStringAsFixed(2)}'),
                  const SizedBox(height: 16),

                  // Card 4: Top Category
                  if (topCat != null)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Column(
                        children: [
                          Text(
                            'Top Category',
                            style: AppTypography.titleSmall.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(topCat.icon, size: 22, color: AppColors.textPrimary),
                              const SizedBox(width: 8),
                              Text(
                                topCat.label,
                                style: AppTypography.titleLarge.copyWith(fontSize: 22),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildInsightCard(String title, String amount) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border),
        boxShadow: const [
          BoxShadow(
            color: Color(0x04000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            title,
            style: AppTypography.titleSmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            amount,
            style: AppTypography.displayLarge,
          ),
        ],
      ),
    );
  }
}

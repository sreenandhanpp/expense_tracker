import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../utils/app_spacing.dart';
import '../utils/app_typography.dart';

class EmptyStateWidget extends StatelessWidget {
  final VoidCallback onAddPressed;

  const EmptyStateWidget({
    super.key,
    required this.onAddPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: AppSpacing.xxxl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'No expenses yet',
              style: AppTypography.titleLarge.copyWith(fontSize: 18),
            ),
            const SizedBox(height: 8),
            Text(
              'Start tracking your spending.',
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            OutlinedButton.icon(
              onPressed: onAddPressed,
              icon: const Icon(Icons.add, size: 18, color: AppColors.textPrimary),
              label: Text(
                'Add expense',
                style: AppTypography.button.copyWith(color: AppColors.textPrimary),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.textPrimary, width: 1.2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../models/expense.dart';
import '../utils/app_colors.dart';
import '../utils/app_typography.dart';
import '../utils/date_formatter.dart';

class ExpenseTile extends StatelessWidget {
  final Expense expense;
  final VoidTapCallback? onTap;
  final String currencySymbol;
  final bool showCategorySubtitle;

  const ExpenseTile({
    super.key,
    required this.expense,
    this.onTap,
    this.currencySymbol = '₹',
    this.showCategorySubtitle = true,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      splashColor: AppColors.splash,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 4.0),
        child: Row(
          children: [
            // Category Icon Badge Box
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.iconBackground,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                expense.category.icon,
                size: 20,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(width: 14),

            // Expense Title & Subtitle Column
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    expense.title,
                    style: AppTypography.titleMedium.copyWith(
                      fontSize: 15,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    showCategorySubtitle
                        ? expense.category.label
                        : DateFormatter.formatShort(expense.date),
                    style: AppTypography.bodySmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            // Amount Column
            Text(
              '$currencySymbol${expense.amount.toStringAsFixed(2)}',
              style: AppTypography.titleMedium.copyWith(
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
typedef VoidTapCallback = void Function();

import 'package:flutter/material.dart';
import '../models/expense.dart';
import '../utils/app_colors.dart';
import '../utils/app_typography.dart';
import '../utils/date_formatter.dart';
import 'add_expense_screen.dart';

class ExpenseDetailSheet extends StatelessWidget {
  final Expense expense;
  final VoidCallback onDelete;
  final ValueChanged<Expense> onUpdate;

  const ExpenseDetailSheet({
    super.key,
    required this.expense,
    required this.onDelete,
    required this.onUpdate,
  });

  static Future<void> show(
    BuildContext context, {
    required Expense expense,
    required VoidCallback onDelete,
    required ValueChanged<Expense> onUpdate,
  }) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return ExpenseDetailSheet(
          expense: expense,
          onDelete: onDelete,
          onUpdate: onUpdate,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.divider,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Header Icon & Title
            Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: AppColors.iconBackground,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    expense.category.icon,
                    size: 26,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        expense.title,
                        style: AppTypography.titleLarge.copyWith(fontSize: 22),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        DateFormatter.formatShort(expense.date),
                        style: AppTypography.bodySmall.copyWith(fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Amount Display
            Text(
              '₹${expense.amount.toStringAsFixed(2)}',
              style: AppTypography.displayLarge.copyWith(fontSize: 36),
            ),

            const SizedBox(height: 24),
            const Divider(color: AppColors.divider),
            const SizedBox(height: 16),

            // Details Rows
            _buildDetailRow('Category', expense.category.label, expense.category.icon),
            const SizedBox(height: 12),
            _buildDetailRow('Payment Method', expense.paymentMethod.label, expense.paymentMethod.icon),
            const SizedBox(height: 12),
            _buildDetailRow('Date', DateFormatter.formatShort(expense.date), Icons.calendar_today),

            const SizedBox(height: 32),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      onDelete();
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: const BorderSide(color: Color(0xFFE53935)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(
                      'Delete',
                      style: AppTypography.button.copyWith(color: const Color(0xFFE53935)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      Navigator.pop(context);
                      final updated = await Navigator.push<Expense>(
                        context,
                        MaterialPageRoute(
                          builder: (_) => AddExpenseScreen(editingExpense: expense),
                        ),
                      );
                      if (updated != null) {
                        onUpdate(updated);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.textPrimary,
                      foregroundColor: AppColors.surface,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(
                      'Edit',
                      style: AppTypography.button.copyWith(color: AppColors.surface),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.textSecondary),
        const SizedBox(width: 10),
        Text(
          label,
          style: AppTypography.bodySmall.copyWith(fontSize: 14),
        ),
        const Spacer(),
        Text(
          value,
          style: AppTypography.titleMedium.copyWith(fontSize: 14),
        ),
      ],
    );
  }
}

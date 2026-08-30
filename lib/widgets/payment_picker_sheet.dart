import 'package:flutter/material.dart';
import '../models/expense.dart';
import '../utils/app_colors.dart';
import '../utils/app_typography.dart';

class PaymentPickerSheet extends StatelessWidget {
  final PaymentMethod? selectedMethod;
  final ValueChanged<PaymentMethod> onSelect;

  const PaymentPickerSheet({
    super.key,
    required this.selectedMethod,
    required this.onSelect,
  });

  static Future<PaymentMethod?> show(
    BuildContext context,
    PaymentMethod? currentMethod,
  ) {
    return showModalBottomSheet<PaymentMethod>(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return PaymentPickerSheet(
          selectedMethod: currentMethod,
          onSelect: (method) => Navigator.pop(context, method),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
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
            const SizedBox(height: 16),
            Text(
              'Select Payment Method',
              style: AppTypography.titleLarge.copyWith(fontSize: 18),
            ),
            const SizedBox(height: 16),
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: PaymentMethod.values.length,
                separatorBuilder: (context, index) => const Divider(height: 1, color: AppColors.divider),
                itemBuilder: (context, index) {
                  final method = PaymentMethod.values[index];
                  final isSelected = method == selectedMethod;
                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                    leading: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.textPrimary : AppColors.iconBackground,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        method.icon,
                        size: 18,
                        color: isSelected ? AppColors.surface : AppColors.textPrimary,
                      ),
                    ),
                    title: Text(
                      method.label,
                      style: AppTypography.titleMedium.copyWith(
                        fontSize: 15,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      ),
                    ),
                    trailing: isSelected
                        ? const Icon(Icons.check, color: AppColors.textPrimary, size: 20)
                        : null,
                    onTap: () => onSelect(method),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

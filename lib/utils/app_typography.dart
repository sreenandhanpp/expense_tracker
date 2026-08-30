import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Typography hierarchy matching the reference screenshots' clean, bold, editorial look.
class AppTypography {
  AppTypography._();

  /// Hero title / Display amount (e.g. ₹120.38)
  static const TextStyle displayLarge = TextStyle(
    fontSize: 32.0,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    letterSpacing: -0.8,
    height: 1.15,
  );

  /// Main section header (e.g. Total Spending, Latest)
  static const TextStyle titleLarge = TextStyle(
    fontSize: 20.0,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    letterSpacing: -0.4,
  );

  /// Medium title (e.g. Expense Item Title, Card Headers)
  static const TextStyle titleMedium = TextStyle(
    fontSize: 16.0,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    letterSpacing: -0.2,
  );

  /// Subtle header (e.g. Total Spending small label, group date header like Monday)
  static const TextStyle titleSmall = TextStyle(
    fontSize: 14.0,
    fontWeight: FontWeight.w600,
    color: AppColors.textSecondary,
    letterSpacing: 0.1,
  );

  /// Standard body text
  static const TextStyle bodyMedium = TextStyle(
    fontSize: 15.0,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
  );

  /// Secondary subtitle text (e.g. Date, Category under title)
  static const TextStyle bodySmall = TextStyle(
    fontSize: 13.0,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
  );

  /// Micro text for chart x-axis, subtle badges
  static const TextStyle labelSmall = TextStyle(
    fontSize: 12.0,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
  );

  /// Button text style
  static const TextStyle button = TextStyle(
    fontSize: 14.0,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );
}

import 'package:flutter/material.dart';

/// Centralized color palette matching the minimal off-white reference design.
class AppColors {
  AppColors._();

  /// Primary off-white background
  static const Color background = Color(0xFFFAFAFA);

  /// Off-white slightly gray secondary background for pills/containers
  static const Color backgroundSecondary = Color(0xFFF2F2F5);

  /// Pure white background for cards
  static const Color surface = Color(0xFFFFFFFF);

  /// Main text & key structural elements (Black)
  static const Color textPrimary = Color(0xFF111111);

  /// Secondary text (Subtle Gray)
  static const Color textSecondary = Color(0xFF707070);

  /// Light tertiary text / placeholders
  static const Color textMuted = Color(0xFFA0A0A0);

  /// Dividers and thin subtle borders
  static const Color divider = Color(0xFFE8E8E8);

  /// Subtle gray border for cards
  static const Color border = Color(0xFFEFEFEF);

  /// Icon badge background box
  static const Color iconBackground = Color(0xFFF4F4F6);

  /// Primary Accent color (black for buttons/FABs)
  static const Color primary = Color(0xFF111111);

  /// Card/FAB press highlight
  static const Color splash = Color(0x10000000);
}

import 'package:flutter/material.dart';

class AppColors {
  // Brand and semantic colors
  static const Color primary = Color(0xFFFF9800);
  static const Color secondary = Color(0xFF263238);
  static const Color background = Color(0xFFF5F5F5);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFF263238);
  static const Color textSecondary = Color(0xFF607D8B);
  static const Color success = Color(0xFF00C853);
  static const Color error = Color(0xFFE91E63);
  static const Color warning = Color(0xFFFFC107);
  static const Color info = Color(0xFF2196F3);

  // Semantic Aliases
  static Color get cardShadow => Colors.black.withValues(alpha: 0.05);
  static Color get divider => grey.withValues(alpha: 0.2);
  static Color get inputFill => Colors.grey.shade100;
  static Color get iconBackground => primary.withValues(alpha: 0.1);
  static Color get promoGradientStart => primary;
  static Color get promoGradientEnd => const Color(0xFFFF5722);

  // Shared UI colors
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color grey = Color(0xFF808080);
  static const Color lightGrey = Color(0xFFF5F5F5);
  static const Color darkGrey = Color(0xFF607D8B);
  static const Color blue = Color(0xFF2196F3);
  static const Color red = Color(0xFFF44336);
  static const Color green = Color(0xFF4CAF50);
  static const Color teal = Color(0xFF009688);
  static const Color purple = Color(0xFF9C27B0);
  static const Color darkNavy = Color(0xFF1A1F36);
  static const Color lightBlue = Color(0xFFE3F2FD);
  static const Color lightGreen = Color(0xFFE8F5E9);
  static const Color lightOrange = Color(0xFFFFF3E0);
  static const Color accentOrange = Color(0xFFFF5722);
}

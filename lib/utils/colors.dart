import 'package:flutter/material.dart';

class AppColors {
  // Primary Colors
  static const Color primary = Color(0xFF155E63); // Teal
  static const Color primaryDark = Color(0xFF0D3B3F);
  static const Color primaryLight = Color(0xFF2E9DA7);

  // Secondary Colors
  static const Color secondary = Color(0xFFF39C12); // Orange
  static const Color secondaryLight = Color(0xFFF8B84E);
  static const Color secondaryDark = Color(0xFFD68910);

  // Neutral Colors
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color grey = Color(0xFF757575);
  static const Color greyLight = Color(0xFFF5F5F5);
  static const Color greyLighter = Color(0xFFEEEEEE);
  static const Color greyDark = Color(0xFF424242);

  // Status Colors
  static const Color success = Color(0xFF4CAF50);
  static const Color successLight = Color(0xFFC8E6C9);
  static const Color error = Color(0xFFFF5252);
  static const Color errorLight = Color(0xFFFFCDD2);
  static const Color warning = Color(0xFFFFC107);
  static const Color warningLight = Color(0xFFFFF9C4);
  static const Color info = Color(0xFF2196F3);
  static const Color infoLight = Color(0xFFBBDEFB);

  // Paid/Unpaid Status
  static const Color paid = Color(0xFF4CAF50);
  static const Color unpaid = Color(0xFFFF5252);
  static const Color overdue = Color(0xFFFFC107);

  // Dark Mode Colors
  static const Color darkBg = Color(0xFF121212);
  static const Color darkBgSecondary = Color(0xFF1E1E1E);
  static const Color darkBgTertiary = Color(0xFF2C2C2C);
  static const Color darkText = Color(0xFFE0E0E0);
  static const Color darkTextSecondary = Color(0xFFB0B0B0);

  // Transparency
  static Color primaryWithOpacity(double opacity) =>
      primary.withOpacity(opacity);
  static Color whiteWithOpacity(double opacity) =>
      white.withOpacity(opacity);
  static Color blackWithOpacity(double opacity) =>
      black.withOpacity(opacity);
}

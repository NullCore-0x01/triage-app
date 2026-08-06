// lib/core/constants/app_colors.dart

import 'package:flutter/material.dart';

class AppColors {
  // ألوان الفرز الخمسة
  static const Color triageRed = Color(0xFFE53935); // أحمر
  static const Color triageOrange = Color(0xFFF57C00); // برتقالي (جديد)
  static const Color triageYellow = Color(0xFFFFB300); // أصفر
  static const Color triageGreen = Color(0xFF43A047); // أخضر
  static const Color triageBlack = Color(0xFF212121); // أسود

  static const Color primary = Color(0xFF1976D2);
  static const Color background = Color(0xFFF5F7FA);
  static const Color surface = Colors.white;
  static const Color textPrimary = Color(0xFF2C3E50);
  static const Color textSecondary = Color(0xFF7F8C8D);

  static Color getColorForSeverity(String colorCode) {
    switch (colorCode) {
      case 'RED':
        return triageRed;
      case 'ORANGE':
        return triageOrange; // 🟢 إضافة البرتقالي
      case 'YELLOW':
        return triageYellow;
      case 'GREEN':
        return triageGreen;
      case 'BLACK':
        return triageBlack; // 🟢 إضافة الأسود
      default:
        return Colors.grey;
    }
  }
}

import 'package:flutter/material.dart';

import 'app_theme.dart';

Color departmentBadgeColor(String department) {
  switch (department.trim().toLowerCase()) {
    case 'engineering':
      return const Color(0xFF4F8CFF);
    case 'product':
      return const Color(0xFFFFB84D);
    case 'operations':
      return const Color(0xFF35C49A);
    case 'marketing':
      return const Color(0xFFEC6AA8);
    case 'hr':
    case 'human resources':
      return const Color(0xFFB68DFF);
    case 'finance':
      return const Color(0xFF34D399);
    case 'design':
      return const Color(0xFFFB923C);
    default:
      return AppTheme.violet;
  }
}

List<Color> departmentGradientColors(String department) {
  switch (department.trim().toLowerCase()) {
    case 'engineering':
      return const [Color(0xFF4F8CFF), Color(0xFF818CF8)];
    case 'product':
      return const [Color(0xFFFFB84D), Color(0xFFFCD34D)];
    case 'operations':
      return const [Color(0xFF35C49A), Color(0xFF6EE7B7)];
    case 'marketing':
      return const [Color(0xFFEC6AA8), Color(0xFFF9A8D4)];
    case 'hr':
    case 'human resources':
      return const [Color(0xFFB68DFF), Color(0xFFC4B5FD)];
    case 'finance':
      return const [Color(0xFF34D399), Color(0xFF6EE7B7)];
    case 'design':
      return const [Color(0xFFFB923C), Color(0xFFFCD34D)];
    default:
      return [AppTheme.violet, AppTheme.cyan];
  }
}

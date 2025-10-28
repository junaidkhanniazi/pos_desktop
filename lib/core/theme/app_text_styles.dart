import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppText {
  // Headings
  static const TextStyle h1 = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    color: AppColors.textDark,
    letterSpacing: -0.5,
  );

  static const TextStyle h2 = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w600,
    color: AppColors.textDark,
  );

  static const TextStyle h3 = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.textDark,
  );

  // Body
  static const TextStyle body = TextStyle(
    fontSize: 15,
    color: AppColors.textMedium,
    fontWeight: FontWeight.w400,
  );

  static const TextStyle small = TextStyle(
    fontSize: 13,
    color: AppColors.textLight,
  );

  static const TextStyle button = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w600,
    color: Colors.white,
  );
}

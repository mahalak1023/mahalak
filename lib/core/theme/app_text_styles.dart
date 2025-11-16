import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Central text styles for Mahallak app using Cairo font
class AppTextStyles {
  // Prevent instantiation
  AppTextStyles._();

  /// Main page titles and large headings
  static TextStyle get headlineLarge => const TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: AppColors.darkGrey,
        fontFamily: 'Arial',
      );

  /// Section headers like "العروض", "متاجر قريبة منك"
  static TextStyle get sectionTitle => const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: AppColors.darkGrey,
        fontFamily: 'Arial',
      );

  /// Normal readable text for paragraphs and content
  static TextStyle get body => const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.normal,
        color: AppColors.darkGrey,
        fontFamily: 'Arial',
      );

  /// Secondary information or helper text
  static TextStyle get secondary => TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.normal,
        color: AppColors.darkGrey.withValues(alpha: 0.7),
        fontFamily: 'Arial',
      );

  /// Very small labels, badges, hints
  static TextStyle get caption => TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.normal,
        color: AppColors.darkGrey.withValues(alpha: 0.6),
        fontFamily: 'Arial',
      );

  /// Small headings for forms and cards
  static TextStyle get headlineSmall => const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: AppColors.darkGrey,
        fontFamily: 'Arial',
      );

  /// Button text style
  static TextStyle get button => const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: AppColors.white,
        fontFamily: 'Arial',
      );

  /// App bar title style
  static TextStyle get appBarTitle => const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: AppColors.darkGrey,
        fontFamily: 'Arial',
      );
}

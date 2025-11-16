import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Central text styles for Mahallak app using Cairo font
class AppTextStyles {
  // Prevent instantiation
  AppTextStyles._();

  /// Main page titles and large headings
  static TextStyle get headlineLarge => GoogleFonts.cairo(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: AppColors.darkGrey,
      );

  /// Section headers like "العروض", "متاجر قريبة منك"
  static TextStyle get sectionTitle => GoogleFonts.cairo(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: AppColors.darkGrey,
      );

  /// Normal readable text for paragraphs and content
  static TextStyle get body => GoogleFonts.cairo(
        fontSize: 16,
        fontWeight: FontWeight.normal,
        color: AppColors.darkGrey,
      );

  /// Secondary information or helper text
  static TextStyle get secondary => GoogleFonts.cairo(
        fontSize: 14,
        fontWeight: FontWeight.normal,
        color: AppColors.darkGrey.withValues(alpha: 0.7),
      );

  /// Very small labels, badges, hints
  static TextStyle get caption => GoogleFonts.cairo(
        fontSize: 12,
        fontWeight: FontWeight.normal,
        color: AppColors.darkGrey.withValues(alpha: 0.6),
      );

  /// Button text style
  static TextStyle get button => GoogleFonts.cairo(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: AppColors.white,
      );

  /// App bar title style
  static TextStyle get appBarTitle => GoogleFonts.cairo(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: AppColors.darkGrey,
      );
}

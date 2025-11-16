import 'package:flutter/material.dart';
import 'package:myapp/core/theme/app_colors.dart';

class AppSecondaryButton extends StatelessWidget {
  const AppSecondaryButton({
    super.key,
    required this.text,
    this.onPressed,
  });

  final String text;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.accentTeal,
        side: const BorderSide(color: AppColors.accentTeal),
      ),
      child: Text(text),
    );
  }
}

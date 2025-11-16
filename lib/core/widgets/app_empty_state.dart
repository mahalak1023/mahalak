import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:myapp/core/widgets/app_primary_button.dart';

class AppEmptyState extends StatelessWidget {
  const AppEmptyState({
    super.key,
    required this.title,
    required this.description,
    this.buttonText,
    this.onButtonPressed,
    this.lottieAssetPath,
  });

  final String title;
  final String description;
  final String? buttonText;
  final VoidCallback? onButtonPressed;
  final String? lottieAssetPath;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (lottieAssetPath != null)
              Lottie.asset(
                lottieAssetPath!,
                width: 200,
                height: 200,
                fit: BoxFit.contain,
              ),
            const SizedBox(height: 24),
            Text(
              title,
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              description,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            if (buttonText != null && onButtonPressed != null)
              AppPrimaryButton(
                text: buttonText!,
                onPressed: onButtonPressed,
              ),
          ],
        ),
      ),
    );
  }
}

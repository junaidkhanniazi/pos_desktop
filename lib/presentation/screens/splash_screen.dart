import 'package:flutter/material.dart';
import 'package:pos_desktop/core/theme/app_colors.dart';
import 'package:pos_desktop/core/theme/app_text_styles.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "POS System",
              style: AppText.h1.copyWith(color: AppColors.primary),
            ),
            const SizedBox(height: 20),
            const CircularProgressIndicator(color: AppColors.primary),
            const SizedBox(height: 20),
            Text("Loading workspace...", style: AppText.small),
          ],
        ),
      ),
    );
  }
}

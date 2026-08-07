// ignore_for_file: file_names

import 'package:e_comm/controllers/apple-sign-in-controller.dart';
import 'package:e_comm/controllers/google-sign-in-controller.dart';
import 'package:e_comm/screens/auth-ui/sign-in-screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_radius.dart';

class WelcomeScreen extends StatelessWidget {
  WelcomeScreen({super.key});

  final GoogleSignInController _googleSignInController =
      Get.put(GoogleSignInController());
  final AppleSignInController _appleSignInController =
      Get.put(AppleSignInController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              vertical: AppSpacing.xl,
              horizontal: AppSpacing.lg,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(
                  height: 200,
                  child: Lottie.asset('assets/images/splash-icon.json'),
                ),
                const SizedBox(height: AppSpacing.md),
                const Text(
                  'Sunder Garments',
                  style: TextStyle(
                    fontSize: 22.0,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                const Text(
                  'Wholesale ordering, made simple',
                  style: TextStyle(fontSize: 14.0, color: AppColors.textSecondary),
                ),
                const SizedBox(height: AppSpacing.xxl),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    icon: Image.asset(
                      'assets/images/final-google-logo.png',
                      width: 20,
                      height: 20,
                    ),
                    label: const Text('Sign in with Google'),
                    onPressed: () {
                      _googleSignInController.signInWithGoogle();
                    },
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                // Apple requires their own official button - Human
                // Interface Guidelines don't allow restyling this to
                // match app branding the way the other two buttons
                // are. Matched the corner radius to AppRadius.lg
                // (same as every other button in the app) since
                // that's the one visual property Apple does allow
                // customizing.
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: SignInWithAppleButton(
                    onPressed: () {
                      _appleSignInController.signInWithApple();
                    },
                    style: SignInWithAppleButtonStyle.black,
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.email_outlined),
                    label: const Text('Sign in with email'),
                    onPressed: () {
                      Get.to(() => SignInScreen());
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

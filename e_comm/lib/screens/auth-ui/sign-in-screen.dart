// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, avoid_unnecessary_containers, unused_local_variable, unnecessary_null_comparison, file_names

import 'package:e_comm/controllers/get-user-data-controller.dart';
import 'package:e_comm/controllers/sign-in-controller.dart';
import 'package:e_comm/screens/admin-panel/admin-main-screen.dart';
import 'package:e_comm/screens/auth-ui/forget-password-screen.dart';
import 'package:e_comm/screens/auth-ui/sign-up-screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final SignInController signInController = Get.put(SignInController());
  final GetUserDataController getUserDataController =
      Get.put(GetUserDataController());
  TextEditingController userEmail = TextEditingController();
  TextEditingController userPassword = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return KeyboardVisibilityBuilder(builder: (context, isKeyboardVisible) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text('Sign in'),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            children: [
              if (!isKeyboardVisible) ...[
                SizedBox(
                  height: 160,
                  child: Lottie.asset('assets/images/splash-icon.json'),
                ),
                const SizedBox(height: AppSpacing.lg),
              ] else
                const SizedBox(height: AppSpacing.md),
              TextFormField(
                controller: userEmail,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email_outlined),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Obx(
                () => TextFormField(
                  controller: userPassword,
                  obscureText: signInController.isPasswordVisible.value,
                  keyboardType: TextInputType.visiblePassword,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      onPressed: () {
                        signInController.isPasswordVisible.toggle();
                      },
                      icon: Icon(
                        signInController.isPasswordVisible.value
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                    ),
                  ),
                ),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    Get.to(() => ForgetPasswordScreen());
                  },
                  child: const Text('Forgot password?'),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () async {
                    String email = userEmail.text.trim();
                    String password = userPassword.text.trim();

                    if (email.isEmpty || password.isEmpty) {
                      Get.snackbar(
                        "Error",
                        "Please enter all details",
                        snackPosition: SnackPosition.BOTTOM,
                        backgroundColor: AppColors.dangerFg,
                        colorText: AppColors.textOnBrand,
                      );
                      return;
                    }

                    UserCredential? userCredential =
                        await signInController.signInMethod(email, password);

                    if (userCredential == null) {
                      Get.snackbar(
                        "Error",
                        "Please try again",
                        snackPosition: SnackPosition.BOTTOM,
                        backgroundColor: AppColors.dangerFg,
                        colorText: AppColors.textOnBrand,
                      );
                      return;
                    }

                    if (!userCredential.user!.emailVerified) {
                      Get.snackbar(
                        "Error",
                        "Please verify your email before login",
                        snackPosition: SnackPosition.BOTTOM,
                        backgroundColor: AppColors.dangerFg,
                        colorText: AppColors.textOnBrand,
                      );
                      return;
                    }

                    var userData = await getUserDataController
                        .getUserData(userCredential.user!.uid);

                    if (userData.isNotEmpty && userData[0]['isAdmin'] == true) {
                      Get.offAll(() => AdminMainScreen());
                    }
                    // Non-admin: navigation is already handled by
                    // NavigationService inside signInController -
                    // nothing more to do here.
                  },
                  child: const Text('Sign in'),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Don't have an account? ",
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                  GestureDetector(
                    onTap: () => Get.offAll(() => SignUpScreen()),
                    child: const Text(
                      "Sign up",
                      style: TextStyle(
                          color: AppColors.brand,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    });
  }
}

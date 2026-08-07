// ignore_for_file: file_names, avoid_unnecessary_containers, prefer_const_constructors, prefer_const_literals_to_create_immutables, sized_box_for_whitespace

import 'dart:async';

import 'package:e_comm/controllers/get-user-data-controller.dart';
import 'package:e_comm/screens/admin-panel/admin-main-screen.dart';
import 'package:e_comm/screens/user-panel/new-main-screen.dart';
import 'package:e_comm/utils/app-constant.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import '../../theme/app_colors.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 3), () {
      loggdin(context);
    });
  }

  Future<void> loggdin(BuildContext context) async {
    try {
      // Check the synchronous snapshot first, then fall back to
      // watching a few auth-state events if that's null - same
      // pattern applied to Android's equivalent check, after finding
      // that trusting a single authStateChanges().first emission
      // carries a real race on some devices. Narrower consequence
      // here than on Android (both branches below still route a guest
      // to NewMainScreen either way), but an admin account could
      // still briefly land on the retailer view instead of the admin
      // one if the race resolved wrong, so worth fixing the same way.
      User? user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        User? resolved;
        await for (final event in FirebaseAuth.instance
            .authStateChanges()
            .take(3)
            .timeout(const Duration(milliseconds: 2500), onTimeout: (sink) => sink.close())) {
          if (event != null) {
            resolved = event;
            break;
          }
        }
        user = resolved;
      }

      if (user != null) {
        final GetUserDataController getUserDataController =
            Get.put(GetUserDataController());
        var userData = await getUserDataController.getUserData(user.uid);

        if (userData.isNotEmpty && userData[0]['isAdmin'] == true) {
          Get.offAll(() => AdminMainScreen());
        } else {
          Get.offAll(() => NewMainScreen());
        }
      } else {
        // Guest browsing is allowed by design - only cart/profile/
        // checkout require signing in, gated individually at those
        // screens via AuthGuard.
        Get.offAll(() => NewMainScreen());
      }
    } catch (e) {
      // Don't leave the user stuck on the splash screen forever if
      // anything above fails - fall back to guest browsing.
      Get.offAll(() => NewMainScreen());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.brandDark,
      body: Column(
        children: [
          Expanded(
            child: Container(
              width: Get.width,
              alignment: Alignment.center,
              child: Lottie.asset('assets/images/splash-icon.json'),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 20.0),
            child: Text(
              AppConstant.appPoweredBy,
              style: const TextStyle(
                color: AppColors.textOnBrand,
                fontSize: 12.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

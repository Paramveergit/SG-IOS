// ignore_for_file: file_names, unused_local_variable, unused_field, avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_comm/controllers/get-device-token-controller.dart';
import 'package:e_comm/models/user-model.dart';
import 'package:e_comm/screens/user-panel/new-main-screen.dart';
import 'package:e_comm/services/navigation-service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class AppleSignInController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> signInWithApple() async {
    final GetDeviceTokenController getDeviceTokenController =
        Get.put(GetDeviceTokenController());
    try {
      // Request Apple Sign In
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      // Create OAuth credential for Firebase
      final oauthCredential = OAuthProvider("apple.com").credential(
        idToken: appleCredential.identityToken,
        accessToken: appleCredential.authorizationCode,
      );

      EasyLoading.show(status: "Please wait..");

      // Sign in to Firebase with the Apple credential
      final UserCredential userCredential =
          await _auth.signInWithCredential(oauthCredential);

      final User? user = userCredential.user;

      if (user != null) {
        // Get user information from Apple
        String displayName = '';
        String email = '';

        // Apple only provides name and email on first sign in
        // Subsequent sign-ins may not include this information
        if (appleCredential.givenName != null || appleCredential.familyName != null) {
          displayName = '${appleCredential.givenName ?? ''} ${appleCredential.familyName ?? ''}'.trim();
        }

        if (appleCredential.email != null) {
          email = appleCredential.email!;
        } else if (user.email != null) {
          // Fallback to Firebase user email if available
          email = user.email!;
        }

        // If we don't have display name or email, try to get from Firebase user
        if (displayName.isEmpty && user.displayName != null) {
          displayName = user.displayName!;
        }
        if (email.isEmpty && user.email != null) {
          email = user.email!;
        }

        UserModel userModel = UserModel(
          uId: user.uid,
          username: displayName.isNotEmpty ? displayName : 'Apple User',
          email: email,
          phone: user.phoneNumber ?? '',
          userImg: user.photoURL ?? '',
          userDeviceToken: getDeviceTokenController.deviceToken.toString(),
          country: '',
          userAddress: '',
          street: '',
          isAdmin: false,
          isActive: true,
          createdOn: DateTime.now(),
          city: '',
        );

        // Save user data to Firestore
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .set(userModel.toMap(), SetOptions(merge: true));

        EasyLoading.dismiss();
        
        // Execute any pending actions after successful login
        await NavigationService.instance.executePendingActions();
      }
    } catch (e) {
      EasyLoading.dismiss();
      print("Apple Sign In error: $e");

      // Handle specific error types
      String errorMessage = "Failed to sign in with Apple. Please try again.";

      if (e.toString().contains("operation-not-allowed")) {
        errorMessage = "Apple Sign In is not enabled in Firebase Console.\nPlease contact the developer.";
      } else if (e.toString().contains("AuthorizationError")) {
        errorMessage = "Apple Sign In authorization failed.\nPlease check your device settings.";
      } else if (e.toString().contains("network")) {
        errorMessage = "Network error. Please check your internet connection.";
      }

      // Show user-friendly error message
      Get.snackbar(
        "Sign In Error",
        errorMessage,
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 5),
      );
    }
  }
}

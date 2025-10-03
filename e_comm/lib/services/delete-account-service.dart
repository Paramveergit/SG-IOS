// ignore_for_file: file_names

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../utils/app-constant.dart';

/// Service class to handle complete account deletion
/// Follows Apple's App Store Guidelines 5.1.1(v) for account deletion
class DeleteAccountService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Deletes user account and all associated data
  /// Returns true if successful, false otherwise
  static Future<bool> deleteUserAccount() async {
    try {
      final User? user = _auth.currentUser;
      
      if (user == null) {
        Get.snackbar(
          "Error",
          "No user is currently signed in",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppConstant.appScendoryColor,
          colorText: AppConstant.appTextColor,
        );
        return false;
      }

      EasyLoading.show(status: "Deleting account...");

      // Step 1: Delete user's cart data
      await _deleteUserCart(user.uid);

      // Step 2: Delete user's orders
      await _deleteUserOrders(user.uid);

      // Step 3: Delete user profile data from Firestore
      await _deleteUserProfile(user.uid);

      // Step 4: Sign out from Google if logged in via Google
      await _signOutFromProviders();

      // Step 5: Delete Firebase Authentication account
      await user.delete();

      EasyLoading.dismiss();
      
      Get.snackbar(
        "Account Deleted",
        "Your account has been permanently deleted",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppConstant.appMainColor,
        colorText: AppConstant.appTextColor,
        duration: const Duration(seconds: 3),
      );

      return true;

    } on FirebaseAuthException catch (e) {
      EasyLoading.dismiss();
      
      // Handle reauthentication required error
      if (e.code == 'requires-recent-login') {
        Get.snackbar(
          "Re-authentication Required",
          "For security reasons, please sign out and sign in again before deleting your account",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppConstant.appScendoryColor,
          colorText: AppConstant.appTextColor,
          duration: const Duration(seconds: 5),
        );
      } else {
        Get.snackbar(
          "Error",
          "Failed to delete account: ${e.message}",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppConstant.appScendoryColor,
          colorText: AppConstant.appTextColor,
        );
      }
      return false;

    } catch (e) {
      EasyLoading.dismiss();
      Get.snackbar(
        "Error",
        "An unexpected error occurred: $e",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppConstant.appScendoryColor,
        colorText: AppConstant.appTextColor,
      );
      return false;
    }
  }

  /// Delete all cart data for the user
  static Future<void> _deleteUserCart(String uid) async {
    try {
      // Delete all items in cartOrders subcollection
      final cartOrdersSnapshot = await _firestore
          .collection('cart')
          .doc(uid)
          .collection('cartOrders')
          .get();

      for (var doc in cartOrdersSnapshot.docs) {
        await doc.reference.delete();
      }

      // Delete the cart parent document
      await _firestore.collection('cart').doc(uid).delete();
      
      print('Cart data deleted for user: $uid');
    } catch (e) {
      print('Error deleting cart data: $e');
      // Continue with deletion even if cart deletion fails
    }
  }

  /// Delete all orders for the user
  static Future<void> _deleteUserOrders(String uid) async {
    try {
      // Delete all items in confirmOrders subcollection
      final confirmOrdersSnapshot = await _firestore
          .collection('orders')
          .doc(uid)
          .collection('confirmOrders')
          .get();

      for (var doc in confirmOrdersSnapshot.docs) {
        await doc.reference.delete();
      }

      // Delete the orders parent document
      await _firestore.collection('orders').doc(uid).delete();
      
      print('Orders data deleted for user: $uid');
    } catch (e) {
      print('Error deleting orders data: $e');
      // Continue with deletion even if orders deletion fails
    }
  }

  /// Delete user profile from Firestore
  static Future<void> _deleteUserProfile(String uid) async {
    try {
      await _firestore.collection('users').doc(uid).delete();
      print('User profile deleted for user: $uid');
    } catch (e) {
      print('Error deleting user profile: $e');
      // Continue with deletion even if profile deletion fails
    }
  }

  /// Sign out from external providers (Google, Apple)
  static Future<void> _signOutFromProviders() async {
    try {
      // Sign out from Google
      final GoogleSignIn googleSignIn = GoogleSignIn();
      if (await googleSignIn.isSignedIn()) {
        await googleSignIn.signOut();
      }
      
      // Note: Apple Sign In doesn't require explicit sign out
      // Firebase Auth handles it automatically
      
    } catch (e) {
      print('Error signing out from providers: $e');
      // Continue with deletion even if provider sign out fails
    }
  }
}


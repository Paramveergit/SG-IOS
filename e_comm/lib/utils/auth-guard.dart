// Authentication Guard - Handles authentication checks for protected screens
// Redirects unauthenticated users to login with return navigation

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/navigation-service.dart';
import '../screens/auth-ui/welcome-screen.dart';

class AuthGuard {
  // Check if user is authenticated, redirect to login if not
  static bool requireAuth({Widget? returnScreen}) {
    final user = FirebaseAuth.instance.currentUser;
    
    if (user == null) {
      // Set pending navigation if return screen is provided
      if (returnScreen != null) {
        NavigationService.instance.setPendingNavigation(returnScreen);
      }
      
      // Redirect to login screen
      Get.to(() => WelcomeScreen());
      return false;
    }
    
    return true;
  }
  
  // Check if user is authenticated for add-to-cart action
  static bool requireAuthForAddToCart(dynamic product) {
    final user = FirebaseAuth.instance.currentUser;
    
    if (user == null) {
      // Set pending add-to-cart action
      NavigationService.instance.setPendingAddToCart(product);
      
      // Redirect to login screen
      Get.to(() => WelcomeScreen());
      return false;
    }
    
    return true;
  }
  
  // Get current user or null
  static User? getCurrentUser() {
    return FirebaseAuth.instance.currentUser;
  }
  
  // Check if user is authenticated (without redirect)
  static bool isAuthenticated() {
    return FirebaseAuth.instance.currentUser != null;
  }
}

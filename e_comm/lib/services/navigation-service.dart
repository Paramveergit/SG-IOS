// Navigation Service - Handles authentication redirects and return navigation
// Maintains pending actions for unauthenticated users

import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/product-model.dart';
import '../models/cart-model.dart';
import '../screens/user-panel/new-main-screen.dart';
import '../screens/user-panel/cart-screen.dart';
import '../screens/user-panel/profile-screen.dart';

class NavigationService extends GetxController {
  static NavigationService get instance => Get.find<NavigationService>();
  
  // Pending navigation after login
  Widget? _pendingScreen;
  
  // Pending add-to-cart action
  ProductModel? _pendingAddToCartProduct;
  
  // Clear all pending actions
  void clearPendingActions() {
    _pendingScreen = null;
    _pendingAddToCartProduct = null;
  }
  
  // Set pending navigation (for profile/cart access)
  void setPendingNavigation(Widget screen) {
    _pendingScreen = screen;
  }
  
  // Set pending add-to-cart action
  void setPendingAddToCart(ProductModel product) {
    _pendingAddToCartProduct = product;
  }
  
  // Execute pending actions after successful login
  Future<void> executePendingActions() async {
    try {
      // Handle pending add-to-cart first (higher priority)
      if (_pendingAddToCartProduct != null) {
        final product = _pendingAddToCartProduct!;
        clearPendingActions();
        
        // Execute add-to-cart and return to previous screen
        await _executeAddToCart(product);
        return;
      }
      
      // Handle pending navigation
      if (_pendingScreen != null) {
        final screen = _pendingScreen!;
        clearPendingActions();
        
        // Use Get.offAll() to completely clear the navigation stack
        // This prevents users from getting stuck on the login screen
        // and ensures they land directly on the target screen
        Get.offAll(() => screen);
        return;
      }
      
      // No pending actions, go to main screen
      clearPendingActions();
      Get.offAll(() => const NewMainScreen());
    } catch (e) {
      // Fallback: clear any pending actions and go to main screen
      clearPendingActions();
      Get.offAll(() => const NewMainScreen());
    }
  }
  
  // Execute add-to-cart action
  Future<void> _executeAddToCart(ProductModel product) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        Get.snackbar(
          'Error',
          'Authentication failed. Please try again.',
          backgroundColor: Colors.red,
          colorText: Colors.white,
          duration: const Duration(seconds: 2),
        );
        return;
      }

      await _addToCartHelper(product, user.uid);
      
      Get.snackbar(
        'Success',
        '${product.productName} added to cart',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );
      
      // Return to the previous screen (product page) after successful add-to-cart
      // This fixes the issue where users get stuck on the login screen
      Get.back();
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to add item to cart',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );
    }
  }
  
  // Helper method to add item to cart (extracted from existing code)
  Future<void> _addToCartHelper(ProductModel product, String userId) async {
    final documentReference = FirebaseFirestore.instance
        .collection('cart')
        .doc(userId)
        .collection('cartOrders')
        .doc(product.productId.toString());

    final snapshot = await documentReference.get();

    if (snapshot.exists) {
      int currentQuantity = snapshot['productQuantity'];
      int updatedQuantity = currentQuantity + 1;
      double totalPrice = double.parse(product.isSale
              ? product.salePrice
              : product.fullPrice) *
          updatedQuantity;

      await documentReference.update({
        'productQuantity': updatedQuantity,
        'productTotalPrice': totalPrice
      });
    } else {
      await FirebaseFirestore.instance.collection('cart').doc(userId).set({
        'uId': userId,
        'createdAt': DateTime.now(),
      });

      final cartModel = CartModel(
        productId: product.productId,
        categoryId: product.categoryId,
        productName: product.productName,
        categoryName: product.categoryName,
        salePrice: product.salePrice,
        fullPrice: product.fullPrice,
        productImages: product.productImages,
        deliveryTime: product.deliveryTime,
        isSale: product.isSale,
        productDescription: product.productDescription,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        productQuantity: 1,
        productTotalPrice: double.parse(product.isSale
            ? product.salePrice
            : product.fullPrice),
      );

      await documentReference.set(cartModel.toMap());
    }
  }
}

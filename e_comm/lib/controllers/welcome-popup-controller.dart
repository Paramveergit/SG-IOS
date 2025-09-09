// Welcome Popup Controller - Manages welcome popup state

import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class WelcomePopupController extends GetxController {
  final GetStorage _storage = GetStorage();
  static const String _welcomeShownKey = 'welcome_popup_shown';
  
  bool _isVisible = false;
  bool get isVisible => _isVisible;

  @override
  void onInit() {
    super.onInit();
    _checkWelcomeStatus();
  }

  void _checkWelcomeStatus() {
    // Check if welcome popup has been shown before
    final hasShownWelcome = _storage.read(_welcomeShownKey) ?? false;
    
    // Show welcome popup only if it hasn't been shown before
    if (!hasShownWelcome) {
      // Delay showing the popup to ensure the screen is fully loaded
      Future.delayed(const Duration(milliseconds: 1000), () {
        showWelcomePopup();
      });
    }
  }

  void showWelcomePopup() {
    _isVisible = true;
    update();
  }

  void hideWelcomePopup() {
    _isVisible = false;
    update();
    
    // Mark welcome popup as shown
    _storage.write(_welcomeShownKey, true);
  }

  void resetWelcomeStatus() {
    _storage.remove(_welcomeShownKey);
  }
}

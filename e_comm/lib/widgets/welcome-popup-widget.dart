// Welcome Popup Widget - User engagement and onboarding

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/welcome-popup-controller.dart';
import '../utils/app-constant.dart';

class WelcomePopupWidget extends StatelessWidget {
  const WelcomePopupWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<WelcomePopupController>(
      builder: (controller) {
        if (!controller.isVisible) {
          return const SizedBox.shrink();
        }

        return Container(
          color: Colors.black.withOpacity(0.5),
          child: Center(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 32.0),
              padding: const EdgeInsets.all(24.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 20.0,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Welcome Icon
                  Container(
                    width: 80.0,
                    height: 80.0,
                    decoration: BoxDecoration(
                      color: AppConstant.appMainColor.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.waving_hand,
                      size: 40.0,
                      color: AppConstant.appMainColor,
                    ),
                  ),
                  
                  const SizedBox(height: 20.0),
                  
                  // Welcome Title
                  const Text(
                    'Welcome to Sunder Garments!',
                    style: TextStyle(
                      fontSize: 24.0,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  
                  const SizedBox(height: 12.0),
                  
                  // Welcome Message
                  Text(
                    'Discover amazing clothing at great prices. Start shopping now!',
                    style: TextStyle(
                      fontSize: 16.0,
                      color: Colors.grey.shade600,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  
                  const SizedBox(height: 24.0),
                  
                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () => controller.hideWelcomePopup(),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12.0),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                          ),
                          child: Text(
                            'Maybe Later',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ),
                      ),
                      
                      const SizedBox(width: 12.0),
                      
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            controller.hideWelcomePopup();
                            // Navigate to products or main screen
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppConstant.appMainColor,
                            foregroundColor: AppConstant.appTextColor,
                            padding: const EdgeInsets.symmetric(vertical: 12.0),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                          ),
                          child: const Text('Start Shopping'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

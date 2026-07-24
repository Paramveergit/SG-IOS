// ignore_for_file: file_names

import 'package:e_comm/utils/app-constant.dart';
import 'package:e_comm/services/navigation-service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';

class SignInController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  //for password visibilty
  var isPasswordVisible = false.obs;

  Future<UserCredential?> signInMethod(
      String userEmail, String userPassword) async {
    try {
      EasyLoading.show(status: "Please wait");
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: userEmail,
        password: userPassword,
      );

      EasyLoading.dismiss();

      // Execute any pending actions after successful login
      await NavigationService.instance.executePendingActions();

      return userCredential;
    } on FirebaseAuthException catch (e) {
      EasyLoading.dismiss();
      Get.snackbar(
        "Error",
        "$e",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppConstant.appScendoryColor,
        colorText: AppConstant.appTextColor,
      );
      return null;
    }
  }
}

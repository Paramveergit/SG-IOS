// ignore_for_file: file_names, unused_local_variable, unused_field, avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_comm/controllers/get-device-token-controller.dart';
import 'package:e_comm/models/user-model.dart';
import 'package:e_comm/screens/user-panel/new-main-screen.dart';
import 'package:e_comm/services/navigation-service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';

class GoogleSignInController extends GetxController {
  final GoogleSignIn googleSignIn = GoogleSignIn(
    clientId: '453261302664-ht6iplbe0hku8b7pduk6p4tsojftfe66.apps.googleusercontent.com',
  );
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> signInWithGoogle() async {
    final GetDeviceTokenController getDeviceTokenController =
        Get.put(GetDeviceTokenController());
    try {
      final GoogleSignInAccount? googleSignInAccount =
          await googleSignIn.signIn();

      if (googleSignInAccount != null) {
        EasyLoading.show(status: "Please wait..");
        final GoogleSignInAuthentication googleSignInAuthentication =
            await googleSignInAccount.authentication;

        final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleSignInAuthentication.accessToken,
          idToken: googleSignInAuthentication.idToken,
        );

        final UserCredential userCredential =
            await _auth.signInWithCredential(credential);

        final User? user = userCredential.user;

        if (user != null) {
          // CRITICAL: check whether this account already has a profile
          // before writing anything - the old code unconditionally
          // overwrote the entire user document on every sign-in,
          // silently wiping isAdmin status and any saved profile data
          // (address/phone/city) for existing accounts.
          final userDocRef =
              FirebaseFirestore.instance.collection('users').doc(user.uid);
          final existingDoc = await userDocRef.get();

          if (existingDoc.exists) {
            await userDocRef.set({
              'userDeviceToken': getDeviceTokenController.deviceToken.toString(),
            }, SetOptions(merge: true));
          } else {
            UserModel userModel = UserModel(
              uId: user.uid,
              username: user.displayName.toString(),
              email: user.email.toString(),
              phone: user.phoneNumber.toString(),
              userImg: user.photoURL.toString(),
              userDeviceToken: getDeviceTokenController.deviceToken.toString(),
              country: '',
              userAddress: '',
              street: '',
              isAdmin: false,
              isActive: true,
              createdOn: DateTime.now(),
              city: '',
            );

            await userDocRef.set(userModel.toMap());
          }
          EasyLoading.dismiss();
          
          // Execute any pending actions after successful login
          await NavigationService.instance.executePendingActions();
        }
      }
    } catch (e) {
      EasyLoading.dismiss();
      print("error $e");
    }
  }
}

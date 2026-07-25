// ignore_for_file: file_names, prefer_const_constructors, avoid_unnecessary_containers, prefer_const_literals_to_create_immutables, sized_box_for_whitespace, avoid_print, unused_local_variable, use_build_context_synchronously
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_comm/models/cart-model.dart';
import 'package:e_comm/utils/app-constant.dart';
import 'package:e_comm/utils/auth-guard.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_swipe_action_cell/core/cell.dart';
import 'package:get/get.dart';
import '../../controllers/cart-price-controller.dart';
import '../../controllers/get-customer-device-token-controller.dart';
import '../../services/place-order-service.dart';

class CheckOutScreen extends StatefulWidget {
  const CheckOutScreen({super.key});

  @override
  State<CheckOutScreen> createState() => _CheckOutScreenState();
}

class _CheckOutScreenState extends State<CheckOutScreen> {
  User? user = FirebaseAuth.instance.currentUser;
  final ProductPriceController productPriceController =
      Get.put(ProductPriceController());
  TextEditingController nameController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  
  String? customerToken;
  String? name;
  String? phone;
  String? address;

  @override
  void initState() {
    super.initState();
    // Check authentication when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!AuthGuard.requireAuth(returnScreen: const CheckOutScreen())) {
        return; // User will be redirected to login
      }
    });
    _prefillFromSavedProfile();
  }

  // FIX: this used to ask for name/phone/address on every single order,
  // even though the person is already signed in with a real account.
  // Pre-fill from whatever's already saved on their profile, so most
  // returning customers see the sheet already filled in and can just
  // confirm instead of retyping the same details every time.
  Future<void> _prefillFromSavedProfile() async {
    if (user == null) return;
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .get();
      if (!doc.exists) return;
      final data = doc.data();
      if (data == null) return;
      // FIX: some accounts have "null" (the literal 4-character string,
      // from an old ?.toString() call on an actually-null value) stored
      // in Firestore instead of a genuinely empty value. isNotEmpty
      // alone doesn't catch that - "null" is a non-empty string as far
      // as Dart is concerned. Treat it the same as missing/empty so it
      // never shows up pre-filled in a form.
      String? clean(String? value) {
        final v = value?.trim();
        if (v == null || v.isEmpty) return null;
        if (v.toLowerCase() == 'null') return null;
        return v;
      }

      final savedName = clean(data['username'] as String?);
      final savedPhone = clean(data['phone'] as String?);
      final savedAddress = clean(data['userAddress'] as String?);
      if (savedName != null) {
        nameController.text = savedName;
      }
      if (savedPhone != null) {
        phoneController.text = savedPhone;
      }
      if (savedAddress != null) {
        addressController.text = savedAddress;
      }
    } catch (e) {
      // Non-fatal - if this fails, the sheet just opens blank like before.
      print('Could not pre-fill checkout details: $e');
    }
  }

  // Saves whatever the customer confirmed/typed back to their profile,
  // so the NEXT order pre-fills too, even if this was their first time
  // entering these details or they corrected something.
  Future<void> _saveDetailsToProfile({
    required String name,
    required String phone,
    required String address,
  }) async {
    if (user == null) return;
    try {
      await FirebaseFirestore.instance.collection('users').doc(user!.uid).set(
        {
          'username': name,
          'phone': phone,
          'userAddress': address,
        },
        SetOptions(merge: true),
      );
    } catch (e) {
      // Non-fatal - the order itself already succeeded by the time this
      // runs; failing to save the profile shouldn't block the user.
      print('Could not save checkout details to profile: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Double-check authentication in build method
    if (!AuthGuard.isAuthenticated()) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: AppConstant.appTextColor,
        ),
        backgroundColor: AppConstant.appMainColor,
        title: Text(
          "Checkout Screen",
          style: TextStyle(color: AppConstant.appTextColor),
        ),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('cart')
            .doc(user!.uid)
            .collection('cartOrders')
            .snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text("Error"),
            );
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Container(
              height: Get.height / 5,
              child: Center(
                child: CupertinoActivityIndicator(),
              ),
            );
          }

          if (snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text("No products found!"),
            );
          }

          if (snapshot.data != null) {
            return Container(
              child: ListView.builder(
                itemCount: snapshot.data!.docs.length,
                shrinkWrap: true,
                physics: BouncingScrollPhysics(),
                itemBuilder: (context, index) {
                  final productData = snapshot.data!.docs[index];
                  CartModel cartModel = CartModel(
                    productId: productData['productId'],
                    categoryId: productData['categoryId'],
                    productName: productData['productName'],
                    categoryName: productData['categoryName'],
                    salePrice: productData['salePrice'],
                    fullPrice: productData['fullPrice'],
                    productImages: productData['productImages'],
                    deliveryTime: productData['deliveryTime'],
                    isSale: productData['isSale'],
                    productDescription: productData['productDescription'],
                    createdAt: productData['createdAt'],
                    updatedAt: productData['updatedAt'],
                    productQuantity: productData['productQuantity'],
                    productTotalPrice: double.parse(
                        productData['productTotalPrice'].toString()),
                  );

                  //calculate price
                  productPriceController.fetchProductPrice();
                  return SwipeActionCell(
                    key: ObjectKey(cartModel.productId),
                    trailingActions: [
                      SwipeAction(
                        title: "Delete",
                        forceAlignmentToBoundary: true,
                        performsFirstActionWithFullSwipe: true,
                        onTap: (CompletionHandler handler) async {
                          print('deleted');

                          await FirebaseFirestore.instance
                              .collection('cart')
                              .doc(user!.uid)
                              .collection('cartOrders')
                              .doc(cartModel.productId)
                              .delete();
                        },
                      )
                    ],
                    child: Card(
                      elevation: 5,
                      color: AppConstant.appTextColor,
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: AppConstant.appMainColor,
                          backgroundImage:
                              NetworkImage(cartModel.productImages[0]),
                        ),
                        title: Text(cartModel.productName),
                        subtitle: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text(cartModel.productTotalPrice.toString()),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            );
          }

          return Container();
        },
      ),
      bottomNavigationBar: Container(
        margin: EdgeInsets.only(bottom: 5.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Obx(
              () => Text(
                " Total Rs : ${productPriceController.totalPrice.value.toStringAsFixed(1)}",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Material(
                child: Container(
                  width: Get.width / 2.0,
                  height: Get.height / 18,
                  decoration: BoxDecoration(
                    color: AppConstant.appScendoryColor,
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  child: TextButton(
                    child: Text(
                      "Confirm Order",
                      style: TextStyle(color: AppConstant.appTextColor),
                    ),
                    onPressed: () async {
                      showCustomBottomSheet();
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void showCustomBottomSheet() {
    Get.bottomSheet(
      Container(
        height: Get.height * 0.8,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(16.0),
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 20.0, vertical: 20.0),
                child: Container(
                  height: 55.0,
                  child: TextFormField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: 'Name',
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 10.0,
                      ),
                      hintStyle: TextStyle(
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 20.0, vertical: 20.0),
                child: Container(
                  height: 55.0,
                  child: TextFormField(
                    controller: phoneController,
                    textInputAction: TextInputAction.next,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      labelText: 'Phone',
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 10.0,
                      ),
                      hintStyle: TextStyle(
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 20.0, vertical: 20.0),
                child: Container(
                  height: 55.0,
                  child: TextFormField(
                    controller: addressController,
                    decoration: InputDecoration(
                      labelText: 'Address',
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 10.0,
                      ),
                      hintStyle: TextStyle(
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppConstant.appMainColor,
                  padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
                ),
                onPressed: () async {
                  if (nameController.text != '' &&
                      phoneController.text != '' &&
                      addressController.text != '') {
                    name = nameController.text.trim();
                    phone = phoneController.text.trim();
                    address = addressController.text.trim();
                    customerToken = await getCustomerDeviceToken();

                    placeOrder(
                      context: context,
                      customerName: name!,
                      customerPhone: phone!,
                      customerAddress: address!,
                      customerDeviceToken: customerToken!,
                    );

                    // Save these details for next time, so the sheet
                    // pre-fills automatically on future orders.
                    _saveDetailsToProfile(
                      name: name!,
                      phone: phone!,
                      address: address!,
                    );
                  } else {
                    print("Fill The Details");
                  }
                },
                child: Text(
                  "Place Order",
                  style: TextStyle(color: Colors.white),
                ),
              )
            ],
          ),
        ),
      ),
      backgroundColor: Colors.transparent,
      isDismissible: true,
      enableDrag: true,
      elevation: 6,
    );
  }
}

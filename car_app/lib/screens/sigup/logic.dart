import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../home_screen/logic.dart';

class SignUp_screeenLogic extends GetxController {
  TextEditingController userName = TextEditingController();
  TextEditingController passC = TextEditingController();
  TextEditingController emailC = TextEditingController();

  Future<bool> userNameAvailable(String username) async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('RabbitCoin')
        .where('name', isEqualTo: username)
        .get();
    List<DocumentSnapshot> saim = querySnapshot.docs;
    if (saim.isEmpty) {
      return false;
    } else {
      return true;
    }
  }

  Future<void> createUserOnFirebase() async {
    if (userName.text.isEmpty || emailC.text.isEmpty || passC.text.isEmpty) {
      Get.snackbar('Error', 'All fields are required!');
    } else {
      try {
        bool isAvailable = await userNameAvailable(userName.text);
        if (isAvailable == true) {
          Get.snackbar('Error', 'User already exists');
        } else {
          UserCredential myUser = await FirebaseAuth.instance
              .createUserWithEmailAndPassword(
                  email: emailC.text, password: passC.text);
          if (myUser.user != null) {
            String name = userName.text;
            String id = myUser.user!.uid; // Set id as the Firebase user's UID
            FirebaseFirestore.instance.collection("RabbitCoin").doc(id).set({
              'name': userName.text,
              'email': emailC.text,
              'password': passC.text,
              'createdAt': DateTime.now(),
            });
            Get.snackbar(
              "Successfully", // Title of the snackbar
              "Signup Successfully", // Message of the snackbar
              snackPosition: SnackPosition.TOP, // Position of the snackbar
              backgroundColor: Colors.green, // Background color
              colorText: Colors.white, // Text color
              borderRadius:
                  10, // Optional: Adds rounded corners to the snackbar
              margin: EdgeInsets.all(
                  10), // Optional: Adds margin around the snackbar
            );

            Get.to(() => HomeScreenLogic());
          }
        }
      } catch (e) {
        print("Error occurred: $e");
        Get.snackbar('Error', e.toString());
      }
    }
  }
}

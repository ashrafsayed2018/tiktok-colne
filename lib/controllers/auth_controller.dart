import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get/get.dart';
import 'package:tiktok_clone/constants.dart';
import 'package:tiktok_clone/models/user_model.dart';

class AuthController extends GetxController {
  // method to upload image to firebase storage

  Future<String> _uploadImageToStorage(File image) async {
    Reference reference = firebaseStorage
        .ref()
        .child("profilePics")
        .child(firebaseAuth.currentUser!.uid);
    UploadTask uploadTask = reference.putFile(image);

    TaskSnapshot snap = await uploadTask;
    String downloadUrl = await snap.ref.getDownloadURL();

    return downloadUrl;
  }

  // register user method
  void registerUser(
      String username, String email, String password, File? image) async {
    try {
      if (username.isNotEmpty &&
          email.isNotEmpty &&
          password.isNotEmpty &&
          image != null) {
        // save the user to firebase firestore
        UserCredential credentials = await firebaseAuth
            .createUserWithEmailAndPassword(email: email, password: password);

        String downloadUrl = await _uploadImageToStorage(image);

        UserModel user = UserModel(
            uid: credentials.user!.uid,
            name: username,
            email: email,
            password: password,
            profilePhoto: downloadUrl);
      }
    } catch (e) {
      Get.snackbar(
        "خطاء في تسجيل الدخول",
        e.toString(),
      );
    }
  }
}

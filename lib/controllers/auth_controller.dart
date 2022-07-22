import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tiktok_clone/constants.dart';
import 'package:tiktok_clone/models/user_model.dart';
import 'package:tiktok_clone/views/screens/auth/login_screen.dart';
import 'package:tiktok_clone/views/screens/home_screen.dart';

class AuthController extends GetxController {
  static AuthController instance = Get.find();

  late Rx<File?> _pickedImage;

  // firebase user

  late Rx<User?> _user;

  @override
  void onReady() {
    super.onReady();

    _user = Rx<User?>(firebaseAuth.currentUser);

    // bind the user to the changes
    _user.bindStream(firebaseAuth.authStateChanges());
    // when ever the user changes we will calback method

    ever(_user, _setInitialScreen);
  }

  _setInitialScreen(User? user) {
    if (user != null) {
      Get.offAll(() => const HomeScreen());
    } else {
      Get.offAll(() => LoginScreen());
    }
  }

  File? get profilePhoto => _pickedImage.value;
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

        // creating user in firebase firstore

        await firestore
            .collection("users")
            .doc(credentials.user!.uid)
            .set(user.toJson());
      } else {
        Get.snackbar(
          "خطاء في تسجيل الدخول",
          "الرجاء ملاء كل الحقول",
        );
      }
    } catch (e) {
      Get.snackbar(
        "خطاء في تسجيل الدخول",
        e.toString(),
      );
    }
  }

  // login user method

  void loginUser(String email, String password) async {
    try {
      if (email.isNotEmpty && password.isNotEmpty) {
        await firebaseAuth.signInWithEmailAndPassword(
            email: email, password: password);
      } else {
        Get.snackbar(
          "خطاء في تسجيل الدخول",
          "خطاء في تسجيل الدخول",
        );
      }
    } catch (e) {
      Get.snackbar(
        "خطاء في تسجيل الدخول",
        e.toString(),
      );
    }
  }

  // pick image

  void pickImage() async {
    final pickedImage =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      Get.snackbar("صورة الملف", "تم تحميل صورة الملف بنجاح");
    }

    _pickedImage = Rx<File?>(File(pickedImage!.path));
  }
}

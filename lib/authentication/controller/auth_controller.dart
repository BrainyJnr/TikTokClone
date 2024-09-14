import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tiktokclone/authentication/loginscreen.dart';
import 'package:tiktokclone/authentication/signup_Screen.dart';
import 'package:tiktokclone/common/home.dart';
import 'package:tiktokclone/fancy/global.dart';

import '../users/user.dart' as userModel;

class AuthenticationController extends GetxController {
  static AuthenticationController instanceAuth = Get.find();
  late Rx<User?> _currentUser;

  late Rx<File?> _pickedFile;

  File? get profileImage => _pickedFile.value;

  void chooseImageFromGallery() async {
    final pickedImageFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);

    if (pickedImageFile != null) {
      Get.snackbar("Profile Image",
          "you have successfully selected your profile image.");
    }

    _pickedFile = Rx<File?>(File(pickedImageFile!.path));
  }

  void captureImageWithCamera() async {
    final pickedImageFile =
        await ImagePicker().pickImage(source: ImageSource.camera);

    if (pickedImageFile != null) {
      Get.snackbar("Profile Image",
          "you have successfully captured your face with your Phone Camera.");
    }

    _pickedFile = Rx<File?>(File(pickedImageFile!.path));
  }

  Future<void> createAccountForNewUser(File imageFile, String userName,
      String userEmail, String userPassword) async {
    try {
      //1. create user in the firebase authentication
      UserCredential credential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
              email: userEmail, password: userPassword);

      //2. Save the user profile image to firebase storage
      String imageDownloadUrl = await uploadImageToStorage(imageFile);

      //3. Save user data to the firestore database
      userModel.User user = userModel.User(
          name: userName,
          email: userEmail,
          image: imageDownloadUrl,
          uid: credential.user!.uid);

      await FirebaseFirestore.instance
          .collection("users")
          .doc(credential.user!.uid)
          .set(user.toJson());

      Get.snackbar("Account Created", "Congratulations mannnnnnnnnnnnnn.");
      showProgressBar = false;
      // Get.to(LoginScreen());
    } catch (error) {
      Get.snackbar("Oh Snap!", "Error Occurred creating account. Try Again");
      showProgressBar = false;
      Get.to(LoginScreen());
    }
  }

  Future<String> uploadImageToStorage(File imageFile) async {
    Reference reference = FirebaseStorage.instance
        .ref()
        .child("Profile Images")
        .child(FirebaseAuth.instance.currentUser!.uid);

    UploadTask uploadTask = reference.putFile(imageFile);
    TaskSnapshot taskSnapshot = await uploadTask;

    String downloadUrlOfUploadedImage = await taskSnapshot.ref.getDownloadURL();

    return downloadUrlOfUploadedImage;
  }

  void loginUser(String userEmail, String userPassword) async {
    try {
      await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: userEmail, password: userPassword);
      Get.snackbar("Login Successful", "Success mannnnnnnnnnnnnnnnn");
      showProgressBar = false;
      // Get.to(SignupScreen());
    } catch (error) {
      Get.snackbar("Login Unsuccessful", "Error Occurred Login In. Try Again");
      showProgressBar = false;
      Get.to(SignupScreen());
    }
  }

  goToScreen(User? currentUser) {
    // when user is not already logged-in
    if (currentUser == null) {
      Get.offAll(LoginScreen());
    } else {
      Get.offAll(HomeScreen());
    }
  }

  @override
  void onReady() {
    // TODO: inplement onReady
    super.onReady();

    _currentUser = Rx<User?>(FirebaseAuth.instance.currentUser);
    _currentUser.bindStream(FirebaseAuth.instance.authStateChanges());
    ever(_currentUser, goToScreen);
  }

}
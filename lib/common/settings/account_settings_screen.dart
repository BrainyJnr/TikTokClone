import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tiktokclone/common/profile/controller/profile_controller.dart';
import 'package:tiktokclone/fancy/global.dart';
import 'package:tiktokclone/widgets/input_text_widget.dart';

class AccountSettingsScreen extends StatefulWidget {
  const AccountSettingsScreen({super.key});

  @override
  State<AccountSettingsScreen> createState() => _AccountSettingsScreenState();
}

class _AccountSettingsScreenState extends State<AccountSettingsScreen> {
  String facebook = "";
  String youtube = "";
  String instagram = "";
  String twitter = "";
  String userImageUrl = "";

  TextEditingController facebookTextEditingController = TextEditingController();
  TextEditingController youtubeTextEditingController = TextEditingController();
  TextEditingController instagramTextEditingController =
      TextEditingController();
  TextEditingController twitterTextEditingController = TextEditingController();

  getCurrentUserData() async {
    DocumentSnapshot snapshotUser = await FirebaseFirestore.instance
        .collection("users")
        .doc(currentUserID)
        .get();

    facebook = snapshotUser["facebook"];
    youtube = snapshotUser["youtube"];
    instagram = snapshotUser["instagram"];
    twitter = snapshotUser["twitter"];
    userImageUrl = snapshotUser["image"];

    setState(() {
      facebookTextEditingController.text = facebook == null ? "" : facebook;
      youtubeTextEditingController.text = youtube == null ? "" : youtube;
      instagramTextEditingController.text = instagram == null ? "" : instagram;
      twitterTextEditingController.text = twitter == null ? "" : twitter;

      ProfileController controllerProfile = Get.put(ProfileController());
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    getCurrentUserData();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ProfileController>(
      init: ProfileController(),
      builder: (controllerProfile) {
        return Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.black,
            title: Text(
              "Account Settings",
              style: GoogleFonts.acme(fontSize: 24, color: Colors.grey),
            ),
            centerTitle: true,
          ),
          body: SingleChildScrollView(
            child: Center(
              child: Column(
                children: [
                  const SizedBox(
                    height: 20,
                  ),
                  CircleAvatar(
                    radius: 50,
                    backgroundImage:
                        NetworkImage(controllerProfile.userMap["userImage"]),
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  Text(
                    "Update your profile social links:",
                    style: GoogleFonts.acme(fontSize: 20, color: Colors.grey),
                  ),

                  const SizedBox(
                    height: 10,
                  ),

                  //facebook
                  Container(
                    width: MediaQuery.of(context).size.width,
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    child: InputTextWidget(
                      textEditingController: facebookTextEditingController,
                      lableString: "facebook.com/username",
                      isObscure: false,
                      assetRefrence: "assets/images/logo/facebook.png",
                    ),
                  ),
                  const SizedBox(
                    height: 15,
                  ),

                  //instagram
                  Container(
                    width: MediaQuery.of(context).size.width,
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    child: InputTextWidget(
                      textEditingController: instagramTextEditingController,
                      lableString: "instagram.com/username",
                      isObscure: false,
                      assetRefrence: "assets/images/logo/instagram.png",
                    ),
                  ),
                  const SizedBox(
                    height: 15,
                  ),

                  //twitter
                  Container(
                    width: MediaQuery.of(context).size.width,
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    child: InputTextWidget(
                      textEditingController: twitterTextEditingController,
                      lableString: "twitter.com/username",
                      isObscure: false,
                      assetRefrence: "assets/images/logo/twitter.png",
                    ),
                  ),
                  const SizedBox(
                    height: 15,
                  ),

                  //youtube
                  Container(
                    width: MediaQuery.of(context).size.width,
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    child: InputTextWidget(
                      textEditingController: youtubeTextEditingController,
                      lableString: "m.instagram.com/c/username",
                      isObscure: false,
                      assetRefrence: "assets/images/logo/youtube.png",
                    ),
                  ),
                  const SizedBox(
                    height: 15,
                  ),

                  //update
                  SizedBox(
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                          backgroundColor: Colors.blueAccent,
                        ),
                        child: const Text(
                          "Update Now",
                          style: TextStyle(
                              fontSize: 20,
                              color: Colors.black,
                              fontWeight: FontWeight.w700),
                        ),
                        onPressed: () {
                          controllerProfile.updateUserSocialAccountLinks(
                              facebookTextEditingController.text,
                              youtubeTextEditingController.text,
                              twitterTextEditingController.text,
                              instagramTextEditingController.text);
                        },
                      ))
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

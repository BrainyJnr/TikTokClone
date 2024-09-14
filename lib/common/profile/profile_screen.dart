import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:tiktokclone/common/profile/controller/profile_controller.dart';
import 'package:tiktokclone/common/profile/follower/follower_screen.dart';
import 'package:tiktokclone/common/profile/following/following_screen.dart';
import 'package:tiktokclone/common/profile/profile_video_player.dart';
import 'package:tiktokclone/common/settings/account_settings_screen.dart';
import 'package:tiktokclone/fancy/global.dart';
import 'package:url_launcher/url_launcher.dart';

class ProfileScreen extends StatefulWidget {
  final String? visitUserID;

  ProfileScreen({this.visitUserID});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  ProfileController controllerProfile = Get.put(ProfileController());
  bool isFollowingUser = false;

  @override
  void initState() {
    super.initState();
    controllerProfile.updateCurrentUserID(widget.visitUserID.toString());
    getIsFollowingValue();
  }

  Future<void> getIsFollowingValue() async {
    final doc = await FirebaseFirestore.instance
        .collection("users")
        .doc(widget.visitUserID.toString())
        .collection("followers")
        .doc(currentUserID)
        .get();

    setState(() {
      isFollowingUser = doc.exists;
    });
  }

  Future<void> launchUserSocialProfile(String socialLink) async {
    final url = Uri.parse("https://$socialLink");
    if (!await launchUrl(url)) {
      throw Exception("Could not launch $socialLink");
    }
  }

  void handleClickEvent(String choiceClicked) {
    switch (choiceClicked) {
      case "Settings":
        Get.to(AccountSettingsScreen());
        break;
      case "Logout":
        FirebaseAuth.instance.signOut();
        Get.snackbar("Logged Out", "You are logged out from the app.");

        Future.delayed(const Duration(microseconds: 1000),(){
          SystemChannels.platform.invokeMethod("SystemNavigator.pop");
        });
        break;
    }
  }

  readClickedThumbnailInfo(String clickedThumbnailUrl) async {
    var allVideosDocs =
        await FirebaseFirestore.instance.collection("videos").get();

    for (int i = 0; i < allVideosDocs.docs.length; i++) {
      if (((allVideosDocs.docs[i].data() as dynamic)["thumbnailUrl"]) ==
          clickedThumbnailUrl) {
        Get.to(() => ProfileVideoPlayer(
            clickedVideoID:
                (allVideosDocs.docs[i].data() as dynamic)["videoID"]));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ProfileController>(
      builder: (controllerProfile) {
        if (controllerProfile.userMap.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.white),
          );
        }

        return Scaffold(
          appBar: AppBar(
            actions: [
              widget.visitUserID.toString() == currentUserID
                  ? PopupMenuButton<String>(
                      onSelected: handleClickEvent,
                      itemBuilder: (BuildContext context) {
                        return {"Settings", "Logout"}
                            .map((String choiceClicked) {
                          return PopupMenuItem(
                            value: choiceClicked,
                            child: Text(choiceClicked),
                          );
                        }).toList();
                      })
                  : Container()
            ],
            backgroundColor: Colors.black,
            title: Text(
              controllerProfile.userMap["userName"],
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            centerTitle: true,
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // User profile image
                  ClipOval(
                    child: Image.network(
                      controllerProfile.userMap["userImage"],
                      height: 100,
                      width: 100,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Followers - Following - Likes
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Following
                      GestureDetector(
                        onTap: () {
                          Get.to(() => FollowingScreen(
                              visitedProfileUserID:
                                  widget.visitUserID.toString()));
                        },
                        child: Column(
                          children: [
                            Text(
                              controllerProfile.userMap["totalFollowings"],
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              "Following",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Spacer
                      Container(
                        color: Colors.black54,
                        width: 1,
                        height: 15,
                        margin: const EdgeInsets.symmetric(horizontal: 15),
                      ),

                      // Followers
                      GestureDetector(
                        onTap: () {
                          Get.to(() => FollowerScreen(
                              visitedProfileUserID:
                              widget.visitUserID.toString()));
                        },                        child: Column(
                          children: [
                            Text(
                              controllerProfile.userMap["totalFollowers"],
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              "Followers",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Spacer
                      Container(
                        color: Colors.black54,
                        width: 1,
                        height: 15,
                        margin: const EdgeInsets.symmetric(horizontal: 15),
                      ),

                      // Likes
                      GestureDetector(
                        onTap: () {},
                        child: Column(
                          children: [
                            Text(
                              controllerProfile.userMap["totalLikes"] ?? "0",
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              "Likes",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // User social links
// User social links
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Only show social icons if viewing the current logged-in user's profile
                      if (widget.visitUserID.toString() == currentUserID) ...[
                        // Facebook
                        GestureDetector(
                          onTap: () {
                            final facebookLink = controllerProfile.userMap["userFacebook"];
                            if (facebookLink.isEmpty) {
                              Get.snackbar("Facebook Profile",
                                  "You have not connected your profile to Facebook yet.");
                            } else {
                              launchUserSocialProfile(facebookLink);
                            }
                          },
                          child: Image.asset(
                            "assets/images/logo/facebook.png",
                            width: 50,
                          ),
                        ),
                        const SizedBox(width: 10),

                        // Instagram
                        GestureDetector(
                          onTap: () {
                            final instagramLink = controllerProfile.userMap["userInstagram"];
                            if (instagramLink.isEmpty) {
                              Get.snackbar("Instagram Profile",
                                  "You have not connected your profile to Instagram yet.");
                            } else {
                              launchUserSocialProfile(instagramLink);
                            }
                          },
                          child: Image.asset(
                            "assets/images/logo/instagram.png",
                            width: 50,
                          ),
                        ),
                        const SizedBox(width: 10),

                        // Twitter
                        GestureDetector(
                          onTap: () {
                            final twitterLink = controllerProfile.userMap["userTwitter"];
                            if (twitterLink.isEmpty) {
                              Get.snackbar("Twitter Profile",
                                  "You have not connected your profile to Twitter yet.");
                            } else {
                              launchUserSocialProfile(twitterLink);
                            }
                          },
                          child: Image.asset(
                            "assets/images/logo/twitter.png",
                            width: 50,
                          ),
                        ),
                        const SizedBox(width: 10),

                        // YouTube
                        GestureDetector(
                          onTap: () {
                            final youtubeLink = controllerProfile.userMap["userYoutube"];
                            if (youtubeLink.isEmpty) {
                              Get.snackbar("YouTube Profile",
                                  "You have not connected your profile to YouTube yet.");
                            } else {
                              launchUserSocialProfile(youtubeLink);
                            }
                          },
                          child: Image.asset(
                            "assets/images/logo/youtube.png",
                            width: 50,
                          ),
                        ),
                        const SizedBox(width: 10),
                      ]
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Follow/Unfollow/Sign Out Button
                  ElevatedButton(
                    onPressed: () async {
                      if (widget.visitUserID.toString() == currentUserID) {
                        await FirebaseAuth.instance.signOut();
                        Get.snackbar("Logged Out",
                            "You are logged out from this account.");

                        Future.delayed(const Duration(microseconds: 1000),(){
                          SystemChannels.platform.invokeMethod("SystemNavigator.pop");
                        });
                      } else {
                        setState(() {
                          isFollowingUser = !isFollowingUser;
                        });
                        await controllerProfile.followUnFollowUser();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      padding: const EdgeInsets.symmetric(horizontal: 90),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                        side: BorderSide(
                          color: widget.visitUserID.toString() == currentUserID
                              ? Colors.red
                              : isFollowingUser
                                  ? Colors.red
                                  : Colors.green,
                        ),
                      ),
                    ),
                    child: Text(
                      widget.visitUserID.toString() == currentUserID
                          ? "Sign Out"
                          : isFollowingUser
                              ? "Unfollow"
                              : "Follow",
                      style: const TextStyle(
                          fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                  ),

                  //user's videos - thumbnail
                  GridView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            childAspectRatio: .7,
                            crossAxisSpacing: 2),
                    itemCount:
                        controllerProfile.userMap["thumbnailList"].length,
                    itemBuilder: (context, index) {
                      String eachThumbnailUrl =
                          controllerProfile.userMap["thumbnailList"][index];

                      return GestureDetector(
                        onTap: () {
                          readClickedThumbnailInfo(eachThumbnailUrl);
                        },
                        child: Image.network(
                          eachThumbnailUrl,
                          fit: BoxFit.cover,
                        ),
                      );
                    },
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:tiktokclone/common/profile/controller/profile_controller.dart';

import '../profile_screen.dart';

class FollowingScreen extends StatefulWidget {
  final String visitedProfileUserID;

  FollowingScreen({required this.visitedProfileUserID});

  @override
  State<FollowingScreen> createState() => _FollowingScreenState();
}

class _FollowingScreenState extends State<FollowingScreen> {
  List<String> followingKeysList = [];
  List followingUserDataList = [];
  ProfileController controllerProfile = Get.put(ProfileController());

  @override
  void initState() {
    super.initState();
    getFollowingListKeys();
  }

  Future<void> getFollowingListKeys() async {
    try {
      var followingDocument = await FirebaseFirestore.instance
          .collection("users")
          .doc(widget.visitedProfileUserID)
          .collection("following")
          .get();

      followingKeysList = followingDocument.docs.map((doc) => doc.id).toList();

      // Fetch user data after getting keys
      getFollowingKeyDataFromUsersCollection(followingKeysList);
    } catch (e) {
      print("Error fetching following list keys: $e");
    }
  }

  Future<void> getFollowingKeyDataFromUsersCollection(
      List<String> listOfFollowingKeys) async {
    try {
      var allUserDocument = await FirebaseFirestore.instance.collection("users").get();

      followingUserDataList = allUserDocument.docs
          .where((doc) => listOfFollowingKeys.contains((doc.data() as Map<String, dynamic>)["uid"]))
          .map((doc) => doc.data())
          .toList();

      setState(() {});
    } catch (e) {
      print("Error fetching user data: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Column(
          children: [
            Text(
              controllerProfile.userMap["userName"],
              style: const TextStyle(color: Colors.white70),
            ),
            Text(
              "Following " + controllerProfile.userMap["totalFollowings"],
              style: const TextStyle(color: Colors.white54, fontSize: 14),
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: followingUserDataList.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.person_off_sharp,
              color: Colors.white,
              size: MediaQuery.of(context).size.width / 1.9,
            ),
            const SizedBox(height: 20),

          ],
        ),
      )
          : ListView.builder(
        itemCount: followingUserDataList.length,
        itemBuilder: (context, index) {
          var user = followingUserDataList[index];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            child: GestureDetector(
              onTap: () {
                Get.to(ProfileScreen(
                  visitUserID: user["uid"],
                ));
              },
              child: ListTile(
                contentPadding: const EdgeInsets.all(10),
                leading: CircleAvatar(
                  radius: 25,
                  backgroundImage: NetworkImage(
                    user["image"] ?? 'https://example.com/sample-profile-pic.jpg',
                  ),
                ),
                title: Text(
                  user["name"] ?? "No Name",
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                subtitle: Text(
                  user["email"] ?? "No Email",
                  style: const TextStyle(
                    color: Colors.white60,
                    fontSize: 14,
                  ),
                ),
                trailing: IconButton(
                  onPressed: () {
                    Get.to(ProfileScreen(
                      visitUserID: user["uid"],
                    ));
                  },
                  icon: const Icon(
                    Icons.navigate_next,
                    color: Colors.redAccent,
                    size: 30,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}


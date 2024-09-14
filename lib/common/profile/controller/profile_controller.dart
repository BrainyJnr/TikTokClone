import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:tiktokclone/common/home.dart';
import 'package:tiktokclone/fancy/global.dart';

class ProfileController extends GetxController {
  // Reactive Map for storing user information
  final RxMap<String, dynamic> _userMap = RxMap<String, dynamic>({});
  Rx<String> _userID = "".obs;

  // Getter for userMap
  Map<String, dynamic> get userMap => _userMap;

  // Method to update the current user ID and fetch user data
  void updateCurrentUserID(String visitUserID) {
    _userID.value = visitUserID;
    retrieveUserInformation();
  }

  // Method to retrieve user information from Firestore
  Future<void> retrieveUserInformation() async {
    try {
      DocumentSnapshot userDocumentSnapshot = await FirebaseFirestore.instance
          .collection("users")
          .doc(_userID.value)
          .get();

      if (userDocumentSnapshot.exists) {
        final userInfo = userDocumentSnapshot.data() as Map<String, dynamic>;

        // Extract user data from Firestore
        String userName = userInfo["name"] ?? "N/A";
        String userEmail = userInfo["email"] ?? "N/A";
        String userImage = userInfo["image"] ?? "";
        String userUID = userInfo["uid"] ?? "";
        String userYoutube = userInfo["youtube"] ?? "";
        String userInstagram = userInfo["instagram"] ?? "";
        String userTwitter = userInfo["twitter"] ?? "";
        String userFacebook = userInfo["facebook"] ?? "";
        int totalLikes = 0; // Assuming this is in the database
        int totalFollowers = 0;
        int totalFollowings = 0;
        bool isFollowing = false;
        List<String> thumbnailList = [];

        //get user's videos info
        var currentUserVideos = await FirebaseFirestore.instance
            .collection("videos")
            .orderBy("publishedDateTime", descending: true)
            .where("userID", isEqualTo: _userID.value)
            .get();

        for (int i = 0; i < currentUserVideos.docs.length; i++) {
          thumbnailList.add(
              (currentUserVideos.docs[i].data() as dynamic)["thumbnailUrl"]);
        }

        //Get the total number of likes
        for (var eachVideo in currentUserVideos.docs) {
          totalLikes =
              totalLikes + (eachVideo.data()["likeList"] as List).length;
        }

        // Get the total number of followers
        var followersNumDocument = await FirebaseFirestore.instance
            .collection("users")
            .doc(_userID.value)
            .collection("followers")
            .get();
        totalFollowers = followersNumDocument.docs.length;

        // Get the total number of followings
        var followingNumDocument = await FirebaseFirestore.instance
            .collection("users")
            .doc(_userID.value)
            .collection("following")
            .get();
        totalFollowings = followingNumDocument.docs.length;

        // Check if currentUser is following the visited profile
        var currentUserDoc = await FirebaseFirestore.instance
            .collection("users")
            .doc(_userID.value)
            .collection("followers")
            .doc(currentUserID)
            .get();
        isFollowing = currentUserDoc.exists;

        // Update the userMap with the retrieved data
        _userMap.value = {
          "userName": userName,
          "userEmail": userEmail,
          "userImage":
              userImage + "?timestamp=${DateTime.now().millisecondsSinceEpoch}",
          "userUID": userUID,
          "userYoutube": userYoutube,
          "userInstagram": userInstagram,
          "userTwitter": userTwitter,
          "userFacebook": userFacebook,
          "totalLikes": totalLikes.toString(), // Store as String
          "totalFollowers": totalFollowers.toString(),
          "totalFollowings": totalFollowings.toString(),
          "isFollowing": isFollowing,
          "thumbnailList": thumbnailList,
        };

        // Notify the UI to rebuild
        update();
      } else {
        print("User document not found");
      }
    } catch (e) {
      print("Error retrieving user information: $e");
    }
  }

  // Method to follow/unfollow a user
  Future<void> followUnFollowUser() async {
    var document = await FirebaseFirestore.instance
        .collection("users")
        .doc(_userID.value)
        .collection("followers")
        .doc(currentUserID)
        .get();

    if (document.exists) {
      // Unfollow the user
      await FirebaseFirestore.instance
          .collection("users")
          .doc(_userID.value)
          .collection("followers")
          .doc(currentUserID)
          .delete();

      await FirebaseFirestore.instance
          .collection("users")
          .doc(currentUserID)
          .collection("following")
          .doc(_userID.value)
          .delete();

      // Decrement the totalFollowers count
      _userMap.update(
          "totalFollowers", (value) => (int.parse(value) - 1).toString());
      _userMap.update("isFollowing", (value) => false);
    } else {
      // Follow the user
      await FirebaseFirestore.instance
          .collection("users")
          .doc(_userID.value)
          .collection("followers")
          .doc(currentUserID)
          .set({});

      await FirebaseFirestore.instance
          .collection("users")
          .doc(currentUserID)
          .collection("following")
          .doc(_userID.value)
          .set({});

      // Increment the totalFollowers count
      _userMap.update(
          "totalFollowers", (value) => (int.parse(value) + 1).toString());
      _userMap.update("isFollowing", (value) => true);
    }

    update(); // Notify the UI to rebuild
  }

  updateUserSocialAccountLinks(
      String facebook, String youtube, String twitter, String instagram) async {
    try {
      final Map<String, dynamic> userSocialLinkMsg = {
        "facebook": facebook,
        "instagram": instagram,
        "twitter": twitter,
        "youtube": youtube
      };
      await FirebaseFirestore.instance
          .collection("users")
          .doc(currentUserID)
          .update(userSocialLinkMsg);
      Get.snackbar(
          "Social Links", "your social links are updated successfully.");
      Get.to(HomeScreen());
    } catch (errorMsg) {
      Get.snackbar("Error Updating Account", "Please try again");
    }
  }
}

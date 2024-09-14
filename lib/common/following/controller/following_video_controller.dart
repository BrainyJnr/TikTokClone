import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:tiktokclone/fancy/global.dart';
import '../../upload_video/model/upload_video_model.dart';

class ControllerFollowingVideos extends GetxController {
  // List of videos followed by the user
  final Rx<List<Video>> followingVideoList = Rx<List<Video>>([]);
  // Track the current playing video index
  final RxInt currentVideoIndex = 0.obs;
  // Track the visibility of the comments section
  final RxBool isCommentsSectionVisible = false.obs;

  // List of user IDs the current user follows
  List<String> followingKeyList = [];

  // Fetch all videos from users the current user follows
  List<Video> get followingAllVideoList => followingVideoList.value;

  @override
  void onInit() {
    super.onInit();
    getFollowingUsersVideos();
  }

  // Method to fetch videos of the users being followed
  Future<void> getFollowingUsersVideos() async {
    try {
      // Fetch all users the current user is following
      var followingDocs = await FirebaseFirestore.instance
          .collection("users")
          .doc(FirebaseAuth.instance.currentUser!.uid) // current user
          .collection("following")
          .get();

      // Extract user IDs from the following documents
      followingKeyList = followingDocs.docs.map((doc) => doc.id).toList();

      // If there are no users followed, clear the video list
      if (followingKeyList.isEmpty) {
        followingVideoList.value = [];
        print("No users followed.");
        return;
      }

      // Bind stream to listen for videos from followed users
      followingVideoList.bindStream(FirebaseFirestore.instance
          .collection("videos")
          .orderBy("publishedDateTime", descending: true)
          .snapshots()
          .map((snapshot) {
        List<Video> videosFromFollowing = [];

        for (var videoDoc in snapshot.docs) {
          String videoUserID = videoDoc["userID"];

          // Check if the video's userID matches any followed users
          if (followingKeyList.contains(videoUserID)) {
            videosFromFollowing.add(Video.fromDocumentSnapshot(videoDoc));
          }
        }

        if (videosFromFollowing.isEmpty) {
          print("No videos from followed users.");
        }

        return videosFromFollowing;
      }));
    } catch (e) {
      print("Error fetching following users' videos: $e");
    }
  }

  // Method to set the current video index
  void setCurrentVideoIndex(int index) {
    currentVideoIndex.value = index;
  }

  // Like or unlike a video
  Future<void> likeOrUnlikeVideo(String videoID) async {
    try {
      var currentUserID = FirebaseAuth.instance.currentUser!.uid;

      // Get the video document
      DocumentSnapshot videoSnapshot = await FirebaseFirestore.instance
          .collection("videos")
          .doc(videoID)
          .get();

      List<dynamic> likeList = (videoSnapshot.data() as Map<String, dynamic>)["likeList"];

      // Like or unlike logic
      if (likeList.contains(currentUserID)) {
        // If already liked, remove the like
        await FirebaseFirestore.instance
            .collection("videos")
            .doc(videoID)
            .update({
          "likeList": FieldValue.arrayRemove([currentUserID])
        });
      } else {
        // If not liked, add the like
        await FirebaseFirestore.instance
            .collection("videos")
            .doc(videoID)
            .update({
          "likeList": FieldValue.arrayUnion([currentUserID])
        });
      }
    } catch (e) {
      print("Error liking/unliking video: $e");
    }
  }

  // Toggle the visibility of the comments section
  void toggleCommentsSectionVisibility() {
    isCommentsSectionVisible.value = !isCommentsSectionVisible.value;
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import '../../upload_video/model/upload_video_model.dart';

class ControllerFollowingVideo extends GetxController {
  final Rx<List<Video>> forYouVideosList = Rx<List<Video>>([]);
  final RxInt currentVideoIndex = 0.obs; // Track the currently playing video index
  final RxBool isCommentsSectionVisible = false.obs;

  List<Video> get forYouAllVideoList => forYouVideosList.value;

  @override
  void onInit() {
    super.onInit();

    forYouVideosList.bindStream(FirebaseFirestore.instance
        .collection("videos")
        .orderBy("totalComments", descending: true)
        .snapshots()
        .map((QuerySnapshot snapshotQuery) {
      List<Video> videosList = [];

      for (var eachVideo in snapshotQuery.docs) {
        videosList.add(Video.fromDocumentSnapshot(eachVideo));
      }
      return videosList;
    }));
  }

  // Set the current video index
  void setCurrentVideoIndex(int index) {
    currentVideoIndex.value = index;
  }

  // Get the current video
  Video? get currentVideo =>
      (currentVideoIndex.value < forYouVideosList.value.length)
          ? forYouVideosList.value[currentVideoIndex.value]
          : null;

  Future<void> likeOrUnlikeVideo(String videoID) async {
    var currentUserID = FirebaseAuth.instance.currentUser!.uid.toString();

    DocumentSnapshot snapshotDoc = await FirebaseFirestore.instance
        .collection("videos")
        .doc(videoID)
        .get();

    if ((snapshotDoc.data() as dynamic)["likeList"].contains(currentUserID)) {
      await FirebaseFirestore.instance
          .collection("videos")
          .doc(videoID)
          .update({
        "likeList": FieldValue.arrayRemove([currentUserID])
      });
    } else {
      await FirebaseFirestore.instance
          .collection("videos")
          .doc(videoID)
          .update({
        "likeList": FieldValue.arrayUnion([currentUserID]),
      });
    }
  }

  Future<void> decrementCommentCount(String videoID) async {
    try {
      final videoDoc =
      FirebaseFirestore.instance.collection('videos').doc(videoID);
      await videoDoc.update({
        'totalComments': FieldValue.increment(-1),
      });
    } catch (e) {
      print("Error decrementing comment count: $e");
    }
  }

  void toggleCommentsSectionVisibility() {
    isCommentsSectionVisible.value = !isCommentsSectionVisible.value;
  }
}

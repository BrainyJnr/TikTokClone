import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import '../../upload_video/model/upload_video_model.dart';

class VideoControllerProfile extends GetxController {
  final Rx<List<Video>> videoFileList = Rx<List<Video>>([]);
  final RxInt currentVideoIndex =
      0.obs; // Track the currently playing video index
  List<Video> get clickedVideoFile => videoFileList.value;
  final Rx<String> _videoID = "".obs;

  String get ClickedvideoID => _videoID.value;

  setVideoID(String vID) {
    _videoID.value = vID;
  }

  getClickedInfo() {
    videoFileList.bindStream(FirebaseFirestore.instance
        .collection("videos")
        .orderBy("totalComments", descending: true)
        .snapshots()
        .map((QuerySnapshot snapshotQuery) {
      List<Video> videosList = [];

      for (var eachVideo in snapshotQuery.docs) {
        if (eachVideo["videoID"] == ClickedvideoID) {
          videosList.add(Video.fromDocumentSnapshot(eachVideo));
        }
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
      (currentVideoIndex.value < videoFileList.value.length)
          ? videoFileList.value[currentVideoIndex.value]
          : null;

  @override
  void onInit() {
    super.onInit();
    getClickedInfo();
  }

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
}

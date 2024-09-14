import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:tiktokclone/common/comment/comment_moodel.dart';


class CommentsController extends GetxController {
  String currentVideoID = "";
  final Rx<List<Comment>> commentList = Rx<List<Comment>>([]);
  final RxBool isCommentsSectionVisible = false.obs; // Use RxBool
  final RxString showDeleteOptionID = ''.obs; // ID of the comment to show delete option for

  List<Comment> get ListOfComment => commentList.value;

  // Method to update the current video ID and fetch comments for that video
  void updateCurrentVideoID(String videoID) {
    currentVideoID = videoID;
    retrieveComments();
  }

  // Method to save a new comment to the database
  Future<void> saveNewCommentToDatabase(String commentTextData) async {
    try {
      String commentID = DateTime.now().millisecondsSinceEpoch.toString();

      DocumentSnapshot snapshotUserDocument = await FirebaseFirestore.instance
          .collection("users")
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .get();

      Comment commentModel = Comment(
        userName: (snapshotUserDocument.data() as dynamic)["name"],
        userID: FirebaseAuth.instance.currentUser!.uid,
        userProfileImage: (snapshotUserDocument.data() as dynamic)["image"],
        commentText: commentTextData,
        commentID: commentID,
        commentLikeList: [],
        publishDatTime: DateTime.now(),
      );

      // Save new comment info to database
      await FirebaseFirestore.instance
          .collection("videos")
          .doc(currentVideoID)
          .collection("comments")
          .doc(commentID)
          .set(commentModel.toJson());

      // Update comments counter
      DocumentSnapshot currentVideoSnapshotDocument = await FirebaseFirestore
          .instance
          .collection("videos")
          .doc(currentVideoID)
          .get();

      await FirebaseFirestore.instance
          .collection("videos")
          .doc(currentVideoID)
          .update({
        "totalComments":
        (currentVideoSnapshotDocument.data() as dynamic)["totalComments"] + 1,
      });
    } catch (error) {
      Get.snackbar("Error in Posting New Comment", error.toString());
    }
  }

  // Method to retrieve comments for the current video
  void retrieveComments() {
    commentList.bindStream(FirebaseFirestore.instance
        .collection("videos")
        .doc(currentVideoID)
        .collection("comments")
        .orderBy("publishDatTime", descending: true)
        .snapshots()
        .map((QuerySnapshot commentSnapshot) {
      List<Comment> commentsListOfVideo = [];

      for (var eachComment in commentSnapshot.docs) {
        commentsListOfVideo.add(Comment.fromDocumentSnapshot(eachComment));
      }

      return commentsListOfVideo;
    }));
  }

  // Method to like or unlike a comment
  Future<void> likeUnlikeComment(String commentID) async {
    DocumentSnapshot commentDocumentSnapshot = await FirebaseFirestore.instance
        .collection("videos")
        .doc(currentVideoID)
        .collection("comments")
        .doc(commentID)
        .get();

    // Toggle like status
    if ((commentDocumentSnapshot.data() as dynamic)["commentLikeList"]
        .contains(FirebaseAuth.instance.currentUser!.uid)) {
      await FirebaseFirestore.instance
          .collection("videos")
          .doc(currentVideoID)
          .collection("comments")
          .doc(commentID)
          .update({
        "commentLikeList":
        FieldValue.arrayRemove([FirebaseAuth.instance.currentUser!.uid]),
      });
    } else {
      await FirebaseFirestore.instance
          .collection("videos")
          .doc(currentVideoID)
          .collection("comments")
          .doc(commentID)
          .update({
        "commentLikeList":
        FieldValue.arrayUnion([FirebaseAuth.instance.currentUser!.uid]),
      });
    }
  }

  // Method to toggle the visibility of the comments section
  void toggleCommentsSectionVisibility() {
    isCommentsSectionVisible.value = !isCommentsSectionVisible.value;
  }

  // Method to show the delete option for a comment
  void showDeleteOption(String commentID) {
    showDeleteOptionID.value = commentID;
  }

  // Method to hide the delete option
  void hideDeleteOption() {
    showDeleteOptionID.value = '';
  }  Future<void> fetchCommentsForVideo(String videoID) async {
    try {
      final commentsSnapshot = await FirebaseFirestore.instance
          .collection('videos')
          .doc(videoID)
          .collection('comments')
          .get();

      // Update the reactive list with new data
      commentList.value = commentsSnapshot.docs.map((doc) {
        return Comment.fromDocumentSnapshot(doc);
      }).toList();
    } catch (e) {
      // Handle error
      print("Error fetching comments: $e");
    }
  }


  // Method to delete a comment from the database
  Future<void> deleteComment(String commentID) async {
    try {
      // Delete the comment from Firestore
      await FirebaseFirestore.instance
          .collection('videos')
          .doc(currentVideoID)
          .collection('comments')
          .doc(commentID)
          .delete();

      // Remove the comment from the ListOfComment
      commentList.value.removeWhere((comment) => comment.commentID == commentID);

      // Decrement the total comment count
      await decrementCommentCount(currentVideoID);  // Ensure this is awaited correctly

      // Optionally, you can also refresh or re-fetch comments after deleting
      // retrieveComments();

    } catch (e) {
      // Handle error
      print("Error deleting comment: $e");
      Get.snackbar("Error", "Failed to delete comment: $e");
    }
  }

  Future<void> decrementCommentCount(String videoID) async {
    try {
      final videoDoc = FirebaseFirestore.instance.collection('videos').doc(videoID);
      await videoDoc.update({
        'totalComments': FieldValue.increment(-1),  // Correct usage of FieldValue.increment
      });
    } catch (e) {
      print("Error decrementing comment count: $e");
    }
  }


}

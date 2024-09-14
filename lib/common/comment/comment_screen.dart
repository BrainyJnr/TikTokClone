import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:tiktokclone/common/comment/controller/comment_controller.dart';
import 'package:timeago/timeago.dart' as tAgo;

class CommentScreen extends StatelessWidget {
  final String videoID;

  CommentScreen({required this.videoID});

  final TextEditingController commentTextEditingController = TextEditingController();
  final CommentsController commentsController = Get.put(CommentsController());

  @override
  Widget build(BuildContext context) {
    commentsController.updateCurrentVideoID(videoID);

    void _showDeleteConfirmationDialog(BuildContext context, String commentID) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Delete Comment"),
            content: const Text("Are you sure you want to delete this comment?"),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text("Cancel"),
              ),
              TextButton(
                onPressed: () {
                  commentsController.deleteComment(commentID);
                  Navigator.of(context).pop();
                },
                child: const Text("Delete", style: TextStyle(color: Colors.red)),
              ),
            ],
          );
        },
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        children: [
          // Upper half for the video (50% of the screen height)
          Expanded(
            flex: 1,
            child: Container(
              // Video content displayed in the upper half
              color: Colors.black,
            ),
          ),

          // Bottom half for comments (50% of the screen height)
          Expanded(
            flex: 1,
            child: DraggableScrollableSheet(
              initialChildSize: 1.0, // Comment section takes entire bottom half
              minChildSize: 0.5, // Allow dragging the comments to half size
              maxChildSize: 1.0, // Maximum drag up is full screen (but initially it's at 50%)
              builder: (context, scrollController) {
                return Container(
                  decoration: BoxDecoration(
                    color: Colors.black, // Background for comment section
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  child: Column(
                    children: [
                      // Drag handle indicator
                      Container(
                        width: 40,
                        height: 5,
                        margin: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: Colors.grey[800],
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),

                      // Comments list section
                      Expanded(
                        child: Obx(() {
                          return ListView.builder(
                            controller: scrollController, // Sync scrolling with draggable sheet
                            itemCount: commentsController.ListOfComment.length,
                            itemBuilder: (context, index) {
                              final eachCommentInfo = commentsController.ListOfComment[index];

                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
                                child: GestureDetector(
                                  onLongPress: () {
                                    _showDeleteConfirmationDialog(context, eachCommentInfo.commentID.toString());
                                  },
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      // Profile Image
                                      CircleAvatar(
                                        radius: 18,
                                        backgroundImage: NetworkImage(eachCommentInfo.userProfileImage.toString()),
                                      ),
                                      const SizedBox(width: 10),

                                      // Comment Text
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            // Username and Comment Text
                                            Text(
                                              eachCommentInfo.userName.toString(),
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              eachCommentInfo.commentText.toString(),
                                              style: const TextStyle(
                                                color: Colors.white70,
                                                fontSize: 14,
                                              ),
                                            ),

                                            // Time and Like Count
                                            Row(
                                              children: [
                                                Text(
                                                  tAgo.format(eachCommentInfo.publishDatTime.toDate()),
                                                  style: const TextStyle(
                                                    color: Colors.grey,
                                                    fontSize: 12,
                                                  ),
                                                ),
                                                const SizedBox(width: 10),
                                                Text(
                                                  "${eachCommentInfo.commentLikeList?.length ?? 0} likes",
                                                  style: const TextStyle(
                                                    color: Colors.grey,
                                                    fontSize: 12,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),

                                      // Like Button
                                      IconButton(
                                        onPressed: () {
                                          commentsController.likeUnlikeComment(eachCommentInfo.commentID.toString());
                                        },
                                        icon: Icon(
                                          Icons.favorite,
                                          color: eachCommentInfo.commentLikeList?.contains(FirebaseAuth.instance.currentUser!.uid) == true
                                              ? Colors.red
                                              : Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          );
                        }),
                      ),

                      // Add New Comment Box
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Row(
                          children: [
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                                decoration: BoxDecoration(
                                  color: Colors.white24,
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                child: TextFormField(
                                  controller: commentTextEditingController,
                                  style: const TextStyle(color: Colors.white),
                                  decoration: const InputDecoration(
                                    hintText: "Add a comment...",
                                    hintStyle: TextStyle(color: Colors.grey),
                                    border: InputBorder.none,
                                  ),
                                ),
                              ),
                            ),
                            IconButton(
                              onPressed: () {
                                if (commentTextEditingController.text.isNotEmpty) {
                                  commentsController.saveNewCommentToDatabase(commentTextEditingController.text);
                                  commentTextEditingController.clear();
                                }
                              },
                              icon: const Icon(Icons.send, color: Colors.white, size: 25),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

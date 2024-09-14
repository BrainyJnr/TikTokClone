import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tiktokclone/widgets/circular_image_animation.dart';
import 'package:tiktokclone/widgets/custom_video_player.dart';
import '../comment/comment_screen.dart';
import '../comment/controller/comment_controller.dart';
import '../profile/profile_screen.dart';
import 'conttroller/foryou_controller.dart';

import 'package:get/get_core/src/get_main.dart';

class ForYouVideoScreen extends StatefulWidget {
  @override
  _ForYouVideoScreenState createState() => _ForYouVideoScreenState();
}

class _ForYouVideoScreenState extends State<ForYouVideoScreen> {
  final ControllerFollowingVideo controllerVideosForYou =
      Get.put(ControllerFollowingVideo());
  final CommentsController commentsController = Get.put(CommentsController());
  final TextEditingController commentTextEditingController =
      TextEditingController();

  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(
      initialPage: controllerVideosForYou.currentVideoIndex.value,
      viewportFraction: 1,
    );

    // Add a listener to update the index
    _pageController.addListener(() {
      if (_pageController.page != null) {
        controllerVideosForYou.currentVideoIndex.value =
            _pageController.page!.toInt();
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _showCommentsSection(String videoID) {
    commentsController.updateCurrentVideoID(videoID);
    commentsController.toggleCommentsSectionVisibility(); // Toggle visibility
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Video PageView
          Obx(() {
            return PageView.builder(
              itemCount: controllerVideosForYou.forYouAllVideoList.length,
              controller: _pageController,
              scrollDirection: Axis.vertical,
              itemBuilder: (context, index) {
                final eachVideoInfo =
                    controllerVideosForYou.forYouAllVideoList[index];

                return Stack(
                  children: [
                    // Video Player
                    CustomVideoPlayer(
                      videoFileUrl: eachVideoInfo.videoUrl.toString(),
                      autoPlay: true,
                    ),

                    // Bottom-Left Panel
                    Positioned(
                      bottom: 70,
                      left: 10,
                      right: 10,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Username
                          Text(
                            "@${eachVideoInfo.userName}",
                            style: GoogleFonts.abel(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 1),

                          // Description and Tags
                          Text(
                            eachVideoInfo.descriptionTags.toString(),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.abel(
                              fontSize: 16,
                              fontWeight: FontWeight.normal,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 1),

                          // Artist and Song Name
                          Row(
                            children: [
                              Icon(Icons.music_note,
                                  size: 16, color: Colors.white),
                              const SizedBox(width: 5),
                              Expanded(
                                child: Text(
                                  eachVideoInfo.artistSongName.toString(),
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.alexBrush(
                                    fontSize: 16,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Right Panel
                    Positioned(
                      right: 1,
                      top: 180,
                      child: Container(
                        width: 80,
                        margin: EdgeInsets.only(
                            top: MediaQuery.of(context).size.height / 5),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            // Profile
                            GestureDetector(
                              onTap: () {
                                // Navigate to the user's profile
                                Get.to(ProfileScreen(
                                    visitUserID:
                                        eachVideoInfo.userID.toString()));
                              },
                              child: SizedBox(
                                width: 62,
                                height: 62,
                                child: Stack(
                                  children: [
                                    Positioned(
                                      left: 4,
                                      child: Container(
                                        width: 52,
                                        height: 52,
                                        padding: EdgeInsets.all(2),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(25),
                                        ),
                                        child: ClipOval(
                                          child: Image(
                                            width: 52,
                                            fit: BoxFit.cover,
                                            image: NetworkImage(eachVideoInfo
                                                .userProfileImage
                                                .toString()),
                                          ),
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ),

                            // Like
                            Column(
                              children: [
                                // Like Button
                                IconButton(
                                  onPressed: () {
                                    controllerVideosForYou.likeOrUnlikeVideo(
                                        eachVideoInfo.videoID.toString());
                                  },
                                  icon: Icon(
                                    Icons.favorite_rounded,
                                    size: 40,
                                    color: eachVideoInfo.likeList!.contains(
                                            FirebaseAuth
                                                .instance.currentUser!.uid)
                                        ? Colors.red
                                        : Colors.white,
                                  ),
                                ),

                                // Total Likes
                                Padding(
                                  padding: EdgeInsets.only(bottom: 8.0),
                                  child: Text(
                                    eachVideoInfo.likeList!.length.toString(),
                                    style: const TextStyle(
                                        fontSize: 14, color: Colors.white),
                                  ),
                                )
                              ],
                            ),

                            // Total Comments
                            Column(
                              children: [
                                // Comment Button
                                IconButton(
                                  onPressed: () {
                                    Get.to(CommentScreen(
                                        videoID:
                                            eachVideoInfo.videoID.toString()));
                                  },
                                  icon: Icon(
                                    Icons.add_comment,
                                    size: 40,
                                    color: Colors.white,
                                  ),
                                ),

                                // Total Comments
                                Text(
                                  eachVideoInfo.totalComments.toString(),
                                  style: const TextStyle(
                                      fontSize: 14, color: Colors.white),
                                )
                              ],
                            ),

                            // Share Button
                            Column(
                              children: [
                                // Share Button
                                IconButton(
                                  onPressed: () {},
                                  icon: Icon(
                                    Icons.share,
                                    size: 40,
                                    color: Colors.white,
                                  ),
                                ),

                                // Total Shares
                                Text(
                                  eachVideoInfo.totalShares.toString(),
                                  style: const TextStyle(
                                      fontSize: 14, color: Colors.white),
                                ),

                                CircularImageAnimation(
                                  widgetAnimation: SizedBox(
                                    width: 62,
                                    height: 62,
                                    child: Column(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(12),
                                          height: 52,
                                          width: 52,
                                          decoration: BoxDecoration(
                                            gradient:
                                                const LinearGradient(colors: [
                                              Colors.grey,
                                              Colors.white,
                                            ]),
                                            borderRadius:
                                                BorderRadius.circular(25),
                                          ),
                                          child: ClipOval(
                                            child: Image(
                                              fit: BoxFit.cover,
                                              image: NetworkImage(eachVideoInfo
                                                  .userProfileImage
                                                  .toString()),
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            );
          }),

          // Comments Section (Add this widget to toggle visibility)
        ],
      ),
    );
  }
}

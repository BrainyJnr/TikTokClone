import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:simple_circular_progress_bar/simple_circular_progress_bar.dart';
import 'package:tiktokclone/common/upload_video/controller/upload_controller.dart';
import 'package:tiktokclone/fancy/global.dart';
import 'dart:io';

import 'package:video_player/video_player.dart';

import '../../widgets/input_text_widget.dart';

class UploadForm extends StatefulWidget {
  final File videoFile;
  final String videoPath;

  UploadForm({required this.videoFile, required this.videoPath});

  @override
  State<UploadForm> createState() => _UploadFormState();
}

class _UploadFormState extends State<UploadForm> {

  UploadController uploadVideoController = Get.put(UploadController());
  VideoPlayerController? PlayerController;
  TextEditingController artistSongTextEditingController =
      TextEditingController();
  TextEditingController descriptionTextEditingController =
      TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setState(() {
      PlayerController = VideoPlayerController.file(widget.videoFile);
    });
    PlayerController!.initialize();
    PlayerController!.play();
    PlayerController!.setVolume(2);
    PlayerController!.setLooping(true);
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();

    PlayerController!.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            //display video player
            SizedBox(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.width * 9 / 9, // Aspect ratio for video player
              child: VideoPlayer(PlayerController!),
            ),

            const SizedBox(
              height: 30,
            ),
            // Upload Now Button
            // Circular Progress Bar
            // Input Fields
            showProgressBar == true
                ? Container(
                    child: const SimpleCircularProgressBar(
                      progressColors: [
                        Colors.green,
                        Colors.blueAccent,
                        Colors.red,
                        Colors.amber,
                        Colors.purpleAccent,
                      ],
                      animationDuration: 5,
                      backColor: Colors.white38,
                    ),
                  )
                : Column(children: [
                    // artist song
                    Container(
                      width: MediaQuery.of(context).size.width,
                      margin: EdgeInsets.symmetric(horizontal: 20),
                      child: InputTextWidget(
                        textEditingController: artistSongTextEditingController,
                        lableString: "Artist - Song",
                        iconData: Icons.music_video_sharp,
                        isObscure: false,
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),

                    // description tags
                    Container(
                      width: MediaQuery.of(context).size.width,
                      margin: EdgeInsets.symmetric(horizontal: 20),
                      child: InputTextWidget(
                        textEditingController: descriptionTextEditingController,
                        lableString: "Description - Tags",
                        iconData: Icons.slideshow_sharp,
                        isObscure: false,
                      ),
                    ),

                    SizedBox(
                      height: 10,
                    ),

                    // Upload Now Button
                    Container(
                      width: MediaQuery.of(context).size.width - 30,
                      height: 54,
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.all(Radius.circular(10))),
                      child: InkWell(
                        onTap: () {
                          if (artistSongTextEditingController.text.isNotEmpty &&
                              descriptionTextEditingController
                                  .text.isNotEmpty) {
                            uploadVideoController
                                .saveVideoInformationToFirestoreDatabase(
                                    artistSongTextEditingController.text,
                                    descriptionTextEditingController.text,
                                    widget.videoPath,
                                    context);
                          }
                          setState(() {
                            showProgressBar = true;
                          });
                        },
                        child: Center(
                          child: Text(
                            "Upload Now",
                            style: TextStyle(
                              fontSize: 20,
                              color: Colors.black,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    )
                  ])
          ],
        ),
      ),
    );
  }
}

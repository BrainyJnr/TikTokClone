import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:tiktokclone/common/home.dart';
import 'package:tiktokclone/common/upload_video/model/upload_video_model.dart';

import 'package:video_compress/video_compress.dart';

import '../../../fancy/global.dart';



class UploadController extends GetxController {
  compressVideoFile(String videoFilePath) async {
    final compressVideoFilePath = await VideoCompress.compressVideo(
        videoFilePath,
        quality: VideoQuality.LowQuality);

    return compressVideoFilePath!.file;
  }

  UploadCompressVideoFileToFirebaseStorage(
      String videoID, String videoFilePath) async {
    UploadTask videoUploadTask = FirebaseStorage.instance
        .ref()
        .child("All Videos")
        .child(videoID)
        .putFile(await compressVideoFile(videoFilePath));

    TaskSnapshot snapshot = await videoUploadTask;

    String downloadUrlOfUploadVideo = await snapshot.ref.getDownloadURL();

    return downloadUrlOfUploadVideo;
  }

  getThumbnailImage(String videoFilePath) async {
    final thumbnailImage = await VideoCompress.getFileThumbnail(videoFilePath);

    return thumbnailImage;
  }

  UploadThumbnailImageToFirebaseStorage(
      String videoID, String videoFilePath) async {
    UploadTask thumbnailUploadTask = FirebaseStorage.instance
        .ref()
        .child("All Thumbnails")
        .child(videoID)
        .putFile(await getThumbnailImage(videoFilePath));

    TaskSnapshot snapshot = await thumbnailUploadTask;

    String downloadUrlOfUploadThumbnail = await snapshot.ref.getDownloadURL();

    return downloadUrlOfUploadThumbnail;
  }

  saveVideoInformationToFirestoreDatabase(
      String artistSongName,
      String descriptionTags,
      String videoFilePaath,
      BuildContext context) async {
    try {
      DocumentSnapshot userDocumentSnapshot = await FirebaseFirestore.instance
          .collection("users")
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .get();
      String videoID = DateTime.now().microsecondsSinceEpoch.toString();

      //1. upload video to storage
      String videoDownloadUrl = await UploadCompressVideoFileToFirebaseStorage(
          videoID, videoFilePaath);

      //2. upload thumbnail to storage
      String thumbnailDownloadUrl =
      await UploadThumbnailImageToFirebaseStorage(videoID, videoFilePaath);

      //3. save overall video info to firestore database
      Video videoObject = Video(
        userID: FirebaseAuth.instance.currentUser!.uid,
        userName: (userDocumentSnapshot.data() as Map<String, dynamic>)["name"],
        userProfileImage: (userDocumentSnapshot.data() as Map<String, dynamic>)["image"],
        videoID: videoID,
        totalComments: 0,
        totalShares: 0,
        likeList: [],
        artistSongName: artistSongName,
        descriptionTags: descriptionTags,
        videoUrl: videoDownloadUrl,
        thumbnailUrl: thumbnailDownloadUrl,
        publishedDateTime: DateTime.now().millisecondsSinceEpoch,
      );
      await FirebaseFirestore.instance.collection("videos")
          .doc(videoID).set(videoObject.toJson());

      showProgressBar = false;
      Get.to(HomeScreen());

      Get.snackbar("New Video", "you have successfully uploaded your new video");

    } catch (errorMsg) {
      Get.snackbar("Video Upload Unsuccessful",
          "Error occurred, your video is not uploaded. Try again");
    }
  }
}
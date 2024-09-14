import 'package:cloud_firestore/cloud_firestore.dart';

class Comment{
  String? userName;
  String? commentText;
  String? userProfileImage;
  String? userID;
  String? commentID;
  final publishDatTime;
  List? commentLikeList;

  Comment({
    this.userName,
    this.commentText,
    this.userProfileImage,
    this.userID,
    this.commentID,
    this.publishDatTime,
    this.commentLikeList,
  });

  Map<String, dynamic> toJson() =>  {
    "userName": userName,
    "commentText": commentText,
    "userProfileImage": userProfileImage,
    "userID": userID,
    "commentID": commentID,
    "publishDatTime": publishDatTime,
    "commentLikeList": commentLikeList,
  };

  static Comment fromDocumentSnapshot(DocumentSnapshot snapshotDoc){
    var documentSnapshot = snapshotDoc.data() as Map<String, dynamic>;

    return Comment(
      userName: documentSnapshot["userName"],
      commentText: documentSnapshot["commentText"],
      userProfileImage: documentSnapshot["userProfileImage"],
      userID: documentSnapshot["userID"],
      commentID: documentSnapshot["commentID"],
      publishDatTime: documentSnapshot["publishDatTime"],
      commentLikeList: documentSnapshot["commentLikeList"],
    );
  }
}
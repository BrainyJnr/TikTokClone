import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:tiktokclone/authentication/users/user.dart';

class ControllerSearch extends GetxController {
  final Rx<List<User>> _userSearchedList = Rx<List<User>>([]);

  List<User> get userSearchedList => _userSearchedList.value;

  searchForUser(String textInput) async {
    // Clear the list to avoid appending
    _userSearchedList.value = [];

    _userSearchedList.bindStream(FirebaseFirestore.instance
        .collection("users")
        .where("name", isGreaterThanOrEqualTo: textInput)
        .where("name", isLessThan: textInput + 'z') // Limits search results
        .snapshots()
        .map((QuerySnapshot searchedUserQuerySnapshot) {
      List<User> searchList = [];

      for (var user in searchedUserQuerySnapshot.docs) {
        searchList.add(User.fromSnap(user));
      }

      return searchList;
    }));
  }
}

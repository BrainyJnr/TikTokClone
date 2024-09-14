import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../authentication/users/user.dart';
import '../profile/profile_screen.dart';
import 'controller/search_controller.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  ControllerSearch controllerSearch = Get.put(ControllerSearch());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: Container(
          height: 40,
          decoration: BoxDecoration(
            color: Colors.grey[850],
            borderRadius: BorderRadius.circular(8),
          ),
          child: TextFormField(
            decoration: InputDecoration(
              hintText: "Search",
              hintStyle: const TextStyle(fontSize: 18, color: Colors.grey),
              prefixIcon: const Icon(
                Icons.search,
                color: Colors.white,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.only(left: 10),
            ),
            style: const TextStyle(color: Colors.white),
            onFieldSubmitted: (textInput) {
              controllerSearch.searchForUser(textInput);
            },
            onChanged: (textInput) {
              controllerSearch.searchForUser(textInput);
            },
          ),
        ),
      ),
      body: Obx(() {
        return controllerSearch.userSearchedList.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      "assets/images/common/search.png",
                      width: MediaQuery.of(context).size.width / 1.5,
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      "Search for users",
                      style: TextStyle(color: Colors.grey, fontSize: 16),
                    ),
                  ],
                ),
              )
            : ListView.builder(
                itemCount: controllerSearch.userSearchedList.length,
                itemBuilder: (context, index) {
                  User eachSearchedUserRecord =
                      controllerSearch.userSearchedList[index];

                  return Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      child: GestureDetector(
                        onTap: () {
                          Get.to(ProfileScreen(
                              visitUserID:
                                  eachSearchedUserRecord.uid.toString()));
                        },
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(10),
                          leading: CircleAvatar(
                            radius: 25,
                            backgroundImage: NetworkImage(
                              eachSearchedUserRecord.image.toString(),
                            ),
                          ),
                          title: Text(
                            eachSearchedUserRecord.name.toString(),
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          subtitle: Text(
                            eachSearchedUserRecord.email.toString(),
                            style: const TextStyle(
                              color: Colors.white60,
                              fontSize: 14,
                            ),
                          ),
                          trailing: IconButton(
                            onPressed: () {
                              Get.to(ProfileScreen(
                                  visitUserID:
                                      eachSearchedUserRecord.uid.toString()));
                            },
                            icon: Icon(
                              Icons.navigate_next,
                              color: Colors.redAccent,
                              size: 30,
                            ),
                          ),
                        ),
                      ));
                },
              );
      }),
    );
  }
}

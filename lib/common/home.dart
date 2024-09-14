import 'package:flutter/material.dart';
import 'package:tiktokclone/common/following/following_video_screen.dart';
import 'package:tiktokclone/common/for_you/for_you_video.dart';
import 'package:tiktokclone/common/profile/profile_screen.dart';
import 'package:tiktokclone/common/search/search_screen.dart';
import 'package:tiktokclone/common/upload_video/upload_custom_icon.dart';
import 'package:tiktokclone/common/upload_video/upload_video_screen.dart';
import 'package:tiktokclone/fancy/global.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int screenIndex = 0;
  final List<Widget> screensList = [
    ForYouVideoScreen(),
    SearchScreen(),
    UploadVideoScreen(),
    FollowingVideoScreen(),
    ProfileScreen(visitUserID: currentUserID,)
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,  // Ensure the body extends under the BottomNavigationBar
      bottomNavigationBar: Theme(
        data: Theme.of(context).copyWith(
          bottomNavigationBarTheme: const BottomNavigationBarThemeData(
            elevation: 0.0,  // Removes the shadow
            backgroundColor: Colors.black,  // Ensures consistent background
          ),
        ),
        child: BottomNavigationBar(
          elevation: 0.0,  // Directly removes the shadow
          onTap: (index) {
            setState(() {
              screenIndex = index;
            });
          },
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.black,  // Ensure background matches theme
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.white12,
          currentIndex: screenIndex,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(
                Icons.home,
                size: 30,
              ),
              label: "Home",
            ),
            BottomNavigationBarItem(
              icon: Icon(
                Icons.search,
                size: 30,
              ),
              label: "Discover",
            ),
            BottomNavigationBarItem(
              icon: UploadCustonIcon(),
              label: "",
            ),
            BottomNavigationBarItem(
              icon: Icon(
                Icons.inbox_sharp,
                size: 30,
              ),
              label: "Following",
            ),
            BottomNavigationBarItem(
              icon: Icon(
                Icons.person,
                size: 30,
              ),
              label: "Me",
            ),
          ],
        ),
      ),
      body: screensList[screenIndex],
    );
  }
}


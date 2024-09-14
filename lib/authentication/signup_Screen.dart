import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:simple_circular_progress_bar/simple_circular_progress_bar.dart';
import 'package:tiktokclone/authentication/controller/auth_controller.dart';
import 'package:tiktokclone/authentication/loginscreen.dart';

import '../fancy/global.dart';
import '../widgets/input_text_widget.dart';

class SignupScreen extends StatefulWidget {
  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  TextEditingController usernameTextEditingController = TextEditingController();
  TextEditingController emailTextEditingController = TextEditingController();
  TextEditingController passwordTextEditingController = TextEditingController();
  var authenticationController = AuthenticationController.instanceAuth;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              const SizedBox(
                height: 85,
              ),

              Text(
                "Create Account",
                style: GoogleFonts.acme(
                    fontSize: 34,
                    color: Colors.grey,
                    fontWeight: FontWeight.bold),
              ),
              Text(
                "to get Started!",
                style: GoogleFonts.acme(
                  fontSize: 34,
                  color: Colors.grey,
                ),
              ),

              const SizedBox(
                height: 30,
              ),

              // Profile avatar
              GestureDetector(
                onTap: () {
                  // Allow user to choose image
                  authenticationController.chooseImageFromGallery();
                },
                child: const CircleAvatar(
                  radius: 80,
                  backgroundImage:
                      AssetImage("assets/images/profile/profile_avatar.jpg"),
                ),
              ),
              SizedBox(height: 30),

              /// username input

              /// email input
              Container(
                width: MediaQuery.of(context).size.width,
                margin: EdgeInsets.symmetric(horizontal: 20),
                child: InputTextWidget(
                  textEditingController: usernameTextEditingController,
                  lableString: "Username",
                  iconData: Icons.person_outline,
                  isObscure: false,
                ),
              ),

              SizedBox(
                height: 20,
              ),

              Container(
                width: MediaQuery.of(context).size.width,
                margin: EdgeInsets.symmetric(horizontal: 20),
                child: InputTextWidget(
                  textEditingController: emailTextEditingController,
                  lableString: "Email",
                  iconData: Icons.email_outlined,
                  isObscure: false,
                ),
              ),

              SizedBox(
                height: 20,
              ),

              ///Password input
              Container(
                width: MediaQuery.of(context).size.width,
                margin: EdgeInsets.symmetric(horizontal: 20),
                child: InputTextWidget(
                  textEditingController: passwordTextEditingController,
                  lableString: "Password",
                  iconData: Icons.lock_outline,
                  isObscure: true,
                ),
              ),

              SizedBox(height: 30),

              /// Login button
              showProgressBar == false
                  ? Column(
                      children: [
                        // login button
                        Container(
                          width: MediaQuery.of(context).size.width - 30,
                          height: 54,
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10))),
                          child: InkWell(
                            onTap: () {

                              if (authenticationController
                                          .profileImage !=
                                      null &&
                                  usernameTextEditingController
                                      .text.isNotEmpty &&
                                  emailTextEditingController.text.isNotEmpty &&
                                  passwordTextEditingController.text.isNotEmpty)
                              {
                                setState(() {
                                  showProgressBar = true;
                                });
                                //Create a new account for user
                                authenticationController
                                    .createAccountForNewUser(
                                    authenticationController.profileImage!,
                                    usernameTextEditingController.text,
                                    emailTextEditingController.text,
                                    passwordTextEditingController.text);
                              } },
                            child: Center(
                              child: Text(
                                "Sign Up",
                                style: TextStyle(
                                  fontSize: 20,
                                  color: Colors.black,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                        ),

                        // Don't have an account, signup button
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Already have an Account? ",
                              style:
                                  TextStyle(fontSize: 16, color: Colors.grey),
                            ),
                            SizedBox(
                              height: 30,
                            ),
                            InkWell(
                              onTap: () {
                                Get.to(LoginScreen());

                                /// Send user to signup screen
                              },
                              child: const Text(
                                "Sign In",
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            )
                          ],
                        )
                      ],
                    )
                  : Container(
                      // SHOW ANIMATION
                      child: const SimpleCircularProgressBar(
                        progressColors: [
                          Colors.green,
                          Colors.blueAccent,
                          Colors.red,
                          Colors.amber,
                          Colors.purpleAccent,
                        ],
                        animationDuration: 3,
                        backColor: Colors.white38,
                      ),
                    )
            ],
          ),
        ),
      ),
    );
  }
}

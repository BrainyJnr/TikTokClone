import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:simple_circular_progress_bar/simple_circular_progress_bar.dart';
import 'package:tiktokclone/authentication/signup_Screen.dart';
import 'package:tiktokclone/widgets/input_text_widget.dart';

import 'controller/auth_controller.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  TextEditingController emailTextEditingController = TextEditingController();
  TextEditingController passwordTextEditingController = TextEditingController();
  bool showProgressBar = false;
  var authenticationController = AuthenticationController.instanceAuth;


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              const SizedBox(
                height: 100,
              ),
              Image.asset(
                "assets/images/logo/tiktok.png",
                width: 180,
              ),
              Text(
                "Welcome",
                style: GoogleFonts.acme(
                    fontSize: 34,
                    color: Colors.grey,
                    fontWeight: FontWeight.bold),
              ),
              Text(
                "Glad to see you!",
                style: GoogleFonts.acme(
                  fontSize: 34,
                  color: Colors.grey,
                ),
              ),

              const SizedBox(
                height: 30,
              ),

              /// email input
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
              showProgressBar == false ?
              Column(
                children: [

                  // login button
                  Container(
                    width: MediaQuery.of(context).size.width - 30,
                    height: 54,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.all(Radius.circular(10))
                    ),
                    child: InkWell(
                      onTap: () {

                        // login user
                        if(emailTextEditingController.text.isNotEmpty &&
                         passwordTextEditingController.text.isNotEmpty
                        )
                        setState(() {
                          showProgressBar = true;
                        });

                          authenticationController.loginUser(
                            emailTextEditingController.text,
                              passwordTextEditingController.text,
                          );


                        },
                      child: Center(
                        child: Text(
                          "Login",
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
                      Text("Don't have an Account? ",
                       style: TextStyle(
                         fontSize: 16,
                         color: Colors.grey
                       ),
                      ),
                      SizedBox(height: 30,),
                      InkWell(
                        onTap: () { Get.to(SignupScreen());
                          /// Send user to signup screen

                        },
                          child: const Text("Sign Up",
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
              ) : Container(
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

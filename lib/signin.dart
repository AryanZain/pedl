
import 'package:flutter/material.dart';
import 'package:pedl/forgotpassword.dart';
import 'package:pedl/home.dart';

import 'package:pedl/services/auth.dart';
import 'package:pedl/signup.dart';
import 'package:pedl/widget/message.dart';
import 'package:pedl/widget/textfeild.dart';
import 'package:pedl/widget/button.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SigninScreen extends StatefulWidget {
  const SigninScreen({super.key});

  @override
  State<SigninScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SigninScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  bool isLoading = false;
  bool rememberMe = false;

  @override
  void initState() {
    super.initState();
    _loadRememberMeData();
  }

  @override
  void dispose() {
    super.dispose();
    emailController.dispose();
    passwordController.dispose();
  }

  // Load email and password from SharedPreferences
  Future<void> _loadRememberMeData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      rememberMe = prefs.getBool('rememberMe') ?? false;
      if (rememberMe) {
        emailController.text = prefs.getString('email') ?? '';
        passwordController.text = prefs.getString('password') ?? '';
      }
    });
  }

  // Save email and password to SharedPreferences
  Future<void> _saveRememberMeData() async {
    final prefs = await SharedPreferences.getInstance();
    if (rememberMe) {
      await prefs.setBool('rememberMe', true);
      await prefs.setString('email', emailController.text);
      await prefs.setString('password', passwordController.text);
    } else {
      await prefs.remove('rememberMe');
      await prefs.remove('email');
      await prefs.remove('password');
    }
  }





  //Sign In Function
  void signinUsers() async{
    String res = await AuthServices().signinUser(
      email: emailController.text,
      password: passwordController.text,
    );
    if (res == "success") {
      setState(() {
        isLoading = true;
      });
      //navigate to the next screen
      try {
        await _saveRememberMeData();
        // Fetch the user's name from Firestore
        User? user = _auth.currentUser;
        if (user != null) {
          String userEmail = user.email!;
          DocumentSnapshot userDoc = await _firestore.collection('users').doc(user.uid).get();
          String userName = userDoc['name'];
          String userId = user.uid; // Fetch the userId (UID)

          // Navigate to the HomeScreen with the user's name
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => HomeScreen(userName: userName, userId: userId,userEmail: userEmail,),
            ),
          );
        }
      } catch (e) {
        showSnackBar(context, "Failed to fetch user data: $e");
        setState(() {
          isLoading = false;
        });
      }
      /*Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => const HomeScreen(),
        ),
      );*/
    } else {
      setState(() {
        isLoading = false;
      });
      // show error
      showSnackBar(context, res);
    }
  }



  @override
  Widget build(BuildContext context) {

    double height = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
          child: SizedBox(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              //LOGO
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 50),
                child: SizedBox(
                  width: double.infinity,
                  height: height / 5,
                  child: Image.asset("assets/images/logo.png"),
                ),
              ),
          
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 25),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Sign in",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 36,
                        color: Colors.black),
                  ),
                ),
              ),
          
              TextFeildInput(
                  icon: Icons.email_outlined,
                  textEditingController: emailController,
                  hintText: 'abc@email.com',
                  textInputType: TextInputType.text),
              TextFeildInput(
                icon: Icons.lock_outlined,
                textEditingController: passwordController,
                hintText: 'Your password',
                textInputType: TextInputType.text,
                isPass: true,
              ),
              //REMEMBER ME Section
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Switch(
                          value: rememberMe,
                          onChanged: (bool value) {
                            setState(() {
                              rememberMe = value;
                            });
                          },
                          activeColor: Color(0xffdf453e),
                        ),
                        const SizedBox(
                            width: 8), // Space between Switch and "Remember Me"
                        Text(
                          "Remember Me",
                          style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w400),
                        ),
                      ],
                    ),
                    InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const ForgotPasswordScreen(),
                          ),
                        );
                      },
                      child: Text(
                        "Forgot Password?",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.black54,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          
               // ADDHERE==-=-=-=-=-=-=-=-=-=-=-=-=-=-
              MyButtons(onTap: signinUsers  , text: "SIGN IN"),
              SizedBox(height: height / 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Don't have an account?",
                    style: TextStyle(fontSize: 16),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const SignUpScreen(),
                          ),
                        );
                      },
                      child: const Text(
                        "Sign up",
                        style: TextStyle(
                          color: Color(0xffdf453e),
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  )
                ],
              )
            ],
          ),
        ),
      )),
    );
  }
}

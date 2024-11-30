import 'package:flutter/material.dart';
import 'package:pedl/services/auth.dart';
import 'package:pedl/widget/button.dart';
import 'package:pedl/widget/message.dart';
import 'package:pedl/widget/textfeild.dart';
import 'package:pedl/signin.dart';
import 'package:pedl/services/auth.dart';



class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  bool isLoading = false;

  @override
  void dispose() {
    super.dispose();
    emailController.dispose();
    passwordController.dispose();
    nameController.dispose();
  }

void signupUser() async{
  String res = await AuthServices().signupUser(name: nameController.text,
      email: emailController.text,
      password: passwordController.text,
      confirmpassword: passwordController.text,
  );
  if (res == "success") {
    setState(() {
      isLoading = true;
    });
    //navigate to the next screen
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => const SigninScreen(),
      ),
    );
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
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 40),
                    child: SizedBox(
                      width: double.infinity,
                      height: height / 8,
                      child: Image.asset("assets/images/logo.png"),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 25),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Sign up",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 36,
                            color: Colors.black),
                      ),
                    ),
                  ),
                  TextFeildInput(
                      icon: Icons.person_outlined,
                      textEditingController: nameController,
                      hintText: 'Full name',
                      textInputType: TextInputType.text),
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
                  TextFeildInput(
                    icon: Icons.lock_outlined,
                    textEditingController: passwordController,
                    hintText: 'Confirm password',
                    textInputType: TextInputType.text,
                    isPass: true,
                  ),
              
              
              
                  MyButtons(onTap: signupUser, text: "SIGN UP"),
                  SizedBox(height: height / 9),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Already have an account?",
                        style: TextStyle(fontSize: 16),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        child: GestureDetector(
                          onTap: () {
                            Navigator.of(
                              context).push(
                              MaterialPageRoute(builder: (context) => const SigninScreen(),
                              ),
                            );
                          },
                          child: const Text(
                            "Sign in",
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

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pedl/services/auth.dart';
import 'package:pedl/signin.dart';
import 'package:pedl/widget/message.dart';
import 'package:pedl/widget/textfeild.dart';
import 'package:pedl/widget/utils.dart';

import 'Widget/button.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final emailController = TextEditingController();
  final auth = FirebaseAuth.instance;
  @override
  /*Future<void> forgotpass(String email) async{
    try{
      await auth.sendPasswordResetEmail(email: email);
    }catch (e) {
      showSnackBar(context, "Failed to send Email: $e");
    }
  }*/
  void forgotpass() async{
    try{
      await auth.sendPasswordResetEmail(email: emailController.text.toString());
    }catch (e) {
      showSnackBar(context, "Failed to send Email: $e");
    }
  }
  /*void forgotpass(){
    final utils = Utils(); // Instantiate Utils
    auth.sendPasswordResetEmail(email: emailController.text.toString()).then((value){
      Utils().toastMessage('We have sent email to recover password, Please check your mail');
    }).onError((error, stackTrace){
      Utils().toastMessage(error.toString());
    });
  }*/


  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () async {
            await AuthServices().signOut();
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => SigninScreen(),

                //builder: (context) => const HomeScreen(),
              ),
            );
          },
        ),
        title: const Text('Reset Password', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
      ),

      body: SafeArea(
          child: SizedBox(
            //child: SingleChildScrollView(
              //child: Padding(
                //padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  //mainAxisAlignment: MainAxisAlignment.center,
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
                          "Reset Password",
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
                    SizedBox(height: 40,),
                    MyButtons(text: "Send Email", onTap: forgotpass),
                  ],
                ),
              //),
            //),
          )),
    );
  }
}

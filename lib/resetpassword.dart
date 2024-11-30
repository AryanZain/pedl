import 'package:flutter/material.dart';
import 'package:pedl/widget/textfeild.dart';

import 'Widget/button.dart';


class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordState();
}

class _ResetPasswordState extends State<ResetPasswordScreen> {
  final TextEditingController emailController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
          child: SizedBox(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
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



                MyButtons(onTap: (){}  , text: "SIGN IN"),
                              ],
            ),
          )),
    );
  }
}

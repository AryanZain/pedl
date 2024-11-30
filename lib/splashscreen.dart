import 'dart:async';

import 'package:flutter/material.dart';
import 'package:pedl/signin.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(Duration(seconds: 3), () {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => SigninScreen())
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
      body: Container(
          color: Colors.white,
          child: Center(
            child: SizedBox(
              width: double.infinity,
              height: height / 5,
              child: Image.asset("assets/images/logo.png"),
            ),
          )),
    );
  }
}

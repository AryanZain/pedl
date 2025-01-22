import 'package:pedl/checkout.dart';
import 'package:flutter/material.dart';
import 'package:pedl/services/auth.dart';

import 'bike.dart';
import 'calender.dart';


class termsandcondition extends StatelessWidget {
  final String userId;
  final String userName;
  final Map<String, dynamic> bikeData;
  const termsandcondition({required this.userId,required this.userName,required this.bikeData,  Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: TermsAndConditionsPage(userId: userId, userName: userName,bikeData: bikeData,), // Pass userId
    );
  }
}

class TermsAndConditionsPage extends StatefulWidget {
  final String userId;
  final String userName;
  final Map<String, dynamic> bikeData;
  const TermsAndConditionsPage({required this.userId, required this.userName,required this.bikeData, Key? key}) : super(key: key);

  @override
  _TermsAndConditionsPageState createState() => _TermsAndConditionsPageState();
}

class _TermsAndConditionsPageState extends State<TermsAndConditionsPage> {
  bool isChecked = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () async {
            // Handle back navigation
            await AuthServices().signOut();
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => BikeDetailsApp(userId: widget.userId, userName: widget.userName,
                  bikeData: widget.bikeData,
                ),
              ),
            );
          },
        ),
        title: const Text(
          'Terms and Conditions',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Terms and Conditions Pedl',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Lorem ipsum dolor sit amet, consectetur adipiscing elit. '
                          'Cras ac justo ac orci sagittis tincidunt euismod eu sem. '
                          'Morbi hendrerit suscipit commodo. In iaculis justo nibh. Nulla facilisi. '
                          'Etiam fermentum porttitor tortor. Etiam ut commodo magna, ac varius enim. '
                          'In hac habitasse platea dictumst. Fusce turpis nisi. Nunc mollis, lorem nec '
                          'ultricida mi, sed commodo massa facilisis at. Etiam sollicitudin enim mi, nec '
                          'tristique tellus ultrices ut. Cras vel massa faucibus, pharetra odio ac, '
                          'lobortis nisl. Aenean cursus eget metus vel dignissim. Nulla id ultrices est. '
                          'Suspendisse lobortis ultrices lectus, a lacinia orci. Aliquam temp.',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade800,
                        height: 1.6,

                      ),
                      textAlign: TextAlign.justify,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Checkbox(
                  value: isChecked,
                  onChanged: (value) {
                    setState(() {
                      isChecked = value ?? false;
                    });
                  },
                  activeColor: Colors.red,
                ),
                const Text(
                  'Agree to the terms and Conditions',
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: 250,
              child: ElevatedButton(
                onPressed: isChecked
                    ? () async {
                  await AuthServices().signOut();
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (context) => Calendar_Page(bikeData: widget.bikeData,),
                    ),
                  );
                }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: isChecked ? Colors.red : Colors.grey.shade300,
                  disabledBackgroundColor: Colors.grey.shade300,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text(
                  'CONTINUE TO CHECKOUT',
                  style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
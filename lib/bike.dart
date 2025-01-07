import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:pedl/calender.dart';
import 'package:pedl/services/auth.dart';
import 'package:pedl/termsandcondition.dart';

import 'home.dart';

class BikeDetailsApp extends StatelessWidget {
  const BikeDetailsApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(fontFamily: 'Roboto'),
      home: const BikeDetailsPage(),
    );
  }
}

class BikeDetailsPage extends StatelessWidget {
  const BikeDetailsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
                builder: (context) => const HomeScreen(),
              ),
            );
          },
        ),
        title: const Text('Bike Details', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(CupertinoIcons.bookmark, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Bike Image
            Center(
                child: Image.asset("assets/images/bike.png", fit: BoxFit.cover),
            ),

            const SizedBox(height: 20),

            // Title and Price
            const Text(
              'E-MONO 26\"\nSE-26L03',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 5),
            const Text(
              'From \$49 per week',
              style: TextStyle(
                fontSize: 16,
                color: Colors.red,
              ),
            ),

            const SizedBox(height: 20),

            // Booking Details
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Icon(Icons.calendar_today, color: Colors.red),
                  Text(
                    '  2 Oct 2024 - 5 Oct 2024\n  Pickup: 10AM - Dropoff: 4PM',
                    style: TextStyle(color: Colors.black),
                  ),

                ],
              ),
            ),

            const SizedBox(height: 20),

            // Icons Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _iconInfo(Icons.speed, '50KM/H'),
                _iconInfo(Icons.bolt, '48V 750W'),
                _iconInfo(Icons.route, '90KM'),

              ],
            ),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [

                _iconInfo(Icons.battery_full, '17AH'),
                _iconInfo(Icons.fitness_center, '140KG'),
                _iconInfo(Icons.monitor_weight, '25KG'),
              ],
            ),

            const SizedBox(height: 30),

            // Specifications
            const Text(
              'Specification',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'FRAME: Super Light Step-Through Aluminium-Alloy Frame\n'
                  'FRONT FORK: 40mm Suspension\n'
                  'GEARS: Shimano Tourney 7-Speed Cassette with Shifter\n'
                  'BRAKES: Front & Rear Disc Brakes 180/160MM\n'
                  'Handle Bar: 66cm Aluminium-Alloy Bar\n'
                  'Wheel Quick Release Design\n'
                  'Thumb Accelerator Control',
              style: TextStyle(
                fontSize: 14,
                color: Colors.black,
                height: 1.5,
              ),
            ),

            const SizedBox(height: 30),

            // Book Now Button
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () async {
                  await AuthServices().signOut();
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (context) => const termsandcondition(),
                    ),
                  );
                },
                child: const Text(
                  'BOOK NOW',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _iconInfo(IconData icon, String label) {
    return Column(
      children: [
        Icon(icon, color: Colors.black, size: 30),
        const SizedBox(height: 5),
        Text(
          label,
          style: const TextStyle(color: Colors.black, fontSize: 12),
        ),
      ],
    );
  }
}

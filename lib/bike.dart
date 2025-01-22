import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:pedl/services/auth.dart';
import 'package:pedl/termsandcondition.dart';
import 'package:pedl/home.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert'; // For JSON encoding/decoding

//List<Map<String, dynamic>> bookmarks = []; // Global list for bookmarks

class BikeDetailsApp extends StatelessWidget {
  //final String userName;
  //const BikeDetailsApp({required this.userName, Key? key}) : super(key: key);
  //const BikeDetailsApp({Key? key}) : super(key: key);
  final Map<String, dynamic> bikeData;
  final String userId;
  final String userName;



  const BikeDetailsApp({
    required this.bikeData,
    required this.userId,
    required this.userName,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(fontFamily: 'Roboto'),
      home: BikeDetailsPage(bikeData: bikeData, userId: userId,userName: userName, ),
    );
  }
}

class BikeDetailsPage extends StatefulWidget {
  //const BikeDetailsPage({Key? key}) : super(key: key);
  final Map<String, dynamic> bikeData;
  final String userId;
  final String userName;

  const BikeDetailsPage({
    required this.bikeData,
    required this.userId,
    required this.userName,
    Key? key,
  }) : super(key: key);

  @override
  _BikeDetailsPageState createState() => _BikeDetailsPageState();
}

class _BikeDetailsPageState extends State<BikeDetailsPage> {
  late SharedPreferences _prefs;
  List<Map<String, dynamic>> _bookmarks = [];
  bool isBookmarked = false;

  @override
  void initState() {
    super.initState();
    // Check if bike is already bookmarked
    _loadBookmarks();
  }

  /// Load bookmarks for the current user
  Future<void> _loadBookmarks() async {
    _prefs = await SharedPreferences.getInstance();
    String? bookmarksString = _prefs.getString('bookmarks_${widget.userId}');
    if (bookmarksString != null) {
      setState(() {
        _bookmarks = List<Map<String, dynamic>>.from(
          json.decode(bookmarksString),
        );
        isBookmarked = _bookmarks.any((bike) => bike['title'] == widget.bikeData['title']);
      });
    }
  }

  // Save bookmarks for the current user
  Future<void> _saveBookmarks() async {
    await _prefs.setString('bookmarks_${widget.userId}', json.encode(_bookmarks));
  }

  // Toggle bookmark
  void _toggleBookmark() {
    setState(() {
      if (isBookmarked) {
        _bookmarks.removeWhere((bike) => bike['title'] == widget.bikeData['title']);
      } else {
        _bookmarks.add(widget.bikeData);
      }
      isBookmarked = !isBookmarked;
      _saveBookmarks();
    });
  }


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
                builder: (context) => HomeScreen(userName:  widget.userName,userId: widget.userId,userEmail: "abcd@gmail.com", ),
              ),
            );
          },
        ),
        title: const Text('Bike Details', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: Icon(
              isBookmarked ? CupertinoIcons.bookmark_solid : CupertinoIcons.bookmark,
              color: Colors.black,
            ),
            onPressed: _toggleBookmark,
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
              child: Image.asset(widget.bikeData['image'], fit: BoxFit.cover),
            ),

            const SizedBox(height: 20),

            // Title and Price
            Text(
              widget.bikeData['title'],
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              widget.bikeData['subtitle'],
              style: const TextStyle(
                fontSize: 16,
                color: Colors.red,
              ),
            ),

            const SizedBox(height: 20),

            // Booking Details
            /* Container(
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

            const SizedBox(height: 20),*/

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
              'Specifications',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 10),
            ...widget.bikeData['specifications'].map<Widget>((spec) => Text(
              spec,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black,
                height: 1.5,
              ),
            )),

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
                      builder: (context) => termsandcondition(userId: widget.userId, userName: widget.userName, bikeData: widget.bikeData,),
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

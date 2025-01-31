// Updated home.dart file
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pedl/profile.dart';
import 'package:pedl/services/auth.dart';
import 'package:pedl/services/local_storage_manager.dart';
import 'package:pedl/signin.dart';
import 'package:pedl/bike.dart';
import 'package:pedl/calendar2_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'bike_list_page.dart';
import 'book_service_page.dart';
import 'booked_bikes_page.dart';
import 'bookmark.dart';
import 'contact_us_page.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

import 'notification_page.dart';

class HomeScreen extends StatelessWidget {
  final String userName;
  final String userId;
  final String userEmail;
  const HomeScreen(
      {required this.userName,
      required this.userId,
      required this.userEmail,
      Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bookedBikes = [];
    return Scaffold(
      appBar: _CustomAppBar(
        userId: userId,
      ),
      drawer: _SideMenu(
        userName: userName,
        userId: userId,
      ),
      body: _HomeContent(
          userName: userName,
          userId: userId,
          userEmail: userEmail), // Pass userId to _HomeContent
      bottomNavigationBar: _CustomBottomNavigationBar(
        userId: userId,
        userName: userName,
        bookedBikes: [],
      ), // Pass userId
      floatingActionButton: _CenteredFAB(userId: userId, userName: userName, userEmail: userEmail,),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}

/*class _CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  @override
  Widget build(BuildContext context) {
    return AppBar(
      toolbarHeight: 100,
      backgroundColor: Colors.redAccent,
      elevation: 0,
      title: Padding(
        padding: const EdgeInsets.only(top: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Current Location",
                style: TextStyle(fontSize: 14, color: Colors.white)),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Redfern, NSW",
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
                IconButton(
                  icon: Icon(Icons.notifications, color: Colors.white),
                  onPressed: () {
                    print("Notifications clicked");
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(100);
}*/
//=====================================================================
class _CustomAppBar extends StatefulWidget implements PreferredSizeWidget {
  final String userId;
  const _CustomAppBar({required this.userId, Key? key}) : super(key: key);

  @override
  _CustomAppBarState createState() => _CustomAppBarState();

  @override
  Size get preferredSize => const Size.fromHeight(100);
}

class _CustomAppBarState extends State<_CustomAppBar> {
  String _location = "Fetching location...";
  int _unreadCount = 0;

  @override
  void initState() {
    super.initState();
    _fetchLocation();
    _loadUnreadCount();
  }

  Future<void> _loadUnreadCount() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _unreadCount = prefs.getInt('unread_${widget.userId}') ?? 0;
    });
  }

  Future<int> _getUnreadCount() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('unread_${widget.userId}') ?? 0;
  }

  void _resetUnreadCount() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('unread_${widget.userId}', 0);
    setState(() {
      _unreadCount = 0; // Reset the unread count
    });
  }

  Future<void> _fetchLocation() async {
    try {
      LocationPermission permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        setState(() {
          _location = "Location permissions denied";
        });
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);

      // Debug: Print fetched latitude and longitude
      print("Latitude: ${position.latitude}, Longitude: ${position.longitude}");

      // Reverse geocode to get the address
      List<Placemark> placemarks =
          await placemarkFromCoordinates(position.latitude, position.longitude);

      // Use the first placemark to extract the location details
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        setState(() {
          _location =
              "${place.locality}, ${place.administrativeArea}, ${place.country}";
        });
      } else {
        setState(() {
          _location = "No location details available";
        });
      }
    } catch (e) {
      setState(() {
        _location = "Error: $e"; // Display the error for debugging
        print("Error: $e");
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      toolbarHeight: 100,
      backgroundColor: Colors.redAccent,
      elevation: 0,
      title: Padding(
        padding: const EdgeInsets.only(top: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Current Location",
                style: TextStyle(fontSize: 14, color: Colors.white)),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    _location,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    overflow: TextOverflow.ellipsis, // Prevent overflow
                  ),
                ),
                IconButton(
                  icon: Badge(
                    label: _unreadCount > 0
                        ? Text(
                            '$_unreadCount',
                            style: const TextStyle(color: Colors.white),
                          )
                        : null, // Hide badge if no unread notifications
                    child: const Icon(Icons.notifications, color: Colors.white),
                  ),
                  onPressed: () {
                    _resetUnreadCount(); // Reset unread count when notifications are opened
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            NotificationPage(userId: widget.userId),
                      ),
                    ).then((_) {
                      // Refresh the unread count after returning from the notification page
                      _loadUnreadCount();
                    });
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SideMenu extends StatefulWidget {
  final String userName;
  final String userId;

  const _SideMenu({required this.userName, required this.userId, Key? key})
      : super(key: key);

  @override
  _SideMenuState createState() => _SideMenuState();
}

class _SideMenuState extends State<_SideMenu> {
  String? profilePicturePath;
  final LocalStorageManager _storage = LocalStorageManager();

  @override
  void initState() {
    super.initState();
    _loadProfilePicture();
  }

  // Load saved profile picture from local storage
  Future<void> _loadProfilePicture() async {
    final data = await _storage.loadUserData();
    setState(() {
      profilePicturePath = data['profileImage'];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            accountName: Text(widget.userName,
                style: const TextStyle(fontSize: 24, color: Colors.black)),
            accountEmail: null,
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.grey.shade800,
              backgroundImage: profilePicturePath != null
                  ? FileImage(File(profilePicturePath!))
                  : null,
              child: profilePicturePath == null
                  ? const Icon(Icons.person, size: 50, color: Colors.white)
                  : null,
            ),
            decoration: const BoxDecoration(color: Colors.white),
          ),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text("My Profile"),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProfilePage(
                    userName: widget.userName,
                    /*aboutMe: "Enter Your Description",
                    interests: ["Games Online", "Music"],*/
                  ),
                ),
              ).then((_) =>
                  _loadProfilePicture()); // Reload profile picture after returning
            },
          ),
          ListTile(
            leading: const Icon(Icons.notifications),
            title: const Text("Notification"),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => NotificationPage(userId: widget.userId),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.calendar_today),
            title: const Text("Calendar"),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CalendarPage(),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.contact_support),
            title: const Text("Contact Us"),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ContactUsPage()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text("Sign Out"),
            onTap: () async {
              await AuthServices().signOut();
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => const SigninScreen()),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _HomeContent extends StatelessWidget {
  final String userName;
  final String userId;
  final String userEmail;
  const _HomeContent(
      {required this.userName,
      required this.userId,
      required this.userEmail,
      Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView(
      //padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      children: [
        SizedBox(height: 20),
        _SearchAndCategories(
          userName: userName,
          userId: userId,
          userEmail: userEmail,
        ),
        SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 0),
          child: AspectRatio(
            aspectRatio: 16 / 9, // Responsive aspect ratio for the image
            child: ClipRRect(
              borderRadius: BorderRadius.circular(0), // Rounded corners
              child: Image.asset(
                'assets/images/cover_image.webp', // Replace with your image path
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
        SizedBox(height: 20),
        _YouMayLikeSection(
          userId: userId,
          userName: userName,
          userEmail: userEmail,
        ), // Pass userId
        SizedBox(height: 40),
        _CurrentTripSection(userEmail: userEmail),
        //SizedBox(height: 20),
        //_NearbySection(),

        //_YouMayLikeSection(),
      ],
    );
  }
}

//*** CHANGES FOR SEARCH BAR ***
class _SearchAndCategories extends StatefulWidget {
  final String userName;
  final String userId;
  final String userEmail;

  const _SearchAndCategories(
      {required this.userName,
      required this.userId,
      required this.userEmail,
      Key? key})
      : super(key: key);
  @override
  _SearchAndCategoriesState createState() => _SearchAndCategoriesState();
}

class _SearchAndCategoriesState extends State<_SearchAndCategories> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode =
      FocusNode(); // Add FocusNode for the search bar
  List<Map<String, dynamic>> filteredBikes = [];
  bool _isSearchActive = false;
  final List<Map<String, dynamic>> allBikes = [
    {
      'title': 'E-MONO 26″ SE-26L03',
      'subtitle': 'From \$65 per week',
      'image': 'assets/images/bike1.png',
      'specifications': [
        'FRAME: Lightweight Aluminum',
        'SUSPENSION: 40mm Fork',
        'BRAKES: Disc Brakes 160mm'
      ],
    },
    {
      'title': 'E-MONO 27.5″ 27M002',
      'subtitle': 'From \$75 per week',
      'image': 'assets/images/bike2.png',
      'specifications': [
        'FRAME: Steel',
        'WHEELS: 26-inch',
        'BRAKES: V-Brakes',
      ],
    },
    {
      'title': 'E-mono’s Folding Bike',
      'subtitle': 'From \$89 per week',
      'image': 'assets/images/bike3.png',
      'specifications': [
        'FRAME: Steel',
        'WHEELS: 26-inch',
        'BRAKES: V-Brakes',
      ],
    },
    {
      'title': 'NCM Moscow Electric Mountain Bike',
      'subtitle': 'From \$85 per week',
      'image': 'assets/images/bike4.png',
      'specifications': [
        'FRAME: Steel',
        'WHEELS: 26-inch',
        'BRAKES: V-Brakes',
      ],
    },
    {
      'title': 'E-MONO ELECTRIC URBAN BIKE SE-26L03',
      'subtitle': 'From \$95 per week',
      'image': 'assets/images/bike5.png',
      'specifications': [
        'FRAME: Steel',
        'WHEELS: 26-inch',
        'BRAKES: V-Brakes',
      ],
    },
    {
      'title': 'E-MONO 20 ELECTRIC CARGO BIKE SE-20B01',
      'subtitle': 'From \$100 per week',
      'image': 'assets/images/bike6.png',
      'specifications': [
        'FRAME: Steel',
        'WHEELS: 26-inch',
        'BRAKES: V-Brakes',
      ],
    },
    {
      'title': 'SUNMONO 26 ELECTRIC URBAN BIKE SE-26L002',
      'subtitle': 'From \$85 per week',
      'image': 'assets/images/bike7.png',
      'specifications': [
        'FRAME: Steel',
        'WHEELS: 26-inch',
        'BRAKES: V-Brakes',
      ],
    },
  ];

  @override
  void initState() {
    super.initState();
    filteredBikes = [];

    // Add a listener to track focus changes
    _searchFocusNode.addListener(() {
      setState(() {
        _isSearchActive = _searchFocusNode.hasFocus; // Update the active state
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode
        .dispose(); // Dispose of the FocusNode to avoid memory leaks
    super.dispose();
  }

  void _filterBikes(String query) {
    final lowerCaseQuery = query.toLowerCase();
    setState(() {
      if (lowerCaseQuery.isEmpty) {
        filteredBikes = []; // Reset the list if the query is empty
      } else {
        filteredBikes = allBikes.where((bike) {
          return bike['title'].toLowerCase().contains(lowerCaseQuery);
        }).toList();
      }
    });
  }

  void _dismissKeyboard() {
    _searchFocusNode.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _dismissKeyboard, // Detect taps outside the search bar
      behavior:
          HitTestBehavior.opaque, // Ensure GestureDetector captures all taps
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Search Bar
          Row(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: TextField(
                    controller: _searchController,
                    focusNode: _searchFocusNode, // Attach the FocusNode
                    decoration: InputDecoration(
                      hintText: "Search...",
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    onChanged: _filterBikes,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
          _buildBikeResults(),
        ],
      ),
    );
  }

  Widget _buildBikeResults() {
    // Show "Start typing..." only when the search bar is focused and empty
    if (_isSearchActive && _searchController.text.isEmpty) {
      return Padding(
        padding: const EdgeInsets.only(top: 20),
        child: Text(
          'Start typing to search for bikes', // Show message when search is active
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    // Show "No results found" if no bikes match the search query
    if (filteredBikes.isEmpty && _searchController.text.isNotEmpty) {
      return Padding(
        padding: const EdgeInsets.only(top: 20),
        child: Text(
          'No results found', // Show message if no bikes are found
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    // Show filtered bike results
    return Column(
      children: filteredBikes.map((bike) {
        return ListTile(
          leading: Image.asset(bike['image'],
              width: 50, height: 50, fit: BoxFit.cover),
          title: Text(bike['title']),
          subtitle: Text(bike['subtitle']),
          onTap: () {
            _dismissKeyboard(); // Dismiss the keyboard when navigating
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => BikeDetailsApp(
                  bikeData: bike,
                  userName: widget.userName,
                  userId: widget.userId,
                  userEmail: widget.userEmail,
                ),
              ),
            );
          },
        );
      }).toList(),
    );
  }
}

//YOU MAY LIKE SECTION
class _YouMayLikeSection extends StatelessWidget {
  final String userId;
  final String userName;
  final String userEmail;
  _YouMayLikeSection(
      {required this.userId,
      required this.userName,
      required this.userEmail,
      Key? key})
      : super(key: key);

  final List<Map<String, dynamic>> bikes = [
    {
      'title': 'E-MONO 26″ SE-26L03',
      'subtitle': 'From \$65 per week',
      'image': 'assets/images/bike1.png',
      'specifications': [
        'FRAME: Lightweight Aluminum',
        'SUSPENSION: 40mm Fork',
        'BRAKES: Disc Brakes 160mm',
      ],
    },
    {
      'title': 'E-MONO 27.5″ 27M002',
      'subtitle': 'From \$75 per week',
      'image': 'assets/images/bike2.png',
      'specifications': [
        'FRAME: Steel',
        'WHEELS: 26-inch',
        'BRAKES: V-Brakes',
      ],
    },
    {
      'title': 'E-mono’s Folding Bike',
      'subtitle': 'From \$89 per week',
      'image': 'assets/images/bike3.png',
      'specifications': [
        'FRAME: Steel',
        'WHEELS: 26-inch',
        'BRAKES: V-Brakes',
      ],
    },
    {
      'title': 'SUNMONO 26 ELECTRIC URBAN BIKE SE-26L002',
      'subtitle': 'From \$85 per week',
      'image': 'assets/images/bike7.png',
      'specifications': [
        'FRAME: Steel',
        'WHEELS: 26-inch',
        'BRAKES: V-Brakes',
      ],
    },
    {
      'title': 'E-MONO 20 CARGO BIKE',
      'subtitle': 'From \$100 per week',
      'image': 'assets/images/bike6.png',
      'specifications': [
        'FRAME: Steel',
        'WHEELS: 26-inch',
        'BRAKES: V-Brakes',
      ],
    },
    {
      'title': 'E-MONO ELECTRIC URBAN BIKE',
      'subtitle': 'From \$95 per week',
      'image': 'assets/images/bike5.png',
      'specifications': [
        'FRAME: Steel',
        'WHEELS: 26-inch',
        'BRAKES: V-Brakes',
      ],
    },
    {
      'title': 'NCM Moscow Electric Mountain Bike',
      'subtitle': 'From \$85 per week',
      'image': 'assets/images/bike4.png',
      'specifications': [
        'FRAME: Steel',
        'WHEELS: 26-inch',
        'BRAKES: V-Brakes',
      ],
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(
          title: "You May Like",
          onSeeAllPressed: () {
            // Navigate to the Bike List Page when "See All" is pressed
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => BikeListPage(
                  userId: userId,
                  userName: userName,
                  userEmail: userEmail,
                  bikes: bikes,
                ),
              ),
            );
          },
        ),
        SizedBox(height: 10),
        SizedBox(
          height: 200,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: bikes.length,
            itemBuilder: (context, index) {
              final bike = bikes[index];
              return _Card(
                title: bike['title']!,
                subtitle: bike['subtitle']!,
                imagePath: bike['image']!,
                onClick: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => BikeDetailsApp(
                        bikeData: bike,
                        userId: userId,
                        userName: userName,
                        userEmail: userEmail,
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

class _CurrentTripSection extends StatelessWidget {
  final String userEmail;
  const _CurrentTripSection({required this.userEmail, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5.0),
      child: Card(
        color: Colors.lightBlue.shade100,
        child: ListTile(
          leading: Icon(Icons.directions_bike, size: 40, color: Colors.blue),
          title: Text("Service Due?"),
          subtitle: Text("Book One Now"),
          trailing: ElevatedButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => BookServicePage(userEmail: userEmail)),
            ),
            child: Text("BOOK"),
          ),
        ),
      ),
    );
  }
}

/*class _NearbySection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(title: "Nearby You"),
        // Add Nearby content here
      ],
    );
  }
}*/

class _SectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback onSeeAllPressed; // Add a callback for "See All"

  _SectionHeader({required this.title, required this.onSeeAllPressed});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          TextButton(
            onPressed: onSeeAllPressed, // Use the callback here
            child: Text("See All"),
          ),
        ],
      ),
    );
  }
}

class _Card extends StatelessWidget {
  final String title;
  final String subtitle;
  final String imagePath;
  final VoidCallback onClick;

  const _Card({
    required this.title,
    required this.subtitle,
    required this.imagePath,
    required this.onClick,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 150,
      margin: EdgeInsets.only(right: 10),
      child: Card(
        elevation: 3,
        child: InkWell(
          onTap: onClick,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Image.asset(imagePath, fit: BoxFit.cover),
              ),
              Padding(
                padding: EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
                    Text(subtitle, style: TextStyle(color: Colors.grey)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CustomBottomNavigationBar extends StatelessWidget {
  final String userId;
  final String userName;
  final List<Map<String, dynamic>> bookedBikes;

  const _CustomBottomNavigationBar({
    required this.userId,
    required this.userName,
    required this.bookedBikes,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      shape: CircularNotchedRectangle(),
      notchMargin: 8.0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      BookmarkPage(userId: userId), // Pass userId
                ),
              );
            },
            icon: Icon(CupertinoIcons.bookmark, color: Colors.black),
          ),
          IconButton(
            onPressed: () {
              // Navigate to the CalendarPage
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CalendarPage(),
                ),
              );
            },
            icon: Icon(Icons.calendar_today),
          ),
          SizedBox(width: 40), // Space for FAB
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => BookedBikesPage(userId: userId),
                ),
              );
            },
            icon: Icon(Icons.directions_bike),
          ),
          IconButton(
            onPressed: () async {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProfilePage(
                    userName: "$userName",
                    /*aboutMe: "Enter Your Description",
                    interests: ["Games Online", "Music"],*/
                  ),
                ),
              );
            },
            icon: Icon(Icons.person),
          ),
        ],
      ),
    );
  }
}

class _CenteredFAB extends StatelessWidget {
  final String userId;
  final String userName;
  final String userEmail;
  const _CenteredFAB({required this.userId,required this.userName,required this.userEmail, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Replace this with your actual bike data
    final List<Map<String, dynamic>> bikes = [
      {
        'title': 'E-MONO 26″ SE-26L03',
        'subtitle': 'From \$65 per week',
        'image': 'assets/images/bike1.png',
        'specifications': [
          'FRAME: Lightweight Aluminum',
          'SUSPENSION: 40mm Fork',
          'BRAKES: Disc Brakes 160mm',
        ],
      },
      {
        'title': 'E-MONO 27.5″ 27M002',
        'subtitle': 'From \$75 per week',
        'image': 'assets/images/bike2.png',
        'specifications': [
          'FRAME: Steel',
          'WHEELS: 26-inch',
          'BRAKES: V-Brakes',
        ],
      },
      {
        'title': 'E-mono’s Folding Bike',
        'subtitle': 'From \$89 per week',
        'image': 'assets/images/bike3.png',
        'specifications': [
          'FRAME: Steel',
          'WHEELS: 26-inch',
          'BRAKES: V-Brakes',
        ],
      },
      {
        'title': 'SUNMONO 26 ELECTRIC URBAN BIKE SE-26L002',
        'subtitle': 'From \$85 per week',
        'image': 'assets/images/bike7.png',
        'specifications': [
          'FRAME: Steel',
          'WHEELS: 26-inch',
          'BRAKES: V-Brakes',
        ],
      },
      {
        'title': 'E-MONO 20 CARGO BIKE',
        'subtitle': 'From \$100 per week',
        'image': 'assets/images/bike6.png',
        'specifications': [
          'FRAME: Steel',
          'WHEELS: 26-inch',
          'BRAKES: V-Brakes',
        ],
      },
      {
        'title': 'E-MONO ELECTRIC URBAN BIKE',
        'subtitle': 'From \$95 per week',
        'image': 'assets/images/bike5.png',
        'specifications': [
          'FRAME: Steel',
          'WHEELS: 26-inch',
          'BRAKES: V-Brakes',
        ],
      },
      {
        'title': 'NCM Moscow Electric Mountain Bike',
        'subtitle': 'From \$85 per week',
        'image': 'assets/images/bike4.png',
        'specifications': [
          'FRAME: Steel',
          'WHEELS: 26-inch',
          'BRAKES: V-Brakes',
        ],
      },
    ];


    return FloatingActionButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BikeListPage(
              userId: userId,
              userName: userName,
              userEmail: userEmail,
              bikes: bikes,
            ),
          ),
        );
      },
      backgroundColor: Colors.redAccent,
      child: Icon(Icons.add, color: Colors.white),
    );
  }
}

// Updated home.dart file
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pedl/profile.dart';
import 'package:pedl/services/auth.dart';
import 'package:pedl/signin.dart';
import 'package:pedl/bike.dart';

import 'bookmark.dart';

class HomeScreen extends StatelessWidget {
  final String userName;
  final String userId; // Add userId here
  const HomeScreen({required this.userName, required this.userId, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _CustomAppBar(),
      drawer: _SideMenu(userName: userName),
      body: _HomeContent(userId: userId), // Pass userId to _HomeContent
      bottomNavigationBar: _CustomBottomNavigationBar(userId: userId), // Pass userId
      floatingActionButton: _CenteredFAB(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}

class _CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
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
}

class _SideMenu extends StatelessWidget {
  final String userName; //

  const _SideMenu({required this.userName, Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            accountName: Text("$userName", style: TextStyle(fontSize: 24, color: Colors.black)),
            accountEmail: null,
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.grey.shade800,
              child: Text("Z", style: TextStyle(fontSize: 24, color: Colors.white, fontWeight: FontWeight.bold)),
            ),
            decoration: BoxDecoration(
                color: Colors.white
            ),
          ),
          ListTile(
              leading: Icon(Icons.person),
              title: Text("My Profile"),
              onTap: () async{
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProfilePage(
                      userName: "$userName",
                      aboutMe: "Enter Your Description",
                      interests: ["Games Online", "Music"],
                    ),
                  ),
                );
                /*Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => const ProfilePage(),
                ),
              );*/
              }
          ),
          ListTile(
            leading: Icon(Icons.notifications),
            title: Text("Notification"),

            onTap: () => print("Notification clicked"),
          ),
          ListTile(
            leading: Icon(Icons.calendar_today),
            title: Text("Calendar"),
            onTap: () => print("Calendar clicked"),
          ),
          ListTile(
            leading: Icon(Icons.contact_support),
            title: Text("Contact Us"),
            onTap: () => print("Contact Us clicked"),
          ),
          ListTile(
            leading: Icon(Icons.logout),
            title: Text("Sign Out"),
            onTap: () async {
              await AuthServices().signOut();
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => const SigninScreen(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _HomeContent extends StatelessWidget {
  final String userId; // Receive userId
  const _HomeContent({required this.userId, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView(
      //padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      children: [
        SizedBox(height: 20),
        _SearchAndCategories(),
        SizedBox(height: 20),
        _YouMayLikeSection(userId: userId), // Pass userId
        SizedBox(height: 20),
        _CurrentTripSection(),
        SizedBox(height: 20),
        _NearbySection(),

        //_YouMayLikeSection(),
      ],
    );
  }
}

class _SearchAndCategories extends StatelessWidget {
  final categories = ["E-Bike", "E-Scooter", "Accessories"];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Search Bar
        Row(
          children: [
            Expanded(
              child: TextField(
                decoration: InputDecoration(
                  hintText: "Search...",
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ),
            ),
            SizedBox(width: 10),
            ElevatedButton.icon(
              onPressed: () {
                print("Filter clicked");
              },
              icon: Icon(Icons.filter_alt),
              label: Text("Filters"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 20),
        // Category Chips
        Wrap(
          spacing: 10,
          children: categories.map((category) {
            return ActionChip(
              label: Text(category),
              onPressed: () => print("$category clicked"),
              backgroundColor: category == "Accessories"
                  ? Colors.green
                  : Colors.orangeAccent,
              labelStyle: TextStyle(color: Colors.white),
            );
          }).toList(),
        ),
      ],
    );
  }
}
//YOU MAY LIKE SECTION
class _YouMayLikeSection extends StatelessWidget {
  final String userId; // Receive userId
  _YouMayLikeSection({required this.userId, Key? key}) : super(key: key);

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
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(title: "You May Like"),
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
                      builder: (context) => BikeDetailsApp(bikeData: bike, userId: userId), // Pass userId
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
  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.lightBlue.shade100,
      child: ListTile(
        leading: Icon(Icons.directions_bike, size: 40, color: Colors.blue),
        title: Text("Service Due"),
        subtitle: Text("E-MONO SE-26L03"),
        trailing: ElevatedButton(
          onPressed: () => print("Book clicked"),
          child: Text("BOOK"),
        ),
      ),
    );
  }
}

class _NearbySection extends StatelessWidget {
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
}

class _SectionHeader extends StatelessWidget {
  final String title;

  _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        TextButton(
          onPressed: () => print("See All clicked"),
          child: Text("See All"),
        ),
      ],
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
  final String userId; // Receive userId
  const _CustomBottomNavigationBar({required this.userId, Key? key}) : super(key: key);

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
                  builder: (context) => BookmarkPage(userId: userId), // Pass userId
                ),
              );
    },
            icon: Icon(CupertinoIcons.bookmark, color: Colors.black),
          ),
          IconButton(
            onPressed: () => print("Calendar clicked"),
            icon: Icon(Icons.calendar_today),
          ),
          SizedBox(width: 40), // Space for FAB
          IconButton(
            onPressed: () => print("Rent clicked"),
            icon: Icon(Icons.directions_bike),
          ),
          IconButton(
            onPressed: () => print("Profile clicked"),
            icon: Icon(Icons.person),
          ),
        ],
      ),
    );
  }
}

class _CenteredFAB extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () => print("FAB clicked"),
      child: Icon(Icons.add),
      backgroundColor: Colors.redAccent,
    );
  }
}
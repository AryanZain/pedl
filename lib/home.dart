import 'package:flutter/material.dart';
import 'package:pedl/profile.dart';
import 'package:pedl/services/auth.dart';
import 'package:pedl/signin.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _CustomAppBar(),
      drawer: _SideMenu(),
      body: _HomeContent(),
      bottomNavigationBar: _CustomBottomNavigationBar(),
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
  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            accountName: Text("Zain Ul Abideen", style: TextStyle(fontSize: 24, color: Colors.black)),
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
                    userName: "Zain Ul Abideen",
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
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      children: [
        _SearchAndCategories(),
        SizedBox(height: 20),
        _YouMayLikeSection(),
        SizedBox(height: 20),
        _CurrentTripSection(),
        SizedBox(height: 20),
        _NearbySection(),
      ],
    );
  }
}

class _SearchAndCategories extends StatelessWidget {
  final categories = ["E-Bike", "E-Scooter", "Accessories"];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
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

class _YouMayLikeSection extends StatelessWidget {
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
            itemCount: 3,
            itemBuilder: (context, index) {
              return _Card(
                title: "E-MONO 26” SE-26L03",
                subtitle: "From \$49 per week",
                onClick: () => print("E-Bike clicked"),
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
  final VoidCallback onClick;

  _Card({required this.title, required this.subtitle, required this.onClick});

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
                child: Image.asset("assets/images/bike.png", fit: BoxFit.cover),
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
  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      shape: CircularNotchedRectangle(),
      notchMargin: 8.0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          IconButton(
            onPressed: () => print("Explore clicked"),
            icon: Icon(Icons.explore),
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

import 'package:flutter/material.dart';

class ProfilePage extends StatefulWidget {
  final String userName; // Dynamically passed user name
  final String aboutMe; // Dynamically passed aboutMe description
  final List<String> interests; // List of interests

  const ProfilePage({
    Key? key,
    required this.userName,
    required this.aboutMe,
    required this.interests,
  }) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late String aboutMe;
  late List<String> interests;

  @override
  void initState() {
    super.initState();
    aboutMe = widget.aboutMe;
    interests = widget.interests;
  }

  void _editProfile() {
    showDialog(
      context: context,
      builder: (context) {
        TextEditingController aboutMeController = TextEditingController(text: aboutMe);
        return AlertDialog(
          title: const Text("Edit About Me"),
          content: TextField(
            controller: aboutMeController,
            maxLines: 4,
            decoration: const InputDecoration(
              hintText: "Enter details about yourself...",
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  aboutMe = aboutMeController.text;
                });
                Navigator.of(context).pop();
              },
              child: const Text("Save"),
            ),
          ],
        );
      },
    );
  }

  void _changeInterests() {
    showDialog(
      context: context,
      builder: (context) {
        List<String> allInterests = [
          "Games Online",
          "Concert",
          "Music",
          "Art",
          "Movie",
          "Others"
        ];
        List<String> selectedInterests = List.from(interests);

        return AlertDialog(
          title: const Text("Change Interests"),
          content: StatefulBuilder(
            builder: (context, setState) {
              return Wrap(
                spacing: 8,
                runSpacing: 8,
                children: allInterests.map((interest) {
                  bool isSelected = selectedInterests.contains(interest);
                  return FilterChip(
                    label: Text(interest),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          selectedInterests.add(interest);
                        } else {
                          selectedInterests.remove(interest);
                        }
                      });
                    },
                  );
                }).toList(),
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  interests = selectedInterests;
                });
                Navigator.of(context).pop();
              },
              child: const Text("Save"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.of(context).pop(); // Go back to the previous screen
          },
        ),
        title: const Text("Profile", style: TextStyle(color: Colors.black)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const CircleAvatar(
                radius: 50,
                backgroundColor: Colors.grey,
                child: Icon(Icons.person, size: 50, color: Colors.white),
              ),
              const SizedBox(height: 16),
              Text(
                widget.userName,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _editProfile,
                icon: const Icon(Icons.edit),
                label: const Text("Edit Profile"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  textStyle: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "About Me",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                aboutMe,
                style: const TextStyle(fontSize: 16, color: Colors.black54),
                textAlign: TextAlign.left,
              ),
              const Divider(thickness: 1),
              const SizedBox(height: 16),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Interest",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: interests.map((interest) {
                  return Chip(
                    label: Text(interest),
                    backgroundColor: Colors.lightBlueAccent,
                    labelStyle: const TextStyle(color: Colors.white),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _changeInterests,
                icon: const Icon(Icons.edit),
                label: const Text("Change"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

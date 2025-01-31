import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pedl/services/local_storage_manager.dart';

class ProfilePage extends StatefulWidget {
  final String userName;

  const ProfilePage({
    Key? key,
    required this.userName,
  }) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late String aboutMe;
  late List<String> interests;
  String? profilePicturePath;
  final LocalStorageManager _storage = LocalStorageManager();
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  // Load user data from local storage
  void _loadUserData() async {
    final data = await _storage.loadUserData();
    setState(() {
      aboutMe = data['aboutMe'];
      interests = data['interests'];
      profilePicturePath = data['profileImage'];
    });
  }

  // Handle profile picture upload
  void _uploadProfilePicture() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image == null) return;

    final String? path = await _storage.saveImageLocally(image);
    if (path != null) {
      await _storage.saveUserData(
        aboutMe: aboutMe,
        interests: interests,
        imagePath: path,
      );
      setState(() => profilePicturePath = path);
    }
  }

  // Edit About Me dialog
  void _editProfile() {
    TextEditingController aboutMeController = TextEditingController(text: aboutMe);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Edit About Me"),
          content: TextField(
            controller: aboutMeController,
            maxLines: 4,
            decoration: const InputDecoration(
              hintText: "Tell us about yourself...",
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                setState(() => aboutMe = aboutMeController.text);
                await _storage.saveUserData(
                  aboutMe: aboutMe,
                  interests: interests,
                  imagePath: profilePicturePath,
                );
                Navigator.pop(context);
              },
              child: const Text("Save"),
            ),
          ],
        );
      },
    );
  }

  // Change Interests dialog
  void _changeInterests() {
    List<String> allInterests = [
      "Games Online",
      "Concert",
      "Music",
      "Art",
      "Movie",
      "Others"
    ];
    List<String> selectedInterests = List.from(interests);

    showDialog(
      context: context,
      builder: (context) {
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
                    onSelected: (selected) => setState(() {
                      selected ? selectedInterests.add(interest)
                          : selectedInterests.remove(interest);
                    }),
                  );
                }).toList(),
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                setState(() => interests = selectedInterests);
                await _storage.saveUserData(
                  aboutMe: aboutMe,
                  interests: interests,
                  imagePath: profilePicturePath,
                );
                Navigator.pop(context);
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
          onPressed: () => Navigator.pop(context),
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
              GestureDetector(
                onTap: _uploadProfilePicture,
                child: CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.grey[300],
                  backgroundImage: profilePicturePath != null
                      ? FileImage(File(profilePicturePath!))
                      : null,
                  child: profilePicturePath == null
                      ? const Icon(Icons.add_a_photo, size: 30, color: Colors.black54)
                      : null,
                ),
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
                label: const Text("Edit About Me", style: const TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
              const SizedBox(height: 42),
              _buildSectionTitle("About Me",),
              const SizedBox(height: 20),
              Text(
                aboutMe,
                style: const TextStyle(fontSize: 16, color: Colors.black87),
              ),
              const Divider(thickness: 1),
              const SizedBox(height: 60),
              _buildSectionTitle("Interests"),
              const SizedBox(height: 18),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: interests.map((interest) => Chip(
                  label: Text(interest, style: const TextStyle(color: Colors.white)),
                  backgroundColor: Colors.redAccent,
                  labelStyle: const TextStyle(color: Colors.black87),
                )).toList(),
              ),
              const SizedBox(height: 26),
              ElevatedButton.icon(
                onPressed: _changeInterests,
                icon: const Icon(Icons.edit),
                label: const Text("Change Interests", style: const TextStyle(fontSize: 16, color: Colors.white)),
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

  Widget _buildSectionTitle(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      ),
    );
  }
}
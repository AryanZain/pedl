import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageManager {
  static final LocalStorageManager _instance = LocalStorageManager._internal();
  factory LocalStorageManager() => _instance;
  LocalStorageManager._internal();

  // SharedPreferences keys
  static const String _aboutMeKey = 'aboutMe';
  static const String _interestsKey = 'interests';
  static const String _profileImageKey = 'profileImage';

  // Save all user data to SharedPreferences
  Future<void> saveUserData({
    required String aboutMe,
    required List<String> interests,
    String? imagePath,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_aboutMeKey, aboutMe);
    await prefs.setStringList(_interestsKey, interests);
    if (imagePath != null) {
      await prefs.setString(_profileImageKey, imagePath);
    }
  }

  // Load all user data from SharedPreferences
  Future<Map<String, dynamic>> loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'aboutMe': prefs.getString(_aboutMeKey) ?? 'Write something about yourself...',
      'interests': prefs.getStringList(_interestsKey) ?? [],
      'profileImage': prefs.getString(_profileImageKey),
    };
  }

  // Save image to device storage and return path
  Future<String?> saveImageLocally(XFile image) async {
    try {
      final Directory directory = await getApplicationDocumentsDirectory();
      final String path = '${directory.path}/profile_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final File newImage = File(path);
      await newImage.writeAsBytes(await image.readAsBytes());
      return path;
    } catch (e) {
      print('Error saving image: $e');
      return null;
    }
  }
}
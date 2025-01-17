import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class ProfilePictureManager {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  /// Uploads the selected image to Firebase Storage and returns the download URL.
  Future<String?> uploadProfilePicture() async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);

      if (pickedFile == null) {
        return null; // User canceled image selection.
      }

      final user = _auth.currentUser;
      if (user == null) throw Exception("User not authenticated");

      final storageRef = _storage.ref().child('profile_pictures/${user.uid}.jpg');
      final uploadTask = storageRef.putFile(File(pickedFile.path));

      // Await the upload and get the download URL
      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();

      return downloadUrl;
    } catch (e) {
      print("Error uploading profile picture: $e");
      rethrow; // Re-throw the error for further handling.
    }
  }

  /// Retrieves the user's profile picture URL from Firebase Storage.
  Future<String?> getProfilePictureUrl() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return null;

      final storageRef = _storage.ref().child('profile_pictures/${user.uid}.jpg');
      return await storageRef.getDownloadURL();
    } catch (e) {
      print("Error fetching profile picture: $e");
      return null; // Return null if image not found or error occurred.
    }
  }
}

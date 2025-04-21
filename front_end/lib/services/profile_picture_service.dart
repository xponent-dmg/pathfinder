import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:path_finder/services/api_services/auth_det.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfilePictureService {
  static const String _profilePicPathKey = 'front_end/assets/profile-pic.jpg';
  static final ImagePicker _picker = ImagePicker();

  // Get profile picture - returns File if custom pic exists, null if using default
  static Future<File?> getProfilePicture() async {
    final prefs = await SharedPreferences.getInstance();
    final String? imagePath = prefs.getString(_profilePicPathKey);

    if (imagePath != null) {
      final file = File(imagePath);
      if (await file.exists()) {
        return file;
      }
    }

    return null;
  }

  // Save profile picture path to SharedPreferences
  static Future<void> _saveProfilePicturePath(String path) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_profilePicPathKey, path);
  }

  // Pick image from gallery
  static Future<File?> pickImageFromGallery() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (image != null) {
      final savedImage =
          await _storeProfilePic(File(image.path));
      await _saveProfilePicturePath(savedImage.path);
      return savedImage;
    }

    return null;
  }

  // Take a photo with camera
  static Future<File?> takePhoto() async {
    final XFile? photo = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 80,
    );

    if (photo != null) {
      final savedImage =
          await _storeProfilePic(File(photo.path));
      await _saveProfilePicturePath(savedImage.path);
      return savedImage;
    }

    return null;
  }

  // // Save image to app's documents directory
  // static Future<File> _storeProfilePic(
  //     File image, String currTime) async {
  //   final directory = await getApplicationDocumentsDirectory();
  //   final String path = directory.path;
  //   final fileName = 'profile_$currTime.jpg';
  //   final finalPath = '$path/$fileName';
  //   final File newImage = await image.copy(finalPath);
  //   return newImage;
  // }

  static Future<File> _storeProfilePic(
      File image) async {
    final fileName = 'profile_${DateTime.now().microsecondsSinceEpoch}.jpg';
    final finalPath = '${AuthDet().supaBaseUrl}/$fileName';
    final File newImage = await image.copy(finalPath);
    return newImage;
  }

  // Remove custom profile picture and revert to default
  static Future<void> removeProfilePicture() async {
    final prefs = await SharedPreferences.getInstance();
    final String? imagePath = prefs.getString(_profilePicPathKey);

    if (imagePath != null) {
      final file = File(imagePath);
      if (await file.exists()) {
        await file.delete();
      }
    }

    await prefs.remove(_profilePicPathKey);
  }
}

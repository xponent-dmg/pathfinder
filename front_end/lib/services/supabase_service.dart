import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  final _supabase = Supabase.instance.client;

  Future<String?> uploadEventPicture(File imageFile, String eventName) async {
    final String fileName =
        '$eventName-${DateTime.now().millisecondsSinceEpoch}.jpg';
    final String filePath = 'event-pics/$fileName';

    try {
      print('Uploading file to Supabase storage: $filePath');

      await _supabase.storage.from('pathfinder').upload(filePath, imageFile);

      final String publicUrl =
          _supabase.storage.from('pathfinder').getPublicUrl(filePath);

      print('File uploaded successfully. Public URL: $publicUrl');
      return publicUrl;
    } catch (e) {
      print('Upload Error: $e');
      return null;
    }
  }
}

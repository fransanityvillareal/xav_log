import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ImageUploadService {
  Future<String?> uploadImage() async {
    try {
      // Ensure user is authenticated
      final firebaseUser = FirebaseAuth.instance.currentUser;
      final supabaseUser = Supabase.instance.client.auth.currentUser;
      if (firebaseUser == null || supabaseUser == null) {
        throw Exception('User not authenticated');
      }

      // Open file picker
      final result = await FilePicker.platform.pickFiles(type: FileType.image);
      if (result == null || result.files.single.path == null) {
        throw Exception('No file selected');
      }

      // Prepare file for upload
      final file = File(result.files.single.path!);
      final fileExt = file.path.split('.').last;
      final fileName =
          '${firebaseUser.uid}_${DateTime.now().millisecondsSinceEpoch}.$fileExt';

      // Upload to Supabase
      await Supabase.instance.client.storage
          .from('xavlog-profile')
          .upload(fileName, file, fileOptions: const FileOptions(upsert: true));

      // Get public URL
      final publicUrl = Supabase.instance.client.storage
          .from('xavlog-profile')
          .getPublicUrl(fileName);

      // Store URL in Firestore
      await FirebaseFirestore.instance
          .collection('Users')
          .doc(firebaseUser.uid)
          .set({'profileImageUrl': publicUrl}, SetOptions(merge: true));

      return publicUrl;
    } catch (e) {
      print('Error uploading image: $e');
      return null;
    }
  }
}

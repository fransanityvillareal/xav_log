import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileImageUploader extends StatefulWidget {
  const ProfileImageUploader({super.key});

  @override
  State<ProfileImageUploader> createState() => _ProfileImageUploaderState();
}

class _ProfileImageUploaderState extends State<ProfileImageUploader> {
  String? imageUrl;

  Future<void> pickAndUploadImage() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowedExtensions: ['jpg', 'jpeg', 'png'],
    );

    if (result != null && result.files.single.path != null) {
      final file = File(result.files.single.path!);
      final fileName = '${Supabase.instance.client.auth.currentUser?.id}.png';

      try {
        // Upload to Supabase
        await Supabase.instance.client.storage.from('profile_images').upload(
            fileName, file,
            fileOptions: const FileOptions(upsert: true));

        // Get public URL
        final url = Supabase.instance.client.storage
            .from('profile_images')
            .getPublicUrl(fileName);

        setState(() {
          imageUrl = url;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Upload successful!')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Upload failed: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: pickAndUploadImage,
          child: CircleAvatar(
            backgroundImage: imageUrl != null ? NetworkImage(imageUrl!) : null,
            radius: 50,
            child: imageUrl == null
                ? const Icon(
                    Icons.camera_alt,
                    size: 30,
                    color: Colors.white,
                  )
                : null,
          ),
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: pickAndUploadImage,
          child: const Text('Upload Profile Image'),
        ),
      ],
    );
  }
}

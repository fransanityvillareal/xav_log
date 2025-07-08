import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/product.dart';

class SellerProductCreateScreen extends StatefulWidget {
  const SellerProductCreateScreen({super.key});

  @override
  State<SellerProductCreateScreen> createState() =>
      _SellerProductCreateScreenState();
}

class _SellerProductCreateScreenState extends State<SellerProductCreateScreen> {
  final _formKey = GlobalKey<FormState>();
  String _title = '';
  String _description = '';
  int _price = 0;
  String _image = '';
  String _condition = '';
  String _category = '';

  // Submit the form and add the product
  void _submit() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      // Ensure an image URL is available
      if (_image.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Please upload an image before submitting!'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 2),
          ),
        );
        return;
      }

      // Fetch the current user's email
      final user = FirebaseAuth.instance.currentUser;
      final sellerEmail = user?.email ?? 'Unknown';

      // Creating a new product object
      final newProduct = Product(
        id: DateTime.now().millisecondsSinceEpoch, // Simple unique id
        image: _image,
        title: _title,
        price: _price,
        description: _description,
        condition: _condition.isNotEmpty ? _condition : 'Used',
        color: Colors.grey, // Default color
        category: _category.isNotEmpty ? _category : 'Others',
        sellerEmail: sellerEmail, // Use the authenticated user's email
        sellerProfileImageUrl: '', // Placeholder, can be updated later
      );

      try {
        // Save product to Firestore
        await FirebaseFirestore.instance
            .collection('products')
            .add(newProduct.toFirestore());

        // Removed manual addition to ProductProvider to avoid duplication

        // Show Snackbar for successful product addition
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Product Added Successfully!'),
            backgroundColor: Colors.green, // Success color
            duration: const Duration(seconds: 2),
          ),
        );

        // Pop the screen to go back to the previous one
        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to add product: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } else {
      // If form is invalid, show an error message in Snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please fill in all fields correctly!'),
          backgroundColor: Colors.red, // Error color
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _pickImage() async {
    // Open file picker for image selection
    final result = await FilePicker.platform.pickFiles(type: FileType.image);
    if (result == null || result.files.single.path == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('No image selected!'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }

    final filePath = result.files.single.path!;
    final file = File(filePath);

    // Validate if the file exists
    if (!file.existsSync()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Selected image file does not exist!'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }

    final fileExt = file.path.split('.').last;
    final fileName =
        'product_${DateTime.now().millisecondsSinceEpoch}.$fileExt';

    try {
      // Upload image to Supabase bucket
      await Supabase.instance.client.storage.from('xavlog-profile').upload(
            fileName,
            file,
            fileOptions: const FileOptions(upsert: true),
          );

      // Get public URL of the uploaded image
      final publicUrl = Supabase.instance.client.storage
          .from('xavlog-profile')
          .getPublicUrl(fileName);

      // Update UI with the new image URL
      setState(() {
        _image = '$publicUrl?ts=${DateTime.now().millisecondsSinceEpoch}';
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Image uploaded successfully!'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Image upload failed: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _chatNow(String sellerEmail) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('You need to be logged in to chat!'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }

    final currentUserEmail = currentUser.email;

    try {
      // Check if a chat room already exists
      final chatRoomQuery = await FirebaseFirestore.instance
          .collection('chat_rooms')
          .where('participants', arrayContains: currentUserEmail)
          .get();

      DocumentSnapshot? existingChatRoom;
      for (var doc in chatRoomQuery.docs) {
        final participants = List<String>.from(doc['participants']);
        if (participants.contains(sellerEmail)) {
          existingChatRoom = doc;
          break;
        }
      }

      if (existingChatRoom != null) {
        // Navigate to the existing chat room
        Navigator.pushNamed(context, '/chat', arguments: existingChatRoom.id);
      } else {
        // Create a new chat room
        final newChatRoom =
            await FirebaseFirestore.instance.collection('chat_rooms').add({
          'participants': [currentUserEmail, sellerEmail],
          'lastMessage': '',
          'timestamp': FieldValue.serverTimestamp(),
        });

        // Navigate to the new chat room
        Navigator.pushNamed(context, '/chat', arguments: newChatRoom.id);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to start chat: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue, // Blue color for AppBar
        title: const Text('Add Product', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        elevation: 5.0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Product Title
              _buildTextFormField(
                label: 'Product Title',
                icon: Icons.title,
                validator: (value) => value == null || value.isEmpty
                    ? 'Enter product title'
                    : null,
                onSaved: (value) => _title = value!,
              ),

              // Description
              _buildTextFormField(
                label: 'Description',
                icon: Icons.description,
                validator: (value) =>
                    value == null || value.isEmpty ? 'Enter description' : null,
                onSaved: (value) => _description = value!,
              ),

              // Price
              _buildTextFormField(
                label: 'Price',
                icon: Icons.monetization_on,
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Enter price';
                  final price = int.tryParse(value);
                  if (price == null || price < 0) return 'Enter valid price';
                  return null;
                },
                onSaved: (value) => _price = int.parse(value!),
              ),

              // Condition
              _buildTextFormField(
                label: 'Condition',
                icon: Icons.build,
                validator: (value) =>
                    value == null || value.isEmpty ? 'Enter condition' : null,
                onSaved: (value) => _condition = value ?? '',
              ),

              // Category (Dropdown, required)
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: DropdownButtonFormField<String>(
                  value: _category.isNotEmpty ? _category : null,
                  decoration: InputDecoration(
                    labelText: 'Category *',
                    prefixIcon: const Icon(Icons.category, color: Colors.blue),
                    labelStyle: const TextStyle(color: Colors.black54),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFB0BEC5)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.blue),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.red),
                    ),
                  ),
                  items: [
                    'Stationery',
                    'Equipment',
                    'Clothing',
                    'Technology',
                    'Accessories',
                    'Others'
                  ]
                      .map((cat) => DropdownMenuItem(
                            value: cat,
                            child: Text(cat),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _category = value ?? '';
                    });
                  },
                  validator: (value) => (value == null || value.isEmpty)
                      ? 'Category is required'
                      : null,
                  onSaved: (value) => _category = value ?? '',
                ),
              ),

              // Image Picker Button
              ElevatedButton.icon(
                onPressed: _pickImage,
                icon: const Icon(Icons.image),
                label: const Text('Pick Image'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),

           

              // Add Product Button
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber, // Amber color for the button
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  elevation: 5,
                ),
                onPressed: _submit,
                child: const Text('Add Product',
                    style: TextStyle(fontSize: 16, color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // A helper method to build styled TextFormFields
  Widget _buildTextFormField({
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    void Function(String?)? onSaved,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        keyboardType: keyboardType,
        validator: validator,
        onSaved: onSaved,
        style: const TextStyle(fontSize: 16),
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: Colors.blue), // Blue color for icons
          labelStyle: const TextStyle(color: Colors.black54),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFB0BEC5)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
                color: Colors.blue), // Blue border when focused
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.red),
          ),
        ),
      ),
    );
  }
}

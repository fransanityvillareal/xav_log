import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/product.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

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
  XFile? _pickedImage;

  // Submit the form and add the product
  void _submit() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      // Ensure an image is selected
      if (_pickedImage == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Please select an image first!'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 2),
          ),
        );
        return;
      }

      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return const AlertDialog(
            content: Row(
              children: [
                CircularProgressIndicator(),
                SizedBox(width: 20),
                Text("Uploading product..."),
              ],
            ),
          );
        },
      );

      try {
        await _uploadImageToSupabase();
        // Check if upload was successful
        if (_image.isEmpty) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Failed to upload image. Please try again.'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 2),
            ),
          );
          return;
        }

        // Fetch the current user's email
        final user = FirebaseAuth.instance.currentUser;
        final sellerEmail = user?.email ?? 'Unknown';

        // Creating a new product object with the Supabase image URL
        final newProduct = Product(
          id: DateTime.now().millisecondsSinceEpoch,
          image: _image, // Now this contains the Supabase URL
          title: _title,
          price: _price,
          description: _description,
          condition: _condition.isNotEmpty ? _condition : 'Used',
          color: Colors.grey,
          category: _category.isNotEmpty ? _category : 'Others',
          sellerEmail: sellerEmail,
          sellerProfileImageUrl: '',
        );

        // Save product to Firestore
        await FirebaseFirestore.instance
            .collection('products')
            .add(newProduct.toFirestore());

        // Close loading dialog
        Navigator.pop(context);

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Product Added Successfully!'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );

        // Go back to previous screen
        Navigator.pop(context);
      } catch (e) {
        // Close loading dialog
        Navigator.pop(context);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to add product: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please fill in all fields correctly!'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  //upload to supabase
  //upload to supabase
  Future<void> _uploadImageToSupabase() async {
    if (_pickedImage == null) return;

    try {
      final fileExt = _pickedImage!.path.split('.').last.toLowerCase();
      final fileName =
          'product_${DateTime.now().millisecondsSinceEpoch}.$fileExt';

      // Determine the correct MIME type based on file extension
      String contentType;
      switch (fileExt) {
        case 'jpg':
        case 'jpeg':
          contentType = 'image/jpeg';
          break;
        case 'png':
          contentType = 'image/png';
          break;
        case 'gif':
          contentType = 'image/gif';
          break;
        case 'webp':
          contentType = 'image/webp';
          break;
        case 'bmp':
          contentType = 'image/bmp';
          break;
        default:
          contentType = 'image/jpeg'; // Default to JPEG
      }

      // Upload to Supabase Storage with correct content type
      if (kIsWeb) {
        // Web upload using bytes
        final bytes = await _pickedImage!.readAsBytes();
        await Supabase.instance.client.storage
            .from('xavlog-profile')
            .uploadBinary(
              fileName,
              bytes,
              fileOptions: FileOptions(
                upsert: true,
                contentType: contentType, // Specify the correct MIME type
              ),
            );
      } else {
        // Mobile upload using file
        final file = File(_pickedImage!.path);
        await Supabase.instance.client.storage.from('xavlog-profile').upload(
              fileName,
              file,
              fileOptions: FileOptions(
                upsert: true,
                contentType: contentType, // Specify the correct MIME type
              ),
            );
      }

      // Get public URL and set it to _image
      final publicUrl = Supabase.instance.client.storage
          .from('xavlog-profile')
          .getPublicUrl(fileName);

      // Verify the URL is not empty
      if (publicUrl.isNotEmpty) {
        setState(() {
          _image = publicUrl;
        });
        print('Image uploaded successfully: $_image');
        print('Content Type: $contentType');
      } else {
        throw Exception('Failed to get public URL');
      }
    } catch (e) {
      print('Upload error: $e');
      setState(() {
        _image = '';
      });
      throw Exception('Upload failed: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF283AA3), // Set AppBar background to white
        title: const Text('Add Product',
            style: TextStyle(
                color: Color.fromARGB(
                    255, 253, 253, 253))), // Set title color to black
        centerTitle: true,
        elevation: 5.0,
        iconTheme: const IconThemeData(
            color: Colors.white), // Set back icon color to white
      ),
      body: Container(
        color: Colors.white, // Set background color to white
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                //Image
                GestureDetector(
                  onTap: () async {
                    final image = await ImagePicker()
                        .pickImage(source: ImageSource.gallery);
                    if (image != null) {
                      setState(() {
                        _pickedImage = image;
                        //save to supabase
                      });
                    }
                  },
                  child: Container(
                    height: 150,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    // child: const Icon(Icons.camera_alt, size: 50, color: Colors.grey),
                    child: _pickedImage == null
                        ? const Icon(Icons.camera_alt,
                            size: 50, color: Colors.grey)
                        : kIsWeb
                            ? Image.network(_pickedImage!.path,
                                fit: BoxFit.cover)
                            : Image.file(File(_pickedImage!.path),
                                fit: BoxFit.cover),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                      top: 16.0, bottom: 16.0), // Added bottom padding
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color.fromARGB(
                          255, 255, 255, 255), // Amber color for the button

                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    onPressed: () {
                      setState(() {
                        _pickedImage = null;
                      });
                    },
                    child: const Text('Reset'),
                  ),
                ),
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
                  validator: (value) => value == null || value.isEmpty
                      ? 'Enter description'
                      : null,
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

                // Condition (Dropdown, required)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: DropdownButtonFormField<String>(
                    value: _condition.isNotEmpty ? _condition : null,
                    decoration: InputDecoration(
                      labelText: 'Condition *',
                      prefixIcon:
                          const Icon(Icons.build, color: Color(0xFF283AA3)),
                      labelStyle: const TextStyle(color: Colors.black54),
                      filled: true, // Enable background color
                      fillColor: Colors.white, // Set background color to white
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFFB0BEC5)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFF283AA3)),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Colors.red),
                      ),
                    ),
                    dropdownColor: Colors.white,
                    items: [
                      'New',
                      'Like New',
                      'Refurbished',
                      'Used',
                      'Fair',
                      'Broken',
                    ]
                        .map((condition) => DropdownMenuItem(
                              value: condition,
                              child: Text(condition),
                            ))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        _condition = value ?? '';
                      });
                    },
                    validator: (value) => (value == null || value.isEmpty)
                        ? 'Condition is required'
                        : null,
                    onSaved: (value) => _condition = value ?? '',
                  ),
                ),

                // Category (Dropdown, required)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: DropdownButtonFormField<String>(
                    value: _category.isNotEmpty ? _category : null,
                    decoration: InputDecoration(
                      labelText: 'Category *',
                      prefixIcon:
                          const Icon(Icons.category, color: Color(0xFF283AA3)),
                      labelStyle: const TextStyle(color: Colors.black54),
                      filled: true, // Enable background color
                      fillColor: Colors.white, // Set background color to white
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFFB0BEC5)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFF283AA3)),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Colors.red),
                      ),
                    ),
                    dropdownColor: Colors.white,
                    items: [
                      'Stationnery',
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
                // Add Product Button
                const SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        Color(0xFFBFA547), // Amber color for the button
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
          prefixIcon:
              Icon(icon, color: Color(0xFF283AA3)), // Blue color for icons
          labelStyle: const TextStyle(color: Colors.black54),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFB0BEC5)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
                color: Color(0xFF283AA3)), // Blue border when focused
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

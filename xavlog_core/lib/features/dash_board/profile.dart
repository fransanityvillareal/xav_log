import 'package:flutter/material.dart';
import 'package:xavlog_core/features/login/log_in_main.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:xavlog_core/widget/bottom_nav_wrapper.dart';
import '../login/terms_and_conditions.dart';
import '../login/faqs.dart';
import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:file_picker/file_picker.dart';

class ProfilePage extends StatefulWidget {
  final String? orgName;
  final String? description;
  final String? profileImageUrl;
  final String? orgcontact;
  final String? orgemail;
  final bool isOrganization;

  const ProfilePage({
    super.key,
    this.orgName,
    this.description,
    this.profileImageUrl,
    this.orgcontact,
    this.orgemail,
    this.isOrganization = false,
  });

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _formKey = GlobalKey<FormState>();
  bool _isEditing = false;
  late String name = 'Loading...';
  late String description = ' ';
  late String profileImageUrl;
  late String contact = ' ';
  late String email = '';

  // Additional fields for individual profiles
  String department = '';
  String program = '';
  String studentId = '';

  @override
  void initState() {
    super.initState();
    profileImageUrl = 'https://i.imgur.com/4STeKWS.png';
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      // Handle the case where no user is signed in
      print('No user is signed in');
      return;
    }

    final uid = user.uid; // Get the current user's UID
    final doc =
        await FirebaseFirestore.instance.collection('Users').doc(uid).get();

    if (doc.exists) {
      final data = doc.data();
      setState(() {
        name = '${data?['firstName'] ?? 'NoName'} ${data?['lastName'] ?? ''}';
        description =
            '${data?['program'] ?? ''} - ${data?['department'] ?? ''}';
        email = data?['email'] ?? 'No Email';
        studentId = data?['studentId'] ?? 'No ID';
        department = data?['department'] ?? '';
        program = data?['program'] ?? '';
        profileImageUrl =
            data?['profileImageUrl'] ?? 'https://i.imgur.com/4STeKWS.png';

        // Add a timestamp to avoid caching issues
        profileImageUrl =
            '$profileImageUrl?ts=${DateTime.now().millisecondsSinceEpoch}';
      });
    }
  }

  Future<void> _uploadProfileImage() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['png', 'jpg', 'jpeg'],
      withData: true,
    );

    if (result != null && result.files.single.bytes != null) {
      final fileBytes = result.files.single.bytes!;
      final fileName = result.files.single.name;
      final tempFile = File('${Directory.systemTemp.path}/$fileName');
      await tempFile.writeAsBytes(fileBytes);

      // Show preview dialog
      bool? confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: Colors.white,
          title: const Text('Preview Profile Image'),
          content: Image.memory(fileBytes,
              width: 300, height: 300, fit: BoxFit.cover),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Upload'),
            ),
          ],
        ),
      );

      if (confirmed != true) return;

      try {
        await Supabase.instance.client.storage.from('xavlog-profile').upload(
            fileName, tempFile,
            fileOptions: const FileOptions(upsert: true));

        final publicUrl = Supabase.instance.client.storage
            .from('xavlog-profile')
            .getPublicUrl(fileName);

        print('Public URL: $publicUrl');

        await FirebaseFirestore.instance
            .collection('Users')
            .doc(user.uid)
            .set({'profileImageUrl': publicUrl}, SetOptions(merge: true));

        setState(() {
          profileImageUrl =
              '$publicUrl?ts=${DateTime.now().millisecondsSinceEpoch}';
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.greenAccent,
            content: Text(
              'Profile image uploaded successfully!',
              style: TextStyle(color: Colors.black),
            ),
          ),
        );
      } catch (e) {
        print('Error uploading profile image: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to upload image: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Responsive dimensions
    final fontSize = MediaQuery.of(context).size.width * 0.03;

    return Scaffold(
      backgroundColor: Colors.white, // Set background to white
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF071D99), // Blue AppBar
        leading: IconButton(
          icon: const Padding(
            padding: EdgeInsets.only(top: 5.0, bottom: 5.0),
            child: Icon(Icons.arrow_back, color: Colors.white),
          ),
          onPressed: () {
            if (_isEditing) {
              setState(() {
                _isEditing = false;
              });
            } else {
              _navigateBackWithData();
            }
          },
        ),
        title: _isEditing
            ? const Text(
                'Edit Profile',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Jost',
                  color: Colors.white,
                ),
              )
            : null,
        actions: _isEditing
            ? null // Remove settings icon when in edit mode
            : [],
      ),
      body: SingleChildScrollView(
        child: _isEditing
            ? _buildEditForm()
            : Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),
                  GestureDetector(
                    onTap: _uploadProfileImage,
                    child: CircleAvatar(
                      radius: MediaQuery.of(context).size.width *
                          0.10, // Responsive avatar size
                      backgroundColor: const Color.fromARGB(255, 146, 146, 146),
                      backgroundImage: NetworkImage(profileImageUrl),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    name,
                    style: TextStyle(
                      fontSize: fontSize * 1.8,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Jost', // Updated font
                      color: const Color(0xFF071D99), // Blue text
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: fontSize * 1.2,
                      fontFamily: 'Jost', // Updated font
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Personal Information Section
                  if (!widget.isOrganization)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: _buildInfoCard(
                        'Personal Information',
                        [
                          _buildInfoTile(Icons.email, 'Email', email),
                          _buildInfoTile(Icons.perm_identity, 'ID', studentId),
                          _buildInfoTile(
                              Icons.home_filled, 'Department', department),
                          _buildInfoTile(
                              Icons.category, 'Program of Study', program),
                        ],
                        showEditIcon: true,
                      ),
                    ),

                  // Organization Information Section
                  if (widget.isOrganization)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: _buildInfoCard(
                        'Organization Information',
                        [
                          _buildInfoTile(Icons.email, 'Email', email),
                          _buildInfoTile(Icons.phone, 'Contact', contact),
                        ],
                        showEditIcon: true,
                      ),
                    ),

                  const SizedBox(height: 16),

                  // Utilities Section
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: _buildInfoCard(
                      'Utilities',
                      [
                        _buildUtilityTile(Icons.rule, 'Terms and Conditions',
                            () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    const TermsAndConditions()),
                          );
                        }),
                        _buildUtilityTile(Icons.help, 'View FAQs', () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const FAQs()),
                          );
                        }),
                        _buildUtilityTile(Icons.logout, 'Log-Out', () {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                backgroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                title: const Text(
                                  'Logout',
                                  style: TextStyle(
                                    color: Color(0xFF071D99),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                content: const Text(
                                  'Are you sure you want to logout?',
                                  style: TextStyle(fontSize: 16),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.of(context).pop(),
                                    child: const Text(
                                      'Cancel',
                                      style: TextStyle(
                                        color: Color.fromARGB(255, 0, 0, 0),
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () async {
                                      // Close dialog first
                                      Navigator.of(context).pop();

                                      // Sign out and navigate
                                      await FirebaseAuth.instance.signOut();
                                      Navigator.of(context).pushAndRemoveUntil(
                                        MaterialPageRoute(
                                            builder: (context) => LoginPage()),
                                        (route) => false,
                                      );
                                    },
                                    child: const Text(
                                      'Logout',
                                      style: TextStyle(
                                        color: Color(0xFF071D99),
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                          );
                        }),
                      ],
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildEditForm() {
    final nameController = TextEditingController(text: name);
    final emailController = TextEditingController(text: email);
    final idController = TextEditingController(text: studentId);
    final descriptionController = TextEditingController(text: description);
    final departmentController = TextEditingController(text: department);
    final programController = TextEditingController(text: program);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),

            // Name Field
            _buildTextField('Name', nameController, (value) => name = value),

            // Email Field (disabled)
            AbsorbPointer(
              child: TextFormField(
                controller: emailController,
                enabled: false, // also makes keyboard not open
                readOnly: true,
                style: const TextStyle(color: Colors.grey), // Greyed-out text
                decoration: InputDecoration(
                  labelText: 'Email',
                  filled: true,
                  fillColor: Colors.grey.shade200, // Light background
                  prefixIcon:
                      const Icon(Icons.email_outlined, color: Colors.grey),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade400),
                  ),
                ),
              ),
            ),

            // ID Field (editable)
            _buildTextField('ID', idController, (value) => studentId = value),

            // Description Field
            _buildTextField('Description', descriptionController,
                (value) => description = value),

            // Department Field - Only for personal accounts
            if (!widget.isOrganization)
              _buildTextField('Department', departmentController,
                  (value) => department = value),

            // Program Field - Only for personal accounts
            if (!widget.isOrganization)
              _buildTextField('Program of Study', programController,
                  (value) => program = value),

            const SizedBox(height: 20),

            // Save Button
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF071D99), // Blue button
                  padding:
                      const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () {
                  _saveChanges(nameController.text, idController.text,
                      emailController.text);
                },
                child: const Text(
                  'Save Changes',
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: 'Jost', // Updated font
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller,
      Function(String) onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(
              color: Colors.grey, fontFamily: 'Jost'), // Updated font
          filled: true,
          fillColor: const Color(0xFFF5F5F5), // Light gray background
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide:
                const BorderSide(color: Color(0xFF071D99)), // Blue border
          ),
        ),
        style: const TextStyle(
            color: Colors.black, fontFamily: 'Jost'), // Updated font
        onChanged: onChanged,
      ),
    );
  }

  void _saveChanges(
      String updatedName, String updatedId, String updatedEmail) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    // Split name into first and last name
    final nameParts = updatedName.trim().split(' ');
    final firstName = nameParts.isNotEmpty ? nameParts.first : '';
    final lastName = nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';

    try {
      await FirebaseFirestore.instance.collection('Users').doc(user.uid).set({
        'firstName': firstName,
        'lastName': lastName,
        'email': updatedEmail,
        'department': department,
        'program': program,
        'studentId': updatedId,
      }, SetOptions(merge: true));

      setState(() {
        name = updatedName;
        studentId = updatedId;
        email = updatedEmail;
        _isEditing = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update profile: $e')),
      );
    }
  }

  Widget _buildInfoCard(String title, List<Widget> children,
      {bool showEditIcon = false}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF), // White background
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 23, // Increased font size for titles
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF071D99),
                ),
              ),
              if (showEditIcon)
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _isEditing = true;
                    });
                  },
                  child: Icon(
                    Icons.edit,
                    color: const Color(0xFF071D99),
                    size: 23 * 0.8,
                  ),
                ),
            ],
          ),
          const Divider(height: 20, color: Colors.grey),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoTile(IconData icon, String label, String value) {
    final fontSize = 14;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(fontSize * 0.4),
            decoration: BoxDecoration(
              color: const Color(0xFF071D99).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: const Color(0xFF071D99),
              size: fontSize * 1.2,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: fontSize * 1.2,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUtilityTile(IconData icon, String label, VoidCallback onTap) {
    final fontSize = 14;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: InkWell(
        onTap: onTap,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF071D99).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: const Color(0xFF071D99), size: 20),
                ),
                const SizedBox(width: 16),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: fontSize * 1.2,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
            const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 16),
          ],
        ),
      ),
    );
  }

  void _navigateBackWithData() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (context) => HomeWrapper(
          initialTab: 2,
        ),
      ),
      (route) => false,
    );
  }
}

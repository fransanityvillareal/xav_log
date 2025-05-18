import 'package:flutter/material.dart';
// import 'package:file_picker/file_picker.dart';
import 'package:xavlog_core/features/dash_board/org_dashboard.dart';

class ProfileOrganization extends StatefulWidget {
  const ProfileOrganization({super.key});

  @override
  State<ProfileOrganization> createState() => _ProfileOrganizationState();
}

class _ProfileOrganizationState extends State<ProfileOrganization> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  String? _selectedFilePath;

  Future<void> _pickPDF() async {
    // TODO: Enable actual PDF picker here
    /*
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );
      if (result != null) {
        setState(() => _selectedFilePath = result.files.single.path);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
    */

    // Mock for now
    setState(() => _selectedFilePath = 'mock_document.pdf');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Mock file selected')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF132BB2), Color(0xFFFFFFFF)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: [0.0, 0.4],
                  ),
                ),
                child: Column(
                  children: [
                    // Back button
                    Align(
                      alignment: Alignment.topLeft,
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back,
                            color: Color(0xFFD7A61F)),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),

                    // Logo and Title
                    Column(
                      children: [
                        const SizedBox(height: 30),
                        Hero(
                          tag: 'app-logo',
                          child: Image.asset(
                            'assets/images/fulllogo.png',
                            width: MediaQuery.of(context).size.width * 0.5,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) =>
                                const Icon(Icons.account_circle, size: 100),
                          ),
                        ),
                        const SizedBox(height: 32),
                      ],
                    ),

                    const SizedBox(height: 40),

                    // Form Container
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          )
                        ],
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            Text(
                              'Organization Profile',
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontFamily: 'Jost',
                                color: const Color(0xFF071D99),
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 30),

                            // PDF Upload Section
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                'Upload Organization Documents',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF071D99),
                                  fontFamily: 'Jost',
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            GestureDetector(
                              onTap: _pickPDF,
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                      color: const Color(0xFF071D99)),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      _selectedFilePath != null
                                          ? Icons.check_circle
                                          : Icons.upload_file,
                                      color: const Color(0xFFD7A61F),
                                    ),
                                    const SizedBox(width: 10),
                                    Text(
                                      _selectedFilePath != null
                                          ? 'File Selected (Mock)'
                                          : 'Upload PDF (Mock)',
                                      style: const TextStyle(
                                        color: Color(0xFF071D99),
                                        fontFamily: 'Jost',
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            const SizedBox(height: 30),
                            const Divider(),
                            const SizedBox(height: 30),

                            // Email Field
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                'Moderator Email',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF071D99),
                                  fontFamily: 'Jost',
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            TextFormField(
                              controller: _emailController,
                              decoration: InputDecoration(
                                hintText: "Enter moderator's email",
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 14),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: const BorderSide(
                                      color: Color(0xFF071D99)),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Email is required';
                                }
                                if (!value.contains('@')) {
                                  return 'Enter a valid email address';
                                }
                                return null;
                              },
                            ),

                            const SizedBox(height: 40),

                            // Submit Button
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFD7A61F),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 50, vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                elevation: 3,
                              ),
                              onPressed: () {
                                if (_formKey.currentState!.validate()) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (_) => const OrgDashboard()),
                                  );
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text(
                                            'Please fill all required fields')),
                                  );
                                }
                              },
                              child: const Text(
                                'Submit for Verification',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.white,
                                  fontFamily: 'Jost',
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

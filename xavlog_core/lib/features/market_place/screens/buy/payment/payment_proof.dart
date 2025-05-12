import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:xavlog_core/features/market_place/models/product.dart';
import 'package:xavlog_core/features/market_place/services/login_authentication/authentication_gate.dart';

void navigateToPaymentProof(BuildContext context, Product product,
    String method, String qrCodeAsset, double qrSize) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => PaymentProofPage(
        product: product,
        method: method,
        qrCodeAsset: qrCodeAsset,
        qrSizeHeight: qrSize,
        qrSizeWidth: qrSize,
      ),
    ),
  );
}

class PaymentProofPage extends StatefulWidget {
  final Product product;
  final String method;
  final String qrCodeAsset;
  final double qrSizeHeight;
  final double qrSizeWidth;

  const PaymentProofPage({
    Key? key,
    required this.product,
    required this.method,
    required this.qrCodeAsset,
    required this.qrSizeHeight,
    required this.qrSizeWidth,
  }) : super(key: key);

  @override
  State<PaymentProofPage> createState() => _PaymentProofPageState();
}

class _PaymentProofPageState extends State<PaymentProofPage> {
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();
  String? _selectedProofType; // Start as null
  final TextEditingController _refController = TextEditingController();

  final List<String> _proofTypes = ['Reference Number', 'Upload Screenshot'];

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  @override
  void dispose() {
    _refController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Define your color palette clearly here:
    Color backgroundColor = Color(0xFFF6F8FA); // background
    Color primaryColor =
        Color(0xFF0D47A1); // <-- strong blue for important actions
    Color secondaryColor = Color(0xFF42A5F5); //  blue for less critical buttons
    Color textColor = Color(0xFF212121); //dark text
    Color cardColor = Colors.white; // <-- for cards/containers

    return Scaffold(
      backgroundColor: backgroundColor, // << background is softer
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: const Text('Submit Payment Proof',
            style: TextStyle(color: Colors.white)),
        iconTheme:
            const IconThemeData(color: Colors.white), // back button color
        centerTitle: true,
        elevation: 1,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- QR code or Chat Button Section ---
            Center(
              child: Column(
                children: [
                  if (widget.method != 'Pay Face-to-Face') ...[
                    Text(
                      "Scan Seller's QR Code",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(16),
                      child: Image.asset(
                        widget.qrCodeAsset,
                        height: widget.qrSizeHeight,
                        width: widget.qrSizeWidth,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ],
                  if (widget.method == 'Pay Face-to-Face') ...[
                    const SizedBox(height: 30),
                    Text(
                      "To get started, please chat with the seller to arrange the meeting for the face-to-face transaction.",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: textColor,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        AuthenticationGate();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Navigate to Chat!')),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            secondaryColor, // <-- lighter blue for chat
                        padding: const EdgeInsets.symmetric(
                            horizontal: 30, vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Start Chat',
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 30),

            // --- Payment Proof Selection Section ---
            if (widget.method != 'Pay Face-to-Face') ...[
              const Text(
                'Select Proof Type',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedProofType,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: cardColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
                hint: const Text('Choose proof method'),
                items: _proofTypes.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(type),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedProofType = value;
                    _imageFile = null;
                    _refController.clear();
                  });
                },
              ),
              const SizedBox(height: 20),
              if (_selectedProofType == 'Reference Number') ...[
                TextField(
                  controller: _refController,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: cardColor,
                    labelText: 'Reference Number',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ] else if (_selectedProofType == 'Upload Screenshot') ...[
                ElevatedButton.icon(
                  onPressed: _pickImage,
                  icon: const Icon(Icons.upload_file),
                  label: const Text('Pick Image from Gallery'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        secondaryColor, // <-- lighter blue for uploads
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                if (_imageFile != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(
                      _imageFile!,
                      height: 180,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
              ],
            ],

            const SizedBox(height: 30),

            // --- Submit Button Section ---
            if (widget.method != 'Pay Face-to-Face') ...[
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (_selectedProofType == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Please select a proof type')),
                      );
                      return;
                    }
                    if (_selectedProofType == 'Reference Number' &&
                        _refController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Please enter a reference number')),
                      );
                      return;
                    }
                    if (_selectedProofType == 'Upload Screenshot' &&
                        _imageFile == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Please upload a screenshot')),
                      );
                      return;
                    }

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content:
                              Text('Payment proof submitted successfully!')),
                    );
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Submit Payment Proof',
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

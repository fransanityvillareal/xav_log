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
  String? _selectedProofType;
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
    Color backgroundColor = const Color(0xFFF6F8FA);
    Color primaryColor = const Color(0xFF0D47A1);
    Color secondaryColor = const Color(0xFF42A5F5);
    Color textColor = const Color(0xFF212121);
    Color cardColor = Colors.white;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: const Text('Submit Payment Proof',
            style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
        elevation: 1,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
                        backgroundColor: secondaryColor,
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
                  fillColor: Colors.white, // dropdown field background white
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
                dropdownColor: Colors.white, // dropdown menu background white
                iconEnabledColor: textColor, // dropdown arrow color
                hint: const Text('Choose proof method'),
                items: _proofTypes.map((type) {
                  return DropdownMenuItem<String>(
                    value: type,
                    child: Text(
                      type,
                      style: TextStyle(color: textColor),
                    ),
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
                  icon: const Icon(Icons.upload_file,
                      size: 20, color: Color.fromARGB(255, 0, 0, 0)),
                  label: const Text(
                    'Pick Image from Gallery',
                    style: TextStyle(
                        fontSize: 16, color: Color.fromARGB(255, 0, 0, 0)),
                  ),
                  style: ButtonStyle(
                    backgroundColor:
                        MaterialStateProperty.resolveWith<Color>((states) {
                      if (states.contains(MaterialState.pressed)) {
                        return const Color.fromARGB(
                            255, 230, 230, 230); // darker gold when pressed
                      }
                      return const Color.fromARGB(
                          255, 255, 255, 255); // normal gold
                    }),
                    foregroundColor:
                        MaterialStateProperty.all<Color>(Colors.white),
                    padding: MaterialStateProperty.all<EdgeInsets>(
                        const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 12)),
                    shape: MaterialStateProperty.resolveWith<OutlinedBorder>(
                        (states) {
                      return RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: BorderSide(
                          color: states.contains(MaterialState.pressed)
                              ? Colors
                                  .blue.shade900 // darker blue border on press
                              : Colors.blue.shade700, // normal blue border
                          width: 2,
                        ),
                      );
                    }),
                    elevation: MaterialStateProperty.all<double>(0),
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
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          backgroundColor: cardColor,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16)),
                          title: Text(
                            'Success',
                            style: TextStyle(
                              color: primaryColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 22,
                            ),
                          ),
                          content: Text(
                            'Payment proof submitted successfully!',
                            style: TextStyle(
                              color: textColor,
                              fontSize: 16,
                            ),
                          ),
                          actions: [
                            TextButton(
                              style: TextButton.styleFrom(
                                backgroundColor: secondaryColor,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 24, vertical: 12),
                              ),
                              onPressed: () {
                                Navigator.of(context).pop(); // close dialog
                                Navigator.of(context)
                                    .pop(); // go back to previous screen
                              },
                              child: const Text(
                                'OK',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    );

                    // Show success popup dialog instead of SnackBar
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

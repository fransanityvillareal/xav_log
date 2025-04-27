import 'package:flutter/material.dart';
import 'package:xavlog_core/features/market_place/models/product.dart';
import 'package:xavlog_core/features/market_place/screens/buy/payment/payment_proof.dart';
import 'package:xavlog_core/features/market_place/services/login_authentication/authentication_gate.dart';

class BuyPage extends StatelessWidget {
  final Product product;

  const BuyPage({Key? key, required this.product}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = product.color.withOpacity(0.8);

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text('Buy ${product.title}'),
        backgroundColor: primaryColor,
        centerTitle: true,
        elevation: 2,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.title,
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "₱${product.price}",
                    style: TextStyle(
                      fontSize: 22,
                      color: Colors.green.shade700,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "Condition: ${product.condition}",
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // Payment Methods Section
            const Text(
              "Select Payment Method",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _paymentMethodTile(context, Icons.account_balance_wallet, "Maya",
                'assets/images/maya_qr.jpg', 400, 200),
            _paymentMethodTile(context, Icons.mobile_friendly, "GCash",
                'assets/images/gcash_qr.jpg', 300, 150),
            _paymentMethodTile(context, Icons.credit_card, "Credit/Debit Card",
                'assets/images/bdo_qr.jpg', 500, 250),
            _paymentMethodTile(context, Icons.handshake, "Pay Face-to-Face",
                'assets/images/face_to_face_qr.jpg', 350, 200),
          ],
        ),
      ),
    );
  }

  Widget _paymentMethodTile(BuildContext context, IconData icon, String method,
      String qrCodeAsset, double qrSizeHeight, double qrSizeWidth) {
    return InkWell(
      onTap: () {
        if (method == 'Pay Face-to-Face') {
          // Instead of navigating to PaymentProofPage, show a dialog for face-to-face payment
          _showFaceToFaceDialog(context);
        } else {
          // For other payment methods, navigate to PaymentProofPage as usual
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PaymentProofPage(
                product: product,
                method: method,
                qrCodeAsset: qrCodeAsset,
                qrSizeHeight: qrSizeHeight,
                qrSizeWidth: qrSizeWidth,
              ),
            ),
          );
        }
      },
      borderRadius: BorderRadius.circular(15),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, size: 28, color: Colors.black87),
            const SizedBox(width: 16),
            Text(
              method,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
            const Spacer(),
            const Icon(Icons.arrow_forward_ios, size: 18, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  void _showFaceToFaceDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Pay Face-to-Face'),
          content: Text(
              'To get started, please chat with the seller and meet in person to complete the payment process.'),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
            TextButton(
              child: Text('Okay'),
              onPressed: () {
                AuthenticationGate();

                Navigator.of(context).pop(); 
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        AuthenticationGate(), 
                    // ChatHomePage(),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }
}

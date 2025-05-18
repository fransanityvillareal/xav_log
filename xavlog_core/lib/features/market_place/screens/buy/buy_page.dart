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
        title: Text('Buy ${product.title}',
            style: const TextStyle(fontWeight: FontWeight.w600)),
        backgroundColor: primaryColor,
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Card
            _productCard(context),

            const SizedBox(height: 30),

            // Payment Methods Title
            const Text(
              "Select Payment Method",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 20),

            // Payment Options
            _paymentMethodTile(context, Icons.account_balance_wallet, "Maya",
                'assets/images/maya_qr.jpg', 400, 400),
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

  Widget _productCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 12,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            product.title,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            "₱${product.price}",
            style: TextStyle(
              fontFamily: 'Rubik',
              fontSize: 24,
              color: Colors.green.shade700,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Condition: ${product.condition}",
            style: const TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _paymentMethodTile(
    BuildContext context,
    IconData icon,
    String method,
    String qrCodeAsset,
    double qrSizeHeight,
    double qrSizeWidth,
  ) {
    return GestureDetector(
      onTap: () {
        if (method == 'Pay Face-to-Face') {
          _showFaceToFaceDialog(context);
        } else {
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
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, size: 28, color: Colors.blueGrey),
            const SizedBox(width: 20),
            Expanded(
              child: Text(
                method,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded,
                size: 20, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  void _showFaceToFaceDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          backgroundColor: Colors.white, // dialog background
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Face-to-Face Payment Icon
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.handshake,
                    size: 60,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(height: 20),

                // Title of the Dialog
                const Text(
                  'Pay Face-to-Face',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),

                // Description of the Payment Process
                const Text(
                  'To get started, please chat with the seller and meet in person to complete the payment process.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.black54),
                ),
                const SizedBox(height: 24),

                // Action buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // Cancel Button
                    TextButton(
                      child: const Text('Cancel'),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    const SizedBox(width: 12),

                    // Okay Button
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AuthenticationGate(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 12),
                      ),
                      child: const Text(
                        'Okay',
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

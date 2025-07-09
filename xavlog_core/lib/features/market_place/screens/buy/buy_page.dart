import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:xavlog_core/features/market_place/models/product.dart';
import 'package:xavlog_core/features/market_place/screens/buy/payment/payment_proof.dart';
import 'package:xavlog_core/features/market_place/screens/chat/chat_home_page.dart';

class BuyPage extends StatelessWidget {
  final Product product;

  const BuyPage({Key? key, required this.product}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    product.color.withOpacity(0.8);

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Custom AppBar with centered title
              SizedBox(
                height: 56,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                    const Center(
                      child: Text(
                        'Item Checkout',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: Color.fromARGB(255, 75, 75, 75),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Product Card
              _productCard(context),

              const SizedBox(height: 45),

              // Payment Methods Title
              const Text(
                "Payment Method",
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
              _paymentMethodTile(context, Icons.credit_card,
                  "Credit/Debit Card", 'assets/images/bdo_qr.jpg', 500, 250),
              _paymentMethodTile(context, Icons.handshake, "Cash",
                  'assets/images/face_to_face_qr.jpg', 350, 200),
            ],
          ),
        ),
      ),
    );
  }

  Widget _productCard(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 70,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 12,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              product.image,
              width: 60,
              height: 60,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) =>
                  const Icon(Icons.image_not_supported),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    product.title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  NumberFormat.currency(locale: 'en_PH', symbol: 'P ')
                          .format(product.price),
                  style: const TextStyle(
                    fontFamily: 'Jost',
                    fontSize: 15,
                    color: Color(0xFF071D99),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
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
        if (method == 'Cash') {
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
          borderRadius: BorderRadius.circular(12),
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
            const Icon(Icons.circle, size: 0), // placeholder
            Icon(icon, size: 28, color: Color(0xFFD7A61F)), // gold color
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
          backgroundColor: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
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
                const Text(
                  'Cash',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'To get started, please chat with the seller and meet in person to complete the payment process.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.black54),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      child: const Text('Cancel'),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ChatHomePage(),
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

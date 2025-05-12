import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/product.dart';
import '../../providers/product_provider.dart';

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
  void _submit() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      // Creating a new product object
      final newProduct = Product(
        id: DateTime.now().millisecondsSinceEpoch, // Simple unique id
        image: _image.isNotEmpty ? _image : 'assets/images/item_1.png',
        title: _title,
        price: _price,
        description: _description,
        condition: _condition.isNotEmpty ? _condition : 'Used',
        color: Colors.grey, // Default color
        category: _category.isNotEmpty ? _category : 'Others',
      );

      // Add product to the provider
      Provider.of<ProductProvider>(context, listen: false)
          .addProduct(newProduct);

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

              // a place holder for image
              _buildTextFormField(
                label: 'Image Asset Path (optional)',
                icon: Icons.image,
                onSaved: (value) => _image = value ?? '',
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
                    'Books',
                    'PE Equipment',
                    'Accessories',
                    'Tech',
                    'Shirt',
                    'Others',
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

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:xavlog_core/features/market_place/models/product.dart';
import 'package:xavlog_core/features/market_place/providers/product_provider.dart';
import 'package:xavlog_core/features/market_place/screens/details/details_screen.dart';

const double kDefaultPadding = 16.0;

class Body extends StatefulWidget {
  final int initialIndex;

  const Body({super.key, this.initialIndex = 0});

  @override
  BodyState createState() => BodyState();
}

class BodyState extends State<Body> {
  late int selectedIndex;

  @override
  void initState() {
    super.initState();
    selectedIndex = widget.initialIndex;
  }

  final List<String> categories = [
    'Stationery',
    'Equipment',
    'Clothing',
    'Technology',
    'Accessories',
    'Others'
  ];

  @override
  Widget build(BuildContext context) {
    final productProvider = context.watch<ProductProvider>();
    List<Product> filteredProducts = productProvider.products.where((product) {
      return product.category == categories[selectedIndex];
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
            padding: const EdgeInsets.symmetric(horizontal: kDefaultPadding),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              SizedBox(height: 12),
              Text(
                'Campus Marketplace',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 0, 0, 0),
                    fontSize: 25),
              ),
            ])),
        const SizedBox(height: 10),
        Category(
          categories: categories,
          selectedIndex: selectedIndex,
          onCategorySelected: (index) {
            setState(() {
              selectedIndex = index;
            });
          },
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: kDefaultPadding),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final crossAxisCount = constraints.maxWidth < 600
                    ? 2
                    : 3; // Adjust columns based on width
                final childAspectRatio = constraints.maxWidth < 600
                    ? 0.65
                    : 0.75; // Adjust aspect ratio
                final crossAxisSpacing = constraints.maxWidth < 600
                    ? kDefaultPadding
                    : kDefaultPadding / 2; // Reduce spacing for larger screens
                final mainAxisSpacing = constraints.maxWidth < 600
                    ? kDefaultPadding
                    : kDefaultPadding / 2; // Reduce spacing for larger screens

                return GridView.builder(
                  itemCount: filteredProducts.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    childAspectRatio: childAspectRatio,
                    crossAxisSpacing: crossAxisSpacing,
                    mainAxisSpacing: mainAxisSpacing,
                  ),
                  itemBuilder: (context, index) => ItemCard(
                    key: ValueKey(filteredProducts[index].id),
                    product: filteredProducts[index],
                    press: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => DetailsScreen(
                          product: filteredProducts[index],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

class ItemCard extends StatelessWidget {
  final Product product;
  final VoidCallback press;

  const ItemCard({
    required Key key,
    required this.product,
    required this.press,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final currencyFormatter =
        NumberFormat.currency(locale: 'en_PH', symbol: 'P ');

    return GestureDetector(
      onTap: press,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(kDefaultPadding),
            height: 165,
            width: 165,
            decoration: BoxDecoration(
              color: product.color,
              borderRadius: BorderRadius.circular(16),
            ),
            child: product.image.isNotEmpty
                ? Image.network(
                    product.image,
                    fit: BoxFit.cover,
                  )
                : const Icon(Icons.image, size: 50),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: kDefaultPadding / 4),
            child: Text(
              product.title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 19,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              currencyFormatter.format(product.price),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Color.fromARGB(255, 17, 5, 152),
                fontSize: 17,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class Category extends StatefulWidget {
  final List<String> categories;
  final int selectedIndex;
  final Function(int) onCategorySelected;

  const Category({
    required this.categories,
    required this.selectedIndex,
    required this.onCategorySelected,
    super.key,
  });

  @override
  State<Category> createState() => _CategoryState();
}

class _CategoryState extends State<Category> {
  final ScrollController _scrollController = ScrollController();

  @override
  void didUpdateWidget(covariant Category oldWidget) {
    super.didUpdateWidget(oldWidget);

    // If selected index changed, scroll to it
    if (widget.selectedIndex != oldWidget.selectedIndex) {
      _scrollToSelected();
    }
  }

  @override
  void initState() {
    super.initState();
    // Delay scroll until after layout is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToSelected();
    });
  }

  void _scrollToSelected() {
    // Estimate item width + padding: 80 is safe
    double targetOffset = widget.selectedIndex * 80.0;

    _scrollController.animateTo(
      targetOffset,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: kDefaultPadding),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        controller: _scrollController,
        child: Row(
          children: List.generate(
            widget.categories.length,
            (index) => buildCategory(index),
          ),
        ),
      ),
    );
  }

  Widget buildCategory(int index) {
    final bool isSelected = widget.selectedIndex == index;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: kDefaultPadding),
      child: GestureDetector(
        onTap: () => widget.onCategorySelected(index),
        child: Column(
          children: [
            Text(
              widget.categories[index],
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: isSelected
                    ? Color.fromARGB(255, 14, 0, 174)
                    : const Color.fromARGB(255, 74, 74, 74),
              ),
            ),
            Container(
              margin: const EdgeInsets.only(top: kDefaultPadding / 4),
              height: 2,
              width: 30,
              color: isSelected
                  ? Color.fromARGB(255, 0, 0, 0)
                  : Colors.transparent,
            ),
          ],
        ),
      ),
    );
  }
}

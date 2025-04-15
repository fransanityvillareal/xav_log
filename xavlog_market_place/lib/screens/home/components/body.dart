import 'package:flutter/material.dart';
import 'package:xavlog_market_place/constants.dart';
import 'package:xavlog_market_place/models/product.dart';
import 'package:xavlog_market_place/screens/details/details_screen.dart';


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
    'Books',
    'PE Equipment',
    'Shirt',
    'Tech',
    'Accessories',
    'Others'
  ];
  

  @override
  Widget build(BuildContext context) {
    List<Product> filteredProducts = products.where((product) {
      return product.category == categories[selectedIndex];
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: kDefaultPadding),
          child: Text(
            'Market Place',
            style: Theme.of(context)
                .textTheme
                .headlineSmall
                ?.copyWith(fontWeight: FontWeight.bold,
                color: Color(0xFF071D99)),
          ),
        ),
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
            child: GridView.builder(
              itemCount: filteredProducts.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.75,
                crossAxisSpacing: kDefaultPadding,
                mainAxisSpacing: kDefaultPadding,
              ),
              itemBuilder: (context, index) => ItemCard(
                key: ValueKey(filteredProducts[index].id),
                product: filteredProducts[index],
                press: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DetailsScreen(
                      product: filteredProducts[index],
                    ),
                  ),
                ),
              ),
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
    return GestureDetector(
      onTap: press,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(kDefaultPadding),
            height: 180,
            width: 168,
            decoration: BoxDecoration(
              color: product.color,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Image.asset(product.image),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: kDefaultPadding / 4),
            child: Text(
              product.title,
              style: const TextStyle(color: Colors.black),
            ),
          ),
          Text(
            '\$${product.price}',
            style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF007F5F)),
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: kDefaultPadding),
      child: GestureDetector(
        onTap: () => widget.onCategorySelected(index),
        child: Column(
          children: [
            Text(
              widget.categories[index],
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: widget.selectedIndex == index
                    ? const Color.fromARGB(255, 0, 0, 0)
                    : const Color(0xFF6F6F79),
              ),
            ),
            Container(
              margin: const EdgeInsets.only(top: kDefaultPadding / 4),
              height: 2,
              width: 30,
              color: widget.selectedIndex == index
                  ? kNavActiveColor
                  : Colors.transparent,
            ),
          ],
        ),
      ),
    );
  }
}

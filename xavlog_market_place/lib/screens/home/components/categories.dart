import 'package:flutter/material.dart';

const double kDefaultPadding = 16.0;

class Body extends StatelessWidget {
  const Body({super.key});
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,  // Keeps text aligned to the left
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: kDefaultPadding),
          child: Text(
            'Market Place',
            style: Theme.of(context)
                .textTheme
                .headlineSmall
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
        SizedBox(height: 10), // Spacing between title and categories
        Category(),
      ],
    );
  }
}

class Category extends StatefulWidget {
  const Category({super.key});

  @override
  CategoryState createState() => CategoryState();
}

class CategoryState extends State<Category> {
  List<String> categories = ['Books', 'PE Equipment', 'Shirt', 'Tech', 'Accessories'];
  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: kDefaultPadding),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,  // Prevents horizontal overflow
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,  // Aligns text properly
          children: List.generate(categories.length, (index) => buildCategory(index)),
        ),
      ),
    );
  }

  Widget buildCategory(int index) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: kDefaultPadding),
      child: GestureDetector(
        onTap: () {
          setState(() {
            selectedIndex = index;
          });
        },
        child: Column(
          children: [
            Text(
              categories[index],
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: selectedIndex == index ? Colors.blueAccent:Colors.black,
              ),
            ),
            Container(
              margin: EdgeInsets.only(top: kDefaultPadding / 4),
              height: 2,
              width: 30,
              color: selectedIndex == index ? Colors.blueAccent:Colors.transparent,
            ),
          ],
        ),
      ),
    );
  }
}
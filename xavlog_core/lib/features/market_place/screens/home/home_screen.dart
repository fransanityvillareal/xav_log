import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:xavlog_core/constants.dart';
import 'package:xavlog_core/features/market_place/screens/cart/cart_screen.dart';
import 'package:xavlog_core/features/market_place/screens/home/components/body.dart';
import 'package:xavlog_core/features/market_place/screens/search/search_screen.dart';


class HomeScreen extends StatefulWidget {
  final int initialCategoryIndex;

  const HomeScreen({super.key, this.initialCategoryIndex = 0});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: SvgPicture.asset("assets/icons/back.svg"),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: SvgPicture.asset(
              "assets/icons/search.svg",
              colorFilter: const ColorFilter.mode(kTextColor, BlendMode.srcIn),
            ),
            onPressed: () {
              showSearch(context: context, delegate: ProductSearchDelegate());
            },
          ),
          IconButton(
            icon: SvgPicture.asset(
              "assets/icons/cart.svg",
              colorFilter: const ColorFilter.mode(kTextColor, BlendMode.srcIn),
            ),
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const CartScreen()));
            },
          ),
          const SizedBox(width: kDefaultPaddin / 2),
        ],
      ),
      body: Body(initialIndex: widget.initialCategoryIndex),
    );
  }
}

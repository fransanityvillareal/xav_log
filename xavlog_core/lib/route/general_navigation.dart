import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';

class MainScaffold extends StatefulWidget {
  final List<Widget> screens;
  final int initialIndex;

  const MainScaffold({
    super.key,
    required this.screens,
    this.initialIndex = 2,
  });

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  late int _page;

  // Minimalist palette inspired by Ateneo colors
  static const Color softBlue = Color(0xFF26338B);
  static const Color softGold = Color(0xFFF8D65C);

  @override
  void initState() {
    super.initState();
    _page = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: widget.screens[_page],
      bottomNavigationBar: CurvedNavigationBar(
        height: 65,
        index: _page,
        backgroundColor: Colors.white,
        color: softBlue,
        buttonBackgroundColor: softGold,
        animationDuration: const Duration(milliseconds: 350),
        items: const [
          Icon(Icons.bar_chart_sharp, size: 25, color: Colors.white),
          Icon(Icons.chat_sharp, size: 25, color: Colors.white),
          Icon(Icons.home_sharp, size: 25, color: Colors.white),
          Icon(Icons.storefront_sharp, size: 25, color: Colors.white),
          Icon(Icons.account_circle_sharp, size: 25, color: Colors.white),
        ],
        onTap: (index) {
          setState(() {
            _page = index;
          });
        },
      ),
    );
  }
}

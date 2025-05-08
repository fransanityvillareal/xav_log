import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';

class MainScaffold extends StatefulWidget {
  final List<Widget> screens;
  final int initialIndex;

  const MainScaffold({
    super.key,
    required this.screens,
    this.initialIndex = 0,
  });

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  late int _page;

  // Minimalist palette inspired by Ateneo colors
  static const Color softBlue = Color(0xFF1E2A78); 
  static const Color softGold = Color(0xFFF4D35E); 

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
        index: _page,
        backgroundColor: Colors.white,
        color: softBlue,
        buttonBackgroundColor: softGold,
        animationDuration: const Duration(milliseconds: 300),
        items: const [
          Icon(Icons.home, size: 28, color: Colors.white),
          Icon(Icons.bar_chart, size: 28, color: Colors.white),
          Icon(Icons.event, size: 28, color: Colors.white),
          Icon(Icons.storefront, size: 28, color: Colors.white),
          Icon(Icons.account_circle, size: 28, color: Colors.white),
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

import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:xavlog_core/features/market_place/models/product.dart';
import 'package:xavlog_core/features/market_place/providers/product_provider.dart'
    show ProductProvider;
import 'package:xavlog_core/features/market_place/screens/cart/cart_provider.dart';
import 'package:xavlog_core/features/market_place/screens/home/home_screen.dart';
import 'package:provider/provider.dart';
import 'dart:async';

import 'package:xavlog_core/features/market_place/screens/seller/seller_dashboard_screen.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => CartProvider()),
        ChangeNotifierProvider(
            create: (context) => ProductProvider(products)), // Add this line
      ],
      child: MaterialApp(
        home: HomeWidget(),
        debugShowCheckedModeBanner: false,
      ),
    ),
  );
}
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _page = 0;

  final List<Widget> _pages = [
    HomeWidget(),
    SellerDashboardScreen(),
    Placeholder(), // Replace with Message screen
    Placeholder(), // Replace with Notifications screen
    Placeholder(), // Replace with Profile screen
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: CurvedNavigationBar(
        backgroundColor: Colors.transparent,
        buttonBackgroundColor: Colors.green,
        color: Colors.green,
        animationDuration: const Duration(milliseconds: 300),
        items: const <Widget>[
          Icon(Icons.home, size: 26, color: Colors.white),
          Icon(Icons.message, size: 26, color: Colors.white),
          Icon(Icons.add, size: 26, color: Colors.white),
          Icon(Icons.notifications, size: 26, color: Colors.white),
          Icon(Icons.person, size: 26, color: Colors.white),
        ],
        onTap: (index) {
          setState(() {
            _page = index;
          });
        },
      ),
      body: _pages[_page],
    );
  }
}

class AutoScrollHeader extends StatefulWidget {
  @override
  _AutoScrollHeaderState createState() => _AutoScrollHeaderState();
}

class _AutoScrollHeaderState extends State<AutoScrollHeader> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<String> messages = [
    'Welcome to Xavalog. The Ateneo Marketplace at your fingertips.',
    'Flexible transactions. Online or cash, you choose.',
    'Pick up items safely at Ateneo de Naga, hassle-free.',
  ];

  final List<String> greetings = [
    'Hello there!',
    'Easy!',
    'Secure!',
  ];

  // Corresponding screens for each banner
  final List<Widget> screens = [
    SellerDashboardScreen(),
    SellerDashboardScreen(),
    SellerDashboardScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _startAutoScroll();
  }

  void _startAutoScroll() {
    Future.delayed(const Duration(seconds: 3), () {
      if (!mounted) return;
      setState(() {
        _currentPage = (_currentPage + 1) % messages.length;
        _pageController.animateToPage(
          _currentPage,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      });
      _startAutoScroll();
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 160,
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => screens[_currentPage]),
          );
        },
        child: PageView.builder(
          controller: _pageController,
          itemCount: messages.length,
          itemBuilder: (context, index) {
            return Card(
              color: const Color(0xFFFFD700), // Gold color for Xavalog
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: ListTile(
                  title: Text(
                    greetings[index],
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E3A8A), // Xavalog Blue
                    ),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      messages[index],
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class HomeWidget extends StatefulWidget {
  const HomeWidget({super.key});

  @override
  State<HomeWidget> createState() => _HomeWidgetState();
}

class _HomeWidgetState extends State<HomeWidget> {
  String selected = 'Delivery';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SizedBox(
          width: double.infinity,
          height: double.infinity,
          child: Stack(
            alignment: AlignmentDirectional(1, -1),
            children: [
              SizedBox(
                width: double.infinity,
                height: double.infinity,
                child: Column(
                  children: [
                    Flexible(
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            // _buildHeader(),

                            AutoScrollHeader(),
                            _buildSectionTitle('Categories'),
                            _buildMainCategoryButtons(),
                            _buildSecondaryCategoryButtons(),
                            _buildSectionTitle('Place'),
                            _buildFeaturedContent(
                                'assets/images/place.jpg',
                                'Ateneo De Naga',
                                Text(
                                    'Pick up your products securely and conveniently at Ateneo de Naga University. Enjoy a flexible, face-to-face transaction experience right on campus.')),
                            _buildSectionTitle('Transactions'),
                            _buildFeaturedContent(
                                'assets/images/transactions.jpg',
                                'Flexible Transactions',
                                Text(
                                    'Pay your way! cash or online, whatever works best for you. With Xavalog, transactions are always secure and flexible.')),
                          ]
                              .map((widget) => Padding(
                                    padding: EdgeInsets.only(bottom: 24),
                                    child: widget,
                                  ))
                              .toList(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.fromLTRB(16, 16, 0, 0),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color.fromARGB(255, 0, 0, 0),
          ),
        ),
      ),
    );
  }

  Widget _buildMainCategoryButtons() {
    return Padding(
      padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment
            .spaceBetween, // Ensures even spacing between buttons
        children: [
          Expanded(
            child: _buildCategoryButton(
              'PE Equipment',
              'assets/images/sport.png',
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          HomeScreen(initialCategoryIndex: 1)),
                );
              },
            ),
          ),
          SizedBox(width: 12), // Adds spacing between buttons
          Expanded(
            child: _buildCategoryButton('Books', 'assets/images/book.png', () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => HomeScreen(initialCategoryIndex: 0)),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryButton(
      String text, String assetPath, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white, // Background color of the button
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ], // Add shadow here
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Image.asset(
                    assetPath,
                    width: 50,
                    height: 45,
                    fit: BoxFit.cover,
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(text, style: TextStyle(fontSize: 17)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSmallCategoryButton(
      String text, String assetPath, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 65,
            height: 65,
            decoration: BoxDecoration(
              color: Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Image.asset(assetPath, fit: BoxFit.contain),
            ),
          ),
          SizedBox(height: 8),
          Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildSecondaryCategoryButtons() {
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              SizedBox(width: 20),
              _buildSmallCategoryButton('Shirt', 'assets/images/shirts.png',
                  () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => HomeScreen(initialCategoryIndex: 2),
                  ),
                );
              }),
              SizedBox(width: 20),
              _buildSmallCategoryButton('Tech', 'assets/images/tech.png', () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          HomeScreen(initialCategoryIndex: 3)),
                );
              }),
              SizedBox(width: 20),
              _buildSmallCategoryButton(
                  'Accessories', 'assets/images/accessories.png', () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          HomeScreen(initialCategoryIndex: 4)),
                );
              }),
              SizedBox(width: 20),
              _buildSmallCategoryButton('Others', 'assets/images/more.png', () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          HomeScreen(initialCategoryIndex: 5)),
                );
              }),
              SizedBox(width: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeaturedContent(
      String assetPath, String title, Text description) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          Stack(
            alignment: AlignmentDirectional(1, -1),
            children: [
              Image.asset(
                assetPath,
                width: double.infinity,
                height: 155,
                fit: BoxFit.cover,
              ),
              Padding(
                padding: EdgeInsets.only(top: 16, right: 16),
              ),
            ],
          ),
          SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(68),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  title,
                  style: TextStyle(fontSize: 17),
                ),
                SizedBox(height: 8),
                Row(
                  children: [
                    Flexible(
                      child: description,
                    ),
                    SizedBox(width: 8),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
// Widget _buildHeader() {
//   return Container(
//     width: double.infinity,
//     margin: EdgeInsets.fromLTRB(10, 20, 10, 0),
//     padding: EdgeInsets.all(20),
//     decoration: BoxDecoration(
//       gradient: LinearGradient(
//         colors: [
//           Color(0xFF1E3C72),
//           Color(0xFF2A5298)
//         ], // modern blue gradient
//         begin: Alignment.topLeft,
//         end: Alignment.bottomRight,
//       ),
//       borderRadius: BorderRadius.circular(16),
//       boxShadow: [
//         BoxShadow(
//           color: Colors.black12,
//           blurRadius: 8,
//           offset: Offset(0, 4),
//         ),
//       ],
//     ),
//     child: Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           'Hi there! 👋',
//           style: TextStyle(
//             color: Colors.white,
//             fontSize: 24,
//             fontWeight: FontWeight.bold,
//             letterSpacing: 0.5,
//           ),
//         ),
//         SizedBox(height: 6),
//         Text(
//           'Welcome to Xavalog – the Ateneo Marketplace at your fingertips.',
//           style: TextStyle(
//             color: Colors.white.withAlpha((0.9 * 255).toInt()),
//             fontSize: 15.5,
//           ),
//         ),
//       ],
//     ),
//   );
// }

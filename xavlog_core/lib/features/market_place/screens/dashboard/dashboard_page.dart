import 'package:flutter/material.dart';
import 'package:xavlog_core/features/market_place/screens/home/home_screen.dart';
import 'dart:async';
import 'package:url_launcher/url_launcher.dart';
import 'package:xavlog_core/features/market_place/screens/seller/seller_dashboard_screen.dart';
import 'package:xavlog_core/features/market_place/screens/chat/chat_home_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return HomeWidget(); // Only show the main marketplace content
  }
}

class AutoScrollHeader extends StatefulWidget {
  const AutoScrollHeader({super.key});

  @override
  _AutoScrollHeaderState createState() => _AutoScrollHeaderState();
}

class _AutoScrollHeaderState extends State<AutoScrollHeader> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<String> messages = [
    'Tap here to start selling your items on Xavalog today!',
    'Looking to buy? Click now and discover great deals!',
    'See something you like? Chat now to make a deal!',
  ];

  final List<String> greetings = [
    'Sell Items!',
    'Browse Items!',
    'Chat Now!',
  ];

  // Corresponding icons for each message
  final List<IconData> actionIcons = [
    Icons.local_grocery_store_sharp, // Sell Items
    Icons.search_sharp, // Browse Items
    Icons.chat_bubble_outline_sharp, // Chat Now
  ];

  // Corresponding screens for each banner
  final List<Widget> screens = [
    SellerDashboardScreen(),
    HomeScreen(),
    ChatHomePage(),
  ];

  @override
  void initState() {
    super.initState();
    _startAutoScroll();
  }

  void _startAutoScroll() {
    Future.delayed(const Duration(seconds: 3), () {
      if (!mounted ||
          _pageController.hasClients && _pageController.page != _currentPage)
        return; // Stop auto-scroll if user interacts
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
          if (_currentPage < screens.length) {
            // Ensure valid index
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => screens[_currentPage]),
            );
          }
        },
        onPanDown: (_) => _pageController
            .jumpToPage(_currentPage), // Stop auto-scroll on user interaction
        child: PageView.builder(
          controller: _pageController,
          itemCount: messages.length,
          onPageChanged: (index) {
            setState(() {
              _currentPage = index;
            });
          },
          itemBuilder: (context, index) {
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF071D99).withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFFFFD700), // Ateneo Gold
                    Color(0xFFFFE066), // Lightened Gold
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Row(
                  children: [
                    Icon(
                      actionIcons[index], // Dynamic icon
                      size: 32,
                      color: const Color(0xFF1E3A8A), // Ateneo Blue
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            greetings[index],
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1E3A8A),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            messages[index],
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
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
      backgroundColor: Colors.white,
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
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AutoScrollHeader(),

                            SizedBox(height: 12),

                            _buildSectionTitle('Categories'),

                            _buildCategoryBar(),

                            SizedBox(height: 24), // Space between sections

                            _buildSectionTitle('Ateneo de Naga University'),
                            SizedBox(
                                height: 8), // Space between title and content
                            _buildFeaturedContent(
                              'assets/images/place.jpg',
                              null,
                              Text(
                                'Pick up your products securely and conveniently at Ateneo de Naga University. Enjoy a flexible, face-to-face transaction experience right on campus.',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontFamily: 'Jost',
                                ),
                              ),
                              index: 0,
                            ),

                            SizedBox(height: 24),

                            _buildSectionTitle('Flexible Transactions'),
                            SizedBox(height: 8),
                            _buildFeaturedContent(
                              'assets/images/transactions.jpg',
                              null,
                              Text(
                                'Pay your way! cash or online, whatever works best for you. With Xavalog, transactions are always secure and flexible.',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontFamily: 'Jost',
                                ),
                              ),
                              index: 1,
                            ),

                            SizedBox(height: 24),

                            _buildSectionTitle('Ateneans Buy and Sell'),
                            SizedBox(height: 8),
                            _buildFeaturedContent(
                              'assets/images/buying.jpg',
                              null,
                              Text(
                                'Buy and sell anything new or pre-loved with fellow Ateneans. Easy deals, flexible payments, and a trusted Ateneo community.',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontFamily: 'Jost',
                                ),
                              ),
                              index: 3,
                            ),

                            SizedBox(height: 24),
                          ],
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
        margin: EdgeInsets.fromLTRB(16, 16, 0, 4),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.bold,
            color: Color.fromARGB(255, 0, 0, 0),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryBar() {
    return SizedBox(
      height: 150, // ⬅️ Increased height to give room for shadow visibility
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: BouncingScrollPhysics(),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center, // optional
            children: [
              _buildCategoryItem('Stationery', 'assets/images/book.png', () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => HomeScreen(initialCategoryIndex: 0),
                  ),
                );
              }),
              _buildCategoryItem('Equipment', 'assets/images/sport.png', () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => HomeScreen(initialCategoryIndex: 1),
                  ),
                );
              }),
              _buildCategoryItem('Clothing', 'assets/images/shirts.png', () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => HomeScreen(initialCategoryIndex: 2),
                  ),
                );
              }),
              _buildCategoryItem('Technology', 'assets/images/tech.png', () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => HomeScreen(initialCategoryIndex: 3),
                  ),
                );
              }),
              _buildCategoryItem('Accessories', 'assets/images/accessories.png',
                  () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => HomeScreen(initialCategoryIndex: 4),
                  ),
                );
              }),
              _buildCategoryItem('Others', 'assets/images/more.png', () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => HomeScreen(initialCategoryIndex: 5),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryItem(String text, String assetPath, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 100,
        height: 100,
        margin: EdgeInsets.symmetric(
            horizontal: 8,
            vertical:
                4), // 👈 vertical margin gives room for shadow - AI ito noh - gian
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: const Color.fromARGB(38, 0, 0, 0),
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              assetPath,
              width: 50,
              height: 50,
              fit: BoxFit.contain,
            ),
            SizedBox(height: 8),
            Text(
              text,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeaturedContent(
    String assetPath,
    String? title,
    Text description, {
    required int index,
  }) {
    final Uri streetViewUri = Uri.parse(
      'https://www.google.com/maps/@13.630323,123.1851484,3a,90y,12.57h,89.88t/data=!3m7!1e1!3m5!1sCIHM0ogKEICAgICpzOfmkwE!2e10!6shttps:%2F%2Flh3.googleusercontent.com%2Fgpms-cs-s%2FAB8u6HYlEiHQW-0I04qkGSwIs--hqp0S9Z7mZ28O7hNCvSo3zhNipEmmyOFLk-E7CHE6OfsEFZViLtqLNz2qN8Bmqmi_31SZntJa_haa14jtc_YVSFzD8psMuvU91DSxXTgT-BIO_rZOfQ%3Dw900-h600-k-no-pi0.11886842302389766-ya12.567076750166581-ro0-fo100!7i6080!8i3040?entry=ttu&g_ep=EgoyMDI1MDUwNy4wIKXMDSoASAFQAw%3D%3D',
    );

    void handleTap(BuildContext context) async {
      if (index == 0) {
        try {
          final launched = await launchUrl(
            streetViewUri,
            mode: LaunchMode.externalApplication,
          );
          if (!launched) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Could not open Street View.")),
            );
          }
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Error: $e")),
          );
        }
      } else {
        showDialog(
          context: context,
          builder: (_) => Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: const EdgeInsets.all(10),
            child: GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: InteractiveViewer(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(
                    assetPath,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
          ),
        );
      }
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          GestureDetector(
            onTap: () => handleTap(context),
            child: Stack(
              alignment: const AlignmentDirectional(1, -1),
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(
                    assetPath,
                    width: double.infinity,
                    height: 155,
                    fit: BoxFit.cover,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(68),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (title != null && title.isNotEmpty)
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                if (title != null && title.isNotEmpty)
                  const SizedBox(height: 8),
                Row(
                  children: [
                    Flexible(child: description),
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

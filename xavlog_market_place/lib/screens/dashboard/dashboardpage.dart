import 'package:flutter/material.dart';
import 'package:xavlog_market_place/screens/home/home_screen.dart';
import 'package:provider/provider.dart';
import 'package:xavlog_market_place/screens/cart/cart_provider.dart';
import 'dart:async';
import 'package:xavlog_market_place/screens/home/components/body.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => CartProvider()),
      ],
      child: MaterialApp(
        home: HomeWidget(),
        debugShowCheckedModeBanner: false,
      ),
    ),
  );
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

  @override
  void initState() {
    super.initState();
    Timer.periodic(Duration(seconds: 5), (Timer timer) {
      if (_currentPage < messages.length - 1) {
        _currentPage++;
      } else {
        _currentPage = 0;
      }

      _pageController.animateToPage(
        _currentPage,
        duration: Duration(milliseconds: 900),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 130,
      margin: EdgeInsets.fromLTRB(10, 20, 10, 0),
      child: PageView.builder(
        controller: _pageController,
        itemCount: messages.length,
        itemBuilder: (context, index) {
          return Container(
            margin: EdgeInsets.symmetric(horizontal: 6),
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF1E3C72), Color(0xFF2A5298)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 8,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  greetings[index],
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  messages[index],
                  style: TextStyle(
                    color: Colors.white.withAlpha((0.9 * 255).toInt()),
                    fontSize: 14.5,
                  ),
                ),
              ],
            ),
          );
        },
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
                    _buildBottomNavBar(),
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
                MaterialPageRoute(builder: (context) => HomeScreen(initialCategoryIndex: 1,)),
              );
            },
          )),
          SizedBox(width: 12), // Adds spacing between buttons
          Expanded(
            child: _buildCategoryButton('Books', 'assets/images/book.png', () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => HomeScreen(initialCategoryIndex: 0 )),
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
          color: Colors.white, //dito
          borderRadius: BorderRadius.circular(8),
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
                  MaterialPageRoute(builder: (context) => HomeScreen(initialCategoryIndex: 3)),
                );
              }),
              SizedBox(width: 20),
              _buildSmallCategoryButton(
                  'Accessories', 'assets/images/accessories.png', () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => HomeScreen(initialCategoryIndex: 4)),
                );
              }),
              SizedBox(width: 20),
              _buildSmallCategoryButton('Others', 'assets/images/more.png', () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => HomeScreen(initialCategoryIndex: 5)),
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

  Widget _buildBottomNavBar() {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey[300]!)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          IconButton(icon: Icon(Icons.home), onPressed: () {}),
          IconButton(icon: Icon(Icons.search), onPressed: () {}),
          IconButton(icon: Icon(Icons.shopping_bag), onPressed: () {}),
          IconButton(icon: Icon(Icons.person), onPressed: () {}),
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
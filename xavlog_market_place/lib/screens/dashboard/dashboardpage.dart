import 'package:flutter/material.dart';
import 'package:xavlog_market_place/screens/home/home_screen.dart';
import 'package:provider/provider.dart';
import 'package:xavlog_market_place/screens/cart/cart_provider.dart';

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
                            _buildHeader(),
                            _buildSectionTitle('Categories'),
                            _buildMainCategoryButtons(),
                            _buildSecondaryCategoryButtons(),
                            _buildSectionTitle('Place'),
                            _buildFeaturedContent(),
                            _buildFeaturedContent(),

                            // _buildOrderItemsList(),
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

  Widget _buildDeliveryOption(String text) {
    return GestureDetector(
      onTap: () => setState(() => selected = text),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: selected == text ? Colors.blue : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: selected == text ? Colors.white : Colors.black,
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
                MaterialPageRoute(builder: (context) => HomeScreen()),
              );
            },
          )),
          SizedBox(width: 12), // Adds spacing between buttons
          Expanded(
            child: _buildCategoryButton('Books', 'assets/images/book.png', () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => HomeScreen()),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.fromLTRB(10, 20, 10, 0),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF1E3C72),
            Color(0xFF2A5298)
          ], // modern blue gradient
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
            'Hi there! 👋',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
          SizedBox(height: 6),
          Text(
            'Welcome to Xavalog – the Ateneo Marketplace at your fingertips.',
            style: TextStyle(
              color: Colors.white.withAlpha((0.9 * 255).toInt()),
              fontSize: 15.5,
            ),
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
          color: Colors.white, //color here
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

  Widget _buildSecondaryCategoryButtons() {
    return Padding(
      padding:
          EdgeInsets.fromLTRB(20, 0, 20, 0), // Match header & main category
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
              _buildSmallCategoryButton('Shirt', 'assets/images/shirts.png'),
              SizedBox(width: 20),
              _buildSmallCategoryButton('Tech', 'assets/images/tech.png'),
              SizedBox(width: 20),
              _buildSmallCategoryButton(
                  'Accessories', 'assets/images/accessories.png'),
              SizedBox(width: 20),
              _buildSmallCategoryButton('Others', 'assets/images/more.png'),
              SizedBox(width: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSmallCategoryButton(String text, String assetPath) {
    return Column(
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
            child: Image.asset(
              assetPath,
              fit: BoxFit.contain,
            ),
          ),
        ),
        SizedBox(height: 8),
        Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  Widget _buildFeaturedContent() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          Stack(
            alignment: AlignmentDirectional(1, -1),
            children: [
              Image.asset(
                'assets/images/place.jpg',
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
                Text('Ateneo De Naga University', style: TextStyle(fontSize: 17)),
                SizedBox(height: 8),
                Row(
                  children: [
                    Text('Pick-up and Meet'),
                    SizedBox(width: 8),
                    Container(
                        width: 3,
                        height: 3,
                        decoration: BoxDecoration(
                            color: Colors.black, shape: BoxShape.circle)),
                    SizedBox(width: 8),
                    SizedBox(width: 8),
                    Text('Easy Transaction'),
                    SizedBox(width: 8),
                    Container(
                        width: 3,
                        height: 3,
                        decoration: BoxDecoration(
                            color: Colors.black, shape: BoxShape.circle)),
                    SizedBox(width: 8),
                    Text('Trusted Seller'),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Widget _buildOrderItemsList() {
  //   return ListView(
  //     shrinkWrap: true,
  //     physics: NeverScrollableScrollPhysics(),
  //     children: [
  //       _buildOrderItem(),
  //       _buildOrderItem(),
  //     ]
  //         .map((widget) => Padding(
  //               padding: EdgeInsets.symmetric(horizontal: 16),
  //               child: widget,
  //             ))
  //         .toList(),
  //   );
  // }

  // Widget _buildOrderItem() {
  //   return Container(
  //     margin: EdgeInsets.only(bottom: 24),
  //     child: Column(
  //       children: [
  //         Container(
  //           height: 100,
  //           decoration: BoxDecoration(
  //             color: Colors.grey[300],
  //             image: DecorationImage(
  //               image: AssetImage('assets/images/item_5.png'),
  //               fit: BoxFit.cover,
  //             ),
  //           ),
  //         ),
  //         SizedBox(height: 12),
  //         Text('Order Item'),
  //       ],
  //     ),
  //   );
  // }

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

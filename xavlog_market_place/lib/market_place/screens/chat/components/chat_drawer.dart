import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import Firebase Auth
import 'package:xavlog_market_place/market_place/services/login_authentication/authentication_service.dart';
import 'package:xavlog_market_place/market_place/screens/chat/chat_settting.dart';

class ChatDrawer extends StatelessWidget {
  const ChatDrawer({super.key});

  void logout() {
    final _authentication = AuthenticationService();
    _authentication.signOut();
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    String email = user?.email ?? "user@example.com";
    String username = email.split('@')[0];

    return Drawer(
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      elevation: 5,
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(25),
                  spreadRadius: 0,
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 35,
                    backgroundImage: NetworkImage(
                      email.startsWith('j')
                          ? "https://a.espncdn.com/combiner/i?img=/i/headshots/nba/players/full/3945274.png"
                          : email.startsWith('s')
                              ? "https://akm-img-a-in.tosshub.com/indiatoday/images/story/202503/taylor-swift-040933273-1x1.jpg?VersionId=yd_RRnX9v0fJ13qLXya4gUp4LEYV7_Tr"
                              : "https://i.scdn.co/image/ab6761610000e5ebe053b8338322b9c8609ee7ae",
                    ),
                    backgroundColor: Colors.transparent,
                    child: ClipOval(),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user?.displayName ?? username,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        email,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                ListTile(
                  leading: Icon(Icons.home,
                      color: Theme.of(context).iconTheme.color),
                  title: Text("Home",
                      style: Theme.of(context).textTheme.bodyLarge),
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  leading: Icon(Icons.settings,
                      color: Theme.of(context).iconTheme.color),
                  title: Text("Settings",
                      style: Theme.of(context).textTheme.bodyLarge),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ChatSettting(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),

          // Logout button
          Padding(
            padding:
                const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 24.0),
            child: ListTile(
              leading:
                  Icon(Icons.logout, color: Theme.of(context).iconTheme.color),
              title:
                  Text("Logout", style: Theme.of(context).textTheme.bodyLarge),
              onTap: logout,
            ),
          ),
        ],
      ),
    );
  }
}

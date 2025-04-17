import 'package:flutter/material.dart';
import 'package:xavlog_market_place/services/login_authentication/authentication_service.dart';
import 'package:xavlog_market_place/screens/chat/chat_settting.dart';

class ChatDrawer extends StatelessWidget {
  const ChatDrawer({super.key});

  void logout() {
  final _authetication = AuthenticationService();
  _authetication.signOut();
}

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Theme.of(context).colorScheme.surface,
      child: Column(
        children: [
          Expanded(
            child: ListView(
              children: [
                const DrawerHeader(
                  child: Center(
                    child: Icon(Icons.shop, size: 40),
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.home),
                  title: const Text("Home"),
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.settings),
                  title: const Text("Settings"),
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

          Padding(
            padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 24.0),
            child: ListTile(
              leading: const Icon(Icons.logout),
              title: const Text("Logout"),
              onTap: logout, 
            ),
          ),
        ],
      ),
    );
  }
}

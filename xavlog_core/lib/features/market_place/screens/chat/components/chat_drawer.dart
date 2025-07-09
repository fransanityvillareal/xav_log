import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:xavlog_core/features/market_place/screens/chat/chat_settting.dart';
import 'package:xavlog_core/features/market_place/screens/chat/chat_home_page.dart';

class ChatDrawer extends StatelessWidget {
  const ChatDrawer({super.key});

  void logout(BuildContext context) async {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const ChatHomePage()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    String email = user?.email ?? "user@example.com";
    String username = email.split('@')[0];

    return FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      future: user != null
          ? FirebaseFirestore.instance.collection('Users').doc(user.uid).get()
          : null,
      builder: (context, snapshot) {
        String displayName = user?.displayName ?? username;
        String profileImageUrl = "https://via.placeholder.com/150";
        String gbox = "";

        if (snapshot.hasData &&
            snapshot.data != null &&
            snapshot.data!.exists) {
          final data = snapshot.data!.data();
          if (data != null) {
            displayName =
                "${data['firstName'] ?? ''} ${data['lastName'] ?? ''}".trim();
            profileImageUrl = data['profileImageUrl'] ?? profileImageUrl;
            gbox = data['studentId'] ?? "";
          }
        }

        return Drawer(
          backgroundColor: Colors.white,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              topRight: Radius.circular(30),
              bottomRight: Radius.circular(30),
            ),
          ),
          elevation: 10,
          child: Column(
            children: [
              // Header Section
              Container(
                padding: const EdgeInsets.symmetric(
                    vertical: 40, horizontal: 16), // Increased vertical padding
                decoration: const BoxDecoration(
                  color: Color(0xFF003A70), // Match ateneoBlue from login
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(30),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Color.fromRGBO(0, 0, 0, 0.1),
                      blurRadius: 12,
                      offset: Offset(0, 6),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white,
                          width: 2,
                        ),
                      ),
                      child: CircleAvatar(
                        radius: 35,
                        backgroundImage: NetworkImage(profileImageUrl),
                        backgroundColor: Colors.grey[200],
                        child:
                            profileImageUrl == "https://via.placeholder.com/150"
                                ? const Icon(Icons.person,
                                    size: 40, color: Colors.white)
                                : null,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            displayName.isNotEmpty ? displayName : username,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (gbox.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 4.0),
                              child: Text(
                                gbox,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.white70,
                                ),
                              ),
                            ),
                          const SizedBox(height: 6),
                          Text(
                            email,
                            style: const TextStyle(
                              fontSize: 13,
                              color: Colors.white70,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Menu Items
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.only(top: 16),
                  children: [
                    _buildListTile(
                      context,
                      icon: Icons.home_filled,
                      title: "Home",
                      onTap: () => Navigator.pop(context),
                    ),
                    _buildListTile(
                      context,
                      icon: Icons.settings,
                      title: "Settings",
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
                    _buildListTile(
                      context,
                      icon: Icons.group,
                      title: "Contacts",
                      onTap: () {},
                    ),
                    _buildListTile(
                      context,
                      icon: Icons.notifications,
                      title: "Notifications",
                      onTap: () {},
                    ),
                    _buildListTile(
                      context,
                      icon: Icons.help_center,
                      title: "Help & Support",
                      onTap: () {},
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // Helper method to create consistent list tiles
  Widget _buildListTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      leading: Icon(
        icon,
        color: Colors.grey[800],
        size: 24,
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w400,
          color: Colors.black87,
        ),
      ),
      onTap: onTap,
    );
  }
}

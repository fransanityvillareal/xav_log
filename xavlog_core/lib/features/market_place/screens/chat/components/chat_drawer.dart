import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import Firebase Auth
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Cloud Firestore
import 'package:xavlog_core/features/market_place/screens/chat/chat_settting.dart';
import 'package:xavlog_core/features/market_place/services/login_authentication/authentication_service.dart';

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
              SizedBox(height: 20),
              Container(
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
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
                        backgroundImage: NetworkImage(profileImageUrl),
                        backgroundColor: Colors.transparent,
                        child: ClipOval(),
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            displayName.isNotEmpty ? displayName : username,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          if (gbox.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 2.0),
                              child: Text(
                                gbox,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.black54,
                                ),
                              ),
                            ),
                          const SizedBox(height: 4),
                          Text(
                            email,
                            style: const TextStyle(
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
                padding: const EdgeInsets.only(
                    left: 16.0, right: 16.0, bottom: 24.0),
                child: ListTile(
                  leading: Icon(Icons.logout,
                      color: Theme.of(context).iconTheme.color),
                  title: Text("Logout",
                      style: Theme.of(context).textTheme.bodyLarge),
                  onTap: logout,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

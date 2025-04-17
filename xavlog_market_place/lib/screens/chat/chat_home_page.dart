import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:xavlog_market_place/screens/chat/chat_page.dart';
import 'package:xavlog_market_place/screens/chat/components/chat_drawer.dart';
import 'package:xavlog_market_place/screens/chat/components/user_tile.dart';
import 'package:xavlog_market_place/services/chat/chat_services.dart';
import 'package:xavlog_market_place/services/login_authentication/authentication_service.dart';

class ChatHomePage extends StatelessWidget {
  ChatHomePage({super.key});

  final ChatService _chatService =
      ChatService(); // Make sure the class name matches!
  final AuthenticationService _authenticationService = AuthenticationService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: const Text('Chat Home'),
      ),
      drawer: const ChatDrawer(),
      body: _buildUserList(),
    );
  }

  Widget _buildUserList() {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: _chatService.getUserStream(),
      builder: (context, snapshot) {
        // loading
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        // error
        if (snapshot.hasError) {
          return const Center(child: Text('Something went wrong.'));
        }
        // return list view
        return ListView(
          children: snapshot.data!
              .map<Widget>((userData) => _buildUserListItem(userData, context))
              .toList(),
        );
      },
    );
  }

//build individual list title for user
  Widget _buildUserListItem(
      Map<String, dynamic> userData, BuildContext context) {
    return UserTile(
      text: userData['email'],
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) {
          return ChatPage(
            receiverEmail: userData['email'],
          );
        }));
      },
    ); //39:41
  }
}

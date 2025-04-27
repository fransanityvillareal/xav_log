import 'package:flutter/material.dart';
import 'package:xavlog_core/features/market_place/screens/chat/chat_page.dart';
import 'package:xavlog_core/features/market_place/screens/chat/components/chat_drawer.dart';
import 'package:xavlog_core/features/market_place/services/chat/chat_services.dart';
import 'package:xavlog_core/features/market_place/services/login_authentication/authentication_service.dart';


class ChatHomePage extends StatelessWidget {
  ChatHomePage({super.key});

  final ChatService _chatService = ChatService();
  final AuthenticationService _authenticationService = AuthenticationService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF003A70),
        title: const Text(
          'Xavlog Chat',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22,
            color: Colors.white,
          ),
        ),
        elevation: 0,
      ),
      drawer: const ChatDrawer(),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Contacts",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF003A70),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(child: _buildUserList(context)),
          ],
        ),
      ),
    );
  }

  Widget _buildUserList(BuildContext context) {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: _chatService.getUserStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return const Center(child: Text('Something went wrong.'));
        }

        final currentUserEmail = _authenticationService.getCurrentUser?.email;

        return ListView.separated(
          itemCount: snapshot.data!.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final user = snapshot.data![index];
            if (user['email'] == currentUserEmail) {
              return const SizedBox.shrink();
            }

            final photoUrl = user['photoURL'];
            final email = user['email'];
            final initials = email.isNotEmpty ? email[0].toUpperCase() : "?";

            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChatPage(
                      receiverEmail: user['email'],
                      receiverID: user['uid'],
                    ),
                  ),
                );
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundImage: photoUrl != null && photoUrl != ""
                          ? NetworkImage(photoUrl)
                          : null,
                      backgroundColor: const Color(0xFFCAD6E2),
                      child: photoUrl == null || photoUrl == ""
                          ? Text(
                              initials,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            )
                          : null,
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        email,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Color(0xFF1C1C1C),
                          fontWeight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios,
                        size: 16, color: Colors.grey),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

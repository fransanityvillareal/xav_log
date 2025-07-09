library;

import 'package:flutter/material.dart';

class ChatHelpSupportPage extends StatelessWidget {
  const ChatHelpSupportPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        toolbarHeight: 80,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
          ),
        ),
        title: Padding(
          padding: const EdgeInsets.only(top: 10.0),
          child: Text(
            'Chat Help & Support',
            style: TextStyle(
              fontFamily: 'Jost',
              color: const Color.fromARGB(255, 16, 16, 16),
              fontWeight: FontWeight.bold,
              fontSize: 24,
            ),
          ),
        ),
        leading: Padding(
          padding: const EdgeInsets.only(top: 10.0),
          child: IconButton(
            icon: const Icon(Icons.arrow_back,
                color: Color.fromARGB(255, 16, 16, 16)),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            _buildFaqSection('Chat Features', [
              {
                'Q': 'How do I start a new chat?',
                'A':
                    'To start a new chat, go to the Contacts tab, select a user, and begin typing your message.'
              },
              {
                'Q': 'Can I create group chats?',
                'A':
                    'Yes, you can create group chats by selecting the "Add Group" option in the chat drawer.'
              },
              {
                'Q': 'How do I block a user?',
                'A':
                    'Go to Settings, select "Block User," and choose the user you want to block.'
              },
              {
                'Q': 'Can I delete chat messages?',
                'A':
                    'Currently, chat messages cannot be deleted. This feature may be added in future updates.'
              },
            ]),
            _buildFaqSection('Technical Issues', [
              {
                'Q': 'Why am I not receiving messages?',
                'A':
                    'Ensure you have a stable internet connection and that notifications are enabled for the app.'
              },
              {
                'Q': 'What should I do if the app crashes?',
                'A':
                    'Try restarting the app. If the issue persists, contact support at support@xavlog.com.'
              },
              {
                'Q': 'How do I report a bug?',
                'A':
                    'You can report bugs through the Help & Support section or by emailing support@xavlog.com.'
              },
            ]),
          ],
        ),
      ),
    );
  }

  Widget _buildFaqSection(
      String title, List<Map<String, String>> faqs) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 16.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header with Xavier blue gradient
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16.0),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF071D99), Color(0xFF2C3E91)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Text(
              title,
              style: const TextStyle(
                fontFamily: 'Jost',
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          // FAQ items with expansion panels
          Container(
            color: Colors.white,
            child: Column(
              children: faqs.map((faq) {
                return ExpansionTile(
                  title: Text(
                    faq['Q']!,
                    style: const TextStyle(
                      fontFamily: 'Jost',
                      fontSize: 17,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        faq['A']!,
                        style: const TextStyle(
                          fontFamily: 'Jost',
                          fontSize: 16,
                          color: Color.fromARGB(188, 0, 0, 0),
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

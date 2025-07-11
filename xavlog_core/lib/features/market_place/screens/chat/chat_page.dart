import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:xavlog_core/services/chat_services.dart';
import 'package:xavlog_core/services/authentication_service.dart';
import 'package:xavlog_core/services/recent_chats_service.dart';


class ChatPage extends StatefulWidget {
  final String receiverEmail;
  final String receiverID;
  final bool isGroup;
  final Map<String, dynamic>? groupData;

  const ChatPage({
    super.key,
    required this.receiverEmail,
    required this.receiverID,
    this.isGroup = false,
    this.groupData,
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ChatService _chatService = ChatService();
  final AuthenticationService _authenticationService = AuthenticationService();

  // Theme color state
  Color _backgroundColor = const Color.fromARGB(255, 255, 255, 255);

  // List of selectable colors
  final List<Color> _themeColors = [
    const Color(0xFF1A365D), // Deep Navy (softer than original dark blue)
    const Color(0xFF2C5282), // Ateneo Blue (softer variant)
    const Color(0xFFBFA547), // Mint Teal (replaces gold)
    const Color.fromARGB(
        255, 68, 137, 158), // Azure Teal (replaces blue variant)
    const Color.fromARGB(255, 75, 153, 116), // Forest Teal (replaces green)
    const Color.fromARGB(255, 20, 12, 11), // Coral (red alternative)
    const Color.fromARGB(
        255, 139, 66, 129), // Vibrant Purple (replaces original purple)
  ];

  void sendMessage() async {
    if (_messageController.text.isNotEmpty) {
      final user = _authenticationService.getCurrentUser;
      final messageText = _messageController.text; // Store the message text
      
      if (widget.isGroup) {
        // Get sender email and firstName from Users collection
        String senderName = user?.uid ?? '';
        String senderFirstName = '';
        if (user != null) {
          final userDoc = await FirebaseFirestore.instance
              .collection('Users')
              .doc(user.uid)
              .get();
          final userData = userDoc.data();
          if (userData != null) {
            senderName = userData['email'] ?? user.email ?? user.uid;
            senderFirstName = userData['firstName'] ?? '';
          } else {
            senderName = user.email ?? user.uid;
            senderFirstName = '';
          }
        }
        // Send group message
        await FirebaseFirestore.instance
            .collection('Groups')
            .doc(widget.receiverID)
            .collection('messages')
            .add({
          'message': messageText,
          'senderID': user!.uid,
          'senderName': senderName,
          'senderFirstName': senderFirstName,
          'timestamp': FieldValue.serverTimestamp(),
        });
      } else {
        // Send regular message
        await _chatService.sendMessage(widget.receiverID, messageText);

        // Update recent chats - CORRECT PLACEMENT
        if (user != null) {
          await RecentChatsService.updateRecentChats(
            senderId: user.uid,           // ✅ Use user.uid
            receiverId: widget.receiverID,
            lastMessage: messageText,     // ✅ Use stored message text
            timestamp: Timestamp.now(),
          );
        }
      }
      
      _messageController.clear();
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _showThemeDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Choose Chat Background'),
        content: SizedBox(
          width: 320,
          child: Wrap(
            spacing: 12,
            runSpacing: 12,
            children: _themeColors.map((color) {
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _backgroundColor = color;
                  });
                  Navigator.of(context).pop();
                },
                child: Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: _backgroundColor == color
                          ? Colors.black
                          : Colors.white,
                      width: 2.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: _backgroundColor == color
                      ? const Icon(Icons.check, color: Colors.white, size: 20)
                      : null,
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }


  @override
  void initState() {
    super.initState();
    _fetchReceiverName();
  }

  String _receiverName = 'Loading...';

  Future<void> _fetchReceiverName() async {
    try {
      if (widget.isGroup) {
        // Fetch group name from Groups collection
        final groupDoc = await FirebaseFirestore.instance
            .collection('Groups')
            .doc(widget.receiverID)
            .get();
        final groupData = groupDoc.data();
        if (groupData != null && mounted) {
          setState(() {
            _receiverName = groupData['name'] ?? 'Group';
          });
        }
      } else {
        // Fetch user name from Users collection
        final userDoc = await FirebaseFirestore.instance
            .collection('Users')
            .doc(widget.receiverID)
            .get();
        final userData = userDoc.data();
        if (userData != null && mounted) {
          setState(() {
            _receiverName = userData['firstName'] ?? widget.receiverEmail;
          });
        }
      }
    } catch (e) {
      setState(() {
        _receiverName =
            widget.isGroup ? 'Group' : widget.receiverEmail; // Fallback
      });
    }
  }

    void _showEncryptionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Encryption Settings'),
        content: FutureBuilder<bool>(
          future: _chatService.isChatEncrypted(widget.receiverID),
          builder: (context, snapshot) {
            final isEncrypted = snapshot.data ?? false;
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  isEncrypted 
                    ? '🔒 This chat is encrypted'
                    : '🔓 This chat is not encrypted',
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 16),
                if (!isEncrypted)
                  ElevatedButton(
                    onPressed: () async {
                      final success = await _chatService.enableEncryption(widget.receiverID);
                      if (success && mounted) {
                        Navigator.of(context).pop();
                        setState(() {}); // Refresh to show encryption status
                      }
                    },
                    child: const Text('Enable Encryption'),
                  ),
              ],
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        title: Row(
          children: [
            Text(
              _receiverName,
              style: const TextStyle(
                color: Color.fromARGB(255, 255, 255, 255),
                fontWeight: FontWeight.bold,
                fontSize: 20,
                letterSpacing: 0.2,
              ),
            ),
            // 🔒 Add encryption indicator
            if (!widget.isGroup) ...[
              const SizedBox(width: 8),
              FutureBuilder<bool>(
                future: _chatService.isChatEncrypted(widget.receiverID),
                builder: (context, snapshot) {
                  final isEncrypted = snapshot.data ?? false;
                  return isEncrypted
                      ? const Icon(
                          Icons.lock,
                          color: Colors.green,
                          size: 16,
                        )
                      : const Icon(
                          Icons.lock_open,
                          color: Colors.orange,
                          size: 16,
                        );
                },
              ),
            ],
          ],
        ),
        iconTheme: const IconThemeData(color: Color.fromARGB(255, 255, 255, 255)),
        backgroundColor: const Color(0xFF283AA3),
        actions: [
          // 🔒 Add encryption toggle button for 1-on-1 chats
          if (!widget.isGroup)
            IconButton(
              icon: const Icon(Icons.security),
              tooltip: 'Encryption Settings',
              onPressed: _showEncryptionDialog,
            ),
          IconButton(
            icon: const Icon(Icons.color_lens_rounded),
            tooltip: 'Change Chat Theme',
            onPressed: _showThemeDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(child: _buildMessageList()),
          _buildUserInput(),
        ],
      ),
    );
  }

  Widget _buildMessageList() {
  String senderID = _authenticationService.getCurrentUser!.uid;
  
  if (widget.isGroup) {
    // Group messages - no encryption, use QuerySnapshot
    Stream<QuerySnapshot> messageStream = FirebaseFirestore.instance
        .collection('Groups')
        .doc(widget.receiverID)
        .collection('messages')
        .orderBy('timestamp')
        .snapshots();
        
    return StreamBuilder<QuerySnapshot>(
      stream: messageStream,
      builder: (context, snapshot) {
        if (snapshot.hasError) return const Text("Error loading messages.");
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        // Auto-scroll to bottom after messages build
        WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());

        return ListView(
          controller: _scrollController,
          padding: const EdgeInsets.all(10),
          children:
              snapshot.data!.docs.map((doc) => _buildMessageItem(doc)).toList(),
        );
      },
    );
  } else {
    // 1-on-1 messages - with encryption, use List<Map<String, dynamic>>
    Stream<List<Map<String, dynamic>>> messageStream = _chatService.getMessages(widget.receiverID, senderID);
    
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: messageStream,
      builder: (context, snapshot) {
        if (snapshot.hasError) return const Text("Error loading messages.");
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        // Auto-scroll to bottom after messages build
        WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());

        return ListView(
          controller: _scrollController,
          padding: const EdgeInsets.all(10),
          children: snapshot.data!.map((messageData) => _buildEncryptedMessageItem(messageData)).toList(),
        );
      },
    );
  }
}

  // handle encrypted message items
  Widget _buildEncryptedMessageItem(Map<String, dynamic> data) {
    bool isCurrentUser = data['senderID'] == _authenticationService.getCurrentUser!.uid;

    final alignment = isCurrentUser ? Alignment.centerRight : Alignment.centerLeft;
    final bubbleColor = isCurrentUser ? const Color(0xFF003A70) : const Color(0xFFFFD700);
    final textColor = isCurrentUser ? Colors.white : Colors.black87;
    final textAlign = isCurrentUser ? TextAlign.right : TextAlign.left;

    String timeString = '';
    if (data['timestamp'] != null) {
      try {
        final dateTime = (data['timestamp'] as Timestamp).toDate();
        timeString = DateFormat('EEE, hh:mm a').format(dateTime);
      } catch (_) {
        timeString = '';
      }
    }

    Color timestampColor;
    double bgLuminance = _backgroundColor.computeLuminance();
    if (bgLuminance < 0.4) {
      timestampColor = Colors.white.withOpacity(0.85);
    } else {
      timestampColor = Colors.grey.shade700;
    }

    return Align(
      alignment: alignment,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Column(
          crossAxisAlignment:
              isCurrentUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Container(
              constraints: const BoxConstraints(maxWidth: 260),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: bubbleColor,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: isCurrentUser
                      ? const Radius.circular(16)
                      : const Radius.circular(4),
                  bottomRight: isCurrentUser
                      ? const Radius.circular(4)
                      : const Radius.circular(16),
                ),
              ),
              child: Text(
                data["message"],
                style: TextStyle(color: textColor, fontSize: 15),
                textAlign: textAlign,
              ),
            ),
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: Text(
                timeString,
                style: TextStyle(
                  fontSize: 12,
                  color: timestampColor,
                ),
              ),
            ),
          ],
        ),
      ),
    ).animate().fade(duration: 300.ms).slideY(begin: 0.2);
  }

  Widget _buildMessageItem(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    bool isCurrentUser = false;
    if (widget.isGroup) {
      isCurrentUser =
          data['senderID'] == _authenticationService.getCurrentUser!.uid;
    } else {
      isCurrentUser =
          data['senderID'] == _authenticationService.getCurrentUser!.uid;
    }

    final alignment =
        isCurrentUser ? Alignment.centerRight : Alignment.centerLeft;
    final bubbleColor =
        isCurrentUser ? const Color(0xFF003A70) : const Color(0xFFFFD700);
    final textColor = isCurrentUser ? Colors.white : Colors.black87;
    final textAlign = isCurrentUser ? TextAlign.right : TextAlign.left;

    // For group chat, show sender first name above the message (except for current user)
    Widget? senderNameWidget;
    if (widget.isGroup && !isCurrentUser) {
      senderNameWidget = FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance
            .collection('Users')
            .doc(data['senderID'])
            .get(),
        builder: (context, snapshot) {
          String display = '';
          if (snapshot.connectionState == ConnectionState.done &&
              snapshot.hasData) {
            final userData = snapshot.data!.data() as Map<String, dynamic>?;
            display = userData?['firstName'] ??
                userData?['email'] ??
                data['senderID'].toString();
          } else {
            display = '';
          }
          return display.isNotEmpty
              ? Padding(
                  padding: const EdgeInsets.only(left: 4, right: 4, bottom: 2),
                  child: Text(
                    display,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: _backgroundColor.computeLuminance() < 0.4
                          ? Colors.white
                          : Colors.black87, // Adjust color based on theme
                    ),
                  ),
                )
              : const SizedBox.shrink();
        },
      );
    }

    String timeString = '';
    if (data['timestamp'] != null) {
      try {
        final dateTime = (data['timestamp'] as Timestamp).toDate();
        timeString = DateFormat('EEE, hh:mm a').format(dateTime); // Include day
      } catch (_) {
        timeString = '';
      }
    }

    Color timestampColor;
    double bgLuminance = _backgroundColor.computeLuminance();
    if (bgLuminance < 0.4) {
      timestampColor = Colors.white.withOpacity(0.85);
    } else {
      timestampColor = Colors.grey.shade700;
    }

    return Align(
      alignment: alignment,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Column(
          crossAxisAlignment:
              isCurrentUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            if (senderNameWidget != null) senderNameWidget,
            Container(
              constraints: const BoxConstraints(maxWidth: 260),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: bubbleColor,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: isCurrentUser
                      ? const Radius.circular(16)
                      : const Radius.circular(4),
                  bottomRight: isCurrentUser
                      ? const Radius.circular(4)
                      : const Radius.circular(16),
                ),
              ),
              child: Text(
                data["message"],
                style: TextStyle(color: textColor, fontSize: 15),
                textAlign: textAlign,
              ),
            ),
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: Text(
                timeString,
                style: TextStyle(
                  fontSize: 12,
                  color: timestampColor,
                ),
              ),
            ),
          ],
        ),
      ),
    ).animate().fade(duration: 300.ms).slideY(begin: 0.2);
  }

  Widget _buildUserInput() {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        color: const Color.fromARGB(255, 22, 45, 83),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _messageController,
                decoration: InputDecoration(
                  hintText: "Type a message...",
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            CircleAvatar(
              backgroundColor: const Color(0xFF003A70), // Ateneo Blue
              child: IconButton(
                icon: const Icon(Icons.send, color: Colors.white),
                onPressed: sendMessage,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

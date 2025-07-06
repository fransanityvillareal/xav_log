import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:xavlog_core/features/market_place/screens/chat/chat_page.dart';
import 'package:xavlog_core/features/market_place/screens/chat/components/chat_drawer.dart';
import 'package:xavlog_core/features/market_place/services/chat/chat_services.dart';
import 'package:xavlog_core/features/market_place/services/login_authentication/authentication_service.dart';

class ChatHomePage extends StatefulWidget {
  final String? initialSearchQuery; // Add initialSearchQuery parameter

  const ChatHomePage({super.key, this.initialSearchQuery});

  @override
  State<ChatHomePage> createState() => ChatHomePageState();
}

class ChatHomePageState extends State<ChatHomePage> { // Renamed to make public
  final ChatService _chatService = ChatService();
  final AuthenticationService _authenticationService = AuthenticationService();
  late TextEditingController _searchController;
  bool _showSearch = false;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchQuery =
        widget.initialSearchQuery ?? ''; // Use initialSearchQuery if provided
    _searchController = TextEditingController(text: _searchQuery);
  }

  Future<String> _getProfileImageUrl(String uid, String? fallbackUrl) async {
    try {
      final doc =
          await FirebaseFirestore.instance.collection('Users').doc(uid).get();
      if (doc.exists) {
        final data = doc.data();
        if (data != null &&
            data['profileImageUrl'] != null &&
            data['profileImageUrl'] != "") {
          return data['profileImageUrl'] as String;
        }
      }
    } catch (e) {
      // ignore error, fallback to photoURL
    }
    return fallbackUrl ?? '';
  }

  void _toggleSearch() {
    setState(() {
      _showSearch = !_showSearch;
      if (!_showSearch) {
        _searchQuery = '';
        _searchController.clear();
      }
    });
  }

  void _createGroup() {
    final TextEditingController _groupNameController = TextEditingController();
    final TextEditingController _groupDescController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create New Group'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _groupNameController,
              decoration: const InputDecoration(
                labelText: 'Group Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _groupDescController,
              decoration: const InputDecoration(
                labelText: 'Description (optional)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                final groupName = _groupNameController.text.trim();
                _groupDescController.text.trim();
                if (groupName.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Group name is required.')),
                  );
                  return;
                }
                final currentUser = _authenticationService.getCurrentUser;
                if (currentUser == null) return;
                // Create group in Firestore
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Group "$groupName" created!')),
                );
              },
              child: const Text('Create Group'),
            ),
          ],
        ),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF003A70),
        iconTheme: const IconThemeData(color: Colors.white),
        title: _showSearch
            ? TextField(
                controller: _searchController,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'Search contacts...',
                  border: InputBorder.none,
                  hintStyle: const TextStyle(color: Colors.white70),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: _toggleSearch,
                  ),
                ),
                style: const TextStyle(color: Colors.white),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value.toLowerCase();
                  });
                },
              )
            : const Text(
                'Xavlog Chat',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                  color: Colors.white,
                ),
              ),
        elevation: 0,
        actions: [
          if (!_showSearch) ...[
            IconButton(
              icon: const Icon(Icons.search),
              color: Colors.white,
              onPressed: _toggleSearch,
            ),
            IconButton(
              icon: const Icon(Icons.group_add),
              onPressed: _createGroup,
              color: Colors.white,
            ),
          ],
        ],
      ),
      drawer: const ChatDrawer(),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!_showSearch) ...[
              const Text(
                "Contacts",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF003A70),
                ),
              ),
              const SizedBox(height: 12),
            ],
            Expanded(child: _buildUserList(context)),
          ],
        ),
      ),
    );
  }

  Widget _buildUserList(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          TabBar(
            labelColor: const Color(0xFF003A70),
            unselectedLabelColor: Colors.grey,
            indicatorColor: const Color(0xFF003A70),
            tabs: const [
              Tab(text: 'Contacts'),
              Tab(text: 'Groups'),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                // Contacts Tab
                _buildContactsList(context),
                // Groups Tab
                _buildGroupsList(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

// Build contacts
  Widget _buildContactsList(BuildContext context) {
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
      final currentUserId = _authenticationService.getCurrentUser?.uid;
      
      if (currentUserId == null) {
        return const Center(child: Text('Not logged in.'));
      }
      
      var users = snapshot.data!;
      
      // Filter users: exclude current user
      users = users.where((user) {
        final isNotCurrentUser = user['email'] != currentUserEmail;
        final matchesSearch = _searchQuery.isEmpty ||
            user['email'].toLowerCase().contains(_searchQuery) ||
            (user['displayName']?.toLowerCase().contains(_searchQuery) ?? false) ||
            (user['firstName']?.toLowerCase().contains(_searchQuery) ?? false) ||
            (user['lastName']?.toLowerCase().contains(_searchQuery) ?? false);
        return isNotCurrentUser && matchesSearch;
      }).toList();

      if (users.isEmpty) {
        return Center(
          child: Text(
            _searchQuery.isEmpty
                ? 'No users found'
                : 'No users match your search',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.grey),
          ),
        );
      }

      // Get users with chat history
      return FutureBuilder<List<Map<String, dynamic>>>(
        future: _getFilteredUsersByChatHistory(users, currentUserId, _searchQuery.isNotEmpty),
        builder: (context, sortedSnapshot) {
          if (sortedSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          
          final filteredUsers = sortedSnapshot.data ?? [];

          if (filteredUsers.isEmpty) {
            return Center(
              child: Text(
                _searchQuery.isEmpty
                    ? 'No recent conversations\nSearch to find new contacts'
                    : 'No users match your search',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey),
              ),
            );
          }

          return ListView.separated(
            itemCount: filteredUsers.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final user = filteredUsers[index];
              final photoUrl = user['photoURL'];
              final email = user['email'];
              final displayName = user['displayName'] ?? user['firstName'] ?? '';
              final initials = _getInitials(email, displayName);
              final uid = user['uid'];
              final hasHistory = user['hasHistory'] ?? false;
              
              return FutureBuilder<String>(
                future: _getProfileImageUrl(uid, photoUrl),
                builder: (context, snapshot) {
                  final profileImageUrl = snapshot.data ?? '';
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
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: hasHistory 
                          ? Border.all(color: const Color(0xFF003A70).withOpacity(0.3), width: 1)
                          : Border.all(color: Colors.grey.withOpacity(0.2), width: 1),
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
                          Stack(
                            children: [
                              CircleAvatar(
                                radius: 24,
                                backgroundImage: (profileImageUrl.isNotEmpty)
                                    ? NetworkImage(profileImageUrl)
                                    : null,
                                backgroundColor: const Color(0xFFCAD6E2),
                                child: (profileImageUrl.isEmpty)
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
                              // Show indicator for users with chat history
                              if (hasHistory)
                                Positioned(
                                  right: 0,
                                  bottom: 0,
                                  child: Container(
                                    width: 12,
                                    height: 12,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF52B788),
                                      shape: BoxShape.circle,
                                      border: Border.all(color: Colors.white, width: 2),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  displayName.isNotEmpty ? displayName : email,
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: hasHistory ? const Color(0xFF1C1C1C) : Colors.grey[600],
                                    fontWeight: hasHistory ? FontWeight.w500 : FontWeight.w400,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                if (displayName.isNotEmpty && displayName != email)
                                  Text(
                                    email,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                // Show "New contact" for users without history when searching
                                if (!hasHistory && _searchQuery.isNotEmpty)
                                  Text(
                                    'New contact',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.blue[600],
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (hasHistory)
                                const Icon(
                                  Icons.chat_bubble_outline,
                                  size: 16,
                                  color: Color(0xFF52B788),
                                )
                              else if (_searchQuery.isNotEmpty)
                                const Icon(
                                  Icons.person_add_alt_1,
                                  size: 16,
                                  color: Colors.blue,
                                ),
                              const SizedBox(width: 8),
                              const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      );
    },
  );
}

//get users with chat history
          //HEAVILY INEFFICIENT, but works for now
Future<List<Map<String, dynamic>>> _getFilteredUsersByChatHistory(
  List<Map<String, dynamic>> allUsers, 
  String currentUserId,
  bool showAllUsers // true when searching, false when not searching
) async {
  List<Map<String, dynamic>> usersWithHistory = [];
  List<Map<String, dynamic>> usersWithoutHistory = [];
  
  for (final user in allUsers) {
    final otherUserId = user['uid'];
    
    // Create chat room ID
    List<String> ids = [currentUserId, otherUserId];
    ids.sort();
    String chatRoomId = ids.join('_');
    
    bool hasHistory = false;
    
    try {
      // Check if chat room exists and has messages
      final chatDoc = await FirebaseFirestore.instance
          .collection('chat_rooms')
          .doc(chatRoomId)
          .collection('messages')
          .limit(1)
          .get();
      
      hasHistory = chatDoc.docs.isNotEmpty;
    } catch (e) {
      hasHistory = false;
    }
    
    final userWithFlag = Map<String, dynamic>.from(user);
    userWithFlag['hasHistory'] = hasHistory;
    
    if (hasHistory) {
      usersWithHistory.add(userWithFlag);
    } else if (showAllUsers) {
      usersWithoutHistory.add(userWithFlag);
    }
  }
  
  // Alpahetical sort
  usersWithHistory.sort((a, b) {
    final nameA = a['displayName'] ?? a['firstName'] ?? a['email'] ?? '';
    final nameB = b['displayName'] ?? b['firstName'] ?? b['email'] ?? '';
    return nameA.toLowerCase().compareTo(nameB.toLowerCase());
  });
  
  usersWithoutHistory.sort((a, b) {
    final nameA = a['displayName'] ?? a['firstName'] ?? a['email'] ?? '';
    final nameB = b['displayName'] ?? b['firstName'] ?? b['email'] ?? '';
    return nameA.toLowerCase().compareTo(nameB.toLowerCase());
  });
  
  // Return users with history first, then users without history (only when searching)
  return [...usersWithHistory, ...usersWithoutHistory];
}

//helper method for better initials
String _getInitials(String email, String displayName) {
  if (displayName.isNotEmpty) {
    final names = displayName.split(' ');
    if (names.length >= 2) {
      return (names[0][0] + names[1][0]).toUpperCase();
    } else {
      return names[0][0].toUpperCase();
    }
  }
  return email.isNotEmpty ? email[0].toUpperCase() : "?";
}


  Widget _buildGroupsList(BuildContext context) {
    final currentUser = _authenticationService.getCurrentUser;
    if (currentUser == null) {
      return const Center(child: Text('Not logged in.'));
    }
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('Groups')
          .where('members', arrayContains: currentUser.uid)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return const Center(child: Text('Error loading groups.'));
        }
        final groups = snapshot.data?.docs ?? [];
        if (groups.isEmpty) {
          return const Center(child: Text('No groups yet.'));
        }
        return ListView.separated(
          itemCount: groups.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final group = groups[index];
            final data = group.data() as Map<String, dynamic>;
            final isMember =
                (data['members'] as List).contains(currentUser.uid);
            return ListTile(
              leading: const CircleAvatar(
                backgroundColor: Color(0xFF003A70),
                child: Icon(Icons.group, color: Colors.white),
              ),
              title: Text(data['name'] ?? 'Unnamed Group'),
              subtitle: (data['description'] != null &&
                      data['description'].toString().isNotEmpty)
                  ? Text(data['description'])
                  : null,
              trailing: IconButton(
                icon: const Icon(Icons.person_add_alt_1,
                    color: Color(0xFF003A70)),
                tooltip: 'Add People',
                onPressed: () async {
                  final usersSnapshot = await FirebaseFirestore.instance
                      .collection('Users')
                      .get();
                  final allUsers = usersSnapshot.docs
                      .map((doc) => doc.data())
                      .where(
                          (u) => !(data['members'] as List).contains(u['uid']))
                      .toList();
                  showDialog(
                    context: context,
                    builder: (context) {
                      String? selectedUid;
                      return AlertDialog(
                        backgroundColor: Colors.grey[50],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18.0),
                        ),
                        title: Row(
                          children: const [
                            Icon(Icons.person_add_alt_1,
                                color: Color(0xFF003A70)),
                            SizedBox(width: 8),
                            Text(
                              'Add Member',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF003A70),
                                fontSize: 20,
                              ),
                            ),
                          ],
                        ),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Select a user to add to this group:',
                              style: TextStyle(
                                  fontSize: 15, color: Colors.black87),
                            ),
                            const SizedBox(height: 16),
                            DropdownButtonFormField<String>(
                              items: allUsers.map((user) {
                                return DropdownMenuItem<String>(
                                  value: user['uid'],
                                  child: Row(
                                    children: [
                                      const Icon(Icons.account_circle,
                                          color: Color(0xFF003A70), size: 20),
                                      const SizedBox(width: 8),
                                      Text(
                                        user['email'] ??
                                            user['displayName'] ??
                                            'Unknown',
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.w500),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                              onChanged: (val) => selectedUid = val,
                              decoration: InputDecoration(
                                labelText: 'Select user',
                                labelStyle:
                                    const TextStyle(color: Color(0xFF003A70)),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: const BorderSide(
                                      color: Color(0xFF003A70)),
                                ),
                                filled: true,
                                fillColor: Colors.white,
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 14),
                              ),
                              style: const TextStyle(color: Color(0xFF003A70)),
                              dropdownColor: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              icon: const Icon(Icons.arrow_drop_down,
                                  color: Color(0xFF003A70)),
                            ),
                          ],
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text(
                              'Cancel',
                              style: TextStyle(
                                color: Color(0xFF003A70),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () async {
                              if (selectedUid != null) {
                                await group.reference.update({
                                  'members':
                                      FieldValue.arrayUnion([selectedUid])
                                });
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Member added!'),
                                    backgroundColor: Color(0xFF52B788),
                                  ),
                                );
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF003A70),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 24, vertical: 12),
                            ),
                            child: const Text(
                              'Add',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
              onTap: isMember
                  ? () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChatPage(
                            receiverEmail: data['name'] ?? 'Unnamed Group',
                            receiverID: group.id,
                            isGroup: true,
                            groupData: data,
                          ),
                        ),
                      );
                    }
                  : () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('You are not a member of this group.'),
                          backgroundColor: Colors.redAccent,
                        ),
                      );
                    },
            );
          },
        );
      },
    );
  }
}

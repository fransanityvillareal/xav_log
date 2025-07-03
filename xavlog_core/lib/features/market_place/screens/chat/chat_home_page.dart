import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:xavlog_core/features/market_place/screens/chat/chat_page.dart';
import 'package:xavlog_core/features/market_place/screens/chat/components/chat_drawer.dart';
import 'package:xavlog_core/features/market_place/services/chat/chat_services.dart';
import 'package:xavlog_core/features/market_place/services/login_authentication/authentication_service.dart';

class ChatHomePage extends StatefulWidget {
  const ChatHomePage({super.key});

  @override
  State<ChatHomePage> createState() => _ChatHomePageState();
}

class _ChatHomePageState extends State<ChatHomePage> {
  final ChatService _chatService = ChatService();
  final AuthenticationService _authenticationService = AuthenticationService();
  final TextEditingController _searchController = TextEditingController();
  bool _showSearch = false;
  String _searchQuery = '';

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
                final groupDesc = _groupDescController.text.trim();
                if (groupName.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Group name is required.')),
                  );
                  return;
                }
                final currentUser = _authenticationService.getCurrentUser;
                if (currentUser == null) return;
                // Create group in Firestore
                final groupDoc =
                    await FirebaseFirestore.instance.collection('Groups').add({
                  'name': groupName,
                  'description': groupDesc,
                  'createdBy': currentUser.uid,
                  'createdAt': FieldValue.serverTimestamp(),
                  'members': [currentUser.uid],
                  'type': 'group',
                });
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
        var users = snapshot.data!;
        users = users.where((user) {
          final isNotCurrentUser = user['email'] != currentUserEmail;
          final matchesSearch = _searchQuery.isEmpty ||
              user['email'].toLowerCase().contains(_searchQuery) ||
              (user['displayName']?.toLowerCase().contains(_searchQuery) ??
                  false);
          return isNotCurrentUser && matchesSearch;
        }).toList();
        if (users.isEmpty) {
          return Center(
            child: Text(
              _searchQuery.isEmpty
                  ? 'No contacts available'
                  : 'No contacts found',
              style: const TextStyle(color: Colors.grey),
            ),
          );
        }
        return ListView.separated(
          itemCount: users.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final user = users[index];
            final photoUrl = user['photoURL'];
            final email = user['email'];
            final initials = email.isNotEmpty ? email[0].toUpperCase() : "?";
            final uid = user['uid'];
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
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
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
      },
    );
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
                      .map((doc) => doc.data() as Map<String, dynamic>)
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

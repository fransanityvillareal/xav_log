import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:xavlog_core/features/market_place/screens/chat/chat_page.dart';
import 'package:xavlog_core/features/market_place/screens/chat/components/chat_drawer.dart';
import 'package:xavlog_core/services/chat_services.dart';
import 'package:xavlog_core/services/authentication_service.dart';
import 'package:xavlog_core/services/recent_chats_service.dart';

class ChatHomePage extends StatefulWidget {
  final String? initialSearchQuery; // Add initialSearchQuery parameter

  const ChatHomePage({super.key, this.initialSearchQuery});

  @override
  State<ChatHomePage> createState() => ChatHomePageState();
}

class ChatHomePageState extends State<ChatHomePage> {
  // Renamed to make public
  final ChatService _chatService = ChatService();
  final AuthenticationService _authenticationService = AuthenticationService();
  late TextEditingController _searchController;
  bool _showSearch = false;
  String _searchQuery = '';
  Timer? _searchDebounce;
  final Map<String, String> _profileImageCache = {};

  // pagination variables
  static const int _usersPerPage = 20;
  static const int _groupsPerPage = 15;
  DocumentSnapshot? _lastUserDoc;
  DocumentSnapshot? _lastGroupDoc;
  List<Map<String, dynamic>> _allUsers = [];
  List<DocumentSnapshot> _allGroups = [];
  bool _isLoadingMoreUsers = false;
  bool _isLoadingMoreGroups = false;
  bool _hasMoreUsers = true;
  bool _hasMoreGroups = true;
  
  //batch processing variables
  static const int _profileImageBatchSize = 10;
  final Map<String, Future<String>> _profileImageFutures = {};

  void _onSearchChanged(String value) {
    if (_searchDebounce?.isActive ?? false) _searchDebounce!.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 300), () {
      setState(() {
        _searchQuery = value.toLowerCase();
      });
    });
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
  showDialog(
    context: context,
    barrierDismissible: true,
    builder: (context) {
      final TextEditingController groupNameController = TextEditingController();
      final TextEditingController groupDescController = TextEditingController();

      return AlertDialog(
        title: const Text('Create New Group'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: groupNameController,
                decoration: const InputDecoration(
                  labelText: 'Group Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: groupDescController,
                decoration: const InputDecoration(
                  labelText: 'Description (optional)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    final groupName = groupNameController.text.trim();
                    final groupDesc = groupDescController.text.trim();

                    if (groupName.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Group name is required.')),
                      );
                      return;
                    }

                    final currentUser = _authenticationService.getCurrentUser;
                    if (currentUser == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('You must be logged in to create a group.'),
                        ),
                      );
                      return;
                    }

                    try {
                      // Create the group document in Firestore
                      final docRef = await FirebaseFirestore.instance
                          .collection('Groups')
                          .add({
                        'name': groupName,
                        'description': groupDesc.isNotEmpty ? groupDesc : null,
                        'createdBy': currentUser.uid,
                        'createdAt': FieldValue.serverTimestamp(),
                        'members': [currentUser.uid],
                        'type': 'group',
                      });

                      // Get the document snapshot from the returned reference
                      final newGroupDoc = await docRef.get();
                      
                      // Add to local state immediately
                      setState(() {
                        _allGroups.insert(0, newGroupDoc);
                      });

                      // Close dialog
                      Navigator.pop(context);

                      // Show success message
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Group "$groupName" created successfully!'),
                          backgroundColor: const Color(0xFF52B788),
                        ),
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Error creating group: $e'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF003A70),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('Create Group'),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

  // Load initial batch of users
  Future<void> _loadInitialUsers() async {
    setState(() {
      _isLoadingMoreUsers = true;
      _hasMoreUsers = true;
    });
    
    try {
      final query = FirebaseFirestore.instance
          .collection('Users')
          .limit(_usersPerPage);
      
      final snapshot = await query.get();
      
      if (snapshot.docs.isNotEmpty) {
        _lastUserDoc = snapshot.docs.last;
        _allUsers = snapshot.docs.map((doc) => doc.data()).toList();
        _hasMoreUsers = snapshot.docs.length == _usersPerPage;
        
        // Batch load profile images
        _batchLoadProfileImages(_allUsers);
      } else {
        _hasMoreUsers = false;
      }
    } catch (e) {
      print('Error loading users: $e');
      _hasMoreUsers = false;
    } finally {
      setState(() {
        _isLoadingMoreUsers = false;
      });
    }
  }

  // Load more users (pagination)
  Future<void> _loadMoreUsers() async {
    if (_isLoadingMoreUsers || !_hasMoreUsers) return;
    
    setState(() {
      _isLoadingMoreUsers = true;
    });
    
    try {
      Query query = FirebaseFirestore.instance
          .collection('Users')
          .limit(_usersPerPage);
      
      if (_lastUserDoc != null) {
        query = query.startAfterDocument(_lastUserDoc!);
      }
      
      final snapshot = await query.get();
      
      if (snapshot.docs.isNotEmpty) {
        _lastUserDoc = snapshot.docs.last;
        final newUsers = snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
        
        setState(() {
          _allUsers.addAll(newUsers);
        });
        
        // Batch load profile images for new users
        _batchLoadProfileImages(newUsers);
        
        _hasMoreUsers = snapshot.docs.length == _usersPerPage;
      } else {
        _hasMoreUsers = false;
      }
    } catch (e) {
      print('Error loading more users: $e');
    } finally {
      setState(() {
        _isLoadingMoreUsers = false;
      });
    }
  }

  // Batch load profile images
  void _batchLoadProfileImages(List<Map<String, dynamic>> users) {
    for (int i = 0; i < users.length; i += _profileImageBatchSize) {
      final batch = users.skip(i).take(_profileImageBatchSize).toList();
      
      for (final user in batch) {
        final uid = user['uid'];
        if (uid != null && !_profileImageCache.containsKey(uid)) {
          _preloadProfileImage(uid, user['photoURL']);
        }
      }
    }
  }

  // Preload profile image
  void _preloadProfileImage(String uid, String? fallbackUrl) {
    if (_profileImageFutures.containsKey(uid)) return;
    
    _profileImageFutures[uid] = _fetchProfileImageUrl(uid, fallbackUrl);
  }

  // Fetch profile image URL (optimized)
  Future<String> _fetchProfileImageUrl(String uid, String? fallbackUrl) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('Users')
          .doc(uid)
          .get();
      
      if (doc.exists) {
        final data = doc.data();
        if (data != null && 
            data['profileImageUrl'] != null && 
            data['profileImageUrl'] != "") {
          final url = data['profileImageUrl'] as String;
          _profileImageCache[uid] = url;
          return url;
        }
      }
    } catch (e) {
      print('Error fetching profile image: $e');
    }
    
    final result = fallbackUrl ?? '';
    _profileImageCache[uid] = result;
    return result;
  }

  // Get profile image URL (updated)
  Future<String> _getProfileImageUrl(String uid, String? fallbackUrl) async {
    // Check cache first
    if (_profileImageCache.containsKey(uid)) {
      return _profileImageCache[uid]!;
    }
    
    // Check if we have a pending future
    if (_profileImageFutures.containsKey(uid)) {
      final result = await _profileImageFutures[uid]!;
      _profileImageFutures.remove(uid);
      return result;
    }
    
    // Fetch immediately if not cached or pending
    return await _fetchProfileImageUrl(uid, fallbackUrl);
  }
  @override
  void initState() {
    super.initState();
    _searchQuery = widget.initialSearchQuery ?? '';
    _searchController = TextEditingController(text: _searchQuery);
    _loadInitialUsers();
  }
  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.dispose();
    _profileImageCache.clear();
    _profileImageFutures.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF283AA3),
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
                onChanged: _onSearchChanged,
              )
            : const Text(
                'xavLOG Chat',
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
                  color: Color(0xFF283AA3),
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
            labelColor: const Color(0xFF283AA3),
            unselectedLabelColor: Colors.grey,
            indicatorColor: const Color(0xFFBFA547),
            tabs: const [
              Tab(text: 'Contacts'),
              Tab(text: 'Groups'),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: _buildContactsList(context),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: _buildGroupsList(context),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Build contacts
  Widget _buildContactsList(BuildContext context) {
    final currentUserEmail = _authenticationService.getCurrentUser?.email;
    final currentUserId = _authenticationService.getCurrentUser?.uid;

    if (currentUserId == null) {
      return const Center(child: Text('Not logged in.'));
    }

    // Filter users based on search and exclude current user
    var filteredUsers = _allUsers.where((user) {
      final isNotCurrentUser = user['email'] != currentUserEmail;
      final matchesSearch = _searchQuery.isEmpty ||
          user['email'].toLowerCase().contains(_searchQuery) ||
          (user['displayName']?.toLowerCase().contains(_searchQuery) ?? false) ||
          (user['firstName']?.toLowerCase().contains(_searchQuery) ?? false) ||
          (user['lastName']?.toLowerCase().contains(_searchQuery) ?? false);
      return isNotCurrentUser && matchesSearch;
    }).toList();

    if (filteredUsers.isEmpty && !_isLoadingMoreUsers) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _searchQuery.isEmpty
                  ? 'No users found'
                  : 'No users match your search',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey),
            ),
            if (_hasMoreUsers) ...[
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadMoreUsers,
                child: const Text('Load More Users'),
              ),
            ],
          ],
        ),
      );
    }

    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _getFilteredUsersByChatHistory(
          filteredUsers, currentUserId, _searchQuery.isNotEmpty),
      builder: (context, sortedSnapshot) {
        if (sortedSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final finalUsers = sortedSnapshot.data ?? [];

        return NotificationListener<ScrollNotification>(
          onNotification: (ScrollNotification scrollInfo) {
            // Load more users when scrolling near the bottom
            if (scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent &&
                _hasMoreUsers &&
                !_isLoadingMoreUsers) {
              _loadMoreUsers();
            }
            return false;
          },
          child: ListView.separated(
            itemCount: finalUsers.length + (_hasMoreUsers ? 1 : 0),
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              // Show loading indicator at the bottom
              if (index == finalUsers.length) {
                return Container(
                  padding: const EdgeInsets.all(16),
                  alignment: Alignment.center,
                  child: _isLoadingMoreUsers
                      ? const CircularProgressIndicator()
                      : ElevatedButton(
                          onPressed: _loadMoreUsers,
                          child: const Text('Load More'),
                        ),
                );
              }

              final user = finalUsers[index];
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
                            ? Border.all(
                                color: const Color(0xFF003A70).withOpacity(0.3),
                                width: 1)
                            : Border.all(
                                color: Colors.grey.withOpacity(0.2),
                                width: 1),
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
                              // Show unread count
                              if (hasHistory && (user['unreadCount'] ?? 0) > 0)
                                Positioned(
                                  right: 0,
                                  top: 0,
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      color: Colors.red,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    constraints: const BoxConstraints(
                                      minWidth: 20,
                                      minHeight: 20,
                                    ),
                                    child: Text(
                                      '${user['unreadCount']}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      textAlign: TextAlign.center,
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
                                // Show last message for users with history
                                if (hasHistory && (user['lastMessage'] ?? '').isNotEmpty)
                                  Text(
                                    user['lastMessage'],
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  )
                                else if (displayName.isNotEmpty && displayName != email)
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
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        );
      },
    );
  }

//get users with chat history
  //MUCH more efficient
  Future<List<Map<String, dynamic>>> _getFilteredUsersByChatHistory(
    List<Map<String, dynamic>> allUsers,
    String currentUserId,
    bool showAllUsers,
  ) async {
    if (showAllUsers) {
      // When searching, show all users but prioritize those with history
      final recentChats = await RecentChatsService.getRecentChats(currentUserId);
      final recentChatUserIds = recentChats.map((c) => c['uid']).toSet();
      
      List<Map<String, dynamic>> usersWithHistory = [];
      List<Map<String, dynamic>> usersWithoutHistory = [];
      
      for (final user in allUsers) {
        final userWithFlag = Map<String, dynamic>.from(user);
        final hasHistory = recentChatUserIds.contains(user['uid']);
        userWithFlag['hasHistory'] = hasHistory;
        
        if (hasHistory) {
          // Get chat data from recent chats
          final chatData = recentChats.firstWhere(
            (c) => c['uid'] == user['uid'],
            orElse: () => {},
          );
          userWithFlag['lastMessage'] = chatData['lastMessage'] ?? '';
          userWithFlag['unreadCount'] = chatData['unreadCount'] ?? 0;
          usersWithHistory.add(userWithFlag);
        } else {
          usersWithoutHistory.add(userWithFlag);
        }
      }
      
      // Sort alphabetically
      usersWithHistory.sort((a, b) => _getUserName(a).compareTo(_getUserName(b)));
      usersWithoutHistory.sort((a, b) => _getUserName(a).compareTo(_getUserName(b)));
      
      return [...usersWithHistory, ...usersWithoutHistory];
    } else {
      // When not searching, only show users with recent chats
      return await RecentChatsService.getRecentChats(currentUserId);
    }
  }

  // Helper method to get user name for sorting
  String _getUserName(Map<String, dynamic> user) {
    return (user['displayName'] ?? user['firstName'] ?? user['email'] ?? '').toLowerCase();
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

// Load more groups method
Future<void> _loadMoreGroups() async {
  if (_isLoadingMoreGroups || !_hasMoreGroups) return;
  
  setState(() {
    _isLoadingMoreGroups = true;
  });
  
  try {
    final currentUser = _authenticationService.getCurrentUser;
    if (currentUser == null) return;

    Query query = FirebaseFirestore.instance
        .collection('Groups')
        .where('members', arrayContains: currentUser.uid)
        .limit(_groupsPerPage);
    
    if (_lastGroupDoc != null) {
      query = query.startAfterDocument(_lastGroupDoc!);
    }
    
    final snapshot = await query.get();
    
    if (snapshot.docs.isNotEmpty) {
      _lastGroupDoc = snapshot.docs.last;
      setState(() {
        _allGroups.addAll(snapshot.docs);
      });
      
      _hasMoreGroups = snapshot.docs.length == _groupsPerPage;
    } else {
      _hasMoreGroups = false;
    }
  } catch (e) {
    print('Error loading more groups: $e');
  } finally {
    setState(() {
      _isLoadingMoreGroups = false;
    });
  }
}


  void _showAddMemberDialog(DocumentSnapshot group, Map<String, dynamic> data) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            width: MediaQuery.of(context).size.width * 0.9,
            height: MediaQuery.of(context).size.height * 0.7,
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Add Members',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF283AA3),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // Search bar
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Search users...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.grey[50],
                  ),
                  onChanged: (value) {
                    // You can implement search functionality here
                  },
                ),
                
                const SizedBox(height: 16),
                
                // Users list
                Expanded(
                  child: FutureBuilder<List<Map<String, dynamic>>>(
                    future: _getAvailableUsersForGroup(data['members']),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      
                      final availableUsers = snapshot.data ?? [];
                      
                      if (availableUsers.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.people_outline,
                                size: 64,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No users available',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'All users are already members of this group',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[500],
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        );
                      }

                      return ListView.builder(
                        itemCount: availableUsers.length,
                        itemBuilder: (context, index) {
                          final user = availableUsers[index];
                          final displayName = user['displayName'] ?? user['firstName'] ?? '';
                          final email = user['email'] ?? '';
                          
                          return Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            elevation: 1,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              leading: FutureBuilder<String>(
                                future: _getProfileImageUrl(user['uid'], user['photoURL']),
                                builder: (context, imgSnapshot) {
                                  final profileImageUrl = imgSnapshot.data ?? '';
                                  return CircleAvatar(
                                    radius: 24,
                                    backgroundImage: profileImageUrl.isNotEmpty
                                        ? NetworkImage(profileImageUrl)
                                        : null,
                                    backgroundColor: const Color(0xFF283AA3),
                                    child: profileImageUrl.isEmpty
                                        ? Text(
                                            _getInitials(email, displayName),
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          )
                                        : null,
                                  );
                                },
                              ),
                              title: Text(
                                displayName.isNotEmpty ? displayName : email,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF1C1C1C),
                                ),
                              ),
                              subtitle: displayName.isNotEmpty && displayName != email
                                  ? Text(
                                      email,
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 13,
                                      ),
                                    )
                                  : null,
                              trailing: ElevatedButton(
                                onPressed: () => _addMemberToGroup(group, user['uid'], user),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF283AA3),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 8,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: const Text(
                                  'Add',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Get available users for group (with pagination)
  Future<List<Map<String, dynamic>>> _getAvailableUsersForGroup(List<dynamic> currentMembers) async {
    try {
      final List<Map<String, dynamic>> allAvailableUsers = [];
      
      // Get users in batches to avoid large queries
      const batchSize = 20;
      DocumentSnapshot? lastDoc;
      
      while (true) {
        Query query = FirebaseFirestore.instance
            .collection('Users')
            .limit(batchSize);
        
        if (lastDoc != null) {
          query = query.startAfterDocument(lastDoc);
        }
        
        final snapshot = await query.get();
        
        if (snapshot.docs.isEmpty) break;
        
        final batchUsers = snapshot.docs
            .map((doc) => doc.data() as Map<String, dynamic>)
            .where((user) => !currentMembers.contains(user['uid']))
            .toList();
        
        allAvailableUsers.addAll(batchUsers);
        
        // If we have enough users or this was the last batch, break
        if (snapshot.docs.length < batchSize || allAvailableUsers.length >= 50) {
          break;
        }
        
        lastDoc = snapshot.docs.last;
      }
      
      // Sort by display name
      allAvailableUsers.sort((a, b) {
        final nameA = a['displayName'] ?? a['firstName'] ?? a['email'] ?? '';
        final nameB = b['displayName'] ?? b['firstName'] ?? b['email'] ?? '';
        return nameA.toLowerCase().compareTo(nameB.toLowerCase());
      });
      
      // Return max 50 users to keep UI responsive
      return allAvailableUsers.take(50).toList();
      
    } catch (e) {
      print('Error getting available users: $e');
      return [];
    }
  }

  Future<void> _addMemberToGroup(DocumentSnapshot group, String userId, Map<String, dynamic> userData) async {
    try {
      await group.reference.update({
        'members': FieldValue.arrayUnion([userId])
      });
      
      // Update local state immediately
      final groupIndex = _allGroups.indexWhere((g) => g.id == group.id);
      if (groupIndex != -1) {
        // Force a rebuild to update member count
        setState(() {
          // The UI will refresh and show updated member count
        });
      }
      
      // Close the dialog
      Navigator.pop(context);
      
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${userData['displayName'] ?? userData['email']} added to group!',
          ),
          backgroundColor: const Color(0xFF52B788),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      );
    } catch (e) {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error adding member: $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      );
    }
  }

  Widget _buildGroupsList(BuildContext context) {
  final currentUser = _authenticationService.getCurrentUser;
  if (currentUser == null) {
    return const Center(child: Text('Not logged in.'));
  }

  return FutureBuilder<void>(
    future: _loadInitialGroups(),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting && _allGroups.isEmpty) {
        return const Center(child: CircularProgressIndicator());
      }

      if (_allGroups.isEmpty && !_isLoadingMoreGroups) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.group_outlined,
                size: 64,
                color: Colors.grey,
              ),
              const SizedBox(height: 16),
              const Text(
                'No groups yet.',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _createGroup,
                icon: const Icon(Icons.group_add),
                label: const Text('Create Your First Group'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF283AA3),
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        );
      }

      return NotificationListener<ScrollNotification>(
        onNotification: (ScrollNotification scrollInfo) {
          // Load more groups when scrolling near the bottom
          if (scrollInfo.metrics.pixels >= scrollInfo.metrics.maxScrollExtent * 0.8 &&
              _hasMoreGroups &&
              !_isLoadingMoreGroups) {
            _loadMoreGroups();
          }
          return false;
        },
        child: ListView.separated(
          itemCount: _allGroups.length + (_hasMoreGroups ? 1 : 0),
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            // Show loading indicator at the bottom
            if (index == _allGroups.length) {
              return Container(
                padding: const EdgeInsets.all(16),
                alignment: Alignment.center,
                child: _isLoadingMoreGroups
                    ? const CircularProgressIndicator()
                    : ElevatedButton(
                        onPressed: _loadMoreGroups,
                        child: const Text('Load More Groups'),
                      ),
              );
            }

            final group = _allGroups[index];
            final data = group.data() as Map<String, dynamic>;
            final isMember = (data['members'] as List).contains(currentUser.uid);
            final memberCount = (data['members'] as List).length;
            
            return Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.withOpacity(0.2)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                leading: Stack(
                  children: [
                    CircleAvatar(
                      backgroundColor: const Color(0xFF283AA3),
                      radius: 24,
                      child: Text(
                        (data['name'] ?? 'G')[0].toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ),
                    if (memberCount > 1)
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: const Color(0xFF52B788),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 16,
                            minHeight: 16,
                          ),
                          child: Text(
                            '$memberCount',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                  ],
                ),
                title: Text(
                  data['name'] ?? 'Unnamed Group',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1C1C1C),
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (data['description'] != null && data['description'].toString().isNotEmpty)
                      Text(
                        data['description'],
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 13,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.people,
                          size: 14,
                          color: Colors.grey[500],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '$memberCount ${memberCount == 1 ? 'member' : 'members'}',
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 12,
                          ),
                        ),
                        if (data['createdBy'] == currentUser.uid) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFF283AA3).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'Admin',
                              style: TextStyle(
                                color: Color(0xFF283AA3),
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Add member button (only for members)
                    if (isMember)
                      IconButton(
                        icon: const Icon(
                          Icons.person_add_alt_1,
                          color: Color(0xFF003A70),
                          size: 20,
                        ),
                        tooltip: 'Add People',
                        onPressed: () => _showAddMemberDialog(group, data),
                      ),
                    // More options button
                    IconButton(
                      icon: const Icon(
                        Icons.more_vert,
                        color: Colors.grey,
                        size: 20,
                      ),
                      onPressed: () => _showGroupOptions(group, data),
                    ),
                  ],
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
              ),
            );
          },
        ),
      );
    },
  );
}

// Add initial groups loading method
Future<void> _loadInitialGroups() async {
  if (_allGroups.isNotEmpty) return; // Already loaded
  
  final currentUser = _authenticationService.getCurrentUser;
  if (currentUser == null) return;

  setState(() {
    _isLoadingMoreGroups = true;
    _hasMoreGroups = true;
  });

  try {
    final query = FirebaseFirestore.instance
        .collection('Groups')
        .where('members', arrayContains: currentUser.uid)
        .limit(_groupsPerPage);

    final snapshot = await query.get();

    if (snapshot.docs.isNotEmpty) {
      _lastGroupDoc = snapshot.docs.last;
      _allGroups = snapshot.docs;
      _hasMoreGroups = snapshot.docs.length == _groupsPerPage;
    } else {
      _hasMoreGroups = false;
    }
  } catch (e) {
    print('Error loading initial groups: $e');
    _hasMoreGroups = false;
  } finally {
    setState(() {
      _isLoadingMoreGroups = false;
    });
  }
}

// Add group options dialog
void _showGroupOptions(DocumentSnapshot group, Map<String, dynamic> data) {
  final currentUser = _authenticationService.getCurrentUser;
  if (currentUser == null) return;

  final isAdmin = data['createdBy'] == currentUser.uid;
  final isMember = (data['members'] as List).contains(currentUser.uid);

  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) {
      return Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            
            Text(
              data['name'] ?? 'Unnamed Group',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1C1C1C),
              ),
            ),
            const SizedBox(height: 20),

            // Options
            if (isMember) ...[
              _buildOptionTile(
                icon: Icons.person_add_alt_1,
                title: 'Add Member',
                onTap: () {
                  Navigator.pop(context);
                  _showAddMemberDialog(group, data);
                },
              ),
              _buildOptionTile(
                icon: Icons.people,
                title: 'View Members',
                onTap: () {
                  Navigator.pop(context);
                  _showGroupMembers(data);
                },
              ),
            ],
            
            if (isAdmin) ...[
              _buildOptionTile(
                icon: Icons.edit,
                title: 'Edit Group',
                onTap: () {
                  Navigator.pop(context);
                  _editGroup(group, data);
                },
              ),
              _buildOptionTile(
                icon: Icons.delete,
                title: 'Delete Group',
                color: Colors.red,
                onTap: () {
                  Navigator.pop(context);
                  _deleteGroup(group, data);
                },
              ),
            ] else if (isMember) ...[
              _buildOptionTile(
                icon: Icons.exit_to_app,
                title: 'Leave Group',
                color: Colors.red,
                onTap: () {
                  Navigator.pop(context);
                  _leaveGroup(group, data);
                },
              ),
            ],
            
            const SizedBox(height: 10),
          ],
        ),
      );
    },
  );
}

// Helper method for option tiles
Widget _buildOptionTile({
  required IconData icon,
  required String title,
  required VoidCallback onTap,
  Color? color,
}) {
  return ListTile(
    leading: Icon(icon, color: color ?? const Color(0xFF283AA3)),
    title: Text(
      title,
      style: TextStyle(
        color: color ?? const Color(0xFF1C1C1C),
        fontWeight: FontWeight.w500,
      ),
    ),
    onTap: onTap,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
    ),
  );
}

// Add group members dialog
void _showGroupMembers(Map<String, dynamic> data) {
  final members = data['members'] as List;
  
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text('${data['name']} Members'),
        content: SizedBox(
          width: double.maxFinite,
          child: FutureBuilder<List<Map<String, dynamic>>>(
            future: _getGroupMembers(members),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              
              final memberDetails = snapshot.data ?? [];
              
              return ListView.builder(
                shrinkWrap: true,
                itemCount: memberDetails.length,
                itemBuilder: (context, index) {
                  final member = memberDetails[index];
                  final isAdmin = member['uid'] == data['createdBy'];
                  
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundImage: member['profileImageUrl'] != null
                          ? NetworkImage(member['profileImageUrl'])
                          : null,
                      backgroundColor: const Color(0xFF283AA3),
                      child: member['profileImageUrl'] == null
                          ? Text(
                              (member['displayName'] ?? member['email'] ?? 'U')[0].toUpperCase(),
                              style: const TextStyle(color: Colors.white),
                            )
                          : null,
                    ),
                    title: Text(member['displayName'] ?? member['email'] ?? 'Unknown'),
                    subtitle: isAdmin ? const Text('Admin') : null,
                    trailing: isAdmin
                        ? const Icon(Icons.admin_panel_settings, color: Color(0xFF283AA3))
                        : null,
                  );
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      );
    },
  );
}

// Get group members details
Future<List<Map<String, dynamic>>> _getGroupMembers(List<dynamic> memberIds) async {
  try {
    final List<Map<String, dynamic>> members = [];
    
    // Process in batches of 10 (Firestore limit)
    for (int i = 0; i < memberIds.length; i += 10) {
      final batch = memberIds.skip(i).take(10).toList();
      final snapshot = await FirebaseFirestore.instance
          .collection('Users')
          .where('uid', whereIn: batch)
          .get();
      
      members.addAll(snapshot.docs.map((doc) => doc.data()));
    }
    
    return members;
  } catch (e) {
    print('Error getting group members: $e');
    return [];
  }
}

// Edit group method
void _editGroup(DocumentSnapshot group, Map<String, dynamic> data) {
  final nameController = TextEditingController(text: data['name']);
  final descController = TextEditingController(text: data['description'] ?? '');

  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Edit Group'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Group Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: descController,
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final newName = nameController.text.trim();
              if (newName.isNotEmpty) {
                try {
                  await group.reference.update({
                    'name': newName,
                    'description': descController.text.trim(),
                  });
                  
                  // Update local state immediately
                  setState(() {
                    // This will trigger UI refresh with updated group info
                  });
                  
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Group updated successfully!')),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error updating group: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: const Text('Update'),
          ),
        ],
      );
    },
  );
}

// Delete group method
// Delete group method
void _deleteGroup(DocumentSnapshot group, Map<String, dynamic> data) {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Delete Group'),
        content: Text('Are you sure you want to delete "${data['name']}"? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await group.reference.delete();
                
                // Remove from local state immediately
                setState(() {
                  _allGroups.removeWhere((g) => g.id == group.id);
                });
                
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Group deleted successfully!')),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error deleting group: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      );
    },
  );
}

// Leave group method
void _leaveGroup(DocumentSnapshot group, Map<String, dynamic> data) {
  final currentUser = _authenticationService.getCurrentUser;
  if (currentUser == null) return;

  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Leave Group'),
        content: Text('Are you sure you want to leave "${data['name']}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              await group.reference.update({
                'members': FieldValue.arrayRemove([currentUser.uid])
              });
              setState(() {
                _allGroups.removeWhere((g) => g.id == group.id);
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Left group successfully!')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Leave'),
          ),
        ],
      );
    },
  );
}
}

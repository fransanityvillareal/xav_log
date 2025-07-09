import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:dropdown_search/dropdown_search.dart';

class ChatSetting extends StatefulWidget {
  const ChatSetting({Key? key}) : super(key: key);

  @override
  State<ChatSetting> createState() => _ChatSettingState();
}

class _ChatSettingState extends State<ChatSetting> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> _blockUser(String userId) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return;

    try {
      await FirebaseFirestore.instance
          .collection('Users')
          .doc(currentUser.uid)
          .update({
        'blockedUsers': FieldValue.arrayUnion([userId]),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User blocked successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to block user: $e')),
      );
    }
  }

  Future<List<Map<String, String>>> _fetchUsers() async {
    try {
      final querySnapshot =
          await FirebaseFirestore.instance.collection('Users').get();

      final users = querySnapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          'name': (data['firstName'] ?? 'Unknown').toString(),
          'lastName': (data['lastName'] ?? 'No Last Name').toString(),
          'email': (data['email'] ?? 'No Email').toString(),
        };
      }).toList();

      // Debugging: Print fetched users
      debugPrint('Fetched users: $users');

      return users;
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to fetch users: $e')),
      );
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Block User',
          style:
              TextStyle(color: Colors.white), // Set app bar text color to white
        ),
        iconTheme: const IconThemeData(
            color: Colors.white), // Set back icon color to white
        backgroundColor: const Color(0xFF003A70),
      ),
      body: FutureBuilder<List<Map<String, String>>>(
        future: _fetchUsers(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError ||
              !snapshot.hasData ||
              snapshot.data!.isEmpty) {
            return const Center(child: Text('No users available to block.'));
          }

          final users = snapshot.data!;

          return ListView(
            children: [
              ListTile(
                leading: const Icon(Icons.block),
                title: const Text('Block User'),
                onTap: () async {
                  String? selectedUserId;
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      backgroundColor: Colors.white,
                      title: const Text('Block User'),
                      content: SizedBox(
                        width: MediaQuery.of(context).size.width * 0.8,
                        child: DropdownSearch<Map<String, String>>(
                          items: users,
                          itemAsString: (user) =>
                              '${user['name']} ${user['lastName']} (${user['email']})',
                          onChanged: (value) {
                            selectedUserId = value?['id'];
                          },
                          dropdownDecoratorProps: const DropDownDecoratorProps(
                            dropdownSearchDecoration: InputDecoration(
                              labelText: 'Select User',
                              border: OutlineInputBorder(),
                            ),
                          ),
                          popupProps: const PopupProps.menu(
                            showSearchBox: true,
                            fit: FlexFit.loose,
                          ),
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Cancel'),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                const Color.fromARGB(255, 255, 255, 255),
                          ),
                          onPressed: () async {
                            if (selectedUserId != null) {
                              await _blockUser(selectedUserId!);
                              Navigator.pop(context);
                            }
                          },
                          child: const Text('Block'),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }
}

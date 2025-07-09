import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ViewGroupPage extends StatelessWidget {
  const ViewGroupPage({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      return const Scaffold(
        body: Center(
          child: Text('You must be logged in to view groups.'),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'View Groups',
          style:
              TextStyle(color: Colors.white), // Set app bar text color to white
        ),
        iconTheme: const IconThemeData(
            color: Colors.white), // Set back icon color to white
        backgroundColor: const Color(0xFF003A70),
      ),
      body: StreamBuilder<QuerySnapshot>(
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
            return const Center(child: Text('You are not part of any groups.'));
          }

          return ListView.builder(
            itemCount: groups.length,
            itemBuilder: (context, index) {
              final group = groups[index];
              final data = group.data() as Map<String, dynamic>;

              return ListTile(
                title: Text(data['name'] ?? 'Unnamed Group'),
                subtitle: (data['description'] != null &&
                        data['description'].toString().isNotEmpty)
                    ? Text(data['description'])
                    : null,
                trailing: IconButton(
                  icon: const Icon(Icons.exit_to_app, color: Colors.red),
                  tooltip: 'Leave Group',
                  onPressed: () async {
                    try {
                      await FirebaseFirestore.instance
                          .collection('Groups')
                          .doc(group.id)
                          .update({
                        'members': FieldValue.arrayRemove([currentUser.uid]),
                      });

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('You have left the group.'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Error leaving group: $e'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}

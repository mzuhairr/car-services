import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/user_model.dart';
import '../../services/firestore_service.dart';

class ManageUsersPage extends StatelessWidget {
  final FirestoreService _firestoreService = FirestoreService();

  ManageUsersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Users'),
        backgroundColor: Colors.green,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('users').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No users found'));
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final doc = snapshot.data!.docs[index];
              final Map<String, dynamic> data =
                  doc.data() as Map<String, dynamic>;
              data['uid'] = doc.id; // Add the document ID as uid
              final user = UserModel.fromMap(data);

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  title: Text(user.email),
                  subtitle: Text(user.name),
                  trailing: Switch(
                    value: user.isAdmin,
                    activeColor: Colors.green,
                    onChanged: (bool value) {
                      _firestoreService.setUserAsAdmin(user.uid, value);
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

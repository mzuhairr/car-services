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
            return const Center(child: Text('Something went wrong'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final doc = snapshot.data!.docs[index];
              final user =
                  UserModel.fromMap(doc.data() as Map<String, dynamic>);

              return ListTile(
                title: Text(user.email),
                subtitle: Text(user.name),
                trailing: Switch(
                  value: user.isAdmin,
                  onChanged: (bool value) {
                    _firestoreService.setUserAsAdmin(user.uid, value);
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

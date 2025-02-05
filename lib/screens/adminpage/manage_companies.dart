import 'package:flutter/material.dart';
import '../../services/firestore_service.dart';
import '../../models/insurance_company.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ManageCompaniesPage extends StatefulWidget {
  const ManageCompaniesPage({super.key});

  @override
  State<ManageCompaniesPage> createState() => _ManageCompaniesPageState();
}

class _ManageCompaniesPageState extends State<ManageCompaniesPage> {
  final FirestoreService _firestoreService = FirestoreService();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Insurance Companies'),
        backgroundColor: Colors.green,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddCompanyDialog,
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('insurance_companies')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Something went wrong'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final companies = snapshot.data!.docs
              .map((doc) => InsuranceCompany.fromMap(
                  doc.id, doc.data() as Map<String, dynamic>))
              .toList();

          return ListView.builder(
            itemCount: companies.length,
            itemBuilder: (context, index) {
              final company = companies[index];
              return ListTile(
                title: Text(company.name),
                subtitle: Text(company.description ?? ''),
                trailing: IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () => _deleteCompany(company.id!),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _showAddCompanyDialog() async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Insurance Company'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Company Name'),
            ),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'Description'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              await _firestoreService.addInsuranceCompany(
                InsuranceCompany(
                  name: _nameController.text,
                  description: _descriptionController.text,
                  location: 'Khartoum',
                ),
              );
              Navigator.pop(context);
              _nameController.clear();
              _descriptionController.clear();
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteCompany(String id) async {
    await FirebaseFirestore.instance
        .collection('insurance_companies')
        .doc(id)
        .delete();
  }
}

import 'package:flutter/material.dart';

class CustomersPage extends StatelessWidget {
  final Map<String, dynamic> companyData;
  final bool isDarkMode;

  const CustomersPage({
    super.key,
    required this.companyData,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Customers'),
      ),
      body: const Center(
        child: Text('Customers Page'),
      ),
    );
  }
}

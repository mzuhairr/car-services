import 'package:flutter/material.dart';

class AppointmentsPage extends StatelessWidget {
  final Map<String, dynamic> companyData;
  final bool isDarkMode;

  const AppointmentsPage({
    super.key,
    required this.companyData,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Appointments'),
      ),
      body: const Center(
        child: Text('Appointments Page'),
      ),
    );
  }
}

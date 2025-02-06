import 'package:flutter/material.dart';

class AnalyticsPage extends StatelessWidget {
  final Map<String, dynamic> companyData;
  final bool isDarkMode;

  const AnalyticsPage({
    super.key,
    required this.companyData,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Analytics'),
      ),
      body: const Center(
        child: Text('Analytics Page'),
      ),
    );
  }
}

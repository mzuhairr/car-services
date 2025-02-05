import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';
import '../auth/login_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AppointmentCard extends StatelessWidget {
  final Map<String, dynamic> appointment;
  final bool isCompleted;

  const AppointmentCard({
    super.key,
    required this.appointment,
    required this.isCompleted,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Card(
      color: isDark ? Colors.grey[800] : Colors.white,
      child: ListTile(
        title: Text(
          appointment['serviceName'] ?? 'Unknown Service',
          style: TextStyle(color: isDark ? Colors.white : Colors.black87),
        ),
        subtitle: Text(
          'Date: ${appointment['date']}',
          style: TextStyle(color: isDark ? Colors.grey[300] : Colors.black54),
        ),
        trailing: Icon(
          isCompleted ? Icons.check_circle : Icons.pending,
          color: isCompleted ? Colors.green : Colors.orange,
        ),
      ),
    );
  }
}

class CustomerListItem extends StatelessWidget {
  final String customerId;

  const CustomerListItem({
    super.key,
    required this.customerId,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return FutureBuilder<DocumentSnapshot>(
      future:
          FirebaseFirestore.instance.collection('users').doc(customerId).get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox();

        final userData = snapshot.data?.data() as Map<String, dynamic>?;
        return ListTile(
          leading: Icon(Icons.person,
              color: isDark ? Colors.white70 : Colors.black54),
          title: Text(
            userData?['name'] ?? 'Unknown User',
            style: TextStyle(color: isDark ? Colors.white : Colors.black87),
          ),
          subtitle: Text(
            userData?['email'] ?? '',
            style: TextStyle(color: isDark ? Colors.grey[300] : Colors.black54),
          ),
        );
      },
    );
  }
}

class InsuranceCompanyDashboard extends StatefulWidget {
  final String companyName;
  final Map<String, dynamic>? companyData;

  const InsuranceCompanyDashboard({
    super.key,
    required this.companyName,
    this.companyData,
  });

  @override
  State<InsuranceCompanyDashboard> createState() =>
      _InsuranceCompanyDashboardState();
}

class _InsuranceCompanyDashboardState extends State<InsuranceCompanyDashboard> {
  final _authService = AuthService();
  bool _isDarkMode = true;

  Future<void> _signOut() async {
    bool? confirmLogout = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Logout'),
          content: const Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );

    if (confirmLogout == true) {
      await _authService.signOut();
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginPage()),
        );
      }
    }
  }

  void _toggleTheme() {
    setState(() {
      _isDarkMode = !_isDarkMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    final appointments =
        (widget.companyData?['appointments'] as List<dynamic>?) ?? [];
    final completedAppointments =
        appointments.where((a) => a['isCompleted'] == true).toList();
    final pendingAppointments =
        appointments.where((a) => a['isCompleted'] == false).toList();
    final customers =
        (widget.companyData?['customers'] as List<dynamic>?) ?? [];

    return Scaffold(
      backgroundColor: _isDarkMode ? Colors.grey[900] : Colors.white,
      appBar: AppBar(
        backgroundColor: _isDarkMode ? Colors.green[700] : Colors.green,
        title: Text(widget.companyName),
        actions: [
          IconButton(
            icon: Icon(
              _isDarkMode ? Icons.light_mode : Icons.dark_mode,
              color: Colors.white,
            ),
            onPressed: _toggleTheme,
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: _signOut,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Completed Appointments (${completedAppointments.length})',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: _isDarkMode ? Colors.white : Colors.black87,
                  ),
            ),
            ...completedAppointments.map((appointment) => AppointmentCard(
                  appointment: appointment,
                  isCompleted: true,
                )),
            const SizedBox(height: 24),
            Text(
              'Pending Appointments (${pendingAppointments.length})',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: _isDarkMode ? Colors.white : Colors.black87,
                  ),
            ),
            ...pendingAppointments.map((appointment) => AppointmentCard(
                  appointment: appointment,
                  isCompleted: false,
                )),
            const SizedBox(height: 24),
            Text(
              'Customers (${customers.length})',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: _isDarkMode ? Colors.white : Colors.black87,
                  ),
            ),
            ...customers
                .map((customerId) => CustomerListItem(customerId: customerId)),
          ],
        ),
      ),
    );
  }
}

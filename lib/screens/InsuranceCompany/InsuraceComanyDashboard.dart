import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';
import '../auth/login_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/insurance_company.dart';

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
    if (customerId.isEmpty) return const SizedBox();

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

class _InsuranceCompanyDashboardState extends State<InsuranceCompanyDashboard>
    with SingleTickerProviderStateMixin {
  final _authService = AuthService();
  bool _isDarkMode = true;
  late Map<String, dynamic> _companyData;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _companyData = Map<String, dynamic>.from(widget.companyData ?? {});
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  final Map<String, List<String>> carServices = {
    'General Repairs': [
      'Engine Repair',
      'Transmission Service',
      'Brake Service',
      'Oil Change',
      'Battery Service',
      'AC Service',
    ],
    'Body Repairs': [
      'Bumper Repair',
      'Bumper Replacement',
      'Scratch Painting',
      'Dent Removal',
      'Panel Replacement',
      'Paint Touch-up',
    ],
    'Tire Services': [
      'Tire Rotation',
      'Tire Replacement',
      'Wheel Alignment',
      'Tire Balancing',
      'Flat Tire Repair',
      'Tire Pressure Check',
    ],
  };

  Future<void> _updateServicePrice(String serviceName, double newPrice) async {
    try {
      final currentUser = _authService.getCurrentUser();
      if (currentUser == null) {
        throw Exception('No authenticated user found');
      }

      // Get user data from Firestore to get the insuranceCompanyId
      final userData = await _authService.getUserData();
      final companyId = userData?['insuranceCompanyId'];

      if (companyId == null) {
        throw Exception('No company ID found for user');
      }

      final companyDoc = FirebaseFirestore.instance
          .collection('InsuranceCompany')
          .doc(companyId);

      // First check if the document exists
      final docSnapshot = await companyDoc.get();

      if (!docSnapshot.exists) {
        // If document doesn't exist, create it with initial data
        await companyDoc.set({
          'name': widget.companyName,
          'servicesPricing': {
            serviceName: newPrice,
          },
          'appointments': [],
          'customers': []
        });
      } else {
        // If document exists, update it
        await companyDoc.update({
          'servicesPricing.$serviceName': newPrice,
        });
      }

      // After successful update, update the local state
      setState(() {
        if (_companyData['servicesPricing'] == null) {
          _companyData['servicesPricing'] = {};
        }
        _companyData['servicesPricing'][serviceName] = newPrice;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Price updated successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating price: $e')),
        );
      }
    }
  }

  Widget _buildServicePricingSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Service Pricing',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: _isDarkMode ? Colors.white : Colors.black87,
              ),
        ),
        const SizedBox(height: 16),
        ...carServices.entries.map((category) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  category.key,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: _isDarkMode ? Colors.white70 : Colors.black87,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                ...category.value.map((service) => Card(
                      color: _isDarkMode ? Colors.grey[800] : Colors.white,
                      child: ListTile(
                        title: Text(
                          service,
                          style: TextStyle(
                            color: _isDarkMode ? Colors.white : Colors.black87,
                          ),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '\$${(_companyData['servicesPricing']?[service] ?? 0).toStringAsFixed(2)}',
                              style: TextStyle(
                                color: _isDarkMode
                                    ? Colors.white70
                                    : Colors.black87,
                              ),
                            ),
                            IconButton(
                              icon: Icon(
                                Icons.edit,
                                color: _isDarkMode
                                    ? Colors.white70
                                    : Colors.black54,
                              ),
                              onPressed: () async {
                                final controller = TextEditingController(
                                  text: (widget.companyData?['servicesPricing']
                                              ?[service] ??
                                          0)
                                      .toString(),
                                );
                                await showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: Text('Update price for $service'),
                                    content: TextField(
                                      controller: controller,
                                      keyboardType: TextInputType.number,
                                      decoration: const InputDecoration(
                                        prefixText: '\$',
                                        hintText: 'Enter new price',
                                      ),
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: const Text('Cancel'),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          final newPrice =
                                              double.tryParse(controller.text);
                                          if (newPrice != null) {
                                            _updateServicePrice(
                                                service, newPrice);
                                          }
                                          Navigator.pop(context);
                                        },
                                        child: const Text('Update'),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    )),
                const SizedBox(height: 16),
              ],
            )),
      ],
    );
  }

  Widget _buildAppointmentsSection() {
    final appointments =
        (widget.companyData?['appointments'] as List<dynamic>?) ?? [];
    final completedAppointments =
        appointments.where((a) => a['isCompleted'] == true).toList();
    final pendingAppointments =
        appointments.where((a) => a['isCompleted'] == false).toList();

    return Column(
      children: [
        TabBar(
          controller: _tabController,
          labelColor: _isDarkMode ? Colors.white : Colors.black87,
          tabs: const [
            Tab(text: 'All'),
            Tab(text: 'Pending'),
            Tab(text: 'Completed'),
          ],
        ),
        SizedBox(
          height: 300, // Adjust height as needed
          child: TabBarView(
            controller: _tabController,
            children: [
              // All Appointments
              ListView(
                children: [
                  ...appointments.map((appointment) => AppointmentCard(
                        appointment: appointment,
                        isCompleted: appointment['isCompleted'] ?? false,
                      )),
                ],
              ),
              // Pending Appointments
              ListView(
                children: [
                  ...pendingAppointments.map((appointment) => AppointmentCard(
                        appointment: appointment,
                        isCompleted: false,
                      )),
                ],
              ),
              // Completed Appointments
              ListView(
                children: [
                  ...completedAppointments.map((appointment) => AppointmentCard(
                        appointment: appointment,
                        isCompleted: true,
                      )),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

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
            _buildServicePricingSection(),
            const SizedBox(height: 24),
            Text(
              'Appointments',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: _isDarkMode ? Colors.white : Colors.black87,
                  ),
            ),
            const SizedBox(height: 16),
            _buildAppointmentsSection(),
            const SizedBox(height: 24),
            Text(
              'Customers',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: _isDarkMode ? Colors.white : Colors.black87,
                  ),
            ),
            ...((widget.companyData?['customers'] as List<dynamic>?) ?? [])
                .where((customerId) => customerId.isNotEmpty)
                .map((customerId) => CustomerListItem(customerId: customerId)),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../auth/login_page.dart';
import '../appointment/appointment_booking.dart';
import '../../models/insurance_company.dart';
import '../../services/firestore_service.dart';
import '../adminpage/manage_users.dart';
import '../adminpage/manage_companies.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.title});

  final String title;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _authService = AuthService();
  late InsuranceCompany userInsuranceCompany;
  final _firestoreService = FirestoreService();
  bool _isDarkMode = true;

  @override
  void initState() {
    super.initState();
    userInsuranceCompany = InsuranceCompany(
        name: 'Loading...', location: 'Loading...', description: 'Loading...');
    _loadInsuranceData();
  }

  Future<void> _loadInsuranceData() async {
    try {
      final userId = _authService.currentUser?.uid;
      if (userId != null) {
        final company = await _firestoreService.getUserInsuranceCompany(userId);
        if (company != null) {
          setState(() {
            userInsuranceCompany = company;
          });
        }
      }
    } catch (e) {
      // Handle error - you might want to show a snackbar or dialog
      debugPrint('Error loading insurance data: $e');
    }
  }

  // Car service categories with their specific services
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

  Future<void> _signOut() async {
    // Show confirmation dialog
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

    // Proceed with logout if confirmed
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
      backgroundColor: _isDarkMode ? Colors.black : Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: Text(
          widget.title,
          style: const TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: Icon(
              _isDarkMode ? Icons.light_mode : Icons.dark_mode,
              color: Colors.white,
            ),
            onPressed: _toggleTheme,
          ),
          FutureBuilder<bool>(
            future: _firestoreService
                .isUserAdmin(_authService.currentUser?.uid ?? ''),
            builder: (context, snapshot) {
              if (snapshot.data == true) {
                return PopupMenuButton(
                  icon: const Icon(Icons.more_vert, color: Colors.white),
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      child: const Text('Manage Companies'),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ManageCompaniesPage(),
                          ),
                        );
                      },
                    ),
                    PopupMenuItem(
                      child: const Text('Manage Users'),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ManageUsersPage(),
                          ),
                        );
                      },
                    ),
                    PopupMenuItem(
                      child: const Text('Logout'),
                      onTap: () => _signOut(),
                    ),
                  ],
                );
              }
              return PopupMenuButton(
                icon: const Icon(Icons.more_vert, color: Colors.white),
                itemBuilder: (context) => [
                  PopupMenuItem(
                    child: const Text('Logout'),
                    onTap: () => _signOut(),
                  ),
                ],
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _isDarkMode ? Colors.grey[900] : Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.green, width: 2),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Your Insurance Provider:',
                  style: TextStyle(
                    color: Colors.green,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  userInsuranceCompany.name,
                  style: TextStyle(
                    color: _isDarkMode ? Colors.white : Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(
                      Icons.location_on,
                      size: 16,
                      color: Colors.green,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      userInsuranceCompany.location,
                      style: TextStyle(
                        color: _isDarkMode ? Colors.white70 : Colors.black87,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: carServices.length,
              itemBuilder: (context, index) {
                String category = carServices.keys.elementAt(index);
                List<String> services = carServices[category]!;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      margin: const EdgeInsets.only(bottom: 10),
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        category,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        childAspectRatio: 1.5,
                      ),
                      itemCount: services.length,
                      itemBuilder: (context, serviceIndex) {
                        return Card(
                          elevation: 4,
                          color: _isDarkMode ? Colors.grey[850] : Colors.white,
                          child: InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      AppointmentBookingScreen(
                                    serviceCategory: category,
                                    serviceName: services[serviceIndex],
                                    company:
                                        userInsuranceCompany, // Get this from user data
                                  ),
                                ),
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: _isDarkMode
                                    ? Colors.grey[850]
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    _getIconForService(services[serviceIndex]),
                                    size: 32,
                                    color: _isDarkMode
                                        ? Colors.white
                                        : Colors.green,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    services[serviceIndex],
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: _isDarkMode
                                          ? Colors.white
                                          : Colors.black,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 20),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  IconData _getIconForService(String service) {
    switch (service.toLowerCase()) {
      case 'engine repair':
        return Icons.engineering;
      case 'transmission service':
        return Icons.settings;
      case 'brake service':
        return Icons.do_not_disturb_on;
      case 'oil change':
        return Icons.opacity;
      case 'battery service':
        return Icons.battery_charging_full;
      case 'ac service':
        return Icons.ac_unit;
      case 'bumper repair':
      case 'bumper replacement':
        return Icons.car_repair;
      case 'scratch painting':
      case 'paint touch-up':
        return Icons.format_paint;
      case 'dent removal':
      case 'panel replacement':
        return Icons.build;
      case 'tire rotation':
      case 'tire replacement':
      case 'wheel alignment':
      case 'tire balancing':
      case 'flat tire repair':
      case 'tire pressure check':
        return Icons.tire_repair;
      default:
        return Icons.miscellaneous_services;
    }
  }
}

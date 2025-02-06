import 'package:flutter/material.dart';
import '../../../models/insurance_company.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AppointmentBookingScreen extends StatefulWidget {
  final String serviceCategory;
  final String serviceName;
  final InsuranceCompany company;

  const AppointmentBookingScreen({
    super.key,
    required this.serviceCategory,
    required this.serviceName,
    required this.company,
  });

  @override
  State<AppointmentBookingScreen> createState() =>
      _AppointmentBookingScreenState();
}

class _AppointmentBookingScreenState extends State<AppointmentBookingScreen> {
  DateTime selectedDate = DateTime.now();
  TimeOfDay selectedTime = TimeOfDay.now();
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: selectedTime,
    );
    if (picked != null && picked != selectedTime) {
      setState(() {
        selectedTime = picked;
      });
    }
  }

  Future<void> _createAppointment() async {
    try {
      // Get current user
      final User? currentUser = _auth.currentUser;
      if (currentUser == null) throw Exception('No user logged in');

      // Get user document to access insuranceCompanyId
      final userDoc =
          await _firestore.collection('users').doc(currentUser.uid).get();
      final userData = userDoc.data() as Map<String, dynamic>;
      final String companyId = userData['insuranceCompanyId'] ?? '';

      // Create new appointment document
      final appointmentRef = _firestore.collection('Appointments').doc();
      final appointment = {
        'userId': currentUser.uid,
        'companyId': companyId,
        'serviceCategory': widget.serviceCategory,
        'serviceName': widget.serviceName,
        'date': Timestamp.fromDate(DateTime(
          selectedDate.year,
          selectedDate.month,
          selectedDate.day,
          selectedTime.hour,
          selectedTime.minute,
        )),
        'description': _descriptionController.text,
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
      };

      // Start a batch write
      final batch = _firestore.batch();

      // Create the appointment
      batch.set(appointmentRef, appointment);

      // Add appointment reference to user's myAppointments
      batch.update(
        _firestore.collection('users').doc(currentUser.uid),
        {
          'myAppointments': FieldValue.arrayUnion([appointmentRef.id])
        },
      );

      // Add appointment reference to company's myAppointments
      batch.update(
        _firestore.collection('InsuranceCompany').doc(companyId),
        {
          'myAppointments': FieldValue.arrayUnion([appointmentRef.id])
        },
      );

      // Commit the batch
      await batch.commit();
    } catch (e) {
      debugPrint('Error creating appointment: $e');
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    final price = widget.company.servicesPricing[widget.serviceName] ?? 0.0;

    // Debug prints
    print('Service Name from widget: ${widget.serviceName}');
    print(
        'All available services in company: ${widget.company.servicesPricing.keys.toList()}');
    print('Price found: $price');
    print('All prices: ${widget.company.servicesPricing}');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Book Appointment'),
        backgroundColor: Colors.green,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Service: ${widget.serviceName}',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                'Price: \$${price.toStringAsFixed(2)}',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 20),
              ListTile(
                title: Text('Date: ${selectedDate.toString().split(' ')[0]}'),
                trailing: const Icon(Icons.calendar_today),
                onTap: () => _selectDate(context),
              ),
              ListTile(
                title: Text('Time: ${selectedTime.format(context)}'),
                trailing: const Icon(Icons.access_time),
                onTap: () => _selectTime(context),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Additional Details',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please provide some details about the service needed';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      try {
                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (context) =>
                              const Center(child: CircularProgressIndicator()),
                        );

                        await _createAppointment();

                        Navigator.pop(context); // Remove loading dialog
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Booking submitted successfully!')),
                        );
                        Navigator.pop(context); // Return to previous screen
                      } catch (e) {
                        Navigator.pop(context); // Remove loading dialog
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error: ${e.toString()}')),
                        );
                      }
                    }
                  },
                  child: const Text('Book Appointment'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

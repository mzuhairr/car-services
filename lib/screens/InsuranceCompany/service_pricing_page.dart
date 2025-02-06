import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ServicePricingPage extends StatefulWidget {
  final Map<String, dynamic> companyData;
  final bool isDarkMode;

  const ServicePricingPage({
    super.key,
    required this.companyData,
    required this.isDarkMode,
  });

  @override
  State<ServicePricingPage> createState() => _ServicePricingPageState();
}

class _ServicePricingPageState extends State<ServicePricingPage> {
  late Stream<QuerySnapshot> servicesStream;

  @override
  void initState() {
    super.initState();
    // Initialize the stream to listen to services collection
    servicesStream = FirebaseFirestore.instance
        .collection('companies')
        .doc(widget.companyData['id'])
        .collection('services')
        .snapshots();
  }

  Future<void> updateServicePrice(String serviceId, double newPrice) async {
    try {
      await FirebaseFirestore.instance
          .collection('companies')
          .doc(widget.companyData['id'])
          .collection('services')
          .doc(serviceId)
          .update({'price': newPrice});

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Price updated successfully')),
      );
    } catch (e) {
      print('Error updating price: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to update price')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Service Pricing'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: servicesStream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final services = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: services.length,
            itemBuilder: (context, index) {
              final service = services[index].data() as Map<String, dynamic>;
              final serviceId = services[index].id;

              return Card(
                child: ListTile(
                  title: Text(service['name'] ?? 'Unnamed Service'),
                  subtitle: Text('\$${service['price']?.toString() ?? '0'}'),
                  trailing: IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () {
                      _showPriceUpdateDialog(serviceId, service);
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

  void _showPriceUpdateDialog(String serviceId, Map<String, dynamic> service) {
    final controller = TextEditingController(
      text: service['price']?.toString() ?? '0',
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Update ${service['name']} Price'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'New Price',
            prefixText: '\$',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final newPrice = double.tryParse(controller.text);
              if (newPrice != null) {
                updateServicePrice(serviceId, newPrice);
                Navigator.pop(context);
              }
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }
}

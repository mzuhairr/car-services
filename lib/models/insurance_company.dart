class InsuranceCompany {
  final String? id;
  final String name;
  final String? description;
  final String location;
  final Map<String, double> servicesPricing;
  final List<String>? customers;
  final List<Appointment>? appointments;

  InsuranceCompany({
    this.id,
    required this.name,
    this.description,
    required this.location,
    this.servicesPricing = const <String, double>{},
    this.customers,
    this.appointments,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'location': location,
      'servicesPricing': servicesPricing,
      'customers': customers,
      'appointments': appointments?.map((a) => a.toMap()).toList(),
    };
  }

  factory InsuranceCompany.fromMap(String id, Map<String, dynamic> map) {
    Map<String, double> pricing = {};
    if (map['servicesPricing'] != null) {
      final pricingData = map['servicesPricing'] as Map<String, dynamic>;
      pricingData.forEach((key, value) {
        if (value is num) {
          pricing[key] = value.toDouble();
        }
      });
    }

    return InsuranceCompany(
      id: id,
      name: map['name'] ?? '',
      description: map['description'],
      location: map['location'] ?? '',
      servicesPricing: pricing,
    );
  }
}

class Appointment {
  final String? date;
  final String? time;
  final String? description;
  final bool? isCompleted;
  final String? insuranceCompanyId;
  final String? userId;

  Appointment({
    this.date,
    this.time,
    this.description,
    this.isCompleted,
    this.insuranceCompanyId,
    this.userId,
  });

  Map<String, dynamic> toMap() {
    return {
      'date': date,
      'time': time,
      'description': description,
      'isCompleted': isCompleted,
      'insuranceCompanyId': insuranceCompanyId,
      'userId': userId,
    };
  }

  factory Appointment.fromMap(Map<String, dynamic> map) {
    return Appointment(
      date: map['date'],
      time: map['time'],
      description: map['description'],
      isCompleted: map['isCompleted'],
      insuranceCompanyId: map['insuranceCompanyId'],
      userId: map['userId'],
    );
  }
}

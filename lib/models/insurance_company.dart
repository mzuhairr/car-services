class InsuranceCompany {
  final String? id;
  final String name;
  final String? description;
  final String location;
  final Map<String, Map<String, double>> servicesPricing;
  final List<String>? customers;
  final List<Appointment>? appointments;

  InsuranceCompany({
    this.id,
    required this.name,
    this.description,
    required this.location,
    this.servicesPricing = const {},
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
      'appointments': appointments,
    };
  }

  factory InsuranceCompany.fromMap(String id, Map<String, dynamic> map) {
    return InsuranceCompany(
      id: id,
      name: map['name'] ?? '',
      description: map['description'],
      location: map['location'] ?? '',
      servicesPricing:
          Map<String, Map<String, double>>.from(map['servicesPricing'] ?? {}),
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

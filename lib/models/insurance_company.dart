class InsuranceCompany {
  final String? id;
  final String name;
  final String? description;
  final String location;
  final Map<String, Map<String, double>> servicesPricing;

  InsuranceCompany({
    this.id,
    required this.name,
    this.description,
    required this.location,
    this.servicesPricing = const {},
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'location': location,
      'servicesPricing': servicesPricing,
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

// Demo insurance companies
final List<InsuranceCompany> insuranceCompanies = [
  InsuranceCompany(
    name: 'Al-Baraka Insurance',
    location: 'Khartoum, Al-Amarat',
    description:
        'Leading insurance provider with 15 years of experience in automotive services.',
    servicesPricing: {
      'General Repairs': {
        'Engine Repair': 25000,
        'Transmission Service': 15000,
        'Brake Service': 8000,
        'Oil Change': 3000,
        'Battery Service': 4000,
        'AC Service': 6000,
      },
    },
  ),
  InsuranceCompany(
    name: 'Nile Shield Insurance',
    location: 'Omdurman, Al-Morada',
    description: 'Comprehensive coverage and quick service response times.',
    servicesPricing: {
      'General Repairs': {
        'Engine Repair': 23000,
        'Transmission Service': 14000,
        'Brake Service': 7500,
        'Oil Change': 2800,
        'Battery Service': 3800,
        'AC Service': 5500,
      },
    },
  ),
  // Add more companies: Al-Salam Insurance, Blue Nile Insurance, etc.
];

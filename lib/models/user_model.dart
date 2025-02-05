class UserModel {
  final String uid;
  final String email;
  final String name;
  final bool isAdmin;
  final String? insuranceCompanyId;

  UserModel({
    required this.uid,
    required this.email,
    required this.name,
    this.isAdmin = false,
    this.insuranceCompanyId,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'name': name,
      'isAdmin': isAdmin,
      'insuranceCompanyId': insuranceCompanyId,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      email: map['email'] ?? '',
      name: map['name'] ?? '',
      isAdmin: map['isAdmin'] ?? false,
      insuranceCompanyId: map['insuranceCompanyId'],
    );
  }
}

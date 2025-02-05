import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String email;
  final String name;
  final bool isAdmin;
  final String insuranceCompanyId;
  final DateTime? createdAt;

  UserModel({
    required this.uid,
    required this.email,
    required this.name,
    required this.insuranceCompanyId,
    this.isAdmin = false,
    this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'name': name,
      'insuranceCompanyId': insuranceCompanyId,
      'isAdmin': isAdmin,
      'createdAt': createdAt ?? FieldValue.serverTimestamp(),
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      email: map['email'] ?? '',
      name: map['name'] ?? '',
      insuranceCompanyId: map['insuranceCompanyId'] ?? '',
      isAdmin: map['isAdmin'] ?? false,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate(),
    );
  }
}

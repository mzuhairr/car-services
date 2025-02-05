import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/insurance_company.dart';
import '../models/user_model.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Insurance Companies
  Future<List<InsuranceCompany>> getInsuranceCompanies() async {
    final snapshot = await _firestore.collection('InsuranceCompany').get();
    return snapshot.docs
        .map((doc) => InsuranceCompany.fromMap(doc.id, doc.data()))
        .toList();
  }

  Future<void> addInsuranceCompany(InsuranceCompany company) async {
    await _firestore.collection('InsuranceCompany').add(company.toMap());
  }

  // User Management
  Future<UserModel?> getUser(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    if (doc.exists) {
      return UserModel.fromMap(doc.data()!);
    }
    return null;
  }

  Future<void> createUser(UserModel user) async {
    await _firestore.collection('users').doc(user.uid).set(user.toMap());
  }

  Future<bool> isUserAdmin(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    return doc.data()?['isAdmin'] ?? false;
  }

  Future<void> setUserAsAdmin(String uid, bool isAdmin) async {
    await _firestore.collection('users').doc(uid).update({'isAdmin': isAdmin});
  }

  Future<void> createNewUser(Map<String, dynamic> userData) async {
    final UserModel newUser = UserModel(
      uid: userData['uid'],
      email: userData['email'],
      name: userData['name'],
      insuranceCompanyId: userData['insuranceCompanyId'],
      isAdmin: false,
      createdAt: DateTime.now(),
    );

    await createUser(newUser);
  }
}

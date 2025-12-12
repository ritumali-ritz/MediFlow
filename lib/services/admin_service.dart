import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../models/clinic_model.dart';
import '../models/location_model.dart';

class AdminService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Create a new doctor account with credentials
  Future<Map<String, String>> createDoctor({
    required String email,
    required String displayName,
    required String hospitalId,
    required String departmentId,
  }) async {
    // Generate a random password
    final password = _generatePassword();
    
    // In production, use Firebase Admin SDK to create auth user
    // For now, just create the Firestore profile
    final doctorId = 'doc_${DateTime.now().millisecondsSinceEpoch}';
    
    final doctor = UserModel(
      uid: doctorId,
      email: email,
      displayName: displayName,
      role: 'doctor',
      hospitalId: hospitalId,
      department: departmentId,
    );

    await _db.collection('users').doc(doctorId).set(doctor.toMap());

    // Update hospital's department doctors mapping
    await _db.collection('clinics').doc(hospitalId).update({
      'departmentDoctors.$departmentId': FieldValue.arrayUnion([doctorId]),
      'doctorIds': FieldValue.arrayUnion([doctorId]),
    });

    return {
      'doctorId': doctorId,
      'email': email,
      'password': password,
    };
  }

  /// Create a new hospital
  Future<String> createHospital({
    required String name,
    required String address,
    required LocationModel location,
    required List<String> departmentIds,
  }) async {
    final hospitalId = 'hospital_${DateTime.now().millisecondsSinceEpoch}';
    
    final hospital = ClinicModel(
      id: hospitalId,
      name: name,
      address: address,
      location: location,
      doctorIds: [],
      ownerId: 'admin',
      departmentIds: departmentIds,
      departmentDoctors: {},
    );

    await _db.collection('clinics').doc(hospitalId).set(hospital.toMap());
    
    return hospitalId;
  }

  /// Assign doctor to a department
  Future<void> assignDoctorToDepartment({
    required String doctorId,
    required String hospitalId,
    required String departmentId,
  }) async {
    await _db.collection('clinics').doc(hospitalId).update({
      'departmentDoctors.$departmentId': FieldValue.arrayUnion([doctorId]),
    });
  }

  /// Get all hospitals
  Stream<List<ClinicModel>> getHospitals() {
    return _db.collection('clinics').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => ClinicModel.fromMap(doc.data(), doc.id)).toList();
    });
  }

  /// Get all doctors
  Stream<List<UserModel>> getDoctors() {
    return _db.collection('users')
        .where('role', isEqualTo: 'doctor')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => UserModel.fromMap(doc.data(), doc.id)).toList();
    });
  }

  String _generatePassword() {
    const chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = DateTime.now().millisecondsSinceEpoch;
    return List.generate(8, (index) => chars[(random + index) % chars.length]).join();
  }
}

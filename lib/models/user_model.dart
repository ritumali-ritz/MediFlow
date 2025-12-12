class UserModel {
  final String uid;
  final String email;
  final String displayName;
  final String role; // 'patient' or 'doctor'
  final String? phoneNumber;
  final String? fullName;
  final String? aadhaarNumber;
  final bool profileComplete;
  final String? hospitalId; // For doctors
  final String? department; // For doctors

  UserModel({
    required this.uid,
    required this.email,
    required this.displayName,
    required this.role,
    this.phoneNumber,
    this.fullName,
    this.aadhaarNumber,
    this.profileComplete = false,
    this.hospitalId,
    this.department,
  });

  factory UserModel.fromMap(Map<String, dynamic> map, String uid) {
    return UserModel(
      uid: uid,
      email: map['email'] ?? '',
      displayName: map['displayName'] ?? '',
      role: map['role'] ?? 'patient',
      phoneNumber: map['phoneNumber'],
      fullName: map['fullName'],
      aadhaarNumber: map['aadhaarNumber'],
      profileComplete: map['profileComplete'] ?? false,
      hospitalId: map['hospitalId'],
      department: map['department'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'role': role,
      'phoneNumber': phoneNumber,
      'fullName': fullName,
      'aadhaarNumber': aadhaarNumber,
      'profileComplete': profileComplete,
      'hospitalId': hospitalId,
      'department': department,
    };
  }
}

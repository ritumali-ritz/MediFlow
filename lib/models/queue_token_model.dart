class QueueTokenModel {
  final String id;
  final String clinicId;
  final String doctorId;
  final String patientId;
  final int tokenNumber;
  final String status; // 'waiting', 'serving', 'completed', 'cancelled'
  final DateTime createdAt;
  
  // Enhanced fields
  final String? doctorName;
  final String? departmentName;
  final String? clinicName;
  final String? patientName;
  final String? patientPhone;
  final int? estimatedWaitTime; // in minutes

  QueueTokenModel({
    required this.id,
    required this.clinicId,
    required this.doctorId,
    required this.patientId,
    required this.tokenNumber,
    required this.status,
    required this.createdAt,
    this.doctorName,
    this.departmentName,
    this.clinicName,
    this.patientName,
    this.patientPhone,
    this.estimatedWaitTime,
  });

  factory QueueTokenModel.fromMap(Map<String, dynamic> map, String id) {
    // Handle createdAt field - can be either Timestamp or String
    DateTime createdAtValue;
    final createdAtRaw = map['createdAt'];
    if (createdAtRaw is String) {
      createdAtValue = DateTime.parse(createdAtRaw);
    } else if (createdAtRaw != null) {
      // Firestore Timestamp
      createdAtValue = (createdAtRaw as dynamic).toDate();
    } else {
      createdAtValue = DateTime.now();
    }

    return QueueTokenModel(
      id: id,
      clinicId: map['clinicId'] ?? '',
      doctorId: map['doctorId'] ?? '',
      patientId: map['patientId'] ?? '',
      tokenNumber: map['tokenNumber'] ?? 0,
      status: map['status'] ?? 'waiting',
      createdAt: createdAtValue,
      doctorName: map['doctorName'],
      departmentName: map['departmentName'],
      clinicName: map['clinicName'],
      patientName: map['patientName'],
      patientPhone: map['patientPhone'],
      estimatedWaitTime: map['estimatedWaitTime'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'clinicId': clinicId,
      'doctorId': doctorId,
      'patientId': patientId,
      'tokenNumber': tokenNumber,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      'doctorName': doctorName,
      'departmentName': departmentName,
      'clinicName': clinicName,
      'patientName': patientName,
      'patientPhone': patientPhone,
      'estimatedWaitTime': estimatedWaitTime,
    };
  }
}

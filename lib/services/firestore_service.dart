import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../models/clinic_model.dart';
import '../models/queue_token_model.dart';
import '../models/user_model.dart';
import '../utils/constants.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final _uuid = const Uuid();

  // --- Clinics ---
  Stream<List<ClinicModel>> getClinics() {
    return _db.collection(AppConstants.clinicsCollection).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => ClinicModel.fromMap(doc.data(), doc.id)).toList();
    });
  }

  // --- Queue Token Management ---

  /// Joins a queue for a specific clinic and doctor.
  /// Returns the generated Token ID.
  Future<String> joinQueue({
    required String clinicId,
    required String doctorId,
    required String patientId,
    required String departmentId,
  }) async {
    // Check if user can join (max 2 queues)
    final canJoin = await canJoinQueue(patientId);
    if (!canJoin) {
      throw Exception('You can only join a maximum of 2 queues at a time');
    }

    // Fetch doctor details
    final doctorDoc = await _db.collection('users').doc(doctorId).get();
    final doctorData = doctorDoc.data();
    final doctorName = doctorData?['fullName'] ?? doctorData?['displayName'] ?? 'Doctor';
    
    // Fetch clinic details
    final clinicDoc = await _db.collection('clinics').doc(clinicId).get();
    final clinicData = clinicDoc.data();
    final clinicName = clinicData?['name'] ?? 'Hospital';
    
    // Fetch patient details
    final patientDoc = await _db.collection('users').doc(patientId).get();
    final patientData = patientDoc.data();
    final patientName = patientData?['fullName'] ?? patientData?['displayName'] ?? 'Patient';
    final patientPhone = patientData?['phoneNumber'] ?? '';
    
    // Get department name
    final Map<String, String> departments = {
      'general': 'General Medicine',
      'cardiology': 'Cardiology',
      'pediatrics': 'Pediatrics',
      'orthopedics': 'Orthopedics',
      'dermatology': 'Dermatology',
      'gynecology': 'Gynecology',
      'neurology': 'Neurology',
    };
    final departmentName = departments[departmentId] ?? departmentId;

    return _db.runTransaction((transaction) async {
      final todayStr = DateTime.now().toIso8601String().split('T')[0];
      final queueId = '${clinicId}_${doctorId}_$todayStr';
      final queueRef = _db.collection(AppConstants.queuesCollection).doc(queueId);
      
      final queueDoc = await transaction.get(queueRef);
      
      int nextTokenNumber = 1;
      
      if (queueDoc.exists) {
        nextTokenNumber = (queueDoc.data()?['lastTokenNumber'] ?? 0) + 1;
        transaction.update(queueRef, {'lastTokenNumber': nextTokenNumber});
      } else {
        transaction.set(queueRef, {
          'clinicId': clinicId,
          'doctorId': doctorId,
          'date': todayStr,
          'lastTokenNumber': 1,
          'currentServing': 0,
        });
      }

      // Calculate estimated wait time
      final waitingCount = nextTokenNumber - 1; // Number of people ahead
      final estimatedWaitTime = calculateEstimatedWaitTime(waitingCount);

      final tokenId = _uuid.v4();
      // Create the token document with enhanced details
      final tokenRef = _db.collection('tokens').doc(tokenId);
      transaction.set(tokenRef, {
        'id': tokenId,
        'clinicId': clinicId,
        'doctorId': doctorId,
        'patientId': patientId,
        'tokenNumber': nextTokenNumber,
        'status': 'waiting',
        'createdAt': DateTime.now().toIso8601String(),
        'doctorName': doctorName,
        'departmentName': departmentName,
        'clinicName': clinicName,
        'patientName': patientName,
        'patientPhone': patientPhone,
        'estimatedWaitTime': estimatedWaitTime,
      });
      
      return tokenId;
    });
  }

  // --- Streams for Patient ---

  /// Stream of my active tokens
  Stream<List<QueueTokenModel>> getMyTokens(String patientId) {
    return _db
        .collection('tokens')
        .where('patientId', isEqualTo: patientId)
        .where('status', whereIn: ['waiting', 'serving'])
        .snapshots()
        .map((snap) => snap.docs.map((d) => QueueTokenModel.fromMap(d.data(), d.id)).toList());
  }

  /// Remove patient from queue
  Future<void> removeFromQueue(String tokenId) async {
    await _db.collection('tokens').doc(tokenId).update({
      'status': 'cancelled',
      'cancelledAt': FieldValue.serverTimestamp(),
    });
  }

  /// Get user's active queues (waiting or serving)
  Future<List<QueueTokenModel>> getUserActiveQueues(String userId) async {
    final snapshot = await _db
        .collection('tokens')
        .where('patientId', isEqualTo: userId)
        .where('status', whereIn: ['waiting', 'serving'])
        .get();
    
    return snapshot.docs
        .map((doc) => QueueTokenModel.fromMap(doc.data(), doc.id))
        .toList();
  }

  /// Check if user can join a queue (max 2 active queues)
  Future<bool> canJoinQueue(String userId) async {
    final activeQueues = await getUserActiveQueues(userId);
    return activeQueues.length < 2;
  }

  /// Calculate estimated wait time based on position in queue
  /// Assumes average 10 minutes per patient
  int calculateEstimatedWaitTime(int position) {
    const int avgTimePerPatient = 10; // minutes
    return position * avgTimePerPatient;
  }

  /// Stream of all active tokens for doctor dashboard
  Stream<List<QueueTokenModel>> getAllActiveTokens() {
    return _db
        .collection('tokens')
        .where('status', whereIn: ['waiting', 'serving'])
        .orderBy('tokenNumber')
        .snapshots()
        .map((snap) => snap.docs.map((d) => QueueTokenModel.fromMap(d.data(), d.id)).toList());
  }

  /// Complete a token
  Future<void> completeToken(String tokenId) async {
    await _db.collection('tokens').doc(tokenId).update({
      'status': 'completed',
      'completedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Get active tokens for TV display
  Stream<List<QueueTokenModel>> getActiveTokensForTv(String clinicId, String doctorId) {
    return _db
        .collection('tokens')
        .where('clinicId', isEqualTo: clinicId)
        .where('doctorId', isEqualTo: doctorId)
        .where('status', isEqualTo: 'waiting')
        .orderBy('tokenNumber')
        .snapshots()
        .map((snap) => snap.docs.map((d) => QueueTokenModel.fromMap(d.data(), d.id)).toList());
  }

  /// Get doctors by clinic and department
  Future<List<UserModel>> getDoctorsByDepartment(String clinicId, String department) async {
    final snapshot = await _db
        .collection('users')
        .where('role', isEqualTo: 'doctor')
        .where('hospitalId', isEqualTo: clinicId) // matching hospitalId with clinicId
        .where('department', isEqualTo: department)
        .get();
        
    return snapshot.docs.map((d) => UserModel.fromMap(d.data(), d.id)).toList();
  }

  /// Get distinct departments from doctors in a clinic
  Future<List<String>> getDepartmentsByClinic(String clinicId) async {
    final snapshot = await _db
        .collection('users')
        .where('role', isEqualTo: 'doctor')
        .where('hospitalId', isEqualTo: clinicId)
        .get();
    
    final doctors = snapshot.docs.map((d) => UserModel.fromMap(d.data(), d.id)).toList();
    return doctors.map((d) => d.department).toSet().toList().cast<String>(); // Unique departments
  }

  /// Call next patient (mark as serving)
  Future<void> callPatient(String tokenId) async {
    await _db.collection('tokens').doc(tokenId).update({
      'status': 'serving',
    });
  }

  /// Stream of a specific queue status (for dashboard)
  Stream<Map<String, dynamic>> getQueueStatus(String clinicId, String doctorId) {
    final todayStr = DateTime.now().toIso8601String().split('T')[0];
    final queueId = '${clinicId}_${doctorId}_$todayStr';
    
    return _db.collection(AppConstants.queuesCollection).doc(queueId).snapshots().map((doc) {
      if (!doc.exists) return {'currentServing': 0, 'lastTokenNumber': 0};
      return doc.data()!;
    });
  }
  
  // --- Doctor Actions ---
  
  Future<void> nextPatient(String clinicId, String doctorId, int currentTokenNumber) async {
    final todayStr = DateTime.now().toIso8601String().split('T')[0];
    final queueId = '${clinicId}_${doctorId}_$todayStr';
    
    // Update Queue Metadata
    await _db.collection(AppConstants.queuesCollection).doc(queueId).update({
      'currentServing': currentTokenNumber + 1
    });
    
    // Update old token status to 'completed'
    final oldTokenQuery = await _db.collection('tokens')
        .where('clinicId', isEqualTo: clinicId)
        .where('doctorId', isEqualTo: doctorId)
        .where('tokenNumber', isEqualTo: currentTokenNumber)
        .get();
        
    for (var doc in oldTokenQuery.docs) {
      await doc.reference.update({'status': 'completed'});
    }

    // Update new token status to 'serving'
    final newTokenQuery = await _db.collection('tokens')
        .where('clinicId', isEqualTo: clinicId)
        .where('doctorId', isEqualTo: doctorId)
        .where('tokenNumber', isEqualTo: currentTokenNumber + 1)
        .get();
        
    for (var doc in newTokenQuery.docs) {
      await doc.reference.update({'status': 'serving'});
    }
  }
}

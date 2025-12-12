
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../services/notification_service.dart';
import '../models/queue_token_model.dart';
import '../models/clinic_model.dart';

// Services
final authServiceProvider = Provider<AuthService>((ref) => AuthService());
final firestoreServiceProvider = Provider<FirestoreService>((ref) => FirestoreService());
final notificationServiceProvider = Provider<NotificationService>((ref) => NotificationService());

// Streams
final authStateProvider = StreamProvider<User?>((ref) {
  return ref.watch(authServiceProvider).authStateChanges;
});

// Queue Streams
final myTokensProvider = StreamProvider.family<List<QueueTokenModel>, String>((ref, userId) {
  return ref.read(firestoreServiceProvider).getMyTokens(userId);
});

final clinicsProvider = StreamProvider<List<ClinicModel>>((ref) {
  return ref.read(firestoreServiceProvider).getClinics();
});

final queueStatusProvider = StreamProvider.family<Map<String, dynamic>, ({String clinicId, String doctorId})>((ref, args) {
    return ref.read(firestoreServiceProvider).getQueueStatus(args.clinicId, args.doctorId);
});

final queueTokensProvider = StreamProvider.family<List<QueueTokenModel>, ({String clinicId, String doctorId})>((ref, args) {
    return ref.read(firestoreServiceProvider).getActiveTokensForTv(args.clinicId, args.doctorId);
});


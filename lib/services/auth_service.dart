
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../utils/constants.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  // Stream of the current user's profile data from Firestore
  Stream<UserModel?> get userProfileStream {
    return _auth.authStateChanges().asyncMap((user) async {
      if (user == null) return null;
      final doc = await _db.collection(AppConstants.usersCollection).doc(user.uid).get();
      if (!doc.exists) return null;
      return UserModel.fromMap(doc.data()!, user.uid);
    });
  }

  Future<UserModel?> signInWithEmailPassword(String email, String password) async {
    final cred = await _auth.signInWithEmailAndPassword(email: email, password: password);
    if (cred.user == null) return null;
    
    // Fetch user profile
    final doc = await _db.collection(AppConstants.usersCollection).doc(cred.user!.uid).get();
    if (doc.exists) {
      return UserModel.fromMap(doc.data()!, cred.user!.uid);
    }
    
    // If user document doesn't exist, create it (for doctors created by admin)
    final newUser = UserModel(
      uid: cred.user!.uid,
      email: email,
      displayName: email.split('@')[0],
      role: 'doctor', // Assume doctor if no document exists
    );
    await _db.collection(AppConstants.usersCollection).doc(cred.user!.uid).set(newUser.toMap());
    return newUser;
  }

  Future<UserModel?> registerWithEmailPassword({
    required String email,
    required String password,
    required String role,
    String? displayName,
  }) async {
    final cred = await _auth.createUserWithEmailAndPassword(email: email, password: password);
    if (cred.user == null) return null;

    final newUser = UserModel(
      uid: cred.user!.uid,
      email: email,
      displayName: displayName ?? email.split('@')[0],
      role: role,
    );

    // Create user document in Firestore
    await _db.collection(AppConstants.usersCollection).doc(cred.user!.uid).set(newUser.toMap());

    // If doctor, create a doctor profile placeholder (optional, can be done in separate flow)
    if (role == AppConstants.roleDoctor) {
      // Logic to create doctor specific record if needed
    }

    return newUser;
  }


  Future<void> signOut() async {
    await _auth.signOut();
  }

  /// Google Sign-In
  Future<UserModel?> signInWithGoogle() async {
    try {
      // This is a placeholder - Google Sign-In requires additional setup
      // For now, we'll show an error message
      throw UnimplementedError('Google Sign-In requires additional configuration');
    } catch (e) {
      rethrow;
    }
  }

  /// Send password reset email
  Future<void> sendPasswordResetEmail(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }
}


import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import '../lib/models/user_model.dart';
import '../lib/models/clinic_model.dart';
import '../lib/utils/constants.dart';
import '../lib/services/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MaterialApp(home: SeederHome()));
}

class SeederHome extends StatefulWidget {
  const SeederHome({super.key});

  @override
  State<SeederHome> createState() => _SeederHomeState();
}

class _SeederHomeState extends State<SeederHome> {
  String _status = "Initializing...";

  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 2), _seed);
  }

  Future<void> _seed() async {
    setState(() => _status = "Seeding...");
    
    final db = FirebaseFirestore.instance;
    
    try {
      // 1. Create a Clinic
      final clinicRef = db.collection(AppConstants.clinicsCollection).doc('clinic_1');
      await clinicRef.set({
        'name': 'City Health Center',
        'address': '123 Medical Drive',
        'doctorIds': ['doc_1'],
        'ownerId': 'doc_1'
      });

      // 2. Create a Doctor User
      final docRef = db.collection(AppConstants.usersCollection).doc('doc_1');
      await docRef.set({
        'email': 'doctor@test.com',
        'displayName': 'Dr. Sarah Smith',
        'role': 'doctor',
        'createdAt': FieldValue.serverTimestamp(),
      });
      
      // 3. Create a Patient User
      final patRef = db.collection(AppConstants.usersCollection).doc('pat_1');
      await patRef.set({
        'email': 'patient@test.com',
        'displayName': 'John Doe',
        'role': 'patient',
        'createdAt': FieldValue.serverTimestamp(),
      });

      // 4. Create initial Queue State
      final todayStr = DateTime.now().toIso8601String().split('T')[0];
      final queueId = 'clinic_1_doc_1_$todayStr';
      await db.collection(AppConstants.queuesCollection).doc(queueId).set({
        'clinicId': 'clinic_1',
        'doctorId': 'doc_1',
        'date': todayStr,
        'currentServing': 0,
        'lastTokenNumber': 0
      });

      setState(() => _status = "SUCCESS! \nData Seeded Successfully. \nYou can close this window now.");
    } catch (e) {
      setState(() => _status = "Error: $e");
      print("Seeding Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Demo Data Seeder")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_status, textAlign: TextAlign.center, style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 24),
            ElevatedButton(onPressed: _seed, child: const Text("Run Seed")),
          ],
        ),
      ),
    );
  }
}

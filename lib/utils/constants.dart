
import 'package:flutter/material.dart';

class AppConstants {
  static const String appName = 'Smart Health Queue';
  
  // Collections
  static const String usersCollection = 'users';
  static const String clinicsCollection = 'clinics';
  static const String doctorsCollection = 'doctors'; // sub-collection of clinics usually, or root if simple
  static const String queuesCollection = 'queues';
  
  // Roles
  static const String rolePatient = 'patient';
  static const String roleDoctor = 'doctor';
  static const String roleAdmin = 'admin';
}

class AppColors {
  static const Color primary = Color(0xFF00796B); // Medical Teal
  static const Color primaryLight = Color(0xFF48A999);
  static const Color primaryDark = Color(0xFF004C40);
  static const Color accent = Color(0xFF0288D1); // Light Blue
  static const Color background = Color(0xFFF5F5F5);
  static const Color error = Color(0xFFD32F2F);
  static const Color success = Color(0xFF388E3C);
  static const Color warning = Color(0xFFFBC02D);
}

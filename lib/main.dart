
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'utils/theme.dart';
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/forgot_password_screen.dart';
import 'screens/patient/patient_home.dart';
import 'screens/patient/clinic_search.dart';
import 'screens/patient/location_selector_screen.dart';
import 'screens/patient/department_selector_screen.dart';
import 'screens/patient/doctor_selector_screen.dart';
import 'screens/patient/patient_profile_screen.dart';
import 'screens/clinic/doctor_dashboard.dart';
import 'screens/clinic/doctor_profile_screen.dart';
import 'screens/clinic/scanner_screen.dart';
import 'screens/admin/admin_dashboard.dart';
import 'screens/tv_display_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  
  runApp(const ProviderScope(child: MyApp()));
}


final _router = GoRouter(
  initialLocation: '/',
  redirect: (context, state) {
    // This will be handled by splash screen
    return null;
  },
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/register',
      builder: (context, state) => const RegisterScreen(),
    ),
    GoRoute(
      path: '/forgot-password',
      builder: (context, state) => const ForgotPasswordScreen(),
    ),
    GoRoute(
      path: '/patient',
      builder: (context, state) => const PatientHomeScreen(),
    ),
    GoRoute(
      path: '/location-selector',
      builder: (context, state) => const LocationSelectorScreen(),
    ),
    GoRoute(
      path: '/clinic-search',
      builder: (context, state) => const ClinicSearchScreen(),
    ),
    GoRoute(
      path: '/department-selector',
      builder: (context, state) {
        final clinicId = state.uri.queryParameters['clinicId'] ?? '';
        final clinicName = state.uri.queryParameters['clinicName'] ?? '';
        return DepartmentSelectorScreen(clinicId: clinicId, clinicName: clinicName);
      },
    ),
    GoRoute(
      path: '/doctor-selector',
      builder: (context, state) {
        final clinicId = state.uri.queryParameters['clinicId'] ?? '';
        final departmentId = state.uri.queryParameters['departmentId'] ?? '';
        final departmentName = state.uri.queryParameters['departmentName'] ?? '';
        return DoctorSelectorScreen(
          clinicId: clinicId,
          departmentId: departmentId,
          departmentName: departmentName,
        );
      },
    ),
    GoRoute(
      path: '/patient-profile',
      builder: (context, state) => const PatientProfileScreen(),
    ),
    GoRoute(
      path: '/doctor-profile',
      builder: (context, state) => const DoctorProfileScreen(),
    ),
    GoRoute(
      path: '/doctor',
      builder: (context, state) => const DoctorDashboardScreen(),
    ),
    GoRoute(
      path: '/doctor-dashboard',
      builder: (context, state) => const DoctorDashboardScreen(),
    ),
    GoRoute(
      path: '/admin',
      builder: (context, state) => const AdminDashboardScreen(),
    ),
    GoRoute(
      path: '/scanner',
      builder: (context, state) => const ScannerScreen(),
    ),
    GoRoute(
      path: '/tv',
      builder: (context, state) {
        final clinicId = state.uri.queryParameters['clinicId'] ?? '';
        final doctorId = state.uri.queryParameters['doctorId'] ?? '';
        return TVDisplayScreen(clinicId: clinicId, doctorId: doctorId);
      },
    ),
    // Route for Token View - pass token object via extra or ID via params
    // Using simple ID param for reloadability would be better, but 'extra' is faster for now
    // Implementing ID param pattern for robustness:
    // GoRoute(
    //   path: '/token/:id',
    //   builder: (context, state) { ... }
    // ),
  ],
);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Smart Health Queue',
      theme: AppTheme.lightTheme,
      routerConfig: _router,
      debugShowCheckedModeBanner: false,
    );
  }
}

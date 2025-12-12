import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/providers.dart';
import '../../services/firestore_service.dart';
import '../../utils/theme.dart';
import '../../models/user_model.dart';

class DoctorSelectorScreen extends ConsumerWidget {
  final String clinicId;
  final String departmentId;
  final String departmentName;

  const DoctorSelectorScreen({
    super.key,
    required this.clinicId,
    required this.departmentId,
    required this.departmentName,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Doctor'),
        flexibleSpace: Container(
          decoration: const BoxDecoration(gradient: AppTheme.primaryGradient),
        ),
      ),
      body: Column(
        children: [
          GradientCard(
            gradient: AppTheme.accentGradient,
            child: Column(
              children: [
                Text(
                  departmentName,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Choose your doctor',
                  style: TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder<List<UserModel>>(
              future: ref.read(firestoreServiceProvider).getDoctorsByDepartment(clinicId, departmentName),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                   return const Center(child: CircularProgressIndicator());
                }
                
                final doctors = snapshot.data ?? [];
                
                if (doctors.isEmpty) {
                   return const Center(child: Text('No doctors available in this department'));
                }
                
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: doctors.length,
                  itemBuilder: (context, index) {
                    final doctor = doctors[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16),
                        leading: CircleAvatar(
                          radius: 30,
                          backgroundColor: const Color(0xFF00BCD4).withOpacity(0.2),
                          child: const Icon(Icons.person, size: 32, color: Color(0xFF00BCD4)),
                        ),
                        title: Text(
                          (doctor.fullName?.isNotEmpty == true) ? doctor.fullName! : 'Doctor',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            // In a real app, specialization/degrees would be in UserModel. 
                            // For now using department as specialization
                            Text(doctor.department ?? 'General'),
                            const SizedBox(height: 8),
                            // Future enhancement: Fetch queue length per doctor if needed
                          ],
                        ),
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            gradient: AppTheme.successGradient,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            'Select',
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                        ),
                        onTap: () async {
                          final user = authState.value;
                          if (user == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Please login first')),
                            );
                            return;
                          }

                          try {
                            // Generate token
                            await ref.read(firestoreServiceProvider).joinQueue(
                              clinicId: clinicId,
                              doctorId: doctor.uid,
                              patientId: user.uid,
                              departmentId: departmentId,
                            );

                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Token generated successfully!')),
                              );
                              context.go('/patient');
                            }
                          } catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Error: $e')),
                              );
                            }
                          }
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

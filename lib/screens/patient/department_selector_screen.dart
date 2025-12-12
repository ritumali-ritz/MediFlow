import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../models/department_model.dart';
import '../../utils/theme.dart';
import '../../providers/providers.dart';

class DepartmentSelectorScreen extends ConsumerWidget {
  final String clinicId;
  final String clinicName;

  const DepartmentSelectorScreen({
    super.key,
    required this.clinicId,
    required this.clinicName,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Sample departments - in production, fetch from Firestore based on clinicId
    final departments = [
      DepartmentModel(id: 'general', name: 'General Medicine', icon: '🏥'),
      DepartmentModel(id: 'cardiology', name: 'Cardiology', icon: '❤️'),
      DepartmentModel(id: 'pediatrics', name: 'Pediatrics', icon: '👶'),
      DepartmentModel(id: 'orthopedics', name: 'Orthopedics', icon: '🦴'),
      DepartmentModel(id: 'dermatology', name: 'Dermatology', icon: '🧴'),
      DepartmentModel(id: 'ophthalmology', name: 'Ophthalmology', icon: '👁️'),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text('Select Department'),
        flexibleSpace: Container(
          decoration: const BoxDecoration(gradient: AppTheme.primaryGradient),
        ),
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: AppTheme.primaryGradient.scale(0.3),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
            ),
            child: Column(
              children: [
                const Icon(Icons.local_hospital, size: 48, color: Colors.white),
                const SizedBox(height: 8),
                Text(
                  clinicName,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                const Text(
                  'Choose a department',
                  style: TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder<List<String>>(
              future: ref.read(firestoreServiceProvider).getDepartmentsByClinic(clinicId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                
                final departments = snapshot.data ?? [];
                
                if (departments.isEmpty) {
                   return const Center(child: Text('No departments found'));
                }
                
                return GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1.1,
                  ),
                  itemCount: departments.length,
                  itemBuilder: (context, index) {
                    final deptName = departments[index];
                    // Clean department name for ID (lowercase, no spaces)
                    final deptId = deptName.toLowerCase().replaceAll(' ', '_');
                    
                    return GestureDetector(
                      onTap: () {
                        context.push(
                          '/doctor-selector?clinicId=$clinicId&departmentId=$deptName&departmentName=$deptName',
                        );
                      },
                      child: Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            gradient: LinearGradient(
                              colors: [
                                Colors.white,
                                const Color(0xFF00BCD4).withOpacity(0.1),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                '🏥', // Generic icon as we don't store icons yet
                                style: TextStyle(fontSize: 48),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                deptName,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
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

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../utils/theme.dart';
import '../../services/admin_service.dart';
import '../../models/location_model.dart';

final adminServiceProvider = Provider<AdminService>((ref) => AdminService());

class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Super Admin Dashboard'),
        flexibleSpace: Container(
          decoration: const BoxDecoration(gradient: AppTheme.accentGradient),
        ),
      ),
      body: GridView.count(
        crossAxisCount: 2,
        padding: const EdgeInsets.all(24),
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        children: [
          _DashboardCard(
            title: 'Hospitals',
            icon: Icons.local_hospital,
            gradient: AppTheme.primaryGradient,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const HospitalManagementScreen()),
            ),
          ),
          _DashboardCard(
            title: 'Doctors',
            icon: Icons.medical_services,
            gradient: AppTheme.accentGradient,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const DoctorManagementScreen()),
            ),
          ),
          _DashboardCard(
            title: 'Departments',
            icon: Icons.category,
            gradient: AppTheme.successGradient,
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Department management coming soon')),
              );
            },
          ),
          _DashboardCard(
            title: 'Analytics',
            icon: Icons.analytics,
            gradient: LinearGradient(
              colors: [Colors.orange.shade400, Colors.deepOrange.shade600],
            ),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Analytics coming soon')),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _DashboardCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final LinearGradient gradient;
  final VoidCallback onTap;

  const _DashboardCard({
    required this.title,
    required this.icon,
    required this.gradient,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: gradient.colors.first.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 64, color: Colors.white),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class HospitalManagementScreen extends ConsumerStatefulWidget {
  const HospitalManagementScreen({super.key});

  @override
  ConsumerState<HospitalManagementScreen> createState() => _HospitalManagementScreenState();
}

class _HospitalManagementScreenState extends ConsumerState<HospitalManagementScreen> {
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  String? selectedState;
  String? selectedDistrict;
  String? selectedTehsil;

  Future<void> _createHospital() async {
    if (_nameController.text.isEmpty || selectedState == null) return;

    try {
      await ref.read(adminServiceProvider).createHospital(
        name: _nameController.text,
        address: _addressController.text,
        location: LocationModel(
          state: selectedState!,
          district: selectedDistrict ?? '',
          tehsil: selectedTehsil ?? '',
        ),
        departmentIds: ['general', 'cardiology', 'pediatrics'],
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Hospital created successfully!')),
        );
        _nameController.clear();
        _addressController.clear();
        setState(() {
          selectedState = null;
          selectedDistrict = null;
          selectedTehsil = null;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final hospitalsStream = ref.watch(adminServiceProvider).getHospitals();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Hospital Management'),
        flexibleSpace: Container(
          decoration: const BoxDecoration(gradient: AppTheme.primaryGradient),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Add New Hospital',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _nameController,
                      decoration: const InputDecoration(labelText: 'Hospital Name'),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _addressController,
                      decoration: const InputDecoration(labelText: 'Address'),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: selectedState,
                      decoration: const InputDecoration(labelText: 'State'),
                      items: ['Maharashtra', 'Karnataka', 'Delhi', 'Tamil Nadu']
                          .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                          .toList(),
                      onChanged: (val) => setState(() => selectedState = val),
                    ),
                    const SizedBox(height: 16),
                    GradientButton(
                      text: 'Create Hospital',
                      icon: Icons.add,
                      onPressed: _createHospital,
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder(
              stream: hospitalsStream,
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final hospitals = snapshot.data!;
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: hospitals.length,
                  itemBuilder: (context, index) {
                    final hospital = hospitals[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: const CircleAvatar(
                          child: Icon(Icons.local_hospital),
                        ),
                        title: Text(hospital.name),
                        subtitle: Text(hospital.location.fullAddress),
                        trailing: IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () {},
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

class DoctorManagementScreen extends ConsumerStatefulWidget {
  const DoctorManagementScreen({super.key});

  @override
  ConsumerState<DoctorManagementScreen> createState() => _DoctorManagementScreenState();
}

class _DoctorManagementScreenState extends ConsumerState<DoctorManagementScreen> {
  final _emailController = TextEditingController();
  final _nameController = TextEditingController();
  String? selectedHospital;
  String? selectedDepartment;

  Future<void> _createDoctor() async {
    if (_emailController.text.isEmpty || selectedHospital == null) return;

    try {
      final result = await ref.read(adminServiceProvider).createDoctor(
        email: _emailController.text,
        displayName: _nameController.text,
        hospitalId: selectedHospital!,
        departmentId: selectedDepartment ?? 'general',
      );

      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Doctor Created'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Email: ${result['email']}'),
                Text('Password: ${result['password']}'),
                const SizedBox(height: 8),
                const Text(
                  'Please share these credentials with the doctor.',
                  style: TextStyle(fontStyle: FontStyle.italic, fontSize: 12),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        );

        _emailController.clear();
        _nameController.clear();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final doctorsStream = ref.watch(adminServiceProvider).getDoctors();
    final hospitalsStream = ref.watch(adminServiceProvider).getHospitals();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Doctor Management'),
        flexibleSpace: Container(
          decoration: const BoxDecoration(gradient: AppTheme.accentGradient),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Add New Doctor',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _nameController,
                      decoration: const InputDecoration(labelText: 'Doctor Name'),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _emailController,
                      decoration: const InputDecoration(labelText: 'Email'),
                    ),
                    const SizedBox(height: 12),
                    StreamBuilder(
                      stream: hospitalsStream,
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) return const SizedBox();
                        return DropdownButtonFormField<String>(
                          value: selectedHospital,
                          decoration: const InputDecoration(labelText: 'Hospital'),
                          items: snapshot.data!
                              .map((h) => DropdownMenuItem(value: h.id, child: Text(h.name)))
                              .toList(),
                          onChanged: (val) => setState(() => selectedHospital = val),
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: selectedDepartment,
                      decoration: const InputDecoration(labelText: 'Department'),
                      items: ['general', 'cardiology', 'pediatrics', 'orthopedics']
                          .map((d) => DropdownMenuItem(value: d, child: Text(d.toUpperCase())))
                          .toList(),
                      onChanged: (val) => setState(() => selectedDepartment = val),
                    ),
                    const SizedBox(height: 16),
                    GradientButton(
                      text: 'Create Doctor Account',
                      icon: Icons.person_add,
                      gradient: AppTheme.accentGradient,
                      onPressed: _createDoctor,
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder(
              stream: doctorsStream,
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final doctors = snapshot.data!;
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: doctors.length,
                  itemBuilder: (context, index) {
                    final doctor = doctors[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: const CircleAvatar(
                          child: Icon(Icons.person),
                        ),
                        title: Text(doctor.displayName ?? 'Unknown'),
                        subtitle: Text(doctor.email),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () {},
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

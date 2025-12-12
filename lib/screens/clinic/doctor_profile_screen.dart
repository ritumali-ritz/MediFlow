import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../providers/providers.dart';
import '../../utils/theme.dart';

class DoctorProfileScreen extends ConsumerStatefulWidget {
  const DoctorProfileScreen({super.key});

  @override
  ConsumerState<DoctorProfileScreen> createState() => _DoctorProfileScreenState();
}

class _DoctorProfileScreenState extends ConsumerState<DoctorProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _isLoading = false;
  bool _isEditing = false;
  
  String? _hospitalName;
  String? _department;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  void _loadProfile() async {
    final authState = ref.read(authStateProvider);
    final user = authState.value;
    if (user == null) return;

    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    if (doc.exists) {
      final data = doc.data()!;
      setState(() {
        _fullNameController.text = data['fullName'] ?? data['displayName'] ?? '';
        _phoneController.text = data['phoneNumber'] ?? '';
        _department = data['department'];
      });

      // Load hospital name
      final hospitalId = data['hospitalId'];
      if (hospitalId != null) {
        final hospitalDoc = await FirebaseFirestore.instance
            .collection('clinics')
            .doc(hospitalId)
            .get();
        if (hospitalDoc.exists) {
          setState(() {
            _hospitalName = hospitalDoc.data()?['name'];
          });
        }
      }
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final authState = ref.read(authStateProvider);
      final user = authState.value;
      if (user == null) return;

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update({
        'fullName': _fullNameController.text.trim(),
        'phoneNumber': _phoneController.text.trim(),
        'profileComplete': true,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully'),
            backgroundColor: Colors.green,
          ),
        );
        setState(() => _isEditing = false);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  String _getDepartmentName(String? dept) {
    final Map<String, String> departments = {
      'general': 'General Medicine',
      'cardiology': 'Cardiology',
      'pediatrics': 'Pediatrics',
      'orthopedics': 'Orthopedics',
      'dermatology': 'Dermatology',
      'gynecology': 'Gynecology',
      'neurology': 'Neurology',
    };
    return departments[dept] ?? dept ?? 'Not assigned';
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Doctor Profile'),
        flexibleSpace: Container(
          decoration: const BoxDecoration(gradient: AppTheme.primaryGradient),
        ),
        actions: [
          if (!_isEditing)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => setState(() => _isEditing = true),
            ),
        ],
      ),
      body: authState.when(
        data: (user) {
          if (user == null) {
            return const Center(child: Text('Not logged in'));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Profile Icon
                  Center(
                    child: CircleAvatar(
                      radius: 60,
                      backgroundColor: const Color(0xFF00BCD4),
                      child: const Icon(
                        Icons.medical_services,
                        size: 60,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade100,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'DOCTOR',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Email (Read-only)
                  Card(
                    child: ListTile(
                      leading: const Icon(Icons.email, color: Color(0xFF00BCD4)),
                      title: const Text('Email'),
                      subtitle: Text(user.email ?? 'No email'),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Hospital (Read-only)
                  Card(
                    child: ListTile(
                      leading: const Icon(Icons.local_hospital, color: Color(0xFF00BCD4)),
                      title: const Text('Hospital'),
                      subtitle: Text(_hospitalName ?? 'Not assigned'),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Department (Read-only)
                  Card(
                    child: ListTile(
                      leading: const Icon(Icons.medical_information, color: Color(0xFF00BCD4)),
                      title: const Text('Department'),
                      subtitle: Text(_getDepartmentName(_department)),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Full Name
                  TextFormField(
                    controller: _fullNameController,
                    enabled: _isEditing,
                    decoration: InputDecoration(
                      labelText: 'Full Name *',
                      prefixIcon: const Icon(Icons.person),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: !_isEditing,
                      fillColor: _isEditing ? null : Colors.grey.shade100,
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter your full name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Phone Number
                  TextFormField(
                    controller: _phoneController,
                    enabled: _isEditing,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      labelText: 'Phone Number *',
                      prefixIcon: const Icon(Icons.phone),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: !_isEditing,
                      fillColor: _isEditing ? null : Colors.grey.shade100,
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter your phone number';
                      }
                      if (value.trim().length != 10) {
                        return 'Phone number must be 10 digits';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 30),

                  // Save Button
                  if (_isEditing)
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: _isLoading
                                ? null
                                : () {
                                    setState(() => _isEditing = false);
                                    _loadProfile();
                                  },
                            child: const Text('Cancel'),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          flex: 2,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _saveProfile,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF00BCD4),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Text('Save Profile'),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
    );
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }
}

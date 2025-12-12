import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../providers/providers.dart';
import '../../utils/theme.dart';

class PatientProfileScreen extends ConsumerStatefulWidget {
  const PatientProfileScreen({super.key});

  @override
  ConsumerState<PatientProfileScreen> createState() => _PatientProfileScreenState();
}

class _PatientProfileScreenState extends ConsumerState<PatientProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _aadhaarController = TextEditingController();
  bool _isLoading = false;
  bool _isEditing = false;

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
        _fullNameController.text = data['fullName'] ?? '';
        _phoneController.text = data['phoneNumber'] ?? '';
        _aadhaarController.text = data['aadhaarNumber'] ?? '';
      });
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
        'aadhaarNumber': _aadhaarController.text.trim(),
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

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
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
                      child: Text(
                        _fullNameController.text.isNotEmpty
                            ? _fullNameController.text[0].toUpperCase()
                            : user.email?[0].toUpperCase() ?? 'P',
                        style: const TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
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
                  const SizedBox(height: 16),

                  // Aadhaar Number (Optional)
                  TextFormField(
                    controller: _aadhaarController,
                    enabled: _isEditing,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Aadhaar Number (Optional)',
                      prefixIcon: const Icon(Icons.credit_card),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: !_isEditing,
                      fillColor: _isEditing ? null : Colors.grey.shade100,
                      hintText: 'XXXX XXXX XXXX',
                    ),
                    validator: (value) {
                      if (value != null && value.trim().isNotEmpty) {
                        if (value.trim().length != 12) {
                          return 'Aadhaar must be 12 digits';
                        }
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
    _aadhaarController.dispose();
    super.dispose();
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/providers.dart';
import '../../models/location_model.dart';

class ClinicSearchScreen extends ConsumerWidget {
  final LocationModel? location;
  
  const ClinicSearchScreen({super.key, this.location});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final clinicsAsync = ref.watch(firestoreServiceProvider).getClinics();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Hospital'),
      ),
      body: StreamBuilder(
        stream: clinicsAsync,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text('No hospitals found'),
            );
          }

          final clinics = snapshot.data!;
          
          // Filter by location if provided
          final filteredClinics = location != null
              ? clinics.where((c) => c.location.state == location!.state).toList()
              : clinics;

          if (filteredClinics.isEmpty) {
            return const Center(
              child: Text('No hospitals found in this location'),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: filteredClinics.length,
            itemBuilder: (context, index) {
              final clinic = filteredClinics[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: const CircleAvatar(
                    child: Icon(Icons.local_hospital),
                  ),
                  title: Text(clinic.name),
                  subtitle: Text(clinic.location.fullAddress),
                  trailing: const Icon(Icons.arrow_forward),
                  onTap: () {
                    // Navigate to department selector
                    context.push(
                      '/department-selector?clinicId=${clinic.id}&clinicName=${Uri.encodeComponent(clinic.name)}',
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}

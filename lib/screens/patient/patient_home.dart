import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/providers.dart';
import '../../utils/theme.dart';
import '../../widgets/emergency_section.dart';
import '../../models/queue_token_model.dart';

class PatientHomeScreen extends ConsumerWidget {
  const PatientHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    
    return authState.when(
      data: (user) {
        if (user == null) {
          return const Scaffold(body: Center(child: Text('Not logged in')));
        }
        
        final tokensAsync = ref.watch(myTokensProvider(user.uid));
        
        return Scaffold(
          appBar: AppBar(
            title: Row(
              children: [
                const Text('My Queue Tokens'),
                const SizedBox(width: 8),
                tokensAsync.when(
                  data: (tokens) {
                    if (tokens.isEmpty) return const SizedBox.shrink();
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${tokens.length}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    );
                  },
                  loading: () => const SizedBox.shrink(),
                  error: (_, __) => const SizedBox.shrink(),
                ),
              ],
            ),
            flexibleSpace: Container(
              decoration: const BoxDecoration(gradient: AppTheme.primaryGradient),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.person),
                tooltip: 'Profile',
                onPressed: () => context.push('/patient-profile'),
              ),
              IconButton(
                icon: const Icon(Icons.logout),
                tooltip: 'Logout',
                onPressed: () async {
                  await ref.read(authServiceProvider).signOut();
                  if (context.mounted) context.go('/login');
                },
              ),
            ],
          ),
          body: Column(
            children: [
              // Emergency Section at top
              const Padding(
                padding: EdgeInsets.all(16),
                child: EmergencySection(),
              ),
              
              // Rest of the content
              Expanded(
                child: tokensAsync.when(
                  data: (tokens) {
                    if (tokens.isEmpty) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(32),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.inbox, size: 80, color: Colors.grey),
                              SizedBox(height: 16),
                              Text(
                                'No Active Tokens',
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Join a queue to get started',
                                style: TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                      );
                    }
                    
                    return Column(
                      children: [
                        Expanded(
                          child: ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: tokens.length,
                            itemBuilder: (context, index) {
                              final token = tokens[index];
                              final isServing = token.status == 'serving';
                              
                              return Card(
                                margin: const EdgeInsets.only(bottom: 16),
                                elevation: isServing ? 8 : 2,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  side: BorderSide(
                                    color: isServing ? const Color(0xFF00BCD4) : Colors.grey.shade300,
                                    width: isServing ? 3 : 1,
                                  ),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(20),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      // Header with token number and status
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Row(
                                            children: [
                                              Container(
                                                padding: const EdgeInsets.all(12),
                                                decoration: BoxDecoration(
                                                  color: isServing ? const Color(0xFF00BCD4) : Colors.grey.shade200,
                                                  borderRadius: BorderRadius.circular(12),
                                                ),
                                                child: Text(
                                                  '#${token.tokenNumber}',
                                                  style: TextStyle(
                                                    fontSize: 24,
                                                    fontWeight: FontWeight.bold,
                                                    color: isServing ? Colors.white : Colors.black87,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 12),
                                              Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    isServing ? 'NOW SERVING' : 'WAITING',
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      fontWeight: FontWeight.bold,
                                                      color: isServing ? const Color(0xFF00BCD4) : Colors.orange,
                                                    ),
                                                  ),
                                                  if (!isServing) ...[
                                                    const SizedBox(height: 4),
                                                    // Queue position counter
                                                    StreamBuilder<List<QueueTokenModel>>(
                                                      stream: ref.read(firestoreServiceProvider).getAllActiveTokens(),
                                                      builder: (context, queueSnapshot) {
                                                        if (!queueSnapshot.hasData || queueSnapshot.data == null) {
                                                          return const SizedBox.shrink();
                                                        }
                                                        
                                                        final List<QueueTokenModel> allTokens = queueSnapshot.data!;
                                                        final List<QueueTokenModel> waitingTokens = allTokens
                                                            .where((QueueTokenModel t) => t.status == 'waiting' && t.clinicId == token.clinicId && t.doctorId == token.doctorId)
                                                            .toList();
                                                        
                                                        waitingTokens.sort((QueueTokenModel a, QueueTokenModel b) => a.tokenNumber.compareTo(b.tokenNumber));
                                                        
                                                        final int position = waitingTokens.indexWhere((QueueTokenModel t) => t.id == token.id) + 1;
                                                        
                                                        if (position > 0) {
                                                          return Text(
                                                            'You are #$position in queue',
                                                            style: const TextStyle(
                                                              fontSize: 13,
                                                              fontWeight: FontWeight.w600,
                                                              color: Colors.blue,
                                                            ),
                                                          );
                                                        }
                                                        return const SizedBox.shrink();
                                                      },
                                                    ),
                                                  ],
                                                  if (!isServing && token.estimatedWaitTime != null) ...[
                                                    const SizedBox(height: 4),
                                                    Text(
                                                      'Est. wait: ~${token.estimatedWaitTime} min',
                                                      style: const TextStyle(
                                                        fontSize: 12,
                                                        fontWeight: FontWeight.w500,
                                                        color: Colors.green,
                                                      ),
                                                    ),
                                                  ],
                                                ],
                                              ),
                                            ],
                                          ),
                                          if (isServing)
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                              decoration: BoxDecoration(
                                                color: Colors.green,
                                                borderRadius: BorderRadius.circular(20),
                                              ),
                                              child: const Row(
                                                children: [
                                                  Icon(Icons.notifications_active, size: 16, color: Colors.white),
                                                  SizedBox(width: 4),
                                                  Text(
                                                    'YOUR TURN',
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontWeight: FontWeight.bold,
                                                      fontSize: 12,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                        ],
                                      ),
                                      
                                      const Divider(height: 24),
                                      
                                      // Clinic and Doctor Details
                                      _DetailRow(
                                        icon: Icons.local_hospital,
                                        label: 'Hospital',
                                        value: token.clinicName ?? 'N/A',
                                      ),
                                      const SizedBox(height: 8),
                                      _DetailRow(
                                        icon: Icons.medical_services,
                                        label: 'Doctor',
                                        value: token.doctorName ?? 'N/A',
                                      ),
                                      const SizedBox(height: 8),
                                      _DetailRow(
                                        icon: Icons.medical_information,
                                        label: 'Department',
                                        value: token.departmentName ?? 'N/A',
                                      ),
                                      
                                      const SizedBox(height: 16),
                                      
                                      // Action Button
                                      if (!isServing)
                                        ElevatedButton.icon(
                                          onPressed: () async {
                                            final confirm = await showDialog<bool>(
                                              context: context,
                                              builder: (context) => AlertDialog(
                                                title: const Text('Remove from Queue'),
                                                content: const Text('Are you sure you want to cancel this appointment?'),
                                                actions: [
                                                  TextButton(
                                                    onPressed: () => Navigator.pop(context, false),
                                                    child: const Text('No'),
                                                  ),
                                                  TextButton(
                                                    onPressed: () => Navigator.pop(context, true),
                                                    child: const Text('Yes, Cancel'),
                                                  ),
                                                ],
                                              ),
                                            );

                                            if (confirm == true && context.mounted) {
                                              await ref.read(firestoreServiceProvider).removeFromQueue(token.id);
                                              if (context.mounted) {
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  const SnackBar(content: Text('Removed from queue')),
                                                );
                                              }
                                            }
                                          },
                                          icon: const Icon(Icons.cancel, size: 18),
                                          label: const Text('Cancel Appointment'),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.red,
                                            foregroundColor: Colors.white,
                                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: GradientButton(
                            text: 'Join Another Queue',
                            icon: Icons.add,
                            onPressed: () => context.push('/location-selector'),
                          ),
                        ),
                      ],
                    );
                  },
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (error, stack) => Center(child: Text('Error: $error')),
                ),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => context.push('/location-selector'),
            icon: const Icon(Icons.add),
            label: const Text('Join Queue'),
            backgroundColor: const Color(0xFF00BCD4),
          ),
        );
      },
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (error, stack) => Scaffold(body: Center(child: Text('Error: $error'))),
    );
  }
}

// Helper widget for detail rows
class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: const Color(0xFF00BCD4)),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: const TextStyle(
            fontWeight: FontWeight.w500,
            color: Colors.grey,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 15,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

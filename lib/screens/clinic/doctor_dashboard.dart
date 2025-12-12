import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/providers.dart';
import '../../utils/theme.dart';
import '../../models/queue_token_model.dart';

class DoctorDashboardScreen extends ConsumerStatefulWidget {
  const DoctorDashboardScreen({super.key});

  @override
  ConsumerState<DoctorDashboardScreen> createState() => _DoctorDashboardScreenState();
}

class _DoctorDashboardScreenState extends ConsumerState<DoctorDashboardScreen> {
  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Doctor Dashboard'),
        flexibleSpace: Container(
          decoration: const BoxDecoration(gradient: AppTheme.primaryGradient),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            tooltip: 'Profile',
            onPressed: () => context.push('/doctor-profile'),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () async {
              await ref.read(authServiceProvider).signOut();
              if (context.mounted) {
                context.go('/login');
              }
            },
          ),
        ],
      ),
      body: authState.when(
        data: (user) {
          if (user == null) {
            return const Center(child: Text('Not logged in'));
          }

          return StreamBuilder<List<QueueTokenModel>>(
            stream: ref.read(firestoreServiceProvider).getAllActiveTokens(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final tokens = snapshot.data ?? [];
              final servingToken = tokens.where((t) => t.status == 'serving').firstOrNull;
              final waitingTokens = tokens.where((t) => t.status == 'waiting').toList();

              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Current Serving Card
                    Card(
                      elevation: 8,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF00BCD4), Color(0xFF0097A7)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          children: [
                            const Text(
                              'NOW SERVING',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 16,
                                letterSpacing: 2,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              servingToken != null ? '#${servingToken.tokenNumber}' : '--',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 72,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (servingToken != null) ...[
                              const SizedBox(height: 16),
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Column(
                                  children: [
                                    Row(
                                      children: [
                                        const Icon(Icons.person, color: Colors.white, size: 20),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            servingToken.patientName ?? 'Patient',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 18,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    if (servingToken.patientPhone != null && servingToken.patientPhone!.isNotEmpty) ...[
                                      const SizedBox(height: 8),
                                      Row(
                                        children: [
                                          const Icon(Icons.phone, color: Colors.white70, size: 18),
                                          const SizedBox(width: 8),
                                          Text(
                                            servingToken.patientPhone!,
                                            style: const TextStyle(
                                              color: Colors.white70,
                                              fontSize: 16,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ],
                            if (servingToken != null) ...[
                              const SizedBox(height: 24),
                              ElevatedButton.icon(
                                onPressed: () async {
                                  await ref.read(firestoreServiceProvider).completeToken(servingToken.id);
                                  if (waitingTokens.isNotEmpty) {
                                    await ref.read(firestoreServiceProvider).callPatient(waitingTokens.first.id);
                                  }
                                },
                                icon: const Icon(Icons.check_circle),
                                label: const Text('Complete & Next'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: const Color(0xFF00BCD4),
                                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                                  textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ] else if (waitingTokens.isNotEmpty) ...[
                              const SizedBox(height: 24),
                              ElevatedButton.icon(
                                onPressed: () async {
                                  await ref.read(firestoreServiceProvider).callPatient(waitingTokens.first.id);
                                },
                                icon: const Icon(Icons.play_arrow),
                                label: const Text('Call Next Patient'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: const Color(0xFF00BCD4),
                                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                                  textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Statistics Row
                    Row(
                      children: [
                        Expanded(
                          child: _StatCard(
                            icon: Icons.people,
                            label: 'Waiting',
                            value: '${waitingTokens.length}',
                            color: Colors.orange,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _StatCard(
                            icon: Icons.event_available,
                            label: 'Total Today',
                            value: '${tokens.length}',
                            color: Colors.blue,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Waiting Queue
                    if (waitingTokens.isNotEmpty) ...[
                      const Text(
                        'Waiting Queue',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],

                    const SizedBox(height: 16),

                    if (waitingTokens.isEmpty)
                      const Card(
                        child: Padding(
                          padding: EdgeInsets.all(32),
                          child: Column(
                            children: [
                              Icon(Icons.check_circle, size: 64, color: Colors.green),
                              SizedBox(height: 16),
                              Text(
                                'No patients waiting',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      ...waitingTokens.asMap().entries.map((entry) {
                        final index = entry.key;
                        final token = entry.value;
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(
                              color: index == 0 ? const Color(0xFF00BCD4) : Colors.grey.shade300,
                              width: index == 0 ? 2 : 1,
                            ),
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            leading: CircleAvatar(
                              backgroundColor: index == 0 ? const Color(0xFF00BCD4) : Colors.grey,
                              radius: 28,
                              child: Text(
                                '#${token.tokenNumber}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            title: Text(
                              'Patient ${token.patientId.substring(0, 8)}...',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            subtitle: Text(
                              'Waiting ${index + 1}${_getOrdinalSuffix(index + 1)} in queue',
                              style: TextStyle(color: Colors.grey.shade600),
                            ),
                            trailing: index == 0
                                ? Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF00BCD4),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: const Text(
                                      'NEXT',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                  )
                                : null,
                          ),
                        );
                      }).toList(),
                  ],
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
    );
  }

  String _getOrdinalSuffix(int number) {
    if (number >= 11 && number <= 13) return 'th';
    switch (number % 10) {
      case 1: return 'st';
      case 2: return 'nd';
      case 3: return 'rd';
      default: return 'th';
    }
  }
}

// Helper widget for statistics cards
class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}


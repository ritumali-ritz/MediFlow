
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/providers.dart';
import '../../utils/constants.dart';

class TVDisplayScreen extends ConsumerWidget {
  final String clinicId;
  final String doctorId;

  const TVDisplayScreen({
    super.key,
    required this.clinicId,
    required this.doctorId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // If IDs are missing, show error
    if (clinicId.isEmpty || doctorId.isEmpty) {
      return const Scaffold(body: Center(child: Text("Missing clinicId or doctorId parameters")));
    }

    // Stream of waiting tokens for Up Next list
    final upNextAsync = ref.watch(queueTokensProvider((clinicId: clinicId, doctorId: doctorId)));
    final queueStatusAsync = ref.watch(queueStatusProvider((clinicId: clinicId, doctorId: doctorId)));

    return Scaffold(
      backgroundColor: Colors.black, // Dark background for TV
      body: queueStatusAsync.when(
        data: (status) {
          final currentServing = status['currentServing'] ?? 0;
          
          return Row(
            children: [
              // Left Panel: Now Serving
              Expanded(
                flex: 2,
                child: Container(
                  color: AppColors.primary,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'NOW SERVING',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 48,
                          fontWeight: FontWeight.w300,
                          letterSpacing: 4.0,
                        ),
                      ),
                      const SizedBox(height: 48),
                      Text(
                        '$currentServing',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 280, // Massive font
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Token Number',
                        style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 24),
                      )
                    ],
                  ),
                ),
              ),
              
              // Right Panel: Up Next / Ads / Info
              Expanded(
                flex: 1,
                child: Container(
                  color: const Color(0xFF1E1E1E),
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'UP NEXT',
                        style: TextStyle(color: AppColors.accent, fontSize: 32, fontWeight: FontWeight.bold),
                      ),
                      const Divider(color: Colors.grey),
                      const SizedBox(height: 16),
                      
                      // Real Up Next List
                      Expanded(
                        child: upNextAsync.when(
                          data: (tokens) {
                            if (tokens.isEmpty) {
                              return const Center(child: Text('No other patients waiting', style: TextStyle(color: Colors.grey, fontSize: 20)));
                            }
                            // Take next 5 tokens
                            final nextTokens = tokens.take(5).toList();
                            return ListView.builder(
                              itemCount: nextTokens.length,
                              itemBuilder: (context, index) {
                                return _NextItem(token: nextTokens[index].tokenNumber);
                              },
                            );
                          },
                          loading: () => const Center(child: CircularProgressIndicator()),
                          error: (_,__) => const SizedBox(),
                        ),
                      ),
                      
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white10,
                          borderRadius: BorderRadius.circular(16)
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.qr_code, color: Colors.white, size: 64),
                            SizedBox(width: 16),
                            Expanded(child: Text("Scan to join queue from your phone", style: TextStyle(color: Colors.white, fontSize: 24)))
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator(color: Colors.white)),
        error: (err, stack) => Center(child: Text('Error: $err', style: const TextStyle(color: Colors.white))),
      ),
    );
  }
}

class _NextItem extends StatelessWidget {
  final int token;
  const _NextItem({required this.token});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: Colors.white24,
            radius: 24,
            child: Text('$token', style: const TextStyle(color: Colors.white, fontSize: 24)),
          ),
          const SizedBox(width: 24),
          const Text('Waiting...', style: TextStyle(color: Colors.white70, fontSize: 28)),
        ],
      ),
    );
  }
}

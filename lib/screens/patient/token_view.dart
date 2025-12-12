
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../models/queue_token_model.dart';
import '../../utils/constants.dart';

class TokenViewScreen extends ConsumerWidget {
  final QueueTokenModel token;

  const TokenViewScreen({super.key, required this.token});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: Text('Token #${token.tokenNumber}')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Your Token', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Text(
                '${token.tokenNumber}',
                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text('Status: ${token.status.toUpperCase()}', 
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)
            ),
            const SizedBox(height: 32),
            QrImageView(
              data: token.id,
              version: QrVersions.auto,
              size: 200.0,
            ),
            const SizedBox(height: 16),
            const Text('Show this QR to the clinic staff'),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../utils/theme.dart';

class EmergencySection extends StatelessWidget {
  const EmergencySection({super.key});

  Future<void> _callEmergency(String number) async {
    final uri = Uri.parse('tel:$number');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GradientCard(
      gradient: LinearGradient(
        colors: [Colors.red.shade600, Colors.red.shade800],
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.emergency, color: Colors.white, size: 32),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Emergency Services',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _EmergencyButton(
                  icon: Icons.local_hospital,
                  label: 'Ambulance\n108',
                  onTap: () => _callEmergency('108'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _EmergencyButton(
                  icon: Icons.phone,
                  label: 'Emergency\n112',
                  onTap: () => _callEmergency('112'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _EmergencyButton(
                  icon: Icons.location_on,
                  label: 'Nearby\nHospitals',
                  onTap: () async {
                    try {
                      // Try Google Maps app first, then browser
                      final mapsUrl = Uri.parse('geo:0,0?q=hospitals+near+me');
                      final webUrl = Uri.parse('https://www.google.com/maps/search/hospitals+near+me');
                      
                      // Try maps URL first (opens Google Maps app on Android)
                      if (await canLaunchUrl(mapsUrl)) {
                        await launchUrl(mapsUrl);
                      } else if (await canLaunchUrl(webUrl)) {
                        // Fallback to web browser
                        await launchUrl(webUrl, mode: LaunchMode.externalApplication);
                      } else {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Could not open maps')),
                          );
                        }
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
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _EmergencyButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _EmergencyButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.white, size: 32),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

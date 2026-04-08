import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../auth_provider.dart';
import '../login_screen.dart';
import '../../../../services/notification_service.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Avatar
            CircleAvatar(
              radius: 48,
              backgroundColor: Colors.indigo[100],
              child: Text(
                user?.prenom.isNotEmpty == true
                    ? user!.prenom[0].toUpperCase()
                    : '?',
                style: const TextStyle(
                    fontSize: 36,
                    color: Colors.indigo,
                    fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              '${user?.prenom ?? ''} ${user?.nom ?? ''}',
              style: const TextStyle(
                  fontSize: 22, fontWeight: FontWeight.bold),
            ),
            Text(user?.email ?? '',
                style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 8),
            Chip(
              label: Text(_roleLabel(user?.role ?? '')),
              backgroundColor: Colors.indigo[50],
              labelStyle: const TextStyle(color: Colors.indigo),
            ),
            const SizedBox(height: 32),
            const Divider(),
            const SizedBox(height: 16),

            // Test notification
            ElevatedButton.icon(
              icon: const Icon(Icons.notifications_active, color: Colors.white),
              label: const Text('Tester notification',
                  style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo),
              onPressed: () async {
                await NotificationService.instance.showNotification(
                  title: '🔔 Test notification',
                  body: 'Les notifications CSFM Library+ fonctionnent !',
                );
              },
            ),
            const SizedBox(height: 12),

            // Logout
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                icon: const Icon(Icons.logout, color: Colors.red),
                label: const Text('Se déconnecter',
                    style: TextStyle(color: Colors.red)),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.red),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: () async {
                  await ref.read(authProvider.notifier).logout();
                  if (context.mounted) {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const LoginScreen()),
                      (_) => false,
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _roleLabel(String role) {
    switch (role) {
      case 'apprenant_loge':
        return '⭐ Apprenant logé';
      case 'apprenant_externe':
        return 'Apprenant externe';
      case 'admin':
        return '🔑 Administrateur';
      default:
        return role;
    }
  }
}
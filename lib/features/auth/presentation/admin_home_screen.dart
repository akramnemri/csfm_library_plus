import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'auth_provider.dart';
import 'emprunts/emprunts_provider.dart';
import 'emprunts/emprunts_admin_screen.dart';
import 'catalogue/catalogue_screen.dart';
import 'profile_screen.dart';
import 'statistiques/statistiques_screen.dart';

class AdminHomeScreen extends ConsumerStatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  ConsumerState<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends ConsumerState<AdminHomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    _AdminDashboard(),
    CatalogueScreen(),
    EmpruntsAdminScreen(),
    StatistiquesScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: Colors.indigo,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.dashboard_outlined),
              activeIcon: Icon(Icons.dashboard),
              label: 'Dashboard'),
          BottomNavigationBarItem(
              icon: Icon(Icons.library_books_outlined),
              activeIcon: Icon(Icons.library_books),
              label: 'Catalogue'),
          BottomNavigationBarItem(
              icon: Icon(Icons.swap_horiz),
              activeIcon: Icon(Icons.swap_horiz),
              label: 'Emprunts'),
          BottomNavigationBarItem(
              icon: Icon(Icons.bar_chart_outlined),
              activeIcon: Icon(Icons.bar_chart),
              label: 'Stats'),
          BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: 'Profil'),
        ],
      ),
    );
  }
}

class _AdminDashboard extends ConsumerWidget {
  const _AdminDashboard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allEmpruntsAsync = ref.watch(allEmpruntsProvider);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        title: const Text('Admin — CSFM Library+'),
      ),
      body: allEmpruntsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Erreur: $e')),
        data: (emprunts) {
          final enAttente = emprunts
              .where((e) => e.statut == 'en_attente')
              .length;
          final actifs =
              emprunts.where((e) => e.statut == 'actif').length;
          final enRetard =
              emprunts.where((e) => e.estEnRetard).length;
          final retournes =
              emprunts.where((e) => e.statut == 'retourne').length;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Admin welcome
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF1A237E), Colors.indigo],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Tableau de bord',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold)),
                      SizedBox(height: 4),
                      Text('Vue d\'ensemble de la bibliothèque',
                          style: TextStyle(
                              color: Colors.white70, fontSize: 13)),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                const Text('Statistiques emprunts',
                    style: TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),

                // Stats grid
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.4,
                  children: [
                    _AdminStatCard('En attente', enAttente.toString(),
                        Icons.hourglass_empty, Colors.orange),
                    _AdminStatCard('Actifs', actifs.toString(),
                        Icons.book_outlined, Colors.green),
                    _AdminStatCard('En retard', enRetard.toString(),
                        Icons.warning_outlined, Colors.red),
                    _AdminStatCard('Retournés', retournes.toString(),
                        Icons.check_circle_outline, Colors.teal),
                  ],
                ),

                // Alert if pending requests
                if (enAttente > 0) ...[
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.orange[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.orange),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.notifications_active,
                            color: Colors.orange),
                        const SizedBox(width: 12),
                        Text(
                          '$enAttente demande(s) en attente de validation',
                          style: const TextStyle(
                              color: Colors.orange,
                              fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}

class _AdminStatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _AdminStatCard(this.label, this.value, this.icon, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(value,
              style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: color)),
          Text(label,
              style:
                  const TextStyle(fontSize: 12, color: Colors.grey)),
        ],
      ),
    );
  }
}
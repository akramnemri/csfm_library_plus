import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'auth_provider.dart';
import 'login_screen.dart';
import 'notifications/notification_service.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).user;
    final isAdmin = user?.role == 'admin';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Avatar
            CircleAvatar(
              radius: 40,
              backgroundColor: Colors.indigo[100],
              child: Text(
                user?.prenom.isNotEmpty == true
                    ? user!.prenom[0].toUpperCase()
                    : '?',
                style: const TextStyle(
                    fontSize: 28,
                    color: Colors.indigo,
                    fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              '${user?.prenom ?? ''} ${user?.nom ?? ''}',
              style: const TextStyle(
                  fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(user?.email ?? '',
                style: const TextStyle(color: Colors.grey, fontSize: 13)),
            const SizedBox(height: 8),
            Chip(
              label: Text(_roleLabel(user?.role ?? '')),
              backgroundColor: Colors.indigo[50],
              labelStyle: const TextStyle(color: Colors.indigo, fontSize: 12),
              padding: const EdgeInsets.symmetric(horizontal: 8),
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 12),

            // Seed documents button (admin only)
            if (isAdmin) ...[
              ElevatedButton.icon(
                icon: const Icon(Icons.cloud_upload, color: Colors.white),
                label: const Text('Seed Documents',
                    style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple),
                onPressed: () => _seedDocuments(context),
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                icon: const Icon(Icons.library_books, color: Colors.white),
                label: const Text('Seed Emprunts',
                    style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
                onPressed: () => _seedEmprunts(context),
              ),
              const SizedBox(height: 12),
            ],

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

  Future<void> _seedDocuments(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Seed Documents'),
        content: const Text('Add sample documents to Firestore?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Seed'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final firestore = FirebaseFirestore.instance;
    final sampleDocs = [
      // Informatique (12 books)
      {'titre': 'Introduction to Algorithms', 'auteur': 'Cormen, Leiserson, Rivest, Stein', 'categorie': 'livre', 'annee': 2009, 'description': 'Comprehensive introduction to algorithms and data structures', 'disponible': true, 'coverUrl': ''},
      {'titre': 'Clean Code', 'auteur': 'Robert C. Martin', 'categorie': 'livre', 'annee': 2008, 'description': 'A handbook of agile software craftsmanship', 'disponible': true, 'coverUrl': ''},
      {'titre': 'Design Patterns', 'auteur': 'Gang of Four', 'categorie': 'livre', 'annee': 1994, 'description': 'Elements of reusable object-oriented software', 'disponible': true, 'coverUrl': ''},
      {'titre': 'The Pragmatic Programmer', 'auteur': 'David Thomas, Andrew Hunt', 'categorie': 'livre', 'annee': 2019, 'description': 'Your journey to mastery in software development', 'disponible': true, 'coverUrl': ''},
      {'titre': 'Refactoring', 'auteur': 'Martin Fowler', 'categorie': 'livre', 'annee': 2018, 'description': 'Improving the design of existing code', 'disponible': true, 'coverUrl': ''},
      {'titre': 'Code Complete', 'auteur': 'Steve McConnell', 'categorie': 'livre', 'annee': 2004, 'description': 'A practical handbook of software construction', 'disponible': true, 'coverUrl': ''},
      {'titre': 'Head First Design Patterns', 'auteur': 'Eric Freeman', 'categorie': 'livre', 'annee': 2004, 'description': 'A brain-friendly guide to design patterns', 'disponible': true, 'coverUrl': ''},
      {'titre': 'JavaScript: The Good Parts', 'auteur': 'Douglas Crockford', 'categorie': 'livre', 'annee': 2008, 'description': 'Discover the elegant side of JavaScript', 'disponible': true, 'coverUrl': ''},
      {'titre': 'Python Crash Course', 'auteur': 'Eric Matthes', 'categorie': 'livre', 'annee': 2019, 'description': 'A hands-on, project-based introduction to programming', 'disponible': true, 'coverUrl': ''},
      {'titre': 'Learning React', 'auteur': 'Alex Banks', 'categorie': 'livre', 'annee': 2020, 'description': 'Functional web development with hooks and Redux', 'disponible': true, 'coverUrl': ''},
      {'titre': 'Database System Concepts', 'auteur': 'Silberschatz, Korth', 'categorie': 'livre', 'annee': 2019, 'description': 'Comprehensive guide to database systems', 'disponible': true, 'coverUrl': ''},
      {'titre': 'Artificial Intelligence: A Modern Approach', 'auteur': 'Stuart Russell', 'categorie': 'livre', 'annee': 2020, 'description': 'The leading textbook in AI', 'disponible': true, 'coverUrl': ''},
      
      // Mathématiques (8 books)
      {'titre': 'Calculus: Early Transcendentals', 'auteur': 'James Stewart', 'categorie': 'livre', 'annee': 2015, 'description': 'Comprehensive calculus textbook for university', 'disponible': true, 'coverUrl': ''},
      {'titre': 'Linear Algebra Done Right', 'auteur': 'Sheldon Axler', 'categorie': 'livre', 'annee': 2015, 'description': 'Undergraduate texts in mathematics', 'disponible': true, 'coverUrl': ''},
      {'titre': 'Discrete Mathematics', 'auteur': 'Kenneth Rosen', 'categorie': 'livre', 'annee': 2011, 'description': 'Mathematical foundations for computer science', 'disponible': true, 'coverUrl': ''},
      {'titre': 'Probability and Statistics', 'auteur': 'Morris DeGroot', 'categorie': 'livre', 'annee': 2011, 'description': 'Classic text in probability theory', 'disponible': true, 'coverUrl': ''},
      {'titre': 'Algebra', 'auteur': 'Michael Artin', 'categorie': 'livre', 'annee': 2011, 'description': 'Modern algebra for undergraduate students', 'disponible': true, 'coverUrl': ''},
      {'titre': 'Statistics', 'auteur': 'David Freedman', 'categorie': 'livre', 'annee': 2007, 'description': 'Statistical methods and applications', 'disponible': true, 'coverUrl': ''},
      {'titre': 'Number Theory', 'auteur': 'George Andrews', 'categorie': 'livre', 'annee': 2011, 'description': 'An introduction to number theory', 'disponible': true, 'coverUrl': ''},
      {'titre': 'Graph Theory', 'auteur': 'Reinhard Diestel', 'categorie': 'livre', 'annee': 2017, 'description': 'Graduate texts in mathematics', 'disponible': true, 'coverUrl': ''},
      
      // Physique (6 books)
      {'titre': 'Physics for Scientists and Engineers', 'auteur': 'Raymond A. Serway', 'categorie': 'livre', 'annee': 2018, 'description': 'Foundations of physics course', 'disponible': true, 'coverUrl': ''},
      {'titre': 'University Physics', 'auteur': 'Young, Freedman', 'categorie': 'livre', 'annee': 2015, 'description': 'Modern physics textbook', 'disponible': true, 'coverUrl': ''},
      {'titre': 'Quantum Mechanics', 'auteur': 'David J. Griffiths', 'categorie': 'livre', 'annee': 2017, 'description': 'Introduction to quantum mechanics', 'disponible': true, 'coverUrl': ''},
      {'titre': 'Electricity and Magnetism', 'auteur': 'Purcell', 'categorie': 'livre', 'annee': 2013, 'description': 'Berkeley physics course', 'disponible': true, 'coverUrl': ''},
      {'titre': 'Thermodynamics', 'auteur': 'Cengel, Boles', 'categorie': 'livre', 'annee': 2015, 'description': 'Engineering thermodynamics', 'disponible': true, 'coverUrl': ''},
      {'titre': 'Classical Mechanics', 'auteur': 'Herbert Goldstein', 'categorie': 'livre', 'annee': 2017, 'description': 'Classical mechanics graduate text', 'disponible': true, 'coverUrl': ''},
      
      // Chimie (4 books)
      {'titre': 'Organic Chemistry', 'auteur': 'David Klein', 'categorie': 'livre', 'annee': 2017, 'description': 'Organic chemistry textbook', 'disponible': true, 'coverUrl': ''},
      {'titre': 'Chemistry: The Central Science', 'auteur': 'Theodore Brown', 'categorie': 'livre', 'annee': 2017, 'description': 'Comprehensive general chemistry', 'disponible': true, 'coverUrl': ''},
      {'titre': 'Biochemistry', 'auteur': 'Jeremy Berg', 'categorie': 'livre', 'annee': 2019, 'description': 'Biochemistry textbook', 'disponible': true, 'coverUrl': ''},
      {'titre': 'General Chemistry', 'auteur': 'Ebbing, Gammon', 'categorie': 'livre', 'annee': 2017, 'description': 'General chemistry principles', 'disponible': true, 'coverUrl': ''},
      
      // Biologie (4 books)
      {'titre': 'Campbell Biology', 'auteur': 'Lisa A. Urry', 'categorie': 'livre', 'annee': 2020, 'description': 'Comprehensive biology textbook', 'disponible': true, 'coverUrl': ''},
      {'titre': 'Molecular Biology of the Cell', 'auteur': 'Bruce Alberts', 'categorie': 'livre', 'annee': 2022, 'description': 'Cell biology reference', 'disponible': true, 'coverUrl': ''},
      {'titre': 'Human Anatomy', 'auteur': 'Marieb, Hoehn', 'categorie': 'livre', 'annee': 2019, 'description': 'Human anatomy and physiology', 'disponible': true, 'coverUrl': ''},
      {'titre': 'Microbiology', 'auteur': 'Tortora, Funke', 'categorie': 'livre', 'annee': 2016, 'description': 'Introduction to microbiology', 'disponible': true, 'coverUrl': ''},
      
      // Magazines (5)
      {'titre': 'Science Magazine - AI Special', 'auteur': 'Science', 'categorie': 'magazine', 'annee': 2024, 'description': 'Special edition on artificial intelligence', 'disponible': true, 'coverUrl': ''},
      {'titre': 'Nature - Climate Change', 'auteur': 'Nature', 'categorie': 'magazine', 'annee': 2024, 'description': 'Climate change research collection', 'disponible': true, 'coverUrl': ''},
      {'titre': 'MIT Technology Review', 'auteur': 'MIT', 'categorie': 'magazine', 'annee': 2024, 'description': 'Technology and innovation magazine', 'disponible': true, 'coverUrl': ''},
      {'titre': 'Harvard Business Review', 'auteur': 'HBR', 'categorie': 'magazine', 'annee': 2024, 'description': 'Business and management insights', 'disponible': true, 'coverUrl': ''},
      {'titre': 'Le Monde Diplomatique', 'auteur': 'Le Monde', 'categorie': 'magazine', 'annee': 2024, 'description': 'International relations and geopolitics', 'disponible': true, 'coverUrl': ''},
      
      // DVDs (5)
      {'titre': 'Calculus Tutorial DVD', 'auteur': 'EduLearn', 'categorie': 'dvd', 'annee': 2020, 'description': 'Complete calculus course on DVD', 'disponible': true, 'coverUrl': ''},
      {'titre': 'Physics Lab Demonstrations', 'auteur': 'ScienceFirst', 'categorie': 'dvd', 'annee': 2019, 'description': 'Essential physics experiments', 'disponible': true, 'coverUrl': ''},
      {'titre': 'Organic Chemistry Reactions', 'auteur': 'ChemEdu', 'categorie': 'dvd', 'annee': 2018, 'description': 'Visual guide to organic reactions', 'disponible': true, 'coverUrl': ''},
      {'titre': 'Biology: Cell Structure', 'auteur': 'BioMedia', 'categorie': 'dvd', 'annee': 2021, 'description': 'Cell biology educational film', 'disponible': true, 'coverUrl': ''},
      {'titre': 'Linear Algebra Made Easy', 'auteur': 'MathMaster', 'categorie': 'dvd', 'annee': 2020, 'description': 'Step-by-step linear algebra lessons', 'disponible': true, 'coverUrl': ''},
      
      // Supports pédagogiques (5)
      {'titre': 'Algorithmique - Cours et Exercices', 'auteur': 'CNAM', 'categorie': 'support_pedagogique', 'annee': 2023, 'description': 'Algorithm course materials and exercises', 'disponible': true, 'coverUrl': ''},
      {'titre': 'Introduction à la Programmation', 'auteur': 'OpenClassrooms', 'categorie': 'support_pedagogique', 'annee': 2023, 'description': 'Programming basics learning kit', 'disponible': true, 'coverUrl': ''},
      {'titre': 'Mathématiques pour Ingénieurs', 'auteur': 'Polytech', 'categorie': 'support_pedagogique', 'annee': 2022, 'description': 'Engineering mathematics workbook', 'disponible': true, 'coverUrl': ''},
      {'titre': 'Physique Appliquée - TD', 'auteur': 'Université Paris-Saclay', 'categorie': 'support_pedagogique', 'annee': 2021, 'description': 'Applied physics problem sets', 'disponible': true, 'coverUrl': ''},
      {'titre': 'Chimie Organique - Travaux Pratiques', 'auteur': 'ENS', 'categorie': 'support_pedagogique', 'annee': 2022, 'description': 'Organic chemistry lab manual', 'disponible': true, 'coverUrl': ''},
    ];

    try {
      for (final doc in sampleDocs) {
        await firestore.collection('documents').add({
          ...doc,
          'dateAjout': DateTime.now().toIso8601String(),
        });
      }

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ ${sampleDocs.length} documents seeded successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _seedEmprunts(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Seed Emprunts'),
        content: const Text('Add sample emprunts to Firestore?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Seed'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final firestore = FirebaseFirestore.instance;

    // Get documents first
    final docsSnap = await firestore.collection('documents').get();
    if (docsSnap.docs.isEmpty) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('❌ Seed documents first!'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    final sampleEmprunts = <Map<String, dynamic>>[];
    
    // Generate 30 random emprunts
    for (int i = 0; i < 30; i++) {
      final docIndex = i % docsSnap.docs.length;
      final daysAgo = (i * 2) % 30;
      final daysToReturn = (i * 3) % 20 - 5;
      final isLate = daysToReturn < 0;
      final isEnAttente = i % 5 == 0;
      
      sampleEmprunts.add({
        'userId': 'user-${i + 1}',
        'userNom': ['Dupont', 'Martin', 'Bernard', 'Petit', 'Moreau', 'Laurent'][i % 6],
        'userPrenom': ['Jean', 'Marie', 'Pierre', 'Anne', 'Sophie', 'Lucas'][i % 6],
        'userRole': i % 3 == 0 ? 'apprenant_loge' : 'apprenant_externe',
        'documentId': docsSnap.docs[docIndex].id,
        'documentTitre': docsSnap.docs[docIndex].get('titre') ?? 'Unknown',
        'dateEmprunt': DateTime.now().subtract(Duration(days: daysAgo)).toIso8601String(),
        'dateRetourPrevue': DateTime.now().add(Duration(days: daysToReturn)).toIso8601String(),
        'statut': isEnAttente ? 'en_attente' : (isLate ? 'en_retard' : 'actif'),
      });
    }

    try {
      for (final emp in sampleEmprunts) {
        await firestore.collection('emprunts').add(emp);
      }

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ ${sampleEmprunts.length} emprunts seeded successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
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
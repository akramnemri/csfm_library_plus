import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/presentation/auth_provider.dart';
import '../domain/emprunt_model.dart';
import 'emprunts_provider.dart';
import '../domain/document_model.dart';

class DocumentDetailScreen extends ConsumerWidget {
  final DocumentModel document;
  const DocumentDetailScreen({super.key, required this.document});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final user = authState.user;
    final empruntsState = ref.watch(empruntsNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(document.titre),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cover
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: document.coverUrl.isNotEmpty
                    ? Image.network(document.coverUrl,
                        height: 200, fit: BoxFit.cover)
                    : Container(
                        height: 200,
                        width: 140,
                        color: Colors.indigo[100],
                        child: const Icon(Icons.book,
                            size: 64, color: Colors.indigo),
                      ),
              ),
            ),
            const SizedBox(height: 24),

            _InfoRow('Titre', document.titre),
            _InfoRow('Auteur', document.auteur),
            _InfoRow('Catégorie', document.categorie),
            _InfoRow('Année', document.annee.toString()),
            _InfoRow('Disponibilité',
                document.disponible ? 'Disponible' : 'Emprunté'),

            if (document.description.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Text('Description',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 8),
              Text(document.description,
                  style: const TextStyle(color: Colors.grey)),
            ],

            const SizedBox(height: 32),

            // Borrow button (only for non-admin users)
            if (user != null && user.role != 'admin')
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: !document.disponible ||
                          empruntsState is AsyncLoading
                      ? null
                      : () => _confirmEmprunt(context, ref, user),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  icon: const Icon(Icons.book_outlined, color: Colors.white),
                  label: Text(
                    document.disponible
                        ? 'Demander un emprunt'
                        : 'Non disponible',
                    style: const TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ),

            // Error message
            if (empruntsState is AsyncError)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(
                  empruntsState.error.toString(),
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _confirmEmprunt(BuildContext context, WidgetRef ref, user) {
    // Apprenants logés get 14 days, externes get 7 days
    final jours = user.role == 'apprenant_loge' ? 14 : 7;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Confirmer l\'emprunt'),
        content: Text(
          'Emprunter "${document.titre}" ?\n\n'
          'Durée : $jours jours\n'
          'Retour prévu : ${_formatDate(
            DateTime.now().add(Duration(days: jours)),
          )}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            style:
                ElevatedButton.styleFrom(backgroundColor: Colors.indigo),
            onPressed: () async {
              Navigator.pop(context);
              final emprunt = EmpruntModel(
                id: '',
                userId: user.uid,
                userNom: user.nom,
                userPrenom: user.prenom,
                userRole: user.role,
                documentId: document.id,
                documentTitre: document.titre,
                dateEmprunt: DateTime.now(),
                dateRetourPrevue:
                    DateTime.now().add(Duration(days: jours)),
                statut: 'en_attente',
              );

              final success = await ref
                  .read(empruntsNotifierProvider.notifier)
                  .createEmprunt(emprunt);

              if (success && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                        'Demande envoyée ! En attente de validation.'),
                    backgroundColor: Colors.green,
                  ),
                );
                Navigator.pop(context);
              }
            },
            child: const Text('Confirmer',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(label,
                style: const TextStyle(
                    fontWeight: FontWeight.bold, color: Colors.indigo)),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
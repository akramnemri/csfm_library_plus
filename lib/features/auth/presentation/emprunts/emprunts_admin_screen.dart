import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/emprunt_model.dart';
import '../../../../core/constants/app_constants.dart';
import 'emprunts_provider.dart';

class EmpruntsAdminScreen extends ConsumerWidget {
  const EmpruntsAdminScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final empruntsAsync = ref.watch(activeEmpruntsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestion des emprunts'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: empruntsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Erreur: $e')),
        data: (emprunts) {
          if (emprunts.isEmpty) {
            return const Center(
              child: Text('Aucun emprunt actif.',
                  style: TextStyle(color: Colors.grey)),
            );
          }
          return RefreshIndicator(
            onRefresh: () async {
              // ignore: unused_result
              ref.refresh(activeEmpruntsProvider);
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: emprunts.length,
              itemBuilder: (context, index) =>
                  _EmpruntAdminCard(emprunt: emprunts[index]),
            ),
          );
        },
      ),
    );
  }
}

class _EmpruntAdminCard extends ConsumerWidget {
  final EmpruntModel emprunt;
  const _EmpruntAdminCard({required this.emprunt});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isEnAttente = emprunt.statut == AppStatuts.enAttente;
    final isEnRetard = emprunt.estEnRetard;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(emprunt.documentTitre,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16)),
                ),
                _StatusBadge(emprunt.statut, isEnRetard),
              ],
            ),
            const SizedBox(height: 8),

            Text('${emprunt.userPrenom} ${emprunt.userNom}',
                style: const TextStyle(color: Colors.grey)),
            Text(
              emprunt.userRole == 'apprenant_loge'
                  ? '⭐ Apprenant logé'
                  : 'Apprenant externe',
              style: TextStyle(
                  fontSize: 12,
                  color: emprunt.userRole == 'apprenant_loge'
                      ? Colors.indigo
                      : Colors.grey),
            ),
            const SizedBox(height: 4),
            _CategoryBadge(emprunt.documentCategorie),
            const SizedBox(height: 8),

            Text('Emprunté le : ${_formatDate(emprunt.dateEmprunt)}'),
            Text(
              'Retour prévu : ${_formatDate(emprunt.dateRetourPrevue)}',
              style: TextStyle(
                  color: isEnRetard ? Colors.red : Colors.black,
                  fontWeight:
                      isEnRetard ? FontWeight.bold : FontWeight.normal),
            ),
            if (isEnRetard)
              Text(
                '⚠️ En retard de ${emprunt.joursRestants.abs()} jour(s)',
                style: const TextStyle(
                    color: Colors.red, fontWeight: FontWeight.bold),
              ),

            const SizedBox(height: 12),

            // Action buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (isEnAttente)
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green),
                    onPressed: () => ref
                        .read(empruntsNotifierProvider.notifier)
                        .validerEmprunt(emprunt.id),
                    child: const Text('Valider',
                        style: TextStyle(color: Colors.white)),
                  ),
                if (emprunt.statut == AppStatuts.actif) ...[
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.indigo),
                    onPressed: () => ref
                        .read(empruntsNotifierProvider.notifier)
                        .retournerDocument(emprunt.id, emprunt.documentId),
                    child: const Text('Retour rendu',
                        style: TextStyle(color: Colors.white)),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }
}

class _StatusBadge extends StatelessWidget {
  final String statut;
  final bool enRetard;
  const _StatusBadge(this.statut, this.enRetard);

  @override
  Widget build(BuildContext context) {
    final labels = {
      AppStatuts.enAttente: 'En attente',
      AppStatuts.actif: enRetard ? 'En retard' : 'Actif',
      AppStatuts.retourne: 'Retourné',
    };
    final colors = {
      AppStatuts.enAttente: Colors.orange,
      AppStatuts.actif: enRetard ? Colors.red : Colors.green,
      AppStatuts.retourne: Colors.grey,
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
       decoration: BoxDecoration(
         color: (colors[statut] ?? Colors.grey).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors[statut] ?? Colors.grey),
      ),
      child: Text(
        labels[statut] ?? statut,
        style: TextStyle(
            color: colors[statut] ?? Colors.grey,
            fontWeight: FontWeight.bold,
            fontSize: 12),
      ),
    );
  }
}

class _CategoryBadge extends StatelessWidget {
  final String categorie;
  const _CategoryBadge(this.categorie);

  @override
  Widget build(BuildContext context) {
    final labels = {
      AppCategories.livre: 'Livre',
      AppCategories.magazine: 'Magazine',
      AppCategories.dvd: 'DVD',
      AppCategories.supportPedagogique: 'Support',
    };
    final colors = {
      AppCategories.livre: Colors.indigo,
      AppCategories.magazine: Colors.teal,
      AppCategories.dvd: Colors.orange,
      AppCategories.supportPedagogique: Colors.purple,
    };
    final label = labels[categorie] ?? categorie;
    final color = colors[categorie] ?? Colors.grey;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
       decoration: BoxDecoration(
         color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(label,
          style: TextStyle(fontSize: 11, color: color)),
    );
  }
}
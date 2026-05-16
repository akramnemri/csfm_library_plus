import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/emprunt_model.dart';
import 'emprunts_provider.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_theme.dart';

class MesEmpruntsScreen extends ConsumerWidget {
  const MesEmpruntsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final empruntsAsync = ref.watch(userEmpruntsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes emprunts'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: empruntsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Erreur: $e')),
        data: (emprunts) {
          if (emprunts.isEmpty) {
            return const Center(
              child: Text("Vous n'avez aucun emprunt.",
                  style: TextStyle(color: Colors.grey)),
            );
          }
          return RefreshIndicator(
            onRefresh: () async {
              // ignore: unused_result
              ref.refresh(userEmpruntsProvider);
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: emprunts.length,
              itemBuilder: (context, index) =>
                  _UserEmpruntCard(emprunt: emprunts[index]),
            ),
          );
        },
      ),
    );
  }
}

class _UserEmpruntCard extends StatelessWidget {
  final EmpruntModel emprunt;
  const _UserEmpruntCard({required this.emprunt});

  @override
  Widget build(BuildContext context) {
    final isEnRetard = emprunt.estEnRetard;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Icon(
          Icons.book,
          color: isEnRetard ? AppTheme.errorColor : Theme.of(context).colorScheme.primary,
          size: 36,
        ),
        title: Text(emprunt.documentTitre,
            style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Emprunté le : ${_formatDate(emprunt.dateEmprunt)}'),
            if (emprunt.statut != AppStatuts.retourne)
              Text(
                'Retour prévu : ${_formatDate(emprunt.dateRetourPrevue)}',
                style: TextStyle(
                    color: isEnRetard ? AppTheme.errorColor : Colors.black),
              ),
            if (emprunt.dateRetourEffective != null)
              Text(
                  'Retourné le : ${_formatDate(emprunt.dateRetourEffective!)}'),
            if (isEnRetard)
              Text(
                '⚠️ En retard de ${emprunt.joursRestants.abs()} jour(s)',
                style: const TextStyle(
                    color: AppTheme.errorColor, fontWeight: FontWeight.bold),
              ),
          ],
        ),
        trailing: _StatusChip(emprunt.statut, isEnRetard),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }
}

class _StatusChip extends StatelessWidget {
  final String statut;
  final bool enRetard;
  const _StatusChip(this.statut, this.enRetard);

  @override
  Widget build(BuildContext context) {
    final label = {
      AppStatuts.enAttente: 'En attente',
      AppStatuts.actif: enRetard ? 'En retard' : 'Actif',
      AppStatuts.retourne: 'Retourné',
    }[statut] ?? statut;

    final color = {
      AppStatuts.enAttente: AppTheme.warningColor,
      AppStatuts.actif: enRetard ? AppTheme.errorColor : AppTheme.successColor,
      AppStatuts.retourne: Colors.grey,
    }[statut] ?? Colors.grey;

    return Chip(
      label: Text(label,
          style: TextStyle(color: color, fontSize: 11)),
       backgroundColor: color.withOpacity(0.1),
      side: BorderSide(color: color),
    );
  }
}
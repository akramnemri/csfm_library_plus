import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../presentation/auth_provider.dart';
import '../../domain/document_model.dart';
import 'catalogue_provider.dart';
import '../document_detail_screen.dart';
import '../add_edit_document_screen.dart';
import '../../../../core/theme/app_theme.dart';

class CatalogueScreen extends ConsumerWidget {
  const CatalogueScreen({super.key});

  static const categories = [
    {'value': null, 'label': 'Tous'},
    {'value': 'livre', 'label': 'Livres'},
    {'value': 'magazine', 'label': 'Magazines'},
    {'value': 'dvd', 'label': 'DVDs'},
    {'value': 'support_pedagogique', 'label': 'Supports'},
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filteredDocs = ref.watch(filteredDocumentsProvider);
    final selectedCategorie = ref.watch(selectedCategorieProvider);
    final authState = ref.watch(authProvider);
    final isAdmin = authState.user?.role == 'admin';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Catalogue'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      floatingActionButton: isAdmin
          ? FloatingActionButton(
              backgroundColor: Theme.of(context).colorScheme.primary,
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const AddEditDocumentScreen()),
              ),
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Rechercher par titre ou auteur...',
                hintStyle: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
                prefixIcon: Icon(Icons.search, color: Theme.of(context).colorScheme.primary),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Theme.of(context).colorScheme.outline),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Theme.of(context).colorScheme.outline),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 2),
                ),
                filled: true,
                fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
              ),
              onChanged: (val) =>
                  ref.read(searchQueryProvider.notifier).state = val,
            ),
          ),

          // Category filter chips
          SizedBox(
            height: 44,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final cat = categories[index];
                final isSelected = selectedCategorie == cat['value'];
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(cat['label'] as String,
                        style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
                    selected: isSelected,
                    selectedColor: Theme.of(context).colorScheme.primary,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    onSelected: (_) => ref
                        .read(selectedCategorieProvider.notifier)
                        .state = cat['value'],
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8),

          // Document list
          Expanded(
            child: filteredDocs.when(
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Erreur: $e')),
              data: (docs) {
                if (docs.isEmpty) {
                  return const Center(
                    child: Text('Aucun document trouvé.',
                        style: TextStyle(color: Colors.grey)),
                  );
                }
                return RefreshIndicator(
                  onRefresh: () async {
                    // ignore: unused_result
                    ref.refresh(documentsStreamProvider);
                  },
                  child: ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: docs.length,
                    itemBuilder: (context, index) =>
                        _DocumentCard(doc: docs[index], isAdmin: isAdmin, context: context),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _DocumentCard extends ConsumerWidget {
  final DocumentModel doc;
  final bool isAdmin;
  final BuildContext context;

  const _DocumentCard({required this.doc, required this.isAdmin, required this.context});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: doc.coverUrl.isNotEmpty
              ? Image.network(
                  doc.coverUrl,
                  width: 50,
                  height: 70,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _defaultCover(this.context),
                )
              : _defaultCover(this.context),
        ),
        title: Text(doc.titre,
            style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(doc.auteur, style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 4),
            Row(
              children: [
                _CategoryBadge(doc.categorie),
                const SizedBox(width: 8),
                _AvailabilityBadge(doc.disponible),
              ],
            ),
          ],
        ),
        trailing: isAdmin
            ? PopupMenuButton(
                itemBuilder: (_) => [
                  const PopupMenuItem(value: 'edit', child: Text('Modifier')),
                  const PopupMenuItem(
                      value: 'delete',
                      child:
                          Text('Supprimer', style: TextStyle(color: Colors.red))),
                ],
                onSelected: (val) {
                  if (val == 'edit') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) =>
                              AddEditDocumentScreen(document: doc)),
                    );
                  } else if (val == 'delete') {
                    _confirmDelete(context, ref);
                  }
                },
              )
            : null,
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) => DocumentDetailScreen(document: doc)),
        ),
      ),
    );
  }

  Widget _defaultCover(BuildContext context) {
       return Container(
         width: 50,
         height: 70,
         color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
      child: Icon(Icons.book, color: Theme.of(context).colorScheme.primary),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Supprimer'),
        content: Text('Supprimer "${doc.titre}" ?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annuler')),
          TextButton(
            onPressed: () {
              ref
                  .read(catalogueNotifierProvider.notifier)
                  .deleteDocument(doc.id);
              Navigator.pop(context);
            },
            child:
                const Text('Supprimer', style: TextStyle(color: Colors.red)),
          ),
        ],
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
      'livre': 'Livre',
      'magazine': 'Magazine',
      'dvd': 'DVD',
      'support_pedagogique': 'Support',
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
       decoration: BoxDecoration(
         color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
         borderRadius: BorderRadius.circular(12),
       ),
      child: Text(
        labels[categorie] ?? categorie,
        style: TextStyle(
          fontSize: 11,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}

class _AvailabilityBadge extends StatelessWidget {
  final bool disponible;
  const _AvailabilityBadge(this.disponible);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
         decoration: BoxDecoration(
           color: disponible 
               ? AppTheme.successColor.withOpacity(0.1)
               : AppTheme.errorColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        disponible ? 'Disponible' : 'Emprunté',
        style: TextStyle(
            fontSize: 11,
            color: disponible 
                ? AppTheme.successColor
                : AppTheme.errorColor),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../presentation/auth_provider.dart';
import '../../domain/document_model.dart';
import 'catalogue_provider.dart';
import '../document_detail_screen.dart';
import '../add_edit_document_screen.dart';

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
    final searchQuery = ref.watch(searchQueryProvider);
    final selectedCategorie = ref.watch(selectedCategorieProvider);
    final authState = ref.watch(authProvider);
    final isAdmin = authState.user?.role == 'admin';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Catalogue'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      floatingActionButton: isAdmin
          ? FloatingActionButton(
              backgroundColor: Colors.indigo,
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
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey[100],
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
                    label: Text(cat['label'] as String),
                    selected: isSelected,
                    selectedColor: Colors.indigo,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : Colors.black,
                    ),
                    onSelected: (_) => ref
                        .read(selectedCategorieProvider.notifier)
                        .state = cat['value'] as String?,
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
                return ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: docs.length,
                  itemBuilder: (context, index) =>
                      _DocumentCard(doc: docs[index], isAdmin: isAdmin),
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

  const _DocumentCard({required this.doc, required this.isAdmin});

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
                  errorBuilder: (_, __, ___) => _defaultCover(),
                )
              : _defaultCover(),
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

  Widget _defaultCover() {
    return Container(
      width: 50,
      height: 70,
      color: Colors.indigo[100],
      child: const Icon(Icons.book, color: Colors.indigo),
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
        color: Colors.indigo[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(labels[categorie] ?? categorie,
          style: const TextStyle(fontSize: 11, color: Colors.indigo)),
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
        color: disponible ? Colors.green[50] : Colors.red[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        disponible ? 'Disponible' : 'Emprunté',
        style: TextStyle(
            fontSize: 11,
            color: disponible ? Colors.green[700] : Colors.red[700]),
      ),
    );
  }
}
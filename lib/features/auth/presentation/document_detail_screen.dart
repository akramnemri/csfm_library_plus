import 'package:flutter/material.dart';
import '../domain/document_model.dart';

class DocumentDetailScreen extends StatelessWidget {
  final DocumentModel document;
  const DocumentDetailScreen({super.key, required this.document});

  @override
  Widget build(BuildContext context) {
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
            // Cover image
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
            _InfoRow(
                'Disponibilité', document.disponible ? 'Disponible' : 'Emprunté'),
            if (document.description.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Text('Description',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 8),
              Text(document.description,
                  style: const TextStyle(color: Colors.grey)),
            ],
          ],
        ),
      ),
    );
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
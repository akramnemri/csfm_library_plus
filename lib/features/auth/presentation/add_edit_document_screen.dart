import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/document_model.dart';
import 'catalogue/catalogue_provider.dart';

class AddEditDocumentScreen extends ConsumerStatefulWidget {
  final DocumentModel? document; // null = add, not null = edit
  const AddEditDocumentScreen({super.key, this.document});

  @override
  ConsumerState<AddEditDocumentScreen> createState() =>
      _AddEditDocumentScreenState();
}

class _AddEditDocumentScreenState
    extends ConsumerState<AddEditDocumentScreen> {
  final _titreController = TextEditingController();
  final _auteurController = TextEditingController();
  final _anneeController = TextEditingController();
  final _coverUrlController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _categorie = 'livre';
  bool _disponible = true;

  bool get isEditing => widget.document != null;

  @override
  void initState() {
    super.initState();
    if (isEditing) {
      final doc = widget.document!;
      _titreController.text = doc.titre;
      _auteurController.text = doc.auteur;
      _anneeController.text = doc.annee.toString();
      _coverUrlController.text = doc.coverUrl;
      _descriptionController.text = doc.description;
      _categorie = doc.categorie;
      _disponible = doc.disponible;
    }
  }

  @override
  void dispose() {
    _titreController.dispose();
    _auteurController.dispose();
    _anneeController.dispose();
    _coverUrlController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final doc = DocumentModel(
      id: widget.document?.id ?? '',
      titre: _titreController.text.trim(),
      auteur: _auteurController.text.trim(),
      categorie: _categorie,
      annee: int.tryParse(_anneeController.text.trim()) ?? 0,
      disponible: _disponible,
      coverUrl: _coverUrlController.text.trim(),
      description: _descriptionController.text.trim(),
    );

    if (isEditing) {
      await ref.read(catalogueNotifierProvider.notifier).updateDocument(doc);
    } else {
      await ref.read(catalogueNotifierProvider.notifier).addDocument(doc);
    }

    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(catalogueNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Modifier le document' : 'Ajouter un document'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildField(_titreController, 'Titre', Icons.title),
            const SizedBox(height: 12),
            _buildField(_auteurController, 'Auteur', Icons.person_outline),
            const SizedBox(height: 12),
            _buildField(_anneeController, 'Année', Icons.calendar_today,
                isNumber: true),
            const SizedBox(height: 12),
            _buildField(_coverUrlController, 'URL de couverture', Icons.image,
                hint: 'https://...'),
            const SizedBox(height: 12),
            _buildField(
                _descriptionController, 'Description', Icons.description,
                maxLines: 3),
            const SizedBox(height: 12),

            // Category dropdown
            DropdownButtonFormField<String>(
              value: _categorie,
              decoration: const InputDecoration(
                  labelText: 'Catégorie', border: OutlineInputBorder()),
              items: const [
                DropdownMenuItem(value: 'livre', child: Text('Livre')),
                DropdownMenuItem(value: 'magazine', child: Text('Magazine')),
                DropdownMenuItem(value: 'dvd', child: Text('DVD')),
                DropdownMenuItem(
                    value: 'support_pedagogique',
                    child: Text('Support pédagogique')),
              ],
              onChanged: (val) => setState(() => _categorie = val!),
            ),
            const SizedBox(height: 12),

            // Availability switch
            SwitchListTile(
              title: const Text('Disponible'),
              value: _disponible,
              activeColor: Colors.indigo,
              onChanged: (val) => setState(() => _disponible = val),
            ),
            const SizedBox(height: 24),

            if (state is AsyncError)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(state.error.toString(),
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center),
              ),

            ElevatedButton(
              onPressed: state is AsyncLoading ? null : _save,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigo,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: state is AsyncLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : Text(isEditing ? 'Enregistrer' : 'Ajouter',
                      style:
                          const TextStyle(fontSize: 16, color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildField(
    TextEditingController controller,
    String label,
    IconData icon, {
    bool isNumber = false,
    int maxLines = 1,
    String? hint,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon),
        border: const OutlineInputBorder(),
      ),
    );
  }
}
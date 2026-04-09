import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/catalogue_repository.dart';
import '../../domain/document_model.dart';

// Repository provider
final catalogueRepositoryProvider = Provider<CatalogueRepository>((ref) {
  return CatalogueRepository();
});

// All documents stream
final documentsStreamProvider = StreamProvider<List<DocumentModel>>((ref) {
  return ref.watch(catalogueRepositoryProvider).getDocuments();
});

// Search query state
final searchQueryProvider = StateProvider<String>((ref) => '');

// Selected category filter state
final selectedCategorieProvider = StateProvider<String?>((ref) => null);

// Filtered documents (search + category)
final filteredDocumentsProvider = Provider<AsyncValue<List<DocumentModel>>>((ref) {
  final documentsAsync = ref.watch(documentsStreamProvider);
  final query = ref.watch(searchQueryProvider).toLowerCase();
  final categorie = ref.watch(selectedCategorieProvider);

  return documentsAsync.whenData((docs) {
    return docs.where((doc) {
      final matchesQuery = query.isEmpty ||
          doc.titre.toLowerCase().contains(query) ||
          doc.auteur.toLowerCase().contains(query);
      final matchesCategorie =
          categorie == null || doc.categorie == categorie;
      return matchesQuery && matchesCategorie;
    }).toList();
  });
});

// Catalogue actions notifier
class CatalogueNotifier extends StateNotifier<AsyncValue<void>> {
  final CatalogueRepository _repo;

  CatalogueNotifier(this._repo) : super(const AsyncValue.data(null));

  Future<void> addDocument(DocumentModel doc) async {
    state = const AsyncValue.loading();
    try {
      await _repo.addDocument(doc);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> updateDocument(DocumentModel doc) async {
    state = const AsyncValue.loading();
    try {
      await _repo.updateDocument(doc);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> deleteDocument(String id) async {
    state = const AsyncValue.loading();
    try {
      await _repo.deleteDocument(id);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final catalogueNotifierProvider =
    StateNotifierProvider<CatalogueNotifier, AsyncValue<void>>((ref) {
  return CatalogueNotifier(ref.watch(catalogueRepositoryProvider));
});
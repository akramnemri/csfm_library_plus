import 'package:cloud_firestore/cloud_firestore.dart';
import '../domain/document_model.dart';

class CatalogueRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'documents';

  // Get all documents (realtime stream)
  Stream<List<DocumentModel>> getDocuments() {
    return _firestore
        .collection(_collection)
        .orderBy('titre')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => DocumentModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  // Get single document
  Future<DocumentModel?> getDocument(String id) async {
    final doc = await _firestore.collection(_collection).doc(id).get();
    if (!doc.exists) return null;
    return DocumentModel.fromMap(doc.data()!, doc.id);
  }

  // Add document (admin only)
  Future<void> addDocument(DocumentModel document) async {
    await _firestore.collection(_collection).add(document.toMap());
  }

  // Update document (admin only)
  Future<void> updateDocument(DocumentModel document) async {
    await _firestore
        .collection(_collection)
        .doc(document.id)
        .update(document.toMap());
  }

  // Delete document (admin only)
  Future<void> deleteDocument(String id) async {
    await _firestore.collection(_collection).doc(id).delete();
  }

  // Update availability only (used by emprunts feature)
  Future<void> updateDisponibilite(String id, bool disponible) async {
    await _firestore
        .collection(_collection)
        .doc(id)
        .update({'disponible': disponible});
  }
}
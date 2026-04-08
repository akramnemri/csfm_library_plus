import 'package:cloud_firestore/cloud_firestore.dart';
import '../domain/emprunt_model.dart';

class EmpruntsRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'emprunts';

  // Get all emprunts (admin)
  Stream<List<EmpruntModel>> getAllEmprunts() {
    return _firestore
        .collection(_collection)
        .orderBy('dateEmprunt', descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((doc) => EmpruntModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  // Get emprunts for a specific user
  Stream<List<EmpruntModel>> getUserEmprunts(String userId) {
    return _firestore
        .collection(_collection)
        .where('userId', isEqualTo: userId)
        .orderBy('dateEmprunt', descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((doc) => EmpruntModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  // Get active emprunts only (admin)
  Stream<List<EmpruntModel>> getActiveEmprunts() {
    return _firestore
        .collection(_collection)
        .where('statut', whereIn: ['actif', 'en_attente', 'en_retard'])
        .orderBy('dateRetourPrevue')
        .snapshots()
        .map((snap) => snap.docs
            .map((doc) => EmpruntModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  // Create a new emprunt request
  Future<void> createEmprunt(EmpruntModel emprunt) async {
    final batch = _firestore.batch();

    // Add emprunt
    final empruntRef = _firestore.collection(_collection).doc();
    batch.set(empruntRef, emprunt.toMap());

    // Mark document as unavailable
    final docRef =
        _firestore.collection('documents').doc(emprunt.documentId);
    batch.update(docRef, {'disponible': false});

    await batch.commit();
  }

  // Admin validates emprunt (en_attente → actif)
  Future<void> validerEmprunt(String empruntId) async {
    await _firestore
        .collection(_collection)
        .doc(empruntId)
        .update({'statut': 'actif'});
  }

  // Admin returns a document (actif → retourne)
  Future<void> retournerDocument(
      String empruntId, String documentId) async {
    final batch = _firestore.batch();

    // Update emprunt
    final empruntRef =
        _firestore.collection(_collection).doc(empruntId);
    batch.update(empruntRef, {
      'statut': 'retourne',
      'dateRetourEffective': DateTime.now().toIso8601String(),
    });

    // Mark document as available again
    final docRef = _firestore.collection('documents').doc(documentId);
    batch.update(docRef, {'disponible': true});

    await batch.commit();
  }

  // Check if user already has an active emprunt for a document
  Future<bool> hasActiveEmprunt(String userId, String documentId) async {
    final snap = await _firestore
        .collection(_collection)
        .where('userId', isEqualTo: userId)
        .where('documentId', isEqualTo: documentId)
        .where('statut', whereIn: ['en_attente', 'actif'])
        .get();
    return snap.docs.isNotEmpty;
  }
}
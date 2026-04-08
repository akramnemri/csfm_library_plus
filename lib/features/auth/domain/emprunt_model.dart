class EmpruntModel {
  final String id;
  final String userId;
  final String userNom;
  final String userPrenom;
  final String userRole;
  final String documentId;
  final String documentTitre;
  final DateTime dateEmprunt;
  final DateTime dateRetourPrevue;
  final DateTime? dateRetourEffective;
  final String statut; // 'en_attente' | 'actif' | 'retourne' | 'en_retard'

  const EmpruntModel({
    required this.id,
    required this.userId,
    required this.userNom,
    required this.userPrenom,
    required this.userRole,
    required this.documentId,
    required this.documentTitre,
    required this.dateEmprunt,
    required this.dateRetourPrevue,
    this.dateRetourEffective,
    required this.statut,
  });

  factory EmpruntModel.fromMap(Map<String, dynamic> map, String id) {
    return EmpruntModel(
      id: id,
      userId: map['userId'] ?? '',
      userNom: map['userNom'] ?? '',
      userPrenom: map['userPrenom'] ?? '',
      userRole: map['userRole'] ?? '',
      documentId: map['documentId'] ?? '',
      documentTitre: map['documentTitre'] ?? '',
      dateEmprunt: DateTime.parse(map['dateEmprunt']),
      dateRetourPrevue: DateTime.parse(map['dateRetourPrevue']),
      dateRetourEffective: map['dateRetourEffective'] != null
          ? DateTime.parse(map['dateRetourEffective'])
          : null,
      statut: map['statut'] ?? 'en_attente',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'userNom': userNom,
      'userPrenom': userPrenom,
      'userRole': userRole,
      'documentId': documentId,
      'documentTitre': documentTitre,
      'dateEmprunt': dateEmprunt.toIso8601String(),
      'dateRetourPrevue': dateRetourPrevue.toIso8601String(),
      'dateRetourEffective': dateRetourEffective?.toIso8601String(),
      'statut': statut,
    };
  }

  // Is this emprunt overdue?
  bool get estEnRetard =>
      statut == 'actif' && DateTime.now().isAfter(dateRetourPrevue);

  // Days remaining (negative = overdue)
  int get joursRestants =>
      dateRetourPrevue.difference(DateTime.now()).inDays;
}
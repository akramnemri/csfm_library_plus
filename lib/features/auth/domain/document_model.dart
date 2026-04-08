class DocumentModel {
  final String id;
  final String titre;
  final String auteur;
  final String categorie; // 'livre' | 'magazine' | 'dvd' | 'support_pedagogique'
  final int annee;
  final bool disponible;
  final String coverUrl; // URL string (no Storage needed)
  final String description;

  const DocumentModel({
    required this.id,
    required this.titre,
    required this.auteur,
    required this.categorie,
    required this.annee,
    required this.disponible,
    required this.coverUrl,
    required this.description,
  });

  factory DocumentModel.fromMap(Map<String, dynamic> map, String id) {
    return DocumentModel(
      id: id,
      titre: map['titre'] ?? '',
      auteur: map['auteur'] ?? '',
      categorie: map['categorie'] ?? 'livre',
      annee: map['annee'] ?? 0,
      disponible: map['disponible'] ?? true,
      coverUrl: map['coverUrl'] ?? '',
      description: map['description'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'titre': titre,
      'auteur': auteur,
      'categorie': categorie,
      'annee': annee,
      'disponible': disponible,
      'coverUrl': coverUrl,
      'description': description,
    };
  }
}
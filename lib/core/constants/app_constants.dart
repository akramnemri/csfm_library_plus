class AppRoles {
  static const String apprenantLoge = 'apprenant_loge';
  static const String apprenantExterne = 'apprenant_externe';
  static const String admin = 'admin';

  static const List<String> all = [apprenantLoge, apprenantExterne, admin];

  static String getLabel(String role) {
    switch (role) {
      case apprenantLoge:
        return 'Apprenant logé';
      case apprenantExterne:
        return 'Apprenant externe';
      case admin:
        return 'Administrateur';
      default:
        return role;
    }
  }

  static bool isApprenant(String role) =>
      role == apprenantLoge || role == apprenantExterne;
}

class AppCategories {
  static const String livre = 'livre';
  static const String magazine = 'magazine';
  static const String dvd = 'dvd';
  static const String supportPedagogique = 'support_pedagogique';

  static const List<String> all = [
    livre,
    magazine,
    dvd,
    supportPedagogique,
  ];

  static String getLabel(String category) {
    switch (category) {
      case livre:
        return 'Livre';
      case magazine:
        return 'Magazine';
      case dvd:
        return 'DVD';
      case supportPedagogique:
        return 'Support pédagogique';
      default:
        return category;
    }
  }
}

class AppStatuts {
  static const String enAttente = 'en_attente';
  static const String actif = 'actif';
  static const String retourne = 'retourne';
  static const String enRetard = 'en_retard';

  static String getLabel(String statut) {
    switch (statut) {
      case enAttente:
        return 'En attente';
      case actif:
        return 'Actif';
      case retourne:
        return 'Retourné';
      case enRetard:
        return 'En retard';
      default:
        return statut;
    }
  }
}

class FirestoreCollections {
  static const String users = 'users';
  static const String documents = 'documents';
  static const String emprunts = 'emprunts';
}

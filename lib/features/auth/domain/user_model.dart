class UserModel {
  final String uid;
  final String email;
  final String nom;
  final String prenom;
  final String role; // 'apprenant_loge' | 'apprenant_externe' | 'admin'

  const UserModel({
    required this.uid,
    required this.email,
    required this.nom,
    required this.prenom,
    required this.role,
  });

  // Convert Firestore document → UserModel
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      email: map['email'] ?? '',
      nom: map['nom'] ?? '',
      prenom: map['prenom'] ?? '',
      role: map['role'] ?? 'apprenant_externe',
    );
  }

  // Convert UserModel → Firestore document
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'nom': nom,
      'prenom': prenom,
      'role': role,
    };
  }
}
# 📚 CSFM Library+

> Application mobile de gestion de bibliothèque scolaire — Centre Sectoriel de Formation en Maintenance (CSFM) de Nabeul.

---

## ✨ Aperçu

CSFM Library+ est une application Flutter/Firebase qui modernise la gestion de la bibliothèque du CSFM. Elle permet aux apprenants de consulter le catalogue, de demander des emprunts en ligne, et au personnel de gérer les retours et suivre les statistiques.

---

## 📱 Captures d'écran

> *(à ajouter après les tests sur appareil physique)*

---

## 🚀 Fonctionnalités

### Apprenants
- 🔐 Création de compte et connexion sécurisée
- 📖 Consultation du catalogue (livres, magazines, DVDs, supports pédagogiques)
- 🔍 Recherche par titre / auteur + filtres par catégorie
- 📋 Demande d'emprunt en ligne
- ⭐ Priorité accordée aux apprenants logés (14 jours vs 7 jours)
- 📜 Historique personnel des emprunts
- 🔔 Rappels automatiques de retour

### Administrateur / Bibliothécaire
- ✅ Validation des demandes d'emprunt
- 🔄 Enregistrement des retours
- ➕ Ajout, modification, suppression de documents
- ⚠️ Suivi des retards
- 📊 Statistiques : livres les plus empruntés, documents par catégorie, retards par mois

---

## 🛠 Stack technique

| Élément | Technologie |
|--------|-------------|
| UI | Flutter (Android en priorité) |
| Authentification | Firebase Authentication |
| Base de données | Cloud Firestore |
| Notifications | Firebase Cloud Messaging |
| State management | Riverpod |
| Navigation | Intégré (Navigator) |
| Charts | fl_chart |

---

## 📁 Structure du projet

```
lib/
├── core/
│   ├── constants/
│   ├── errors/
│   ├── router/
│   ├── services/          # NotificationService
│   └── theme/
├── features/
│   ├── auth/              # Login, Register, UserModel
│   ├── catalogue/         # Documents, Search, Filters
│   ├── emprunts/          # Borrow, Return, History
│   ├── home/              # HomeScreen, AdminHomeScreen, ProfileScreen
│   ├── notifications/
│   └── statistiques/      # Charts, Summary
├── shared/
│   ├── widgets/
│   └── utils/
└── main.dart
```

---

## ⚙️ Installation

### Prérequis
- Flutter SDK (stable) — [flutter.dev](https://flutter.dev)
- Compte Firebase — [firebase.google.com](https://firebase.google.com)
- Android Studio (pour l'émulateur) ou appareil Android

### Étapes

**1. Cloner le dépôt**
```bash
git clone https://github.com/YOUR_USERNAME/csfm_library_plus.git
cd csfm_library_plus
```

**2. Installer les dépendances**
```bash
flutter pub get
```

**3. Configurer Firebase**

> ⚠️ Les fichiers `google-services.json` et `firebase_options.dart` ne sont pas inclus dans ce dépôt pour des raisons de sécurité. Vous devez générer les vôtres.

```bash
# Installer FlutterFire CLI
dart pub global activate flutterfire_cli

# Connecter votre projet Firebase
dart pub global run flutterfire_cli:flutterfire configure
```

Puis activer dans la console Firebase :
- Authentication (Email/Password)
- Cloud Firestore
- Firebase Cloud Messaging

**4. Lancer l'application**
```bash
flutter run
```

---

## 🔐 Rôles utilisateurs

| Rôle | Accès |
|------|-------|
| `apprenant_loge` | Catalogue, emprunts (14j), historique, notifications |
| `apprenant_externe` | Catalogue, emprunts (7j), historique, notifications |
| `admin` | Tout + gestion catalogue + validation + statistiques |

---

## 🗃 Collections Firestore

```
users/
  └── {uid}: { email, nom, prenom, role, fcmToken }

documents/
  └── {id}: { titre, auteur, categorie, annee, disponible, coverUrl, description }

emprunts/
  └── {id}: { userId, documentId, dateEmprunt, dateRetourPrevue, dateRetourEffective, statut }
```

---

## 🔒 Sécurité

- Les règles Firestore limitent l'accès selon le rôle de l'utilisateur
- Les fichiers de configuration Firebase sont exclus du dépôt via `.gitignore`
- Les mots de passe ne sont jamais stockés en clair (Firebase Auth)

---

## 📅 Planning du projet

| Phase | Durée | Livrable |
|-------|-------|----------|
| Analyse & UX Design | 1 semaine | MCD + maquettes |
| Développement | 4–5 semaines | Application complète |
| Tests & déploiement | 1 semaine | APK fonctionnel |
| Formation du personnel | 1 journée | Guide d'utilisation |

---

## 👤 Auteur

Développé dans le cadre du projet **DEVMOB-ApcPedagogie-18** au CSFM de Nabeul.

---

## 📄 Licence

Ce projet est réalisé à des fins pédagogiques — CSFM Nabeul © 2024.
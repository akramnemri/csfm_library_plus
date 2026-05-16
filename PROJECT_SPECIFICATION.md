# CSFM Library+ — Project Specification & Agent Guideline

## Project Identity
- **Name:** csfm_library_plus
- **Description:** A Flutter mobile application for managing a school library at CSFM (Centre Sectoriel de Formation en Maintenance) de Nabeul. Built for students ("apprenants") and library administrators.
- **Platform:** Android (primary), Flutter SDK ^3.9.0
- **State Management:** Riverpod (flutter_riverpod + riverpod_annotation)
- **Navigation:** Native Flutter Navigator (go_router is a dependency but not yet wired)
- **Backend:** Firebase (Authentication, Cloud Firestore, Cloud Messaging, Storage)
- **Code Generation:** freezed_annotation, json_annotation, build_runner, json_serializable
- **Testing Mocks:** mocktail

---

## Project Structure

```
lib/
├── main.dart                              # App entry, Firebase init, root redirect
├── firebase_options.dart                  # Firebase config (auto-generated)
├── core/
│   ├── constants/
│   │   ├── app_constants.dart             # Roles, categories, statuses, Firestore collection names
│   │   ├── app_strings.dart               # UI string constants
│   │   └── app_config.dart                # Environment config (dev/prod), borrow day limits
│   ├── errors/
│   │   ├── failure.dart                   # Abstract Failure + Server/Cache/Network/Auth/Validation
│   │   └── exception.dart                 # AppException + Server/Cache/Network/Auth exceptions
│   ├── services/
│   │   └── connectivity_service.dart      # Network connectivity stream + checker
│   ├── theme/
│   │   ├── app_theme.dart                 # Light and dark theme definitions, colors, spacing, radii
│   │   └── theme_provider.dart            # Theme management with Riverpod for light/dark mode switching
│   └── utils/
│       └── date_utils.dart                # Date formatting, parsing, overdue check, days-between
└── features/
    └── auth/
        ├── domain/
        │   ├── user_model.dart            # UserModel (uid, email, nom, prenom, role)
        │   ├── document_model.dart        # DocumentModel (id, titre, auteur, categorie, annee, disponible, coverUrl, description)
        │   └── emprunt_model.dart         # EmpruntModel (id, userId, userNom, userPrenom, userRole, documentId, documentTitre, dateEmprunt, dateRetourPrevue, dateRetourEffective?, statut)
        │                                 # Computed: estEnRetard (bool), joursRestants (int)
        ├── data/
        │   ├── auth_repository.dart       # AuthRepository: login, register, logout, resetPassword, getCurrentUserData, authStateChanges
        │   ├── catalogue_repository.dart  # CatalogueRepository: CRUD on documents, updateDisponibilite
        │   └── emprunts_repository.dart   # EmpruntsRepository: CRUD on emprunts, createEmprunt (batch update document availability), validerEmprunt, retournerDocument (batch), hasActiveEmprunt
        └── presentation/
            ├── auth_provider.dart         # AuthNotifier (login, register, logout, resetPassword) + providers
            ├── login_screen.dart          # Email/password login with remember-me stub, validation, error messages
            ├── register_screen.dart       # Full registration form with role selection (apprenant_loge, apprenant_externe), password validation
            ├── forgot_password_screen.dart# Password reset via email
            ├── home_screen.dart           # USER home: 4 tabs (Dashboard, Catalogue, Mes Emprunts, Profile)
            ├── admin_home_screen.dart     # ADMIN home: 5 tabs (Dashboard, Catalogue, Emprunts, Stats, Profile)
            ├── profile_screen.dart        # User profile display with role badge, notification test, logout
            ├── document_detail_screen.dart# Shows document details + borrow button (non-admin only, 14/7 day logic)
            ├── add_edit_document_screen.dart# Admin form to add/edit documents (title, author, year, coverUrl, description, category, availability)
            ├── catalogue/
            │   ├── catalogue_screen.dart  # Browse documents with search bar, category filter chips, FAB for admin
            │   └── catalogue_provider.dart # documentsStreamProvider, searchQueryProvider, selectedCategorieProvider, filteredDocumentsProvider, CatalogueNotifier
            ├── emprunts/
            │   ├── emprunts_provider.dart  # empruntsNotifierProvider, allEmpruntsProvider, activeEmpruntsProvider, userEmpruntsProvider, statistics providers (summary, empruntsParDocument, documentsParCategorie, retardsParMois)
            │   ├── mes_emprunts_screen.dart# User's personal borrow history with status chips
            │   └── emprunts_admin_screen.dart# Admin borrow management: validate pending, mark returned, status badges, overdue indicators
            ├── statistiques/
            │   └── statistiques_screen.dart# Dashboard with summary cards, top-books horizontal bar chart, category pie chart, overdue-by-month bar chart (all using fl_chart)
            └── notifications/
                ├── notification_service.dart# Singleton NotificationService: FCM init, local notifications, foreground/background handlers, notifyDisponible, notifyRetourRappel (3/1/0 day thresholds), saveTokenToFirestore
                └── notification_provider.dart# notificationServiceProvider, NotificationChecker class, notificationCheckerProvider
```
lib/
├── main.dart                              # App entry, Firebase init, root redirect
├── firebase_options.dart                  # Firebase config (auto-generated)
├── core/
│   ├── constants/
│   │   ├── app_constants.dart             # Roles, categories, statuses, Firestore collection names
│   │   ├── app_strings.dart               # UI string constants
│   │   └── app_config.dart                # Environment config (dev/prod), borrow day limits
│   ├── errors/
│   │   ├── failure.dart                   # Abstract Failure + Server/Cache/Network/Auth/Validation
│   │   └── exception.dart                 # AppException + Server/Cache/Network/Auth exceptions
│   ├── services/
│   │   └── connectivity_service.dart      # Network connectivity stream + checker
│   ├── theme/
│   │   ├── app_theme.dart                 # Light and dark theme definitions, colors, spacing, radii
│   │   └── theme_provider.dart            # Theme management with Riverpod for light/dark mode switching
│   └── utils/
│       └── date_utils.dart                # Date formatting, parsing, overdue check, days-between
└── features/
    └── auth/
        ├── domain/
        │   ├── user_model.dart            # UserModel (uid, email, nom, prenom, role)
        │   ├── document_model.dart        # DocumentModel (id, titre, auteur, categorie, annee, disponible, coverUrl, description)
        │   └── emprunt_model.dart         # EmpruntModel (id, userId, userNom, userPrenom, userRole, documentId, documentTitre, dateEmprunt, dateRetourPrevue, dateRetourEffective?, statut)
        │                                 # Computed: estEnRetard (bool), joursRestants (int)
        ├── data/
        │   ├── auth_repository.dart       # AuthRepository: login, register, logout, resetPassword, getCurrentUserData, authStateChanges
        │   ├── catalogue_repository.dart  # CatalogueRepository: CRUD on documents, updateDisponibilite
        │   └── emprunts_repository.dart   # EmpruntsRepository: CRUD on emprunts, createEmprunt (batch update document availability), validerEmprunt, retournerDocument (batch), hasActiveEmprunt
        └── presentation/
            ├── auth_provider.dart         # AuthNotifier (login, register, logout, resetPassword) + providers
            ├── login_screen.dart          # Email/password login with remember-me stub, validation, error messages
            ├── register_screen.dart       # Full registration form with role selection (apprenant_loge, apprenant_externe), password validation
            ├── forgot_password_screen.dart# Password reset via email
            ├── home_screen.dart           # USER home: 4 tabs (Dashboard, Catalogue, Mes Emprunts, Profile)
            ├── admin_home_screen.dart     # ADMIN home: 5 tabs (Dashboard, Catalogue, Emprunts, Stats, Profile)
            ├── profile_screen.dart        # User profile display with role badge, notification test, logout
            ├── document_detail_screen.dart# Shows document details + borrow button (non-admin only, 14/7 day logic)
            ├── add_edit_document_screen.dart# Admin form to add/edit documents (title, author, year, coverUrl, description, category, availability)
            ├── catalogue/
            │   ├── catalogue_screen.dart  # Browse documents with search bar, category filter chips, FAB for admin
            │   └── catalogue_provider.dart # documentsStreamProvider, searchQueryProvider, selectedCategorieProvider, filteredDocumentsProvider, CatalogueNotifier
            ├── emprunts/
            │   ├── emprunts_provider.dart  # empruntsNotifierProvider, allEmpruntsProvider, activeEmpruntsProvider, userEmpruntsProvider, statistics providers (summary, empruntsParDocument, documentsParCategorie, retardsParMois)
            │   ├── mes_emprunts_screen.dart# User's personal borrow history with status chips
            │   └── emprunts_admin_screen.dart# Admin borrow management: validate pending, mark returned, status badges, overdue indicators
            ├── statistiques/
            │   └── statistiques_screen.dart# Dashboard with summary cards, top-books horizontal bar chart, category pie chart, overdue-by-month bar chart (all using fl_chart)
            └── notifications/
                ├── notification_service.dart# Singleton NotificationService: FCM init, local notifications, foreground/background handlers, notifyDisponible, notifyRetourRappel (3/1/0 day thresholds), saveTokenToFirestore
                └── notification_provider.dart# notificationServiceProvider, NotificationChecker class, notificationCheckerProvider
```

---

## Firebase Firestore Schema

### Collection: `users/{uid}`
| Field | Type | Description |
|-------|------|-------------|
| email | String | User email |
| nom | String | Last name |
| prenom | String | First name |
| role | String | `apprenant_loge` / `apprenant_externe` / `admin` |
| fcmToken | String | Firebase Cloud Messaging token |

### Collection: `documents/{id}`
| Field | Type | Description |
|-------|------|-------------|
| titre | String | Document title |
| auteur | String | Author name |
| categorie | String | `livre` / `magazine` / `dvd` / `support_pedagogique` |
| annee | int | Publication year |
| disponible | bool | Whether the document is available for borrowing |
| coverUrl | String | URL of cover image |
| description | String | Document description |

### Collection: `emprunts/{id}`
| Field | Type | Description |
|-------|------|-------------|
| userId | String | Borrower's Firebase UID |
| documentId | String | Borrowed document's Firestore ID |
| userNom | String | Borrower last name (denormalized) |
| userPrenom | String | Borrower first name (denormalized) |
| userRole | String | Borrower role at time of borrow (denormalized) |
| documentTitre | String | Document title (denormalized) |
| dateEmprunt | DateTime | Borrow date |
| dateRetourPrevue | DateTime | Expected return date |
| dateRetourEffective | DateTime? | Actual return date (null if not returned) |
| statut | String | `en_attente` / `actif` / `retourne` / `en_retard` |

---

## Domain Models (Plain Dart Classes — No Codegen)

All three models (UserModel, DocumentModel, EmpruntModel) are **plain Dart classes** with manual `fromMap` factories and `toMap` methods. They are NOT using freezed/json_serializable despite those dependencies being listed.

**Key model logic:**
- `EmpruntModel.estEnRetard` — true when statut is 'actif' or 'en_retard' AND current date is past dateRetourPrevue
- `EmpruntModel.joursRestants` — days difference (negative = overdue)

---

## User Roles & Permissions

| Role | Borrow Duration | Capabilities |
|------|----------------|--------------|
| `apprenant_loge` | 14 days | Browse catalogue, request borrow, view own history, receive notifications |
| `apprenant_externe` | 7 days | Browse catalogue, request borrow, view own history, receive notifications |
| `admin` | N/A | Everything above PLUS: add/edit/delete documents, validate/return emprunts, view all emprunts, view statistics |

Role is determined at login via `authProvider.user.role` and controls:
- Which home screen is shown (`_RootRedirect` in main.dart)
- Whether FAB/edit/delete buttons appear in catalogue
- Whether borrow button appears in document detail
- Which bottom nav tabs are shown

---

## Riverpod Provider Architecture

**Auth layer:**
- `authRepositoryProvider` — plain Provider<AuthRepository>
- `authProvider` — StateNotifierProvider<AuthNotifier, AuthState>
- `currentUserProvider` — FutureProvider<UserModel?>

**Catalogue layer:**
- `catalogueRepositoryProvider` — plain Provider<CatalogueRepository>
- `documentsStreamProvider` — StreamProvider<List<DocumentModel>>
- `searchQueryProvider` — StateProvider<String>
- `selectedCategorieProvider` — StateProvider<String?>
- `filteredDocumentsProvider` — computed Provider<AsyncValue<List<DocumentModel>>>
- `catalogueNotifierProvider` — StateNotifierProvider<CatalogueNotifier, AsyncValue<void>>

**Emprunts layer:**
- `empruntsRepositoryProvider` — plain Provider<EmpruntsRepository>
- `allEmpruntsProvider` — StreamProvider<List<EmpruntModel>>
- `activeEmpruntsProvider` — StreamProvider<List<EmpruntModel>>
- `userEmpruntsProvider` — StreamProvider<List<EmpruntModel>>
- `empruntsNotifierProvider` — StateNotifierProvider<EmpruntsNotifier, AsyncValue<void>>
- `summaryProvider` — FutureProvider<Map<String, int>>
- `empruntsParDocumentProvider` — FutureProvider<Map<String, int>>
- `documentsParCategorieProvider` — FutureProvider<Map<String, int>>
- `retardsParMoisProvider` — FutureProvider<Map<String, int>>

**Notification layer:**
- `notificationServiceProvider` — plain Provider<NotificationService>
- `notificationCheckerProvider` — plain Provider<NotificationChecker>

**Connectivity layer:**
- `connectivityProvider` — StreamProvider<bool>
- `connectivityCheckerProvider` — plain Provider<ConnectivityService>

**Pattern:** Repository classes are instantiated directly inside providers (no dependency injection beyond that). StateNotifiers hold the mutable async state. StreamProviders wrap Firestore `.snapshots()`. Computed Providers combine streams with state.

---

## UI / Design System

**Theme:**
- Primary: Indigo (#3F51B5) with secondary #7986CB
- Surface: White, Background: #F5F5F5
- Error: Red, Success: Green, Warning: Orange
- Material 3, with light and dark theme support

**Dark Mode Implementation:**
- Added theme management using Riverpod StateNotifier
- Light and dark themes defined in `app_theme.dart` with appropriate color schemes
- Dark mode toggle switch available in Profile screen
- All UI components adapt to theme changes using `Theme.of(context)`
- Consistent theming across all screens and components
- Uses Material 3 color scheme with appropriate brightness values

**Typography:** AppBar titles in white on indigo, body text default, bold for emphasis

**Components:**
- `_StatCard` / `_AdminStatCard` — stat display cards with icon + value + label
- `_QuickAction` — tappable action card with icon + label
- `_CategoryBadge` — indigo-tinted chip for document category
- `_AvailabilityBadge` — green/red chip for document availability
- `_StatusChip` / `_StatusBadge` — colored chip/badge for emprunt status
- `_InfoRow` — label-value row in document detail
- `_ChartCard` — container wrapper for charts with shadow
- `_SectionTitle` — bold section headings
- `_EmptyChart` — placeholder for empty chart data

**Screens (14 total):**
1. `LoginScreen` — email + password with validation
2. `RegisterScreen` — full sign-up with role dropdown
3. `ForgotPasswordScreen` — email-based password reset
4. `HomeScreen` (user) — 4-tab layout
5. `AdminHomeScreen` — 5-tab layout
6. `CatalogueScreen` — browsable document list
7. `DocumentDetailScreen` — document info + borrow action
8. `AddEditDocumentScreen` — admin form for documents
9. `MesEmpruntsScreen` — user's borrow history
10. `EmpruntsAdminScreen` — admin borrow management
11. `ProfileScreen` — user profile + test notification + logout
12. `StatistiquesScreen` — charts and summary

---

## Key Business Logic

1. **Borrow duration:** Logged students get 14 days, external students get 7 days (hardcoded in `document_detail_screen.dart` line 111)
2. **Duplicate borrow prevention:** `EmpruntsRepository.hasActiveEmprunt()` checks for active/pending emprunts before creating a new one
3. **Batch operations:** Both `createEmprunt` and `retournerDocument` use Firestore batch writes to atomically update both emprunt status and document availability
4. **Notification timing:** Reminders trigger at 3 days, 1 day, 0 days before return, plus overdue (checked on dashboard load via `notificationCheckerProvider`)
5. **Search + Filter:** Catalogue combines text search (title/author) with category filter in a single computed provider
6. **Statistics:** Four FutureProvider-based stats computed from full emprunts list: summary counts, per-document borrow count, per-category count, per-month overdue count

---

## Known Issues (Post-Fix Status)

All previously identified issues have been resolved as of this revision. The full fix log is below.

---

## Bug Fixes Applied (Change Log)

### 🔴 Bug #1 — `documentsParCategorieProvider` grouped by title instead of category
- **Root cause:** Provider counted emprunts by `documentTitre` instead of `documentCategorie`
- **Fix:** Added `documentCategorie` field to `EmpruntModel` (plain Dart string stored in Firestore). Provider now groups by `e.documentCategorie`. Updated `createEmprunt` in `document_detail_screen.dart` to pass `document.categorie`.
- **Files changed:** `domain/emprunt_model.dart`, `data/emprunts_repository.dart`, `presentation/emprunts/emprunts_provider.dart`, `presentation/document_detail_screen.dart`, `presentation/emprunts/emprunts_admin_screen.dart`

### 🔴 Bug #2 — Duplicate/spammy notifications on every dashboard load
- **Root cause:** `NotificationChecker.checkEmpruntsRetards()` had no deduplication — same notifications fired repeatedly with no timer guard
- **Fix:** Added `_sentNotifications` Set for dedup keys + 30-second debounce Timer. Only overdue emprunts (`estEnRetard == true`) are now checked.
- **File changed:** `presentation/notifications/notification_provider.dart`

### 🔴 Bug #3 — Login flow race condition
- **Root cause:** `login()` returned `Future<void>`, so the caller read `authProvider` state before it updated.
- **Fix:** `AuthNotifier.login()` now returns `Future<bool>` (success/failure). Login screen uses the boolean to gate navigation. Added `_isLoggingIn` guard to prevent double-tap.
- **Files changed:** `auth_provider.dart`, `login_screen.dart`

### 🔴 Bug #4 — `_loadSavedCredentials()` not awaited + stub `_getPrefs()`
- **Root cause:** `_getPrefs()` always returned null. `initState` didn't await the call.
- **Fix:** Replaced stub with real `SharedPreferences.getInstance()`. Credentials now actually persist. `initState` calls `_loadSavedCredentials()` (no await needed since `setState` is called inside).
- **File changed:** `login_screen.dart`

### 🟡 #5 — No form validation on `AddEditDocumentScreen`
- **Fix:** Replaced `TextField` widgets with `TextFormField` inside a `Form` widget with `GlobalKey<FormState>`. Added validators: `_validateTitre` (required), `_validateAuteur` (required), `_validateAnnee` (required, numeric, valid year). `_save()` now checks `_formKey.currentState!.validate()` before proceeding.
- **File changed:** `add_edit_document_screen.dart`

### 🟡 #6 — `notification_provider.dart` used `List<dynamic>`
- **Fix:** Changed to `List<EmpruntModel>` throughout `NotificationChecker`.
- **File changed:** `notification_provider.dart`

### 🟡 #7 — Connectivity service unused
- **Fix:** Integrated into both `HomeScreen` and `AdminHomeScreen`. A connectivity banner ("Pas de connexion Internet") appears at the bottom navigation bar when offline using `ConnectivityService().isConnected`.
- **Files changed:** `home_screen.dart`, `admin_home_screen.dart`, `connectivity_service.dart`

### 🟡 #8 — Dead `AppConfig` with placeholder values
- **Status:** Left as-is — `AppConfig.dev`/`AppConfig.prod` are placeholder holders. The real Firebase config is in `firebase_options.dart`. No functional impact.

### 🟡 #9 — Typo `confermer` → `confirmer`
- **Fix:** Corrected in `app_strings.dart`.
- **File changed:** `app_strings.dart`

### 🟢 #10 — Remember-me checkbox was cosmetic
- **Fix:** Now fully functional with `SharedPreferences` — saves/loads email + password + remember flag.

### 🟢 #11 — No pull-to-refresh on `MesEmpruntsScreen`, `EmpruntsAdminScreen`, `CatalogueScreen`
- **Fix:** Added `RefreshIndicator` wrapping all three lists. Catalogue screen's `RefreshIndicator` is inside the `data` builder of the stream to avoid double-nesting issues.
- **Files changed:** `mes_emprunts_screen.dart`, `emprunts_admin_screen.dart`, `catalogue_screen.dart`

### 🟢 #12 — No empty-state illustrations
- **Status:** Left plain text messages — adding illustrations is a future enhancement, not a bug.

### Additional Improvement
- `EmpruntsAdminScreen` and `MesEmpruntsScreen` now use `AppStatuts` / `AppCategories` constants instead of raw strings, improving consistency and reducing magic strings.
- `_formatDate` method added to `_CategoryBadge` in admin screen.
- Stream providers in `RefreshIndicator` use `// ignore: unused_result` comments to suppress the `unused_result` lint on `ref.refresh()`.

### 🟢 #13 — Dark Mode Implementation
- **Feature:** Added system-wide dark/light mode support with user-toggleable preference
- **Implementation:** 
  - Created ThemeNotifier with Riverpod StateNotifier for theme state management
  - Defined light and dark themes in app_theme.dart using Material 3 color schemes
  - Updated main.dart to use ConsumerWidget and theme provider
  - Added dark mode toggle switch in Profile screen
  - Updated all screens and components to use Theme.of(context) for adaptive colors
  - Ensured consistent theming across all UI elements (buttons, cards, chips, etc.)
- **Files changed:** 
  - core/theme/theme_provider.dart (new)
  - core/theme/app_theme.dart (updated)
  - main.dart (updated)
  - features/auth/presentation/profile_screen.dart (updated)
  - features/auth/presentation/home_screen.dart (updated)
  - features/auth/presentation/login_screen.dart (updated)
  - features/auth/presentation/register_screen.dart (updated)
  - features/auth/presentation/forgot_password_screen.dart (updated)
  - features/auth/presentation/catalogue/catalogue_screen.dart (updated)
  - features/auth/presentation/emprunts/mes_emprunts_screen.dart (updated)
  - features/auth/presentation/statistiques/statistiques_screen.dart (updated)

---

## Post-Fix Code Quality
- **Flutter Analyzer: 0 issues** ✅ (0 errors, 0 warnings, 0 infos)

---

## Coding Conventions Observed

- Import style: `package:` imports first, then relative `../` imports
- Widget naming: Screen classes are named `*Screen`, provider files match their screen names
- State management: `StateNotifier` + `StateNotifierProvider` for mutable operations, `StreamProvider` for realtime data, `FutureProvider` for one-shot async, plain `Provider` for repositories/services
- Naming: snake_case for Firestore fields, camelCase for Dart properties
- UI pattern: `ConsumerWidget`/`ConsumerStatefulWidget` with `ref.watch()` for reads, `ref.read()` for actions
- Async state: `AsyncValue` wrapper pattern (loading/data/error states)
- File encoding: UTF-8 with BOM
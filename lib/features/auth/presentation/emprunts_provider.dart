import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/emprunts_repository.dart';
import '../domain/emprunt_model.dart';
import '../../auth/presentation/auth_provider.dart';

final empruntsRepositoryProvider = Provider<EmpruntsRepository>((ref) {
  return EmpruntsRepository();
});

// All emprunts stream (admin)
final allEmpruntsProvider = StreamProvider<List<EmpruntModel>>((ref) {
  return ref.watch(empruntsRepositoryProvider).getAllEmprunts();
});

// Active emprunts stream (admin)
final activeEmpruntsProvider = StreamProvider<List<EmpruntModel>>((ref) {
  return ref.watch(empruntsRepositoryProvider).getActiveEmprunts();
});

// Current user emprunts stream
final userEmpruntsProvider = StreamProvider<List<EmpruntModel>>((ref) {
  final user = ref.watch(authProvider).user;
  if (user == null) return const Stream.empty();
  return ref.watch(empruntsRepositoryProvider).getUserEmprunts(user.uid);
});

// Emprunts actions
class EmpruntsNotifier extends StateNotifier<AsyncValue<void>> {
  final EmpruntsRepository _repo;

  EmpruntsNotifier(this._repo) : super(const AsyncValue.data(null));

  Future<bool> createEmprunt(EmpruntModel emprunt) async {
    state = const AsyncValue.loading();
    try {
      // Check for duplicate
      final hasActive = await _repo.hasActiveEmprunt(
          emprunt.userId, emprunt.documentId);
      if (hasActive) {
        state = AsyncValue.error(
            'Vous avez déjà un emprunt actif pour ce document.',
            StackTrace.current);
        return false;
      }
      await _repo.createEmprunt(emprunt);
      state = const AsyncValue.data(null);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }

  Future<void> validerEmprunt(String empruntId) async {
    state = const AsyncValue.loading();
    try {
      await _repo.validerEmprunt(empruntId);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> retournerDocument(
      String empruntId, String documentId) async {
    state = const AsyncValue.loading();
    try {
      await _repo.retournerDocument(empruntId, documentId);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final empruntsNotifierProvider =
    StateNotifierProvider<EmpruntsNotifier, AsyncValue<void>>((ref) {
  return EmpruntsNotifier(ref.watch(empruntsRepositoryProvider));
});
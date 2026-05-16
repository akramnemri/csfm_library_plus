import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/emprunt_model.dart';
import 'notification_service.dart';

final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService.instance;
});

// Checks all active emprunts and triggers reminders
// Called once when admin dashboard or home screen loads
class NotificationChecker {
  final NotificationService _service;
  final Set<String> _sentNotifications = {};
  Timer? _debounceTimer;

  NotificationChecker(this._service);

  Future<void> checkEmpruntsRetards(List<EmpruntModel> emprunts) async {
    // Cancel any pending debounce timer
    _debounceTimer?.cancel();

    _debounceTimer = Timer(const Duration(seconds: 30), () {
      _sentNotifications.clear();
    });

    for (final emprunt in emprunts) {
      if (emprunt.statut == 'actif' && emprunt.estEnRetard) {
        final key = '${emprunt.documentId}_${emprunt.dateEmprunt.millisecondsSinceEpoch}';
        if (_sentNotifications.contains(key)) continue;

        final jours = emprunt.joursRestants;

        // Remind at 3 days, 1 day, 0 days, and overdue
        if (jours <= 3) {
          await _service.notifyRetourRappel(
              emprunt.documentTitre, jours);
          _sentNotifications.add(key);
        }
      }
    }
  }
}

final notificationCheckerProvider = Provider<NotificationChecker>((ref) {
  return NotificationChecker(ref.watch(notificationServiceProvider));
});
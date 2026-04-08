import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'notification_service.dart';

final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService.instance;
});

// Checks all active emprunts and triggers reminders
// Called once when admin dashboard or home screen loads
class NotificationChecker {
  final NotificationService _service;

  NotificationChecker(this._service);

  Future<void> checkEmpruntsRetards(List<dynamic> emprunts) async {
    for (final emprunt in emprunts) {
      if (emprunt.statut == 'actif') {
        final jours = emprunt.joursRestants;

        // Remind at 3 days, 1 day, 0 days, and overdue
        if (jours <= 3) {
          await _service.notifyRetourRappel(
              emprunt.documentTitre, jours);
        }
      }
    }
  }
}

final notificationCheckerProvider = Provider<NotificationChecker>((ref) {
  return NotificationChecker(ref.watch(notificationServiceProvider));
});
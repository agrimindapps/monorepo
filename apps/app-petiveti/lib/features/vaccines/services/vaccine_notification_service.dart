import '../../../core/utils/observer_pattern.dart';
import '../domain/entities/vaccine.dart';

/// Service responsible for vaccine-related notifications following SOLID principles
/// 
/// Uses Observer pattern to notify about vaccine events like due dates, reminders, etc.
/// Follows SRP and DIP principles.
class VaccineNotificationService {
  static final VaccineNotificationService _instance = VaccineNotificationService._internal();
  factory VaccineNotificationService() => _instance;
  VaccineNotificationService._internal();

  final NotificationService _notificationService = NotificationService();

  /// Check and send notifications for vaccines that are due
  void checkVaccineDueDates(List<Vaccine> vaccines) {
    for (final vaccine in vaccines) {
      _checkIndividualVaccine(vaccine);
    }
  }

  /// Check individual vaccine and send appropriate notifications
  void _checkIndividualVaccine(Vaccine vaccine) {
    if (vaccine.isOverdue && vaccine.isRequired) {
      _sendOverdueNotification(vaccine);
    } else if (vaccine.isDueToday) {
      _sendDueTodayNotification(vaccine);
    } else if (vaccine.isDueSoon) {
      _sendDueSoonNotification(vaccine);
    }

    if (vaccine.needsReminder) {
      _sendReminderNotification(vaccine);
    }
  }

  /// Send notification for overdue vaccines
  void _sendOverdueNotification(Vaccine vaccine) {
    final daysOverdue = DateTime.now().difference(vaccine.nextDueDate!).inDays;
    
    _notificationService.notify(
      NotificationEvent.alert(
        title: 'Vacina em Atraso!',
        message: '${vaccine.name} está atrasada há $daysOverdue ${daysOverdue == 1 ? 'dia' : 'dias'}. '
                 'Agende uma consulta veterinária.',
        data: {
          'vaccineId': vaccine.id,
          'animalId': vaccine.animalId,
          'vaccineName': vaccine.name,
          'daysOverdue': daysOverdue,
          'type': 'overdue',
        },
      ),
    );
  }

  /// Send notification for vaccines due today
  void _sendDueTodayNotification(Vaccine vaccine) {
    _notificationService.notify(
      NotificationEvent.warning(
        title: 'Vacina Vence Hoje!',
        message: '${vaccine.name} vence hoje. Não se esqueça de aplicar.',
        data: {
          'vaccineId': vaccine.id,
          'animalId': vaccine.animalId,
          'vaccineName': vaccine.name,
          'type': 'due_today',
        },
      ),
    );
  }

  /// Send notification for vaccines due soon
  void _sendDueSoonNotification(Vaccine vaccine) {
    final daysUntilDue = vaccine.daysUntilNextDose;
    
    _notificationService.notify(
      NotificationEvent.info(
        title: 'Vacina Próxima do Vencimento',
        message: '${vaccine.name} vence em $daysUntilDue ${daysUntilDue == 1 ? 'dia' : 'dias'}. '
                 'Prepare-se para a aplicação.',
        data: {
          'vaccineId': vaccine.id,
          'animalId': vaccine.animalId,
          'vaccineName': vaccine.name,
          'daysUntilDue': daysUntilDue,
          'type': 'due_soon',
        },
      ),
    );
  }

  /// Send reminder notification
  void _sendReminderNotification(Vaccine vaccine) {
    _notificationService.notify(
      NotificationEvent.reminder(
        title: 'Lembrete de Vacina',
        message: 'Lembrete configurado para ${vaccine.name}. Verifique o status da vacina.',
        data: {
          'vaccineId': vaccine.id,
          'animalId': vaccine.animalId,
          'vaccineName': vaccine.name,
          'type': 'reminder',
        },
      ),
    );
  }

  /// Send notification when vaccine is successfully scheduled
  void notifyVaccineScheduled(Vaccine vaccine) {
    _notificationService.notify(
      NotificationEvent.success(
        title: 'Vacina Agendada!',
        message: '${vaccine.name} foi agendada para ${_formatDate(vaccine.date)}.',
        data: {
          'vaccineId': vaccine.id,
          'animalId': vaccine.animalId,
          'vaccineName': vaccine.name,
          'scheduledDate': vaccine.date.toIso8601String(),
          'type': 'scheduled',
        },
      ),
    );
  }

  /// Send notification when vaccine is applied
  void notifyVaccineApplied(Vaccine vaccine) {
    _notificationService.notify(
      NotificationEvent.success(
        title: 'Vacina Aplicada!',
        message: '${vaccine.name} foi aplicada com sucesso.',
        data: {
          'vaccineId': vaccine.id,
          'animalId': vaccine.animalId,
          'vaccineName': vaccine.name,
          'appliedDate': vaccine.date.toIso8601String(),
          'type': 'applied',
        },
      ),
    );
  }

  /// Send notification when vaccine series is completed
  void notifyVaccineSeriesCompleted(String vaccineName, String animalId) {
    _notificationService.notify(
      NotificationEvent.success(
        title: 'Série de Vacinas Completa!',
        message: 'Parabéns! A série de $vaccineName foi completada com sucesso.',
        data: {
          'animalId': animalId,
          'vaccineName': vaccineName,
          'type': 'series_completed',
        },
      ),
    );
  }

  /// Send notification for vaccine side effects monitoring
  void notifyVaccineSideEffectsMonitoring(Vaccine vaccine) {
    _notificationService.notify(
      NotificationEvent.info(
        title: 'Monitoramento de Reações',
        message: 'Monitore ${vaccine.name} nas próximas 24-48h para possíveis reações adversas.',
        data: {
          'vaccineId': vaccine.id,
          'animalId': vaccine.animalId,
          'vaccineName': vaccine.name,
          'type': 'side_effects_monitoring',
        },
      ),
    );
  }

  /// Send batch expiration warning
  void notifyBatchExpiration(List<Vaccine> vaccinesWithExpiringBatch) {
    if (vaccinesWithExpiringBatch.isEmpty) return;

    final batchNumber = vaccinesWithExpiringBatch.first.batch;
    final count = vaccinesWithExpiringBatch.length;
    
    _notificationService.notify(
      NotificationEvent.warning(
        title: 'Lote de Vacina Expirando',
        message: 'O lote $batchNumber tem $count ${count == 1 ? 'vacina' : 'vacinas'} '
                 'programadas e pode estar próximo do vencimento.',
        data: {
          'batchNumber': batchNumber,
          'affectedVaccines': vaccinesWithExpiringBatch.map((v) => v.id).toList(),
          'count': count,
          'type': 'batch_expiration',
        },
      ),
    );
  }

  /// Send veterinary consultation reminder
  void notifyVeterinaryConsultationNeeded(String animalId, String reason) {
    _notificationService.notify(
      NotificationEvent.reminder(
        title: 'Consulta Veterinária Recomendada',
        message: 'É recomendado consultar um veterinário: $reason',
        data: {
          'animalId': animalId,
          'reason': reason,
          'type': 'vet_consultation',
        },
      ),
    );
  }

  /// Format date for display
  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  /// Get notification service instance for external use
  NotificationService get notificationService => _notificationService;
}
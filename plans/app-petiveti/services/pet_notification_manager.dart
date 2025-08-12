// Flutter imports:
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

// Project imports:
import '../../core/services/notification_service.dart';
import '../models/14_lembrete_model.dart';
import '../models/16_vacina_model.dart';

/// Gerenciador de notificações para o módulo PetiVeti
/// Utiliza o serviço genérico de notificações e adiciona lógica específica para lembretes e vacinas
class PetNotificationManager {
  // Singleton pattern
  static final PetNotificationManager _instance =
      PetNotificationManager._internal();
  factory PetNotificationManager() => _instance;
  PetNotificationManager._internal();

  // Serviço de notificações genérico
  final NotificationService _notificationService = NotificationService();

  // Channels para categorias específicas
  static const String _channelIdLembretes = 'lembretes_pet_channel';
  static const String _channelNameLembretes = 'Lembretes Pet';
  static const String _channelDescLembretes =
      'Notificações de lembretes para pets';

  static const String _channelIdLembretesExatos = 'lembretes_pet_channel_exato';
  static const String _channelNameLembretesExatos = 'Lembretes Pet Exatos';
  static const String _channelDescLembretesExatos =
      'Notificações para o horário exato de lembretes';

  static const String _channelIdVacinas = 'vacinas_pet_channel';
  static const String _channelNameVacinas = 'Vacinas Pet';
  static const String _channelDescVacinas = 'Notificações de vacinas para pets';

  // Offsets para IDs de notificações
  static const int _offsetLembreteExato = 100000;
  static const int _offsetVacina3Dias = 200000;
  static const int _offsetVacina1Dia = 300000;
  static const int _offsetVacinaDia = 400000;

  /// Inicializar o gerenciador
  Future<void> initialize(
      {Function(String? payload)? onNotificationTap}) async {
    await _notificationService.initialize(onNotificationSelected: (payload) {
      if (onNotificationTap != null) {
        onNotificationTap(payload);
      }
      _handleNotificationTap(payload);
    });
  }

  /// Gerencia o toque em uma notificação
  void _handleNotificationTap(String? payload) {
    if (payload == null) return;

    debugPrint('Notificação clicada com payload: $payload');

    // Aqui você pode adicionar lógica para direcionar para a tela correta
    // com base no payload recebido
    //
    // Exemplo:
    // if (payload.startsWith('lembrete_')) {
    //   final lembreteId = payload.substring(9);
    //   Get.to(() => DetalhesLembreteScreen(lembreteId: lembreteId));
    // } else if (payload.startsWith('vacina_')) {
    //   final vacinaId = payload.substring(7);
    //   Get.to(() => DetalhesVacinaScreen(vacinaId: vacinaId));
    // }
  }

  /// Agenda notificações para um lembrete
  Future<void> agendarNotificacoesLembrete(LembreteVet lembrete) async {
    // Cancela notificações existentes para este lembrete
    await cancelarNotificacoesLembrete(lembrete.id);

    // Se o lembrete já está concluído ou foi deletado, não agenda notificação
    if (lembrete.concluido || lembrete.isDeleted) {
      return;
    }

    // Converte o timestamp para DateTime
    final DateTime dataHoraLembrete =
        DateTime.fromMillisecondsSinceEpoch(lembrete.dataHora);

    // Calcula a data para notificação (30 minutos antes)
    final DateTime dataNotificacaoPrevia =
        dataHoraLembrete.subtract(const Duration(minutes: 30));

    // Gera IDs usando o serviço genérico
    final int notificationIdPrevia =
        NotificationService.createNotificationId(lembrete.id);
    final int notificationIdExato = NotificationService.createNotificationId(
        lembrete.id,
        offset: _offsetLembreteExato);

    // Agenda notificação prévia (30 minutos antes)
    if (dataNotificacaoPrevia.isAfter(DateTime.now())) {
      await _notificationService.scheduleNotification(
        id: notificationIdPrevia,
        title: 'Lembrete: ${lembrete.titulo}',
        body: lembrete.descricao,
        scheduledDate: dataNotificacaoPrevia,
        channelId: _channelIdLembretes,
        channelName: _channelNameLembretes,
        channelDescription: _channelDescLembretes,
        payload: 'lembrete_${lembrete.id}',
      );
    }

    // Agenda notificação para o horário exato
    if (dataHoraLembrete.isAfter(DateTime.now())) {
      await _notificationService.scheduleNotification(
        id: notificationIdExato,
        title: 'Agora: ${lembrete.titulo}',
        body: lembrete.descricao,
        scheduledDate: dataHoraLembrete,
        channelId: _channelIdLembretesExatos,
        channelName: _channelNameLembretesExatos,
        channelDescription: _channelDescLembretesExatos,
        payload: 'lembrete_${lembrete.id}',
      );
    }
  }

  /// Agenda notificações para uma vacina
  Future<void> agendarNotificacoesVacina(VacinaVet vacina) async {
    // Cancela notificações existentes para esta vacina
    await cancelarNotificacoesVacina(vacina.id);

    // Se a vacina foi deletada, não agenda notificações
    if (vacina.isDeleted) {
      return;
    }

    // Converte o timestamp para DateTime
    final DateTime dataProximaDose =
        DateTime.fromMillisecondsSinceEpoch(vacina.proximaDose);

    // Calcula as datas para notificações
    final DateTime dataNotificacao3Dias =
        dataProximaDose.subtract(const Duration(days: 3));
    final DateTime dataNotificacao1Dia =
        dataProximaDose.subtract(const Duration(days: 1));

    // Gera IDs para as notificações
    final int notificationId3Dias = NotificationService.createNotificationId(
        vacina.id,
        offset: _offsetVacina3Dias);
    final int notificationId1Dia = NotificationService.createNotificationId(
        vacina.id,
        offset: _offsetVacina1Dia);
    final int notificationIdDia = NotificationService.createNotificationId(
        vacina.id,
        offset: _offsetVacinaDia);

    // Agenda notificação para 3 dias antes
    if (dataNotificacao3Dias.isAfter(DateTime.now())) {
      await _notificationService.scheduleNotification(
        id: notificationId3Dias,
        title: 'Vacina em 3 dias: ${vacina.nomeVacina}',
        body:
            'A próxima dose da vacina ${vacina.nomeVacina} está agendada para daqui a 3 dias',
        scheduledDate: dataNotificacao3Dias,
        channelId: _channelIdVacinas,
        channelName: _channelNameVacinas,
        channelDescription: _channelDescVacinas,
        payload: 'vacina_${vacina.id}',
      );
    }

    // Agenda notificação para 1 dia antes
    if (dataNotificacao1Dia.isAfter(DateTime.now())) {
      final String observacao = vacina.observacoes?.isNotEmpty == true
          ? '. ${vacina.observacoes}'
          : '';

      await _notificationService.scheduleNotification(
        id: notificationId1Dia,
        title: 'Vacina amanhã: ${vacina.nomeVacina}',
        body:
            'Lembre-se: amanhã é dia da vacina ${vacina.nomeVacina}$observacao',
        scheduledDate: dataNotificacao1Dia,
        channelId: _channelIdVacinas,
        channelName: _channelNameVacinas,
        channelDescription: _channelDescVacinas,
        payload: 'vacina_${vacina.id}',
      );
    }

    // Agenda notificação para o dia exato
    if (dataProximaDose.isAfter(DateTime.now())) {
      final String observacao = vacina.observacoes?.isNotEmpty == true
          ? '. ${vacina.observacoes}'
          : '';

      await _notificationService.scheduleNotification(
        id: notificationIdDia,
        title: 'Vacina hoje: ${vacina.nomeVacina}',
        body: 'Hoje é o dia da vacina ${vacina.nomeVacina}$observacao',
        scheduledDate: dataProximaDose,
        channelId: _channelIdVacinas,
        channelName: _channelNameVacinas,
        channelDescription: _channelDescVacinas,
        payload: 'vacina_${vacina.id}',
      );
    }
  }

  /// Cancela todas as notificações de um lembrete
  Future<void> cancelarNotificacoesLembrete(String lembreteId) async {
    final int notificationIdPrevia =
        NotificationService.createNotificationId(lembreteId);
    final int notificationIdExato = NotificationService.createNotificationId(
        lembreteId,
        offset: _offsetLembreteExato);

    await _notificationService.cancelMultipleNotifications(
        [notificationIdPrevia, notificationIdExato]);
  }

  /// Cancela todas as notificações de uma vacina
  Future<void> cancelarNotificacoesVacina(String vacinaId) async {
    final int notificationId3Dias = NotificationService.createNotificationId(
        vacinaId,
        offset: _offsetVacina3Dias);
    final int notificationId1Dia = NotificationService.createNotificationId(
        vacinaId,
        offset: _offsetVacina1Dia);
    final int notificationIdDia = NotificationService.createNotificationId(
        vacinaId,
        offset: _offsetVacinaDia);

    await _notificationService.cancelMultipleNotifications(
        [notificationId3Dias, notificationId1Dia, notificationIdDia]);
  }

  /// Cancela todas as notificações do módulo
  Future<void> cancelarTodasNotificacoes() async {
    await _notificationService.cancelAllNotifications();
  }
}

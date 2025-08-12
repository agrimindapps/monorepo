// Flutter imports:
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

// Project imports:
import '../../core/services/notification_service.dart';
import '../database/21_veiculos_model.dart';
import '../database/25_manutencao_model.dart';
import '../repository/veiculos_repository.dart';

/// Gerenciador de notificações para o módulo GasOMeter
/// Utiliza o serviço genérico de notificações e adiciona lógica específica para manutenção de veículos
class MaintenanceNotificationManager {
  // Singleton pattern
  static final MaintenanceNotificationManager _instance =
      MaintenanceNotificationManager._internal();
  factory MaintenanceNotificationManager() => _instance;
  MaintenanceNotificationManager._internal();

  // Serviço de notificações genérico
  final NotificationService _notificationService = NotificationService();

  // Channels para categorias específicas
  static const String _channelIdMaintenance = 'maintenance_channel';
  static const String _channelNameMaintenance = 'Manutenções';
  static const String _channelDescMaintenance =
      'Notificações de manutenções agendadas para veículos';

  static const String _channelIdUpcoming = 'upcoming_maintenance_channel';
  static const String _channelNameUpcoming = 'Próximas Manutenções';
  static const String _channelDescUpcoming =
      'Notificações para próximas manutenções agendadas';

  // Offsets para IDs de notificações
  static const int _offsetDiaAntes = 100000;
  static const int _offsetTresDias = 200000;
  static const int _offsetSemanaAntes = 300000;

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

    debugPrint('Notificação de manutenção clicada com payload: $payload');

    // Lógica para direcionar para a tela correta
    // Exemplo de implementação futura:
    // if (payload.startsWith('manutencao_')) {
    //   final manutencaoId = payload.substring(11);
    //   Get.to(() => DetalhesManutencaoPage(manutencaoId: manutencaoId));
    // }
  }

  /// Agenda notificações para uma manutenção
  Future<void> agendarNotificacoesManutencao(ManutencaoCar manutencao) async {
    // Cancela notificações existentes para esta manutenção
    await cancelarNotificacoesManutencao(manutencao.id);

    // Se a manutenção já está concluída ou possui data de próxima revisão nula, não agenda notificação
    if (manutencao.concluida || manutencao.proximaRevisao == null) {
      return;
    }

    // Busca informações do veículo para inclusão nas notificações
    VeiculoCar? veiculo =
        await VeiculosRepository().getVeiculoById(manutencao.veiculoId);
    String veiculoInfo =
        veiculo != null ? '${veiculo.marca} ${veiculo.modelo}' : 'Veículo';

    // Converte o timestamp para DateTime
    final DateTime dataProximaRevisao =
        DateTime.fromMillisecondsSinceEpoch(manutencao.proximaRevisao!);

    // Calcula as datas para notificações
    final DateTime dataNotificacaoSemanaAntes =
        dataProximaRevisao.subtract(const Duration(days: 7));
    final DateTime dataNotificacaoTresDias =
        dataProximaRevisao.subtract(const Duration(days: 3));
    final DateTime dataNotificacaoDiaAntes =
        dataProximaRevisao.subtract(const Duration(days: 1));

    // Gera IDs usando o serviço genérico
    final int notificationIdSemanaAntes =
        NotificationService.createNotificationId(manutencao.id,
            offset: _offsetSemanaAntes);
    final int notificationIdTresDias = NotificationService.createNotificationId(
        manutencao.id,
        offset: _offsetTresDias);
    final int notificationIdDiaAntes = NotificationService.createNotificationId(
        manutencao.id,
        offset: _offsetDiaAntes);
    final int notificationIdDia =
        NotificationService.createNotificationId(manutencao.id);

    // Agenda notificação para uma semana antes
    if (dataNotificacaoSemanaAntes.isAfter(DateTime.now())) {
      await _notificationService.scheduleNotification(
        id: notificationIdSemanaAntes,
        title: 'Manutenção em 7 dias - $veiculoInfo',
        body:
            'Lembrete: Manutenção "${manutencao.descricao}" agendada para a próxima semana',
        scheduledDate: dataNotificacaoSemanaAntes,
        channelId: _channelIdUpcoming,
        channelName: _channelNameUpcoming,
        channelDescription: _channelDescUpcoming,
        payload: 'manutencao_${manutencao.id}',
      );
    }

    // Agenda notificação para três dias antes
    if (dataNotificacaoTresDias.isAfter(DateTime.now())) {
      await _notificationService.scheduleNotification(
        id: notificationIdTresDias,
        title: 'Manutenção em 3 dias - $veiculoInfo',
        body:
            'A ${manutencao.tipo} "${manutencao.descricao}" está agendada para daqui a 3 dias',
        scheduledDate: dataNotificacaoTresDias,
        channelId: _channelIdUpcoming,
        channelName: _channelNameUpcoming,
        channelDescription: _channelDescUpcoming,
        payload: 'manutencao_${manutencao.id}',
      );
    }

    // Agenda notificação para um dia antes
    if (dataNotificacaoDiaAntes.isAfter(DateTime.now())) {
      await _notificationService.scheduleNotification(
        id: notificationIdDiaAntes,
        title: 'Manutenção amanhã - $veiculoInfo',
        body: 'Lembre-se: amanhã é dia da manutenção "${manutencao.descricao}"',
        scheduledDate: dataNotificacaoDiaAntes,
        channelId: _channelIdUpcoming,
        channelName: _channelNameUpcoming,
        channelDescription: _channelDescUpcoming,
        payload: 'manutencao_${manutencao.id}',
      );
    }

    // Agenda notificação para o dia exato
    if (dataProximaRevisao.isAfter(DateTime.now())) {
      await _notificationService.scheduleNotification(
        id: notificationIdDia,
        title: 'Manutenção hoje - $veiculoInfo',
        body: 'Hoje é o dia da manutenção "${manutencao.descricao}"',
        scheduledDate: dataProximaRevisao,
        channelId: _channelIdMaintenance,
        channelName: _channelNameMaintenance,
        channelDescription: _channelDescMaintenance,
        payload: 'manutencao_${manutencao.id}',
      );
    }
  }

  /// Cancela todas as notificações de uma manutenção
  Future<void> cancelarNotificacoesManutencao(String manutencaoId) async {
    final int notificationIdSemanaAntes =
        NotificationService.createNotificationId(manutencaoId,
            offset: _offsetSemanaAntes);
    final int notificationIdTresDias = NotificationService.createNotificationId(
        manutencaoId,
        offset: _offsetTresDias);
    final int notificationIdDiaAntes = NotificationService.createNotificationId(
        manutencaoId,
        offset: _offsetDiaAntes);
    final int notificationIdDia =
        NotificationService.createNotificationId(manutencaoId);

    await _notificationService.cancelMultipleNotifications([
      notificationIdSemanaAntes,
      notificationIdTresDias,
      notificationIdDiaAntes,
      notificationIdDia,
    ]);
  }

  /// Cancela todas as notificações do módulo
  Future<void> cancelarTodasNotificacoes() async {
    await _notificationService.cancelAllNotifications();
  }
}

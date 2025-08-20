// Flutter imports:
import 'package:flutter/foundation.dart';

// Project imports:
import '../model/resultados_pluviometro_model.dart';
import 'state_manager.dart';

/// Tipos de notificação de UI
enum UINotificationType {
  info,
  warning,
  error,
  success,
}

/// Dados de notificação para UI
class UINotification {
  final String message;
  final UINotificationType type;
  final DateTime timestamp;
  final String? actionLabel;
  final VoidCallback? action;

  UINotification({
    required this.message,
    required this.type,
    this.actionLabel,
    this.action,
  }) : timestamp = DateTime.now();

  @override
  String toString() => 'UINotification(${type.name}: $message)';
}

/// Gerenciador de notificações de mudanças de UI
class UINotifier extends ChangeNotifier {
  final StateManager _stateManager;
  final List<UINotification> _notifications = [];
  final int _maxNotifications = 50;

  UINotifier({required StateManager stateManager})
      : _stateManager = stateManager {
    _stateManager.addListener(_onStateChanged);
  }

  List<UINotification> get notifications => List.unmodifiable(_notifications);
  List<UINotification> get recentNotifications =>
      _notifications.take(10).toList();

  /// Chamado quando o estado muda
  void _onStateChanged() {
    final state = _stateManager.state;

    // Notificar sobre mudanças de estado de inicialização
    _handleInitializationStateChange(state);

    // Notificar sobre mudanças de loading
    _handleLoadingStateChange(state);

    // Notificar sobre erros
    _handleErrorStateChange(state);

    // Notificar sobre seleção de pluviômetro
    _handlePluviometroSelection(state);

    notifyListeners();
  }

  /// Manipula mudanças no estado de inicialização
  void _handleInitializationStateChange(ResultadosPluviometroState state) {
    switch (state.initState) {
      case InitializationState.initializing:
        _addNotification(UINotification(
          message: 'Carregando dados iniciais...',
          type: UINotificationType.info,
        ));
        break;
      case InitializationState.initialized:
        _addNotification(UINotification(
          message: 'Dados carregados com sucesso',
          type: UINotificationType.success,
        ));
        break;
      case InitializationState.failed:
        _addNotification(UINotification(
          message: 'Falha ao carregar dados iniciais',
          type: UINotificationType.error,
          actionLabel: 'Tentar novamente',
          action: () => _requestDataReload(),
        ));
        break;
      default:
        break;
    }
  }

  /// Manipula mudanças no estado de loading
  void _handleLoadingStateChange(ResultadosPluviometroState state) {
    if (state.isLoading && state.initState == InitializationState.initialized) {
      _addNotification(UINotification(
        message: 'Atualizando dados...',
        type: UINotificationType.info,
      ));
    }
  }

  /// Manipula mudanças no estado de erro
  void _handleErrorStateChange(ResultadosPluviometroState state) {
    if (state.errorMessage != null && state.errorMessage!.isNotEmpty) {
      _addNotification(UINotification(
        message: state.errorMessage!,
        type: UINotificationType.error,
        actionLabel: 'Limpar erro',
        action: () => _stateManager.clearError(),
      ));
    }
  }

  /// Manipula seleção de pluviômetro
  void _handlePluviometroSelection(ResultadosPluviometroState state) {
    if (state.pluviometroSelecionado != null) {
      _addNotification(UINotification(
        message:
            'Pluviômetro selecionado: ${state.pluviometroSelecionado!.descricao}',
        type: UINotificationType.info,
      ));
    }
  }

  /// Adiciona notificação manualmente
  void addNotification(UINotification notification) {
    _addNotification(notification);
    notifyListeners();
  }

  /// Notifica sucesso
  void notifySuccess(String message,
      {String? actionLabel, VoidCallback? action}) {
    addNotification(UINotification(
      message: message,
      type: UINotificationType.success,
      actionLabel: actionLabel,
      action: action,
    ));
  }

  /// Notifica erro
  void notifyError(String message,
      {String? actionLabel, VoidCallback? action}) {
    addNotification(UINotification(
      message: message,
      type: UINotificationType.error,
      actionLabel: actionLabel,
      action: action,
    ));
  }

  /// Notifica aviso
  void notifyWarning(String message,
      {String? actionLabel, VoidCallback? action}) {
    addNotification(UINotification(
      message: message,
      type: UINotificationType.warning,
      actionLabel: actionLabel,
      action: action,
    ));
  }

  /// Notifica informação
  void notifyInfo(String message, {String? actionLabel, VoidCallback? action}) {
    addNotification(UINotification(
      message: message,
      type: UINotificationType.info,
      actionLabel: actionLabel,
      action: action,
    ));
  }

  /// Remove notificação
  void removeNotification(UINotification notification) {
    _notifications.remove(notification);
    notifyListeners();
  }

  /// Limpa todas as notificações
  void clearAllNotifications() {
    _notifications.clear();
    notifyListeners();
  }

  /// Limpa notificações por tipo
  void clearNotificationsByType(UINotificationType type) {
    _notifications.removeWhere((notification) => notification.type == type);
    notifyListeners();
  }

  /// Limpa notificações antigas (mais de 1 hora)
  void clearOldNotifications() {
    final oneHourAgo = DateTime.now().subtract(const Duration(hours: 1));
    _notifications.removeWhere(
        (notification) => notification.timestamp.isBefore(oneHourAgo));
    notifyListeners();
  }

  /// Adiciona notificação interna
  void _addNotification(UINotification notification) {
    _notifications.insert(0, notification);

    // Manter apenas as notificações mais recentes
    if (_notifications.length > _maxNotifications) {
      _notifications.removeRange(_maxNotifications, _notifications.length);
    }
  }

  /// Solicita recarga de dados (callback placeholder)
  void _requestDataReload() {
    // Este método será implementado no controller principal
    debugPrint('Solicitação de recarga de dados');
  }

  /// Obtém contadores por tipo de notificação
  Map<UINotificationType, int> getNotificationCounts() {
    final counts = <UINotificationType, int>{};

    for (final type in UINotificationType.values) {
      counts[type] = _notifications.where((n) => n.type == type).length;
    }

    return counts;
  }

  @override
  void dispose() {
    _stateManager.removeListener(_onStateChanged);
    super.dispose();
  }
}

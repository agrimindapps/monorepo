import 'dart:convert';

import 'package:core/core.dart' hide Column;
import 'package:flutter/foundation.dart';

import '../data/models/promotional_notification.dart';
import 'firebase_messaging_service.dart';

/// Gerenciador de notificações promocionais do ReceitaAgro
/// Controla when/how mostrar notificações promocionais baseado no comportamento do usuário
class PromotionalNotificationManager {
  static final PromotionalNotificationManager _instance =
      PromotionalNotificationManager._internal();
  factory PromotionalNotificationManager() => _instance;
  PromotionalNotificationManager._internal();

  static const String _keyLastPromotionalShown = 'last_promotional_shown';
  static const String _keyPromotionalCount = 'promotional_count';
  static const String _keyUserPreferences = 'promotional_preferences';
  static const String _keyDismissedNotifications = 'dismissed_notifications';

  final ReceitaAgroFirebaseMessagingService _messagingService =
      ReceitaAgroFirebaseMessagingService();

  /// Configurações de frequência de notificações
  static const Duration _minIntervalBetweenPromotions = Duration(hours: 24);
  static const int _maxPromotionsPerWeek = 3;

  /// Inicializa o manager
  Future<void> initialize() async {
    await _setupBehavioralTriggers();
  }

  /// Configura triggers baseados no comportamento do usuário
  Future<void> _setupBehavioralTriggers() async {
  }

  /// Verifica se pode mostrar notificação promocional
  Future<bool> canShowPromotionalNotification() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastShown = prefs.getInt(_keyLastPromotionalShown) ?? 0;
      final lastShownTime = DateTime.fromMillisecondsSinceEpoch(lastShown);
      final timeSinceLastShown = DateTime.now().difference(lastShownTime);

      if (timeSinceLastShown < _minIntervalBetweenPromotions) {
        return false;
      }
      final weeklyCount = await _getWeeklyPromotionalCount();
      if (weeklyCount >= _maxPromotionsPerWeek) {
        return false;
      }
      final userPreferences = await getUserNotificationPreferences();
      if (!userPreferences.promotionalEnabled) {
        return false;
      }

      return true;
    } catch (e) {
      debugPrint('Error checking if can show promotional: $e');
      return false;
    }
  }

  /// Agenda notificação promocional baseada no contexto
  Future<bool> scheduleContextualPromotion({
    required String context,
    Map<String, dynamic>? contextData,
  }) async {
    if (!await canShowPromotionalNotification()) {
      return false;
    }

    PromotionalNotification? notification;

    switch (context) {
      case 'defensivos_search':
        notification = _createDefensivosPromotion(contextData);
        break;
      case 'pragas_identification':
        notification = _createPragasPromotion(contextData);
        break;
      case 'premium_feature_attempt':
        notification = _createPremiumPromotion(contextData);
        break;
      case 'seasonal_alert':
        notification = _createSeasonalPromotion(contextData);
        break;
      case 'user_milestone':
        notification = _createMilestonePromotion(contextData);
        break;
    }

    if (notification != null) {
      return await _scheduleNotification(notification);
    }

    return false;
  }

  /// Cria promoção relacionada a defensivos
  PromotionalNotification _createDefensivosPromotion(
    Map<String, dynamic>? data,
  ) {
    final searchTerm = data?['search_term'] as String?;

    return PromotionalNotification(
      id: DateTime.now().millisecondsSinceEpoch,
      title: '🌱 Encontre o Defensivo Ideal',
      body:
          searchTerm != null
              ? 'Veja mais opções para "$searchTerm" no ReceitaAgro Premium!'
              : 'Acesso completo a todos os defensivos com ReceitaAgro Premium',
      type: NotificationType.promotional,
      channelId: 'receituagro_promotional',
      channelName: 'Ofertas e Promoções',
      channelDescription: 'Ofertas baseadas em sua pesquisa',
      targetScreen: 'subscription',
      data: {
        'promotion_type': 'defensivos_search',
        'search_term': searchTerm,
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }

  /// Cria promoção relacionada a pragas
  PromotionalNotification _createPragasPromotion(Map<String, dynamic>? data) {
    final pragaName = data?['praga_name'] as String?;

    return PromotionalNotification(
      id: DateTime.now().millisecondsSinceEpoch,
      title: '🐛 Combata Pragas Eficazmente',
      body:
          pragaName != null
              ? 'Descubra tratamentos completos para $pragaName'
              : 'Acesso a diagnósticos avançados e tratamentos específicos',
      type: NotificationType.promotional,
      channelId: 'receituagro_promotional',
      channelName: 'Ofertas e Promoções',
      channelDescription: 'Soluções para controle de pragas',
      targetScreen: 'subscription',
      data: {
        'promotion_type': 'pragas_identification',
        'praga_name': pragaName,
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }

  /// Cria promoção para recursos premium
  PromotionalNotification _createPremiumPromotion(Map<String, dynamic>? data) {
    final feature = data?['blocked_feature'] as String?;

    return PromotionalNotification(
      id: DateTime.now().millisecondsSinceEpoch,
      title: '✨ Desbloqueie Recursos Premium',
      body:
          feature != null
              ? 'Acesse $feature e muito mais por apenas R\$ 9,90/mês'
              : 'Tenha acesso completo a todos os recursos do ReceitaAgro',
      type: NotificationType.premium,
      channelId: 'receituagro_promotional',
      channelName: 'Ofertas e Promoções',
      channelDescription: 'Ofertas ReceitaAgro Premium',
      targetScreen: 'subscription',
      data: {
        'promotion_type': 'premium_unlock',
        'blocked_feature': feature,
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }

  /// Cria promoção sazonal
  PromotionalNotification _createSeasonalPromotion(Map<String, dynamic>? data) {
    final season = data?['season'] as String? ?? 'atual';

    return PromotionalNotification(
      id: DateTime.now().millisecondsSinceEpoch,
      title: '📅 Alerta Sazonal ReceitaAgro',
      body: 'Prepare-se para a temporada $season com as melhores práticas',
      type: NotificationType.promotional,
      channelId: 'receituagro_promotional',
      channelName: 'Ofertas e Promoções',
      channelDescription: 'Alertas e dicas sazonais',
      targetScreen: 'defensivos',
      data: {
        'promotion_type': 'seasonal',
        'season': season,
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }

  /// Cria promoção baseada em marcos do usuário
  PromotionalNotification _createMilestonePromotion(
    Map<String, dynamic>? data,
  ) {
    final milestone = data?['milestone'] as String? ?? 'progresso';

    return PromotionalNotification(
      id: DateTime.now().millisecondsSinceEpoch,
      title: '🎉 Parabéns pelo seu $milestone!',
      body: 'Continue evoluindo com recursos exclusivos do ReceitaAgro Premium',
      type: NotificationType.promotional,
      channelId: 'receituagro_promotional',
      channelName: 'Ofertas e Promoções',
      channelDescription: 'Comemorações e ofertas especiais',
      targetScreen: 'subscription',
      data: {
        'promotion_type': 'milestone',
        'milestone': milestone,
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }

  /// Agenda a notificação para ser enviada
  Future<bool> _scheduleNotification(
    PromotionalNotification notification,
  ) async {
    try {
      if (kDebugMode) {
        await _messagingService.sendTestPromotionalNotification();
      }
      await _recordPromotionalShown(notification);

      return true;
    } catch (e) {
      debugPrint('Error scheduling notification: $e');
      return false;
    }
  }

  /// Registra que uma promoção foi mostrada
  Future<void> _recordPromotionalShown(
    PromotionalNotification notification,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(
        _keyLastPromotionalShown,
        DateTime.now().millisecondsSinceEpoch,
      );
      final weeklyCount = await _getWeeklyPromotionalCount();
      await prefs.setInt(_keyPromotionalCount, weeklyCount + 1);
      await _saveNotificationHistory(notification);
    } catch (e) {
      debugPrint('Error recording promotional shown: $e');
    }
  }

  /// Obtém contagem de promoções da semana atual
  Future<int> _getWeeklyPromotionalCount() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final count = prefs.getInt(_keyPromotionalCount) ?? 0;
      final lastReset = prefs.getInt('${_keyPromotionalCount}_reset') ?? 0;
      final lastResetTime = DateTime.fromMillisecondsSinceEpoch(lastReset);
      final weeksSinceReset =
          DateTime.now().difference(lastResetTime).inDays ~/ 7;

      if (weeksSinceReset > 0) {
        await prefs.setInt(_keyPromotionalCount, 0);
        await prefs.setInt(
          '${_keyPromotionalCount}_reset',
          DateTime.now().millisecondsSinceEpoch,
        );
        return 0;
      }

      return count;
    } catch (e) {
      debugPrint('Error getting weekly count: $e');
      return 0;
    }
  }

  /// Obtém preferências de notificação do usuário
  Future<NotificationPreferences> getUserNotificationPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final prefsJson = prefs.getString(_keyUserPreferences);

      if (prefsJson != null) {
        final data = jsonDecode(prefsJson) as Map<String, dynamic>;
        return NotificationPreferences.fromJson(data);
      }
      return NotificationPreferences.defaultPreferences();
    } catch (e) {
      debugPrint('Error getting user preferences: $e');
      return NotificationPreferences.defaultPreferences();
    }
  }

  /// Salva preferências de notificação do usuário
  Future<void> saveUserNotificationPreferences(
    NotificationPreferences preferences,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        _keyUserPreferences,
        jsonEncode(preferences.toJson()),
      );
      if (preferences.promotionalEnabled) {
        await _messagingService.subscribeToPromotionalNotifications();
      } else {
        await _messagingService.unsubscribeFromPromotionalNotifications();
      }
    } catch (e) {
      debugPrint('Error saving user preferences: $e');
    }
  }

  /// Salva histórico de notificações
  Future<void> _saveNotificationHistory(
    PromotionalNotification notification,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final historyJson = prefs.getStringList('notification_history') ?? [];

      historyJson.add(jsonEncode(notification.toJson()));
      if (historyJson.length > 50) {
        historyJson.removeRange(0, historyJson.length - 50);
      }

      await prefs.setStringList('notification_history', historyJson);
    } catch (e) {
      debugPrint('Error saving notification history: $e');
    }
  }

  /// Obtém histórico de notificações
  Future<List<PromotionalNotification>> getNotificationHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final historyJson = prefs.getStringList('notification_history') ?? [];

      return historyJson.map((json) {
        final data = jsonDecode(json) as Map<String, dynamic>;
        return PromotionalNotification.fromJson(data);
      }).toList();
    } catch (e) {
      debugPrint('Error getting notification history: $e');
      return [];
    }
  }

  /// Marca notificação como dispensada pelo usuário
  Future<void> markNotificationDismissed(int notificationId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final dismissed = prefs.getStringList(_keyDismissedNotifications) ?? [];
      dismissed.add(notificationId.toString());
      await prefs.setStringList(_keyDismissedNotifications, dismissed);
    } catch (e) {
      debugPrint('Error marking notification as dismissed: $e');
    }
  }
}

/// Modelo para preferências de notificação do usuário
class NotificationPreferences {
  final bool promotionalEnabled;
  final bool seasonalAlertsEnabled;
  final bool premiumOffersEnabled;
  final bool newFeaturesEnabled;
  final List<String> interestedCategories;

  const NotificationPreferences({
    required this.promotionalEnabled,
    required this.seasonalAlertsEnabled,
    required this.premiumOffersEnabled,
    required this.newFeaturesEnabled,
    required this.interestedCategories,
  });

  factory NotificationPreferences.defaultPreferences() {
    return const NotificationPreferences(
      promotionalEnabled: true,
      seasonalAlertsEnabled: true,
      premiumOffersEnabled: true,
      newFeaturesEnabled: true,
      interestedCategories: ['defensivos', 'pragas', 'diagnosticos'],
    );
  }

  factory NotificationPreferences.fromJson(Map<String, dynamic> json) {
    return NotificationPreferences(
      promotionalEnabled: json['promotional_enabled'] as bool? ?? true,
      seasonalAlertsEnabled: json['seasonal_alerts_enabled'] as bool? ?? true,
      premiumOffersEnabled: json['premium_offers_enabled'] as bool? ?? true,
      newFeaturesEnabled: json['new_features_enabled'] as bool? ?? true,
      interestedCategories: List<String>.from(
        json['interested_categories'] as List? ?? [],
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'promotional_enabled': promotionalEnabled,
      'seasonal_alerts_enabled': seasonalAlertsEnabled,
      'premium_offers_enabled': premiumOffersEnabled,
      'new_features_enabled': newFeaturesEnabled,
      'interested_categories': interestedCategories,
    };
  }

  NotificationPreferences copyWith({
    bool? promotionalEnabled,
    bool? seasonalAlertsEnabled,
    bool? premiumOffersEnabled,
    bool? newFeaturesEnabled,
    List<String>? interestedCategories,
  }) {
    return NotificationPreferences(
      promotionalEnabled: promotionalEnabled ?? this.promotionalEnabled,
      seasonalAlertsEnabled:
          seasonalAlertsEnabled ?? this.seasonalAlertsEnabled,
      premiumOffersEnabled: premiumOffersEnabled ?? this.premiumOffersEnabled,
      newFeaturesEnabled: newFeaturesEnabled ?? this.newFeaturesEnabled,
      interestedCategories: interestedCategories ?? this.interestedCategories,
    );
  }
}

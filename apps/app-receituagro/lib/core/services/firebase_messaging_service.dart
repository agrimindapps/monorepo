import 'dart:convert';
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../data/models/promotional_notification.dart';
import 'receituagro_navigation_service.dart';

/// Serviço para gerenciar Firebase Cloud Messaging (Push Notifications)
/// Focado em notificações promocionais do ReceitaAgro
class ReceitaAgroFirebaseMessagingService {
  static final ReceitaAgroFirebaseMessagingService _instance = 
      ReceitaAgroFirebaseMessagingService._internal();
  factory ReceitaAgroFirebaseMessagingService() => _instance;
  ReceitaAgroFirebaseMessagingService._internal();

  static const String _topicPrefix = 'receituagro_';
  static const String _topicPromotional = '${_topicPrefix}promotional';
  static const String _topicNews = '${_topicPrefix}news';
  static const String _topicUpdates = '${_topicPrefix}updates';

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = 
      FlutterLocalNotificationsPlugin();
  
  ReceitaAgroNavigationService? _navigationService;
  bool _isInitialized = false;
  String? _fcmToken;

  /// Inicializa o serviço de push notifications
  Future<bool> initialize({ReceitaAgroNavigationService? navigationService}) async {
    if (_isInitialized) return true;
    
    try {
      _navigationService = navigationService;
      
      // Configurar notificações locais
      await _configureLocalNotifications();
      
      // Solicitar permissões
      final settings = await _requestPermissions();
      if (settings.authorizationStatus != AuthorizationStatus.authorized) {
        debugPrint('Push notifications not authorized');
        return false;
      }

      // Obter FCM token
      _fcmToken = await _firebaseMessaging.getToken();
      debugPrint('FCM Token: $_fcmToken');

      // Configurar handlers de mensagens
      _configureMessageHandlers();

      // Subscrever a tópicos promocionais por padrão
      await subscribeToPromotionalNotifications();

      _isInitialized = true;
      return true;
    } catch (e) {
      debugPrint('Error initializing Firebase Messaging: $e');
      return false;
    }
  }

  /// Configura notificações locais para mostrar push notifications
  Future<void> _configureLocalNotifications() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initializationSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Criar canal de notificação para Android
    if (Platform.isAndroid) {
      await _createNotificationChannels();
    }
  }

  /// Cria canais de notificação específicos para o ReceitaAgro
  Future<void> _createNotificationChannels() async {
    const promotionalChannel = AndroidNotificationChannel(
      'receituagro_promotional',
      'Ofertas e Promoções',
      description: 'Notificações sobre ofertas especiais e promoções do ReceitaAgro',
      importance: Importance.high,
      sound: RawResourceAndroidNotificationSound('notification'),
    );

    const newsChannel = AndroidNotificationChannel(
      'receituagro_news',
      'Novidades do App',
      description: 'Notificações sobre novos recursos e conteúdos',
      importance: Importance.defaultImportance,
    );

    const updatesChannel = AndroidNotificationChannel(
      'receituagro_updates',
      'Atualizações Importantes',
      description: 'Notificações sobre atualizações importantes do app',
      importance: Importance.high,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(promotionalChannel);
    
    await _localNotifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(newsChannel);
    
    await _localNotifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(updatesChannel);
  }

  /// Solicita permissões para push notifications
  Future<NotificationSettings> _requestPermissions() async {
    return await _firebaseMessaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );
  }

  /// Configura handlers para diferentes tipos de mensagens
  void _configureMessageHandlers() {
    // Mensagem recebida quando app está em foreground
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Mensagem tocada quando app está em background
    FirebaseMessaging.onMessageOpenedApp.listen(_handleBackgroundMessageTap);

    // Mensagem que abriu o app (cold start)
    FirebaseMessaging.instance.getInitialMessage().then((message) {
      if (message != null) {
        _handleBackgroundMessageTap(message);
      }
    });
  }

  /// Trata mensagens recebidas em foreground
  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    debugPrint('Foreground message received: ${message.messageId}');
    
    final promotional = PromotionalNotification.fromRemoteMessage(message);
    await _showLocalNotification(promotional);
  }

  /// Trata toque em notificação que abriu o app
  Future<void> _handleBackgroundMessageTap(RemoteMessage message) async {
    debugPrint('Background message tapped: ${message.messageId}');
    
    final promotional = PromotionalNotification.fromRemoteMessage(message);
    await _handleNotificationNavigation(promotional);
  }

  /// Callback para notificação local tocada
  void _onNotificationTapped(NotificationResponse response) {
    if (response.payload != null) {
      try {
        final data = jsonDecode(response.payload!) as Map<String, dynamic>;
        final promotional = PromotionalNotification.fromJson(data);
        _handleNotificationNavigation(promotional);
      } catch (e) {
        debugPrint('Error parsing notification payload: $e');
      }
    }
  }

  /// Mostra notificação local personalizada
  Future<void> _showLocalNotification(PromotionalNotification notification) async {
    final androidDetails = AndroidNotificationDetails(
      notification.channelId,
      notification.channelName,
      channelDescription: notification.channelDescription,
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      color: const Color(0xFF4CAF50), // Verde ReceitaAgro
      largeIcon: notification.imageUrl != null 
          ? const DrawableResourceAndroidBitmap('@mipmap/ic_launcher')
          : null,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      notification.id,
      notification.title,
      notification.body,
      notificationDetails,
      payload: jsonEncode(notification.toJson()),
    );
  }

  /// Trata navegação baseada no tipo de notificação
  Future<void> _handleNotificationNavigation(PromotionalNotification notification) async {
    if (_navigationService == null) return;

    switch (notification.type) {
      case NotificationType.premium:
        _navigationService!.navigateTo<void>('/premium',
          pageType: 'premium');
        break;
      case NotificationType.newFeature:
        if (notification.targetScreen != null) {
          _navigateToScreen(notification.targetScreen!);
        }
        break;
      case NotificationType.promotional:
        if (notification.deepLink != null) {
          _handleDeepLink(notification.deepLink!);
        }
        break;
      case NotificationType.general:
        // Navegação padrão ou mostrar dialog
        break;
    }
  }

  /// Navega para tela específica
  void _navigateToScreen(String screenName) {
    switch (screenName.toLowerCase()) {
      case 'defensivos':
        _navigationService?.navigateToListaDefensivos();
        break;
      case 'pragas':
        _navigationService?.navigateToListaPragas();
        break;
      case 'diagnosticos':
        _navigationService?.navigateToListaDiagnosticos();
        break;
      case 'culturas':
        _navigationService?.navigateToListaCulturas();
        break;
      default:
        debugPrint('Unknown target screen: $screenName');
    }
  }

  /// Trata deep links personalizados
  void _handleDeepLink(String deepLink) {
    // Implementar lógica de deep link conforme necessário
    debugPrint('Handling deep link: $deepLink');
  }

  /// Subscreve a notificações promocionais
  Future<bool> subscribeToPromotionalNotifications() async {
    try {
      await _firebaseMessaging.subscribeToTopic(_topicPromotional);
      await _firebaseMessaging.subscribeToTopic(_topicNews);
      debugPrint('Subscribed to promotional notifications');
      return true;
    } catch (e) {
      debugPrint('Error subscribing to promotional notifications: $e');
      return false;
    }
  }

  /// Cancela subscrição de notificações promocionais
  Future<bool> unsubscribeFromPromotionalNotifications() async {
    try {
      await _firebaseMessaging.unsubscribeFromTopic(_topicPromotional);
      await _firebaseMessaging.unsubscribeFromTopic(_topicNews);
      debugPrint('Unsubscribed from promotional notifications');
      return true;
    } catch (e) {
      debugPrint('Error unsubscribing from promotional notifications: $e');
      return false;
    }
  }

  /// Subscreve a atualizações importantes (sempre ativo)
  Future<bool> subscribeToImportantUpdates() async {
    try {
      await _firebaseMessaging.subscribeToTopic(_topicUpdates);
      debugPrint('Subscribed to important updates');
      return true;
    } catch (e) {
      debugPrint('Error subscribing to important updates: $e');
      return false;
    }
  }

  /// Obtém o FCM token atual
  String? get fcmToken => _fcmToken;

  /// Verifica se o serviço está inicializado
  bool get isInitialized => _isInitialized;

  /// Atualiza o serviço de navegação
  void updateNavigationService(ReceitaAgroNavigationService service) {
    _navigationService = service;
  }

  /// Método para testar push notifications (desenvolvimento)
  Future<void> sendTestPromotionalNotification() async {
    if (!kDebugMode) return;
    
    final testNotification = PromotionalNotification(
      id: DateTime.now().millisecondsSinceEpoch,
      title: '🌱 Oferta Especial ReceitaAgro!',
      body: 'Descubra os melhores defensivos com 20% de desconto. Aproveite agora!',
      type: NotificationType.promotional,
      channelId: 'receituagro_promotional',
      channelName: 'Ofertas e Promoções',
      channelDescription: 'Notificações sobre ofertas especiais',
      imageUrl: null,
      targetScreen: 'defensivos',
      deepLink: 'receituagro://promotion/defensivos',
      data: {
        'promotion_id': 'test_001',
        'discount': '20',
        'category': 'defensivos',
      },
    );

    await _showLocalNotification(testNotification);
  }
}


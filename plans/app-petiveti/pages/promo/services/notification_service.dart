// Flutter imports:
import 'package:flutter/foundation.dart';

// Project imports:
import '../models/pre_register_model.dart';

enum NotificationType {
  registration('registration', 'Confirmação de Registro'),
  launch('launch', 'Aplicativo Lançado'),
  update('update', 'Atualização Disponível'),
  reminder('reminder', 'Lembrete'),
  promotional('promotional', 'Promocional');

  const NotificationType(this.id, this.displayName);
  final String id;
  final String displayName;
}

enum NotificationStatus {
  pending('pending', 'Pendente'),
  sent('sent', 'Enviado'),
  delivered('delivered', 'Entregue'),
  failed('failed', 'Falhou'),
  bounced('bounced', 'Rejeitado');

  const NotificationStatus(this.id, this.displayName);
  final String id;
  final String displayName;
}

class NotificationTemplate {
  final String id;
  final String name;
  final NotificationType type;
  final String subject;
  final String htmlContent;
  final String textContent;
  final Map<String, String> variables;

  const NotificationTemplate({
    required this.id,
    required this.name,
    required this.type,
    required this.subject,
    required this.htmlContent,
    required this.textContent,
    this.variables = const {},
  });

  NotificationTemplate copyWith({
    String? id,
    String? name,
    NotificationType? type,
    String? subject,
    String? htmlContent,
    String? textContent,
    Map<String, String>? variables,
  }) {
    return NotificationTemplate(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      subject: subject ?? this.subject,
      htmlContent: htmlContent ?? this.htmlContent,
      textContent: textContent ?? this.textContent,
      variables: variables ?? this.variables,
    );
  }

  String processTemplate(Map<String, String> values) {
    String processed = htmlContent;
    for (final entry in values.entries) {
      processed = processed.replaceAll('{{${entry.key}}}', entry.value);
    }
    return processed;
  }

  String processSubject(Map<String, String> values) {
    String processed = subject;
    for (final entry in values.entries) {
      processed = processed.replaceAll('{{${entry.key}}}', entry.value);
    }
    return processed;
  }

  List<String> getRequiredVariables() {
    final regex = RegExp(r'\{\{(\w+)\}\}');
    final matches = regex.allMatches(htmlContent);
    return matches.map((match) => match.group(1)!).toSet().toList();
  }

  bool hasVariable(String variable) {
    return htmlContent.contains('{{$variable}}') || subject.contains('{{$variable}}');
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type.id,
      'subject': subject,
      'htmlContent': htmlContent,
      'textContent': textContent,
      'variables': variables,
    };
  }

  static NotificationTemplate fromJson(Map<String, dynamic> json) {
    return NotificationTemplate(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      type: _getNotificationTypeById(json['type'] ?? 'registration'),
      subject: json['subject'] ?? '',
      htmlContent: json['htmlContent'] ?? '',
      textContent: json['textContent'] ?? '',
      variables: Map<String, String>.from(json['variables'] ?? {}),
    );
  }

  static NotificationType _getNotificationTypeById(String id) {
    return NotificationType.values.firstWhere(
      (type) => type.id == id,
      orElse: () => NotificationType.registration,
    );
  }

  @override
  String toString() {
    return 'NotificationTemplate(id: $id, name: $name, type: ${type.id})';
  }
}

class NotificationLog {
  final String id;
  final String recipientEmail;
  final String recipientName;
  final NotificationType type;
  final NotificationStatus status;
  final DateTime sentAt;
  final DateTime? deliveredAt;
  final String? errorMessage;
  final Map<String, dynamic> metadata;

  const NotificationLog({
    required this.id,
    required this.recipientEmail,
    required this.recipientName,
    required this.type,
    required this.status,
    required this.sentAt,
    this.deliveredAt,
    this.errorMessage,
    this.metadata = const {},
  });

  NotificationLog copyWith({
    String? id,
    String? recipientEmail,
    String? recipientName,
    NotificationType? type,
    NotificationStatus? status,
    DateTime? sentAt,
    DateTime? deliveredAt,
    String? errorMessage,
    Map<String, dynamic>? metadata,
  }) {
    return NotificationLog(
      id: id ?? this.id,
      recipientEmail: recipientEmail ?? this.recipientEmail,
      recipientName: recipientName ?? this.recipientName,
      type: type ?? this.type,
      status: status ?? this.status,
      sentAt: sentAt ?? this.sentAt,
      deliveredAt: deliveredAt ?? this.deliveredAt,
      errorMessage: errorMessage ?? this.errorMessage,
      metadata: metadata ?? this.metadata,
    );
  }

  bool get isSuccess => status == NotificationStatus.delivered || status == NotificationStatus.sent;
  bool get isFailed => status == NotificationStatus.failed || status == NotificationStatus.bounced;
  bool get isPending => status == NotificationStatus.pending;

  Duration? get deliveryTime {
    if (deliveredAt == null) return null;
    return deliveredAt!.difference(sentAt);
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'recipientEmail': recipientEmail,
      'recipientName': recipientName,
      'type': type.id,
      'status': status.id,
      'sentAt': sentAt.toIso8601String(),
      'deliveredAt': deliveredAt?.toIso8601String(),
      'errorMessage': errorMessage,
      'metadata': metadata,
    };
  }

  static NotificationLog fromJson(Map<String, dynamic> json) {
    return NotificationLog(
      id: json['id'] ?? '',
      recipientEmail: json['recipientEmail'] ?? '',
      recipientName: json['recipientName'] ?? '',
      type: NotificationTemplate._getNotificationTypeById(json['type'] ?? 'registration'),
      status: _getNotificationStatusById(json['status'] ?? 'pending'),
      sentAt: DateTime.parse(json['sentAt'] ?? DateTime.now().toIso8601String()),
      deliveredAt: json['deliveredAt'] != null ? DateTime.parse(json['deliveredAt']) : null,
      errorMessage: json['errorMessage'],
      metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
    );
  }

  static NotificationStatus _getNotificationStatusById(String id) {
    return NotificationStatus.values.firstWhere(
      (status) => status.id == id,
      orElse: () => NotificationStatus.pending,
    );
  }

  @override
  String toString() {
    return 'NotificationLog(id: $id, recipientEmail: $recipientEmail, type: ${type.id}, status: ${status.id})';
  }
}

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  // State
  final List<NotificationLog> _logs = [];
  final Map<String, NotificationTemplate> _templates = {};
  bool _isInitialized = false;

  // Getters
  List<NotificationLog> get logs => List.unmodifiable(_logs);
  Map<String, NotificationTemplate> get templates => Map.unmodifiable(_templates);
  bool get isInitialized => _isInitialized;

  // Initialization
  Future<void> initialize() async {
    try {
      await _loadTemplates();
      _isInitialized = true;
    } catch (e) {
      debugPrint('NotificationService initialization error: $e');
    }
  }

  Future<void> _loadTemplates() async {
    try {
      _templates.addAll(_getDefaultTemplates());
    } catch (e) {
      debugPrint('Error loading notification templates: $e');
    }
  }

  Map<String, NotificationTemplate> _getDefaultTemplates() {
    return {
      'registration_confirmation': const NotificationTemplate(
        id: 'registration_confirmation',
        name: 'Confirmação de Registro',
        type: NotificationType.registration,
        subject: 'Obrigado por se inscrever no PetiVeti! 🐾',
        htmlContent: '''
        <html>
        <body>
          <h1>Olá, {{name}}!</h1>
          <p>Obrigado por se inscrever para ser notificado sobre o lançamento do PetiVeti!</p>
          <p>Você escolheu ser notificado sobre o lançamento para <strong>{{platform}}</strong>.</p>
          <p>Te enviaremos um email assim que o aplicativo estiver disponível na {{store}}.</p>
          <p>Enquanto isso, acompanhe nossas redes sociais para ficar por dentro das novidades!</p>
          <p>Atenciosamente,<br>Equipe PetiVeti</p>
        </body>
        </html>
        ''',
        textContent: '''
        Olá, {{name}}!
        
        Obrigado por se inscrever para ser notificado sobre o lançamento do PetiVeti!
        
        Você escolheu ser notificado sobre o lançamento para {{platform}}.
        Te enviaremos um email assim que o aplicativo estiver disponível na {{store}}.
        
        Enquanto isso, acompanhe nossas redes sociais para ficar por dentro das novidades!
        
        Atenciosamente,
        Equipe PetiVeti
        ''',
        variables: {
          'name': 'Nome do usuário',
          'platform': 'Plataforma escolhida',
          'store': 'Nome da loja',
        },
      ),
      'launch_notification': const NotificationTemplate(
        id: 'launch_notification',
        name: 'Notificação de Lançamento',
        type: NotificationType.launch,
        subject: 'PetiVeti está disponível! Baixe agora 🎉',
        htmlContent: '''
        <html>
        <body>
          <h1>{{name}}, o PetiVeti finalmente chegou!</h1>
          <p>O aplicativo que você estava esperando já está disponível para download!</p>
          <p><strong>Baixe agora na {{store}}:</strong></p>
          <p><a href="{{store_url}}" style="background-color: #6A1B9A; color: white; padding: 12px 24px; text-decoration: none; border-radius: 8px;">Baixar PetiVeti</a></p>
          <h2>Recursos disponíveis:</h2>
          <ul>
            <li>Perfis personalizados para seus pets</li>
            <li>Controle de vacinas e medicamentos</li>
            <li>Lembretes inteligentes</li>
            <li>Gráficos de peso e saúde</li>
            <li>Histórico de consultas</li>
            <li>Sincronização em nuvem</li>
          </ul>
          <p>Comece agora a cuidar melhor do seu melhor amigo!</p>
          <p>Atenciosamente,<br>Equipe PetiVeti</p>
        </body>
        </html>
        ''',
        textContent: '''
        {{name}}, o PetiVeti finalmente chegou!
        
        O aplicativo que você estava esperando já está disponível para download!
        
        Baixe agora na {{store}}: {{store_url}}
        
        Recursos disponíveis:
        - Perfis personalizados para seus pets
        - Controle de vacinas e medicamentos
        - Lembretes inteligentes
        - Gráficos de peso e saúde
        - Histórico de consultas
        - Sincronização em nuvem
        
        Comece agora a cuidar melhor do seu melhor amigo!
        
        Atenciosamente,
        Equipe PetiVeti
        ''',
        variables: {
          'name': 'Nome do usuário',
          'store': 'Nome da loja',
          'store_url': 'URL da loja',
        },
      ),
    };
  }

  // Notification sending
  Future<bool> sendRegistrationConfirmation({
    required String email,
    required String name,
    required AppPlatform platform,
  }) async {
    try {
      final template = _templates['registration_confirmation'];
      if (template == null) {
        throw Exception('Template de confirmação não encontrado');
      }

      final variables = {
        'name': name,
        'platform': platform.displayName,
        'store': platform.storeName,
      };

      return await _sendNotification(
        template: template,
        recipientEmail: email,
        recipientName: name,
        variables: variables,
      );
    } catch (e) {
      debugPrint('Error sending registration confirmation: $e');
      return false;
    }
  }

  Future<bool> sendLaunchNotification({
    required String email,
    required String name,
    required AppPlatform platform,
  }) async {
    try {
      final template = _templates['launch_notification'];
      if (template == null) {
        throw Exception('Template de lançamento não encontrado');
      }

      final storeUrl = PreRegisterRepository.getStoreUrlForPlatform(platform) ?? '';

      final variables = {
        'name': name,
        'store': platform.storeName,
        'store_url': storeUrl,
      };

      return await _sendNotification(
        template: template,
        recipientEmail: email,
        recipientName: name,
        variables: variables,
      );
    } catch (e) {
      debugPrint('Error sending launch notification: $e');
      return false;
    }
  }

  Future<bool> _sendNotification({
    required NotificationTemplate template,
    required String recipientEmail,
    required String recipientName,
    required Map<String, String> variables,
  }) async {
    final logId = _generateLogId();
    
    // Create initial log entry
    final log = NotificationLog(
      id: logId,
      recipientEmail: recipientEmail,
      recipientName: recipientName,
      type: template.type,
      status: NotificationStatus.pending,
      sentAt: DateTime.now(),
      metadata: {
        'templateId': template.id,
        'variables': variables,
      },
    );

    _logs.add(log);

    try {
      // Process template
      final processedSubject = template.processSubject(variables);
      final processedContent = template.processTemplate(variables);

      // Simulate email sending
      await Future.delayed(const Duration(seconds: 1));

      // In a real implementation, use an email service like:
      // - SendGrid
      // - AWS SES
      // - Firebase Cloud Messaging
      // - Mailgun
      // - etc.

      debugPrint('Sending email to $recipientEmail');
      debugPrint('Subject: $processedSubject');
      debugPrint('Content: ${processedContent.substring(0, 100)}...');

      // Simulate success (90% success rate)
      final success = DateTime.now().millisecond % 10 != 0;

      if (success) {
        _updateLogStatus(logId, NotificationStatus.sent);
        
        // Simulate delivery confirmation after a delay
        Future.delayed(const Duration(seconds: 2), () {
          _updateLogStatus(logId, NotificationStatus.delivered);
        });
        
        return true;
      } else {
        _updateLogStatus(logId, NotificationStatus.failed, 'Simulated failure');
        return false;
      }
    } catch (e) {
      _updateLogStatus(logId, NotificationStatus.failed, e.toString());
      return false;
    }
  }

  void _updateLogStatus(String logId, NotificationStatus status, [String? errorMessage]) {
    final index = _logs.indexWhere((log) => log.id == logId);
    if (index != -1) {
      _logs[index] = _logs[index].copyWith(
        status: status,
        deliveredAt: status == NotificationStatus.delivered ? DateTime.now() : null,
        errorMessage: errorMessage,
      );
    }
  }

  String _generateLogId() {
    return 'notification_${DateTime.now().millisecondsSinceEpoch}';
  }

  // Batch operations
  Future<Map<String, bool>> sendBulkNotifications({
    required List<PreRegisterData> recipients,
    required String templateId,
  }) async {
    final results = <String, bool>{};
    final template = _templates[templateId];
    
    if (template == null) {
      debugPrint('Template $templateId not found');
      return results;
    }

    for (final recipient in recipients) {
      final variables = {
        'name': recipient.name,
        'platform': recipient.platform.displayName,
        'store': recipient.platform.storeName,
      };

      final success = await _sendNotification(
        template: template,
        recipientEmail: recipient.email,
        recipientName: recipient.name,
        variables: variables,
      );

      results[recipient.email] = success;
      
      // Add delay between sends to avoid rate limiting
      await Future.delayed(const Duration(milliseconds: 100));
    }

    return results;
  }

  // Statistics and analytics
  Map<String, dynamic> getNotificationStatistics() {
    final totalNotifications = _logs.length;
    final sentNotifications = _logs.where((log) => log.status == NotificationStatus.sent).length;
    final deliveredNotifications = _logs.where((log) => log.status == NotificationStatus.delivered).length;
    final failedNotifications = _logs.where((log) => log.isFailed).length;

    final typeStats = <String, int>{};
    for (final type in NotificationType.values) {
      typeStats[type.id] = _logs.where((log) => log.type == type).length;
    }

    return {
      'totalNotifications': totalNotifications,
      'sentNotifications': sentNotifications,
      'deliveredNotifications': deliveredNotifications,
      'failedNotifications': failedNotifications,
      'successRate': totalNotifications > 0 ? (deliveredNotifications / totalNotifications * 100) : 0,
      'typeStatistics': typeStats,
      'averageDeliveryTime': _calculateAverageDeliveryTime(),
    };
  }

  double _calculateAverageDeliveryTime() {
    final deliveredLogs = _logs.where((log) => log.deliveredAt != null).toList();
    if (deliveredLogs.isEmpty) return 0.0;

    final totalTime = deliveredLogs
        .map((log) => log.deliveryTime!.inMilliseconds)
        .reduce((a, b) => a + b);

    return totalTime / deliveredLogs.length;
  }

  List<NotificationLog> getLogsByType(NotificationType type) {
    return _logs.where((log) => log.type == type).toList();
  }

  List<NotificationLog> getLogsByStatus(NotificationStatus status) {
    return _logs.where((log) => log.status == status).toList();
  }

  List<NotificationLog> getRecentLogs({int limit = 50}) {
    final sortedLogs = List<NotificationLog>.from(_logs);
    sortedLogs.sort((a, b) => b.sentAt.compareTo(a.sentAt));
    return sortedLogs.take(limit).toList();
  }

  // Template management
  void addTemplate(NotificationTemplate template) {
    _templates[template.id] = template;
  }

  void removeTemplate(String templateId) {
    _templates.remove(templateId);
  }

  NotificationTemplate? getTemplate(String templateId) {
    return _templates[templateId];
  }

  List<NotificationTemplate> getTemplatesByType(NotificationType type) {
    return _templates.values.where((template) => template.type == type).toList();
  }

  // Validation
  bool isValidEmail(String email) {
    return RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email);
  }

  bool canSendNotification(String email) {
    return isValidEmail(email) && _isInitialized;
  }

  // Cleanup
  void clearLogs() {
    _logs.clear();
  }

  void clearOldLogs({Duration maxAge = const Duration(days: 30)}) {
    final cutoffDate = DateTime.now().subtract(maxAge);
    _logs.removeWhere((log) => log.sentAt.isBefore(cutoffDate));
  }
}

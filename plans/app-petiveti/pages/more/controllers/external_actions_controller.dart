// Flutter imports:
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

// Project imports:
import '../models/share_model.dart';
import '../services/analytics_service.dart';
import '../services/navigation_service.dart';

class ExternalActionsController extends ChangeNotifier {
  // Services
  late final NavigationService _navigationService;
  late final AnalyticsService _analyticsService;

  // State
  final Map<String, ShareAction> _shareHistory = {};
  bool _isProcessing = false;
  String? _errorMessage;
  DateTime? _lastAction;

  // Getters
  Map<String, ShareAction> get shareHistory => Map.unmodifiable(_shareHistory);
  bool get isProcessing => _isProcessing;
  bool get hasError => _errorMessage != null;
  String? get errorMessage => _errorMessage;
  DateTime? get lastAction => _lastAction;
  bool get hasShareHistory => _shareHistory.isNotEmpty;
  int get shareHistoryCount => _shareHistory.length;

  ExternalActionsController() {
    _initializeServices();
  }

  void _initializeServices() {
    _navigationService = NavigationService();
    _analyticsService = AnalyticsService();
  }

  Future<void> initialize() async {
    try {
      await _loadShareHistory();
      _clearError();
    } catch (e) {
      _setError('Erro ao inicializar ações externas: $e');
    }
  }

  Future<void> _loadShareHistory() async {
    try {
      // In a real implementation, load from persistent storage
      // For now, just initialize empty
    } catch (e) {
      debugPrint('Error loading share history: $e');
    }
  }

  // Share actions
  Future<bool> shareAppPromotion({SharePlatform? platform}) async {
    final content = ShareRepository.getContentById('app_share');
    if (content == null) {
      _setError('Conteúdo de compartilhamento não encontrado');
      return false;
    }

    return await _executeShareAction(content, platform ?? SharePlatform.generic);
  }

  Future<bool> shareCustomText(String text, {SharePlatform? platform}) async {
    final content = ShareContent(
      id: 'custom_${DateTime.now().millisecondsSinceEpoch}',
      title: 'Compartilhamento Personalizado',
      text: text,
      type: ShareType.text,
    );

    return await _executeShareAction(content, platform ?? SharePlatform.generic);
  }

  Future<bool> shareFeedback({SharePlatform? platform}) async {
    final content = ShareRepository.getContentById('feedback_share');
    if (content == null) {
      _setError('Conteúdo de feedback não encontrado');
      return false;
    }

    return await _executeShareAction(content, platform ?? SharePlatform.generic);
  }

  Future<bool> _executeShareAction(ShareContent content, SharePlatform platform) async {
    if (_isProcessing) return false;

    _setProcessing(true);
    _clearError();
    _updateLastAction();

    try {
      final shareText = content.getTextForPlatform(platform);
      final success = await _navigationService.shareText(shareText);

      final action = ShareRepository.createShareAction(
        contentId: content.id,
        platform: platform,
        success: success,
        error: success ? null : 'Falha ao compartilhar',
      );

      _addToShareHistory(action);
      
      _analyticsService.trackEvent('share_action', {
        'content_id': content.id,
        'platform': platform.id,
        'success': success,
        'content_type': content.type.id,
      });

      return success;
    } catch (e) {
      _setError('Erro ao compartilhar: $e');
      
      final action = ShareRepository.createShareAction(
        contentId: content.id,
        platform: platform,
        success: false,
        error: e.toString(),
      );
      
      _addToShareHistory(action);
      return false;
    } finally {
      _setProcessing(false);
    }
  }

  // URL actions
  Future<bool> openAppStore() async {
    const url = 'https://play.google.com/store/apps/details?id=com.petiveti';
    return await _openUrl(url, 'app_store');
  }

  Future<bool> openHelpPage() async {
    const url = 'https://petiveti.com/ajuda';
    return await _openUrl(url, 'help_page');
  }

  Future<bool> openWebsite() async {
    const url = 'https://petiveti.com';
    return await _openUrl(url, 'website');
  }

  Future<bool> openPrivacyPolicy() async {
    const url = 'https://petiveti.com/privacidade';
    return await _openUrl(url, 'privacy_policy');
  }

  Future<bool> openTermsOfService() async {
    const url = 'https://petiveti.com/termos';
    return await _openUrl(url, 'terms_of_service');
  }

  Future<bool> _openUrl(String url, String actionType) async {
    if (_isProcessing) return false;

    _setProcessing(true);
    _clearError();
    _updateLastAction();

    try {
      final success = await _navigationService.openExternalUrl(url);
      
      _analyticsService.trackEvent('external_url_opened', {
        'url': url,
        'action_type': actionType,
        'success': success,
      });

      if (!success) {
        _setError('Não foi possível abrir o link');
      }

      return success;
    } catch (e) {
      _setError('Erro ao abrir link: $e');
      return false;
    } finally {
      _setProcessing(false);
    }
  }

  // Email actions
  Future<bool> sendSupportEmail({String? customMessage}) async {
    return await _sendEmail(
      email: 'suporte@petiveti.com',
      subject: 'Suporte PetiVeti App',
      body: customMessage,
      actionType: 'support_email',
    );
  }

  Future<bool> sendFeedbackEmail(String feedback) async {
    return await _sendEmail(
      email: 'feedback@petiveti.com',
      subject: 'Feedback PetiVeti App',
      body: feedback,
      actionType: 'feedback_email',
    );
  }

  Future<bool> sendBugReportEmail(String bugReport) async {
    return await _sendEmail(
      email: 'bugs@petiveti.com',
      subject: 'Bug Report PetiVeti App',
      body: bugReport,
      actionType: 'bug_report_email',
    );
  }

  Future<bool> _sendEmail({
    required String email,
    required String subject,
    String? body,
    required String actionType,
  }) async {
    if (_isProcessing) return false;

    _setProcessing(true);
    _clearError();
    _updateLastAction();

    try {
      final success = await _navigationService.sendEmail(
        email: email,
        subject: subject,
        body: body,
      );

      _analyticsService.trackEvent('email_action', {
        'email': email,
        'subject': subject,
        'action_type': actionType,
        'success': success,
        'has_custom_body': body != null,
      });

      if (!success) {
        _setError('Não foi possível abrir o cliente de email');
      }

      return success;
    } catch (e) {
      _setError('Erro ao enviar email: $e');
      return false;
    } finally {
      _setProcessing(false);
    }
  }

  // History management
  void _addToShareHistory(ShareAction action) {
    _shareHistory[action.id] = action;
    notifyListeners();
  }

  List<ShareAction> getShareHistoryByPlatform(SharePlatform platform) {
    return _shareHistory.values
        .where((action) => action.platform == platform)
        .toList()
        ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  List<ShareAction> getRecentShareActions({int limit = 10}) {
    final actions = _shareHistory.values.toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return actions.take(limit).toList();
  }

  ShareAction? getLastShareAction() {
    if (_shareHistory.isEmpty) return null;
    
    return _shareHistory.values
        .reduce((a, b) => a.timestamp.isAfter(b.timestamp) ? a : b);
  }

  void clearShareHistory() {
    _shareHistory.clear();
    notifyListeners();
    
    _analyticsService.trackEvent('share_history_cleared', {
      'cleared_count': _shareHistory.length,
    });
  }

  // Statistics and information
  Map<String, dynamic> getActionStatistics() {
    final platformCounts = <String, int>{};
    final successCount = _shareHistory.values.where((a) => a.success).length;
    
    for (final action in _shareHistory.values) {
      platformCounts[action.platform.id] = (platformCounts[action.platform.id] ?? 0) + 1;
    }

    return {
      'totalShares': _shareHistory.length,
      'successfulShares': successCount,
      'failedShares': _shareHistory.length - successCount,
      'sharesByPlatform': platformCounts,
      'lastAction': _lastAction?.toIso8601String(),
      'isProcessing': _isProcessing,
    };
  }

  Map<SharePlatform, int> getShareCountsByPlatform() {
    final counts = <SharePlatform, int>{};
    
    for (final action in _shareHistory.values) {
      counts[action.platform] = (counts[action.platform] ?? 0) + 1;
    }
    
    return counts;
  }

  double getShareSuccessRate() {
    if (_shareHistory.isEmpty) return 0.0;
    
    final successCount = _shareHistory.values.where((a) => a.success).length;
    return successCount / _shareHistory.length;
  }

  // Validation and helpers
  bool canPerformAction() {
    return !_isProcessing;
  }

  List<ShareContent> getAvailableShareContents() {
    return ShareRepository.getDefaultShareContents();
  }

  List<SharePlatform> getAvailablePlatforms() {
    return ShareRepository.getAvailablePlatforms();
  }

  ShareContent? getShareContentById(String id) {
    return ShareRepository.getContentById(id);
  }

  String getPlatformDisplayName(SharePlatform platform) {
    return ShareRepository.getPlatformDisplayName(platform);
  }

  bool isValidShareContent(ShareContent content) {
    return !ShareRepository.hasValidationErrors(content);
  }

  List<String> validateShareContent(ShareContent content) {
    final errors = ShareRepository.validateContent(content);
    return errors.values.toList();
  }

  Future<void> refresh() async {
    _clearError();
    await initialize();
  }

  void _setProcessing(bool processing) {
    _isProcessing = processing;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    debugPrint('ExternalActionsController Error: $error');
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }

  void clearError() {
    _clearError();
    notifyListeners();
  }

  void _updateLastAction() {
    _lastAction = DateTime.now();
  }

}

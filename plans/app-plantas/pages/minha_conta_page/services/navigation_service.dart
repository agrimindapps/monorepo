// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

// Project imports:
import '../../../../core/services/feedback_service.dart';
import '../../../core/extensions/theme_extensions.dart';
import '../../../pages/premium_page/index.dart';

/// Service especializado para navegação e abertura de URLs
/// Centraliza toda lógica de navegação, validação de URLs e tratamento de erros
class NavigationService {
  // Singleton pattern
  static NavigationService? _instance;
  static NavigationService get instance => _instance ??= NavigationService._();
  NavigationService._();

  // URLs conhecidas e confiáveis
  static const String _termosUrl = 'https://plantis.agrimind.com.br/termos-uso';
  static const String _politicasUrl =
      'https://plantis.agrimind.com.br/politica-privacidade';

  // ========== NAVEGAÇÃO PARA URLs EXTERNAS ==========

  /// Navega para página de Termos de Uso com validação e tratamento de erro
  Future<NavigationResult> navigateToTermos() async {
    return await _openExternalUrl(
      url: _termosUrl,
      errorTitle: 'Erro',
      errorMessage: 'Não foi possível abrir o link dos Termos de Uso',
      successMessage: 'Abrindo Termos de Uso...',
    );
  }

  /// Navega para página de Política de Privacidade com validação e tratamento de erro
  Future<NavigationResult> navigateToPoliticas() async {
    return await _openExternalUrl(
      url: _politicasUrl,
      errorTitle: 'Erro',
      errorMessage: 'Não foi possível abrir o link da Política de Privacidade',
      successMessage: 'Abrindo Política de Privacidade...',
    );
  }

  /// Abre URL externa genérica com validação completa
  Future<NavigationResult> openExternalUrl(String url) async {
    return await _openExternalUrl(
      url: url,
      errorTitle: 'Erro',
      errorMessage: 'Não foi possível abrir o link: $url',
      successMessage: 'Abrindo link externo...',
    );
  }

  // ========== NAVEGAÇÃO INTERNA ==========

  /// Navega para página Premium com transição animada
  NavigationResult navigateToPromo() {
    try {
      debugPrint('🎯 NavigationService: Navegando para página Premium');

      Get.to(
        () => const PremiumView(),
        binding: PremiumBinding(),
        transition: Transition.rightToLeft,
        duration: const Duration(milliseconds: 300),
      );

      return NavigationResult(
        success: true,
        type: NavigationType.internal,
        message: 'Navegando para página Premium',
      );
    } catch (e) {
      debugPrint('❌ NavigationService: Erro ao navegar para Premium: $e');
      return NavigationResult(
        success: false,
        type: NavigationType.internal,
        error: e.toString(),
        message: 'Erro ao navegar para página Premium',
      );
    }
  }

  /// Mostra diálogo "Sobre o App" com informações da aplicação
  NavigationResult showAboutDialog() {
    try {
      debugPrint('ℹ️ NavigationService: Mostrando diálogo Sobre');

      Get.dialog(
        AlertDialog(
          title: const Text('Sobre o App Plantas'),
          content: const SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'App Plantas',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text('Versão: 1.0.0'),
                SizedBox(height: 16),
                Text(
                  'O App Plantas foi desenvolvido para ajudar você a cuidar melhor das suas plantas, criando um jardim doméstico saudável e organizado.',
                ),
                SizedBox(height: 16),
                Text(
                  'Funcionalidades:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text('• Cadastro e organização de plantas por espaços'),
                Text('• Configuração automática de cuidados'),
                Text('• Lembretes de rega, adubação e outros cuidados'),
                Text('• Histórico e comentários sobre suas plantas'),
                Text('• Backup e sincronização de dados'),
                SizedBox(height: 16),
                Text(
                  'Desenvolvido por Agrimind Soluções',
                  style: TextStyle(
                    fontStyle: FontStyle.italic,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: const Text('Fechar'),
            ),
          ],
        ),
      );

      return NavigationResult(
        success: true,
        type: NavigationType.dialog,
        message: 'Diálogo Sobre exibido',
      );
    } catch (e) {
      debugPrint('❌ NavigationService: Erro ao mostrar diálogo Sobre: $e');
      return NavigationResult(
        success: false,
        type: NavigationType.dialog,
        error: e.toString(),
        message: 'Erro ao exibir informações do app',
      );
    }
  }

  /// Mostra formulário de feedback usando FeedbackService
  NavigationResult showFeedback() {
    try {
      final context = Get.context;
      if (context == null) {
        return NavigationResult(
          success: false,
          type: NavigationType.service,
          error: 'Context não disponível',
          message: 'Não foi possível abrir o formulário de feedback',
        );
      }

      debugPrint('💬 NavigationService: Abrindo formulário de feedback');

      final feedbackService = FeedbackService();
      feedbackService.showFeedbackDialog(context);

      return NavigationResult(
        success: true,
        type: NavigationType.service,
        message: 'Formulário de feedback aberto',
      );
    } catch (e) {
      debugPrint('❌ NavigationService: Erro ao abrir feedback: $e');
      return NavigationResult(
        success: false,
        type: NavigationType.service,
        error: e.toString(),
        message: 'Erro ao abrir formulário de feedback',
      );
    }
  }

  // ========== NAVEGAÇÃO PLACEHOLDER (PARA FUTURAS IMPLEMENTAÇÕES) ==========

  /// Placeholder para navegação de notificações
  NavigationResult navigateToNotifications() {
    debugPrint(
        '🔔 NavigationService: Navegação para notificações não implementada');
    _showPlaceholderMessage('Notificações',
        'Em breve você poderá gerenciar suas notificações aqui!');

    return NavigationResult(
      success: true,
      type: NavigationType.placeholder,
      message: 'Navegação para notificações (placeholder)',
    );
  }

  /// Placeholder para navegação App Store
  NavigationResult navigateToAppStore() {
    debugPrint(
        '🏪 NavigationService: Navegação para App Store não implementada');
    _showPlaceholderMessage(
        'Avaliar App', 'Em breve você poderá avaliar o app na loja!');

    return NavigationResult(
      success: true,
      type: NavigationType.placeholder,
      message: 'Navegação para App Store (placeholder)',
    );
  }

  /// Placeholder para compartilhamento do app
  NavigationResult shareApp() {
    debugPrint('📤 NavigationService: Compartilhamento não implementado');
    _showPlaceholderMessage('Compartilhar App',
        'Em breve você poderá compartilhar o app com amigos!');

    return NavigationResult(
      success: true,
      type: NavigationType.placeholder,
      message: 'Compartilhamento do app (placeholder)',
    );
  }

  // ========== MÉTODOS PRIVADOS ==========

  /// Abre URL externa com validação completa e tratamento de erro
  Future<NavigationResult> _openExternalUrl({
    required String url,
    required String errorTitle,
    required String errorMessage,
    required String successMessage,
  }) async {
    try {
      debugPrint('🌐 NavigationService: Abrindo URL externa: $url');

      final Uri uri = Uri.parse(url);

      // Validar se a URL pode ser aberta
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);

        debugPrint('✅ NavigationService: URL aberta com sucesso');
        return NavigationResult(
          success: true,
          type: NavigationType.external,
          url: url,
          message: successMessage,
        );
      } else {
        debugPrint('❌ NavigationService: Não foi possível abrir URL: $url');
        _showError(errorTitle, errorMessage);

        return NavigationResult(
          success: false,
          type: NavigationType.external,
          url: url,
          error: 'URL não pode ser aberta',
          message: errorMessage,
        );
      }
    } catch (e) {
      debugPrint('❌ NavigationService: Erro ao abrir URL $url: $e');
      _showError(errorTitle, 'Erro ao abrir $url: $e');

      return NavigationResult(
        success: false,
        type: NavigationType.external,
        url: url,
        error: e.toString(),
        message: 'Erro ao abrir $url: $e',
      );
    }
  }

  /// Mostra mensagem de erro padronizada
  void _showError(String title, String message) {
    final context = Get.context;
    if (context != null) {
      PlantasGetSnackbar.error(context, title, message);
    }
  }

  /// Mostra mensagem para funcionalidades placeholder
  void _showPlaceholderMessage(String title, String message) {
    final context = Get.context;
    if (context != null) {
      PlantasGetSnackbar.info(context, title, message);
    }
  }
}

// ========== CLASSES DE DADOS ==========

/// Tipos de navegação disponíveis
enum NavigationType {
  external, // URLs externas
  internal, // Navegação dentro do app
  dialog, // Diálogos modais
  service, // Serviços externos
  placeholder // Funcionalidades ainda não implementadas
}

/// Resultado de operações de navegação
class NavigationResult {
  final bool success;
  final NavigationType type;
  final String? url;
  final String message;
  final String? error;

  NavigationResult({
    required this.success,
    required this.type,
    this.url,
    required this.message,
    this.error,
  });

  bool get isExternal => type == NavigationType.external;
  bool get isInternal => type == NavigationType.internal;
  bool get isDialog => type == NavigationType.dialog;
  bool get isPlaceholder => type == NavigationType.placeholder;
}

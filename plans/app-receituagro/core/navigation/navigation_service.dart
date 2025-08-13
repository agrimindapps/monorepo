// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:get/get.dart';

// Project imports:
import '../../models/favorito_model.dart';
import 'i_navigation_service.dart';

/// Serviço unificado de navegação para o módulo app-receituagro
/// Centraliza todas as operações de navegação eliminando redundâncias
class NavigationService extends GetxService implements INavigationService {
  
  // =========================================================================
  // Constantes de Rotas
  // =========================================================================
  
  static const String _defensivosDetailsRoute = '/receituagro/defensivos/detalhes';
  static const String _pragasDetailsRoute = '/receituagro/pragas/detalhes';
  static const String _diagnosticoRoute = '/receituagro/diagnostico';
  static const String _diagnosticoDetailsRoute = '/receituagro/diagnostico/detalhes';

  @override
  void onInit() {
    super.onInit();
    debugPrint('NavigationService: Serviço inicializado');
  }

  @override
  void onClose() {
    debugPrint('NavigationService: Serviço finalizado');
    super.onClose();
  }

  // =========================================================================
  // Navegação para Detalhes
  // =========================================================================

  @override
  void navigateToDefensivoDetails(String defensivoId) {
    if (!isValidId(defensivoId)) {
      _showError('ID do defensivo inválido');
      return;
    }

    _executeNavigation(
      () => Get.toNamed(_defensivosDetailsRoute, arguments: defensivoId),
      'Navegando para detalhes do defensivo: $defensivoId',
      'Erro ao abrir detalhes do defensivo',
    );
  }

  @override
  void navigateToPragaDetails(String pragaId) {
    if (!isValidId(pragaId)) {
      _showError('ID da praga inválido');
      return;
    }

    _executeNavigation(
      () => Get.toNamed(_pragasDetailsRoute, arguments: {'idReg': pragaId}),
      'Navegando para detalhes da praga: $pragaId',
      'Erro ao abrir detalhes da praga',
    );
  }

  @override
  void navigateToDiagnosticoDetails(String diagnosticoId) {
    if (!isValidId(diagnosticoId)) {
      _showError('ID do diagnóstico inválido');
      return;
    }

    _executeNavigation(
      () => Get.toNamed(_diagnosticoDetailsRoute, arguments: diagnosticoId),
      'Navegando para detalhes do diagnóstico: $diagnosticoId',
      'Erro ao abrir detalhes do diagnóstico',
    );
  }

  // =========================================================================
  // Navegação Genérica
  // =========================================================================

  @override
  void navigateToRoute(String route, {dynamic arguments}) {
    if (route.isEmpty) {
      _showError('Rota não pode estar vazia');
      return;
    }

    _executeNavigation(
      () => Get.toNamed(route, arguments: arguments),
      'Navegando para rota: $route',
      'Erro na navegação para $route',
    );
  }

  @override
  void goBack({dynamic result}) {
    try {
      Get.back(result: result);
      debugPrint('NavigationService: Voltando para página anterior');
    } catch (e) {
      debugPrint('NavigationService: Erro ao voltar - $e');
      // Não mostra erro ao usuário para operação de voltar
    }
  }

  @override
  void replaceWithRoute(String route, {dynamic arguments}) {
    if (route.isEmpty) {
      _showError('Rota não pode estar vazia');
      return;
    }

    _executeNavigation(
      () => Get.offNamed(route, arguments: arguments),
      'Substituindo por rota: $route',
      'Erro ao substituir pela rota $route',
    );
  }

  @override
  void navigateAndClearStack(String route, {dynamic arguments}) {
    if (route.isEmpty) {
      _showError('Rota não pode estar vazia');
      return;
    }

    _executeNavigation(
      () => Get.offAllNamed(route, arguments: arguments),
      'Navegando e limpando stack para: $route',
      'Erro ao navegar e limpar stack para $route',
    );
  }

  // =========================================================================
  // Navegação com Dados
  // =========================================================================

  @override
  void navigateToPragaFromData(Map<dynamic, dynamic> data) {
    final pragaId = data['fkIdPraga']?.toString();
    if (pragaId == null) {
      _showError('ID da praga não encontrado nos dados');
      return;
    }
    
    navigateToPragaDetails(pragaId);
  }

  @override
  void navigateToDiagnosticoFromData(Map<dynamic, dynamic> data) {
    final diagnosticoId = data['idReg']?.toString();
    if (diagnosticoId == null || diagnosticoId.trim().isEmpty) {
      _showError('ID do diagnóstico não encontrado nos dados');
      return;
    }
    
    navigateToDiagnosticoDetails(diagnosticoId);
  }

  // =========================================================================
  // Navegação com Modelos de Favoritos
  // =========================================================================

  /// Navega para detalhes de defensivo a partir do modelo de favorito
  void navigateToDefensivoFromFavorite(FavoritoDefensivoModel defensivo) {
    navigateToDefensivoDetails(defensivo.id.toString());
  }

  /// Navega para detalhes de praga a partir do modelo de favorito
  void navigateToPragaFromFavorite(FavoritoPragaModel praga) {
    navigateToPragaDetails(praga.id.toString());
  }

  /// Navega para detalhes de diagnóstico a partir do modelo de favorito
  void navigateToDiagnosticoFromFavorite(FavoritoDiagnosticoModel diagnostico) {
    // Para favoritos de diagnóstico, use a rota específica
    _executeNavigation(
      () => Get.toNamed(_diagnosticoRoute, arguments: diagnostico.id),
      'Navegando para diagnóstico favorito: ${diagnostico.id}',
      'Erro ao abrir diagnóstico favorito',
    );
  }

  // =========================================================================
  // Utilitários de Navegação
  // =========================================================================

  @override
  bool isValidId(String? id) {
    return id != null && id.isNotEmpty && id.trim().isNotEmpty;
  }

  @override
  bool canGoBack() {
    try {
      return Get.routing.previous.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  @override
  String get currentRoute {
    try {
      return Get.currentRoute;
    } catch (e) {
      return '';
    }
  }

  @override
  dynamic get currentArguments {
    try {
      return Get.arguments;
    } catch (e) {
      return null;
    }
  }

  // =========================================================================
  // Métodos Privados
  // =========================================================================

  /// Executa navegação com tratamento de erro unificado
  void _executeNavigation(
    VoidCallback navigationAction,
    String successMessage,
    String errorMessage,
  ) {
    try {
      debugPrint('NavigationService: $successMessage');
      navigationAction();
    } catch (e) {
      debugPrint('NavigationService: $errorMessage - $e');
      _showError(errorMessage);
    }
  }

  /// Mostra erro ao usuário de forma consistente
  void _showError(String message) {
    try {
      Get.snackbar(
        'Erro de Navegação',
        message,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withValues(alpha: 0.8),
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
        margin: const EdgeInsets.all(16),
      );
    } catch (e) {
      debugPrint('NavigationService: Erro ao mostrar snackbar - $e');
    }
  }
}
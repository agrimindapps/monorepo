// Flutter imports:
import 'package:flutter/material.dart';
// Package imports:
import 'package:get/get.dart';

import '../../core/services/logging_service.dart';
// Project imports:
import '../core/navigation/i_navigation_service.dart';
import '../models/favorito_model.dart';
import 'navigation_input_validator.dart';

/// NavigationService seguro com validação e sanitização de inputs
/// Previne injection attacks e valida todas as navegações
class SecureNavigationService extends GetxService implements INavigationService {
  static SecureNavigationService get instance => Get.find<SecureNavigationService>();
  
  final NavigationInputValidator _validator = NavigationInputValidator.instance;
  
  // =========================================================================
  // Constantes de Rotas (validadas na whitelist)
  // =========================================================================
  
  static const String _defensivosDetailsRoute = '/receituagro/defensivos/detalhes';
  static const String _pragasDetailsRoute = '/receituagro/pragas/detalhes';
  static const String _diagnosticoRoute = '/receituagro/diagnostico';
  static const String _diagnosticoDetailsRoute = '/receituagro/diagnostico/detalhes';
  
  @override
  void onInit() {
    super.onInit();
    _initializeValidRoutes();
    LoggingService.info(
      'SecureNavigationService inicializado com validação de inputs',
      tag: 'SecureNavigationService',
    );
  }
  
  /// Registra rotas válidas no validador
  void _initializeValidRoutes() {
    final routes = [
      _defensivosDetailsRoute,
      _pragasDetailsRoute,
      _diagnosticoRoute,
      _diagnosticoDetailsRoute,
      '/receituagro/lista/defensivos',
      '/receituagro/lista/pragas',
      '/receituagro/lista/culturas',
      '/receituagro/favoritos',
      '/receituagro/config',
      '/receituagro/sobre',
      '/receituagro/comentarios',
      '/receituagro/pragas/cultura',
      '/receituagro/defensivos/agrupados',
      '/receituagro/home/pragas',
      '/receituagro/home/defensivos',
    ];
    
    for (final route in routes) {
      _validator.registerValidRoute(route);
    }
  }
  
  // =========================================================================
  // Navegação Segura para Detalhes
  // =========================================================================

  @override
  void navigateToDefensivoDetails(String defensivoId) {
    _secureNavigateToDetails(
      route: _defensivosDetailsRoute,
      id: defensivoId,
      context: 'defensivo_details',
      entityType: 'defensivo',
    );
  }

  @override
  void navigateToPragaDetails(String pragaId) {
    _secureNavigateWithMapArgs(
      route: _pragasDetailsRoute,
      arguments: {'idReg': pragaId},
      context: 'praga_details',
    );
  }

  @override
  void navigateToDiagnosticoDetails(String diagnosticoId) {
    _secureNavigateToDetails(
      route: _diagnosticoDetailsRoute,
      id: diagnosticoId,
      context: 'diagnostico_details',
      entityType: 'diagnóstico',
    );
  }
  
  /// Navegação segura para detalhes com validação completa
  void _secureNavigateToDetails({
    required String route,
    required String id,
    required String context,
    required String entityType,
  }) {
    try {
      // Validar ID
      final idResult = _validator.validateId(id, context: context);
      if (!idResult.isValid) {
        _handleValidationError(
          'ID de $entityType inválido: ${idResult.errorMessage}',
          context,
        );
        return;
      }
      
      // Validar rota
      final routeResult = _validator.validateRoute(route, context: context);
      if (!routeResult.isValid) {
        _handleValidationError(
          'Rota inválida: ${routeResult.errorMessage}',
          context,
        );
        return;
      }
      
      // Executar navegação segura
      _executeSecureNavigation(
        () => Get.toNamed(routeResult.value!, arguments: idResult.value),
        'Navegando para detalhes de $entityType: ${idResult.value}',
        'Erro ao abrir detalhes de $entityType',
        context,
      );
    } catch (e) {
      _handleNavigationException(e, context, 'navegação para detalhes de $entityType');
    }
  }
  
  /// Navegação segura com argumentos em Map
  void _secureNavigateWithMapArgs({
    required String route,
    required Map<String, dynamic> arguments,
    required String context,
  }) {
    try {
      // Validar navegação completa
      final validationResult = _validator.validateNavigation(route, arguments, context: context);
      if (!validationResult.isValid) {
        _handleValidationError(validationResult.errorMessage, context);
        return;
      }
      
      // Executar navegação segura
      _executeSecureNavigation(
        () => Get.toNamed(validationResult.route!, arguments: validationResult.arguments),
        'Navegando para: ${validationResult.route}',
        'Erro na navegação',
        context,
      );
    } catch (e) {
      _handleNavigationException(e, context, 'navegação com argumentos map');
    }
  }

  // =========================================================================
  // Navegação Genérica Segura
  // =========================================================================

  @override
  void navigateToRoute(String route, {dynamic arguments}) {
    _secureNavigate(route, arguments, 'generic_route');
  }

  @override
  void replaceWithRoute(String route, {dynamic arguments}) {
    _secureReplace(route, arguments, 'replace_route');
  }

  @override
  void navigateAndClearStack(String route, {dynamic arguments}) {
    _secureNavigateAndClear(route, arguments, 'clear_stack_route');
  }
  
  /// Navegação genérica segura
  void _secureNavigate(String? route, dynamic arguments, String context) {
    try {
      final validationResult = _validator.validateNavigation(route, arguments, context: context);
      if (!validationResult.isValid) {
        _handleValidationError(validationResult.errorMessage, context);
        return;
      }
      
      _executeSecureNavigation(
        () => Get.toNamed(validationResult.route!, arguments: validationResult.arguments),
        'Navegando para rota: ${validationResult.route}',
        'Erro na navegação para ${validationResult.route}',
        context,
      );
    } catch (e) {
      _handleNavigationException(e, context, 'navegação genérica');
    }
  }
  
  /// Substituição de rota segura
  void _secureReplace(String? route, dynamic arguments, String context) {
    try {
      final validationResult = _validator.validateNavigation(route, arguments, context: context);
      if (!validationResult.isValid) {
        _handleValidationError(validationResult.errorMessage, context);
        return;
      }
      
      _executeSecureNavigation(
        () => Get.offNamed(validationResult.route!, arguments: validationResult.arguments),
        'Substituindo por rota: ${validationResult.route}',
        'Erro ao substituir pela rota ${validationResult.route}',
        context,
      );
    } catch (e) {
      _handleNavigationException(e, context, 'substituição de rota');
    }
  }
  
  /// Navegação com limpeza de stack segura
  void _secureNavigateAndClear(String? route, dynamic arguments, String context) {
    try {
      final validationResult = _validator.validateNavigation(route, arguments, context: context);
      if (!validationResult.isValid) {
        _handleValidationError(validationResult.errorMessage, context);
        return;
      }
      
      _executeSecureNavigation(
        () => Get.offAllNamed(validationResult.route!, arguments: validationResult.arguments),
        'Navegando e limpando stack para: ${validationResult.route}',
        'Erro ao navegar e limpar stack para ${validationResult.route}',
        context,
      );
    } catch (e) {
      _handleNavigationException(e, context, 'navegação com limpeza de stack');
    }
  }

  // =========================================================================
  // Navegação com Dados Seguros
  // =========================================================================

  @override
  void navigateToPragaFromData(Map<dynamic, dynamic> data) {
    _secureNavigateFromData(data, 'fkIdPraga', 'praga', navigateToPragaDetails);
  }

  @override
  void navigateToDiagnosticoFromData(Map<dynamic, dynamic> data) {
    _secureNavigateFromData(data, 'idReg', 'diagnóstico', navigateToDiagnosticoDetails);
  }
  
  /// Navegação segura a partir de dados
  void _secureNavigateFromData(
    Map<dynamic, dynamic> data,
    String idKey,
    String entityType,
    Function(String) navigationFunction,
  ) {
    try {
      if (data.isEmpty) {
        _handleValidationError(
          'Dados vazios fornecidos para navegação de $entityType',
          '${entityType}_from_data',
        );
        return;
      }
      
      final id = data[idKey]?.toString();
      if (id == null || id.isEmpty) {
        _handleValidationError(
          'ID de $entityType não encontrado nos dados (chave: $idKey)',
          '${entityType}_from_data',
        );
        return;
      }
      
      // Validar o ID extraído
      final idResult = _validator.validateId(id, context: '${entityType}_from_data');
      if (!idResult.isValid) {
        _handleValidationError(
          'ID de $entityType inválido: ${idResult.errorMessage}',
          '${entityType}_from_data',
        );
        return;
      }
      
      // Executar navegação com ID validado
      navigationFunction(idResult.value!);
    } catch (e) {
      _handleNavigationException(e, '${entityType}_from_data', 'navegação a partir de dados');
    }
  }

  // =========================================================================
  // Navegação com Modelos de Favoritos Seguros
  // =========================================================================

  void navigateToDefensivoFromFavorite(FavoritoDefensivoModel defensivo) {
    try {
      final id = defensivo.id.toString();
      navigateToDefensivoDetails(id);
      
      LoggingService.info(
        'Navegação para defensivo favorito: $id',
        tag: 'SecureNavigationService',
      );
    } catch (e) {
      _handleNavigationException(e, 'favorite_defensivo', 'navegação para defensivo favorito');
    }
  }

  void navigateToPragaFromFavorite(FavoritoPragaModel praga) {
    try {
      final id = praga.id.toString();
      navigateToPragaDetails(id);
      
      LoggingService.info(
        'Navegação para praga favorita: $id',
        tag: 'SecureNavigationService',
      );
    } catch (e) {
      _handleNavigationException(e, 'favorite_praga', 'navegação para praga favorita');
    }
  }

  void navigateToDiagnosticoFromFavorite(FavoritoDiagnosticoModel diagnostico) {
    try {
      final id = diagnostico.id.toString();
      
      // Validar ID do diagnóstico
      final idResult = _validator.validateId(id, context: 'favorite_diagnostico');
      if (!idResult.isValid) {
        _handleValidationError(
          'ID de diagnóstico favorito inválido: ${idResult.errorMessage}',
          'favorite_diagnostico',
        );
        return;
      }
      
      // Usar rota específica para diagnóstico
      _executeSecureNavigation(
        () => Get.toNamed(_diagnosticoRoute, arguments: idResult.value),
        'Navegando para diagnóstico favorito: ${idResult.value}',
        'Erro ao abrir diagnóstico favorito',
        'favorite_diagnostico',
      );
    } catch (e) {
      _handleNavigationException(e, 'favorite_diagnostico', 'navegação para diagnóstico favorito');
    }
  }

  // =========================================================================
  // Utilitários de Navegação
  // =========================================================================

  @override
  bool isValidId(String? id) {
    final result = _validator.validateId(id, context: 'id_check');
    return result.isValid;
  }

  @override
  bool canGoBack() {
    try {
      return Get.routing.previous.isNotEmpty;
    } catch (e) {
      LoggingService.warning(
        'Erro ao verificar se pode voltar: $e',
        tag: 'SecureNavigationService',
      );
      return false;
    }
  }

  @override
  String get currentRoute {
    try {
      return Get.currentRoute;
    } catch (e) {
      LoggingService.warning(
        'Erro ao obter rota atual: $e',
        tag: 'SecureNavigationService',
      );
      return '';
    }
  }

  @override
  dynamic get currentArguments {
    try {
      return Get.arguments;
    } catch (e) {
      LoggingService.warning(
        'Erro ao obter argumentos atuais: $e',
        tag: 'SecureNavigationService',
      );
      return null;
    }
  }

  @override
  void goBack({dynamic result}) {
    try {
      Get.back(result: result);
      LoggingService.debug(
        'Voltando para página anterior',
        tag: 'SecureNavigationService',
      );
    } catch (e) {
      LoggingService.warning(
        'Erro ao voltar: $e',
        tag: 'SecureNavigationService',
      );
    }
  }
  
  /// Obtém estatísticas de validação
  Map<String, dynamic> getSecurityStats() {
    return _validator.getValidationStats();
  }
  
  /// Registra nova rota válida
  void registerSecureRoute(String route) {
    _validator.registerValidRoute(route);
  }

  // =========================================================================
  // Métodos Privados de Segurança
  // =========================================================================

  /// Executa navegação com tratamento de erro seguro
  void _executeSecureNavigation(
    VoidCallback navigationAction,
    String successMessage,
    String errorMessage,
    String context,
  ) {
    try {
      LoggingService.info(
        '$successMessage | Context: $context',
        tag: 'SecureNavigationService',
      );
      navigationAction();
    } catch (e) {
      _handleNavigationException(e, context, errorMessage);
    }
  }

  /// Trata erros de validação
  void _handleValidationError(String message, String context) {
    LoggingService.warning(
      'Validação falhou: $message | Context: $context',
      tag: 'SecureNavigationService:Validation',
    );
    
    _showSecurityError('Navegação inválida', message);
  }
  
  /// Trata exceções de navegação
  void _handleNavigationException(Object e, String context, String operation) {
    LoggingService.error(
      'Erro na $operation: $e | Context: $context',
      tag: 'SecureNavigationService:Exception',
    );
    
    _showSecurityError(
      'Erro de Navegação',
      'Não foi possível completar a navegação. Tente novamente.',
    );
  }

  /// Mostra erro de segurança ao usuário
  void _showSecurityError(String title, String message) {
    try {
      Get.snackbar(
        title,
        message,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withValues(alpha: 0.9),
        colorText: Colors.white,
        duration: const Duration(seconds: 4),
        margin: const EdgeInsets.all(16),
        icon: const Icon(Icons.security, color: Colors.white),
      );
    } catch (e) {
      LoggingService.error(
        'Erro ao mostrar snackbar de segurança: $e',
        tag: 'SecureNavigationService',
      );
    }
  }
}
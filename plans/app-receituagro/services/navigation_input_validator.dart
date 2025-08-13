// Dart imports:
import 'dart:convert';

// Flutter imports:
import 'package:flutter/foundation.dart';

// Project imports:
import '../../core/services/logging_service.dart';

/// Service para validação e sanitização de inputs de navegação
/// Previne ataques de injection e valida rotas/parâmetros
class NavigationInputValidator {
  // Singleton pattern
  static NavigationInputValidator? _instance;
  static NavigationInputValidator get instance => _instance ??= NavigationInputValidator._();
  NavigationInputValidator._();
  
  // Whitelist de rotas válidas
  static const Set<String> _validRoutes = {
    '/receituagro/defensivos/detalhes',
    '/receituagro/pragas/detalhes',
    '/receituagro/diagnostico',
    '/receituagro/diagnostico/detalhes',
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
  };
  
  // Padrões regex para validação de IDs
  static final RegExp _validIdPattern = RegExp(r'^[a-zA-Z0-9_-]{1,50}$');
  static final RegExp _sqlInjectionPattern = RegExp(
    r'(SELECT|INSERT|UPDATE|DELETE|DROP|CREATE|ALTER|UNION)',
    caseSensitive: false,
  );
  static final RegExp _xssPattern = RegExp(
    r'<[^>]*>|javascript:|data:|vbscript:|on\w+\s*=',
    caseSensitive: false,
  );
  static final RegExp _pathTraversalPattern = RegExp(r'\.\.(/|\\)|~');
  
  // Contador de tentativas suspeitas por sessão
  int _suspiciousAttempts = 0;
  static const int _maxSuspiciousAttempts = 10;
  
  /// Valida e sanitiza ID de navegação
  ValidationResult validateId(String? id, {String context = 'unknown'}) {
    try {
      // Null check
      if (id == null) {
        _logSuspiciousActivity('Null ID provided', context, id);
        return ValidationResult.invalid('ID não pode ser nulo');
      }
      
      // Empty check
      if (id.isEmpty) {
        _logSuspiciousActivity('Empty ID provided', context, id);
        return ValidationResult.invalid('ID não pode estar vazio');
      }
      
      // Trim e validar tamanho
      final trimmedId = id.trim();
      if (trimmedId.isEmpty) {
        _logSuspiciousActivity('ID only whitespace', context, id);
        return ValidationResult.invalid('ID não pode conter apenas espaços');
      }
      
      if (trimmedId.length > 50) {
        _logSuspiciousActivity('ID too long', context, id);
        return ValidationResult.invalid('ID muito longo (máximo 50 caracteres)');
      }
      
      // Verificar padrões suspeitos
      if (_containsSqlInjection(trimmedId)) {
        _logSuspiciousActivity('SQL injection attempt', context, id);
        return ValidationResult.invalid('ID contém caracteres não permitidos');
      }
      
      if (_containsXss(trimmedId)) {
        _logSuspiciousActivity('XSS attempt', context, id);
        return ValidationResult.invalid('ID contém caracteres não permitidos');
      }
      
      if (_containsPathTraversal(trimmedId)) {
        _logSuspiciousActivity('Path traversal attempt', context, id);
        return ValidationResult.invalid('ID contém caracteres não permitidos');
      }
      
      // Validar formato do ID
      if (!_validIdPattern.hasMatch(trimmedId)) {
        _logSuspiciousActivity('Invalid ID format', context, id);
        return ValidationResult.invalid(
          'ID deve conter apenas letras, números, underscores e hífens'
        );
      }
      
      // Sanitizar ID (extra safety)
      final sanitizedId = _sanitizeId(trimmedId);
      
      LoggingService.debug(
        'ID validado com sucesso: $sanitizedId',
        tag: 'NavigationInputValidator',
      );
      
      return ValidationResult.valid(sanitizedId);
    } catch (e) {
      LoggingService.error(
        'Erro na validação de ID: $e',
        tag: 'NavigationInputValidator',
      );
      return ValidationResult.invalid('Erro na validação do ID');
    }
  }
  
  /// Valida rota de navegação
  ValidationResult validateRoute(String? route, {String context = 'unknown'}) {
    try {
      if (route == null || route.isEmpty) {
        _logSuspiciousActivity('Empty route', context, route);
        return ValidationResult.invalid('Rota não pode estar vazia');
      }
      
      final trimmedRoute = route.trim();
      if (trimmedRoute.isEmpty) {
        _logSuspiciousActivity('Route only whitespace', context, route);
        return ValidationResult.invalid('Rota não pode conter apenas espaços');
      }
      
      // Verificar se a rota está na whitelist
      if (!_validRoutes.contains(trimmedRoute)) {
        _logSuspiciousActivity('Invalid route', context, route);
        return ValidationResult.invalid('Rota não autorizada');
      }
      
      // Verificar padrões suspeitos na rota
      if (_containsSqlInjection(trimmedRoute) || 
          _containsXss(trimmedRoute) ||
          _containsPathTraversal(trimmedRoute)) {
        _logSuspiciousActivity('Malicious route pattern', context, route);
        return ValidationResult.invalid('Rota contém caracteres suspeitos');
      }
      
      LoggingService.debug(
        'Rota validada: $trimmedRoute',
        tag: 'NavigationInputValidator',
      );
      
      return ValidationResult.valid(trimmedRoute);
    } catch (e) {
      LoggingService.error(
        'Erro na validação de rota: $e',
        tag: 'NavigationInputValidator',
      );
      return ValidationResult.invalid('Erro na validação da rota');
    }
  }
  
  /// Valida argumentos de navegação
  ValidationResult validateArguments(dynamic arguments, {String context = 'unknown'}) {
    try {
      if (arguments == null) {
        return ValidationResult.valid(null);
      }
      
      // Converter para JSON e validar tamanho
      String jsonString;
      try {
        jsonString = jsonEncode(arguments);
      } catch (e) {
        _logSuspiciousActivity('Invalid arguments format', context, arguments?.toString());
        return ValidationResult.invalid('Formato de argumentos inválido');
      }
      
      if (jsonString.length > 1024) {
        _logSuspiciousActivity('Arguments too large', context, jsonString);
        return ValidationResult.invalid('Argumentos muito grandes');
      }
      
      // Verificar padrões suspeitos
      if (_containsSqlInjection(jsonString) ||
          _containsXss(jsonString) ||
          _containsPathTraversal(jsonString)) {
        _logSuspiciousActivity('Malicious arguments', context, jsonString);
        return ValidationResult.invalid('Argumentos contêm dados suspeitos');
      }
      
      // Validar estrutura específica para maps
      if (arguments is Map<String, dynamic>) {
        return _validateArgumentsMap(arguments, context);
      } else if (arguments is String) {
        return validateId(arguments, context: '$context:string_arg');
      }
      
      LoggingService.debug(
        'Argumentos validados',
        tag: 'NavigationInputValidator',
      );
      
      return ValidationResult.valid(arguments);
    } catch (e) {
      LoggingService.error(
        'Erro na validação de argumentos: $e',
        tag: 'NavigationInputValidator',
      );
      return ValidationResult.invalid('Erro na validação dos argumentos');
    }
  }
  
  /// Valida navegação completa (rota + argumentos)
  NavigationValidationResult validateNavigation(String? route, dynamic arguments, {String context = 'unknown'}) {
    final routeResult = validateRoute(route, context: context);
    if (!routeResult.isValid) {
      return NavigationValidationResult.invalid(routeResult.errorMessage);
    }
    
    final argsResult = validateArguments(arguments, context: context);
    if (!argsResult.isValid) {
      return NavigationValidationResult.invalid(argsResult.errorMessage);
    }
    
    return NavigationValidationResult.valid(
      route: routeResult.value,
      arguments: argsResult.value,
    );
  }
  
  /// Registra uma nova rota válida (para extensibilidade)
  void registerValidRoute(String route) {
    if (route.isNotEmpty && !route.contains(' ') && route.startsWith('/')) {
      _validRoutes.add(route);
      LoggingService.info(
        'Nova rota registrada: $route',
        tag: 'NavigationInputValidator',
      );
    }
  }
  
  /// Obtém estatísticas de validação
  Map<String, dynamic> getValidationStats() {
    return {
      'valid_routes_count': _validRoutes.length,
      'suspicious_attempts': _suspiciousAttempts,
      'max_suspicious_threshold': _maxSuspiciousAttempts,
      'security_level': _suspiciousAttempts > _maxSuspiciousAttempts ? 'HIGH' : 'NORMAL',
    };
  }
  
  /// Reset das estatísticas (para uso em testes ou nova sessão)
  void resetStats() {
    _suspiciousAttempts = 0;
    LoggingService.info(
      'Estatísticas de validação resetadas',
      tag: 'NavigationInputValidator',
    );
  }
  
  // === MÉTODOS PRIVADOS ===
  
  ValidationResult _validateArgumentsMap(Map<String, dynamic> args, String context) {
    try {
      final sanitizedArgs = <String, dynamic>{};
      
      for (final entry in args.entries) {
        final key = entry.key;
        final value = entry.value;
        
        // Validar chave
        if (!_validIdPattern.hasMatch(key)) {
          _logSuspiciousActivity('Invalid argument key', context, key);
          return ValidationResult.invalid('Chave de argumento inválida: $key');
        }
        
        // Validar valor baseado no tipo
        if (value is String) {
          final idResult = validateId(value, context: '$context:$key');
          if (!idResult.isValid) {
            return ValidationResult.invalid('Valor inválido para $key: ${idResult.errorMessage}');
          }
          sanitizedArgs[key] = idResult.value;
        } else if (value == null || value is num || value is bool) {
          sanitizedArgs[key] = value;
        } else {
          _logSuspiciousActivity('Unsupported argument type', context, value.runtimeType.toString());
          return ValidationResult.invalid('Tipo de argumento não suportado para $key');
        }
      }
      
      return ValidationResult.valid(sanitizedArgs);
    } catch (e) {
      LoggingService.error('Erro na validação de mapa de argumentos: $e', tag: 'NavigationInputValidator');
      return ValidationResult.invalid('Erro na validação dos argumentos');
    }
  }
  
  bool _containsSqlInjection(String input) {
    return _sqlInjectionPattern.hasMatch(input);
  }
  
  bool _containsXss(String input) {
    return _xssPattern.hasMatch(input);
  }
  
  bool _containsPathTraversal(String input) {
    return _pathTraversalPattern.hasMatch(input);
  }
  
  String _sanitizeId(String id) {
    // Remove caracteres potencialmente perigosos que passaram pela regex
    return id.replaceAll('<', '').replaceAll('>', '').replaceAll('"', '').replaceAll("'", '').trim();
  }
  
  void _logSuspiciousActivity(String reason, String context, String? input) {
    _suspiciousAttempts++;
    
    final securityLevel = _suspiciousAttempts > _maxSuspiciousAttempts ? 'CRITICAL' : 'WARNING';
    
    LoggingService.warning(
      '[$securityLevel] Tentativa suspeita de navegação bloqueada: $reason | Context: $context | Input: ${input ?? 'null'} | Attempts: $_suspiciousAttempts',
      tag: 'NavigationInputValidator:Security',
    );
    
    if (_suspiciousAttempts > _maxSuspiciousAttempts && !kDebugMode) {
      // Em produção, poderia enviar alerta ou tomar medidas mais rigorosas
      LoggingService.error(
        'SECURITY ALERT: Muitas tentativas suspeitas de navegação detectadas ($_suspiciousAttempts)',
        tag: 'NavigationInputValidator:SecurityAlert',
      );
    }
  }
}

/// Resultado da validação simples
class ValidationResult {
  final bool isValid;
  final dynamic value;
  final String errorMessage;
  
  const ValidationResult._(this.isValid, this.value, this.errorMessage);
  
  factory ValidationResult.valid(dynamic value) => 
      ValidationResult._(true, value, '');
      
  factory ValidationResult.invalid(String errorMessage) => 
      ValidationResult._(false, null, errorMessage);
}

/// Resultado da validação de navegação completa
class NavigationValidationResult {
  final bool isValid;
  final String? route;
  final dynamic arguments;
  final String errorMessage;
  
  const NavigationValidationResult._(this.isValid, this.route, this.arguments, this.errorMessage);
  
  factory NavigationValidationResult.valid({String? route, dynamic arguments}) =>
      NavigationValidationResult._(true, route, arguments, '');
      
  factory NavigationValidationResult.invalid(String errorMessage) =>
      NavigationValidationResult._(false, null, null, errorMessage);
}
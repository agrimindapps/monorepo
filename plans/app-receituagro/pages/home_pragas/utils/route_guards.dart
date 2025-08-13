// Flutter imports:
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:get/get.dart';

// Project imports:
import '../models/navigation_args.dart';

/// Mixin for controllers that need route argument validation
mixin RouteGuardMixin {
  /// Validates and extracts navigation arguments from GetX
  T getValidatedArgs<T extends NavigationArgs>(
    T Function(Map<String, dynamic>?) fromMapFunction,
    String routeName, {
    T? defaultArgs,
    VoidCallback? onError,
  }) {
    try {
      final args = Get.arguments as Map<String, dynamic>?;
      
      if (kDebugMode) {
      }
      
      final navigationArgs = NavigationHelper.getArgs(
        args,
        fromMapFunction,
        routeName,
      );
      
      if (kDebugMode) {
      }
      
      return navigationArgs;
      
    } catch (e) {
      if (kDebugMode) {
      }
      
      // Call error handler if provided
      onError?.call();
      
      // Return default args if provided, otherwise rethrow
      if (defaultArgs != null) {
        if (kDebugMode) {
        }
        return defaultArgs;
      }
      
      rethrow;
    }
  }
  
  /// Safely gets optional arguments without throwing errors
  T? getOptionalArgs<T extends NavigationArgs>(
    T Function(Map<String, dynamic>?) fromMapFunction,
    String routeName,
  ) {
    try {
      final args = Get.arguments as Map<String, dynamic>?;
      
      // Return null if no arguments provided
      if (args == null || args.isEmpty) {
        return null;
      }
      
      return NavigationHelper.getArgs(
        args,
        fromMapFunction,
        routeName,
      );
      
    } catch (e) {
      if (kDebugMode) {
      }
      return null;
    }
  }
  
  /// Validates arguments and provides fallback navigation if validation fails
  void validateOrFallback<T extends NavigationArgs>(
    T Function(Map<String, dynamic>?) fromMapFunction,
    String routeName,
    VoidCallback fallbackAction,
  ) {
    try {
      getValidatedArgs(fromMapFunction, routeName);
    } catch (e) {
      if (kDebugMode) {
      }
      fallbackAction();
    }
  }
}

/// Route guard for pages that receive PragaDetailsArgs
mixin PragaDetailsRouteGuard on RouteGuardMixin {
  PragaDetailsArgs getPragaDetailsArgs() {
    return getValidatedArgs(
      PragaDetailsArgs.fromMap,
      'PragaDetails',
      defaultArgs: const PragaDetailsArgs(idReg: ''), // Will fail validation, but provides structure
      onError: () => _handleInvalidPragaDetailsArgs(),
    );
  }
  
  PragaDetailsArgs? getOptionalPragaDetailsArgs() {
    return getOptionalArgs(
      PragaDetailsArgs.fromMap,
      'PragaDetails',
    );
  }
  
  void _handleInvalidPragaDetailsArgs() {
    if (kDebugMode) {
    }
    // Could redirect to pragas home or show error
    // Get.offNamed(AppRoutes.pragasHome);
  }
}

/// Route guard for pages that receive PragasListArgs
mixin PragasListRouteGuard on RouteGuardMixin {
  PragasListArgs getPragasListArgs() {
    return getValidatedArgs(
      PragasListArgs.fromMap,
      'PragasList',
      defaultArgs: const PragasListArgs(tipoPraga: '1'), // Default to insects
      onError: () => _handleInvalidPragasListArgs(),
    );
  }
  
  PragasListArgs? getOptionalPragasListArgs() {
    return getOptionalArgs(
      PragasListArgs.fromMap,
      'PragasList',
    );
  }
  
  void _handleInvalidPragasListArgs() {
    if (kDebugMode) {
    }
  }
}

/// Route guard for pages that receive CulturasListArgs
mixin CulturasListRouteGuard on RouteGuardMixin {
  CulturasListArgs getCulturasListArgs() {
    return getValidatedArgs(
      CulturasListArgs.fromMap,
      'CulturasList',
      defaultArgs: const CulturasListArgs(),
      onError: () => _handleInvalidCulturasListArgs(),
    );
  }
  
  CulturasListArgs? getOptionalCulturasListArgs() {
    return getOptionalArgs(
      CulturasListArgs.fromMap,
      'CulturasList',
    );
  }
  
  void _handleInvalidCulturasListArgs() {
    if (kDebugMode) {
    }
  }
}

/// Route guard for pages that receive PragasPorCulturaArgs
mixin PragasPorCulturaRouteGuard on RouteGuardMixin {
  PragasPorCulturaArgs getPragasPorCulturaArgs() {
    return getValidatedArgs(
      PragasPorCulturaArgs.fromMap,
      'PragasPorCultura',
      defaultArgs: const PragasPorCulturaArgs(
        culturaId: 'default',
        culturaNome: 'Cultura Padrão',
      ),
      onError: () => _handleInvalidPragasPorCulturaArgs(),
    );
  }
  
  PragasPorCulturaArgs? getOptionalPragasPorCulturaArgs() {
    return getOptionalArgs(
      PragasPorCulturaArgs.fromMap,
      'PragasPorCultura',
    );
  }
  
  void _handleInvalidPragasPorCulturaArgs() {
    if (kDebugMode) {
    }
    // Could redirect to culturas list or show error
    // Get.offNamed(AppRoutes.culturasListar);
  }
}

/// Global route guard that can be used in bindings or middleware
class GlobalRouteGuard {
  /// Validates route arguments before page initialization
  static bool validateRouteArgs(String routeName, dynamic arguments) {
    try {
      if (kDebugMode) {
      }
      
      // Convert arguments to Map if needed
      final Map<String, dynamic>? argsMap = 
          arguments is Map<String, dynamic> ? arguments : null;
      
      // Route-specific validation
      switch (routeName) {
        case '/receituagro/pragas/detalhes':
          PragaDetailsArgs.fromMap(argsMap);
          break;
        case '/receituagro/pragas/listar':
          PragasListArgs.fromMap(argsMap);
          break;
        case '/receituagro/culturas/listar':
          CulturasListArgs.fromMap(argsMap);
          break;
        case '/receituagro/pragas/culturas':
          PragasPorCulturaArgs.fromMap(argsMap);
          break;
        default:
          // No validation needed for other routes
          break;
      }
      
      if (kDebugMode) {
      }
      return true;
      
    } catch (e) {
      if (kDebugMode) {
      }
      return false;
    }
  }
  
  /// Provides corrected arguments if validation fails
  static Map<String, dynamic>? getCorrectedArgs(String routeName, dynamic arguments) {
    try {
      validateRouteArgs(routeName, arguments);
      return arguments is Map<String, dynamic> ? arguments : null;
    } catch (e) {
      if (kDebugMode) {
      }
      
      // Provide default arguments for known routes
      switch (routeName) {
        case '/receituagro/pragas/detalhes':
          return const PragaDetailsArgs(idReg: '1').toMap(); // Default to first praga
        case '/receituagro/pragas/listar':
          return const PragasListArgs(tipoPraga: '1').toMap(); // Default to insects
        case '/receituagro/culturas/listar':
          return const CulturasListArgs().toMap();
        case '/receituagro/pragas/culturas':
          return const PragasPorCulturaArgs(
            culturaId: 'default',
            culturaNome: 'Cultura Padrão',
          ).toMap(); // Default cultura
        default:
          return null;
      }
    }
  }
}

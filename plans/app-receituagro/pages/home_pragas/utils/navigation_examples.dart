// Flutter imports:
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

// Package imports:
import 'package:get/get.dart';

// Project imports:
import '../../../router.dart';
import '../models/navigation_args.dart';

/// Examples of how to use the new typed navigation system
class NavigationExamples {
  
  /// Example 1: Basic navigation to praga details
  static void navigateToPragaDetailsBasic(String pragaId) {
    final args = PragaDetailsArgs(
      idReg: pragaId,
      source: 'example_basic',
    );
    
    // Validate before navigation
    if (NavigationHelper.validateNavigation(args, AppRoutes.pragasDetalhes)) {
      final context = Get.context;
      if (context != null && Navigator.of(context).canPop()) {
        // Usa Navigator local se disponível
        Navigator.of(context).pushNamed(AppRoutes.pragasDetalhes, arguments: args.toMap());
      } else {
        // Fallback para GetX se Navigator local não estiver disponível
        Get.toNamed(AppRoutes.pragasDetalhes, arguments: args.toMap());
      }
    }
  }
  
  /// Example 2: Navigation with error handling
  static void navigateToPragaDetailsWithErrorHandling(String pragaId) {
    try {
      final args = PragaDetailsArgs(
        idReg: pragaId,
        source: 'example_with_error_handling',
      );
      
      args.validate();
      NavigationHelper.logNavigationAttempt(AppRoutes.pragasDetalhes, args);
      
      final context = Get.context;
      if (context != null && Navigator.of(context).canPop()) {
        // Usa Navigator local se disponível
        Navigator.of(context).pushNamed(AppRoutes.pragasDetalhes, arguments: args.toMap());
      } else {
        // Fallback para GetX se Navigator local não estiver disponível
        Get.toNamed(AppRoutes.pragasDetalhes, arguments: args.toMap());
      }
      
    } catch (e) {
      if (kDebugMode) {
      }
      // Could show user-friendly error message
      _showNavigationError('Não foi possível abrir os detalhes da praga');
    }
  }
  
  /// Example 3: Navigation to pragas list with filters
  static void navigateToPragasListWithFilters({
    required String tipoPraga,
    String? cultura,
    String? searchTerm,
  }) {
    final args = PragasListArgs(
      tipoPraga: tipoPraga,
      filterCultura: cultura,
      searchTerm: searchTerm,
      source: 'example_with_filters',
    );
    
    if (NavigationHelper.validateNavigation(args, AppRoutes.pragasListar)) {
      final context = Get.context;
      if (context != null && Navigator.of(context).canPop()) {
        // Usa Navigator local se disponível
        Navigator.of(context).pushNamed(AppRoutes.pragasListar, arguments: args.toMap());
      } else {
        // Fallback para GetX se Navigator local não estiver disponível
        Get.toNamed(AppRoutes.pragasListar, arguments: args.toMap());
      }
    }
  }
  
  static void _showNavigationError(String message) {
    if (kDebugMode) {
      print('🚨 Navigation Error: $message');
    }
    // In a real app, you might show a SnackBar or Dialog
    // Get.snackbar('Erro de Navegação', message);
  }
}

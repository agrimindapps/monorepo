// Flutter imports:
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:get/get.dart';

// Project imports:
import '../../../../repository/veiculos_repository.dart';
import '../../veiculos_page/controller/veiculos_page_controller.dart';
import '../controller/veiculos_cadastro_form_controller.dart';
import '../services/veiculo_persistence_service.dart';

/// Binding centralizado para o módulo de veículos
///
/// Implementa um padrão consistente de injeção de dependência que:
/// - Evita registros duplicados
/// - Garante ordem correta de inicialização
/// - Fornece cleanup automático
/// - Previne vazamentos de memória
class VeiculosModuleBinding extends Bindings {
  @override
  void dependencies() {
    _registerRepositories();
    _registerCoreControllers();
    _registerFormControllers();
    _registerServices();
  }

  /// Registra repositórios base (camada de dados)
  void _registerRepositories() {
    if (!Get.isRegistered<VeiculosRepository>()) {
      Get.lazyPut<VeiculosRepository>(
        () => VeiculosRepository(),
        fenix: false, // Permite garbage collection quando não usado
      );
    }
  }

  /// Registra controllers principais do sistema
  void _registerCoreControllers() {
    // Controller de listagem e navegação (deve ser registrado primeiro)
    if (!Get.isRegistered<VeiculosPageController>()) {
      Get.lazyPut<VeiculosPageController>(
        () => VeiculosPageController(),
        fenix: false,
      );
    }
  }

  /// Registra controllers específicos do formulário
  void _registerFormControllers() {
    // Controller do formulário de cadastro (sempre novo para cada uso)
    Get.lazyPut<VeiculosCadastroFormController>(
      () => VeiculosCadastroFormController(),
      fenix: false,
    );
  }

  /// Registra services especializados
  void _registerServices() {
    // Service de persistência (singleton para cache de operações)
    if (!Get.isRegistered<VeiculoPersistenceService>()) {
      Get.lazyPut<VeiculoPersistenceService>(
        () => VeiculoPersistenceService(
          repository: Get.find<VeiculosRepository>(),
        ),
        fenix: false,
      );
    }
  }

  /// Remove todas as dependências do módulo
  static void dispose() {
    _disposeSafely<VeiculosCadastroFormController>();
    _disposeSafely<VeiculoPersistenceService>();
    _disposeSafely<VeiculosPageController>();
    _disposeSafely<VeiculosRepository>();
  }

  /// Helper para remoção segura de dependências
  static void _disposeSafely<T>() {
    if (Get.isRegistered<T>()) {
      try {
        Get.delete<T>();
      } catch (e) {
        // Log error but don't fail - permite cleanup parcial
        debugPrint('Warning: Failed to dispose ${T.toString()}: $e');
      }
    }
  }

  /// Verifica se todas as dependências estão registradas
  static bool isFullyInitialized() {
    return Get.isRegistered<VeiculosRepository>() &&
        Get.isRegistered<VeiculosPageController>();
  }

  /// Força re-inicialização de todas as dependências
  static void reinitialize() {
    dispose();
    VeiculosModuleBinding().dependencies();
  }

  /// Helper para diagnóstico de dependências
  static Map<String, bool> getDependencyStatus() {
    return {
      'VeiculosRepository': Get.isRegistered<VeiculosRepository>(),
      'VeiculosPageController': Get.isRegistered<VeiculosPageController>(),
      'VeiculosCadastroFormController':
          Get.isRegistered<VeiculosCadastroFormController>(),
      'VeiculoPersistenceService':
          Get.isRegistered<VeiculoPersistenceService>(),
    };
  }
}

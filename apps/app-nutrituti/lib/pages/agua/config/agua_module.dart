// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../views/agua_page.dart';

/// DEPRECATED: Este módulo GetX está sendo substituído por Riverpod providers
/// Classe responsável por inicializar e prover acesso ao módulo de água
@Deprecated('Use Riverpod providers instead. Will be removed after migration.')
class AguaModule {
  /// Inicializa o módulo de água, registrando controllers e serviços necessários
  @Deprecated('Use Riverpod providers instead')
  static Future<void> initialize() async {
    // REMOVED: AguaRepository.initialize() - method doesn't exist
    // TODO: Migrar para Riverpod provider
    // Get.lazyPut<AguaController>(() => AguaController());
  }

  /// Retorna a página principal do módulo de água
  static Widget get page => const AguaPage();

  // REMOVED: GetX controller access
  // Use Riverpod provider ref.read() instead
  // static AguaController get controller => Get.find<AguaController>();
}

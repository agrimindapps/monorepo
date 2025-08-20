// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:get/get.dart';

// Project imports:
import '../controllers/agua_controller.dart';
import '../repository/agua_repository.dart';
import '../views/agua_page.dart';

/// Classe responsável por inicializar e prover acesso ao módulo de água
class AguaModule {
  /// Inicializa o módulo de água, registrando controllers e serviços necessários
  static Future<void> initialize() async {
    // Inicializar o repositório
    await AguaRepository.initialize();

    // Registrar o controller como lazyPut para ser inicializado quando necessário
    Get.lazyPut<AguaController>(() => AguaController());
  }

  /// Retorna a página principal do módulo de água
  static Widget get page => const AguaPage();

  /// Permite acessar o controller de água de qualquer lugar do aplicativo
  static AguaController get controller => Get.find<AguaController>();
}

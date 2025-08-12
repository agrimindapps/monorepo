// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:get/get.dart';

// Project imports:
import '../pages/cadastros/despesas_page/controller/despesas_page_controller.dart';
import '../repository/despesas_repository.dart';
import '../repository/veiculos_repository.dart';

/// Classe de utilidade para acessar os controllers do módulo Gasometer
/// de forma segura, exibindo mensagens de erro se necessário
class GasometerControllers {
  static DespesasPageController getDespesasController(BuildContext context) {
    try {
      return Get.find<DespesasPageController>();
    } catch (e) {
      // Fallback para quando o controller não foi registrado corretamente
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Erro ao obter DespesasController. Verifique a inicialização.'),
          backgroundColor: Colors.red,
        ),
      );

      // Registra o controller com dependências
      // Isso é apenas um fallback temporário
      Get.lazyPut<DespesasRepository>(() => DespesasRepository());
      Get.lazyPut<VeiculosRepository>(() => VeiculosRepository());

      Get.put(DespesasPageController());

      return Get.find<DespesasPageController>();
    }
  }
}

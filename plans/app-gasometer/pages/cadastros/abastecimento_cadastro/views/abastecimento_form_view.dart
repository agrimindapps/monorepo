// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:get/get.dart';

// Project imports:
import '../controller/abastecimento_form_controller.dart';
import '../widgets/info_section.dart';
import '../widgets/observacao_section.dart';
import '../widgets/valores_section.dart';

class AbastecimentoFormView extends StatelessWidget {
  const AbastecimentoFormView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AbastecimentoFormController>();

    return Obx(() {
      if (!controller.isInitialized) {
        return const Center(child: CircularProgressIndicator());
      }

      final veiculo = controller.formModel.veiculo;
      final veiculoId = controller.formModel.veiculoId;

      if (veiculoId.isEmpty) {
        return const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.warning, size: 48, color: Colors.orange),
              SizedBox(height: 16),
              Text('Nenhum veículo selecionado.'),
              Text('Selecione um veículo primeiro.'),
            ],
          ),
        );
      }

      if (veiculo == null) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              const Text('Veículo não encontrado.'),
              Text('ID: $veiculoId'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => controller.reloadVeiculo(),
                child: const Text('Tentar novamente'),
              ),
            ],
          ),
        );
      }

      return Form(
        key: controller.formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InfoSectionWidget(controller: controller),
              ValoresSectionWidget(controller: controller),
              const SizedBox(height: 8),
              ObservacaoSectionWidget(controller: controller),
            ],
          ),
        ),
      );
    });
  }
}

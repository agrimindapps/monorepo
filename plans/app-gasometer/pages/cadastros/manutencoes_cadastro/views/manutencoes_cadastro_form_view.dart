// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:get/get.dart';

// Project imports:
import '../controller/manutencoes_cadastro_form_controller.dart';
import '../widgets/configuracoes_section.dart';
import '../widgets/custos_data_section.dart';
import '../widgets/informacoes_basicas_section.dart';

class ManutencoesCadastroFormView extends StatelessWidget {
  const ManutencoesCadastroFormView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ManutencoesCadastroFormController>();

    return Obx(() {
      if (!controller.isInitialized) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      }

      final veiculoId = controller.veiculoId.value;

      if (veiculoId.isEmpty) {
        return const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.warning_amber_rounded, size: 48, color: Colors.orange),
              SizedBox(height: 16),
              Text(
                'Nenhum veículo selecionado',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Selecione um veículo primeiro',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        );
      }

      return Form(
        key: controller.formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InformacoesBasicasSectionWidget(controller: controller),
              const SizedBox(height: 16),
              CustosDataSectionWidget(controller: controller),
              const SizedBox(height: 16),
              ConfiguracoesSectionWidget(controller: controller),
            ],
          ),
        ),
      );
    });
  }

}

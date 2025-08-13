// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:get/get.dart';

// Project imports:
import '../controller/despesas_cadastro_form_controller.dart';
import '../widgets/despesa_info_section.dart';
import '../widgets/despesa_valor_section.dart';
import '../widgets/despesa_descricao_section.dart';

class DespesaCadastroFormView extends StatelessWidget {
  const DespesaCadastroFormView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<DespesaCadastroFormController>();

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
              Icon(
                Icons.warning_amber_rounded,
                size: 48,
                color: Colors.orange,
              ),
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
              DespesaInfoSectionWidget(controller: controller),
              const SizedBox(height: 16),
              DespesaValorSectionWidget(controller: controller),
              const SizedBox(height: 16),
              DespesaDescricaoSectionWidget(controller: controller),
            ],
          ),
        ),
      );
    });
  }

}

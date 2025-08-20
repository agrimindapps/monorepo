// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:get/get.dart';

// Project imports:
import '../controller/previsao_simples_controller.dart';
import '../widgets/previsao_simples/input_fields_widget.dart';
import '../widgets/previsao_simples/result_card_widget.dart';

class PrevisaoSimplesPage extends StatelessWidget {
  const PrevisaoSimplesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<PrevisaoSimplesController>(
      builder: (controller) {
        return SingleChildScrollView(
          child: Column(
            children: [
              PrevisaoSimplesInputFields(controller: controller),
              if (controller.calculado)
                PrevisaoSimplesResultCard(model: controller.model),
            ],
          ),
        );
      },
    );
  }
}

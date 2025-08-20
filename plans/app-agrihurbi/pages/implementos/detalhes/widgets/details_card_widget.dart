// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:get/get.dart';

// Project imports:
import '../controller/implementos_detalhes_controller.dart';

class DetailsCardWidget extends GetView<ImplementosDetalhesController> {
  const DetailsCardWidget({super.key});

  Widget _buildInfoSection({
    required String label,
    required String content,
    bool showDivider = true,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 20)),
        const SizedBox(height: 10),
        Text(content, style: const TextStyle(fontSize: 16)),
        if (showDivider) const Divider(),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Obx(() {
          final implemento = controller.implemento.value;
          if (implemento == null) return const SizedBox.shrink();

          return const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Futuros campos podem ser adicionados aqui
              // _buildInfoSection(
              //   label: 'Categoria',
              //   content: implemento.categoria ?? 'Não informada',
              //   showDivider: true,
              // ),
            ],
          );
        }),
      ),
    );
  }
}

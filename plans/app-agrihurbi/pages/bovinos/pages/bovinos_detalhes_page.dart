// Package imports:

// Flutter imports:
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../models/bovino_class.dart';
// Project imports:
import '../../../widgets/page_header_widget.dart';
import '../detalhes/controllers/bovino_detalhes_controller.dart';
import '../detalhes/widgets/bovino_actions.dart';
import '../detalhes/widgets/bovino_image_card.dart';
import '../detalhes/widgets/bovino_info_card.dart';

class BovinosDetalhesPage extends GetView<BovinoDetalhesController> {
  const BovinosDetalhesPage({super.key});

  Future<void> _handleRemove(String idReg) async {
    final bool success = await controller.removerBovino(idReg);
    if (success) {
      Get.back();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Obx(() {
                final bovino = controller.bovino;
                return PageHeaderWidget(
                  title: 'Detalhes do Bovino',
                  subtitle: bovino.value['nomeComum'] ?? 'Carregando...',
                  icon: Icons.pets,
                  showBackButton: true,
                  actions: [
                    if (bovino.value.isNotEmpty == true)
                      BovinoActions(
                        idReg: bovino.value['id'] ?? '',
                        onRemove: _handleRemove,
                      ),
                  ],
                );
              }),
            ),
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value == true) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (controller.error.isNotEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          controller.error.value,
                          style: const TextStyle(color: Colors.red),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: controller.clearError,
                          child: const Text('Tentar Novamente'),
                        ),
                      ],
                    ),
                  );
                }

                final bovino = controller.bovino;
                if (bovino.value.isEmpty) return const SizedBox.shrink();

                return Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(5, 0, 5, 0),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        BovinoImageCard(bovino: BovinoClass.fromMap(bovino.value)),
                        const SizedBox(height: 10),
                        BovinoInfoCard(bovino: BovinoClass.fromMap(bovino.value)),
                        const SizedBox(height: 10),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

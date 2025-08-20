// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:get/get.dart';

// Project imports:
import '../../../repository/bulas_repository.dart';
import '../../../widgets/page_header_widget.dart';
import 'controller/bulas_detalhes_controller.dart';
import 'widgets/bula_content_widget.dart';

class BulasDetalhesPage extends StatelessWidget {
  final String idReg;

  const BulasDetalhesPage({
    super.key,
    required this.idReg,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(
      BulasDetalhesController(
        repository: BulasRepository(),
        idReg: idReg,
      ),
    );

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Obx(() {
                return PageHeaderWidget(
                  title: 'Detalhes da Bula',
                  subtitle: controller.isLoading
                      ? 'Carregando...'
                      : controller.bula?.descricao ?? '',
                  icon: Icons.medical_information,
                  showBackButton: true,
                  actions: [
                    IconButton(
                      onPressed: controller.navigateToEdit,
                      icon:
                          const Icon(Icons.edit, size: 30, color: Colors.white),
                    ),
                  ],
                );
              }),
            ),
            Expanded(
              child: Obx(() {
                if (controller.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (controller.error.isNotEmpty) {
                  return Center(
                    child: Text(
                      controller.error,
                      style: const TextStyle(color: Colors.red),
                    ),
                  );
                }

                return BulaContentWidget(controller: controller);
              }),
            ),
          ],
        ),
      ),
    );
  }
}

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:get/get.dart';

// Project imports:
import '../../../../core/services/info_device_service.dart';
import '../../../repository/equinos_repository.dart';
import '../../../widgets/page_header_widget.dart';
import 'controllers/equinos_detalhes_controller.dart';
import 'widgets/equino_image_card_widget.dart';
import 'widgets/equino_info_card_widget.dart';

class EquinosDetalhesPage extends GetView<EquinosDetalhesController> {
  const EquinosDetalhesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Obx(() {
                final equino = EquinoRepository().mapEquinos.value;
                return PageHeaderWidget(
                  title: 'Detalhes do Equino',
                  subtitle: controller.isLoading.value
                      ? 'Carregando...'
                      : equino.nomeComum,
                  icon: Icons.pets,
                  showBackButton: true,
                  actions: [
                    if (!InfoDeviceService().isProduction.value)
                      IconButton(
                        onPressed: controller.navigateToEdit,
                        icon: const Icon(Icons.edit,
                            size: 24, color: Colors.white),
                      ),
                  ],
                );
              }),
            ),
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (controller.errorMessage.value.isNotEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: 64,
                            color: Colors.red.shade400,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            controller.errorMessage.value,
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.red.shade600,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: controller.carregarDados,
                            child: const Text('Tentar Novamente'),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const EquinoImageCard(),
                        const SizedBox(height: 10),
                        _buildBasicInfoCard(),
                        const SizedBox(height: 10),
                        _buildDetailsCard(),
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

  Widget _buildBasicInfoCard() {
    return Obx(() {
      final equino = EquinoRepository().mapEquinos.value;
      return EquinoInfoCard(
        sections: [
          EquinoInfoSection(
            label: 'Raça',
            content: equino.nomeComum,
          ),
          EquinoInfoSection(
            label: 'País Origem',
            content: equino.paisOrigem,
            showDivider: false,
          ),
        ],
      );
    });
  }

  Widget _buildDetailsCard() {
    return Obx(() {
      final equino = EquinoRepository().mapEquinos.value;
      return EquinoInfoCard(
        sections: [
          EquinoInfoSection(
            label: 'Histórico',
            content: equino.historico,
          ),
          EquinoInfoSection(
            label: 'Temperamento',
            content: equino.temperamento,
          ),
          EquinoInfoSection(
            label: 'Pelagem',
            content: equino.pelagem,
          ),
          EquinoInfoSection(
            label: 'Uso',
            content: equino.uso,
          ),
          EquinoInfoSection(
            label: 'Influências',
            content: equino.influencias,
          ),
          EquinoInfoSection(
            label: 'Altura',
            content: equino.altura,
          ),
          EquinoInfoSection(
            label: 'Peso',
            content: equino.peso,
            showDivider: false,
          ),
        ],
      );
    });
  }
}

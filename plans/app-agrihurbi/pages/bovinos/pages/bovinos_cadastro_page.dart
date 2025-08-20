// Flutter imports:
import 'dart:io';

import 'package:flutter/material.dart';
// Package imports:
import 'package:get/get.dart';

// Project imports:
import '../../../widgets/page_header_widget.dart';
import '../cadastro/controllers/bovinos_cadastro_controller.dart';
import '../cadastro/widgets/bovino_form_fields_widget.dart';
import '../cadastro/widgets/bovino_image_selector_widget.dart';

class BovinosCadastroPage extends GetView<BovinosCadastroController> {
  const BovinosCadastroPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Obx(() => PageHeaderWidget(
                    title: controller.id.isEmpty
                        ? 'Novo Bovino'
                        : 'Editar Bovino',
                    subtitle: 'Cadastro de animal',
                    icon: Icons.pets,
                    showBackButton: true,
                    actions: [
                      IconButton(
                        onPressed: controller.isLoading == true
                            ? null
                            : controller.salvarRegistro,
                        icon: const Icon(Icons.save, color: Colors.white),
                      ),
                    ],
                  )),
            ),
            Expanded(
              child: Obx(() {
                if (controller.isLoading == true) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const CircularProgressIndicator(),
                        const SizedBox(height: 16),
                        Text(
                          controller.id.isEmpty
                              ? '🐄 Preparando cadastro...'
                              : '🐄 Carregando dados do bovino...',
                          style: Theme.of(context).textTheme.titleMedium,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                }

                if (controller.error.isNotEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.error_outline,
                            size: 64,
                            color: Colors.red,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Ops! Algo deu errado',
                            style: Theme.of(context)
                                .textTheme
                                .headlineSmall
                                ?.copyWith(
                                  color: Colors.red,
                                  fontWeight: FontWeight.bold,
                                ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            controller.error.value,
                            style: Theme.of(context).textTheme.bodyMedium,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 24),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ElevatedButton.icon(
                                onPressed: controller.clearError,
                                icon: const Icon(Icons.refresh),
                                label: const Text('Tentar Novamente'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue,
                                  foregroundColor: Colors.white,
                                ),
                              ),
                              const SizedBox(width: 16),
                              TextButton.icon(
                                onPressed: () => Get.back(),
                                icon: const Icon(Icons.arrow_back),
                                label: const Text('Voltar'),
                              ),
                            ],
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
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Obx(() => BovinoImageSelector(
                                  isMiniatura: false,
                                  onTap: controller.selecionarImagens,
                                  imageFile: controller.images.isNotEmpty
                                      ? File(controller.images[0])
                                      : null,
                                  label: 'Imagens',
                                )),
                            Obx(() => BovinoImageSelector(
                                  isMiniatura: true,
                                  onTap: controller.selecionarMiniatura,
                                  imageFile: controller.imageMiniatura.isNotEmpty ? File(controller.imageMiniatura.value) : null,
                                  label: 'Miniatura',
                                )),
                          ],
                        ),
                        Obx(() => BovinoFormContent(
                              formKey: controller.formKey,
                              nomeComum: controller.nomeComum,
                              paisOrigem: controller.paisOrigem,
                              status: true,
                              tipoAnimal: controller.tipoAnimal,
                              origem: controller.origem,
                              caracteristicas:
                                  controller.caracteristicas,
                              raca: controller.raca,
                              aptidao: controller.aptidao,
                              tags: controller.tags,
                              sistemaCriacao: controller.sistemaCriacao,
                              finalidade: controller.finalidade,
                              onNomeComumChanged: controller.updateNomeComum,
                              onPaisOrigemChanged: controller.updatePaisOrigem,
                              onStatusChanged: (value) => controller.updateStatus(value.toString() ?? ''),
                              onTipoAnimalChanged: controller.updateTipoAnimal,
                              onOrigemChanged: controller.updateOrigem,
                              onCaracteristicasChanged:
                                  controller.updateCaracteristicas,
                              onRacaChanged: controller.updateRaca,
                              onAptidaoChanged: controller.updateAptidao,
                              onTagsChanged: controller.updateTags,
                              onSistemaCriacaoChanged:
                                  controller.updateSistemaCriacao,
                              onFinalidadeChanged: controller.updateFinalidade,
                            )),
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

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:get/get.dart';

// Project imports:
import '../../../widgets/page_header_widget.dart';
import 'controllers/equinos_cadastro_controller.dart';
import 'widgets/equino_form_widget.dart';
import 'widgets/equino_image_selector_widget.dart';

class EquinosCadastroPage extends GetView<EquinosCadastroController> {
  const EquinosCadastroPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Obx(() => PageHeaderWidget(
                    title: controller.idReg.isEmpty
                        ? 'Novo Equino'
                        : 'Editar Equino',
                    subtitle: 'Cadastro de equino',
                    icon: Icons.pets,
                    showBackButton: true,
                    actions: [
                      IconButton(
                        onPressed: controller.isLoading.value
                            ? null
                            : controller.salvarRegistro,
                        icon: const Icon(Icons.save, color: Colors.white),
                      ),
                    ],
                  )),
            ),
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const CircularProgressIndicator(),
                        const SizedBox(height: 16),
                        if (controller.uploadProgress.value > 0)
                          Column(
                            children: [
                              Text(
                                'Upload: ${(controller.uploadProgress.value * 100).toStringAsFixed(0)}%',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                              const SizedBox(height: 8),
                              LinearProgressIndicator(
                                value: controller.uploadProgress.value,
                                backgroundColor: Colors.grey.shade300,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Theme.of(context).primaryColor,
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  );
                }

                return SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Mostrar mensagem de erro se existir
                        if (controller.errorMessage.value.isNotEmpty)
                          Container(
                            width: double.infinity,
                            margin: const EdgeInsets.only(bottom: 16),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.red.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                  color: Colors.red.withValues(alpha: 0.3)),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.error_outline,
                                    color: Colors.red, size: 20),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    controller.errorMessage.value,
                                    style: const TextStyle(
                                        color: Colors.red, fontSize: 14),
                                  ),
                                ),
                                IconButton(
                                  onPressed: () =>
                                      controller.errorMessage.value = '',
                                  icon: const Icon(Icons.close,
                                      color: Colors.red, size: 18),
                                  constraints: const BoxConstraints(),
                                  padding: EdgeInsets.zero,
                                ),
                              ],
                            ),
                          ),

                        // Seletores de imagem
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Obx(() => EquinoImageSelector(
                                  isMiniatura: false,
                                  onTap: controller.selecionarImagens,
                                  images: controller.images.toList(),
                                  label:
                                      'Imagens (${controller.images.length})',
                                  onRemove: controller.removeImage,
                                )),
                            Obx(() => EquinoImageSelector(
                                  isMiniatura: true,
                                  onTap: controller.selecionarMiniatura,
                                  image: controller.imageMiniatura.value,
                                  label: 'Miniatura',
                                  onRemove: (_) => controller.removeMiniatura(),
                                )),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Formulário
                        EquinoFormWidget(
                          formKey: controller.formKey,
                          onStatusChanged: (value) {
                            // O formulário já usa Obx internamente
                          },
                        ),
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

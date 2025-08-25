// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:get/get.dart';

// Project imports:
import '../../../../core/widgets/dialog_cadastro_widget.dart';
import '../../../models/13_despesa_model.dart';
import 'controllers/despesa_form_controller.dart';
import 'views/styles/despesa_form_styles.dart';
import 'views/widgets/animal_selector.dart';
import 'views/widgets/data_picker.dart';
import 'views/widgets/descricao_input.dart';
import 'views/widgets/error_display.dart';
import 'views/widgets/tipo_selector.dart';
import 'views/widgets/valor_input.dart';

/// Abre dialog de cadastro/edição de despesa seguindo o padrão do app
Future<bool?> despesaCadastro(BuildContext context, DespesaVet? despesa, {String? selectedAnimalId}) {
  final controllerTag = 'despesa_form_${DateTime.now().millisecondsSinceEpoch}';
  final formKey = GlobalKey<_DespesaFormDialogContentState>();
  
  return DialogCadastro.show(
    context: context,
    title: despesa == null ? 'Nova Despesa' : 'Editar Despesa',
    formKey: formKey,
    maxHeight: 600,
    onSubmit: () async {
      final controller = Get.find<DespesaFormController>(tag: controllerTag);
      final success = await controller.submitForm();
      if (success && context.mounted) {
        Navigator.of(context).pop(true);
      }
    },
    formWidget: (key) => DespesaFormDialogContent(
      key: key,
      despesa: despesa,
      selectedAnimalId: selectedAnimalId,
      controllerTag: controllerTag,
    ),
  );
}

/// Widget adaptado para funcionar dentro do DialogCadastro
class DespesaFormDialogContent extends StatefulWidget {
  final DespesaVet? despesa;
  final String? selectedAnimalId;
  final String controllerTag;

  const DespesaFormDialogContent({
    super.key,
    this.despesa,
    this.selectedAnimalId,
    required this.controllerTag,
  });

  @override
  State<DespesaFormDialogContent> createState() => _DespesaFormDialogContentState();
}

class _DespesaFormDialogContentState extends State<DespesaFormDialogContent> {
  late DespesaFormController controller;

  @override
  void initState() {
    super.initState();
    controller = DespesaFormController.create(tag: widget.controllerTag);
    controller.initializeForm(
      despesa: widget.despesa,
      selectedAnimalId: widget.selectedAnimalId,
    );
  }

  @override
  void dispose() {
    Get.delete<DespesaFormController>(tag: widget.controllerTag);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Conteúdo do formulário adaptado para dialog
    return GetBuilder<DespesaFormController>(
      tag: widget.controllerTag,
      builder: (controller) {
        return Stack(
          children: [
            SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildFormContent(controller),
                ],
              ),
            ),
            // Loading overlay
            Obx(() {
              if (controller.isLoadingReactive.value) {
                return const ColoredBox(
                  color: Colors.black54,
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                );
              }
              return const SizedBox.shrink();
            }),
          ],
        );
      },
    );
  }

  Widget _buildFormContent(DespesaFormController controller) {
    return Form(
      key: controller.formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Error display
          Obx(() {
            if (controller.formState.value.hasError) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: ErrorDisplay(
                  message: controller.formState.value.errorMessage!,
                  onDismiss: controller.clearMessages,
                ),
              );
            }
            return const SizedBox.shrink();
          }),
          
          // Form fields
          Card(
            elevation: DespesaFormStyles.cardElevation,
            margin: DespesaFormStyles.cardMargin,
            shape: DespesaFormStyles.cardShape,
            child: Padding(
              padding: DespesaFormStyles.cardPadding,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Informações da Despesa',
                    style: DespesaFormStyles.sectionTitleStyle,
                  ),
                  const SizedBox(height: 20),
                  AnimalSelector(controller: controller),
                  const SizedBox(height: 16),
                  TipoSelector(controller: controller),
                  const SizedBox(height: 16),
                  ValorInput(controller: controller),
                  const SizedBox(height: 16),
                  DataPicker(controller: controller),
                  const SizedBox(height: 16),
                  DescricaoInput(controller: controller),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

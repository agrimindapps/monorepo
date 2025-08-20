// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:get/get.dart';

// Project imports:
import '../../../../models/13_despesa_model.dart';
import '../config/despesa_config.dart';
import '../controllers/despesa_form_controller.dart';
import 'styles/despesa_form_styles.dart';
import 'widgets/action_buttons.dart';
import 'widgets/animal_selector.dart';
import 'widgets/data_picker.dart';
import 'widgets/descricao_input.dart';
import 'widgets/error_display.dart';
import 'widgets/loading_overlay.dart';
import 'widgets/tipo_selector.dart';
import 'widgets/valor_input.dart';

class DespesaFormView extends StatefulWidget {
  final DespesaVet? despesa;
  final String? selectedAnimalId;

  const DespesaFormView({
    super.key,
    this.despesa,
    this.selectedAnimalId,
  });

  @override
  State<DespesaFormView> createState() => _DespesaFormViewState();
}

class _DespesaFormViewState extends State<DespesaFormView> {
  late final DespesaFormController controller;
  late final String controllerTag;

  @override
  void initState() {
    super.initState();
    controllerTag = 'despesa_form_${DateTime.now().millisecondsSinceEpoch}';
    controller = DespesaFormController.create(tag: controllerTag);
    controller.initializeForm(
      despesa: widget.despesa,
      selectedAnimalId: widget.selectedAnimalId,
    );
  }

  @override
  void dispose() {
    Get.delete<DespesaFormController>(tag: controllerTag);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DespesaFormStyles.backgroundColor,
      appBar: _buildAppBar(),
      body: Stack(
        children: [
          _buildForm(context),
          // Use granular Obx for loading state only
          Obx(() {
            if (controller.isLoadingReactive.value) {
              return const LoadingOverlay();
            }
            return const SizedBox.shrink();
          }),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Text(
        controller.getFormTitle(),
        style: DespesaFormStyles.appBarTitleStyle,
      ),
      backgroundColor: DespesaFormStyles.primaryColor,
      foregroundColor: Colors.white,
      elevation: 0,
      actions: [
        if (controller.getFormTitle().contains('Editar'))
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () => _showDeleteConfirmation(),
            tooltip: DespesaConfig.buttonTextDelete,
          ),
      ],
    );
  }

  Widget _buildForm(BuildContext context) {
    return Form(
      key: controller.formKey,
      child: SingleChildScrollView(
        padding: DespesaFormStyles.formPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Obx(() {
              if (controller.formState.value.hasError) {
                return ErrorDisplay(
                  message: controller.formState.value.errorMessage!,
                  onDismiss: controller.clearMessages,
                );
              }
              return const SizedBox.shrink();
            }),
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
                    AnimalSelector(
                      controller: controller,
                    ),
                    const SizedBox(height: 16),
                    TipoSelector(
                      controller: controller,
                    ),
                    const SizedBox(height: 16),
                    ValorInput(
                      controller: controller,
                    ),
                    const SizedBox(height: 16),
                    DataPicker(
                      controller: controller,
                    ),
                    const SizedBox(height: 16),
                    DescricaoInput(
                      controller: controller,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            ActionButtons(
              controller: controller,
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation() {
    Get.dialog(
      AlertDialog(
        title: const Text('Confirmar Exclusão'),
        content: const Text(DespesaConfig.confirmDelete),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text(DespesaConfig.buttonTextCancel),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              controller.deleteCurrentDespesa();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text(DespesaConfig.buttonTextDelete),
          ),
        ],
      ),
    );
  }
}

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:get/get.dart';

// Project imports:
import '../../../../models/12_consulta_model.dart';
import '../../../../widgets/form/form_section_widget.dart';
import '../constants/consulta_form_constants.dart';
import '../controllers/consulta_form_controller.dart';
import 'styles/consulta_form_styles.dart';
import 'widgets/action_buttons.dart';
import 'widgets/animal_selector.dart';
import 'widgets/data_picker.dart';
import 'widgets/diagnostico_input.dart';
import 'widgets/error_display.dart';
import 'widgets/loading_overlay.dart';
import 'widgets/motivo_selector.dart';
import 'widgets/observacoes_input.dart';
import 'widgets/valor_input.dart';
import 'widgets/veterinario_input.dart';

enum ConsultaFormMode {
  fullScreen,
  dialog,
}

class ConsultaFormView extends StatefulWidget {
  final Consulta? consulta;
  final ConsultaFormMode mode;
  final GlobalKey? dialogKey;

  const ConsultaFormView({
    super.key,
    this.consulta,
    this.mode = ConsultaFormMode.fullScreen,
    this.dialogKey,
  });

  @override
  State<ConsultaFormView> createState() => _ConsultaFormViewState();
}

class _ConsultaFormViewState extends State<ConsultaFormView> {
  late final ConsultaFormController controller;
  late final String controllerTag;

  @override
  void initState() {
    super.initState();
    controllerTag = 'consulta_form_${DateTime.now().millisecondsSinceEpoch}';
    controller = Get.put(ConsultaFormController(), tag: controllerTag);
    controller.initializeForm(consulta: widget.consulta);
  }

  @override
  void dispose() {
    Get.delete<ConsultaFormController>(tag: controllerTag);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.mode == ConsultaFormMode.dialog) {
      return _buildDialogContent(context);
    }

    return Scaffold(
      backgroundColor: ConsultaFormStyles.backgroundColor,
      appBar: _buildAppBar(),
      body: Stack(
        children: [
          _buildForm(context),
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

  Widget _buildDialogContent(BuildContext context) {
    return Stack(
      children: [
        SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Obx(() {
                if (controller.errorMessageReactive.value != null) {
                  return ErrorDisplay(
                    message: controller.errorMessageReactive.value!,
                    onDismiss: controller.clearError,
                  );
                }
                return const SizedBox.shrink();
              }),
              _buildFormContent(),
            ],
          ),
        ),
        Obx(() {
          if (controller.isLoadingReactive.value) {
            return const LoadingOverlay();
          }
          return const SizedBox.shrink();
        }),
      ],
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Obx(() => Text(
            controller.getPageTitle(),
            style: ConsultaFormStyles.appBarTitleStyle,
          )),
      backgroundColor: ConsultaFormStyles.primaryColor,
      foregroundColor: Colors.white,
      elevation: 0,
      actions: [
        Obx(() {
          if (controller.canDelete()) {
            return IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: () => _showDeleteConfirmation(),
              tooltip: 'Excluir consulta',
            );
          }
          return const SizedBox.shrink();
        }),
      ],
    );
  }

  Widget _buildForm(BuildContext context) {
    return Form(
      key: controller.formKey,
      child: SingleChildScrollView(
        padding: ConsultaFormStyles.formPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Obx(() {
              if (controller.errorMessageReactive.value != null) {
                return ErrorDisplay(
                  message: controller.errorMessageReactive.value!,
                  onDismiss: controller.clearError,
                );
              }
              return const SizedBox.shrink();
            }),
            _buildFormContent(),
            const SizedBox(height: 24),
            ActionButtons(
              controller: controller,
              mode: widget.mode,
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildFormContent() {
    return Column(
      children: [
        // Seção Agendamento
        _buildAgendamentoSection(),
        const SizedBox(height: ConsultaFormConstants.sectionSpacing),

        // Seção Informações Veterinárias
        _buildInformacoesVeterinariasSection(),
        const SizedBox(height: ConsultaFormConstants.sectionSpacing),

        // Seção Informações Clínicas
        _buildInformacoesClinnicasSection(),
        const SizedBox(height: ConsultaFormConstants.sectionSpacing),

        // Seção Informações Financeiras
        _buildInformacoesFinanceirasSection(),

        if (widget.mode == ConsultaFormMode.dialog) ...[
          const SizedBox(height: 20),
          ActionButtons(
            controller: controller,
            mode: widget.mode,
          ),
        ],
      ],
    );
  }

  Widget _buildAgendamentoSection() {
    return FormSectionWidget(
      title: ConsultaFormConstants.titulosSecoes['agendamento']!,
      icon: ConsultaFormConstants.iconesSecoes['agendamento']!,
      children: [
        AnimalSelector(
          controller: controller,
        ),
        const SizedBox(height: ConsultaFormConstants.fieldSpacing),
        DataPicker(
          controller: controller,
        ),
      ],
    );
  }

  Widget _buildInformacoesVeterinariasSection() {
    return FormSectionWidget(
      title: ConsultaFormConstants.titulosSecoes['informacoes_veterinarias']!,
      icon: ConsultaFormConstants.iconesSecoes['informacoes_veterinarias']!,
      children: [
        VeterinarioInput(
          controller: controller,
        ),
        const SizedBox(height: ConsultaFormConstants.fieldSpacing),
        MotivoSelector(
          controller: controller,
        ),
      ],
    );
  }

  Widget _buildInformacoesClinnicasSection() {
    return FormSectionWidget(
      title: ConsultaFormConstants.titulosSecoes['informacoes_clinicas']!,
      icon: ConsultaFormConstants.iconesSecoes['informacoes_clinicas']!,
      children: [
        DiagnosticoInput(
          controller: controller,
        ),
        const SizedBox(height: ConsultaFormConstants.fieldSpacing),
        ObservacoesInput(
          controller: controller,
        ),
      ],
    );
  }

  Widget _buildInformacoesFinanceirasSection() {
    return FormSectionWidget(
      title: ConsultaFormConstants.titulosSecoes['informacoes_financeiras']!,
      icon: ConsultaFormConstants.iconesSecoes['informacoes_financeiras']!,
      children: [
        ValorInput(
          controller: controller,
        ),
      ],
    );
  }

  void _showDeleteConfirmation() {
    Get.dialog(
      AlertDialog(
        title: const Text('Confirmar Exclusão'),
        content: const Text('Tem certeza que deseja excluir esta consulta?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              controller.deleteConsulta();
            },
            style: ConsultaFormStyles.dangerButtonStyle,
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
  }
}

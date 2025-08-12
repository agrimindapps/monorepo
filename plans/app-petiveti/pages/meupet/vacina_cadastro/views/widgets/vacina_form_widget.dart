// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:get/get.dart';

// Project imports:
import '../../../../../models/16_vacina_model.dart';
import '../../controllers/vacina_cadastro_controller.dart';
import '../../mixins/form_state_mixin.dart';
import '../../services/controller_lifecycle_manager.dart';
import '../styles/form_constants.dart';
import '../styles/form_styles.dart';
import 'date_picker_field.dart';
import 'loading_overlay.dart';
import 'observation_field.dart';
import 'vacina_name_field.dart';

/// Main form widget for vaccine registration (MVC version)
class VacinaFormMVCWidget extends StatefulWidget {
  final VacinaVet? vacina;
  final String? selectedAnimalId;

  const VacinaFormMVCWidget({
    super.key,
    this.vacina,
    this.selectedAnimalId,
  });

  @override
  VacinaFormMVCWidgetState createState() => VacinaFormMVCWidgetState();
}

class VacinaFormMVCWidgetState extends State<VacinaFormMVCWidget>
    with FormStateMixin {
  final _formKey = GlobalKey<FormState>();
  late VacinaCadastroController controller;

  @override
  void initState() {
    super.initState();
    controller = 'vacina_form_${widget.hashCode}'.getManagedController();

    _initializeForm();
  }

  void _initializeForm() {
    if (widget.vacina != null) {
      populateForm(
        nomeVacina: widget.vacina!.nomeVacina,
        observacoes: widget.vacina!.observacoes,
      );

      controller.initializeForm(
        vacina: widget.vacina,
        selectedAnimalId: widget.selectedAnimalId ?? '',
      );
    } else {
      controller.initializeForm(
        selectedAnimalId: widget.selectedAnimalId ?? '',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        RepaintBoundary(
          child: Container(
            decoration: FormStyles.getFormContainerDecoration(),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: FormConstants.spacingMedium),

                  // Vaccine name field
                  VacinaNameField(
                    controller: nomeVacinaController,
                    focusNode: nomeVacinaFocusNode,
                    errorText: shouldShowFieldError('nomeVacina')
                        ? getFieldError('nomeVacina')
                        : null,
                    onFieldSubmitted: (_) => focusNextField('nomeVacina'),
                    onChanged: (value) {
                      controller.updateNomeVacina(value);
                    },
                  ),

                  const SizedBox(height: FormConstants.fieldSpacing),

                  // Date field - Data de Aplicação
                  RepaintBoundary(
                    child: Obx(() => DatePickerField(
                      label: 'Data de Aplicação',
                      initialDate: controller.dataAplicacaoDate,
                      focusNode: dataAplicacaoFocusNode,
                      onDateSelected: (date) {
                        controller.updateDataAplicacao(date);
                        focusNextField('dataAplicacao');
                      },
                      validator: (date) =>
                          null, // Controller handles validation
                    )),
                  ),

                  const SizedBox(height: FormConstants.fieldSpacing),

                  // Date field - Próxima Dose
                  RepaintBoundary(
                    child: Obx(() => DatePickerField(
                      label: 'Próxima Dose',
                      initialDate: controller.proximaDoseDate,
                      focusNode: proximaDoseFocusNode,
                      firstDate: controller.dataAplicacaoDate,
                      onDateSelected: (date) {
                        controller.updateProximaDose(date);
                        focusNextField('proximaDose');
                      },
                      validator: (date) =>
                          null, // Controller handles validation
                    )),
                  ),

                  const SizedBox(height: FormConstants.fieldSpacing),

                  // Observations field
                  ObservationField(
                    controller: observacoesController,
                    focusNode: observacoesFocusNode,
                    errorText: shouldShowFieldError('observacoes')
                        ? getFieldError('observacoes')
                        : null,
                    onChanged: (value) {
                      controller.updateObservacoes(value);
                    },
                  ),

                  // Error message display - granular rebuild only when error state changes
                  Obx(() => controller.hasError 
                    ? Column(
                        children: [
                          const SizedBox(height: FormConstants.spacingMedium),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(FormConstants.spacingMedium),
                            decoration: FormStyles.getErrorDecoration(),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.error_outline,
                                  color: FormStyles.errorStyle.color,
                                  size: FormConstants.errorIconSize,
                                ),
                                const SizedBox(width: FormConstants.spacingSmall),
                                Expanded(
                                  child: Text(
                                    controller.errorMessage!,
                                    style: FormStyles.errorStyle,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      )
                    : const SizedBox.shrink(),
                  ),
                ],
              ),
            ),
          ),
        ),

        // Loading overlay - granular rebuild only when loading state changes
        RepaintBoundary(
          child: Obx(() => controller.isLoading
            ? LoadingOverlay(
                message: widget.vacina == null
                    ? 'Salvando vacina...'
                    : 'Atualizando vacina...',
              )
            : const SizedBox.shrink(),
          ),
        ),
      ],
    );
  }

  /// Submits the form
  Future<bool> submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return false;
    }

    _formKey.currentState!.save();

    // Controller handles validation internally

    try {
      final success = await controller.submitForm(context);

      if (!success && mounted) {
        _showErrorSnackBar();
      }

      return success;
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar('Erro inesperado: ${e.toString()}');
      }
      return false;
    }
  }

  void _showErrorSnackBar([String? message]) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content:
            Text(message ?? controller.errorMessage ?? 'Erro ao salvar vacina'),
        backgroundColor: FormStyles.errorStyle.color,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  void dispose() {
    'vacina_form_${widget.hashCode}'.releaseManagedController();
    super.dispose();
  }
}

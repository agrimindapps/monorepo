// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:get/get.dart';

// Project imports:
import '../../controllers/despesa_form_controller.dart';
import '../../models/despesa_form_model.dart';
import '../../utils/despesa_form_utils.dart';
import '../styles/despesa_form_styles.dart';

class TipoSelector extends StatelessWidget {
  final DespesaFormController controller;

  const TipoSelector({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Tipo de Despesa *',
          style: DespesaFormStyles.labelStyle,
        ),
        const SizedBox(height: 8),
        Obx(() {
          final selectedTipo = controller.formModel.value.tipo;
          final hasError = controller.formState.value.getFieldError('tipo') != null;

          return DropdownButtonFormField<String>(
            value: selectedTipo,
            decoration: DespesaFormStyles.getDropdownDecoration(
              labelText: 'Selecione o tipo',
              prefixIcon: Icon(
                Icons.category_outlined,
                color: selectedTipo.isNotEmpty 
                    ? DespesaFormUtils.getTipoColor(selectedTipo)
                    : DespesaFormStyles.textSecondaryColor,
              ),
              hasError: hasError,
            ),
            items: DespesaConstants.tiposDespesa.map((String tipo) {
              return DropdownMenuItem<String>(
                value: tipo,
                child: Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: DespesaFormUtils.getTipoColor(tipo).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          DespesaFormUtils.getTipoIcon(tipo),
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        tipo,
                        style: DespesaFormStyles.inputStyle,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
            onChanged: (String? value) {
              if (value != null) {
                controller.updateTipo(value);
              }
            },
            validator: (String? value) {
              if (value == null || value.isEmpty) {
                return 'Selecione um tipo de despesa';
              }
              return null;
            },
            isExpanded: true,
            icon: const Icon(Icons.arrow_drop_down),
            iconSize: DespesaFormStyles.mediumIconSize,
            style: DespesaFormStyles.inputStyle,
            dropdownColor: Colors.white,
            menuMaxHeight: DespesaFormStyles.maxDropdownHeight,
          );
        }),
        
        Obx(() {
          final error = controller.formState.value.getFieldError('tipo');
          if (error != null) {
            return Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                error,
                style: DespesaFormStyles.errorStyle,
              ),
            );
          }
          return const SizedBox.shrink();
        }),
        
        const SizedBox(height: 8),
        
        Obx(() {
          final selectedTipo = controller.formModel.value.tipo;
          if (selectedTipo.isNotEmpty) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: DespesaFormUtils.getTipoColor(selectedTipo).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: DespesaFormUtils.getTipoColor(selectedTipo).withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    DespesaFormUtils.getTipoIcon(selectedTipo),
                    style: const TextStyle(fontSize: 18),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    selectedTipo,
                    style: TextStyle(
                      color: DespesaFormUtils.getTipoColor(selectedTipo),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            );
          }
          return const SizedBox.shrink();
        }),
      ],
    );
  }
}

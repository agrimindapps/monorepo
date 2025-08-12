// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:get/get.dart';

// Project imports:
import '../../../../../utils/consulta_utils.dart';
import '../../controllers/consulta_form_controller.dart';
import '../styles/consulta_form_styles.dart';

class MotivoSelector extends StatelessWidget {
  final ConsultaFormController controller;

  const MotivoSelector({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Motivo *',
          style: ConsultaFormStyles.labelStyle,
        ),
        const SizedBox(height: 8),
        Obx(() {
          final selectedMotivo = controller.model.motivo;
          final hasError = controller.getFieldError('motivo') != null;
          final motivos = controller.getAvailableMotivos();

          return DropdownButtonFormField<String>(
            value: selectedMotivo.isEmpty ? null : selectedMotivo,
            decoration: ConsultaFormStyles.getDropdownDecoration(
              labelText: 'Selecione o motivo',
              hasError: hasError,
            ),
            items: motivos.map((String motivo) {
              return DropdownMenuItem<String>(
                value: motivo,
                child: Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: ConsultaUtils.getMotivoColor(motivo)
                            .withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          ConsultaUtils.getMotivoIcon(motivo),
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        motivo,
                        style: ConsultaFormStyles.inputStyle,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
            onChanged: (String? value) {
              if (value != null) {
                controller.updateMotivo(value);
              }
            },
            validator: (String? value) {
              if (value == null || value.isEmpty) {
                return 'Selecione um motivo';
              }
              return null;
            },
            isExpanded: true,
            icon: const Icon(Icons.arrow_drop_down),
            iconSize: ConsultaFormStyles.mediumIconSize,
            style: ConsultaFormStyles.inputStyle,
            dropdownColor: Colors.white,
            menuMaxHeight: ConsultaFormStyles.maxDropdownHeight,
          );
        }),
        Obx(() {
          final error = controller.getFieldError('motivo');
          if (error != null) {
            return Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                error,
                style: ConsultaFormStyles.errorStyle,
              ),
            );
          }
          return const SizedBox.shrink();
        }),
      ],
    );
  }
}

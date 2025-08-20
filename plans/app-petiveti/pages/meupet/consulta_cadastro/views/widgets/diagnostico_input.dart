// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Package imports:
import 'package:get/get.dart';

// Project imports:
import '../../controllers/consulta_form_controller.dart';
import '../styles/consulta_form_styles.dart';

class DiagnosticoInput extends StatelessWidget {
  final ConsultaFormController controller;

  const DiagnosticoInput({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Diagnóstico *',
          style: ConsultaFormStyles.labelStyle,
        ),
        const SizedBox(height: 8),
        Obx(() {
          final hasError = controller.getFieldError('diagnostico') != null;
          final currentValue = controller.model.diagnostico;

          return TextFormField(
            initialValue: currentValue,
            decoration: ConsultaFormStyles.getInputDecoration(
              labelText: 'Diagnóstico da consulta',
              hintText: 'Descreva o diagnóstico detalhadamente...',
              hasError: hasError,
            ),
            maxLength: 500,
            maxLines: 4,
            minLines: 2,
            inputFormatters: [
              LengthLimitingTextInputFormatter(500),
            ],
            onChanged: (String value) {
              controller.updateDiagnostico(value);
            },
            validator: (String? value) {
              if (value == null || value.trim().isEmpty) {
                return 'Diagnóstico é obrigatório';
              }
              if (value.length > 500) {
                return 'Diagnóstico muito longo (máx. 500 caracteres)';
              }
              if (value.trim().length < 5) {
                return 'Diagnóstico muito curto (mín. 5 caracteres)';
              }
              return null;
            },
            style: ConsultaFormStyles.inputStyle,
            textCapitalization: TextCapitalization.sentences,
          );
        }),
        Obx(() {
          final error = controller.getFieldError('diagnostico');
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
        const SizedBox(height: 8),
        Obx(() {
          final selectedMotivo = controller.model.motivo;
          final currentDiagnostico = controller.model.diagnostico;
          final suggestion =
              controller.generateMotivoSuggestion(selectedMotivo);

          if (suggestion != null && currentDiagnostico.isEmpty) {
            return GestureDetector(
              onTap: () => controller.updateDiagnostico(suggestion),
              child: Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color:
                      ConsultaFormStyles.secondaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: ConsultaFormStyles.secondaryColor
                        .withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.lightbulb_outline,
                      size: 16,
                      color: ConsultaFormStyles.secondaryColor,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Sugestão: $suggestion',
                        style: const TextStyle(
                          color: ConsultaFormStyles.secondaryColor,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    const Icon(
                      Icons.touch_app,
                      size: 16,
                      color: ConsultaFormStyles.secondaryColor,
                    ),
                  ],
                ),
              ),
            );
          }
          return const SizedBox.shrink();
        }),
      ],
    );
  }
}

// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Package imports:
import 'package:get/get.dart';

// Project imports:
import '../../controllers/despesa_form_controller.dart';
import '../../models/despesa_form_model.dart';
import '../../utils/despesa_form_utils.dart';
import '../styles/despesa_form_styles.dart';

class DescricaoInput extends StatelessWidget {
  final DespesaFormController controller;

  const DescricaoInput({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Descrição',
          style: DespesaFormStyles.labelStyle,
        ),
        const SizedBox(height: 8),
        Obx(() {
          final hasError = controller.formState.value.getFieldError('descricao') != null;
          final currentDescricao = controller.formModel.value.descricao;
          final selectedTipo = controller.formModel.value.tipo;

          return TextFormField(
            initialValue: currentDescricao,
            decoration: DespesaFormStyles.getInputDecoration(
              labelText: 'Descrição da despesa',
              hintText: _getHintText(selectedTipo),
              prefixIcon: const Icon(Icons.description_outlined),
              suffixIcon: _buildSuffixIcon(currentDescricao, selectedTipo),
              hasError: hasError,
            ),
            maxLength: DespesaConstants.descricaoMaxLength,
            maxLines: 3,
            minLines: 1,
            inputFormatters: [
              LengthLimitingTextInputFormatter(DespesaConstants.descricaoMaxLength),
            ],
            onChanged: (String value) {
              controller.updateDescricao(value);
            },
            validator: (String? value) {
              if (value != null && value.length > DespesaConstants.descricaoMaxLength) {
                return 'Descrição muito longa (máx. ${DespesaConstants.descricaoMaxLength} caracteres)';
              }
              
              if (value != null && value.trim().isNotEmpty && value.trim().length < DespesaConstants.descricaoMinLength) {
                return 'Descrição muito curta (mín. ${DespesaConstants.descricaoMinLength} caracteres)';
              }
              
              return null;
            },
            style: DespesaFormStyles.inputStyle,
            textCapitalization: TextCapitalization.sentences,
          );
        }),
        
        Obx(() {
          final error = controller.formState.value.getFieldError('descricao');
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
          final currentDescricao = controller.formModel.value.descricao;
          final suggestion = DespesaFormUtils.generateSuggestion(selectedTipo, currentDescricao);
          
          if (suggestion != null && currentDescricao.isEmpty) {
            return GestureDetector(
              onTap: () => controller.updateDescricao(suggestion),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: DespesaFormStyles.secondaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: DespesaFormStyles.secondaryColor.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.lightbulb_outline,
                      size: 16,
                      color: DespesaFormStyles.secondaryColor,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Sugestão: $suggestion',
                        style: const TextStyle(
                          color: DespesaFormStyles.secondaryColor,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    const Icon(
                      Icons.touch_app,
                      size: 16,
                      color: DespesaFormStyles.secondaryColor,
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

  String _getHintText(String tipo) {
    final hints = {
      'Consulta': 'Ex: Consulta de rotina, check-up geral',
      'Medicamento': 'Ex: Nome do medicamento prescrito',
      'Vacina': 'Ex: Vacina antirrábica, V8, V10',
      'Exame': 'Ex: Hemograma, raio-x, ultrassom',
      'Cirurgia': 'Ex: Castração, cirurgia de emergência',
      'Emergência': 'Ex: Atendimento de emergência',
      'Banho e Tosa': 'Ex: Banho, tosa, hidratação',
      'Alimentação': 'Ex: Ração premium, ração terapêutica',
      'Petiscos': 'Ex: Ossinhos, biscoitos, guloseimas',
      'Brinquedos': 'Ex: Bola, corda, brinquedo interativo',
      'Acessórios': 'Ex: Coleira, guia, cama, comedouro',
      'Hospedagem': 'Ex: Hotel para pets, creche',
      'Transporte': 'Ex: Taxi dog, transporte para clínica',
      'Seguro': 'Ex: Seguro saúde pet, seguro vida',
      'Outros': 'Ex: Outras despesas relacionadas ao pet',
    };
    
    return hints[tipo] ?? 'Descreva a despesa (opcional)';
  }

  Widget? _buildSuffixIcon(String currentDescricao, String selectedTipo) {
    if (currentDescricao.isNotEmpty) {
      return IconButton(
        icon: const Icon(Icons.clear, size: 20),
        onPressed: () => controller.updateDescricao(''),
        tooltip: 'Limpar descrição',
      );
    }
    
    final suggestion = DespesaFormUtils.generateSuggestion(selectedTipo, currentDescricao);
    if (suggestion != null) {
      return IconButton(
        icon: const Icon(
          Icons.auto_fix_high,
          size: 20,
          color: DespesaFormStyles.secondaryColor,
        ),
        onPressed: () => controller.updateDescricao(suggestion),
        tooltip: 'Usar sugestão',
      );
    }
    
    return null;
  }
}

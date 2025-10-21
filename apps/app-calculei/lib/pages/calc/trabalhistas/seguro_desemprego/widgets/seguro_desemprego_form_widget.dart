// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Project imports:
import 'package:app_calculei/core/style/shadcn_style.dart';
import 'package:app_calculei/core/themes/manager.dart';
import 'package:app_calculei/constants/calculation_constants.dart';
import 'package:app_calculei/pages/calc/trabalhistas/seguro_desemprego/widgets/controllers/seguro_desemprego_controller.dart';

class SeguroDesempregoFormWidget extends StatelessWidget {
  final SeguroDesempregoController controller;
  
  const SeguroDesempregoFormWidget({
    super.key,
    required this.controller,
  });
  
  @override
  Widget build(BuildContext context) {
    final isDark = ThemeManager().isDark.value;
    
    return Form(
      key: controller.formKey,
      child: Column(
        children: [
          // Salário Médio dos Últimos 3 Meses
          _buildTextField(
            controller: controller.salarioMedioController,
            label: 'Salário Médio dos Últimos 3 Meses',
            hint: 'Ex: R\$ 2.500,00',
            prefixIcon: Icons.attach_money,
            keyboardType: TextInputType.number,
            inputFormatters: [controller.formattingService.currencyFormatter],
            validator: controller.validateSalarioMedio,
            isDark: isDark,
            helperText: controller.getDicaSalario(),
          ),
          
          const SizedBox(height: CalculationConstants.formFieldSpacing),
          
          Row(
            children: [
              // Tempo de Trabalho
              Expanded(
                child: _buildTextField(
                  controller: controller.tempoTrabalhoController,
                  label: 'Tempo de Trabalho (meses)',
                  hint: 'Ex: 18',
                  prefixIcon: Icons.work,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  validator: controller.validateTempoTrabalho,
                  isDark: isDark,
                  helperText: controller.getDicaTempo(),
                ),
              ),
              
              const SizedBox(width: CalculationConstants.formFieldSpacing),
              
              // Vezes que já Recebeu
              Expanded(
                child: _buildTextField(
                  controller: controller.vezesRecebidasController,
                  label: 'Vezes que já Recebeu',
                  hint: 'Ex: 0',
                  prefixIcon: Icons.history,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  validator: controller.validateVezesRecebidas,
                  isDark: isDark,
                  helperText: controller.getDicaVezesRecebidas(),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: CalculationConstants.formFieldSpacing),
          
          // Data de Demissão
          _buildTextField(
            controller: controller.dataDemissaoController,
            label: 'Data de Demissão',
            hint: 'DD/MM/AAAA',
            prefixIcon: Icons.event,
            keyboardType: TextInputType.number,
            inputFormatters: [controller.formattingService.dateFormatter],
            validator: controller.validateDataDemissao,
            isDark: isDark,
            helperText: controller.getDicaPrazo(),
            onChanged: controller.onDataDemissaoChanged,
          ),
          
          const SizedBox(height: CalculationConstants.formFieldSpacing),
          
          // Status do Direito
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: controller.getDicaCarencia().contains('✅')
                  ? Colors.green.withValues(alpha: 0.1)
                  : Colors.orange.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: controller.getDicaCarencia().contains('✅')
                    ? Colors.green.withValues(alpha: 0.3)
                    : Colors.orange.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  controller.getDicaCarencia().contains('✅') 
                      ? Icons.check_circle 
                      : Icons.warning,
                  color: controller.getDicaCarencia().contains('✅') 
                      ? Colors.green 
                      : Colors.orange,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    controller.getDicaCarencia(),
                    style: TextStyle(
                      color: controller.getDicaCarencia().contains('✅') 
                          ? Colors.green 
                          : Colors.orange,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Error message
          if (controller.errorMessage != null) ...[
            const SizedBox(height: CalculationConstants.formFieldSpacing),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      controller.errorMessage!,
                      style: const TextStyle(color: Colors.red, fontSize: 14),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
  
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData prefixIcon,
    required TextInputType keyboardType,
    required List<TextInputFormatter> inputFormatters,
    required String? Function(String?) validator,
    required bool isDark,
    String? helperText,
    void Function(String)? onChanged,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        helperText: helperText,
        prefixIcon: Icon(prefixIcon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        filled: true,
        fillColor: isDark ? Colors.grey.shade900 : Colors.grey.shade50,
      ),
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      validator: validator,
      style: TextStyle(color: ShadcnStyle.textColor),
      onChanged: onChanged,
    );
  }
}

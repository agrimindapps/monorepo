// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Project imports:
import 'package:app_calculei/core/style/shadcn_style.dart';
import 'package:app_calculei/core/themes/manager.dart';
import 'package:app_calculei/constants/calculation_constants.dart';
import 'package:app_calculei/pages/calc/trabalhistas/decimo_terceiro/widgets/controllers/decimo_terceiro_controller.dart';

class DecimoTerceiroFormWidget extends StatelessWidget {
  final DecimoTerceiroController controller;
  
  const DecimoTerceiroFormWidget({
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
          // Salário Bruto
          _buildTextField(
            controller: controller.salarioBrutoController,
            label: 'Salário Bruto Mensal',
            hint: 'Ex: R\$ 3.000,00',
            prefixIcon: Icons.attach_money,
            keyboardType: TextInputType.number,
            inputFormatters: [controller.formattingService.currencyFormatter],
            validator: controller.validateSalario,
            isDark: isDark,
          ),
          
          const SizedBox(height: CalculationConstants.formFieldSpacing),
          
          Row(
            children: [
              // Data de Admissão
              Expanded(
                child: _buildTextField(
                  controller: controller.dataAdmissaoController,
                  label: 'Data de Admissão',
                  hint: 'DD/MM/AAAA',
                  prefixIcon: Icons.calendar_today,
                  keyboardType: TextInputType.number,
                  inputFormatters: [controller.formattingService.dateFormatter],
                  validator: controller.validateDataAdmissao,
                  isDark: isDark,
                  onChanged: controller.onDataAdmissaoChanged,
                ),
              ),
              
              const SizedBox(width: CalculationConstants.formFieldSpacing),
              
              // Data do Cálculo
              Expanded(
                child: _buildTextField(
                  controller: controller.dataCalculoController,
                  label: 'Data do Cálculo',
                  hint: 'DD/MM/AAAA',
                  prefixIcon: Icons.event,
                  keyboardType: TextInputType.number,
                  inputFormatters: [controller.formattingService.dateFormatter],
                  validator: controller.validateDataCalculo,
                  isDark: isDark,
                  onChanged: controller.onDataCalculoChanged,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: CalculationConstants.formFieldSpacing),
          
          Row(
            children: [
              // Meses Trabalhados (calculado automaticamente)
              Expanded(
                child: _buildTextField(
                  controller: controller.mesesTrabalhadosController,
                  label: 'Meses Trabalhados',
                  hint: 'Ex: 12',
                  prefixIcon: Icons.work,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  validator: controller.validateMeses,
                  isDark: isDark,
                  readOnly: true,
                  helperText: 'Calculado automaticamente',
                ),
              ),
              
              const SizedBox(width: CalculationConstants.formFieldSpacing),
              
              // Dependentes IRRF
              Expanded(
                child: _buildTextField(
                  controller: controller.dependentesController,
                  label: 'Dependentes IRRF',
                  hint: 'Ex: 2',
                  prefixIcon: Icons.people,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  validator: controller.validateDependentes,
                  isDark: isDark,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: CalculationConstants.formFieldSpacing),
          
          // Faltas Não Justificadas
          _buildTextField(
            controller: controller.faltasController,
            label: 'Faltas Não Justificadas (opcional)',
            hint: 'Ex: 5',
            prefixIcon: Icons.cancel,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            validator: controller.validateFaltas,
            isDark: isDark,
            helperText: 'Cada 15 faltas desconta 1 mês do 13º',
          ),
          
          const SizedBox(height: CalculationConstants.formFieldSpacing),
          
          // Checkbox Antecipação
          Row(
            children: [
              Checkbox(
                value: controller.antecipacao,
                onChanged: (value) => controller.setAntecipacao(value ?? false),
                activeColor: Colors.blue,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Simular antecipação (1ª parcela em novembro)',
                  style: TextStyle(
                    color: ShadcnStyle.textColor,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
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
    bool readOnly = false,
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
        fillColor: readOnly 
            ? (isDark ? Colors.grey.shade800 : Colors.grey.shade100)
            : (isDark ? Colors.grey.shade900 : Colors.grey.shade50),
      ),
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      validator: validator,
      readOnly: readOnly,
      style: TextStyle(
        color: readOnly 
            ? (isDark ? Colors.grey.shade500 : Colors.grey.shade600)
            : ShadcnStyle.textColor,
      ),
      onChanged: onChanged,
    );
  }
}

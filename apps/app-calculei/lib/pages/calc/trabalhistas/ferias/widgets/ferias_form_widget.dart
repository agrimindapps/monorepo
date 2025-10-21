// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Project imports:
import 'package:app_calculei/core/style/shadcn_style.dart';
import 'package:app_calculei/core/themes/manager.dart';
import 'package:app_calculei/constants/calculation_constants.dart';
import 'package:app_calculei/pages/calc/trabalhistas/ferias/widgets/controllers/ferias_controller.dart';

class FeriasFormWidget extends StatelessWidget {
  final FeriasController controller;
  
  const FeriasFormWidget({
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
              // Início do Período Aquisitivo
              Expanded(
                child: _buildTextField(
                  controller: controller.inicioAquisitivoController,
                  label: 'Início Período Aquisitivo',
                  hint: 'DD/MM/AAAA',
                  prefixIcon: Icons.calendar_today,
                  keyboardType: TextInputType.number,
                  inputFormatters: [controller.formattingService.dateFormatter],
                  validator: controller.validateDataInicio,
                  isDark: isDark,
                  onChanged: controller.onInicioAquisitivoChanged,
                ),
              ),
              
              const SizedBox(width: CalculationConstants.formFieldSpacing),
              
              // Fim do Período Aquisitivo
              Expanded(
                child: _buildTextField(
                  controller: controller.fimAquisitivoController,
                  label: 'Fim Período Aquisitivo',
                  hint: 'DD/MM/AAAA',
                  prefixIcon: Icons.event,
                  keyboardType: TextInputType.number,
                  inputFormatters: [controller.formattingService.dateFormatter],
                  validator: controller.validateDataFim,
                  isDark: isDark,
                  onChanged: controller.onFimAquisitivoChanged,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: CalculationConstants.formFieldSpacing),
          
          Row(
            children: [
              // Dias de Férias
              Expanded(
                child: _buildTextField(
                  controller: controller.diasFeriasController,
                  label: 'Dias de Férias',
                  hint: 'Ex: 30',
                  prefixIcon: Icons.beach_access,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  validator: controller.validateDiasFerias,
                  isDark: isDark,
                  helperText: controller.getDicaDiasFerias(),
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
            hint: 'Ex: 10',
            prefixIcon: Icons.cancel,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            validator: controller.validateFaltas,
            isDark: isDark,
            helperText: controller.dicaFaltas.isNotEmpty ? controller.dicaFaltas : 'Influencia no direito às férias',
            onChanged: controller.onFaltasChanged,
          ),
          
          const SizedBox(height: CalculationConstants.formFieldSpacing),
          
          // Direito às Férias
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: controller.diasDireito > 0 
                  ? Colors.green.withValues(alpha: 0.1)
                  : Colors.orange.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: controller.diasDireito > 0 
                    ? Colors.green.withValues(alpha: 0.3)
                    : Colors.orange.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  controller.diasDireito > 0 ? Icons.check_circle : Icons.warning,
                  color: controller.diasDireito > 0 ? Colors.green : Colors.orange,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    controller.diasDireito > 0 
                        ? 'Direito a ${controller.diasDireito} dias de férias'
                        : 'Sem direito a férias devido às faltas',
                    style: TextStyle(
                      color: controller.diasDireito > 0 ? Colors.green : Colors.orange,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: CalculationConstants.formFieldSpacing),
          
          // Checkbox Abono Pecuniário
          Row(
            children: [
              Checkbox(
                value: controller.abonoPecuniario,
                onChanged: controller.diasDireito > 0 
                    ? (value) => controller.setAbonoPecuniario(value ?? false)
                    : null,
                activeColor: Colors.blue,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Vender 1/3 das férias (Abono Pecuniário)',
                      style: TextStyle(
                        color: controller.diasDireito > 0 
                            ? ShadcnStyle.textColor 
                            : Colors.grey,
                        fontSize: 14,
                      ),
                    ),
                    if (controller.diasDireito > 0)
                      Text(
                        controller.getDicaAbonoPecuniario(),
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 12,
                        ),
                      ),
                  ],
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

// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Project imports:
import 'package:app_calculei/core/style/shadcn_style.dart';
import 'package:app_calculei/core/themes/manager.dart';
import 'package:app_calculei/constants/calculation_constants.dart';
import 'package:app_calculei/pages/calc/trabalhistas/salario_liquido/widgets/controllers/salario_liquido_controller.dart';

class SalarioLiquidoFormWidget extends StatelessWidget {
  final SalarioLiquidoController controller;
  
  const SalarioLiquidoFormWidget({
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
              // Dependentes
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
              
              const SizedBox(width: CalculationConstants.formFieldSpacing),
              
              // Vale Transporte
              Expanded(
                child: _buildTextField(
                  controller: controller.valeTransporteController,
                  label: 'Vale Transporte',
                  hint: 'Ex: R\$ 150,00',
                  prefixIcon: Icons.directions_bus,
                  keyboardType: TextInputType.number,
                  inputFormatters: [controller.formattingService.currencyFormatter],
                  validator: controller.validateValeTransporte,
                  isDark: isDark,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: CalculationConstants.formFieldSpacing),
          
          Row(
            children: [
              // Plano de Saúde
              Expanded(
                child: _buildTextField(
                  controller: controller.planoSaudeController,
                  label: 'Plano de Saúde',
                  hint: 'Ex: R\$ 200,00',
                  prefixIcon: Icons.local_hospital,
                  keyboardType: TextInputType.number,
                  inputFormatters: [controller.formattingService.currencyFormatter],
                  validator: controller.validatePlanoSaude,
                  isDark: isDark,
                ),
              ),
              
              const SizedBox(width: CalculationConstants.formFieldSpacing),
              
              // Outros Descontos
              Expanded(
                child: _buildTextField(
                  controller: controller.outrosDescontosController,
                  label: 'Outros Descontos',
                  hint: 'Ex: R\$ 50,00',
                  prefixIcon: Icons.remove_circle_outline,
                  keyboardType: TextInputType.number,
                  inputFormatters: [controller.formattingService.currencyFormatter],
                  validator: controller.validateOutrosDescontos,
                  isDark: isDark,
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
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
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
    );
  }
}

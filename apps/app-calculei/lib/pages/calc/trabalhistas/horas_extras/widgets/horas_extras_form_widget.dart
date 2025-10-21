// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Project imports:
import 'package:app_calculei/core/style/shadcn_style.dart';
import 'package:app_calculei/core/themes/manager.dart';
import 'package:app_calculei/constants/calculation_constants.dart';
import 'package:app_calculei/pages/calc/trabalhistas/horas_extras/widgets/controllers/horas_extras_controller.dart';

class HorasExtrasFormWidget extends StatelessWidget {
  final HorasExtrasController controller;
  
  const HorasExtrasFormWidget({
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
          // Salário Bruto e Jornada
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  controller: controller.salarioBrutoController,
                  label: 'Salário Bruto Mensal',
                  hint: 'Ex: R\$ 3.000,00',
                  prefixIcon: Icons.attach_money,
                  keyboardType: TextInputType.number,
                  inputFormatters: [controller.formattingService.currencyFormatter],
                  validator: controller.validateSalario,
                  isDark: isDark,
                ),
              ),
              
              const SizedBox(width: CalculationConstants.formFieldSpacing),
              
              Expanded(
                child: _buildTextField(
                  controller: controller.horasSemanaisController,
                  label: 'Horas Semanais',
                  hint: 'Ex: 44',
                  prefixIcon: Icons.schedule,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  validator: controller.validateHorasSemanais,
                  isDark: isDark,
                  helperText: controller.getDicaJornada(),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: CalculationConstants.formFieldSpacing),
          
          // Dias Úteis
          _buildTextField(
            controller: controller.diasUteisController,
            label: 'Dias Úteis do Mês',
            hint: 'Ex: 22',
            prefixIcon: Icons.calendar_month,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            validator: controller.validateDiasUteis,
            isDark: isDark,
            helperText: 'Horas trabalhadas no mês: ${controller.getHorasTrabalhadasMes().toStringAsFixed(1)}h',
          ),
          
          const SizedBox(height: CalculationConstants.formFieldSpacing),
          
          // Seção Horas Extras
          Text(
            'Horas Extras',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: ShadcnStyle.textColor,
            ),
          ),
          const SizedBox(height: 8),
          
          Row(
            children: [
              // Horas Extras 50%
              Expanded(
                child: _buildTextField(
                  controller: controller.horas50Controller,
                  label: 'Horas Extras 50%',
                  hint: 'Ex: 10,5',
                  prefixIcon: Icons.add_circle_outline,
                  keyboardType: TextInputType.number,
                  inputFormatters: [controller.formattingService.hoursFormatter],
                  validator: controller.validateHoras50,
                  isDark: isDark,
                ),
              ),
              
              const SizedBox(width: CalculationConstants.formFieldSpacing),
              
              // Horas Extras 100%
              Expanded(
                child: _buildTextField(
                  controller: controller.horas100Controller,
                  label: 'Horas Extras 100%',
                  hint: 'Ex: 5,0',
                  prefixIcon: Icons.add_circle,
                  keyboardType: TextInputType.number,
                  inputFormatters: [controller.formattingService.hoursFormatter],
                  validator: controller.validateHoras100,
                  isDark: isDark,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: CalculationConstants.formFieldSpacing),
          
          // Seção Adicionais
          Text(
            'Adicionais Especiais',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: ShadcnStyle.textColor,
            ),
          ),
          const SizedBox(height: 8),
          
          Row(
            children: [
              // Horas Noturnas
              Expanded(
                child: _buildTextField(
                  controller: controller.horasNoturnasController,
                  label: 'Horas Noturnas',
                  hint: 'Ex: 8,0',
                  prefixIcon: Icons.nights_stay,
                  keyboardType: TextInputType.number,
                  inputFormatters: [controller.formattingService.hoursFormatter],
                  validator: controller.validateHorasNoturnas,
                  isDark: isDark,
                  helperText: 'Período: 22h às 5h',
                ),
              ),
              
              const SizedBox(width: CalculationConstants.formFieldSpacing),
              
              // Percentual Adicional Noturno
              Expanded(
                child: _buildTextField(
                  controller: controller.percentualNoturnoController,
                  label: 'Adicional Noturno (%)',
                  hint: 'Ex: 20',
                  prefixIcon: Icons.percent,
                  keyboardType: TextInputType.number,
                  inputFormatters: [controller.formattingService.percentFormatter],
                  validator: controller.validatePercentualNoturno,
                  isDark: isDark,
                  helperText: 'Mínimo legal: 20%',
                ),
              ),
            ],
          ),
          
          const SizedBox(height: CalculationConstants.formFieldSpacing),
          
          Row(
            children: [
              // Horas Domingo/Feriado
              Expanded(
                child: _buildTextField(
                  controller: controller.horasDomingoFeriadoController,
                  label: 'Horas Domingo/Feriado',
                  hint: 'Ex: 4,0',
                  prefixIcon: Icons.weekend,
                  keyboardType: TextInputType.number,
                  inputFormatters: [controller.formattingService.hoursFormatter],
                  validator: controller.validateHorasDomingoFeriado,
                  isDark: isDark,
                  helperText: '100% sobre hora normal',
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
          
          // Resumo das Horas
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.schedule, color: Colors.blue),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Resumo das Horas',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        controller.getResumoHoras(),
                        style: TextStyle(
                          color: ShadcnStyle.textColor,
                          fontSize: 14,
                        ),
                      ),
                      if (controller.getAlertaHorasExtras().isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          controller.getAlertaHorasExtras(),
                          style: TextStyle(
                            color: controller.getAlertaHorasExtras().contains('⚠️')
                                ? Colors.orange
                                : Colors.green,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ],
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
    );
  }
}

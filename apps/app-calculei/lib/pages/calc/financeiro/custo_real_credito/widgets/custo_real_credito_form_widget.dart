// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Project imports:
import 'package:app_calculei/core/style/shadcn_style.dart';
import 'package:app_calculei/core/themes/manager.dart';
import 'package:app_calculei/constants/calculation_constants.dart';
import 'package:app_calculei/pages/calc/financeiro/custo_real_credito/widgets/controllers/custo_real_credito_controller.dart';
import 'package:app_calculei/pages/calc/financeiro/custo_real_credito/widgets/enums/validation_error.dart';

class CustoRealCreditoFormWidget extends StatelessWidget {
  final CustoRealCreditoController controller;

  const CustoRealCreditoFormWidget({
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
          // Área de exibição de erro
          ListenableBuilder(
            listenable: controller,
            builder: (context, _) {
              if (!controller.hasError) return const SizedBox.shrink();
              return Container(
                padding: const EdgeInsets.all(
                    CalculationConstants.DEFAULT_FORM_PADDING),
                margin: const EdgeInsets.only(
                    bottom: CalculationConstants.FORM_FIELD_SPACING),
                decoration: BoxDecoration(
                  color:
                      isDark ? Colors.red.withValues(alpha: 0.1) : Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isDark
                        ? Colors.red.withValues(alpha: 0.3)
                        : Colors.red.shade200,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 20,
                      color: isDark ? Colors.red.shade300 : Colors.red.shade700,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        controller.errorMessage ?? 'Erro no cálculo',
                        style: TextStyle(
                          color: isDark
                              ? Colors.red.shade300
                              : Colors.red.shade700,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.close,
                        color:
                            isDark ? Colors.red.shade300 : Colors.red.shade700,
                      ),
                      onPressed: controller.clearError,
                      iconSize: 16,
                    ),
                  ],
                ),
              );
            },
          ),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: StreamBuilder<ValidationError?>(
                  stream: controller.currencyValidation,
                  builder: (context, snapshot) {
                    return _buildAnimatedTextField(
                      isDark: isDark,
                      controller: controller.valorAVistaController,
                      labelText: 'Valor à Vista (R\$)',
                      hintText: 'Ex: 1.000,00',
                      prefixIcon: Icon(
                        Icons.attach_money_outlined,
                        color: isDark ? Colors.green.shade300 : Colors.green,
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [controller.formatoMoeda],
                      validator: (value) => controller.validationService
                          .validateCurrency(value, 'o valor à vista'),
                      errorText: snapshot.data?.message,
                    );
                  },
                ),
              ),
              const SizedBox(width: CalculationConstants.FORM_FIELD_SPACING),
              Expanded(
                child: StreamBuilder<ValidationError?>(
                  stream: controller.currencyValidation,
                  builder: (context, snapshot) {
                    return _buildAnimatedTextField(
                      isDark: isDark,
                      controller: controller.valorParcelaController,
                      labelText: 'Valor da Parcela (R\$)',
                      hintText: 'Ex: 100,00',
                      prefixIcon: Icon(
                        Icons.payments_outlined,
                        color: isDark ? Colors.blue.shade300 : Colors.blue,
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [controller.formatoMoeda],
                      validator: (value) => controller.validationService
                          .validateCurrency(value, 'o valor da parcela'),
                      errorText: snapshot.data?.message,
                    );
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: CalculationConstants.FORM_FIELD_SPACING),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: StreamBuilder<ValidationError?>(
                  stream: controller.installmentsValidation,
                  builder: (context, snapshot) {
                    return _buildAnimatedTextField(
                      isDark: isDark,
                      controller: controller.numeroParcelasController,
                      labelText: 'Número de Parcelas',
                      hintText: 'Ex: 12',
                      prefixIcon: Icon(
                        Icons.calendar_today_outlined,
                        color: isDark ? Colors.purple.shade300 : Colors.purple,
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      validator: (value) => controller.validationService
                          .validateInstallments(value),
                      errorText: snapshot.data?.message,
                    );
                  },
                ),
              ),
              const SizedBox(width: CalculationConstants.FORM_FIELD_SPACING),
              Expanded(
                child: StreamBuilder<ValidationError?>(
                  stream: controller.rateValidation,
                  builder: (context, snapshot) {
                    return _buildAnimatedTextField(
                      isDark: isDark,
                      controller: controller.taxaInvestimentoController,
                      labelText: 'Taxa de Juros do Investimento (% a.m.)',
                      hintText: 'Ex: 0,7',
                      prefixIcon: Icon(
                        Icons.percent_outlined,
                        color: isDark ? Colors.amber.shade300 : Colors.amber,
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        controller.formattingService.percentageFormatter
                      ],
                      validator: (value) => controller.validationService
                          .validateInvestmentRate(value),
                      errorText: snapshot.data?.message,
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedTextField({
    required bool isDark,
    required TextEditingController controller,
    required String labelText,
    required String hintText,
    required Widget prefixIcon,
    required TextInputType keyboardType,
    required List<TextInputFormatter> inputFormatters,
    required String? Function(String?) validator,
    String? errorText,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(
        begin: 0.0,
        end: errorText != null ? 1.0 : 0.0,
      ),
      duration: const Duration(milliseconds: 200),
      builder: (context, value, child) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              if (value > 0)
                BoxShadow(
                  color: (isDark ? Colors.red.shade900 : Colors.red.shade200)
                      .withValues(alpha: value * 0.2),
                  blurRadius: 8,
                  spreadRadius: -2,
                ),
            ],
          ),
          child: child,
        );
      },
      child: Focus(
        child: TextFormField(
          controller: controller,
          style: TextStyle(color: ShadcnStyle.textColor),
          decoration: InputDecoration(
            labelText: labelText,
            hintText: hintText,
            prefixIcon: prefixIcon,
            errorText: errorText,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: isDark ? Colors.blue.shade300 : Colors.blue,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: isDark ? Colors.red.shade300 : Colors.red,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: isDark ? Colors.red.shade300 : Colors.red,
                width: 2,
              ),
            ),
            labelStyle: TextStyle(
              color: errorText != null
                  ? (isDark ? Colors.red.shade300 : Colors.red)
                  : ShadcnStyle.mutedTextColor,
            ),
            hintStyle: TextStyle(color: ShadcnStyle.mutedTextColor),
            errorStyle: TextStyle(
              color: isDark ? Colors.red.shade300 : Colors.red,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
            filled: true,
            fillColor: isDark ? Colors.grey.shade900 : Colors.grey.shade50,
          ),
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          validator: validator,
        ),
      ),
    );
  }
}

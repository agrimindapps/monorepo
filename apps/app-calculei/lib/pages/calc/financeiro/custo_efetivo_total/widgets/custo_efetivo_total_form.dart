// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Project imports:
import 'package:app_calculei/core/style/shadcn_style.dart';
import 'package:app_calculei/core/themes/manager.dart';
import 'package:app_calculei/pages/calc/financeiro/custo_efetivo_total/widgets/controllers/custo_efetivo_total_controller.dart';
import 'package:app_calculei/pages/calc/financeiro/custo_efetivo_total/widgets/formatters/currency_input_formatter.dart';
import 'package:app_calculei/pages/calc/financeiro/custo_efetivo_total/widgets/formatters/percent_input_formatter.dart';

class CustoEfetivoTotalForm extends StatelessWidget {
  final CustoEfetivoTotalController controller;

  const CustoEfetivoTotalForm({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = ThemeManager().isDark.value;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Informe os valores para o cálculo',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: ShadcnStyle.textColor,
          ),
        ),
        const SizedBox(height: 25),
        _buildTextField(
          isDark: isDark,
          labelText: 'Valor do empréstimo',
          hintText: 'R\$ 0,00',
          controller: controller.valorEmprestimoController,
          focusNode: controller.valorEmprestimoFocus,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            CurrencyInputFormatter(),
          ],
          prefixIcon: Icon(
            Icons.attach_money_outlined,
            color: isDark ? Colors.green.shade300 : Colors.green,
          ),
        ),
        const SizedBox(height: 16),
        _buildTextField(
          isDark: isDark,
          labelText: 'Número de parcelas',
          hintText: '12',
          controller: controller.numeroParcelasController,
          focusNode: controller.numeroParcelasFocus,
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
          ],
          prefixIcon: Icon(
            Icons.calendar_month_outlined,
            color: isDark ? Colors.blue.shade300 : Colors.blue,
          ),
        ),
        const SizedBox(height: 16),
        _buildTextField(
          isDark: isDark,
          labelText: 'Taxa de juros anual (%)',
          hintText: '15,00',
          controller: controller.taxaJurosAnualController,
          focusNode: controller.taxaJurosAnualFocus,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[0-9,\.]')),
            PercentInputFormatter(),
          ],
          prefixIcon: Icon(
            Icons.percent,
            color: isDark ? Colors.purple.shade300 : Colors.purple,
          ),
        ),
        const SizedBox(height: 20),
        const Divider(thickness: 1),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Text(
            'Taxas e encargos adicionais',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: ShadcnStyle.textColor,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        _buildTextField(
          isDark: isDark,
          labelText: 'Taxa administrativa (%)',
          hintText: '0,00',
          controller: controller.taxaAdministrativaController,
          focusNode: controller.taxaAdministrativaFocus,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[0-9,\.]')),
            PercentInputFormatter(),
          ],
          prefixIcon: Icon(
            Icons.request_quote_outlined,
            color: isDark ? Colors.amber.shade300 : Colors.amber,
          ),
        ),
        const SizedBox(height: 16),
        _buildTextField(
          isDark: isDark,
          labelText: 'Seguro',
          hintText: 'R\$ 0,00',
          controller: controller.seguroController,
          focusNode: controller.seguroFocus,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            CurrencyInputFormatter(),
          ],
          prefixIcon: Icon(
            Icons.shield_outlined,
            color: isDark ? Colors.teal.shade300 : Colors.teal,
          ),
        ),
        const SizedBox(height: 16),
        _buildTextField(
          isDark: isDark,
          labelText: 'IOF (%)',
          hintText: '0,38',
          controller: controller.iofController,
          focusNode: controller.iofFocus,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[0-9,\.]')),
            PercentInputFormatter(),
          ],
          prefixIcon: Icon(
            Icons.account_balance_outlined,
            color: isDark ? Colors.indigo.shade300 : Colors.indigo,
          ),
        ),
        const SizedBox(height: 16),
        _buildTextField(
          isDark: isDark,
          labelText: 'Outras taxas',
          hintText: 'R\$ 0,00',
          controller: controller.outrasTaxasController,
          focusNode: controller.outrasTaxasFocus,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            CurrencyInputFormatter(),
          ],
          prefixIcon: Icon(
            Icons.more_horiz,
            color: isDark ? Colors.grey.shade300 : Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton.icon(
              onPressed: controller.limparCampos,
              icon: const Icon(Icons.refresh),
              label: const Text('Limpar'),
              style: ShadcnStyle.textButtonStyle,
            ),
            const SizedBox(width: 16),
            ElevatedButton.icon(
              onPressed: controller.calcular,
              style: ShadcnStyle.primaryButtonStyle,
              icon: const Icon(Icons.calculate_outlined),
              label: const Text('Calcular'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTextField({
    required bool isDark,
    required String labelText,
    required String hintText,
    required TextEditingController controller,
    required FocusNode focusNode,
    required TextInputType keyboardType,
    required List<TextInputFormatter> inputFormatters,
    required Widget prefixIcon,
  }) {
    return TextField(
      controller: controller,
      focusNode: focusNode,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      style: TextStyle(color: ShadcnStyle.textColor),
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        prefixIcon: prefixIcon,
        border: const OutlineInputBorder(),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: isDark ? Colors.blue.shade300 : Colors.blue,
            width: 2,
          ),
        ),
        labelStyle: TextStyle(color: ShadcnStyle.mutedTextColor),
        hintStyle: TextStyle(color: ShadcnStyle.mutedTextColor),
        suffixIcon: IconButton(
          icon: Icon(
            Icons.clear,
            color: ShadcnStyle.mutedTextColor,
          ),
          onPressed: () => controller.clear(),
        ),
      ),
    );
  }
}

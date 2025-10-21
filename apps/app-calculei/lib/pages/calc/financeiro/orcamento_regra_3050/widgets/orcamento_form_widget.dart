// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Package imports:
import 'package:provider/provider.dart';

// Project imports:
import 'package:app_calculei/core/style/shadcn_style.dart';
import 'package:app_calculei/core/themes/manager.dart';
import 'package:app_calculei/pages/calc/financeiro/custo_efetivo_total/formatters/currency_input_formatter.dart';
import 'package:app_calculei/pages/calc/financeiro/orcamento_regra_3050/widgets/controllers/orcamento_controller.dart';

class OrcamentoFormWidget extends StatefulWidget {
  const OrcamentoFormWidget({super.key});

  @override
  State<OrcamentoFormWidget> createState() => _OrcamentoFormWidgetState();
}

class _OrcamentoFormWidgetState extends State<OrcamentoFormWidget> {
  final _rendaTotalController = TextEditingController();
  final _despesasEssenciaisController = TextEditingController();
  final _despesasNaoEssenciaisController = TextEditingController();
  final _investimentosController = TextEditingController();

  final _rendaTotalFocus = FocusNode();
  final _despesasEssenciaisFocus = FocusNode();
  final _despesasNaoEssenciaisFocus = FocusNode();
  final _investimentosFocus = FocusNode();

  @override
  void dispose() {
    _rendaTotalController.dispose();
    _despesasEssenciaisController.dispose();
    _despesasNaoEssenciaisController.dispose();
    _investimentosController.dispose();
    _rendaTotalFocus.dispose();
    _despesasEssenciaisFocus.dispose();
    _despesasNaoEssenciaisFocus.dispose();
    _investimentosFocus.dispose();
    super.dispose();
  }

  Widget _buildTextField({
    required String labelText,
    required String hintText,
    required TextEditingController controller,
    required FocusNode focusNode,
    required IconData icon,
    Color? iconColor,
  }) {
    final isDark = ThemeManager().isDark.value;

    return TextField(
      controller: controller,
      focusNode: focusNode,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        CurrencyInputFormatter(),
        TextInputFormatter.withFunction((oldValue, newValue) {
          final text = newValue.text.replaceAll('.', ',');
          return TextEditingValue(
            text: text,
            selection: TextSelection.collapsed(offset: text.length),
          );
        }),
      ],
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        prefixIcon: Icon(
          icon,
          color: iconColor ?? (isDark ? Colors.blue.shade300 : Colors.blue),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
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
            color: Theme.of(context).colorScheme.primary,
            width: 2,
          ),
        ),
        filled: true,
        fillColor:
            isDark ? Colors.grey.shade800.withValues(alpha: 0.5) : Colors.white,
        suffixIcon: IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () => controller.clear(),
          tooltip: 'Limpar',
        ),
      ),
      style: TextStyle(
        color: isDark ? Colors.grey.shade100 : Colors.grey.shade900,
      ),
    );
  }

  void _limparCampos() {
    _rendaTotalController.clear();
    _despesasEssenciaisController.clear();
    _despesasNaoEssenciaisController.clear();
    _investimentosController.clear();
    context.read<OrcamentoController>().limpar();
  }

  void _calcular() {
    try {
      context.read<OrcamentoController>().calcular(
            _rendaTotalController.text,
            _despesasEssenciaisController.text,
            _despesasNaoEssenciaisController.text,
            _investimentosController.text,
          );
    } catch (e) {
      ScaffoldMessenger.of(context)
        ..clearSnackBars()
        ..showSnackBar(SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(child: Text(e.toString())),
            ],
          ),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;
    final isDark = ThemeManager().isDark.value;

    return Card(
      clipBehavior: Clip.antiAliasWithSaveLayer,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Text(
                'Informe seus dados financeiros',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.grey.shade100 : Colors.grey.shade900,
                ),
              ),
            ),
            _buildTextField(
              labelText: 'Renda Total',
              hintText: 'R\$ 0,00',
              controller: _rendaTotalController,
              focusNode: _rendaTotalFocus,
              icon: Icons.attach_money,
              iconColor: isDark ? Colors.green.shade300 : Colors.green,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              labelText: 'Despesas Essenciais',
              hintText: 'R\$ 0,00',
              controller: _despesasEssenciaisController,
              focusNode: _despesasEssenciaisFocus,
              icon: Icons.home_outlined,
              iconColor: isDark ? Colors.blue.shade300 : Colors.blue,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              labelText: 'Despesas Não Essenciais',
              hintText: 'R\$ 0,00',
              controller: _despesasNaoEssenciaisController,
              focusNode: _despesasNaoEssenciaisFocus,
              icon: Icons.shopping_cart_outlined,
              iconColor: isDark ? Colors.purple.shade300 : Colors.purple,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              labelText: 'Investimentos',
              hintText: 'R\$ 0,00',
              controller: _investimentosController,
              focusNode: _investimentosFocus,
              icon: Icons.trending_up,
              iconColor: isDark ? Colors.amber.shade300 : Colors.amber,
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: _limparCampos,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Limpar'),
                ),
                const SizedBox(width: 16),
                ElevatedButton.icon(
                  onPressed: _calcular,
                  style: ShadcnStyle.primaryButtonStyle,
                  icon: const Icon(Icons.calculate_outlined),
                  label: const Text('Calcular'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

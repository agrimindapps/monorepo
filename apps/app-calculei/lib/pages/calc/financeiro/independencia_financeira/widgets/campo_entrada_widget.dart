// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:app_calculei/core/style/shadcn_style.dart';
import 'package:app_calculei/core/themes/manager.dart';
import 'package:app_calculei/constants/independencia_financeira_constants.dart';
import 'package:app_calculei/constants/independencia_financeira_theme.dart';
import 'package:app_calculei/pages/calc/financeiro/independencia_financeira/widgets/controllers/independencia_financeira_controller.dart';
import 'package:app_calculei/services/validacao_service.dart';

class CampoEntradaWidget extends StatelessWidget {
  final IndependenciaFinanceiraController controller;
  final GlobalKey<FormState> formKey;

  const CampoEntradaWidget({
    super.key,
    required this.controller,
    required this.formKey,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = ThemeManager().isDark.value;
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    Widget buildInputField({
      required TextEditingController textController,
      required String label,
      required String hint,
      required IconData icon,
      Color? iconColor,
      List<ValidacaoService> validacoes = const [],
    }) {
      return Container(
        margin: EdgeInsets.only(bottom: isMobile ? 8.0 : 16.0),
        child: TextFormField(
          controller: textController,
          decoration: IndependenciaFinanceiraTheme.defaultInputDecoration(
            labelText: label,
            hintText: hint,
            errorColor: controller
                    .getValidacoesCampo(label)
                    .any((v) => v.tipo == TipoValidacao.erro)
                ? IndependenciaFinanceiraTheme.errorColor
                : IndependenciaFinanceiraTheme.warningColor,
            prefixIcon: Icon(
              icon,
              color: iconColor ??
                  IndependenciaFinanceiraTheme.getButtonColor(isDark),
            ),
            isDark: isDark,
          ),
          style: TextStyle(
            color: isDark ? ShadcnStyle.textColor : Colors.black87,
            fontSize: 14,
          ),
          keyboardType: TextInputType.number,
          inputFormatters: [controller.formatoMoeda],
        ),
      );
    }

    Widget buildColumn(List<Widget> children) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      );
    }

    final inputs = [
      buildInputField(
        textController: controller.patrimonioAtualController,
        label: IndependenciaFinanceiraConstants.labelPatrimonioAtual,
        hint: IndependenciaFinanceiraConstants.hintPatrimonioAtual,
        icon: Icons.account_balance_wallet_outlined,
        iconColor: isDark ? Colors.green.shade300 : Colors.green,
      ),
      buildInputField(
        textController: controller.aporteMensalController,
        label: IndependenciaFinanceiraConstants.labelAporteMensal,
        hint: IndependenciaFinanceiraConstants.hintAporteMensal,
        icon: Icons.savings_outlined,
        iconColor: isDark ? Colors.amber.shade300 : Colors.amber,
      ),
      buildInputField(
        textController: controller.despesasMensaisController,
        label: IndependenciaFinanceiraConstants.labelDespesasMensais,
        hint: IndependenciaFinanceiraConstants.hintDespesasMensais,
        icon: Icons.trending_up_outlined,
        iconColor: isDark ? Colors.purple.shade300 : Colors.purple,
      ),
      buildInputField(
        textController: controller.retornoInvestimentosController,
        label: IndependenciaFinanceiraConstants.labelRetornoAnual,
        hint: IndependenciaFinanceiraConstants.hintRetornoAnual,
        icon: Icons.percent_outlined,
        iconColor: isDark ? Colors.blue.shade300 : Colors.blue,
      ),
    ];

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: formKey,
          child: isMobile
              ? buildColumn(inputs)
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: buildColumn(inputs.sublist(0, 2))),
                    const SizedBox(
                        width: IndependenciaFinanceiraTheme.defaultSpacing),
                    Expanded(child: buildColumn(inputs.sublist(2))),
                  ],
                ),
        ),
      ),
    );
  }
}

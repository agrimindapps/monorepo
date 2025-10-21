// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:app_calculei/core/style/shadcn_style.dart';
import 'package:app_calculei/core/themes/manager.dart';
import 'package:app_calculei/constants/independencia_financeira_constants.dart';

class IndependenciaFinanceiraInfoDialog extends StatelessWidget {
  const IndependenciaFinanceiraInfoDialog({super.key});

  static void show(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) =>
          const IndependenciaFinanceiraInfoDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = ThemeManager().isDark.value;
    final screenSize = MediaQuery.of(context).size;
    final isMobile = screenSize.width < 600;

    final dialogPadding = isMobile
        ? const EdgeInsets.symmetric(horizontal: 16, vertical: 16)
        : const EdgeInsets.all(20);

    final sectionSpacing = isMobile ? 16.0 : 20.0;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      insetPadding: EdgeInsets.symmetric(
        horizontal: isMobile ? 12.0 : 40.0,
        vertical: isMobile ? 24.0 : 40.0,
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 600,
          maxHeight: screenSize.height * 0.8,
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: dialogPadding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildHeader(isDark),
                SizedBox(height: sectionSpacing),
                _buildSection(
                  'O que é Independência Financeira?',
                  'É o momento em que seus investimentos geram renda suficiente para cobrir todas as suas despesas, sem precisar trabalhar. O cálculo é baseado na famosa "Regra dos 4%", um estudo que indica uma taxa segura de retirada anual do patrimônio.',
                  isDark,
                ),
                SizedBox(height: sectionSpacing),
                _buildSection(
                  'Como funciona a calculadora?',
                  'A calculadora usa suas informações financeiras atuais para projetar quanto tempo levará até atingir a independência financeira, considerando seus aportes mensais e o retorno esperado dos investimentos.',
                  isDark,
                ),
                SizedBox(height: sectionSpacing),
                _buildCamposSection(isDark),
                SizedBox(height: sectionSpacing),
                _buildFormulasSection(isDark),
                SizedBox(height: sectionSpacing),
                _buildExemploSection(isDark),
                SizedBox(height: sectionSpacing),
                _buildDicasSection(isDark),
                const SizedBox(height: 24),
                _buildFooter(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(bool isDark) {
    return Row(
      children: [
        Icon(
          Icons.info_outline,
          color: isDark ? Colors.blue.shade300 : Colors.blue,
          size: 24,
        ),
        const SizedBox(width: 12),
        const Expanded(
          child: Text(
            'Calculadora de Independência Financeira',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSection(String title, String content, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.grey.shade200 : Colors.grey.shade800,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          content,
          style: TextStyle(
            color: isDark ? Colors.grey.shade300 : Colors.grey.shade700,
          ),
        ),
      ],
    );
  }

  Widget _buildCamposSection(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Campos de entrada',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.grey.shade200 : Colors.grey.shade800,
          ),
        ),
        const SizedBox(height: 12),
        Card(
          elevation: 0,
          color: isDark ? Colors.black.withAlpha(51) : Colors.grey.shade50,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(
              color: isDark ? Colors.grey.shade800 : Colors.grey.shade300,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                _buildCampoItem(
                  IndependenciaFinanceiraConstants.labelPatrimonioAtual,
                  'Total atual investido em ativos que geram renda',
                  isDark,
                ),
                _buildCampoItem(
                  IndependenciaFinanceiraConstants.labelDespesasMensais,
                  'Soma de todos os seus gastos mensais',
                  isDark,
                ),
                _buildCampoItem(
                  IndependenciaFinanceiraConstants.labelAporteMensal,
                  'Quanto você consegue investir por mês',
                  isDark,
                ),
                _buildCampoItem(
                  IndependenciaFinanceiraConstants.labelRetornoAnual,
                  'Retorno anual esperado dos investimentos (histórico ou projetado)',
                  isDark,
                ),
                _buildCampoItem(
                  IndependenciaFinanceiraConstants.labelTaxaRetirada,
                  'Percentual anual que você planeja retirar do patrimônio (padrão 4%)',
                  isDark,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCampoItem(String campo, String explicacao, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              campo,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: isDark ? Colors.grey.shade300 : Colors.grey.shade700,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 3,
            child: Text(
              explicacao,
              style: TextStyle(
                color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormulasSection(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Fórmulas utilizadas',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.grey.shade200 : Colors.grey.shade800,
          ),
        ),
        const SizedBox(height: 12),
        Card(
          elevation: 0,
          color: isDark
              ? Colors.indigo.shade900.withValues(alpha: 0.2)
              : Colors.indigo.shade50,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(
              color: isDark ? Colors.indigo.shade700 : Colors.indigo.shade200,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                _buildFormulaItem(
                  'Patrimônio Necessário',
                  '(Despesas Mensais × 12) ÷ Taxa de Retirada',
                  isDark,
                ),
                _buildFormulaItem(
                  'Renda Mensal Atual',
                  '(Patrimônio Atual × Taxa de Retirada) ÷ 12',
                  isDark,
                ),
                _buildFormulaItem(
                  'Evolução do Patrimônio',
                  'Patrimônio × (1 + Retorno Anual) + (Aporte Mensal × 12)',
                  isDark,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFormulaItem(String nome, String formula, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              nome,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: isDark ? Colors.indigo.shade200 : Colors.indigo.shade700,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 3,
            child: Text(
              formula,
              style: TextStyle(
                color: isDark ? Colors.indigo.shade300 : Colors.indigo.shade600,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExemploSection(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Exemplo prático',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.grey.shade200 : Colors.grey.shade800,
          ),
        ),
        const SizedBox(height: 12),
        Card(
          elevation: 0,
          color: isDark
              ? Colors.purple.shade900.withValues(alpha: 0.2)
              : Colors.purple.shade50,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(
              color: isDark ? Colors.purple.shade700 : Colors.purple.shade200,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Cenário:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isDark
                        ? Colors.purple.shade300
                        : Colors.purple.shade700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Uma pessoa gasta R\$ 5.000 por mês e quer viver dos rendimentos. '
                  'Com uma taxa de retirada de 4% ao ano, precisará de R\$ 1.500.000 '
                  '(R\$ 5.000 × 12 ÷ 0,04) em patrimônio para alcançar a independência financeira.',
                  style: TextStyle(
                    color: isDark
                        ? Colors.purple.shade200
                        : Colors.purple.shade800,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDicasSection(bool isDark) {
    return Card(
      elevation: 0,
      color: isDark
          ? Colors.amber.shade900.withValues(alpha: 0.2)
          : Colors.amber.shade50,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: isDark ? Colors.amber.shade700 : Colors.amber.shade200,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.lightbulb_outline,
                  color: isDark ? Colors.amber.shade300 : Colors.amber.shade700,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Dicas importantes',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color:
                        isDark ? Colors.amber.shade300 : Colors.amber.shade700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '• Considere a inflação ao planejar suas despesas futuras\n'
              '• Diversifique seus investimentos para reduzir riscos\n'
              '• Reavalie periodicamente seus objetivos e ajuste o plano\n'
              '• Mantenha uma reserva de emergência separada\n'
              '• Consulte um profissional para orientação personalizada',
              style: TextStyle(
                color: isDark ? Colors.amber.shade100 : Colors.amber.shade900,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: TextButton(
        onPressed: () => Navigator.of(context).pop(),
        style: ShadcnStyle.primaryButtonStyle,
        child: const Text('Entendi'),
      ),
    );
  }
}

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:provider/provider.dart';

// Project imports:
import 'package:app_calculei/core/style/shadcn_style.dart';
import 'package:app_calculei/core/themes/manager.dart';
import 'controllers/juros_compostos_controller.dart';
import 'utils/input_formatters.dart';
import 'widgets/info_dialog.dart';
import 'widgets/result_card.dart';

class JurosCompostosPage extends StatelessWidget {
  const JurosCompostosPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => JurosCompostosController(),
      child: const _JurosCompostosView(),
    );
  }
}

class _JurosCompostosView extends StatelessWidget {
  const _JurosCompostosView();

  @override
  Widget build(BuildContext context) {
    final isDark = ThemeManager().isDark.value;
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
          tooltip: 'Voltar',
        ),
        title: Row(
          children: [
            Icon(
              Icons.monetization_on_outlined,
              size: 20,
              color: isDark ? Colors.green.shade300 : Colors.green,
            ),
            const SizedBox(width: 10),
            const Text('Juros Compostos'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => InfoDialog.show(context),
            tooltip: 'Informações sobre o cálculo',
          ),
        ],
      ),
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: Container(
            constraints: const BoxConstraints(maxWidth: 1120),
            child: SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Card(
                      clipBehavior: Clip.antiAliasWithSaveLayer,
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      child: Padding(
                        padding: const EdgeInsetsDirectional.fromSTEB(
                            16, 24, 16, 16),
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Informe os valores para o cálculo',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: ShadcnStyle.textColor,
                              ),
                            ),
                            const SizedBox(height: 16),
                            _buildInputForm(),
                            const SizedBox(height: 16),
                            _buildButtons(context),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    _buildResults(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputForm() {
    return Consumer<JurosCompostosController>(
      builder: (context, controller, _) {
        final isDark = ThemeManager().isDark.value;

        return Column(
          children: [
            TextFormField(
              decoration: InputDecoration(
                labelText: 'Capital Inicial (R\$)',
                prefixText: 'R\$ ',
                hintText: '0,00',
                border: const OutlineInputBorder(),
                prefixIcon: Icon(
                  Icons.attach_money_outlined,
                  color: isDark ? Colors.amber.shade300 : Colors.amber,
                ),
              ),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: false),
              inputFormatters: [BrazilianCurrencyInputFormatter()],
              onChanged: controller.setCapitalInicial,
            ),
            const SizedBox(height: 16),
            TextFormField(
              decoration: InputDecoration(
                labelText: 'Taxa de Juros (%)',
                suffixText: '% ao mês',
                hintText: '0,0',
                border: const OutlineInputBorder(),
                prefixIcon: Icon(
                  Icons.percent_outlined,
                  color: isDark ? Colors.blue.shade300 : Colors.blue,
                ),
              ),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [PercentageInputFormatter()],
              onChanged: controller.setTaxaJuros,
            ),
            const SizedBox(height: 16),
            TextFormField(
              decoration: InputDecoration(
                labelText: 'Período (meses)',
                suffixText: 'meses',
                hintText: '12',
                border: const OutlineInputBorder(),
                prefixIcon: Icon(
                  Icons.calendar_today_outlined,
                  color: isDark ? Colors.purple.shade300 : Colors.purple,
                ),
              ),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: false),
              inputFormatters: [IntegerWithThousandsFormatter()],
              onChanged: controller.setPeriodo,
            ),
            const SizedBox(height: 16),
            TextFormField(
              decoration: InputDecoration(
                labelText: 'Aporte Mensal (R\$)',
                prefixText: 'R\$ ',
                hintText: '0,00 (opcional)',
                border: const OutlineInputBorder(),
                prefixIcon: Icon(
                  Icons.payments_outlined,
                  color: isDark ? Colors.green.shade300 : Colors.green,
                ),
              ),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: false),
              inputFormatters: [BrazilianCurrencyInputFormatter()],
              onChanged: controller.setAporteMensal,
            ),
            if (controller.error != null) ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  const Icon(
                    Icons.error_outline,
                    color: Colors.red,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    controller.error!,
                    style: TextStyle(
                      color: isDark ? Colors.red.shade300 : Colors.red,
                    ),
                  ),
                ],
              ),
            ],
          ],
        );
      },
    );
  }

  Widget _buildButtons(BuildContext context) {
    return Consumer<JurosCompostosController>(
      builder: (context, controller, _) {
        return Row(
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
              onPressed: controller.isCalculating
                  ? null
                  : controller.calcularJurosCompostos,
              style: ShadcnStyle.primaryButtonStyle,
              icon: const Icon(Icons.calculate_outlined),
              label: controller.isCalculating
                  ? const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(width: 8),
                        Text('Calculando...'),
                      ],
                    )
                  : const Text('Calcular'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildResults() {
    return Consumer<JurosCompostosController>(
      builder: (context, controller, _) {
        final model = controller.model;
        if (model.montanteFinal == null) return const SizedBox.shrink();

        return ResultCard(
          montanteFinal: model.montanteFinal!,
          totalInvestido: model.totalInvestido!,
          totalJuros: model.totalJuros!,
          rendimentoTotal: model.rendimentoTotal!,
        );
      },
    );
  }
}

// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:app_calculei/core/themes/manager.dart';
import 'constants/independencia_financeira_theme.dart';
import 'controllers/independencia_financeira_controller.dart';
import 'widgets/campo_entrada_widget.dart';
import 'widgets/grafico_evolucao_widget.dart';
import 'widgets/info_dialog_widget.dart';
import 'widgets/resultado_widget.dart';

class IndependenciaFinanceiraPage extends StatefulWidget {
  const IndependenciaFinanceiraPage({super.key});

  @override
  State<IndependenciaFinanceiraPage> createState() =>
      _IndependenciaFinanceiraPageState();
}

class _IndependenciaFinanceiraPageState
    extends State<IndependenciaFinanceiraPage> {
  final _controller = IndependenciaFinanceiraController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _mostrarInfoDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) =>
          const IndependenciaFinanceiraInfoDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = ThemeManager().isDark.value;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
          tooltip: 'Voltar',
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.attach_money_outlined,
              size: IndependenciaFinanceiraTheme.defaultIconSize,
              color: IndependenciaFinanceiraTheme.getButtonColor(isDark),
            ),
            const SizedBox(width: 10),
            const Text('Calculadora de Independência Financeira'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            tooltip: 'Informações sobre a calculadora',
            onPressed: _mostrarInfoDialog,
          ),
        ],
      ),
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: SingleChildScrollView(
            padding: IndependenciaFinanceiraTheme.defaultPagePadding,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1120),
              child: ListenableBuilder(
                listenable: _controller,
                builder: (context, _) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              CampoEntradaWidget(
                                controller: _controller,
                                formKey: _formKey,
                              ),
                              const SizedBox(height: 16),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  TextButton(
                                    onPressed: _controller.limpar,
                                    style: TextButton.styleFrom(
                                      foregroundColor: isDark
                                          ? Colors.grey.shade300
                                          : Colors.grey.shade700,
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.refresh,
                                          size: 20,
                                          color: isDark
                                              ? Colors.grey.shade300
                                              : Colors.grey.shade700,
                                        ),
                                        const SizedBox(width: 8),
                                        const Text('Limpar'),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  ElevatedButton(
                                    onPressed: () {
                                      if (_formKey.currentState!.validate()) {
                                        _controller.calcular();
                                      }
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.black,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16, vertical: 12),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    child: const Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.calculate_outlined,
                                            size: 20),
                                        SizedBox(width: 8),
                                        Text('Calcular'),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(
                          height: IndependenciaFinanceiraTheme.defaultSpacing),
                      ResultadoWidget(controller: _controller),
                      if (_controller.calculoRealizado) ...[
                        const SizedBox(
                            height:
                                IndependenciaFinanceiraTheme.defaultSpacing),
                        Card(
                          elevation:
                              IndependenciaFinanceiraTheme.defaultCardElevation,
                          shape: IndependenciaFinanceiraTheme.cardShape,
                          child: Padding(
                            padding:
                                IndependenciaFinanceiraTheme.defaultCardPadding,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Evolução do Patrimônio',
                                  style:
                                      IndependenciaFinanceiraTheme.titleStyle,
                                ),
                                const SizedBox(
                                    height: IndependenciaFinanceiraTheme
                                        .defaultSpacing),
                                GraficoEvolucaoWidget(controller: _controller),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

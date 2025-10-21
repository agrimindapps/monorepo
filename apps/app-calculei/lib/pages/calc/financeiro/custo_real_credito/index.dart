// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:app_calculei/core/style/shadcn_style.dart';
import 'package:app_calculei/core/themes/manager.dart';
import 'controllers/custo_real_credito_controller.dart';
import 'widgets/custo_real_credito_form_widget.dart';
import 'widgets/custo_real_credito_result_widget.dart';
import 'widgets/info_dialog.dart';

class CustoRealCreditoPage extends StatefulWidget {
  const CustoRealCreditoPage({super.key});

  @override
  State<CustoRealCreditoPage> createState() => _CustoRealCreditoPageState();
}

class _CustoRealCreditoPageState extends State<CustoRealCreditoPage> {
  final controller = CustoRealCreditoController();

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
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
          children: [
            Icon(
              Icons.credit_card_outlined,
              size: 20,
              color: isDark ? Colors.green.shade300 : Colors.green,
            ),
            const SizedBox(width: 10),
            const Text('Custo Real do Crédito'),
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
            child: ListenableBuilder(
              listenable: controller,
              builder: (context, _) {
                return SingleChildScrollView(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    children: [
                      Card(
                        clipBehavior: Clip.antiAliasWithSaveLayer,
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsetsDirectional.fromSTEB(
                              16, 24, 16, 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Informe os dados da compra',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: ShadcnStyle.textColor,
                                ),
                              ),
                              const SizedBox(height: 16),
                              CustoRealCreditoFormWidget(
                                  controller: controller),
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
                                    onPressed: controller.isCalculating
                                        ? null
                                        : _handleCalculate,
                                    style: ShadcnStyle.primaryButtonStyle,
                                    icon: controller.isCalculating
                                        ? const SizedBox(
                                            width: 16,
                                            height: 16,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: Colors.white,
                                            ),
                                          )
                                        : const Icon(Icons.calculate_outlined),
                                    label: Text(controller.isCalculating
                                        ? 'Calculando...'
                                        : 'Calcular'),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      if (controller.resultadoVisivel) ...[
                        const SizedBox(height: 24),
                        AnimatedOpacity(
                          opacity: controller.resultadoVisivel ? 1.0 : 0.0,
                          duration: const Duration(milliseconds: 500),
                          child: CustoRealCreditoResultWidget(
                              controller: controller),
                        ),
                      ],
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleCalculate() async {
    try {
      await Future.delayed(const Duration(milliseconds: 300));
      controller.calcular();
    } catch (e) {
      // Error handling will be managed by the controller
      debugPrint('Error during calculation: $e');
    }
  }
}

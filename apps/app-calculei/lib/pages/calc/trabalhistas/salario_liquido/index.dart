// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:app_calculei/core/style/shadcn_style.dart';
import 'controllers/salario_liquido_controller.dart';
import 'widgets/salario_liquido_form_widget.dart';
import 'widgets/salario_liquido_result_widget.dart';

class SalarioLiquidoPage extends StatefulWidget {
  const SalarioLiquidoPage({super.key});
  
  @override
  State<SalarioLiquidoPage> createState() => _SalarioLiquidoPageState();
}

class _SalarioLiquidoPageState extends State<SalarioLiquidoPage> {
  late final SalarioLiquidoController controller;
  
  @override
  void initState() {
    super.initState();
    controller = SalarioLiquidoController();
  }
  
  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Row(
          children: [
            Icon(Icons.calculate, color: Colors.green),
            SizedBox(width: 8),
            Text('Salário Líquido'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => _showInfo(context),
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
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      // Form Card
                      Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Calcule seu salário líquido',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: ShadcnStyle.textColor,
                                ),
                              ),
                              const SizedBox(height: 16),
                              
                              SalarioLiquidoFormWidget(controller: controller),
                              
                              const SizedBox(height: 24),
                              
                              // Buttons
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  TextButton.icon(
                                    onPressed: controller.limparCampos,
                                    icon: const Icon(Icons.clear),
                                    label: const Text('Limpar'),
                                    style: ShadcnStyle.textButtonStyle,
                                  ),
                                  const SizedBox(width: 16),
                                  ElevatedButton.icon(
                                    onPressed: controller.isCalculating 
                                      ? null 
                                      : controller.calcular,
                                    icon: controller.isCalculating
                                      ? const SizedBox(
                                          width: 16,
                                          height: 16,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: Colors.white,
                                          ),
                                        )
                                      : const Icon(Icons.calculate),
                                    label: Text(
                                      controller.isCalculating 
                                        ? 'Calculando...' 
                                        : 'Calcular',
                                    ),
                                    style: ShadcnStyle.primaryButtonStyle,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      
                      // Result
                      if (controller.showResult) ...[
                        const SizedBox(height: 24),
                        AnimatedOpacity(
                          opacity: controller.showResult ? 1.0 : 0.0,
                          duration: const Duration(milliseconds: 500),
                          child: SalarioLiquidoResultWidget(controller: controller),
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
  
  void _showInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sobre a Calculadora'),
        content: const Text(
          'Esta calculadora calcula o salário líquido considerando:\n\n'
          '• Desconto do INSS (faixas progressivas)\n'
          '• Desconto do IRRF (com dependentes)\n'
          '• Vale transporte (máximo 6% do salário)\n'
          '• Plano de saúde e outros descontos\n\n'
          'Os valores são baseados na legislação de 2024.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }
}

// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:app_calculei/core/style/shadcn_style.dart';
import 'controllers/ferias_controller.dart';
import 'widgets/ferias_form_widget.dart';
import 'widgets/ferias_result_widget.dart';

class FeriasPage extends StatefulWidget {
  const FeriasPage({super.key});
  
  @override
  State<FeriasPage> createState() => _FeriasPageState();
}

class _FeriasPageState extends State<FeriasPage> {
  late final FeriasController controller;
  
  @override
  void initState() {
    super.initState();
    controller = FeriasController();
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
            Icon(Icons.beach_access, color: Colors.blue),
            SizedBox(width: 8),
            Text('Cálculo de Férias'),
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
                                'Calcule suas férias',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: ShadcnStyle.textColor,
                                ),
                              ),
                              const SizedBox(height: 16),
                              
                              FeriasFormWidget(controller: controller),
                              
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
                          child: FeriasResultWidget(controller: controller),
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
        title: const Text('Sobre o Cálculo de Férias'),
        content: const Text(
          'As férias são um direito do trabalhador após 12 meses de trabalho.\n\n'
          'Características:\n'
          '• Período: Até 30 dias por ano\n'
          '• Abono constitucional: +1/3 do valor\n'
          '• Abono pecuniário: Venda de até 1/3 das férias\n'
          '• Faltas: Podem reduzir o direito às férias\n'
          '• Descontos: INSS e IRRF (se aplicável)\n\n'
          'Tabela de faltas:\n'
          '• 0-5 faltas: 30 dias\n'
          '• 6-14 faltas: 24 dias\n'
          '• 15-23 faltas: 18 dias\n'
          '• 24-32 faltas: 12 dias\n'
          '• 33+ faltas: Perde o direito\n\n'
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

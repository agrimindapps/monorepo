// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:app_calculei/core/style/shadcn_style.dart';
import 'controllers/decimo_terceiro_controller.dart';
import 'widgets/decimo_terceiro_form_widget.dart';
import 'widgets/decimo_terceiro_result_widget.dart';

class DecimoTerceiroPage extends StatefulWidget {
  const DecimoTerceiroPage({super.key});
  
  @override
  State<DecimoTerceiroPage> createState() => _DecimoTerceiroPageState();
}

class _DecimoTerceiroPageState extends State<DecimoTerceiroPage> {
  late final DecimoTerceiroController controller;
  
  @override
  void initState() {
    super.initState();
    controller = DecimoTerceiroController();
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
            Icon(Icons.card_giftcard, color: Colors.green),
            SizedBox(width: 8),
            Text('Décimo Terceiro Salário'),
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
                                'Calcule seu décimo terceiro salário',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: ShadcnStyle.textColor,
                                ),
                              ),
                              const SizedBox(height: 16),
                              
                              DecimoTerceiroFormWidget(controller: controller),
                              
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
                          child: DecimoTerceiroResultWidget(controller: controller),
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
        title: const Text('Sobre o Décimo Terceiro'),
        content: const Text(
          'O décimo terceiro salário é um benefício obrigatório que deve ser pago até 20 de dezembro.\n\n'
          'Características:\n'
          '• Valor: 1/12 do salário por mês trabalhado\n'
          '• Descontos: INSS e IRRF (se aplicável)\n'
          '• Antecipação: Pode ser paga em duas parcelas\n'
          '• Faltas: Mais de 15 faltas não justificadas por mês desconta 1/12\n\n'
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

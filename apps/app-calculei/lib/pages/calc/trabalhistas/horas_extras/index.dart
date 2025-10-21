// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:app_calculei/core/style/shadcn_style.dart';
import 'controllers/horas_extras_controller.dart';
import 'widgets/horas_extras_form_widget.dart';
import 'widgets/horas_extras_result_widget.dart';

class HorasExtrasPage extends StatefulWidget {
  const HorasExtrasPage({super.key});
  
  @override
  State<HorasExtrasPage> createState() => _HorasExtrasPageState();
}

class _HorasExtrasPageState extends State<HorasExtrasPage> {
  late final HorasExtrasController controller;
  
  @override
  void initState() {
    super.initState();
    controller = HorasExtrasController();
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
            Icon(Icons.schedule, color: Colors.orange),
            SizedBox(width: 8),
            Text('Horas Extras'),
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
                                'Calcule suas horas extras',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: ShadcnStyle.textColor,
                                ),
                              ),
                              const SizedBox(height: 16),
                              
                              HorasExtrasFormWidget(controller: controller),
                              
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
                          child: HorasExtrasResultWidget(controller: controller),
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
        title: const Text('Sobre Horas Extras'),
        content: const Text(
          'As horas extras são horas trabalhadas além da jornada normal.\n\n'
          'Tipos de horas extras:\n'
          '• 50%: Horas extras normais (dias úteis)\n'
          '• 100%: Domingos e feriados\n'
          '• Noturno: 22h às 5h (mín. 20% adicional)\n\n'
          'Reflexos das horas extras:\n'
          '• DSR: 1/6 sobre horas extras\n'
          '• Férias: 1/12 sobre horas extras\n'
          '• 13º salário: 1/12 sobre horas extras\n\n'
          'Descontos:\n'
          '• INSS sobre o total bruto\n'
          '• IRRF sobre (bruto - INSS)\n\n'
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

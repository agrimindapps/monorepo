// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../../../core/style/shadcn_style.dart';
import '../../../../core/themes/manager.dart';
import '../../../widgets/page_header_widget.dart';
import 'controller/fluidoterapia_controller.dart';
import 'widgets/input_card_widget.dart';
import 'widgets/result_card_widget.dart';

class FluidoterapiaPage extends StatefulWidget {
  const FluidoterapiaPage({super.key});

  @override
  _FluidoterapiaPageState createState() => _FluidoterapiaPageState();
}

class _FluidoterapiaPageState extends State<FluidoterapiaPage> {
  final _controller = FluidoterapiaController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _showInfoDialog() {
    final isDark = ThemeManager().isDark.value;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? ShadcnStyle.backgroundColor : Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: isDark ? Colors.blue.shade300 : Colors.blue,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Sobre a Calculadora de Fluidoterapia',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: ShadcnStyle.textColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Como funciona:',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: ShadcnStyle.textColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Esta calculadora ajuda a determinar a quantidade de fluidos necessários para um animal com base no peso e no percentual de hidratação.',
                    style: TextStyle(color: ShadcnStyle.textColor),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Resultados fornecidos:',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: ShadcnStyle.textColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '• Volume total de fluidos necessário\n'
                    '• Taxa de gotejamento recomendada\n'
                    '• Tempo de administração sugerido\n'
                    '• Orientações de monitoramento',
                    style: TextStyle(color: ShadcnStyle.textColor),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Parâmetros considerados:',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: ShadcnStyle.textColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '• Peso do animal\n'
                    '• Percentual de desidratação\n'
                    '• Necessidades de manutenção\n'
                    '• Tipo de fluido a ser administrado',
                    style: TextStyle(color: ShadcnStyle.textColor),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.amber.shade900.withValues(alpha: 0.2)
                          : Colors.amber.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isDark
                            ? Colors.amber.shade700.withValues(alpha: 0.3)
                            : Colors.amber.shade200,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.warning_amber_outlined,
                          color: isDark
                              ? Colors.amber.shade300
                              : Colors.amber.shade700,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'ATENÇÃO: Esta é apenas uma ferramenta de referência. Sempre consulte um médico veterinário para determinar as necessidades específicas do animal.',
                            style: TextStyle(
                              fontSize: 14,
                              color: ShadcnStyle.textColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: ShadcnStyle.primaryButtonStyle,
                      child: const Text('Fechar'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _onCalcular() {
    if (_controller.calcular()) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      body: SingleChildScrollView(
        child: Center(
          child: SizedBox(
            width: 1120,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  InputCardWidget(
                    controller: _controller,
                    onCalcular: _onCalcular,
                  ),
                  ResultCardWidget(model: _controller.model),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(kToolbarHeight + 16),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
          child: PageHeaderWidget(
            title: 'Fluidoterapia',
            subtitle: 'Calcule volumes e taxas de fluidoterapia',
            icon: Icons.opacity,
            showBackButton: true,
            actions: [
              IconButton(
                icon: const Icon(Icons.info_outline),
                onPressed: _showInfoDialog,
                tooltip: 'Informações sobre fluidoterapia',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:provider/provider.dart';

// Project imports:
import '../../../../core/style/shadcn_style.dart';
import '../../../../core/themes/manager.dart';
import '../../../widgets/page_header_widget.dart';
import 'controller/hidratacao_fluidoterapia_controller.dart';
import 'widgets/alert_card_widget.dart';
import 'widgets/input_form_widget.dart';
import 'widgets/reference_card_widget.dart';
import 'widgets/result_card_widget.dart';

class CalcHidratacaoFluidoterapiaPage extends StatefulWidget {
  const CalcHidratacaoFluidoterapiaPage({super.key});

  @override
  State<CalcHidratacaoFluidoterapiaPage> createState() =>
      _CalcHidratacaoFluidoterapiaPageState();
}

class _CalcHidratacaoFluidoterapiaPageState
    extends State<CalcHidratacaoFluidoterapiaPage> {
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
                          'Sobre Hidratação e Fluidoterapia',
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
                    'Esta calculadora ajuda a estimar as necessidades de fluidos para animais desidratados ou que necessitam de fluidoterapia.',
                    style: TextStyle(color: ShadcnStyle.textColor),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Cálculo considera:',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: ShadcnStyle.textColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '• Déficit de hidratação (baseado no grau de desidratação)\n'
                    '• Necessidades de manutenção diária\n'
                    '• Perdas correntes (vômitos, diarreia, etc.)\n'
                    '• Volume total e taxa de administração',
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
                    '• Taxa de administração (mL/h)\n'
                    '• Recomendações de administração\n'
                    '• Orientações de monitoramento',
                    style: TextStyle(color: ShadcnStyle.textColor),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.red.shade900.withValues(alpha: 0.2)
                          : Colors.red.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isDark
                            ? Colors.red.shade700.withValues(alpha: 0.3)
                            : Colors.red.shade200,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.warning_amber_outlined,
                          color: isDark
                              ? Colors.red.shade300
                              : Colors.red.shade700,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'IMPORTANTE: Este cálculo é apenas uma estimativa. Sempre monitore o paciente e ajuste conforme necessário. Em casos graves, procure atendimento veterinário imediato.',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
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

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => HidratacaoFluidoterapiaController(),
      child: Scaffold(
        appBar: _buildAppBar(context),
        body: Consumer<HidratacaoFluidoterapiaController>(
          builder: (context, controller, _) {
            return SingleChildScrollView(
              child: Center(
                child: SizedBox(
                  width: 1120,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        const AlertCardWidget(),
                        const InputFormWidget(),
                        const ReferenceCardWidget(),
                        ResultCardWidget(modelo: controller.resultado),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
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
          child: Consumer<HidratacaoFluidoterapiaController>(
            builder: (context, controller, _) {
              return PageHeaderWidget(
                title: 'Hidratação e Fluidoterapia',
                subtitle: 'Calcule necessidades de hidratação e fluidos',
                icon: Icons.water_drop,
                showBackButton: true,
                actions: [
                  IconButton(
                    icon: const Icon(Icons.info_outline),
                    onPressed: _showInfoDialog,
                    tooltip: 'Informações sobre hidratação',
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

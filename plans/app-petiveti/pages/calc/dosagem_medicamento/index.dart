// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../../../core/style/shadcn_style.dart';
import '../../../../core/themes/manager.dart';
import '../../../widgets/page_header_widget.dart';
import 'controller/dosagem_medicamentos_controller.dart';
import 'widgets/info_card_widget.dart';
import 'widgets/input_form_widget.dart';
import 'widgets/result_card_widget.dart';

class DosagemMedicamentosPage extends StatefulWidget {
  const DosagemMedicamentosPage({super.key});

  @override
  State<DosagemMedicamentosPage> createState() =>
      _DosagemMedicamentosPageState();
}

class _DosagemMedicamentosPageState extends State<DosagemMedicamentosPage> {
  late final DosagemMedicamentosController _controller;

  @override
  void initState() {
    super.initState();
    _controller = DosagemMedicamentosController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      body: ListenableBuilder(
        listenable: _controller,
        builder: (context, _) {
          return SingleChildScrollView(
            child: Center(
              child: SizedBox(
                width: 1120,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      if (_controller.model.showInfoCard)
                        InfoCardWidget(controller: _controller),
                      InputFormWidget(controller: _controller),
                      ResultCardWidget(controller: _controller),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
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
            title: 'Dosagem de Medicamentos',
            subtitle: 'Calcule dosagens precisas de medicamentos',
            icon: Icons.medication,
            showBackButton: true,
            actions: [
              IconButton(
                icon: const Icon(Icons.warning_amber),
                onPressed: _showAlertDialog,
                tooltip: 'Alertas importantes',
              ),
              IconButton(
                icon: const Icon(Icons.info_outline),
                onPressed: _controller.toggleInfoCard,
                tooltip: 'Informações sobre dosagens',
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAlertDialog() {
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
                        Icons.warning_amber,
                        color: isDark ? Colors.red.shade300 : Colors.red,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'ALERTA DE SEGURANÇA',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.red.shade300 : Colors.red,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'IMPORTANTE - USO RESTRITO:',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isDark
                                ? Colors.red.shade300
                                : Colors.red.shade700,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '• Esta calculadora destina-se apenas para referência educacional\n'
                          '• Deve ser usada SOMENTE por médicos veterinários qualificados\n'
                          '• As dosagens sugeridas são apenas guias gerais\n'
                          '• Fatores individuais podem alterar a dose apropriada\n'
                          '• Sempre considere a condição clínica do paciente\n'
                          '• Monitore constantemente a resposta ao tratamento\n'
                          '• Consulte a bula do medicamento para informações específicas',
                          style: TextStyle(
                            fontSize: 14,
                            color: ShadcnStyle.textColor,
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
                      child: const Text('Entendi'),
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
}

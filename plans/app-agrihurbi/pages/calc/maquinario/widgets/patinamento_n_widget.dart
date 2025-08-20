// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:get/get.dart';

// Project imports:
import '../../../../../core/style/shadcn_style.dart';
import '../../../../../core/themes/manager.dart';
import '../../../../../core/widgets/textfield_widget.dart';
import '../controllers/maquinario_controller.dart';

class PatinamentoNWidget extends StatefulWidget {
  const PatinamentoNWidget({super.key});

  @override
  PatinamentoNWidgetState createState() => PatinamentoNWidgetState();
}

class PatinamentoNWidgetState extends State<PatinamentoNWidget> {
  final _voltasLevantado = TextEditingController();
  final _voltasBaixada = TextEditingController();

  final _focus1 = FocusNode();
  final _focus2 = FocusNode();

  @override
  void dispose() {
    _voltasLevantado.dispose();
    _voltasBaixada.dispose();
    _focus1.dispose();
    _focus2.dispose();
    super.dispose();
  }

  bool _validarCampos(BuildContext context) {
    if (_voltasLevantado.text.isEmpty) {
      _focus1.requestFocus();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Número de Voltas Levantado não informado')),
      );
      return false;
    }

    if (_voltasBaixada.text.isEmpty) {
      _focus2.requestFocus();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Número de Voltas Baixado não informado')),
      );
      return false;
    }

    return true;
  }

  void _calcular(BuildContext context) {
    if (!_validarCampos(context)) return;

    final controller = Get.find<MaquinarioController>();

    final voltasLevantado =
        double.parse(_voltasLevantado.text.replaceAll(',', '.'));
    final voltasBaixada =
        double.parse(_voltasBaixada.text.replaceAll(',', '.'));

    controller.calcularPatinamentoN(voltasLevantado, voltasBaixada);
  }

  void _limpar(BuildContext context) {
    _voltasLevantado.clear();
    _voltasBaixada.clear();
    Get.find<MaquinarioController>().limpar();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = ThemeManager().isDark.value;

    return Column(
      children: [
        Card(
          clipBehavior: Clip.antiAliasWithSaveLayer,
          elevation: 2,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                VTextField(
                  labelText: 'N. de Voltas c/ Implem. Levantado (Und)',
                  hintText: '0.0',
                  focusNode: _focus1,
                  txEditController: _voltasLevantado,
                  inputFormatters: [DecimalInputFormatter(decimalPlaces: 2)],
                  showClearButton: true,
                ),
                VTextField(
                  labelText: 'N. de Voltas c/ Implem. Baixado (Und)',
                  hintText: '0.0',
                  focusNode: _focus2,
                  txEditController: _voltasBaixada,
                  inputFormatters: [DecimalInputFormatter(decimalPlaces: 2)],
                  showClearButton: true,
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton.icon(
                        onPressed: () => _limpar(context),
                        icon: const Icon(Icons.clear, size: 18),
                        label: const Text('Limpar'),
                        style: ShadcnStyle.textButtonStyle,
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton.icon(
                        onPressed: () => _calcular(context),
                        icon: const Icon(Icons.calculate_outlined, size: 18),
                        label: const Text('Calcular'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green.shade700,
                          foregroundColor: Colors.white,
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        GetBuilder<MaquinarioController>(
          builder: (controller) {
            if (!controller.calculado) return const SizedBox.shrink();

            return Card(
              clipBehavior: Clip.antiAliasWithSaveLayer,
              elevation: 5,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Resultados',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: ShadcnStyle.textColor,
                          ),
                        ),
                      ],
                    ),
                    const Divider(thickness: 1),
                    Card(
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      color: (isDark
                              ? Colors.purple.shade800
                              : Colors.purple.shade50)
                          .withValues(alpha: isDark ? 0.3 : 1),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: BorderSide(
                          color:
                              (isDark ? Colors.purple.shade300 : Colors.purple)
                                  .withValues(alpha: 0.3),
                          width: 1,
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Icon(
                              Icons.auto_graph,
                              color: isDark
                                  ? Colors.purple.shade300
                                  : Colors.purple,
                              size: 32,
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Índice de Patinamento',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: ShadcnStyle.mutedTextColor,
                                    ),
                                  ),
                                  Text(
                                    '${controller.formatNumber(controller.resultado)} %',
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: ShadcnStyle.textColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

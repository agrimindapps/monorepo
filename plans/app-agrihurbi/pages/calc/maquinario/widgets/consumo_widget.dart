// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:get/get.dart';

// Project imports:
import '../../../../../core/style/shadcn_style.dart';
import '../../../../../core/themes/manager.dart';
import '../../../../../core/widgets/textfield_widget.dart';
import '../controllers/maquinario_controller.dart';

class ConsumoWidget extends StatefulWidget {
  const ConsumoWidget({super.key});

  @override
  ConsumoWidgetState createState() => ConsumoWidgetState();
}

class ConsumoWidgetState extends State<ConsumoWidget> {
  final _horimetroInicial = TextEditingController();
  final _horimetroFinal = TextEditingController();
  final _litrosAbastecidos = TextEditingController();

  final _focus1 = FocusNode();
  final _focus2 = FocusNode();
  final _focus3 = FocusNode();

  @override
  void dispose() {
    _horimetroInicial.dispose();
    _horimetroFinal.dispose();
    _litrosAbastecidos.dispose();
    _focus1.dispose();
    _focus2.dispose();
    _focus3.dispose();
    super.dispose();
  }

  bool _validarCampos(BuildContext context) {
    if (_horimetroInicial.text.isEmpty) {
      _focus1.requestFocus();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Hora Inicial não informada')),
      );
      return false;
    }

    if (_horimetroFinal.text.isEmpty) {
      _focus2.requestFocus();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Hora Final não informada')),
      );
      return false;
    }

    if (_litrosAbastecidos.text.isEmpty) {
      _focus3.requestFocus();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Litros Abastecidos não informados')),
      );
      return false;
    }

    return true;
  }

  void _calcular(BuildContext context) {
    if (!_validarCampos(context)) return;

    final controller = Get.find<MaquinarioController>();

    final horaInicial =
        double.parse(_horimetroInicial.text.replaceAll(',', '.'));
    final horaFinal = double.parse(_horimetroFinal.text.replaceAll(',', '.'));
    final litros = double.parse(_litrosAbastecidos.text.replaceAll(',', '.'));

    controller.calcularConsumo(horaInicial, horaFinal, litros);
  }

  void _limpar(BuildContext context) {
    _horimetroInicial.clear();
    _horimetroFinal.clear();
    _litrosAbastecidos.clear();
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
                  labelText: 'Horímetro Inicial (Hras)',
                  hintText: '0.0',
                  focusNode: _focus1,
                  txEditController: _horimetroInicial,
                  inputFormatters: [DecimalInputFormatter(decimalPlaces: 2)],
                  showClearButton: true,
                ),
                VTextField(
                  labelText: 'Horímetro Final (Hras)',
                  hintText: '0.0',
                  focusNode: _focus2,
                  txEditController: _horimetroFinal,
                  inputFormatters: [DecimalInputFormatter(decimalPlaces: 2)],
                  showClearButton: true,
                ),
                VTextField(
                  labelText: 'Litros Abastecidos (Lts)',
                  hintText: '0.0',
                  focusNode: _focus3,
                  txEditController: _litrosAbastecidos,
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
                              ? Colors.orange.shade800
                              : Colors.orange.shade50)
                          .withValues(alpha: isDark ? 0.3 : 1),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: BorderSide(
                          color:
                              (isDark ? Colors.orange.shade300 : Colors.orange)
                                  .withValues(alpha: 0.3),
                          width: 1,
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Icon(
                              Icons.local_gas_station,
                              color: isDark
                                  ? Colors.orange.shade300
                                  : Colors.orange,
                              size: 32,
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Consumo de Diesel',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: ShadcnStyle.mutedTextColor,
                                    ),
                                  ),
                                  Text(
                                    '${controller.formatNumber(controller.resultado)} Lt/H',
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

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:get/get.dart';

// Project imports:
import '../../../../../../core/style/shadcn_style.dart';
import '../../../../../../core/themes/manager.dart';
import '../../../../../../core/widgets/textfield_widget.dart';
import '../../controllers/leguminosa_controller.dart';

class InputFieldsWidget extends StatefulWidget {
  const InputFieldsWidget({super.key});

  @override
  State<InputFieldsWidget> createState() => _InputFieldsWidgetState();
}

class _InputFieldsWidgetState extends State<InputFieldsWidget> {
  final _vagensPorPlanta = TextEditingController();
  final _sementesPorVagem = TextEditingController();
  final _pesoMilGraos = TextEditingController();
  final _plantasM2 = TextEditingController();

  final _focus1 = FocusNode();
  final _focus2 = FocusNode();
  final _focus3 = FocusNode();
  final _focus4 = FocusNode();

  @override
  void initState() {
    super.initState();
    final controller = Get.find<LeguminosaController>();
    controller.addListener(_updateControllers);
    _initControllers();
  }

  void _initControllers() {
    final controller = Get.find<LeguminosaController>();
    _vagensPorPlanta.text = controller.model.vagensPorPlanta > 0
        ? controller.model.vagensPorPlanta.toString()
        : '';
    _sementesPorVagem.text = controller.model.sementesPorVagem > 0
        ? controller.model.sementesPorVagem.toString()
        : '';
    _pesoMilGraos.text = controller.model.pesoMilGraos > 0
        ? controller.model.pesoMilGraos.toString()
        : '';
    _plantasM2.text = controller.model.plantasM2 > 0
        ? controller.model.plantasM2.toString()
        : '';
  }

  void _updateControllers() {
    setState(() {
      _initControllers();
    });
  }

  @override
  void dispose() {
    _vagensPorPlanta.dispose();
    _sementesPorVagem.dispose();
    _pesoMilGraos.dispose();
    _plantasM2.dispose();
    _focus1.dispose();
    _focus2.dispose();
    _focus3.dispose();
    _focus4.dispose();
    Get.find<LeguminosaController>().removeListener(_updateControllers);
    super.dispose();
  }

  bool _validarCampos() {
    if (_vagensPorPlanta.text.isEmpty) {
      _focus1.requestFocus();
      return false;
    }

    if (_sementesPorVagem.text.isEmpty) {
      _focus2.requestFocus();
      return false;
    }

    if (_pesoMilGraos.text.isEmpty) {
      _focus3.requestFocus();
      return false;
    }

    if (_plantasM2.text.isEmpty) {
      _focus4.requestFocus();
      return false;
    }

    return true;
  }

  void _calcular() {
    if (!_validarCampos()) return;

    final controller = Get.find<LeguminosaController>();
    controller.calcular(
      vagensPorPlanta: double.parse(_vagensPorPlanta.text.replaceAll(',', '.')),
      sementesPorVagem:
          double.parse(_sementesPorVagem.text.replaceAll(',', '.')),
      pesoMilGraos: double.parse(_pesoMilGraos.text.replaceAll(',', '.')),
      plantasM2: double.parse(_plantasM2.text.replaceAll(',', '.')),
    );
  }

  void _limpar() {
    setState(() {
      _vagensPorPlanta.clear();
      _sementesPorVagem.clear();
      _pesoMilGraos.clear();
      _plantasM2.clear();
    });
    Get.find<LeguminosaController>().limpar();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = ThemeManager().isDark.value;

    return Card(
      clipBehavior: Clip.antiAliasWithSaveLayer,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(16, 30, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Text(
                'Informe os valores para o cálculo',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: ShadcnStyle.textColor,
                ),
              ),
            ),
            VTextField(
              labelText: 'Vagens por Planta',
              hintText: '0.0',
              focusNode: _focus1,
              txEditController: _vagensPorPlanta,
              inputFormatters: [DecimalInputFormatter(decimalPlaces: 2)],
              showClearButton: true,
            ),
            VTextField(
              labelText: 'Sementes por Vagem',
              hintText: '0.0',
              focusNode: _focus2,
              txEditController: _sementesPorVagem,
              inputFormatters: [DecimalInputFormatter(decimalPlaces: 2)],
              showClearButton: true,
            ),
            VTextField(
              labelText: 'Peso de Mil Grãos (g)',
              hintText: '0.0',
              focusNode: _focus3,
              txEditController: _pesoMilGraos,
              inputFormatters: [DecimalInputFormatter(decimalPlaces: 2)],
              showClearButton: true,
            ),
            VTextField(
              labelText: 'Plantas por m²',
              hintText: '0.0',
              focusNode: _focus4,
              txEditController: _plantasM2,
              inputFormatters: [DecimalInputFormatter(decimalPlaces: 2)],
              showClearButton: true,
            ),
            Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(0, 20, 0, 0),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    onPressed: _limpar,
                    icon: const Icon(Icons.clear, size: 18),
                    label: const Text('Limpar'),
                    style: ShadcnStyle.textButtonStyle,
                  ),
                  const SizedBox(width: 12),
                  TextButton.icon(
                    onPressed: _calcular,
                    icon: const Icon(Icons.calculate_outlined, size: 18),
                    label: const Text('Calcular'),
                    style: ShadcnStyle.primaryButtonStyle,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

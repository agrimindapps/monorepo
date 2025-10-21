// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'controller/densidade_ossea_controller.dart';
import 'model/densidade_ossea_model.dart';
import 'widgets/densidade_ossea_input_form.dart';
import 'widgets/densidade_ossea_result_card.dart';

class DensidadeOsseaCalcPage extends StatefulWidget {
  const DensidadeOsseaCalcPage({super.key});
  @override
  State<DensidadeOsseaCalcPage> createState() => _DensidadeOsseaCalcPageState();
}

class _DensidadeOsseaCalcPageState extends State<DensidadeOsseaCalcPage> {
  final _model = DensidadeOsseaModel();
  late final DensidadeOsseaController _controller;
  final _unfocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _controller = DensidadeOsseaController(_model);
  }

  @override
  void dispose() {
    _unfocusNode.dispose();
    _model.dispose();
    super.dispose();
  }

  void _calcular() {
    _controller.calcular(context);
    setState(() {});
  }

  void _limpar() {
    _controller.limpar();
    _unfocusNode.requestFocus();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        DensidadeOsseaInputForm(
          model: _model,
          onCalcular: _calcular,
          onLimpar: _limpar,
          setState: setState,
        ),
        const SizedBox(height: 10),
        DensidadeOsseaResultCard(model: _model),
      ],
    );
  }
}

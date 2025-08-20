// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:provider/provider.dart';

// Project imports:
import '../../../widgets/calc_appbar.dart';
import 'controller/calorias_exercicio_controller.dart';
import 'widgets/card_calculos_widget.dart';
import 'widgets/card_resultado_widget.dart';

class CaloriasPorExercicioCalcPage extends StatelessWidget {
  const CaloriasPorExercicioCalcPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CaloriasExercicioController(),
      child: Scaffold(
        appBar: CalcAppBar(
          title: 'Calorias por Exercício',
          onInfoPressed: () => _showInfoDialog(context),
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Center(
                child: SizedBox(
                  width: 1020,
                  child: _buildContent(),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    return Consumer<CaloriasExercicioController>(
      builder: (context, controller, _) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
              child: CardCalculosWidget(),
            ),
            if (controller.calculado)
              const Padding(
                padding: EdgeInsets.fromLTRB(0, 10, 0, 0),
                child: CardResultadoWidget(),
              ),
          ],
        );
      },
    );
  }

  void _showInfoDialog(BuildContext context) {
    // Mantido o código original do diálogo de informações
  }
}

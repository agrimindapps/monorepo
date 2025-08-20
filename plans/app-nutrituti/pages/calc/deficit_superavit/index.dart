// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:provider/provider.dart';

// Project imports:
import '../../../../../core/style/shadcn_style.dart';
import '../../../../../core/themes/manager.dart';
import 'controller/deficit_superavit_controller.dart';
import 'widgets/deficit_superavit_form.dart';
import 'widgets/deficit_superavit_result_card.dart';

class DeficitSuperavitCalcPage extends StatelessWidget {
  const DeficitSuperavitCalcPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => DeficitSuperavitController(),
      child: const DeficitSuperavitCalcView(),
    );
  }
}

class DeficitSuperavitCalcView extends StatelessWidget {
  const DeficitSuperavitCalcView({super.key});

  void _showInfoDialog(BuildContext context, bool perderPeso) {
    final isDark = ThemeManager().isDark.value;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? Colors.black87 : Colors.white,
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
                          perderPeso
                              ? 'Sobre Déficit Calórico'
                              : 'Sobre Superávit Calórico',
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
                    perderPeso
                        ? 'O que é Déficit Calórico:'
                        : 'O que é Superávit Calórico:',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: ShadcnStyle.textColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    perderPeso
                        ? 'O déficit calórico é a diferença entre a quantidade de calorias que você consome e a quantidade que seu corpo gasta. Quando você consome menos calorias do que gasta, cria-se um déficit calórico, o que leva à perda de peso.'
                        : 'O superávit calórico é a diferença entre a quantidade de calorias que você consome e a quantidade que seu corpo gasta. Quando você consome mais calorias do que gasta, cria-se um superávit calórico, o que permite o ganho de peso.',
                    style: TextStyle(
                        color: ShadcnStyle.textColor.withValues(alpha: 0.9)),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Recomendações:',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: ShadcnStyle.textColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    perderPeso
                        ? '• Uma perda de peso saudável é de 0,5 a 1kg por semana\n'
                            '• Um déficit de 500-1000 kcal/dia é geralmente recomendado\n'
                            '• Mulheres não devem consumir menos que 1200 kcal/dia\n'
                            '• Homens não devem consumir menos que 1500 kcal/dia\n'
                            '• Combine redução calórica com exercícios para melhores resultados'
                        : '• Um ganho de peso saudável é de 0,25 a 0,5kg por semana\n'
                            '• Um superávit de 250-500 kcal/dia é geralmente recomendado\n'
                            '• Priorize alimentos nutritivos para um ganho de peso saudável\n'
                            '• Inclua treinamento de resistência para maximizar o ganho muscular\n'
                            '• Distribua as calorias em 4-6 refeições ao dia para facilitar o consumo',
                    style: TextStyle(
                        color: ShadcnStyle.textColor.withValues(alpha: 0.9)),
                  ),
                  const SizedBox(height: 24),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: ShadcnStyle.textButtonStyle,
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
    return Consumer<DeficitSuperavitController>(
      builder: (context, controller, _) {
        final isDark = ThemeManager().isDark.value;

        return Scaffold(
          resizeToAvoidBottomInset: false,
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.of(context).pop(),
              tooltip: 'Voltar',
            ),
            title: Row(
              children: [
                Icon(
                  Icons.calculate_outlined,
                  size: 20,
                  color: isDark ? Colors.orange.shade300 : Colors.orange,
                ),
                const SizedBox(width: 10),
                Text(controller.perderPeso
                    ? 'Déficit Calórico'
                    : 'Superávit Calórico'),
              ],
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.info_outline),
                onPressed: () =>
                    _showInfoDialog(context, controller.perderPeso),
                tooltip: 'Informações sobre cálculo calórico',
              ),
            ],
          ),
          body: Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 800),
              child: Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(16, 16, 16, 16),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      DeficitSuperavitForm(
                        caloriasDiariasController:
                            controller.caloriasDiariasController,
                        metaPesoController: controller.metaPesoController,
                        tempoSemanaController: controller.tempoSemanaController,
                        focusCalorias: controller.focusCalorias,
                        focusMetaPeso: controller.focusMetaPeso,
                        focusTempo: controller.focusTempo,
                        onCalcular: () => controller.calcular(context),
                        onLimpar: controller.limpar,
                        onInfoPressed: () =>
                            _showInfoDialog(context, controller.perderPeso),
                        onTipoMetaChanged: controller.handleTipoMetaChanged,
                        tipoMetaSelecionado: controller.tipoMetaSelecionado,
                      ),
                      if (controller.calculado) ...[
                        const SizedBox(height: 20),
                        DeficitSuperavitResultCard(
                          perderPeso: controller.perderPeso,
                          deficitSuperavitDiario:
                              controller.deficitSuperavitDiario,
                          deficitSuperavitSemanal:
                              controller.deficitSuperavitSemanal,
                          metaCaloricaDiaria: controller.metaCaloricaDiaria,
                          onCompartilhar: controller.compartilhar,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

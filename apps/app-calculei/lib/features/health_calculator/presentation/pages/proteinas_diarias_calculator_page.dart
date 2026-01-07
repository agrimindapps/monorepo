import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/presentation/widgets/calculator_input_field.dart';
import '../../../../shared/widgets/share_button.dart';
import '../../domain/calculators/proteinas_diarias_calculator.dart';

/// Página da calculadora de proteínas diárias
class ProteinasDiariasCalculatorPage extends StatefulWidget {
  const ProteinasDiariasCalculatorPage({super.key});

  @override
  State<ProteinasDiariasCalculatorPage> createState() =>
      _ProteinasDiariasCalculatorPageState();
}

class _ProteinasDiariasCalculatorPageState
    extends State<ProteinasDiariasCalculatorPage> {
  final _formKey = GlobalKey<FormState>();
  final _weightController = TextEditingController();

  ActivityLevel _activityLevel = ActivityLevel.moderate;
  DailyProteinResult? _result;

  @override
  void dispose() {
    _weightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Proteínas Diárias'),
      ),
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: Container(
            constraints: const BoxConstraints(maxWidth: 1120),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Info Card
                  Card(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.egg_outlined,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onPrimaryContainer,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Necessidade Diária de Proteínas',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onPrimaryContainer,
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Calcula a quantidade ideal de proteína baseada no seu peso '
                            'e nível de atividade física. Proteínas são essenciais para '
                            'construção muscular, recuperação e saúde geral.',
                            style: TextStyle(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onPrimaryContainer
                                  .withValues(alpha: 0.9),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Input Form
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              'Seus dados',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            const SizedBox(height: 16),

                            // Weight input
                            SizedBox(
                              width: 200,
                              child: StandardInputField(
                                label: 'Peso',
                                controller: _weightController,
                                suffix: 'kg',
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                  decimal: true,
                                ),
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(
                                    RegExp(r'^\d*\.?\d*'),
                                  ),
                                ],
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Obrigatório';
                                  }
                                  final num = double.tryParse(value);
                                  if (num == null || num <= 0 || num > 500) {
                                    return 'Valor inválido';
                                  }
                                  return null;
                                },
                              ),
                            ),

                            const SizedBox(height: 16),

                            // Activity level selection
                            Text(
                              'Nível de atividade física',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(fontWeight: FontWeight.w500),
                            ),
                            const SizedBox(height: 8),

                            ...ActivityLevel.values.map((level) {
                              return RadioListTile<ActivityLevel>(
                                title: Text(_getActivityLevelText(level)),
                                subtitle: Text(
                                  _getActivityLevelDescription(level),
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                                value: level,
                                groupValue: _activityLevel,
                                onChanged: (value) {
                                  setState(() => _activityLevel = value!);
                                },
                              );
                            }),

                            const SizedBox(height: 24),

                            CalculatorButton(
                              label: 'Calcular Proteínas',
                              icon: Icons.calculate,
                              onPressed: _calculate,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Result
                  if (_result != null) _ProteinResultCard(result: _result!),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _getActivityLevelText(ActivityLevel level) {
    return switch (level) {
      ActivityLevel.sedentary => 'Sedentário',
      ActivityLevel.light => 'Atividade Leve',
      ActivityLevel.moderate => 'Atividade Moderada',
      ActivityLevel.veryActive => 'Muito Ativo',
      ActivityLevel.extreme => 'Atividade Extrema',
    };
  }

  String _getActivityLevelDescription(ActivityLevel level) {
    return switch (level) {
      ActivityLevel.sedentary => 'Pouco ou nenhum exercício',
      ActivityLevel.light => '1-3 dias/semana',
      ActivityLevel.moderate => '3-5 dias/semana',
      ActivityLevel.veryActive => '6-7 dias/semana intenso',
      ActivityLevel.extreme => 'Atleta ou trabalho físico pesado',
    };
  }

  void _calculate() {
    if (!_formKey.currentState!.validate()) return;

    final result = ProteinarDiariasCalculator.calculate(
      weightKg: double.parse(_weightController.text),
      activityLevel: _activityLevel,
    );

    setState(() => _result = result);
  }
}

class _ProteinResultCard extends StatelessWidget {
  final DailyProteinResult result;

  const _ProteinResultCard({required this.result});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(Icons.assessment, color: colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'Resultado',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const Spacer(),
                ShareButton(
                  text: ShareFormatter.formatGeneric(
                    title: 'Proteínas Diárias',
                    data: {
                      '🎯 Faixa recomendada':
                          '${result.minProtein}-${result.maxProtein}g/dia',
                      '🏃 Nível de atividade': result.activityLevelText,
                      '💡 Dica': result.recommendation,
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Protein range
            Center(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    Text(
                      '${result.minProtein} - ${result.maxProtein}g',
                      style:
                          Theme.of(context).textTheme.displaySmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: colorScheme.onPrimaryContainer,
                              ),
                    ),
                    Text(
                      'Proteína por dia',
                      style: TextStyle(
                        color: colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Activity level
            Center(
              child: Chip(
                label: Text(
                  result.activityLevelText,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                backgroundColor: colorScheme.secondary,
              ),
            ),

            const SizedBox(height: 16),

            // Recommendation
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colorScheme.secondaryContainer.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.lightbulb_outline,
                    size: 20,
                    color: colorScheme.secondary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      result.recommendation,
                      style: TextStyle(color: colorScheme.onSecondaryContainer),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Protein sources examples
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Fontes de proteína',
                    style: Theme.of(context)
                        .textTheme
                        .titleSmall
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text('• Peito de frango: 31g/100g'),
                  const Text('• Ovo: 6g por unidade'),
                  const Text('• Feijão: 9g por xícara'),
                  const Text('• Whey protein: 20-30g por dose'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

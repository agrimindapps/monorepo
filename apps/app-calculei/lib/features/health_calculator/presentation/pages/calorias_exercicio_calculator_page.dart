import 'package:flutter/material.dart';
import '../../../../core/presentation/widgets/calculator_app_bar.dart';
import 'package:flutter/services.dart';

import '../../../../core/presentation/widgets/calculator_input_field.dart';
import '../../../../shared/widgets/share_button.dart';
import '../../domain/calculators/calorias_exercicio_calculator.dart';

/// Página da calculadora de calorias por exercício
class CaloriasExercicioCalculatorPage extends StatefulWidget {
  const CaloriasExercicioCalculatorPage({super.key});

  @override
  State<CaloriasExercicioCalculatorPage> createState() =>
      _CaloriasExercicioCalculatorPageState();
}

class _CaloriasExercicioCalculatorPageState
    extends State<CaloriasExercicioCalculatorPage> {
  final _formKey = GlobalKey<FormState>();
  final _durationController = TextEditingController();

  ExerciseType _exerciseType = ExerciseType.running;
  ExerciseCaloriesResult? _result;

  @override
  void dispose() {
    _durationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CalculatorAppBar(
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
                                Icons.fitness_center,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onPrimaryContainer,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Gasto Calórico em Exercícios',
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
                            'Estime quantas calorias você queima em diferentes tipos '
                            'de exercícios. Baseado em valores MET (Equivalente Metabólico '
                            'de Tarefa) para intensidades médias.',
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
                              'Dados do exercício',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            const SizedBox(height: 16),

                            // Exercise type selection
                            Text(
                              'Tipo de exercício',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(fontWeight: FontWeight.w500),
                            ),
                            const SizedBox(height: 8),

                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: ExerciseType.values.map((type) {
                                return _ExerciseTypeChip(
                                  type: type,
                                  isSelected: _exerciseType == type,
                                  onTap: () =>
                                      setState(() => _exerciseType = type),
                                );
                              }).toList(),
                            ),

                            const SizedBox(height: 16),

                            // Duration input
                            SizedBox(
                              width: 200,
                              child: StandardInputField(
                                label: 'Duração',
                                controller: _durationController,
                                suffix: 'minutos',
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                ],
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Obrigatório';
                                  }
                                  final num = int.tryParse(value);
                                  if (num == null || num <= 0 || num > 600) {
                                    return 'Valor inválido';
                                  }
                                  return null;
                                },
                              ),
                            ),

                            const SizedBox(height: 24),

                            CalculatorButton(
                              label: 'Calcular Calorias',
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
                  if (_result != null)
                    _ExerciseCaloriesResultCard(result: _result!),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _calculate() {
    if (!_formKey.currentState!.validate()) return;

    final result = CaloriasExercicioCalculator.calculate(
      exerciseType: _exerciseType,
      durationMinutes: int.parse(_durationController.text),
    );

    setState(() => _result = result);
  }
}

class _ExerciseTypeChip extends StatelessWidget {
  final ExerciseType type;
  final bool isSelected;
  final VoidCallback onTap;

  const _ExerciseTypeChip({
    required this.type,
    required this.isSelected,
    required this.onTap,
  });

  String _getTypeName(ExerciseType type) {
    return switch (type) {
      ExerciseType.walking => '🚶 Caminhada',
      ExerciseType.running => '🏃 Corrida',
      ExerciseType.cycling => '🚴 Ciclismo',
      ExerciseType.swimming => '🏊 Natação',
      ExerciseType.weightTraining => '💪 Musculação',
      ExerciseType.yoga => '🧘 Yoga',
    };
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return FilterChip(
      label: Text(_getTypeName(type)),
      selected: isSelected,
      onSelected: (_) => onTap(),
      selectedColor: colorScheme.primaryContainer,
      checkmarkColor: colorScheme.primary,
    );
  }
}

class _ExerciseCaloriesResultCard extends StatelessWidget {
  final ExerciseCaloriesResult result;

  const _ExerciseCaloriesResultCard({required this.result});

  IconData _getExerciseIcon(ExerciseType type) {
    return switch (type) {
      ExerciseType.walking => Icons.directions_walk,
      ExerciseType.running => Icons.directions_run,
      ExerciseType.cycling => Icons.directions_bike,
      ExerciseType.swimming => Icons.pool,
      ExerciseType.weightTraining => Icons.fitness_center,
      ExerciseType.yoga => Icons.self_improvement,
    };
  }

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
                    title: 'Calorias por Exercício',
                    data: {
                      '🏃 Exercício': result.exerciseTypeName,
                      '⏱️ Duração': '${result.durationMinutes} minutos',
                      '🔥 Calorias queimadas':
                          '${result.calories.toStringAsFixed(0)} kcal',
                      '📊 Valor MET': result.metValue.toStringAsFixed(1),
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Calories burned
            Center(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.orange, width: 2),
                ),
                child: Column(
                  children: [
                    Icon(
                      _getExerciseIcon(result.exerciseType),
                      size: 48,
                      color: Colors.orange,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${result.calories.toStringAsFixed(0)}',
                      style:
                          Theme.of(context).textTheme.displayMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.orange,
                              ),
                    ),
                    Text(
                      'kcal queimadas',
                      style: TextStyle(
                        color: Colors.orange,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Exercise info
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _InfoColumn(
                        icon: Icons.fitness_center,
                        label: 'Exercício',
                        value: result.exerciseTypeName,
                      ),
                      _InfoColumn(
                        icon: Icons.access_time,
                        label: 'Duração',
                        value: '${result.durationMinutes} min',
                      ),
                      _InfoColumn(
                        icon: Icons.speed,
                        label: 'MET',
                        value: result.metValue.toStringAsFixed(1),
                      ),
                    ],
                  ),
                ],
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

            const SizedBox(height: 12),

            // Info note
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Valores são estimativas médias. O gasto real varia com peso, intensidade e condicionamento.',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
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

class _InfoColumn extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoColumn({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 20),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
        Text(
          value,
          style: Theme.of(context)
              .textTheme
              .titleSmall
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}

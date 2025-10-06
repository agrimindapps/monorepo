import 'package:flutter/material.dart';
import '../../domain/entities/calorie_input.dart';

/// Widget para o terceiro step: nível de atividade e condição corporal
class CalorieActivityConditionStep extends StatelessWidget {
  const CalorieActivityConditionStep({
    super.key,
    required this.input,
    required this.validationErrors,
    required this.onInputChanged,
  });

  final CalorieInput input;
  final List<String> validationErrors;
  final void Function(CalorieInput) onInputChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Atividade & Condição Corporal',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Avalie o nível de atividade física e condição corporal atual.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 24),

          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _buildActivityLevelSelector(context),
                  const SizedBox(height: 24),
                  _buildBodyConditionSelector(context),
                  const SizedBox(height: 24),
                  _buildSelectionSummary(context),
                ],
              ),
            ),
          ),
          if (validationErrors.isNotEmpty)
            _buildValidationErrors(context),
        ],
      ),
    );
  }

  Widget _buildActivityLevelSelector(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Nível de Atividade *',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Considere a atividade física diária do animal.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 16),
            ...ActivityLevel.values.map((level) {
              final isSelected = input.activityLevel == level;
              return Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: GestureDetector(
                  onTap: () => _updateActivityLevel(level),
                  child: Container(
                    padding: const EdgeInsets.all(12.0),
                    decoration: BoxDecoration(
                      color: isSelected 
                          ? Theme.of(context).primaryColor.withValues(alpha: 0.1)
                          : null,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isSelected 
                            ? Theme.of(context).primaryColor
                            : Colors.grey[300]!,
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Radio<ActivityLevel>(
                          value: level,
                          groupValue: input.activityLevel,
                          onChanged: (value) => _updateActivityLevel(value!),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                level.displayName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                _getActivityDescription(level),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                              Text(
                                'Fator: ${level.factor}x',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Theme.of(context).primaryColor,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        _getActivityIcon(level),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildBodyConditionSelector(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Condição Corporal (BCS) *',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () => _showBcsGuide(context),
                  child: Icon(
                    Icons.help_outline,
                    size: 20,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Avalie tocando as costelas e observando a silhueta.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 16),
            ...BodyConditionScore.values.map((bcs) {
              final isSelected = input.bodyConditionScore == bcs;
              return Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: GestureDetector(
                  onTap: () => _updateBodyConditionScore(bcs),
                  child: Container(
                    padding: const EdgeInsets.all(12.0),
                    decoration: BoxDecoration(
                      color: isSelected 
                          ? _getBcsColor(bcs).withValues(alpha: 0.1)
                          : null,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isSelected 
                            ? _getBcsColor(bcs)
                            : Colors.grey[300]!,
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Radio<BodyConditionScore>(
                          value: bcs,
                          groupValue: input.bodyConditionScore,
                          onChanged: (value) => _updateBodyConditionScore(value!),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                bcs.displayName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                _getBcsDescription(bcs),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                              Text(
                                'Ajuste: ${(bcs.factor * 100).round()}%',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: _getBcsColor(bcs),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          _getBcsIcon(bcs),
                          color: _getBcsColor(bcs),
                          size: 24,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectionSummary(BuildContext context) {
    final combinedFactor = input.activityLevel.factor * input.bodyConditionScore.factor;
    
    return Card(
      color: Colors.blue[50],
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.analytics, color: Colors.blue[600]),
                const SizedBox(width: 8),
                Text(
                  'Resumo das Seleções',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[600],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Atividade: ${input.activityLevel.displayName}',
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                      Text(
                        'Fator: ${input.activityLevel.factor}x',
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                    ],
                  ),
                ),
                const Text('×', style: TextStyle(fontSize: 18)),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'BCS: ${input.bodyConditionScore.displayName.split(' ')[0]}',
                        style: const TextStyle(fontWeight: FontWeight.w500),
                        textAlign: TextAlign.center,
                      ),
                      Text(
                        'Fator: ${input.bodyConditionScore.factor}x',
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                const Text('=', style: TextStyle(fontSize: 18)),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Total: ${combinedFactor.toStringAsFixed(2)}x',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue[700],
                        ),
                        textAlign: TextAlign.end,
                      ),
                      Text(
                        'Multiplicador final',
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                        textAlign: TextAlign.end,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              _getMetabolicAdvice(combinedFactor),
              style: TextStyle(
                fontSize: 12,
                color: Colors.blue[700],
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildValidationErrors(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.error, color: Colors.red[600], size: 20),
              const SizedBox(width: 8),
              Text(
                'Correções necessárias:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.red[600],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...validationErrors.map((error) => Text(
            '• $error',
            style: TextStyle(color: Colors.red[600]),
          )),
        ],
      ),
    );
  }

  String _getActivityDescription(ActivityLevel level) {
    switch (level) {
      case ActivityLevel.sedentary:
        return 'Pouco movimento, dentro de casa';
      case ActivityLevel.light:
        return 'Caminhadas curtas, brincadeiras leves';
      case ActivityLevel.moderate:
        return 'Caminhadas diárias, atividade regular';
      case ActivityLevel.active:
        return 'Exercícios frequentes, brincadeiras intensas';
      case ActivityLevel.veryActive:
        return 'Atividade intensa diária, corridas longas';
      case ActivityLevel.extreme:
        return 'Trabalho, competição, atividade extrema';
    }
  }

  String _getBcsDescription(BodyConditionScore bcs) {
    switch (bcs) {
      case BodyConditionScore.underweight:
        return 'Costelas visíveis, sem gordura';
      case BodyConditionScore.ideal:
        return 'Costelas palpáveis, cintura visível';
      case BodyConditionScore.overweight:
        return 'Costelas difíceis de palpar';
      case BodyConditionScore.obese:
        return 'Costelas não palpáveis, sem cintura';
    }
  }

  Widget _getActivityIcon(ActivityLevel level) {
    IconData iconData;
    Color color;

    switch (level) {
      case ActivityLevel.sedentary:
        iconData = Icons.hotel;
        color = Colors.grey;
        break;
      case ActivityLevel.light:
        iconData = Icons.directions_walk;
        color = Colors.blue;
        break;
      case ActivityLevel.moderate:
        iconData = Icons.pets;
        color = Colors.green;
        break;
      case ActivityLevel.active:
        iconData = Icons.directions_run;
        color = Colors.orange;
        break;
      case ActivityLevel.veryActive:
        iconData = Icons.fitness_center;
        color = Colors.red;
        break;
      case ActivityLevel.extreme:
        iconData = Icons.flash_on;
        color = Colors.purple;
        break;
    }

    return Icon(iconData, color: color, size: 24);
  }

  IconData _getBcsIcon(BodyConditionScore bcs) {
    switch (bcs) {
      case BodyConditionScore.underweight:
        return Icons.trending_down;
      case BodyConditionScore.ideal:
        return Icons.favorite;
      case BodyConditionScore.overweight:
        return Icons.trending_up;
      case BodyConditionScore.obese:
        return Icons.warning;
    }
  }

  Color _getBcsColor(BodyConditionScore bcs) {
    switch (bcs) {
      case BodyConditionScore.underweight:
        return Colors.blue;
      case BodyConditionScore.ideal:
        return Colors.green;
      case BodyConditionScore.overweight:
        return Colors.orange;
      case BodyConditionScore.obese:
        return Colors.red;
    }
  }

  String _getMetabolicAdvice(double factor) {
    if (factor < 0.8) {
      return 'Necessidades calóricas muito reduzidas - monitoramento rigoroso necessário';
    } else if (factor < 1.0) {
      return 'Necessidades calóricas reduzidas - ideal para perda de peso';
    } else if (factor <= 1.2) {
      return 'Necessidades calóricas normais - manutenção do peso';
    } else if (factor <= 2.0) {
      return 'Necessidades calóricas elevadas - animal ativo';
    } else {
      return 'Necessidades calóricas muito altas - monitoramento especial necessário';
    }
  }

  void _showBcsGuide(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Guia de Condição Corporal (BCS)'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Como avaliar:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text('1. Passe as mãos pelas costelas do animal'),
              Text('2. Observe o animal de perfil'),
              Text('3. Observe o animal de cima'),
              SizedBox(height: 16),
              Text(
                'Classificações:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text('🔵 Abaixo do Peso: Costelas, vértebras e ossos pélvicos facilmente visíveis'),
              Text('🟢 Peso Ideal: Costelas facilmente palpáveis, cintura visível'),
              Text('🟠 Sobrepeso: Costelas palpáveis com pressão, cintura pouco visível'),
              Text('🔴 Obeso: Costelas difíceis ou impossíveis de palpar, sem cintura'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Entendi'),
          ),
        ],
      ),
    );
  }

  void _updateActivityLevel(ActivityLevel level) {
    onInputChanged(input.copyWith(activityLevel: level));
  }

  void _updateBodyConditionScore(BodyConditionScore bcs) {
    onInputChanged(input.copyWith(bodyConditionScore: bcs));
  }
}

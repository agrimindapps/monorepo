import 'package:core/core.dart' hide FormState;
import 'package:flutter/material.dart';

import '../../domain/calculators/exercise_calculator.dart';
import '../../domain/entities/calculation_result.dart';
import '../providers/exercise_provider.dart';

/// Página da Calculadora de Exercícios
class ExercisePage extends ConsumerStatefulWidget {
  const ExercisePage({super.key});

  @override
  ConsumerState<ExercisePage> createState() => _ExercisePageState();
}

class _ExercisePageState extends ConsumerState<ExercisePage> {
  final _formKey = GlobalKey<FormState>();
  final _ageController = TextEditingController();
  final _weightController = TextEditingController();
  final _availableTimeController = TextEditingController();
  String _selectedSpecies = 'Cão';
  String _selectedBreedGroup = 'Sem Raça Definida - Moderado';
  String _selectedActivityLevel = 'Moderadamente Ativo (exercício regular)';
  String _selectedHealthConditions = 'Saudável (sem restrições)';
  String _selectedExerciseGoal = 'Manutenção da Saúde';

  final calculator = const ExerciseCalculator();

  @override
  void dispose() {
    _ageController.dispose();
    _weightController.dispose();
    _availableTimeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final exerciseState = ref.watch(exerciseProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Calculadora de Exercícios'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        foregroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => _showInfoDialog(context),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildInfoCard(),
                    const SizedBox(height: 24),
                    _buildAnimalInfoSection(),
                    const SizedBox(height: 24),
                    _buildPhysicalDataSection(),
                    const SizedBox(height: 24),
                    _buildActivitySection(),
                    const SizedBox(height: 24),
                    _buildGoalsSection(),
                    const SizedBox(height: 24),
                    if (exerciseState.result != null) ...[
                      _buildResultCard(exerciseState.result!),
                      const SizedBox(height: 16),
                    ],
                    if (exerciseState.errorMessage != null) ...[
                      _buildErrorCard(exerciseState.errorMessage!),
                      const SizedBox(height: 16),
                    ],
                  ],
                ),
              ),
            ),
          ),
          _buildCalculateButton(exerciseState.isLoading),
        ],
      ),
    );
  }

  Widget _buildInfoCard() {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.directions_run,
                color: theme.colorScheme.primary,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                'Calculadora de Exercícios',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Calcula as necessidades diárias de exercício baseado na raça, idade, condição física '
            'e objetivos específicos para manter a saúde e bem-estar do seu animal.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimalInfoSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Informações do Animal',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedSpecies,
              decoration: const InputDecoration(
                labelText: 'Espécie',
                border: OutlineInputBorder(),
              ),
              items: ['Cão', 'Gato'].map((species) {
                return DropdownMenuItem(
                  value: species,
                  child: Text(species),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedSpecies = value;
                    if (value == 'Gato') {
                      _selectedBreedGroup = 'Gato de Apartamento';
                    } else {
                      _selectedBreedGroup = 'Sem Raça Definida - Moderado';
                    }
                  });
                }
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor, selecione a espécie';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedBreedGroup,
              decoration: const InputDecoration(
                labelText: 'Grupo da Raça',
                border: OutlineInputBorder(),
              ),
              items: _getBreedGroupOptions(_selectedSpecies).map((group) {
                return DropdownMenuItem(
                  value: group,
                  child: Text(group, style: const TextStyle(fontSize: 12)),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedBreedGroup = value;
                  });
                }
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor, selecione o grupo da raça';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhysicalDataSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Dados Físicos',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _ageController,
              decoration: const InputDecoration(
                labelText: 'Idade',
                suffixText: 'anos',
                border: OutlineInputBorder(),
                helperText: 'Idade do animal em anos',
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor, informe a idade';
                }
                final age = double.tryParse(value);
                if (age == null || age <= 0 || age > 25) {
                  return 'Idade deve estar entre 0.1 e 25 anos';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _weightController,
              decoration: const InputDecoration(
                labelText: 'Peso',
                suffixText: 'kg',
                border: OutlineInputBorder(),
                helperText: 'Peso atual do animal',
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor, informe o peso';
                }
                final weight = double.tryParse(value);
                if (weight == null || weight <= 0 || weight > 100) {
                  return 'Peso deve estar entre 0.5 e 100 kg';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedHealthConditions,
              decoration: const InputDecoration(
                labelText: 'Condições de Saúde',
                border: OutlineInputBorder(),
              ),
              items: [
                'Saudável (sem restrições)',
                'Obesidade/Sobrepeso',
                'Problemas Articulares (artrite, displasia)',
                'Problemas Cardíacos',
                'Problemas Respiratórios',
                'Recuperação de Cirurgia',
                'Idade Avançada (limitações)',
              ].map((condition) {
                return DropdownMenuItem(
                  value: condition,
                  child: Text(condition, style: const TextStyle(fontSize: 12)),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedHealthConditions = value;
                  });
                }
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor, selecione a condição de saúde';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivitySection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Nível de Atividade Atual',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedActivityLevel,
              decoration: const InputDecoration(
                labelText: 'Nível de Atividade Atual',
                border: OutlineInputBorder(),
              ),
              items: [
                'Sedentário (pouco ou nenhum exercício)',
                'Levemente Ativo (exercício ocasional)',
                'Moderadamente Ativo (exercício regular)',
                'Muito Ativo (exercício intenso diário)',
                'Atlético (treinamento intensivo)',
              ].map((level) {
                return DropdownMenuItem(
                  value: level,
                  child: Text(level, style: const TextStyle(fontSize: 12)),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedActivityLevel = value;
                  });
                }
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor, selecione o nível de atividade';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _availableTimeController,
              decoration: const InputDecoration(
                labelText: 'Tempo Disponível por Dia',
                suffixText: 'minutos',
                border: OutlineInputBorder(),
                helperText: 'Tempo disponível diariamente para exercício',
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor, informe o tempo disponível';
                }
                final time = double.tryParse(value);
                if (time == null || time < 10 || time > 300) {
                  return 'Tempo deve estar entre 10 e 300 minutos';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGoalsSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Objetivo do Exercício',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedExerciseGoal,
              decoration: const InputDecoration(
                labelText: 'Objetivo Principal',
                border: OutlineInputBorder(),
              ),
              items: [
                'Manutenção da Saúde',
                'Perda de Peso',
                'Ganho de Condicionamento',
                'Controle de Comportamento',
                'Preparação Esportiva',
                'Reabilitação',
              ].map((goal) {
                return DropdownMenuItem(
                  value: goal,
                  child: Text(goal),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedExerciseGoal = value;
                  });
                }
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor, selecione o objetivo';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultCard(CalculationResult result) {
    final theme = Theme.of(context);
    
    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.analytics_outlined,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Plano de Exercícios',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...result.results.map((item) => _buildResultItem(item)),
            
            if (result.summary != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  result.summary!,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
            
            if (result.recommendations.isNotEmpty == true) ...[
              const SizedBox(height: 16),
              _buildRecommendationsSection(result.recommendations),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildResultItem(ResultItem item) {
    final theme = Theme.of(context);
    final color = _getSeverityColor(item.severity);
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  item.label,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  '${item.value}${item.unit != null ? ' ${item.unit}' : ''}',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
          if (item.description != null) ...[
            const SizedBox(height: 4),
            Text(
              item.description!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildRecommendationsSection(List<Recommendation> recommendations) {
    final theme = Theme.of(context);
    final safetyAlerts = recommendations.where((r) => r.title.contains('Segurança')).toList();
    final normalRecs = recommendations.where((r) => !r.title.contains('Segurança')).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recomendações e Cuidados',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        if (safetyAlerts.isNotEmpty) ...[
          Container(
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: Colors.orange.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.security, color: Colors.orange, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Alertas de Segurança',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.orange,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ...safetyAlerts.map((alert) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    '• ${alert.message}',
                    style: theme.textTheme.bodyMedium,
                  ),
                )),
              ],
            ),
          ),
        ],
        ...normalRecs.map((rec) => Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                _getRecommendationIcon(rec.severity),
                size: 16,
                color: _getSeverityColor(rec.severity),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  rec.message,
                  style: theme.textTheme.bodyMedium,
                ),
              ),
            ],
          ),
        )),
      ],
    );
  }

  Widget _buildErrorCard(String error) {
    final theme = Theme.of(context);
    
    return Card(
      color: theme.colorScheme.errorContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              Icons.error_outline,
              color: theme.colorScheme.onErrorContainer,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                error,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onErrorContainer,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCalculateButton(bool isLoading) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: SizedBox(
        width: double.infinity,
        height: 48,
        child: ElevatedButton(
          onPressed: isLoading ? null : _calculateExercise,
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.primary,
            foregroundColor: Theme.of(context).colorScheme.onPrimary,
          ),
          child: isLoading
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.calculate),
                    SizedBox(width: 8),
                    Text('Calcular Exercícios'),
                  ],
                ),
        ),
      ),
    );
  }

  List<String> _getBreedGroupOptions(String species) {
    if (species == 'Gato') {
      return [
        'Gato de Apartamento',
        'Gato com Acesso Externo',
      ];
    } else {
      return [
        'Cão de Trabalho (Pastor, Border Collie)',
        'Cão Esportivo (Retriever, Pointer)',
        'Cão de Caça (Beagle, Cocker)',
        'Cão Terrier (Jack Russell, Bull Terrier)',
        'Cão de Companhia (Pug, Bulldog)',
        'Cão Toy (Chihuahua, Yorkshire)',
        'Cão Gigante (Mastiff, São Bernardo)',
        'Sem Raça Definida - Ativo',
        'Sem Raça Definida - Moderado',
      ];
    }
  }

  Color _getSeverityColor(ResultSeverity severity) {
    final theme = Theme.of(context);
    switch (severity) {
      case ResultSeverity.success:
        return Colors.green;
      case ResultSeverity.warning:
        return Colors.orange;
      case ResultSeverity.danger:
        return theme.colorScheme.error;
      case ResultSeverity.info:
        return theme.colorScheme.primary;
    }
  }

  IconData _getRecommendationIcon(ResultSeverity severity) {
    switch (severity) {
      case ResultSeverity.success:
        return Icons.check_circle_outline;
      case ResultSeverity.warning:
        return Icons.warning_amber_outlined;
      case ResultSeverity.danger:
        return Icons.error_outline;
      case ResultSeverity.info:
        return Icons.info_outline;
    }
  }

  void _calculateExercise() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final inputs = {
      'species': _selectedSpecies,
      'breed_group': _selectedBreedGroup,
      'age_years': double.parse(_ageController.text),
      'weight': double.parse(_weightController.text),
      'current_activity_level': _selectedActivityLevel,
      'health_conditions': _selectedHealthConditions,
      'exercise_goal': _selectedExerciseGoal,
      'available_time': double.parse(_availableTimeController.text),
    };

    ref.read(exerciseProvider.notifier).calculate(inputs);
  }

  void _showInfoDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sobre a Calculadora'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Esta calculadora determina as necessidades diárias de exercício baseada em:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text('• Características da raça e porte'),
              Text('• Idade e condição física atual'),
              Text('• Objetivos específicos de saúde'),
              Text('• Limitações de saúde existentes'),
              Text('• Tempo disponível para exercício'),
              SizedBox(height: 12),
              Text(
                'Benefícios do exercício adequado:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 4),
              Text('• Manutenção do peso ideal'),
              Text('• Fortalecimento muscular e cardiovascular'),
              Text('• Controle de comportamentos indesejados'),
              Text('• Melhoria do bem-estar mental'),
              Text('• Prevenção de problemas articulares'),
              SizedBox(height: 12),
              Text(
                'IMPORTANTE: Consulte um veterinário antes de iniciar qualquer programa '
                'de exercício intenso, especialmente se o animal tem condições de saúde.',
                style: TextStyle(fontStyle: FontStyle.italic),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }
}
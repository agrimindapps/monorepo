import 'package:core/core.dart' hide FormState, Column;
import 'package:flutter/material.dart';

import '../../domain/calculators/hydration_calculator.dart';
import '../providers/hydration_provider.dart';
import '../widgets/calculation_result_card.dart';

class HydrationPage extends ConsumerStatefulWidget {
  const HydrationPage({super.key});

  @override
  ConsumerState<HydrationPage> createState() => _HydrationPageState();
}

class _HydrationPageState extends ConsumerState<HydrationPage> {
  final _formKey = GlobalKey<FormState>();
  final _weightController = TextEditingController();
  final _currentIntakeController = TextEditingController();
  final _hoursWithoutWaterController = TextEditingController();

  DehydrationLevel _selectedDehydrationLevel = DehydrationLevel.none;
  BodyCondition _selectedBodyCondition = BodyCondition.ideal;
  ActivityLevel _selectedActivityLevel = ActivityLevel.moderate;
  EnvironmentTemp _selectedEnvironmentTemp = EnvironmentTemp.normal;
  bool _isLactating = false;
  bool _hasKidneyDisease = false;
  bool _hasHeartDisease = false;
  bool _hasVomiting = false;
  bool _hasDiarrhea = false;

  @override
  void dispose() {
    _weightController.dispose();
    _currentIntakeController.dispose();
    _hoursWithoutWaterController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(hydrationProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Calculadora de Hidratação'),
        backgroundColor: theme.colorScheme.primaryContainer,
        foregroundColor: theme.colorScheme.onPrimaryContainer,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoCard(),
            const SizedBox(height: 24),
            _buildCalculationForm(),
            if (state.errorMessage != null) ...[
              const SizedBox(height: 16),
              _buildErrorCard(state.errorMessage!),
            ],
            if (state.result != null) ...[
              const SizedBox(height: 24),
              CalculationResultCard(result: state.result!),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.water_drop, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'Sobre a Hidratação Animal',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Esta calculadora avalia as necessidades hídricas do animal considerando seu estado '
              'de hidratação, condição corporal, atividade e fatores ambientais. Fornece '
              'recomendações personalizadas para manutenção e reposição de fluidos.',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Sinais de Desidratação:',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '• Teste da prega cutânea (turgor)\n'
                    '• Mucosas secas ou pegajosas\n'
                    '• Olhos fundos ou sem brilho\n'
                    '• Letargia e fraqueza',
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCalculationForm() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Dados Básicos',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              _buildBasicInfoSection(),
              const SizedBox(height: 24),
              Text(
                'Avaliação de Hidratação',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              _buildHydrationAssessmentSection(),
              const SizedBox(height: 24),
              Text(
                'Fatores Ambientais e Físicos',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              _buildEnvironmentalSection(),
              const SizedBox(height: 24),
              Text(
                'Condições Médicas',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              _buildMedicalConditionsSection(),
              const SizedBox(height: 32),
              _buildCalculateButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBasicInfoSection() {
    return Column(
      children: [
        TextFormField(
          controller: _weightController,
          decoration: const InputDecoration(
            labelText: 'Peso do Animal',
            suffixText: 'kg',
            border: OutlineInputBorder(),
            helperText: 'Peso atual do animal em quilogramas',
          ),
          keyboardType: TextInputType.number,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Peso é obrigatório';
            }
            final weight = double.tryParse(value);
            if (weight == null || weight <= 0) {
              return 'Peso deve ser um número positivo';
            }
            if (weight > 100) {
              return 'Peso muito alto (máximo 100kg)';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<BodyCondition>(
          initialValue: _selectedBodyCondition,
          decoration: const InputDecoration(
            labelText: 'Condição Corporal',
            border: OutlineInputBorder(),
          ),
          items: const [
            DropdownMenuItem(
              value: BodyCondition.underweight,
              child: Text('Abaixo do Peso'),
            ),
            DropdownMenuItem(value: BodyCondition.ideal, child: Text('Ideal')),
            DropdownMenuItem(
              value: BodyCondition.overweight,
              child: Text('Sobrepeso'),
            ),
            DropdownMenuItem(value: BodyCondition.obese, child: Text('Obeso')),
          ],
          onChanged: (value) {
            if (value != null) {
              setState(() {
                _selectedBodyCondition = value;
              });
            }
          },
        ),
      ],
    );
  }

  Widget _buildHydrationAssessmentSection() {
    return Column(
      children: [
        DropdownButtonFormField<DehydrationLevel>(
          initialValue: _selectedDehydrationLevel,
          decoration: const InputDecoration(
            labelText: 'Nível de Desidratação',
            border: OutlineInputBorder(),
          ),
          items: const [
            DropdownMenuItem(
              value: DehydrationLevel.none,
              child: Text('Normal (0-3%)'),
            ),
            DropdownMenuItem(
              value: DehydrationLevel.mild,
              child: Text('Leve (3-5%)'),
            ),
            DropdownMenuItem(
              value: DehydrationLevel.moderate,
              child: Text('Moderada (5-8%)'),
            ),
            DropdownMenuItem(
              value: DehydrationLevel.severe,
              child: Text('Severa (8-12%)'),
            ),
            DropdownMenuItem(
              value: DehydrationLevel.critical,
              child: Text('Crítica (>12%)'),
            ),
          ],
          onChanged: (value) {
            if (value != null) {
              setState(() {
                _selectedDehydrationLevel = value;
              });
            }
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _currentIntakeController,
          decoration: const InputDecoration(
            labelText: 'Ingestão Atual de Água (Opcional)',
            suffixText: 'mL/24h',
            border: OutlineInputBorder(),
            helperText: 'Quantidade de água consumida nas últimas 24 horas',
          ),
          keyboardType: TextInputType.number,
          validator: (value) {
            if (value != null && value.isNotEmpty) {
              final intake = double.tryParse(value);
              if (intake == null || intake < 0) {
                return 'Valor deve ser um número positivo';
              }
              if (intake > 5000) {
                return 'Valor muito alto (máximo 5000 mL)';
              }
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _hoursWithoutWaterController,
          decoration: const InputDecoration(
            labelText: 'Horas sem Água (Opcional)',
            suffixText: 'horas',
            border: OutlineInputBorder(),
            helperText: 'Tempo sem acesso à água',
          ),
          keyboardType: TextInputType.number,
          validator: (value) {
            if (value != null && value.isNotEmpty) {
              final hours = int.tryParse(value);
              if (hours == null || hours < 0) {
                return 'Valor deve ser um número positivo';
              }
              if (hours > 72) {
                return 'Valor muito alto (máximo 72 horas)';
              }
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildEnvironmentalSection() {
    return Column(
      children: [
        DropdownButtonFormField<ActivityLevel>(
          initialValue: _selectedActivityLevel,
          decoration: const InputDecoration(
            labelText: 'Nível de Atividade',
            border: OutlineInputBorder(),
          ),
          items: const [
            DropdownMenuItem(
              value: ActivityLevel.sedentary,
              child: Text('Sedentário'),
            ),
            DropdownMenuItem(
              value: ActivityLevel.moderate,
              child: Text('Moderado'),
            ),
            DropdownMenuItem(value: ActivityLevel.active, child: Text('Ativo')),
            DropdownMenuItem(
              value: ActivityLevel.veryActive,
              child: Text('Muito Ativo'),
            ),
          ],
          onChanged: (value) {
            if (value != null) {
              setState(() {
                _selectedActivityLevel = value;
              });
            }
          },
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<EnvironmentTemp>(
          initialValue: _selectedEnvironmentTemp,
          decoration: const InputDecoration(
            labelText: 'Temperatura Ambiente',
            border: OutlineInputBorder(),
          ),
          items: const [
            DropdownMenuItem(
              value: EnvironmentTemp.cool,
              child: Text('Frio (<20°C)'),
            ),
            DropdownMenuItem(
              value: EnvironmentTemp.normal,
              child: Text('Normal (20-25°C)'),
            ),
            DropdownMenuItem(
              value: EnvironmentTemp.warm,
              child: Text('Quente (25-30°C)'),
            ),
            DropdownMenuItem(
              value: EnvironmentTemp.hot,
              child: Text('Muito Quente (>30°C)'),
            ),
          ],
          onChanged: (value) {
            if (value != null) {
              setState(() {
                _selectedEnvironmentTemp = value;
              });
            }
          },
        ),
      ],
    );
  }

  Widget _buildMedicalConditionsSection() {
    return Column(
      children: [
        SwitchListTile(
          title: const Text('Está lactando?'),
          value: _isLactating,
          onChanged: (value) {
            setState(() {
              _isLactating = value;
            });
          },
        ),
        SwitchListTile(
          title: const Text('Tem doença renal?'),
          value: _hasKidneyDisease,
          onChanged: (value) {
            setState(() {
              _hasKidneyDisease = value;
            });
          },
        ),
        SwitchListTile(
          title: const Text('Tem doença cardíaca?'),
          value: _hasHeartDisease,
          onChanged: (value) {
            setState(() {
              _hasHeartDisease = value;
            });
          },
        ),
        SwitchListTile(
          title: const Text('Está vomitando?'),
          value: _hasVomiting,
          onChanged: (value) {
            setState(() {
              _hasVomiting = value;
            });
          },
        ),
        SwitchListTile(
          title: const Text('Tem diarreia?'),
          value: _hasDiarrhea,
          onChanged: (value) {
            setState(() {
              _hasDiarrhea = value;
            });
          },
        ),
      ],
    );
  }

  Widget _buildCalculateButton() {
    final state = ref.watch(hydrationProvider);

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: state.isLoading ? null : _calculateHydration,
        icon: state.isLoading
            ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.calculate),
        label: Text(state.isLoading ? 'Calculando...' : 'Calcular Hidratação'),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }

  Widget _buildErrorCard(String message) {
    final theme = Theme.of(context);

    return Card(
      color: theme.colorScheme.errorContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(Icons.error_outline, color: theme.colorScheme.error),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onErrorContainer,
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () {
                ref.read(hydrationProvider.notifier).clearError();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _calculateHydration() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final inputs = <String, dynamic>{
      'weight': double.parse(_weightController.text),
      'dehydrationLevel': _selectedDehydrationLevel.index,
      'bodyCondition': _selectedBodyCondition.index,
      'activityLevel': _selectedActivityLevel.index,
      'environmentTemp': _selectedEnvironmentTemp.index,
      'isLactating': _isLactating,
      'hasKidneyDisease': _hasKidneyDisease,
      'hasHeartDisease': _hasHeartDisease,
      'hasVomiting': _hasVomiting,
      'hasDiarrhea': _hasDiarrhea,
    };

    if (_currentIntakeController.text.isNotEmpty) {
      inputs['currentIntake'] = double.parse(_currentIntakeController.text);
    }

    if (_hoursWithoutWaterController.text.isNotEmpty) {
      inputs['hoursWithoutWater'] = int.parse(
        _hoursWithoutWaterController.text,
      );
    }

    ref.read(hydrationProvider.notifier).calculate(inputs);
  }
}

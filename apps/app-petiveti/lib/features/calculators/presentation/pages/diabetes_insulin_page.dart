import 'package:core/core.dart' hide FormState;
import 'package:flutter/material.dart';

import '../providers/diabetes_insulin_provider.dart';
import '../widgets/calculation_result_card.dart';

class DiabetesInsulinPage extends ConsumerStatefulWidget {
  const DiabetesInsulinPage({super.key});

  @override
  ConsumerState<DiabetesInsulinPage> createState() => _DiabetesInsulinPageState();
}

class _DiabetesInsulinPageState extends ConsumerState<DiabetesInsulinPage> {
  final _formKey = GlobalKey<FormState>();
  final _weightController = TextEditingController();
  final _glucoseController = TextEditingController();
  final _previousDoseController = TextEditingController();
  final _timeSinceLastDoseController = TextEditingController();
  
  String _selectedInsulinType = 'regular';
  String _selectedDiabetesType = 'type1';
  bool _isFirstDose = false;
  bool _isEmergency = false;

  @override
  void dispose() {
    _weightController.dispose();
    _glucoseController.dispose();
    _previousDoseController.dispose();
    _timeSinceLastDoseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(diabetesInsulinProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Calculadora de Insulina para Diabetes'),
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
                Icon(
                  Icons.info_outline,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Sobre esta Calculadora',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Esta calculadora determina a dosagem apropriada de insulina com base no peso do animal, '
              'nível de glicose, tipo de diabetes e tipo de insulina. Inclui verificações de segurança '
              'para prevenir hipoglicemia e overdose.',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.errorContainer.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: theme.colorScheme.error.withValues(alpha: 0.5),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.warning_amber,
                    color: theme.colorScheme.error,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'SEMPRE confirme a dosagem com um veterinário antes da administração. '
                      'Esta calculadora é apenas uma ferramenta de apoio.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.error,
                        fontWeight: FontWeight.w500,
                      ),
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
                'Dados do Animal',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              _buildAnimalInfoSection(),
              const SizedBox(height: 24),
              Text(
                'Informações da Insulina',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              _buildInsulinInfoSection(),
              const SizedBox(height: 24),
              Text(
                'Histórico e Condições',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              _buildHistorySection(),
              const SizedBox(height: 32),
              _buildCalculateButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnimalInfoSection() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _weightController,
                decoration: const InputDecoration(
                  labelText: 'Peso do Animal',
                  suffixText: 'kg',
                  border: OutlineInputBorder(),
                  helperText: 'Peso do animal em quilogramas',
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
            ),
          ],
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _glucoseController,
          decoration: const InputDecoration(
            labelText: 'Nível de Glicose',
            suffixText: 'mg/dL',
            border: OutlineInputBorder(),
            helperText: 'Nível atual de glicose no sangue',
          ),
          keyboardType: TextInputType.number,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Nível de glicose é obrigatório';
            }
            final glucose = double.tryParse(value);
            if (glucose == null || glucose <= 0) {
              return 'Nível de glicose deve ser um número positivo';
            }
            if (glucose > 1000) {
              return 'Nível de glicose muito alto (máximo 1000 mg/dL)';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildInsulinInfoSection() {
    return Column(
      children: [
        DropdownButtonFormField<String>(
          initialValue: _selectedInsulinType,
          decoration: const InputDecoration(
            labelText: 'Tipo de Insulina',
            border: OutlineInputBorder(),
            helperText: 'Tipo de insulina a ser administrada',
          ),
          items: const [
            DropdownMenuItem(value: 'regular', child: Text('Regular')),
            DropdownMenuItem(value: 'nph', child: Text('NPH')),
            DropdownMenuItem(value: 'lente', child: Text('Lente')),
            DropdownMenuItem(value: 'ultralente', child: Text('Ultralente')),
          ],
          onChanged: (value) {
            if (value != null) {
              setState(() {
                _selectedInsulinType = value;
              });
            }
          },
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(
          initialValue: _selectedDiabetesType,
          decoration: const InputDecoration(
            labelText: 'Tipo de Diabetes',
            border: OutlineInputBorder(),
            helperText: 'Tipo de diabetes do animal',
          ),
          items: const [
            DropdownMenuItem(value: 'type1', child: Text('Tipo 1')),
            DropdownMenuItem(value: 'type2', child: Text('Tipo 2')),
            DropdownMenuItem(value: 'gestational', child: Text('Gestacional')),
          ],
          onChanged: (value) {
            if (value != null) {
              setState(() {
                _selectedDiabetesType = value;
              });
            }
          },
        ),
      ],
    );
  }

  Widget _buildHistorySection() {
    return Column(
      children: [
        SwitchListTile(
          title: const Text('É a primeira dose?'),
          subtitle: const Text('Marque se esta é a primeira administração de insulina'),
          value: _isFirstDose,
          onChanged: (value) {
            setState(() {
              _isFirstDose = value;
            });
          },
        ),
        const SizedBox(height: 8),
        SwitchListTile(
          title: const Text('É uma emergência?'),
          subtitle: const Text('Marque se o animal está em estado crítico'),
          value: _isEmergency,
          onChanged: (value) {
            setState(() {
              _isEmergency = value;
            });
          },
        ),
        if (!_isFirstDose) ...[
          const SizedBox(height: 16),
          TextFormField(
            controller: _previousDoseController,
            decoration: const InputDecoration(
              labelText: 'Dose Anterior',
              suffixText: 'UI',
              border: OutlineInputBorder(),
              helperText: 'Última dose administrada (Unidades Internacionais)',
            ),
            keyboardType: TextInputType.number,
            validator: (value) {
              if (!_isFirstDose && (value == null || value.isEmpty)) {
                return 'Dose anterior é obrigatória quando não é primeira dose';
              }
              if (value != null && value.isNotEmpty) {
                final dose = double.tryParse(value);
                if (dose == null || dose < 0) {
                  return 'Dose deve ser um número positivo';
                }
                if (dose > 100) {
                  return 'Dose muito alta (máximo 100 UI)';
                }
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _timeSinceLastDoseController,
            decoration: const InputDecoration(
              labelText: 'Horas desde Última Dose',
              suffixText: 'horas',
              border: OutlineInputBorder(),
              helperText: 'Tempo decorrido desde a última administração',
            ),
            keyboardType: TextInputType.number,
            validator: (value) {
              if (!_isFirstDose && (value == null || value.isEmpty)) {
                return 'Tempo desde última dose é obrigatório';
              }
              if (value != null && value.isNotEmpty) {
                final time = int.tryParse(value);
                if (time == null || time < 1) {
                  return 'Tempo deve ser pelo menos 1 hora';
                }
                if (time > 48) {
                  return 'Tempo muito longo (máximo 48 horas)';
                }
              }
              return null;
            },
          ),
        ],
      ],
    );
  }

  Widget _buildCalculateButton() {
    final state = ref.watch(diabetesInsulinProvider);
    
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: state.isLoading ? null : _calculateInsulinDose,
        icon: state.isLoading
            ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.calculate),
        label: Text(state.isLoading ? 'Calculando...' : 'Calcular Dose de Insulina'),
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
            Icon(
              Icons.error_outline,
              color: theme.colorScheme.error,
            ),
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
                ref.read(diabetesInsulinProvider.notifier).clearError();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _calculateInsulinDose() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final inputs = <String, dynamic>{
      'weight': double.parse(_weightController.text),
      'glucoseLevel': double.parse(_glucoseController.text),
      'insulinType': _selectedInsulinType,
      'diabetesType': _selectedDiabetesType,
      'isFirstDose': _isFirstDose,
      'isEmergency': _isEmergency,
    };

    if (!_isFirstDose && _previousDoseController.text.isNotEmpty) {
      inputs['previousDose'] = double.parse(_previousDoseController.text);
    }

    if (!_isFirstDose && _timeSinceLastDoseController.text.isNotEmpty) {
      inputs['timeSinceLastDose'] = int.parse(_timeSinceLastDoseController.text);
    }

    ref.read(diabetesInsulinProvider.notifier).calculate(inputs);
  }
}

import 'package:flutter/material.dart';
import 'package:core/core.dart' hide FormState;

import '../providers/fluid_therapy_provider.dart';
import '../widgets/calculation_result_card.dart';

class FluidTherapyPage extends ConsumerStatefulWidget {
  const FluidTherapyPage({super.key});

  @override
  ConsumerState<FluidTherapyPage> createState() => _FluidTherapyPageState();
}

class _FluidTherapyPageState extends ConsumerState<FluidTherapyPage> {
  final _formKey = GlobalKey<FormState>();
  final _weightController = TextEditingController();
  final _ongoingLossesController = TextEditingController();
  
  String _selectedDehydrationPercentage = '0% (Sem desidratação)';
  String _selectedVomitingFrequency = '0';
  String _selectedDiarrheaSeverity = 'Nenhuma';
  String _selectedCorrectionHours = '24';

  @override
  void dispose() {
    _weightController.dispose();
    _ongoingLossesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(fluidTherapyProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Calculadora de Fluidoterapia'),
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
                  Icons.water_drop,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Sobre a Fluidoterapia',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Esta calculadora determina as necessidades de fluidos para manutenção, '
              'correção de déficits de desidratação e reposição de perdas contínuas. '
              'Baseada em protocolos veterinários estabelecidos.',
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
                    'Fórmulas utilizadas:',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '• Manutenção: 70 ml/kg/dia\n'
                    '• Déficit: peso (kg) × % desidratação × 10\n'
                    '• Taxa total = manutenção + déficit/horas + perdas',
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
                'Dados do Paciente',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              _buildPatientInfoSection(),
              const SizedBox(height: 24),
              Text(
                'Avaliação de Desidratação',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              _buildDehydrationSection(),
              const SizedBox(height: 24),
              Text(
                'Perdas Contínuas',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              _buildLossesSection(),
              const SizedBox(height: 24),
              Text(
                'Parâmetros de Tratamento',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              _buildTreatmentSection(),
              const SizedBox(height: 32),
              _buildCalculateButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPatientInfoSection() {
    return TextFormField(
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
    );
  }

  Widget _buildDehydrationSection() {
    return Column(
      children: [
        DropdownButtonFormField<String>(
          value: _selectedDehydrationPercentage,
          decoration: const InputDecoration(
            labelText: 'Grau de Desidratação',
            border: OutlineInputBorder(),
            helperText: 'Baseado em sinais clínicos (turgor, mucosas, olhos)',
          ),
          items: const [
            DropdownMenuItem(value: '0% (Sem desidratação)', child: Text('0% (Sem desidratação)')),
            DropdownMenuItem(value: '3% (Leve)', child: Text('3% (Leve) - Turgor levemente ↓')),
            DropdownMenuItem(value: '5% (Moderada)', child: Text('5% (Moderada) - Turgor ↓, mucosas secas')),
            DropdownMenuItem(value: '8% (Grave)', child: Text('8% (Grave) - Turgor persistente')),
            DropdownMenuItem(value: '10% (Severa)', child: Text('10% (Severa) - Olhos fundos')),
            DropdownMenuItem(value: '12% (Crítica)', child: Text('12% (Crítica) - Choque')),
          ],
          onChanged: (value) {
            if (value != null) {
              setState(() {
                _selectedDehydrationPercentage = value;
              });
            }
          },
        ),
        const SizedBox(height: 16),
        _buildDehydrationGuide(),
      ],
    );
  }

  Widget _buildDehydrationGuide() {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Guia de Avaliação de Desidratação:',
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '• 3-5%: Turgor cutâneo discretamente diminuído\n'
            '• 6-8%: Turgor persistente, mucosas secas\n'
            '• 9-10%: Turgor muito diminuído, olhos fundos\n'
            '• >10%: Sinais de choque, colapso circulatório',
            style: theme.textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  Widget _buildLossesSection() {
    return Column(
      children: [
        DropdownButtonFormField<String>(
          value: _selectedVomitingFrequency,
          decoration: const InputDecoration(
            labelText: 'Frequência de Vômitos',
            border: OutlineInputBorder(),
            helperText: 'Episódios por dia',
          ),
          items: const [
            DropdownMenuItem(value: '0', child: Text('0 - Nenhum vômito')),
            DropdownMenuItem(value: '1-2', child: Text('1-2 episódios/dia')),
            DropdownMenuItem(value: '3-5', child: Text('3-5 episódios/dia')),
            DropdownMenuItem(value: '6-10', child: Text('6-10 episódios/dia')),
            DropdownMenuItem(value: '>10', child: Text('>10 episódios/dia')),
          ],
          onChanged: (value) {
            if (value != null) {
              setState(() {
                _selectedVomitingFrequency = value;
              });
            }
          },
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(
          value: _selectedDiarrheaSeverity,
          decoration: const InputDecoration(
            labelText: 'Severidade da Diarreia',
            border: OutlineInputBorder(),
            helperText: 'Intensidade e frequência das evacuações',
          ),
          items: const [
            DropdownMenuItem(value: 'Nenhuma', child: Text('Nenhuma')),
            DropdownMenuItem(value: 'Leve', child: Text('Leve - Fezes pastosas')),
            DropdownMenuItem(value: 'Moderada', child: Text('Moderada - Fezes líquidas')),
            DropdownMenuItem(value: 'Severa', child: Text('Severa - Diarreia profusa')),
          ],
          onChanged: (value) {
            if (value != null) {
              setState(() {
                _selectedDiarrheaSeverity = value;
              });
            }
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _ongoingLossesController,
          decoration: const InputDecoration(
            labelText: 'Outras Perdas Estimadas',
            suffixText: 'ml/dia',
            border: OutlineInputBorder(),
            helperText: 'Volume adicional de perdas (drenos, feridas, etc.)',
          ),
          keyboardType: TextInputType.number,
          validator: (value) {
            if (value != null && value.isNotEmpty) {
              final losses = double.tryParse(value);
              if (losses == null || losses < 0) {
                return 'Valor deve ser um número positivo';
              }
              if (losses > 2000) {
                return 'Valor muito alto (máximo 2000 ml/dia)';
              }
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildTreatmentSection() {
    return DropdownButtonFormField<String>(
      value: _selectedCorrectionHours,
      decoration: const InputDecoration(
        labelText: 'Tempo para Correção do Déficit',
        border: OutlineInputBorder(),
        helperText: 'Tempo desejado para corrigir a desidratação',
      ),
      items: const [
        DropdownMenuItem(value: '6', child: Text('6 horas - Emergência')),
        DropdownMenuItem(value: '12', child: Text('12 horas - Urgente')),
        DropdownMenuItem(value: '24', child: Text('24 horas - Padrão')),
        DropdownMenuItem(value: '48', child: Text('48 horas - Conservador')),
      ],
      onChanged: (value) {
        if (value != null) {
          setState(() {
            _selectedCorrectionHours = value;
          });
        }
      },
    );
  }

  Widget _buildCalculateButton() {
    final state = ref.watch(fluidTherapyProvider);
    
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: state.isLoading ? null : _calculateFluidTherapy,
        icon: state.isLoading
            ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.calculate),
        label: Text(state.isLoading ? 'Calculando...' : 'Calcular Fluidoterapia'),
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
                ref.read(fluidTherapyProvider.notifier).clearError();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _calculateFluidTherapy() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final inputs = <String, dynamic>{
      'weight': double.parse(_weightController.text),
      'dehydration_percentage': _selectedDehydrationPercentage,
      'ongoing_losses': _ongoingLossesController.text.isNotEmpty 
          ? double.parse(_ongoingLossesController.text) 
          : 0.0,
      'vomiting_frequency': _selectedVomitingFrequency,
      'diarrhea_severity': _selectedDiarrheaSeverity,
      'correction_hours': _selectedCorrectionHours,
    };

    ref.read(fluidTherapyProvider.notifier).calculate(inputs);
  }
}
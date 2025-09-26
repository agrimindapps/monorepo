import 'package:flutter/material.dart';
import 'package:core/core.dart';

import '../../domain/calculators/anesthesia_calculator.dart';
import '../../domain/entities/calculation_result.dart';
import '../providers/anesthesia_provider.dart';

/// Página da Calculadora de Anestesia
class AnesthesiaPage extends ConsumerStatefulWidget {
  const AnesthesiaPage({super.key});

  @override
  ConsumerState<AnesthesiaPage> createState() => _AnesthesiaPageState();
}

class _AnesthesiaPageState extends ConsumerState<AnesthesiaPage> {
  final _formKey = GlobalKey<FormState>();
  
  // Form controllers
  final _weightController = TextEditingController();
  
  // Form state
  String _selectedSpecies = 'Cão';
  String _selectedProcedureType = 'Anestesia curta (< 30min)';
  String _selectedAgeGroup = 'Adulto (2-8 anos)';
  String _selectedHealthStatus = 'Saudável (ASA I)';

  final calculator = const AnesthesiaCalculator();

  @override
  void dispose() {
    _weightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final anesthesiaState = ref.watch(anesthesiaProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dosagem de Anestésicos'),
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
                    _buildProcedureSection(),
                    const SizedBox(height: 24),
                    _buildPatientAssessmentSection(),
                    const SizedBox(height: 24),
                    if (anesthesiaState.result != null) ...[
                      _buildResultCard(anesthesiaState.result!),
                      const SizedBox(height: 16),
                    ],
                    if (anesthesiaState.errorMessage != null) ...[
                      _buildErrorCard(anesthesiaState.errorMessage!),
                      const SizedBox(height: 16),
                    ],
                  ],
                ),
              ),
            ),
          ),
          _buildCalculateButton(anesthesiaState.isLoading),
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
                Icons.local_hospital,
                color: theme.colorScheme.primary,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                'Calculadora de Anestesia',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Calcula dosagens de medicamentos anestésicos baseado no peso, '
            'espécie e tipo de procedimento. Protocolos baseados em literatura científica atual.',
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
            
            // Peso
            TextFormField(
              controller: _weightController,
              decoration: const InputDecoration(
                labelText: 'Peso do Animal',
                suffixText: 'kg',
                border: OutlineInputBorder(),
                helperText: 'Peso atual em quilogramas',
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
            
            // Espécie
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
          ],
        ),
      ),
    );
  }

  Widget _buildProcedureSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tipo de Procedimento',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            // Tipo de Procedimento
            DropdownButtonFormField<String>(
              value: _selectedProcedureType,
              decoration: const InputDecoration(
                labelText: 'Duração e Complexidade',
                border: OutlineInputBorder(),
              ),
              items: [
                'Sedação leve (exames)',
                'Sedação moderada (curativos)',
                'Anestesia curta (< 30min)',
                'Anestesia média (30-60min)',
                'Anestesia longa (> 60min)',
              ].map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Text(type, style: const TextStyle(fontSize: 13)),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedProcedureType = value;
                  });
                }
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor, selecione o tipo de procedimento';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPatientAssessmentSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Avaliação do Paciente',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            // Faixa Etária
            DropdownButtonFormField<String>(
              value: _selectedAgeGroup,
              decoration: const InputDecoration(
                labelText: 'Faixa Etária',
                border: OutlineInputBorder(),
              ),
              items: [
                'Filhote (< 6 meses)',
                'Jovem (6 meses - 2 anos)',
                'Adulto (2-8 anos)',
                'Senior (> 8 anos)',
              ].map((age) {
                return DropdownMenuItem(
                  value: age,
                  child: Text(age),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedAgeGroup = value;
                  });
                }
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor, selecione a faixa etária';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            
            // Estado de Saúde
            DropdownButtonFormField<String>(
              value: _selectedHealthStatus,
              decoration: const InputDecoration(
                labelText: 'Estado de Saúde (ASA)',
                border: OutlineInputBorder(),
              ),
              items: [
                'Saudável (ASA I)',
                'Doença leve (ASA II)',
                'Doença grave (ASA III)',
                'Risco de vida (ASA IV)',
              ].map((status) {
                return DropdownMenuItem(
                  value: status,
                  child: Text(status, style: const TextStyle(fontSize: 13)),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedHealthStatus = value;
                  });
                }
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor, selecione o estado de saúde';
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
                  Icons.science,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Protocolo Anestésico',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Results
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
            
            if (result.recommendations.isNotEmpty) ...[
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
                  color: theme.colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  item.value.toString(),
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
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
    
    // Separar avisos de monitoramento
    final warnings = recommendations.where((r) => r.severity == ResultSeverity.warning).toList();
    final monitoring = recommendations.where((r) => r.severity != ResultSeverity.warning).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Monitoramento e Cuidados',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        
        // Mostrar avisos primeiro
        if (warnings.isNotEmpty) ...[
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
                    const Icon(Icons.warning, color: Colors.orange, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Avisos Importantes',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.orange,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ...warnings.map((warning) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    '• ${warning.message}',
                    style: theme.textTheme.bodyMedium,
                  ),
                )),
              ],
            ),
          ),
        ],
        
        // Monitoramento
        ...monitoring.map((rec) => Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.monitor_heart,
                size: 16,
                color: Colors.green,
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
          onPressed: isLoading ? null : _calculateAnesthesia,
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
                    Text('Calcular Dosagem'),
                  ],
                ),
        ),
      ),
    );
  }

  void _calculateAnesthesia() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final inputs = {
      'weight': double.parse(_weightController.text),
      'species': _selectedSpecies,
      'procedure_type': _selectedProcedureType,
      'age_group': _selectedAgeGroup,
      'health_status': _selectedHealthStatus,
    };

    ref.read(anesthesiaProvider.notifier).calculate(inputs);
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
                'Esta calculadora fornece protocolos anestésicos baseados em:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text('• Classificação ASA do paciente'),
              Text('• Espécie e peso do animal'),
              Text('• Duração do procedimento'),
              Text('• Idade e estado de saúde'),
              SizedBox(height: 12),
              Text(
                'Protocolos incluem:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 4),
              Text('• Medicamentos e dosagens'),
              Text('• Vias de administração'),
              Text('• Protocolos de monitoramento'),
              Text('• Cuidados específicos'),
              SizedBox(height: 12),
              Text(
                'IMPORTANTE: Esta calculadora é uma ferramenta de auxílio. '
                'Sempre considere a avaliação clínica individual e tenha '
                'medicamentos de emergência disponíveis.',
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
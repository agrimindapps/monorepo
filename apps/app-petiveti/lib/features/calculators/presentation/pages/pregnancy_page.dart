import 'package:core/core.dart' hide FormState;
import 'package:flutter/material.dart';

import '../../domain/calculators/pregnancy_gestacao_calculator.dart';
import '../../domain/entities/calculation_result.dart';
import '../providers/pregnancy_provider.dart';

/// Página da Calculadora de Gestação
class PregnancyPage extends ConsumerStatefulWidget {
  const PregnancyPage({super.key});

  @override
  ConsumerState<PregnancyPage> createState() => _PregnancyPageState();
}

class _PregnancyPageState extends ConsumerState<PregnancyPage> {
  final _formKey = GlobalKey<FormState>();
  final _motherWeightController = TextEditingController();
  final _expectedLitterSizeController = TextEditingController();
  String _selectedSpecies = 'Cão';
  DateTime _matingDate = DateTime.now().subtract(const Duration(days: 30));
  String _selectedBreedSize = 'Médio (10-25kg)';
  bool _isFirstPregnancy = false;

  final calculator = const PregnancyGestacaoCalculator();

  @override
  void dispose() {
    _motherWeightController.dispose();
    _expectedLitterSizeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pregnancyState = ref.watch(pregnancyProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Calculadora de Gestação'),
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
                    _buildBasicInfoSection(),
                    const SizedBox(height: 24),
                    _buildPregnancyDataSection(),
                    const SizedBox(height: 24),
                    _buildOptionalDataSection(),
                    const SizedBox(height: 24),
                    if (pregnancyState.result != null) ...[
                      _buildResultCard(pregnancyState.result!),
                      const SizedBox(height: 16),
                    ],
                    if (pregnancyState.errorMessage != null) ...[
                      _buildErrorCard(pregnancyState.errorMessage!),
                      const SizedBox(height: 16),
                    ],
                  ],
                ),
              ),
            ),
          ),
          _buildCalculateButton(pregnancyState.isLoading),
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
                Icons.pregnant_woman,
                color: theme.colorScheme.primary,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                'Calculadora de Gestação',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Monitora o período gestacional, calcula datas importantes e fornece orientações '
            'de cuidados específicas para cada fase da gestação.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBasicInfoSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Informações Básicas',
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
                      _selectedBreedSize = 'Gato';
                    } else {
                      _selectedBreedSize = 'Médio (10-25kg)';
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
              value: _selectedBreedSize,
              decoration: const InputDecoration(
                labelText: 'Porte da Raça',
                border: OutlineInputBorder(),
              ),
              items: _getBreedSizeOptions(_selectedSpecies).map((size) {
                return DropdownMenuItem(
                  value: size,
                  child: Text(size),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedBreedSize = value;
                  });
                }
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor, selecione o porte da raça';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _motherWeightController,
              decoration: const InputDecoration(
                labelText: 'Peso da Mãe',
                suffixText: 'kg',
                border: OutlineInputBorder(),
                helperText: 'Peso atual da fêmea gestante',
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor, informe o peso da mãe';
                }
                final weight = double.tryParse(value);
                if (weight == null || weight <= 0 || weight > 100) {
                  return 'Peso deve estar entre 0.5 e 100 kg';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPregnancyDataSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Dados da Gestação',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.calendar_today),
              title: const Text('Data do Acasalamento'),
              subtitle: Text(_formatDate(_matingDate)),
              trailing: const Icon(Icons.edit),
              onTap: () => _selectMatingDate(context),
            ),
            const Divider(),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Primeira Gestação'),
              subtitle: const Text('Esta é a primeira gestação da fêmea?'),
              value: _isFirstPregnancy,
              onChanged: (value) {
                setState(() {
                  _isFirstPregnancy = value;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionalDataSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Informações Adicionais (Opcional)',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _expectedLitterSizeController,
              decoration: const InputDecoration(
                labelText: 'Tamanho Esperado da Ninhada',
                suffixText: 'filhotes',
                border: OutlineInputBorder(),
                helperText: 'Quantidade estimada de filhotes (se conhecida)',
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value != null && value.isNotEmpty) {
                  final size = int.tryParse(value);
                  if (size == null || size <= 0 || size > 15) {
                    return 'Número deve estar entre 1 e 15';
                  }
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
                  'Resultado da Análise',
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
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.label,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (item.description != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      item.description!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 8),
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
    );
  }

  Widget _buildRecommendationsSection(List<Recommendation> recommendations) {
    final theme = Theme.of(context);
    final alerts = recommendations.where((r) => r.title.contains('Alerta')).toList();
    final normalRecs = recommendations.where((r) => !r.title.contains('Alerta')).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Cuidados e Recomendações',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        if (alerts.isNotEmpty) ...[
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
                    const Icon(Icons.warning_amber, color: Colors.orange, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Alertas Importantes',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.orange,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ...alerts.map((alert) => Padding(
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
          onPressed: isLoading ? null : _calculatePregnancy,
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
                    Text('Calcular Gestação'),
                  ],
                ),
        ),
      ),
    );
  }

  List<String> _getBreedSizeOptions(String species) {
    if (species == 'Cão') {
      return [
        'Pequeno (até 10kg)',
        'Médio (10-25kg)',
        'Grande (25-40kg)',
        'Gigante (acima de 40kg)',
      ];
    } else {
      return ['Gato'];
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

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  Future<void> _selectMatingDate(BuildContext context) async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: _matingDate,
      firstDate: DateTime.now().subtract(const Duration(days: 90)),
      lastDate: DateTime.now(),
      locale: const Locale('pt', 'BR'),
    );

    if (selectedDate != null) {
      setState(() {
        _matingDate = selectedDate;
      });
    }
  }

  void _calculatePregnancy() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final inputs = {
      'species': _selectedSpecies,
      'mating_date': _matingDate.toIso8601String().split('T')[0],
      'mother_weight': double.parse(_motherWeightController.text),
      'breed_size': _selectedBreedSize,
      'expected_litter_size': _expectedLitterSizeController.text.isNotEmpty 
          ? double.parse(_expectedLitterSizeController.text)
          : null,
      'is_first_pregnancy': _isFirstPregnancy,
    };

    ref.read(pregnancyProvider.notifier).calculate(inputs);
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
                'Esta calculadora monitora a gestação animal e fornece:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text('• Cálculo preciso de datas do parto'),
              Text('• Necessidades nutricionais por fase'),
              Text('• Cuidados específicos por período'),
              Text('• Alertas de parto iminente'),
              Text('• Recomendações veterinárias'),
              SizedBox(height: 12),
              Text(
                'Períodos Gestacionais:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 4),
              Text('• Cães: 58-68 dias (média 63)'),
              Text('• Gatos: 64-70 dias (média 67)'),
              SizedBox(height: 12),
              Text(
                'IMPORTANTE: Esta calculadora é apenas informativa. '
                'Sempre consulte um veterinário para acompanhamento profissional.',
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
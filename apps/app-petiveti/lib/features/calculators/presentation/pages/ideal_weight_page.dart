import 'package:core/core.dart' hide FormState;
import 'package:flutter/material.dart';

import '../../domain/calculators/ideal_weight_calculator.dart';
import '../../domain/entities/calculation_result.dart';
import '../providers/ideal_weight_provider.dart';

/// Página da Calculadora de Peso Ideal
class IdealWeightPage extends ConsumerStatefulWidget {
  const IdealWeightPage({super.key});

  @override
  ConsumerState<IdealWeightPage> createState() => _IdealWeightPageState();
}

class _IdealWeightPageState extends ConsumerState<IdealWeightPage> {
  final _formKey = GlobalKey<FormState>();
  
  // Form controllers
  final _ageController = TextEditingController();
  final _weightController = TextEditingController();
  
  // Form state
  String _selectedSpecies = 'Cão';
  String _selectedBreed = 'Sem raça definida';
  String _selectedSex = 'Macho';
  bool _isNeutered = false;
  double _bcsScore = 5.0;

  final calculator = const IdealWeightCalculator();

  @override
  void dispose() {
    _ageController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final idealWeightState = ref.watch(idealWeightProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Peso Ideal por ECC'),
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
                    _buildPhysicalDataSection(),
                    const SizedBox(height: 24),
                    _buildBcsSection(),
                    const SizedBox(height: 24),
                    if (idealWeightState.result != null) ...[
                      _buildResultCard(idealWeightState.result!),
                      const SizedBox(height: 16),
                    ],
                    if (idealWeightState.errorMessage != null) ...[
                      _buildErrorCard(idealWeightState.errorMessage!),
                      const SizedBox(height: 16),
                    ],
                  ],
                ),
              ),
            ),
          ),
          _buildCalculateButton(idealWeightState.isLoading),
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
                Icons.monitor_weight,
                color: theme.colorScheme.primary,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                'Calculadora de Peso Ideal',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Calcula o peso ideal do animal baseado no Escore de Condição Corporal (ECC), '
            'considerando espécie, raça, sexo e idade para recomendações nutricionais precisas.',
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
                    // Reset breed when species changes
                    _selectedBreed = value == 'Cão' 
                        ? 'Sem raça definida' 
                        : 'Gato doméstico';
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
            
            // Raça/Porte
            DropdownButtonFormField<String>(
              value: _selectedBreed,
              decoration: const InputDecoration(
                labelText: 'Raça/Porte',
                border: OutlineInputBorder(),
              ),
              items: _getBreedOptions(_selectedSpecies).map((breed) {
                return DropdownMenuItem(
                  value: breed,
                  child: Text(breed),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedBreed = value;
                  });
                }
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor, selecione a raça/porte';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            
            // Sexo
            DropdownButtonFormField<String>(
              value: _selectedSex,
              decoration: const InputDecoration(
                labelText: 'Sexo',
                border: OutlineInputBorder(),
              ),
              items: ['Macho', 'Fêmea'].map((sex) {
                return DropdownMenuItem(
                  value: sex,
                  child: Text(sex),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedSex = value;
                  });
                }
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor, selecione o sexo';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            
            // Castrado
            SwitchListTile(
              title: const Text('Animal Castrado/Esterilizado'),
              subtitle: const Text('Influencia no cálculo das necessidades calóricas'),
              value: _isNeutered,
              onChanged: (value) {
                setState(() {
                  _isNeutered = value;
                });
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
            
            // Idade
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
            
            // Peso Atual
            TextFormField(
              controller: _weightController,
              decoration: const InputDecoration(
                labelText: 'Peso Atual',
                suffixText: 'kg',
                border: OutlineInputBorder(),
                helperText: 'Peso atual do animal',
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor, informe o peso atual';
                }
                final weight = double.tryParse(value);
                if (weight == null || weight <= 0 || weight > 100) {
                  return 'Peso deve estar entre 0.1 e 100 kg';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBcsSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Escore de Condição Corporal (ECC)',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Escala de 1 (caquético) a 9 (obeso mórbido)',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 16),
            
            Row(
              children: [
                const Text('1'),
                Expanded(
                  child: Slider(
                    value: _bcsScore,
                    min: 1.0,
                    max: 9.0,
                    divisions: 8,
                    label: _bcsScore.toStringAsFixed(0),
                    onChanged: (value) {
                      setState(() {
                        _bcsScore = value;
                      });
                    },
                  ),
                ),
                const Text('9'),
              ],
            ),
            
            Center(
              child: Column(
                children: [
                  Text(
                    'ECC: ${_bcsScore.toStringAsFixed(0)}',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: _getBcsColor(_bcsScore),
                    ),
                  ),
                  Text(
                    _getBcsDescription(_bcsScore),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: _getBcsColor(_bcsScore),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => _showBcsGuide(context),
              child: const Text('Ver Guia do ECC'),
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
            
            if (result.recommendations.isNotEmpty == true) ...[
              const SizedBox(height: 16),
              Text(
                'Recomendações',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              ...result.recommendations.map((rec) => Padding(
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
                  Text(
                    item.description!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
              ],
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
          onPressed: isLoading ? null : _calculateIdealWeight,
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
                    Text('Calcular Peso Ideal'),
                  ],
                ),
        ),
      ),
    );
  }

  List<String> _getBreedOptions(String species) {
    if (species == 'Cão') {
      return [
        'Sem raça definida',
        'Pequeno (até 10kg)',
        'Médio (10-25kg)',
        'Grande (25-40kg)',
        'Gigante (acima de 40kg)',
      ];
    } else {
      return [
        'Gato doméstico',
        'Maine Coon',
        'Persa',
        'Siamês',
        'Sem raça definida',
      ];
    }
  }

  String _getBcsDescription(double bcsScore) {
    final descriptions = {
      1.0: 'Caquético',
      2.0: 'Muito Magro',
      3.0: 'Magro',
      4.0: 'Levemente Magro',
      5.0: 'Ideal',
      6.0: 'Levemente Sobrepeso',
      7.0: 'Sobrepeso',
      8.0: 'Obeso',
      9.0: 'Obeso Mórbido',
    };
    return descriptions[bcsScore] ?? 'Não Classificado';
  }

  Color _getBcsColor(double bcsScore) {
    final theme = Theme.of(context);
    if (bcsScore <= 2 || bcsScore >= 8) return theme.colorScheme.error;
    if (bcsScore <= 3 || bcsScore >= 7) return Colors.orange;
    if (bcsScore == 5) return Colors.green;
    return theme.colorScheme.primary;
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

  void _calculateIdealWeight() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final inputs = {
      'species': _selectedSpecies,
      'breed': _selectedBreed,
      'sex': _selectedSex,
      'neutered': _isNeutered,
      'age_years': double.parse(_ageController.text),
      'current_weight': double.parse(_weightController.text),
      'bcs_score': _bcsScore,
    };

    ref.read(idealWeightProvider.notifier).calculate(inputs);
  }

  void _showInfoDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sobre a Calculadora'),
        content: const SingleChildScrollView(
          child: Text(
            'Esta calculadora utiliza o Escore de Condição Corporal (ECC) para determinar o peso ideal do seu animal.\n\n'
            'O ECC é uma ferramenta padrão veterinária que avalia a quantidade de gordura corporal, '
            'permitindo calcular o peso ideal e as necessidades nutricionais específicas.\n\n'
            'Os cálculos consideram fatores como espécie, raça, sexo, idade e status reprodutivo '
            'para fornecer recomendações precisas.',
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

  void _showBcsGuide(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Guia do ECC'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView(
            shrinkWrap: true,
            children: [
              _buildBcsGuideItem('1-2', 'Muito Magro', 'Costelas, vértebras e ossos pélvicos facilmente visíveis. Sem gordura corporal detectável.'),
              _buildBcsGuideItem('3', 'Magro', 'Costelas facilmente palpáveis. Cintura bem definida. Gordura abdominal mínima.'),
              _buildBcsGuideItem('4-5', 'Ideal', 'Costelas palpáveis sem excesso de cobertura. Cintura observada atrás das costelas.'),
              _buildBcsGuideItem('6', 'Sobrepeso', 'Costelas palpáveis com ligeira cobertura de gordura. Cintura pouco definida.'),
              _buildBcsGuideItem('7-9', 'Obeso', 'Costelas difíceis de palpar. Depósitos de gordura no dorso e base da cauda.'),
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

  Widget _buildBcsGuideItem(String score, String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'ECC $score - $title',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(description),
        ],
      ),
    );
  }
}
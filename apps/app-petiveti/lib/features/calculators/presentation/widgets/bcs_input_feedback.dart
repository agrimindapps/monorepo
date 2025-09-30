import 'package:core/core.dart';
import 'package:flutter/material.dart';

import '../../domain/entities/body_condition_input.dart';
import '../providers/body_condition_provider.dart';

/// Enhanced input feedback widget providing real-time validation and guidance
class BcsInputFeedback extends ConsumerWidget {
  const BcsInputFeedback({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final state = ref.watch(bodyConditionProvider);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(theme),
            const SizedBox(height: 16),
            _buildCompletionProgress(theme, state),
            const SizedBox(height: 16),
            _buildInputValidation(theme, state),
            if (state.canCalculate) ...[
              const SizedBox(height: 16),
              _buildReadyToCalculate(theme),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.analytics,
            color: theme.colorScheme.primary,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Status do Cálculo',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              'Progresso dos dados inseridos',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCompletionProgress(ThemeData theme, BodyConditionState state) {
    const totalFields = 5; // Weight, age, species, breed, gender
    final completedFields = _countCompletedFields(state);
    final progress = completedFields / totalFields;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Campos Preenchidos',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              '$completedFields/$totalFields',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation<Color>(
              _getProgressColor(progress),
            ),
            minHeight: 6,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          _getProgressMessage(progress),
          style: theme.textTheme.bodySmall?.copyWith(
            color: _getProgressColor(progress),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildInputValidation(ThemeData theme, BodyConditionState state) {
    final validationItems = [
      _ValidationItem(
        label: 'Peso corporal',
        isValid: state.input.currentWeight > 0,
        isRequired: true,
        icon: Icons.monitor_weight,
        hint: 'Peso atual do animal em kg',
      ),
      _ValidationItem(
        label: 'Idade',
        isValid: (state.input.animalAge ?? 0) > 0,
        isRequired: true,
        icon: Icons.calendar_today,
        hint: 'Idade em meses',
      ),
      const _ValidationItem(
        label: 'Espécie',
        isValid: true, // species sempre tem um valor enum default
        isRequired: true,
        icon: Icons.pets,
        hint: 'Cão ou gato',
      ),
      _ValidationItem(
        label: 'Raça',
        isValid: (state.input.animalBreed?.isNotEmpty ?? false),
        isRequired: false,
        icon: Icons.category,
        hint: 'Opcional, mas melhora a precisão',
      ),
      const _ValidationItem(
        label: 'Gênero',
        isValid: true, // usando isNeutered que sempre tem valor bool
        isRequired: true,
        icon: Icons.pets,
        hint: 'Macho ou fêmea, castrado ou não',
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Validação dos Dados',
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 12),
        ...validationItems.map((item) => _buildValidationItem(theme, item)),
      ],
    );
  }

  Widget _buildValidationItem(ThemeData theme, _ValidationItem item) {
    final color = item.isValid 
        ? Colors.green 
        : item.isRequired 
            ? Colors.red 
            : Colors.orange;

    final icon = item.isValid 
        ? Icons.check_circle
        : item.isRequired 
            ? Icons.error
            : Icons.warning;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: color.withValues(alpha: 0.05),
        border: Border.all(
          color: color.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Icon(
              item.icon,
              size: 16,
              color: color,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      item.label,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: color,
                      ),
                    ),
                    if (!item.isRequired) ...[
                      const SizedBox(width: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'opcional',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                if (!item.isValid) ...[
                  const SizedBox(height: 2),
                  Text(
                    item.hint,
                    style: TextStyle(
                      fontSize: 12,
                      color: color.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ],
            ),
          ),
          Icon(
            icon,
            color: color,
            size: 20,
          ),
        ],
      ),
    );
  }

  Widget _buildReadyToCalculate(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green[200]!),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.green[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.play_circle_filled,
              color: Colors.green,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Pronto para Calcular!',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.green[700],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Todos os dados obrigatórios foram preenchidos. Toque no botão para iniciar o cálculo.',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.green[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  int _countCompletedFields(BodyConditionState state) {
    int count = 0;
    
    if (state.input.currentWeight > 0) count++;
    if ((state.input.animalAge ?? 0) > 0) count++;
    count++; // species sempre presente
    if (state.input.animalBreed?.isNotEmpty ?? false) count++;
    count++; // usando isNeutered que sempre tem valor
    
    return count;
  }

  Color _getProgressColor(double progress) {
    if (progress >= 1.0) return Colors.green;
    if (progress >= 0.8) return Colors.blue;
    if (progress >= 0.6) return Colors.orange;
    return Colors.red;
  }

  String _getProgressMessage(double progress) {
    if (progress >= 1.0) return 'Todos os campos preenchidos';
    if (progress >= 0.8) return 'Quase pronto!';
    if (progress >= 0.6) return 'Faltam alguns campos';
    return 'Preencha mais campos';
  }
}

class _ValidationItem {
  final String label;
  final bool isValid;
  final bool isRequired;
  final IconData icon;
  final String hint;

  const _ValidationItem({
    required this.label,
    required this.isValid,
    required this.isRequired,
    required this.icon,
    required this.hint,
  });
}

/// Real-time BCS estimation widget showing preliminary results
class BcsEstimationPreview extends ConsumerWidget {
  const BcsEstimationPreview({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final state = ref.watch(bodyConditionProvider);

    // Only show if we have enough data for a preliminary estimate
    if (!_hasEnoughDataForEstimate(state)) {
      return const SizedBox.shrink();
    }

    final estimatedBcs = _calculatePreliminaryBcs(state);
    final confidence = _calculateConfidence(state);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: theme.colorScheme.primary.withValues(alpha: 0.05),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.preview,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Estimativa Preliminar',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _getBcsColor(estimatedBcs).withValues(alpha: 0.2),
                    border: Border.all(
                      color: _getBcsColor(estimatedBcs),
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      estimatedBcs.toStringAsFixed(1),
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: _getBcsColor(estimatedBcs),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getBcsClassification(estimatedBcs),
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: _getBcsColor(estimatedBcs),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Confiança: ${(confidence * 100).round()}%',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                        ),
                      ),
                      const SizedBox(height: 8),
                      LinearProgressIndicator(
                        value: confidence,
                        backgroundColor: Colors.grey[200],
                        valueColor: AlwaysStoppedAnimation<Color>(
                          _getConfidenceColor(confidence),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.amber[50],
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: Colors.amber[200]!),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 16,
                    color: Colors.amber[700],
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Esta é uma estimativa baseada nos dados inseridos. O cálculo completo fornecerá resultados mais precisos.',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.amber[800],
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

  bool _hasEnoughDataForEstimate(BodyConditionState state) {
    return state.input.currentWeight > 0;
  }

  double _calculatePreliminaryBcs(BodyConditionState state) {
    // Simplified BCS estimation based on available data
    // This would be more sophisticated in a real implementation
    double baseBcs = 5.0; // Average BCS
    
    // Adjust based on weight for species
    if (state.input.species == AnimalSpecies.dog) {
      if (state.input.currentWeight < 5) baseBcs += 0.5; // Small dogs tend to be overweight
      if (state.input.currentWeight > 30) baseBcs -= 0.5; // Large dogs tend to be underweight
    } else if (state.input.species == AnimalSpecies.cat) {
      if (state.input.currentWeight < 3) baseBcs -= 1.0;
      if (state.input.currentWeight > 6) baseBcs += 1.0;
    }
    
    // Adjust based on age
    final age = state.input.animalAge ?? 0;
    if (age > 0) {
      if (age < 12) baseBcs -= 0.5; // Young animals
      if (age > 84) baseBcs += 0.5; // Senior animals
    }
    
    return baseBcs.clamp(1.0, 9.0);
  }

  double _calculateConfidence(BodyConditionState state) {
    double confidence = 0.3; // Base confidence
    
    if (state.input.currentWeight > 0) confidence += 0.3;
    confidence += 0.2; // species sempre presente
    if ((state.input.animalAge ?? 0) > 0) confidence += 0.1;
    if (state.input.animalBreed?.isNotEmpty ?? false) confidence += 0.1;
    
    return confidence.clamp(0.0, 1.0);
  }

  Color _getBcsColor(double bcs) {
    if (bcs <= 3) return Colors.blue;
    if (bcs <= 6) return Colors.green;
    if (bcs <= 7) return Colors.orange;
    return Colors.red;
  }

  String _getBcsClassification(double bcs) {
    if (bcs <= 3) return 'Abaixo do Peso';
    if (bcs <= 5) return 'Peso Ideal';
    if (bcs <= 7) return 'Sobrepeso';
    return 'Obesidade';
  }

  Color _getConfidenceColor(double confidence) {
    if (confidence >= 0.8) return Colors.green;
    if (confidence >= 0.6) return Colors.orange;
    return Colors.red;
  }
}
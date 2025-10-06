import 'package:flutter/material.dart';
import '../../domain/entities/calorie_input.dart';

/// Widget para o quinto step: revisão dos dados e execução do cálculo
class CalorieReviewStep extends StatelessWidget {
  const CalorieReviewStep({
    super.key,
    required this.input,
    required this.isLoading,
    required this.error,
    required this.onCalculate,
  });

  final CalorieInput input;
  final bool isLoading;
  final String? error;
  final VoidCallback onCalculate;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Revisão e Cálculo',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Confira os dados inseridos antes de calcular as necessidades calóricas.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 24),

          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _buildBasicInfoSummary(context),
                  const SizedBox(height: 16),
                  _buildPhysiologicalSummary(context),
                  const SizedBox(height: 16),
                  _buildActivityConditionSummary(context),
                  const SizedBox(height: 16),
                  if (_hasSpecialConditions())
                    _buildSpecialConditionsSummary(context),
                  
                  const SizedBox(height: 24),
                  _buildPreviewCard(context),
                ],
              ),
            ),
          ),
          if (error != null) _buildErrorCard(context),
          const SizedBox(height: 16),
          _buildCalculateButton(context),
        ],
      ),
    );
  }

  Widget _buildBasicInfoSummary(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.pets, color: Theme.of(context).primaryColor),
                const SizedBox(width: 8),
                Text(
                  'Informações Básicas',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildInfoRow('Espécie', input.species.displayName),
            _buildInfoRow('Peso Atual', '${input.weight} kg'),
            if (input.idealWeight != null)
              _buildInfoRow('Peso Ideal', '${input.idealWeight!} kg'),
            _buildInfoRow('Idade', '${input.age} meses (${_formatAge(input.age)})'),
            if (input.breed != null && input.breed!.isNotEmpty)
              _buildInfoRow('Raça', input.breed!),
          ],
        ),
      ),
    );
  }

  Widget _buildPhysiologicalSummary(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.favorite, color: Colors.pink[600]),
                const SizedBox(width: 8),
                Text(
                  'Estado Fisiológico',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildInfoRow('Estado', input.physiologicalState.displayName),
            _buildInfoRow('Fator Base', '${input.physiologicalState.baseFactor}x'),
            if (input.isLactating && input.numberOfOffspring != null)
              _buildInfoRow('Filhotes', '${input.numberOfOffspring} filhotes'),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityConditionSummary(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.directions_run, color: Colors.orange[600]),
                const SizedBox(width: 8),
                Text(
                  'Atividade & Condição Corporal',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildInfoRow('Nível de Atividade', input.activityLevel.displayName),
            _buildInfoRow('Fator Atividade', '${input.activityLevel.factor}x'),
            _buildInfoRow('Condição Corporal', input.bodyConditionScore.displayName),
            _buildInfoRow('Fator BCS', '${input.bodyConditionScore.factor}x'),
          ],
        ),
      ),
    );
  }

  Widget _buildSpecialConditionsSummary(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.medical_services, color: Colors.red[600]),
                const SizedBox(width: 8),
                Text(
                  'Condições Especiais',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (input.environmentalCondition != EnvironmentalCondition.normal)
              _buildInfoRow('Ambiente', input.environmentalCondition.displayName),
            if (input.medicalCondition != MedicalCondition.none)
              _buildInfoRow('Condição Médica', input.medicalCondition.displayName),
            if (input.notes != null && input.notes!.isNotEmpty)
              _buildInfoRow('Observações', input.notes!, maxLines: 3),
          ],
        ),
      ),
    );
  }

  Widget _buildPreviewCard(BuildContext context) {
    final estimatedRer = _calculateEstimatedRer();
    final estimatedMultiplier = _calculateEstimatedMultiplier();
    final estimatedDer = estimatedRer * estimatedMultiplier;

    return Card(
      color: Colors.blue[50],
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.preview, color: Colors.blue[600]),
                const SizedBox(width: 8),
                Text(
                  'Estimativa Prévia',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[600],
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'RER (Repouso): ~${estimatedRer.round()} kcal/dia',
              style: const TextStyle(fontSize: 14),
            ),
            Text(
              'Multiplicador Total: ~${estimatedMultiplier.toStringAsFixed(2)}x',
              style: const TextStyle(fontSize: 14),
            ),
            Text(
              'DER (Total Estimado): ~${estimatedDer.round()} kcal/dia',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.blue[700],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Esta é apenas uma estimativa. Clique em "Calcular" para obter o resultado completo com recomendações detalhadas.',
              style: TextStyle(
                fontSize: 12,
                color: Colors.blue[600],
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorCard(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red[200]!),
      ),
      child: Row(
        children: [
          Icon(Icons.error, color: Colors.red[600], size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              error!,
              style: TextStyle(color: Colors.red[600]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalculateButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton.icon(
        onPressed: isLoading ? null : onCalculate,
        icon: isLoading 
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.calculate),
        label: Text(
          isLoading ? 'Calculando...' : 'Calcular Necessidades Calóricas',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).primaryColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w600),
              maxLines: maxLines,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  bool _hasSpecialConditions() {
    return input.environmentalCondition != EnvironmentalCondition.normal ||
           input.medicalCondition != MedicalCondition.none ||
           (input.notes != null && input.notes!.isNotEmpty);
  }

  String _formatAge(int ageInMonths) {
    if (ageInMonths < 12) {
      return '$ageInMonths meses';
    } else {
      final years = ageInMonths ~/ 12;
      final months = ageInMonths % 12;
      if (months == 0) {
        return '$years ${years == 1 ? 'ano' : 'anos'}';
      } else {
        return '$years ${years == 1 ? 'ano' : 'anos'} e $months ${months == 1 ? 'mês' : 'meses'}';
      }
    }
  }

  double _calculateEstimatedRer() {
    final weight = input.weight;
    if (weight > 2.0) {
      return 70 * (weight * 0.75); // Aproximação simples de peso^0.75
    } else {
      return (30 * weight) + 70;
    }
  }

  double _calculateEstimatedMultiplier() {
    double multiplier = input.physiologicalState.baseFactor;
    if (input.isLactating && input.numberOfOffspring != null) {
      multiplier += 0.25 * input.numberOfOffspring!;
    }
    multiplier *= input.activityLevel.factor;
    multiplier *= input.bodyConditionScore.factor;
    multiplier *= input.environmentalCondition.factor;
    multiplier *= input.medicalCondition.factor;
    
    return multiplier;
  }
}
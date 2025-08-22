import 'package:flutter/material.dart';
import '../../domain/entities/calorie_output.dart';

/// Widget para exibir os resultados do cálculo calórico
class CalorieResultCard extends StatelessWidget {
  const CalorieResultCard({
    super.key,
    required this.output,
    required this.onSaveAsFavorite,
    required this.onRecalculate,
  });

  final CalorieOutput output;
  final VoidCallback onSaveAsFavorite;
  final VoidCallback onRecalculate;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Resultado principal
        _buildMainResultCard(context),
        const SizedBox(height: 16),

        // Necessidades nutricionais
        _buildNutritionalNeedsCard(context),
        const SizedBox(height: 16),

        // Recomendações de alimentação
        _buildFeedingRecommendationsCard(context),
        const SizedBox(height: 16),

        // Manejo de peso
        _buildWeightManagementCard(context),
        const SizedBox(height: 16),

        // Considerações especiais
        if (output.specialConsiderations.isNotEmpty)
          _buildSpecialConsiderationsCard(context),

        // Alertas e recomendações
        if (output.recommendations.isNotEmpty) ...[
          const SizedBox(height: 16),
          _buildRecommendationsCard(context),
        ],
      ],
    );
  }

  Widget _buildMainResultCard(BuildContext context) {
    return Card(
      elevation: 4,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).primaryColor,
              Theme.of(context).primaryColor.withOpacity(0.8),
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              // Título
              Text(
                'Necessidades Calóricas',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),

              // Resultados principais
              Row(
                children: [
                  Expanded(
                    child: _buildMainMetric(
                      context,
                      'RER\n(Repouso)',
                      '${output.restingEnergyRequirement.round()}',
                      'kcal/dia',
                      Icons.hotel,
                    ),
                  ),
                  Container(
                    width: 1,
                    height: 60,
                    color: Colors.white.withOpacity(0.3),
                  ),
                  Expanded(
                    child: _buildMainMetric(
                      context,
                      'DER\n(Total)',
                      '${output.dailyEnergyRequirement.round()}',
                      'kcal/dia',
                      Icons.local_fire_department,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Classificação
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Necessidades: ${output.calorieNeedsClassification}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMainMetric(BuildContext context, String label, String value, String unit, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 32),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          unit,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 10,
          ),
        ),
      ],
    );
  }

  Widget _buildNutritionalNeedsCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.restaurant, color: Colors.green[600]),
                const SizedBox(width: 8),
                Text(
                  'Necessidades Nutricionais',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildNutrientMetric(
                    'Proteína',
                    '${output.proteinRequirement.round()}g',
                    Colors.red[400]!,
                  ),
                ),
                Expanded(
                  child: _buildNutrientMetric(
                    'Gordura',
                    '${output.fatRequirement.round()}g',
                    Colors.orange[400]!,
                  ),
                ),
                Expanded(
                  child: _buildNutrientMetric(
                    'Carboidrato',
                    '${output.carbohydrateRequirement.round()}g',
                    Colors.blue[400]!,
                  ),
                ),
                Expanded(
                  child: _buildNutrientMetric(
                    'Água',
                    '${output.waterRequirement.round()}ml',
                    Colors.cyan[400]!,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNutrientMetric(String label, String value, Color color) {
    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
            border: Border.all(color: color, width: 2),
          ),
          child: Center(
            child: Text(
              value,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildFeedingRecommendationsCard(BuildContext context) {
    final feeding = output.feedingRecommendations;
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.schedule, color: Colors.blue[600]),
                const SizedBox(width: 8),
                Text(
                  'Recomendações de Alimentação',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Informações principais
            Row(
              children: [
                Expanded(
                  child: _buildFeedingInfo(
                    '${feeding.mealsPerDay}x',
                    'Refeições/dia',
                    Icons.restaurant_menu,
                  ),
                ),
                Expanded(
                  child: _buildFeedingInfo(
                    '${feeding.gramsPerMeal.round()}g',
                    'Por refeição',
                    Icons.scale,
                  ),
                ),
                Expanded(
                  child: _buildFeedingInfo(
                    '${feeding.treatAllowance.round()}%',
                    'Petiscos máx.',
                    Icons.cookie,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Horários
            if (feeding.feedingSchedule.isNotEmpty) ...[
              Text(
                'Horários Sugeridos:',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 4),
              Text(feeding.feedingSchedule.join(' • ')),
              const SizedBox(height: 12),
            ],
            
            // Tipo de alimento
            Text(
              'Tipo de Alimento:',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 4),
            Text(feeding.foodType),
            
            // Suplementos
            if (feeding.supplementNeeds.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                'Suplementos Recomendados:',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 4),
              ...feeding.supplementNeeds.map((supplement) => 
                Text('• $supplement', style: TextStyle(fontSize: 12))),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildFeedingInfo(String value, String label, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.blue[600], size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: Colors.grey,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildWeightManagementCard(BuildContext context) {
    final weightAdvice = output.weightManagementAdvice;
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.monitor_weight, color: Colors.purple[600]),
                const SizedBox(width: 8),
                Text(
                  'Manejo de Peso',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            _buildWeightInfo('Objetivo', weightAdvice.weightGoal),
            _buildWeightInfo('Peso Alvo', '${weightAdvice.targetWeight}kg'),
            _buildWeightInfo('Tempo Estimado', weightAdvice.timeToTarget),
            _buildWeightInfo('Monitoramento', weightAdvice.monitoringFrequency),
            
            if (weightAdvice.exerciseRecommendations.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                'Exercícios Recomendados:',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 4),
              ...weightAdvice.exerciseRecommendations.map((exercise) => 
                Text('• $exercise', style: TextStyle(fontSize: 12))),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildWeightInfo(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          SizedBox(
            width: 100,
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
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpecialConsiderationsCard(BuildContext context) {
    return Card(
      color: Colors.orange[50],
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.warning_amber, color: Colors.orange[600]),
                const SizedBox(width: 8),
                Text(
                  'Considerações Especiais',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.orange[800],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...output.specialConsiderations.map((consideration) => 
              Padding(
                padding: const EdgeInsets.only(bottom: 4.0),
                child: Text(
                  consideration,
                  style: TextStyle(color: Colors.orange[800]),
                ),
              )),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendationsCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.lightbulb, color: Colors.amber[600]),
                const SizedBox(width: 8),
                Text(
                  'Recomendações Veterinárias',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...output.recommendations.map((recommendation) {
              Color cardColor;
              IconData icon;
              
              switch (recommendation.severity) {
                case ResultSeverity.danger:
                  cardColor = Colors.red[50]!;
                  icon = Icons.error;
                  break;
                case ResultSeverity.warning:
                  cardColor = Colors.orange[50]!;
                  icon = Icons.warning;
                  break;
                case ResultSeverity.success:
                  cardColor = Colors.green[50]!;
                  icon = Icons.check_circle;
                  break;
                default:
                  cardColor = Colors.blue[50]!;
                  icon = Icons.info;
              }
              
              return Container(
                margin: const EdgeInsets.only(bottom: 8.0),
                padding: const EdgeInsets.all(12.0),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: cardColor.withOpacity(0.5),
                    width: 1,
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      icon,
                      color: _getSeverityColor(recommendation.severity),
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            recommendation.title,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: _getSeverityColor(recommendation.severity),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            recommendation.message,
                            style: const TextStyle(fontSize: 12),
                          ),
                          if (recommendation.actionLabel != null) ...[
                            const SizedBox(height: 8),
                            TextButton(
                              onPressed: () {
                                // TODO: Implementar ação específica
                              },
                              child: Text(recommendation.actionLabel!),
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Color _getSeverityColor(ResultSeverity severity) {
    switch (severity) {
      case ResultSeverity.danger:
        return Colors.red[600]!;
      case ResultSeverity.warning:
        return Colors.orange[600]!;
      case ResultSeverity.success:
        return Colors.green[600]!;
      default:
        return Colors.blue[600]!;
    }
  }
}
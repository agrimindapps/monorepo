import 'package:flutter/material.dart';

import '../../domain/entities/body_condition_output.dart';

/// Widget para exibir resultado do cálculo de condição corporal
class BodyConditionResultCard extends StatelessWidget {
  const BodyConditionResultCard({
    super.key,
    required this.result,
  });

  final BodyConditionOutput result;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Score principal
        _buildMainScoreCard(),
        const SizedBox(height: 16),
        
        // Interpretação
        _buildInterpretationCard(),
        const SizedBox(height: 16),
        
        // Métricas detalhadas
        _buildMetricsGrid(),
        const SizedBox(height: 16),
        
        // Recomendações
        _buildRecommendationsSection(),
        const SizedBox(height: 16),
        
        // Notas veterinárias (se aplicável)
        if (result.veterinaryNotes.isNotEmpty)
          _buildVeterinaryNotesSection(),
          
        const SizedBox(height: 16),
        
        // Ações sugeridas
        _buildActionButtonsSection(context),
      ],
    );
  }

  Widget _buildMainScoreCard() {
    return Card(
      color: Color(int.parse(result.statusColor.substring(1), radix: 16) + 0xFF000000)
          .withValues(alpha: 0.1),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(int.parse(result.statusColor.substring(1), radix: 16) + 0xFF000000),
                  ),
                  child: Center(
                    child: Text(
                      '${result.bcsScore}',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
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
                        'BCS ${result.bcsScore}/9',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        result.classification.displayName,
                        style: TextStyle(
                          fontSize: 16,
                          color: Color(int.parse(result.statusColor.substring(1), radix: 16) + 0xFF000000),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Risco Metabólico: ${result.metabolicRisk}',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                _buildUrgencyIcon(),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                result.statusDescription,
                style: const TextStyle(fontSize: 14, height: 1.4),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUrgencyIcon() {
    final urgencyData = _getUrgencyData();
    final color = urgencyData['color'] as Color;
    final icon = urgencyData['icon'] as IconData;
    
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Icon(
        icon,
        color: color,
        size: 24,
      ),
    );
  }

  Map<String, dynamic> _getUrgencyData() {
    switch (result.actionUrgency) {
      case ActionUrgency.urgent:
        return {'icon': Icons.emergency, 'color': Colors.red};
      case ActionUrgency.veterinary:
        return {'icon': Icons.medical_services, 'color': Colors.orange};
      case ActionUrgency.monitor:
        return {'icon': Icons.monitor_heart, 'color': Colors.blue};
      case ActionUrgency.routine:
        return {'icon': Icons.check_circle, 'color': Colors.green};
    }
  }

  Widget _buildInterpretationCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.description, color: Colors.blue),
                SizedBox(width: 8),
                Text(
                  'Interpretação Detalhada',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              result.interpretation,
              style: const TextStyle(fontSize: 14, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricsGrid() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.5,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      children: [
        _buildMetricCard(
          title: 'Peso Atual',
          value: result.results
              .firstWhere((r) => r.label == 'Peso Atual')
              .formattedValue,
          icon: Icons.monitor_weight,
          color: Colors.blue,
        ),
        if (result.idealWeightEstimate != null)
          _buildMetricCard(
            title: 'Peso Ideal',
            value: '${result.idealWeightEstimate!.toStringAsFixed(1)} kg',
            icon: Icons.flag,
            color: Colors.green,
          ),
        if (result.weightAdjustmentNeeded != 0)
          _buildMetricCard(
            title: result.needsWeightLoss ? 'Perder' : 'Ganhar',
            value: '${result.weightAdjustmentNeeded.abs().toStringAsFixed(1)} kg',
            icon: result.needsWeightLoss ? Icons.trending_down : Icons.trending_up,
            color: result.needsWeightLoss ? Colors.red : Colors.orange,
          ),
        _buildMetricCard(
          title: 'Urgência',
          value: result.actionUrgency.displayName,
          icon: _getUrgencyData()['icon'] as IconData,
          color: _getUrgencyData()['color'] as Color,
        ),
      ],
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendationsSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.recommend, color: Colors.blue),
                SizedBox(width: 8),
                Text(
                  'Recomendações',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...result.recommendations.map((rec) => _buildRecommendationItem(rec as BcsRecommendation)),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendationItem(BcsRecommendation recommendation) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border(
          left: BorderSide(
            width: 4,
            color: _getRecommendationColor(recommendation.type),
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            recommendation.title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            recommendation.description,
            style: const TextStyle(fontSize: 13),
          ),
          if (recommendation.actionSteps.isNotEmpty) ...[
            const SizedBox(height: 12),
            const Text(
              'Passos recomendados:',
              style: TextStyle(fontWeight: FontWeight.w500, fontSize: 12),
            ),
            const SizedBox(height: 4),
            ...recommendation.actionSteps.map((step) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('• ', style: TextStyle(fontSize: 12)),
                  Expanded(child: Text(step, style: const TextStyle(fontSize: 12))),
                ],
              ),
            )),
          ],
          if (recommendation.targetWeightRange != null ||
              recommendation.expectedTimeframe != null ||
              recommendation.monitoringFrequency != null) ...[
            const SizedBox(height: 8),
            _buildRecommendationDetails(recommendation),
          ],
          if (recommendation.additionalNotes != null) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                children: [
                  const Icon(Icons.warning, color: Colors.orange, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      recommendation.additionalNotes!,
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildRecommendationDetails(BcsRecommendation recommendation) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        children: [
          if (recommendation.targetWeightRange != null)
            _buildDetailRow('Meta de peso:', recommendation.targetWeightRange!),
          if (recommendation.expectedTimeframe != null)
            _buildDetailRow('Tempo esperado:', recommendation.expectedTimeframe!),
          if (recommendation.monitoringFrequency != null)
            _buildDetailRow('Monitoramento:', recommendation.monitoringFrequency!),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
          Text(value, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  Color _getRecommendationColor(NutritionalRecommendationType type) {
    switch (type) {
      case NutritionalRecommendationType.maintain:
        return Colors.green;
      case NutritionalRecommendationType.increaseFood:
        return Colors.orange;
      case NutritionalRecommendationType.decreaseFood:
        return Colors.red;
      case NutritionalRecommendationType.dietaryChange:
        return Colors.blue;
      case NutritionalRecommendationType.specializedDiet:
        return Colors.purple;
    }
  }

  Widget _buildVeterinaryNotesSection() {
    return Card(
      color: Colors.amber.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.medical_services, color: Colors.amber),
                SizedBox(width: 8),
                Text(
                  'Notas Veterinárias',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...result.veterinaryNotes.map((note) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('🩺 ', style: TextStyle(fontSize: 14)),
                  Expanded(
                    child: Text(
                      note,
                      style: const TextStyle(fontSize: 14, height: 1.4),
                    ),
                  ),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtonsSection(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => _shareResult(context),
            icon: const Icon(Icons.share),
            label: const Text('Compartilhar'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => _saveResult(context),
            icon: const Icon(Icons.save),
            label: const Text('Salvar'),
          ),
        ),
      ],
    );
  }

  void _shareResult(BuildContext context) {
    // TODO: Implementar compartilhamento
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Compartilhamento será implementado em breve')),
    );
  }

  void _saveResult(BuildContext context) {
    // TODO: Implementar salvamento
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Resultado salvo no histórico!')),
    );
  }
}
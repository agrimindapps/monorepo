import 'package:flutter/material.dart';

/// Widget responsible for veterinary guidelines and weight calculator following SRP
/// 
/// Single responsibility: Display veterinary guidelines and provide weight calculation tools
class WeightVeterinaryGuidelines extends StatefulWidget {
  const WeightVeterinaryGuidelines({super.key});

  @override
  State<WeightVeterinaryGuidelines> createState() => _WeightVeterinaryGuidelinesState();
}

class _WeightVeterinaryGuidelinesState extends State<WeightVeterinaryGuidelines> {
  final _breedController = TextEditingController();
  final _ageController = TextEditingController();

  @override
  void dispose() {
    _breedController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildVeterinaryGuidelinesCard(),
          const SizedBox(height: 16),
          _buildWeightCalculatorCard(),
          const SizedBox(height: 16),
          _buildAlertsCard(),
        ],
      ),
    );
  }

  Widget _buildVeterinaryGuidelinesCard() {
    final theme = Theme.of(context);
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.medical_information, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'Diretrizes Veterinárias',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildGuidelineItem(
              theme,
              'Cães Adultos',
              'Perda de peso saudável: 1-2% do peso corporal por semana',
              Icons.pets,
              Colors.blue,
            ),
            _buildGuidelineItem(
              theme,
              'Gatos Adultos',
              'Perda de peso saudável: 0.5-1% do peso corporal por semana',
              Icons.pets,
              Colors.orange,
            ),
            _buildGuidelineItem(
              theme,
              'Filhotes',
              'Crescimento rápido até 6 meses, monitoramento semanal',
              Icons.child_care,
              Colors.green,
            ),
            _buildGuidelineItem(
              theme,
              'Idosos (+7 anos)',
              'Monitoramento mais frequente, atenção à massa muscular',
              Icons.elderly,
              Colors.purple,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGuidelineItem(ThemeData theme, String title, String description, IconData icon, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border(left: BorderSide(color: color, width: 4)),
        color: color.withValues(alpha: 0.05),
        borderRadius: const BorderRadius.only(
          topRight: Radius.circular(8),
          bottomRight: Radius.circular(8),
        ),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
                Text(
                  description,
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeightCalculatorCard() {
    final theme = Theme.of(context);
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Calculadora de Peso Ideal',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            _buildWeightCalculator(theme),
          ],
        ),
      ),
    );
  }

  Widget _buildWeightCalculator(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _breedController,
                  decoration: const InputDecoration(
                    labelText: 'Raça',
                    prefixIcon: Icon(Icons.pets),
                    isDense: true,
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextField(
                  controller: _ageController,
                  decoration: const InputDecoration(
                    labelText: 'Idade (anos)',
                    prefixIcon: Icon(Icons.cake),
                    isDense: true,
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: _calculateIdealWeight,
            icon: const Icon(Icons.calculate),
            label: const Text('Calcular Peso Ideal'),
          ),
        ],
      ),
    );
  }

  Widget _buildAlertsCard() {
    final theme = Theme.of(context);
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Sinais de Alerta',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 16),
            _buildAlertItem(theme, 'Perda de peso > 10% em 3 meses', Colors.red),
            _buildAlertItem(theme, 'Ganho de peso > 15% em 6 meses', Colors.orange),
            _buildAlertItem(theme, 'Flutuações frequentes (>5% por semana)', Colors.yellow),
          ],
        ),
      ),
    );
  }

  Widget _buildAlertItem(ThemeData theme, String text, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(Icons.warning, color: color, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: theme.textTheme.bodySmall?.copyWith(color: color),
            ),
          ),
        ],
      ),
    );
  }

  void _calculateIdealWeight() {
    if (_breedController.text.isEmpty || _ageController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, preencha raça e idade para calcular o peso ideal'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final age = int.tryParse(_ageController.text);
    if (age == null || age < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, insira uma idade válida'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Mock calculation based on breed and age
    final result = _performWeightCalculation(_breedController.text, age);
    
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Peso Ideal Calculado'),
        content: Text(result),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fechar'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              _showVeterinaryConsultationDialog();
            },
            child: const Text('Consultar Veterinário'),
          ),
        ],
      ),
    );
  }

  String _performWeightCalculation(String breed, int age) {
    // Simplified calculation logic for demonstration
    final breedLower = breed.toLowerCase();
    double minWeight, maxWeight;

    if (breedLower.contains('labrador') || breedLower.contains('golden')) {
      minWeight = 25;
      maxWeight = 35;
    } else if (breedLower.contains('chihuahua') || breedLower.contains('yorkshire')) {
      minWeight = 2;
      maxWeight = 5;
    } else if (breedLower.contains('pastor') || breedLower.contains('german')) {
      minWeight = 30;
      maxWeight = 40;
    } else if (breedLower.contains('persa') || breedLower.contains('siamês')) {
      minWeight = 3;
      maxWeight = 6;
    } else {
      // Default ranges
      minWeight = 15;
      maxWeight = 30;
    }

    // Adjust for age
    if (age < 1) {
      minWeight *= 0.3;
      maxWeight *= 0.5;
    } else if (age > 8) {
      minWeight *= 0.9;
      maxWeight *= 0.9;
    }

    return 'Com base nas informações fornecidas ($breed, $age anos), '
           'o peso ideal estimado é entre ${minWeight.toStringAsFixed(1)}-${maxWeight.toStringAsFixed(1)}kg.\n\n'
           'Esta é uma estimativa baseada em padrões gerais. Consulte um veterinário para uma avaliação precisa.';
  }

  void _showVeterinaryConsultationDialog() {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Consulta Veterinária'),
        content: const Text(
          'Recomendamos consultar um veterinário para definir metas de peso adequadas para seu pet.\n\n'
          'O profissional poderá avaliar:\n'
          '• Condição corporal atual\n'
          '• Histórico de saúde\n'
          '• Necessidades específicas\n'
          '• Plano nutricional personalizado'
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fechar'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              // Navigate to veterinary consultation booking
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Funcionalidade de agendamento será implementada em breve'),
                ),
              );
            },
            child: const Text('Agendar Consulta'),
          ),
        ],
      ),
    );
  }
}
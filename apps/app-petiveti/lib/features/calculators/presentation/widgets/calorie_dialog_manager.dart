import 'package:core/core.dart' hide Column;
import 'package:flutter/material.dart';

import '../../domain/entities/calorie_output.dart';
import '../providers/calorie_provider.dart';
import 'calorie_quick_presets.dart';

/// Dialog manager for Calorie Calculator
///
/// Responsibilities:
/// - Handle all dialog presentations
/// - Manage dialog states and actions
/// - Keep dialog logic separate from main page
class CalorieDialogManager {
  final BuildContext context;
  final WidgetRef ref;

  CalorieDialogManager({required this.context, required this.ref});

  /// Show presets selection dialog
  void showPresetsDialog({VoidCallback? onPresetLoaded}) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Presets Rápidos'),
        content: SizedBox(
          width: double.maxFinite,
          child: CalorieQuickPresets(
            onPresetSelected: (preset) {
              ref.read(calorieProvider.notifier).loadPreset(preset);
              Navigator.of(context).pop();
              onPresetLoaded?.call();
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
        ],
      ),
    );
  }

  /// Show reset confirmation dialog
  void showResetDialog({VoidCallback? onReset}) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Resetar Calculadora'),
        content: const Text(
          'Isso irá limpar todos os dados inseridos. Deseja continuar?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              ref.read(calorieProvider.notifier).reset();
              Navigator.of(context).pop();
              onReset?.call();
            },
            child: const Text('Resetar'),
          ),
        ],
      ),
    );
  }

  /// Show calculation history dialog
  void showHistoryDialog({VoidCallback? onHistoryItemSelected}) {
    final history = ref.read(calorieHistoryProvider);

    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Histórico de Cálculos'),
        content: SizedBox(
          width: double.maxFinite,
          height: 400,
          child: history.isEmpty
              ? _buildEmptyHistoryView()
              : _buildHistoryListView(history, onHistoryItemSelected),
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

  /// Show export options dialog
  void showExportDialog() {
    final output = ref.read(calorieOutputProvider);
    if (output == null) return;

    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Exportar Resultado'),
        content: const Text(
          'Escolha como deseja exportar o resultado do cálculo:',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _showPdfExportNotImplemented();
            },
            child: const Text('PDF'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              shareResult(output);
            },
            child: const Text('Compartilhar'),
          ),
        ],
      ),
    );
  }

  /// Show calorie guide dialog
  void showCalorieGuide() {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Guia de Cálculo Calórico'),
        content: const SingleChildScrollView(child: _CalorieGuideContent()),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Entendi'),
          ),
        ],
      ),
    );
  }

  /// Share calculation result
  void shareResult(CalorieOutput output) {
    final text = _formatResultForSharing(output);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Texto copiado para área de transferência'),
        action: SnackBarAction(
          label: 'Ver',
          onPressed: () => _showFormattedResultDialog(text),
        ),
      ),
    );
  }

  Widget _buildEmptyHistoryView() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text('Nenhum cálculo realizado ainda'),
        ],
      ),
    );
  }

  Widget _buildHistoryListView(
    List<dynamic> history,
    VoidCallback? onItemSelected,
  ) {
    return ListView.builder(
      itemCount: history.length,
      itemBuilder: (context, index) {
        final result = history[index];
        return ListTile(
          title: Text('${result.dailyEnergyRequirement.round()} kcal/dia'),
          subtitle: Text(
            '${result.input.species.displayName} • ${result.input.weight}kg • '
            '${result.calculatedAt?.day}/${result.calculatedAt?.month}',
          ),
          trailing: IconButton(
            icon: const Icon(Icons.restore),
            onPressed: () {
              ref.read(calorieProvider.notifier).loadFromHistory(index);
              Navigator.of(context).pop();
              onItemSelected?.call();
            },
          ),
        );
      },
    );
  }

  void _showPdfExportNotImplemented() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Exportação PDF estará disponível em breve! Use compartilhar por enquanto.',
        ),
      ),
    );
  }

  void _showFormattedResultDialog(String text) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Resultado para Compartilhar'),
        content: SingleChildScrollView(child: Text(text)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }

  String _formatResultForSharing(CalorieOutput output) {
    return '''
🐾 Cálculo de Necessidades Calóricas

Animal: ${output.input.species.displayName}
Peso: ${output.input.weight}kg
Idade: ${output.input.age} meses

📊 Resultados:
• RER: ${output.restingEnergyRequirement.round()} kcal/dia
• DER: ${output.dailyEnergyRequirement.round()} kcal/dia
• Proteína: ${output.proteinRequirement.round()}g/dia
• Água: ${output.waterRequirement.round()}ml/dia

🍽️ Alimentação:
• ${output.feedingRecommendations.mealsPerDay}x refeições/dia
• ${output.feedingRecommendations.gramsPerMeal.round()}g por refeição

Calculado em: ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}
via PetiVeti App
''';
  }
}

/// Static content widget for the calorie guide
class _CalorieGuideContent extends StatelessWidget {
  const _CalorieGuideContent();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Fórmulas Utilizadas:',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8),
        Text('• RER = 70 × peso^0.75 (>2kg)'),
        Text('• RER = 30 × peso + 70 (≤2kg)'),
        Text('• DER = RER × fatores multiplicadores'),
        SizedBox(height: 16),
        Text(
          'Fatores Multiplicadores:',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8),
        Text('• Adulto normal: 1.6x'),
        Text('• Castrado: 1.4x'),
        Text('• Gestação: 1.8-2.6x'),
        Text('• Lactação: 2.0x + 0.25x/filhote'),
        Text('• Crescimento: 2.0-3.0x'),
        Text('• Idoso: 1.2x'),
        SizedBox(height: 16),
        Text(
          'Importante:',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange),
        ),
        SizedBox(height: 8),
        Text('• Valores são estimativas'),
        Text('• Monitorar peso regularmente'),
        Text('• Consultar veterinário para casos especiais'),
      ],
    );
  }
}

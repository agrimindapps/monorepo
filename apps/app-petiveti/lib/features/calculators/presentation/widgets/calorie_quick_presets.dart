import 'package:flutter/material.dart';
import '../providers/calorie_provider.dart';

/// Widget para seleção rápida de presets comuns
class CalorieQuickPresets extends StatelessWidget {
  const CalorieQuickPresets({
    super.key,
    required this.onPresetSelected,
  });

  final void Function(CaloriePreset) onPresetSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Selecione um cenário comum para começar rapidamente:',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 16),
        
        ...CaloriePreset.values.map((preset) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: GestureDetector(
              onTap: () => onPresetSelected(preset),
              child: Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: _getPresetColor(preset).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _getPresetColor(preset).withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      _getPresetIcon(preset),
                      color: _getPresetColor(preset),
                      size: 32,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _getPresetTitle(preset),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: _getPresetColor(preset),
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _getPresetDescription(preset),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _getPresetSpecs(preset),
                            style: TextStyle(
                              fontSize: 11,
                              color: _getPresetColor(preset),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios,
                      color: _getPresetColor(preset),
                      size: 16,
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

  String _getPresetTitle(CaloriePreset preset) {
    switch (preset) {
      case CaloriePreset.adultDogNormal:
        return 'Cão Adulto Normal';
      case CaloriePreset.adultCatNormal:
        return 'Gato Adulto Normal';
      case CaloriePreset.puppyGrowth:
        return 'Filhote em Crescimento';
      case CaloriePreset.seniorDog:
        return 'Cão Idoso';
      case CaloriePreset.lactatingQueen:
        return 'Gata Lactante';
    }
  }

  String _getPresetDescription(CaloriePreset preset) {
    switch (preset) {
      case CaloriePreset.adultDogNormal:
        return 'Cão adulto saudável, atividade moderada, peso ideal';
      case CaloriePreset.adultCatNormal:
        return 'Gato adulto saudável, atividade leve, peso ideal';
      case CaloriePreset.puppyGrowth:
        return 'Filhote de 6 meses em fase de crescimento';
      case CaloriePreset.seniorDog:
        return 'Cão idoso (8+ anos), atividade reduzida';
      case CaloriePreset.lactatingQueen:
        return 'Gata amamentando 4 filhotes';
    }
  }

  String _getPresetSpecs(CaloriePreset preset) {
    switch (preset) {
      case CaloriePreset.adultDogNormal:
        return '25kg • 3 anos • Atividade moderada';
      case CaloriePreset.adultCatNormal:
        return '4.5kg • 3 anos • Atividade leve';
      case CaloriePreset.puppyGrowth:
        return '8kg • 6 meses • Crescimento ativo';
      case CaloriePreset.seniorDog:
        return '20kg • 8 anos • Atividade reduzida';
      case CaloriePreset.lactatingQueen:
        return '4kg • 2 anos • Lactação (4 filhotes)';
    }
  }

  IconData _getPresetIcon(CaloriePreset preset) {
    switch (preset) {
      case CaloriePreset.adultDogNormal:
        return Icons.pets;
      case CaloriePreset.adultCatNormal:
        return Icons.pets;
      case CaloriePreset.puppyGrowth:
        return Icons.child_friendly;
      case CaloriePreset.seniorDog:
        return Icons.elderly;
      case CaloriePreset.lactatingQueen:
        return Icons.child_care;
    }
  }

  Color _getPresetColor(CaloriePreset preset) {
    switch (preset) {
      case CaloriePreset.adultDogNormal:
        return Colors.blue;
      case CaloriePreset.adultCatNormal:
        return Colors.orange;
      case CaloriePreset.puppyGrowth:
        return Colors.green;
      case CaloriePreset.seniorDog:
        return Colors.purple;
      case CaloriePreset.lactatingQueen:
        return Colors.pink;
    }
  }
}
import 'package:flutter/material.dart';
import '../../domain/entities/calorie_input.dart';

/// Widget para o quarto step: condições especiais (ambientais e médicas)
class CalorieSpecialConditionsStep extends StatefulWidget {
  const CalorieSpecialConditionsStep({
    super.key,
    required this.input,
    required this.validationErrors,
    required this.onInputChanged,
  });

  final CalorieInput input;
  final List<String> validationErrors;
  final Function(CalorieInput) onInputChanged;

  @override
  State<CalorieSpecialConditionsStep> createState() => _CalorieSpecialConditionsStepState();
}

class _CalorieSpecialConditionsStepState extends State<CalorieSpecialConditionsStep> {
  late TextEditingController _notesController;

  @override
  void initState() {
    super.initState();
    _notesController = TextEditingController(text: widget.input.notes ?? '');
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Título do step
          Text(
            'Condições Especiais',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Informe condições ambientais e médicas que possam afetar o metabolismo.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue[200]!),
            ),
            child: Row(
              children: [
                Icon(Icons.info, color: Colors.blue[600], size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Este passo é opcional, mas ajuda a refinar o cálculo.',
                    style: TextStyle(
                      color: Colors.blue[700],
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Condições ambientais
                  _buildEnvironmentalConditionsCard(),
                  const SizedBox(height: 20),

                  // Condições médicas
                  _buildMedicalConditionsCard(),
                  const SizedBox(height: 20),

                  // Notas adicionais
                  _buildNotesField(),
                  const SizedBox(height: 20),

                  // Resumo dos ajustes
                  _buildAdjustmentsSummary(),
                ],
              ),
            ),
          ),

          // Erros de validação
          if (widget.validationErrors.isNotEmpty)
            _buildValidationErrors(),
        ],
      ),
    );
  }

  Widget _buildEnvironmentalConditionsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.thermostat, color: Colors.blue[600]),
                const SizedBox(width: 8),
                Text(
                  'Condições Ambientais',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Temperatura e ambiente onde o animal vive.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 16),
            ...EnvironmentalCondition.values.map((condition) {
              final isSelected = widget.input.environmentalCondition == condition;
              return Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: GestureDetector(
                  onTap: () => _updateEnvironmentalCondition(condition),
                  child: Container(
                    padding: const EdgeInsets.all(12.0),
                    decoration: BoxDecoration(
                      color: isSelected 
                          ? Theme.of(context).primaryColor.withValues(alpha: 0.1)
                          : null,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isSelected 
                            ? Theme.of(context).primaryColor
                            : Colors.grey[300]!,
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Radio<EnvironmentalCondition>(
                          value: condition,
                          groupValue: widget.input.environmentalCondition,
                          onChanged: (value) => _updateEnvironmentalCondition(value!),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                condition.displayName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                _getEnvironmentalDescription(condition),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                              if (condition.factor != 1.0)
                                Text(
                                  'Ajuste: ${(condition.factor * 100).round()}%',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Theme.of(context).primaryColor,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                            ],
                          ),
                        ),
                        _getEnvironmentalIcon(condition),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildMedicalConditionsCard() {
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
                  'Condições Médicas',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Condições de saúde que afetam necessidades calóricas.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 16),
            ...MedicalCondition.values.map((condition) {
              final isSelected = widget.input.medicalCondition == condition;
              return Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: GestureDetector(
                  onTap: () => _updateMedicalCondition(condition),
                  child: Container(
                    padding: const EdgeInsets.all(12.0),
                    decoration: BoxDecoration(
                      color: isSelected 
                          ? _getMedicalConditionColor(condition).withValues(alpha: 0.1)
                          : null,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isSelected 
                            ? _getMedicalConditionColor(condition)
                            : Colors.grey[300]!,
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Radio<MedicalCondition>(
                          value: condition,
                          groupValue: widget.input.medicalCondition,
                          onChanged: (value) => _updateMedicalCondition(value!),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                condition.displayName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                _getMedicalDescription(condition),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                              if (condition.factor != 1.0)
                                Text(
                                  'Ajuste: ${(condition.factor * 100).round()}%',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: _getMedicalConditionColor(condition),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                            ],
                          ),
                        ),
                        _getMedicalIcon(condition),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildNotesField() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.notes, color: Colors.green[600]),
                const SizedBox(width: 8),
                Text(
                  'Observações Adicionais',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Informações extras sobre comportamento alimentar, medicações, etc.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _notesController,
              decoration: const InputDecoration(
                hintText: 'Ex: Animal muito ansioso na hora da comida, toma medicação X...',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.all(16),
              ),
              maxLines: 4,
              onChanged: (value) {
                _updateNotes(value.isEmpty ? null : value);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdjustmentsSummary() {
    final envFactor = widget.input.environmentalCondition.factor;
    final medFactor = widget.input.medicalCondition.factor;
    final totalAdjustment = envFactor * medFactor;
    
    if (envFactor == 1.0 && medFactor == 1.0) {
      return const SizedBox.shrink();
    }

    return Card(
      color: Colors.purple[50],
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.tune, color: Colors.purple[600]),
                const SizedBox(width: 8),
                Text(
                  'Resumo de Ajustes',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.purple[600],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (envFactor != 1.0)
              Text('• Ambiental: ${(envFactor * 100).round()}% (${envFactor}x)'),
            if (medFactor != 1.0)
              Text('• Médico: ${(medFactor * 100).round()}% (${medFactor}x)'),
            const SizedBox(height: 8),
            Text(
              'Ajuste total combinado: ${(totalAdjustment * 100).round()}% (${totalAdjustment.toStringAsFixed(2)}x)',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.purple[700],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _getAdjustmentAdvice(totalAdjustment),
              style: TextStyle(
                fontSize: 12,
                color: Colors.purple[700],
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildValidationErrors() {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.error, color: Colors.red[600], size: 20),
              const SizedBox(width: 8),
              Text(
                'Correções necessárias:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.red[600],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...widget.validationErrors.map((error) => Text(
            '• $error',
            style: TextStyle(color: Colors.red[600]),
          )),
        ],
      ),
    );
  }

  String _getEnvironmentalDescription(EnvironmentalCondition condition) {
    switch (condition) {
      case EnvironmentalCondition.normal:
        return 'Temperatura ambiente confortável';
      case EnvironmentalCondition.cold:
        return 'Ambiente frio, gasta mais energia';
      case EnvironmentalCondition.hot:
        return 'Ambiente quente, menos apetite';
      case EnvironmentalCondition.highAltitude:
        return 'Alta altitude, maior demanda energética';
    }
  }

  String _getMedicalDescription(MedicalCondition condition) {
    switch (condition) {
      case MedicalCondition.none:
        return 'Animal saudável, sem condições especiais';
      case MedicalCondition.diabetes:
        return 'Requer controle rigoroso de carboidratos';
      case MedicalCondition.kidneyDisease:
        return 'Necessita dieta com proteína restrita';
      case MedicalCondition.heartDisease:
        return 'Requer dieta com baixo sódio';
      case MedicalCondition.liverDisease:
        return 'Metabolismo hepático comprometido';
      case MedicalCondition.hyperthyroidism:
        return 'Metabolismo acelerado, mais calorias';
      case MedicalCondition.hypothyroidism:
        return 'Metabolismo lento, menos calorias';
      case MedicalCondition.cancer:
        return 'Pode necessitar calorias extras';
      case MedicalCondition.recovery:
        return 'Recuperação pós-cirúrgica';
    }
  }

  Widget _getEnvironmentalIcon(EnvironmentalCondition condition) {
    IconData iconData;
    Color color;

    switch (condition) {
      case EnvironmentalCondition.normal:
        iconData = Icons.home;
        color = Colors.green;
        break;
      case EnvironmentalCondition.cold:
        iconData = Icons.ac_unit;
        color = Colors.blue;
        break;
      case EnvironmentalCondition.hot:
        iconData = Icons.wb_sunny;
        color = Colors.orange;
        break;
      case EnvironmentalCondition.highAltitude:
        iconData = Icons.landscape;
        color = Colors.purple;
        break;
    }

    return Icon(iconData, color: color, size: 24);
  }

  Widget _getMedicalIcon(MedicalCondition condition) {
    IconData iconData;
    Color color = _getMedicalConditionColor(condition);

    switch (condition) {
      case MedicalCondition.none:
        iconData = Icons.favorite;
        break;
      case MedicalCondition.diabetes:
        iconData = Icons.medication;
        break;
      case MedicalCondition.kidneyDisease:
        iconData = Icons.water_drop;
        break;
      case MedicalCondition.heartDisease:
        iconData = Icons.favorite_border;
        break;
      case MedicalCondition.liverDisease:
        iconData = Icons.shield;
        break;
      case MedicalCondition.hyperthyroidism:
        iconData = Icons.trending_up;
        break;
      case MedicalCondition.hypothyroidism:
        iconData = Icons.trending_down;
        break;
      case MedicalCondition.cancer:
        iconData = Icons.warning;
        break;
      case MedicalCondition.recovery:
        iconData = Icons.healing;
        break;
    }

    return Icon(iconData, color: color, size: 24);
  }

  Color _getMedicalConditionColor(MedicalCondition condition) {
    switch (condition) {
      case MedicalCondition.none:
        return Colors.green;
      case MedicalCondition.diabetes:
      case MedicalCondition.kidneyDisease:
      case MedicalCondition.heartDisease:
      case MedicalCondition.liverDisease:
        return Colors.orange;
      case MedicalCondition.hyperthyroidism:
        return Colors.red;
      case MedicalCondition.hypothyroidism:
        return Colors.blue;
      case MedicalCondition.cancer:
        return Colors.red[700]!;
      case MedicalCondition.recovery:
        return Colors.purple;
    }
  }

  String _getAdjustmentAdvice(double factor) {
    if (factor < 0.8) {
      return 'Redução significativa nas calorias - monitoramento veterinário essencial';
    } else if (factor < 1.0) {
      return 'Necessidades calóricas reduzidas devido às condições especiais';
    } else if (factor > 1.3) {
      return 'Necessidades calóricas aumentadas - monitoramento regular recomendado';
    } else if (factor > 1.0) {
      return 'Leve aumento nas necessidades calóricas devido às condições';
    } else {
      return 'Sem ajustes necessários pelas condições selecionadas';
    }
  }

  void _updateEnvironmentalCondition(EnvironmentalCondition condition) {
    widget.onInputChanged(widget.input.copyWith(environmentalCondition: condition));
  }

  void _updateMedicalCondition(MedicalCondition condition) {
    widget.onInputChanged(widget.input.copyWith(medicalCondition: condition));
  }

  void _updateNotes(String? notes) {
    widget.onInputChanged(widget.input.copyWith(notes: notes));
  }
}
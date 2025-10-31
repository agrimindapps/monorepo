// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import '../../domain/entities/calorie_input.dart';

/// Widget para o segundo step: estado fisiológico do animal
class CaloriePhysiologicalStep extends StatefulWidget {
  const CaloriePhysiologicalStep({
    super.key,
    required this.input,
    required this.validationErrors,
    required this.onInputChanged,
  });

  final CalorieInput input;
  final List<String> validationErrors;
  final void Function(CalorieInput) onInputChanged;

  @override
  State<CaloriePhysiologicalStep> createState() => _CaloriePhysiologicalStepState();
}

class _CaloriePhysiologicalStepState extends State<CaloriePhysiologicalStep> {
  late TextEditingController _offspringController;

  @override
  void initState() {
    super.initState();
    _offspringController = TextEditingController(
      text: widget.input.numberOfOffspring?.toString() ?? '',
    );
  }

  @override
  void dispose() {
    _offspringController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Estado Fisiológico',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Informe o estado fisiológico atual do animal.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 24),

          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _buildPhysiologicalStateSelector(),
                  const SizedBox(height: 24),
                  if (widget.input.isLactating)
                    _buildOffspringField(),
                  _buildStateInfoCard(),
                ],
              ),
            ),
          ),
          if (widget.validationErrors.isNotEmpty)
            _buildValidationErrors(),
        ],
      ),
    );
  }

  Widget _buildPhysiologicalStateSelector() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Estado Fisiológico *',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            ...PhysiologicalState.values.map((state) {
              final isSelected = widget.input.physiologicalState == state;
              return Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: GestureDetector(
                  onTap: () => _updatePhysiologicalState(state),
                  child: Container(
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: isSelected 
                          ? Theme.of(context).primaryColor.withValues(alpha: 0.1)
                          : null,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected 
                            ? Theme.of(context).primaryColor
                            : Colors.grey[300]!,
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Radio<PhysiologicalState>(
                          value: state,
                          groupValue: widget.input.physiologicalState,
                          onChanged: (value) => _updatePhysiologicalState(value!),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                state.displayName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                'Fator: ${state.baseFactor}x',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                        _getStateIcon(state),
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

  Widget _buildOffspringField() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: TextFormField(
        controller: _offspringController,
        decoration: InputDecoration(
          labelText: 'Número de Filhotes *',
          hintText: 'Ex: 4',
          border: const OutlineInputBorder(),
          prefixIcon: const Icon(Icons.child_care),
          helperText: 'Quantos filhotes estão sendo amamentados',
          filled: true,
          fillColor: Colors.orange[50],
        ),
        keyboardType: TextInputType.number,
        onChanged: (value) {
          final offspring = int.tryParse(value);
          _updateNumberOfOffspring(offspring);
        },
      ),
    );
  }

  Widget _buildStateInfoCard() {
    final state = widget.input.physiologicalState;
    Color cardColor;
    String title;
    List<String> info;

    switch (state) {
      case PhysiologicalState.normal:
        cardColor = Colors.green[50]!;
        title = 'Animal Adulto Normal';
        info = [
          'Metabolismo estável',
          'Necessidades calóricas moderadas',
          'Manter peso ideal',
          'Exercícios regulares recomendados'
        ];
        break;
      case PhysiologicalState.neutered:
        cardColor = Colors.blue[50]!;
        title = 'Animal Castrado/Esterilizado';
        info = [
          'Metabolismo reduzido em ~10%',
          'Maior tendência ao ganho de peso',
          'Controlar porções cuidadosamente',
          'Exercícios essenciais'
        ];
        break;
      case PhysiologicalState.pregnancy1st:
      case PhysiologicalState.pregnancy2nd:
      case PhysiologicalState.pregnancy3rd:
        cardColor = Colors.pink[50]!;
        title = 'Gestação';
        info = [
          'Aumentar calorias gradualmente',
          'Ração de qualidade superior',
          'Monitoramento veterinário',
          'Suplementação pode ser necessária'
        ];
        break;
      case PhysiologicalState.lactating:
        cardColor = Colors.orange[50]!;
        title = 'Lactação';
        info = [
          'Necessidades calóricas muito altas',
          'Alimentação livre recomendada',
          'Água sempre disponível',
          'Ração de alta energia'
        ];
        break;
      case PhysiologicalState.growth:
      case PhysiologicalState.juvenile:
        cardColor = Colors.yellow[50]!;
        title = 'Crescimento';
        info = [
          'Necessidades calóricas elevadas',
          'Alimentação mais frequente',
          'Ração específica para filhotes',
          'Monitorar crescimento regularmente'
        ];
        break;
      case PhysiologicalState.senior:
        cardColor = Colors.purple[50]!;
        title = 'Animal Idoso';
        info = [
          'Metabolismo mais lento',
          'Dieta de fácil digestão',
          'Pode necessitar suplementação',
          'Exercícios moderados'
        ];
        break;
      case PhysiologicalState.working:
        cardColor = Colors.red[50]!;
        title = 'Animal de Trabalho';
        info = [
          'Necessidades calóricas muito altas',
          'Hidratação extra importante',
          'Alimentação pré/pós atividade',
          'Monitoramento constante'
        ];
        break;
    }

    return Card(
      color: cardColor,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _getStateIcon(state),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...info.map((item) => Padding(
              padding: const EdgeInsets.only(bottom: 4.0),
              child: Text('• $item'),
            )),
          ],
        ),
      ),
    );
  }

  Widget _getStateIcon(PhysiologicalState state) {
    IconData iconData;
    Color? color;

    switch (state) {
      case PhysiologicalState.normal:
        iconData = Icons.pets;
        color = Colors.green;
        break;
      case PhysiologicalState.neutered:
        iconData = Icons.healing;
        color = Colors.blue;
        break;
      case PhysiologicalState.pregnancy1st:
      case PhysiologicalState.pregnancy2nd:
      case PhysiologicalState.pregnancy3rd:
        iconData = Icons.pregnant_woman;
        color = Colors.pink;
        break;
      case PhysiologicalState.lactating:
        iconData = Icons.child_care;
        color = Colors.orange;
        break;
      case PhysiologicalState.growth:
      case PhysiologicalState.juvenile:
        iconData = Icons.child_friendly;
        color = Colors.yellow[700];
        break;
      case PhysiologicalState.senior:
        iconData = Icons.elderly;
        color = Colors.purple;
        break;
      case PhysiologicalState.working:
        iconData = Icons.fitness_center;
        color = Colors.red;
        break;
    }

    return Icon(iconData, color: color, size: 24);
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

  void _updatePhysiologicalState(PhysiologicalState state) {
    final offspring = state == PhysiologicalState.lactating 
        ? widget.input.numberOfOffspring 
        : null;
    
    widget.onInputChanged(widget.input.copyWith(
      physiologicalState: state,
      numberOfOffspring: offspring,
    ));
    if (state != PhysiologicalState.lactating) {
      _offspringController.clear();
    }
  }

  void _updateNumberOfOffspring(int? numberOfOffspring) {
    widget.onInputChanged(widget.input.copyWith(
      numberOfOffspring: numberOfOffspring,
    ));
  }
}

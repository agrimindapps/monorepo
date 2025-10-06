import 'package:flutter/material.dart';

/// Widget indicador de progresso para o formulário step-by-step
class CalorieStepIndicator extends StatelessWidget {
  const CalorieStepIndicator({
    super.key,
    required this.currentStep,
    required this.totalSteps,
    this.isComplete = false,
  });

  final int currentStep;
  final int totalSteps;
  final bool isComplete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Column(
      children: [
        Row(
          children: List.generate(totalSteps, (index) {
            final isActive = index <= currentStep;
            final isCurrent = index == currentStep;
            final isCompleted = index < currentStep || isComplete;
            
            return Expanded(
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isCompleted 
                          ? theme.primaryColor
                          : isCurrent
                              ? theme.primaryColor.withValues(alpha: 0.8)
                              : theme.disabledColor.withValues(alpha: 0.3),
                      border: Border.all(
                        color: isActive 
                            ? theme.primaryColor 
                            : theme.disabledColor,
                        width: 2,
                      ),
                    ),
                    child: Center(
                      child: isCompleted
                          ? const Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 18,
                            )
                          : Text(
                              '${index + 1}',
                              style: TextStyle(
                                color: isActive ? Colors.white : theme.disabledColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                    ),
                  ),
                  if (index < totalSteps - 1)
                    Expanded(
                      child: Container(
                        height: 2,
                        margin: const EdgeInsets.symmetric(horizontal: 8),
                        color: isCompleted
                            ? theme.primaryColor
                            : theme.disabledColor.withValues(alpha: 0.3),
                      ),
                    ),
                ],
              ),
            );
          }),
        ),
        
        const SizedBox(height: 12),
        Row(
          children: _buildStepLabels(theme),
        ),
        
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: isComplete ? 1.0 : (currentStep + 1) / totalSteps,
          backgroundColor: theme.disabledColor.withValues(alpha: 0.3),
          valueColor: AlwaysStoppedAnimation<Color>(theme.primaryColor),
        ),
        
        const SizedBox(height: 8),
        Text(
          isComplete 
              ? 'Cálculo concluído!'
              : 'Passo ${currentStep + 1} de $totalSteps',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.primaryColor,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  List<Widget> _buildStepLabels(ThemeData theme) {
    final labels = [
      'Info\nBásica',
      'Estado\nFisiol.',
      'Atividade\n& BCS',
      'Condições\nEspeciais',
      'Revisar\n& Calc.',
    ];
    
    return List.generate(totalSteps, (index) {
      final isActive = index <= currentStep;
      final isCurrent = index == currentStep;
      
      return Expanded(
        child: Text(
          labels[index],
          textAlign: TextAlign.center,
          style: theme.textTheme.bodySmall?.copyWith(
            color: isActive 
                ? theme.primaryColor 
                : theme.disabledColor,
            fontWeight: isCurrent 
                ? FontWeight.bold 
                : FontWeight.normal,
            fontSize: 10,
          ),
        ),
      );
    });
  }
}
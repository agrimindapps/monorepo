import 'package:flutter/material.dart';

import '../../../../core/presentation/theme/app_theme.dart';
import '../../core/constants/expense_constants.dart';
import '../../domain/entities/expense_entity.dart';

/// Widget para seleção do tipo de despesa com visual atrativo
class ExpenseTypeSelector extends StatelessWidget {
  final ExpenseType selectedType;
  final Function(ExpenseType) onTypeSelected;
  final String? error;

  const ExpenseTypeSelector({
    super.key,
    required this.selectedType,
    required this.onTypeSelected,
    this.error,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tipo de Despesa *',
          style: AppTheme.textStyles.labelLarge?.copyWith(
            color: AppTheme.colors.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 8),
        
        // Grid de tipos
        _buildTypeGrid(),
        
        // Erro
        if (error != null) ...[
          const SizedBox(height: 8),
          Text(
            error!,
            style: AppTheme.textStyles.labelSmall?.copyWith(
              color: AppTheme.colors.error,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildTypeGrid() {
    const types = ExpenseType.values;
    
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 3.5,
      ),
      itemCount: types.length,
      itemBuilder: (context, index) {
        final type = types[index];
        final isSelected = selectedType == type;
        final properties = type.properties;
        
        return InkWell(
          onTap: () => onTypeSelected(type),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected 
                  ? properties.colorValue.withValues(alpha: 0.2)
                  : AppTheme.colors.surface,
              border: Border.all(
                color: isSelected 
                    ? properties.colorValue
                    : AppTheme.colors.outline.withValues(alpha: 0.2),
                width: isSelected ? 2 : 1,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  properties.icon,
                  size: 20,
                  color: isSelected 
                      ? properties.colorValue
                      : AppTheme.colors.onSurfaceVariant,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        properties.displayName,
                        style: AppTheme.textStyles.labelMedium?.copyWith(
                          color: isSelected 
                              ? properties.colorValue
                              : AppTheme.colors.onSurface,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (properties.isRecurring) ...[
                        const SizedBox(height: 2),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                          decoration: BoxDecoration(
                            color: Colors.purple.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'Anual',
                            style: AppTheme.textStyles.labelSmall?.copyWith(
                              fontSize: 9,
                              color: Colors.purple,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Widget alternativo com dropdown para espaços menores
class ExpenseTypeDropdown extends StatelessWidget {
  final ExpenseType selectedType;
  final Function(ExpenseType?) onTypeSelected;
  final String? error;

  const ExpenseTypeDropdown({
    super.key,
    required this.selectedType,
    required this.onTypeSelected,
    this.error,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<ExpenseType>(
      value: selectedType,
      decoration: InputDecoration(
        labelText: 'Tipo de Despesa *',
        prefixIcon: Icon(selectedType.icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        errorText: error,
      ),
      items: ExpenseType.values.map((type) {
        final properties = type.properties;
        return DropdownMenuItem<ExpenseType>(
          value: type,
          child: Row(
            children: [
              Icon(
                properties.icon,
                size: 20,
                color: properties.colorValue,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(properties.displayName),
              ),
              if (properties.isRecurring)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.purple.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Anual',
                    style: AppTheme.textStyles.labelSmall?.copyWith(
                      fontSize: 10,
                      color: Colors.purple,
                    ),
                  ),
                ),
            ],
          ),
        );
      }).toList(),
      onChanged: onTypeSelected,
    );
  }
}

/// Widget para mostrar detalhes do tipo selecionado
class ExpenseTypeDetails extends StatelessWidget {
  final ExpenseType type;
  
  const ExpenseTypeDetails({
    super.key,
    required this.type,
  });

  @override
  Widget build(BuildContext context) {
    final properties = type.properties;
    
    return Card(
      color: properties.colorValue.withValues(alpha: 0.1),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  properties.icon,
                  color: properties.colorValue,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  properties.displayName,
                  style: AppTheme.textStyles.titleSmall?.copyWith(
                    color: properties.colorValue,
                  ),
                ),
                const Spacer(),
                if (properties.isRecurring)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.purple.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Recorrente',
                      style: AppTheme.textStyles.labelSmall?.copyWith(
                        color: Colors.purple,
                      ),
                    ),
                  ),
              ],
            ),
            
            const SizedBox(height: 8),
            
            Text(
              properties.description,
              style: AppTheme.textStyles.bodySmall?.copyWith(
                color: AppTheme.colors.onSurfaceVariant,
              ),
            ),
            
            if (properties.minExpectedValue != null ||
                properties.maxExpectedValue != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 16,
                    color: AppTheme.colors.onSurfaceVariant,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _buildValueRangeText(properties),
                    style: AppTheme.textStyles.labelSmall?.copyWith(
                      color: AppTheme.colors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _buildValueRangeText(ExpenseTypeProperties properties) {
    if (properties.minExpectedValue != null && properties.maxExpectedValue != null) {
      return 'Faixa esperada: R\$ ${properties.minExpectedValue!.toStringAsFixed(0)} - R\$ ${properties.maxExpectedValue!.toStringAsFixed(0)}';
    } else if (properties.minExpectedValue != null) {
      return 'Valor mínimo esperado: R\$ ${properties.minExpectedValue!.toStringAsFixed(0)}';
    } else if (properties.maxExpectedValue != null) {
      return 'Valor máximo esperado: R\$ ${properties.maxExpectedValue!.toStringAsFixed(0)}';
    }
    return '';
  }
}
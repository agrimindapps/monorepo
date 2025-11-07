import 'package:flutter/material.dart';

import '../../../../core/theme/design_tokens.dart';
import '../../../../core/widgets/validated_dropdown_field.dart';
import '../../domain/entities/expense_entity.dart';

/// Widget para seleção do tipo de despesa como dropdown
class ExpenseTypeSelector extends StatelessWidget {
  const ExpenseTypeSelector({
    super.key,
    required this.selectedType,
    required this.onTypeSelected,
    this.error,
  });
  final ExpenseType selectedType;
  final void Function(ExpenseType) onTypeSelected;
  final String? error;

  @override
  Widget build(BuildContext context) {
    return ValidatedDropdownField<ExpenseType>(
      items:
          ExpenseType.values.map((type) {
            return ValidatedDropdownItem<ExpenseType>(
              value: type,
              child: Row(
                children: [
                  Icon(
                    type.icon,
                    size: 20,
                    color: GasometerDesignTokens.colorPrimary,
                  ),
                  const SizedBox(width: GasometerDesignTokens.spacingSm),
                  Text(type.displayName),
                ],
              ),
            );
          }).toList(),
      value: selectedType,
      label: 'Tipo de Despesa *',
      hint: 'Selecione o tipo de despesa',
      prefixIcon: selectedType.icon,
      required: true,
      onChanged: (ExpenseType? type) {
        if (type != null) {
          onTypeSelected(type);
        }
      },
      validator: (value) {
        if (value == null) {
          return 'Selecione um tipo de despesa';
        }
        return error;
      },
    );
  }
}

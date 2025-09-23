import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// **Type Dropdown Field Component**
///
/// Componente reutilizável para dropdowns de tipos/categorias com ícones e cores.
/// Ideal para seleções como tipo de medicamento, prioridade, categoria, etc.
///
/// **Funcionalidades:**
/// - Interface visual com ícones e cores
/// - Suporte a tipos genéricos
/// - Validação integrada
/// - Estados de disabled e loading
/// - Mapeamento automático de display
/// - Configuração flexível
///
/// **Uso:**
/// ```dart
/// TypeDropdownField<MedicationType>(
///   value: selectedType,
///   items: MedicationType.values,
///   onChanged: (type) => setState(() => selectedType = type),
///   label: 'Tipo de Medicamento',
///   getDisplayName: (type) => type.displayName,
///   getIcon: (type) => type.icon,
/// )
/// ```
class TypeDropdownField<T> extends StatelessWidget {
  /// Valor atualmente selecionado
  final T? value;

  /// Lista de itens disponíveis
  final List<T> items;

  /// Callback para mudança de valor
  final ValueChanged<T?>? onChanged;

  /// Função para obter o nome de exibição
  final String Function(T) getDisplayName;

  /// Função para obter o ícone (opcional)
  final IconData? Function(T)? getIcon;

  /// Função para obter a cor (opcional)
  final Color? Function(T)? getColor;

  /// Label do campo
  final String? label;

  /// Texto de hint
  final String? hint;

  /// Função de validação
  final String? Function(T?)? validator;

  /// Se o campo está habilitado
  final bool enabled;

  /// Se é obrigatório
  final bool isRequired;

  /// Ícone padrão se não especificado
  final IconData? defaultIcon;

  /// Texto de ajuda
  final String? helperText;

  const TypeDropdownField({
    super.key,
    required this.value,
    required this.items,
    required this.onChanged,
    required this.getDisplayName,
    this.getIcon,
    this.getColor,
    this.label,
    this.hint,
    this.validator,
    this.enabled = true,
    this.isRequired = false,
    this.defaultIcon,
    this.helperText,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label com indicador obrigatório
        if (label != null) ...[
          Row(
            children: [
              Text(
                label!,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
              ),
              if (isRequired) ...[
                const SizedBox(width: 4),
                const Text(
                  '*',
                  style: TextStyle(
                    color: AppColors.error,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 8),
        ],

        // Dropdown
        DropdownButtonFormField<T>(
          value: value,
          onChanged: enabled ? onChanged : null,
          validator: _buildValidator(),
          decoration: InputDecoration(
            hintText: hint ?? 'Selecione ${label?.toLowerCase() ?? 'uma opção'}',
            helperText: helperText,
            prefixIcon: Icon(
              _getPrefixIcon(),
              color: enabled ? AppColors.primary : AppColors.textSecondary,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.error),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: AppColors.border.withValues(alpha: 0.5)),
            ),
            helperStyle: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
          items: items.map((item) {
            return DropdownMenuItem<T>(
              value: item,
              child: _buildDropdownItem(item),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildDropdownItem(T item) {
    final icon = getIcon?.call(item);
    final color = getColor?.call(item);
    final displayName = getDisplayName(item);

    return Row(
      children: [
        // Ícone ou indicador de cor
        if (icon != null) ...[
          Icon(
            icon,
            size: 20,
            color: color ?? AppColors.primary,
          ),
          const SizedBox(width: 12),
        ] else if (color != null) ...[
          Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
        ],

        // Nome
        Expanded(
          child: Text(
            displayName,
            style: const TextStyle(fontSize: 14),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  IconData _getPrefixIcon() {
    if (value != null) {
      final icon = getIcon?.call(value!);
      if (icon != null) return icon;
    }
    return defaultIcon ?? Icons.category;
  }

  String? Function(T?)? _buildValidator() {
    if (validator != null) return validator;

    if (isRequired) {
      return (value) {
        if (value == null) {
          return '${label ?? 'Este campo'} é obrigatório';
        }
        return null;
      };
    }

    return null;
  }
}

/// **Implementações específicas para entidades do PetiVeti**

// Assumindo que estas enums existem - podem ser adaptadas conforme necessário

/// Dropdown para prioridades
class PriorityDropdownField extends StatelessWidget {
  final String? value;
  final ValueChanged<String?>? onChanged;
  final String? label;
  final bool isRequired;
  final bool enabled;

  const PriorityDropdownField({
    super.key,
    required this.value,
    required this.onChanged,
    this.label,
    this.isRequired = false,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    // Lista simulada de prioridades - ajustar conforme enum real
    final priorities = ['low', 'medium', 'high', 'urgent'];

    return TypeDropdownField<String>(
      value: value,
      items: priorities,
      onChanged: onChanged,
      label: label ?? 'Prioridade',
      isRequired: isRequired,
      enabled: enabled,
      getDisplayName: _getPriorityDisplayName,
      getColor: _getPriorityColor,
      getIcon: _getPriorityIcon,
    );
  }

  String _getPriorityDisplayName(String priority) {
    switch (priority) {
      case 'low':
        return 'Baixa';
      case 'medium':
        return 'Média';
      case 'high':
        return 'Alta';
      case 'urgent':
        return 'Urgente';
      default:
        return priority;
    }
  }

  Color _getPriorityColor(String priority) {
    switch (priority) {
      case 'low':
        return Colors.green;
      case 'medium':
        return Colors.orange;
      case 'high':
        return Colors.red;
      case 'urgent':
        return Colors.purple;
      default:
        return AppColors.textSecondary;
    }
  }

  IconData _getPriorityIcon(String priority) {
    switch (priority) {
      case 'low':
        return Icons.keyboard_arrow_down;
      case 'medium':
        return Icons.remove;
      case 'high':
        return Icons.keyboard_arrow_up;
      case 'urgent':
        return Icons.priority_high;
      default:
        return Icons.help;
    }
  }
}

/// Dropdown para tipos de lembrete
class ReminderTypeDropdownField extends StatelessWidget {
  final String? value;
  final ValueChanged<String?>? onChanged;
  final String? label;
  final bool isRequired;
  final bool enabled;

  const ReminderTypeDropdownField({
    super.key,
    required this.value,
    required this.onChanged,
    this.label,
    this.isRequired = false,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    // Lista simulada de tipos - ajustar conforme enum real
    final types = ['vaccine', 'medication', 'appointment', 'weight', 'general'];

    return TypeDropdownField<String>(
      value: value,
      items: types,
      onChanged: onChanged,
      label: label ?? 'Tipo de Lembrete',
      isRequired: isRequired,
      enabled: enabled,
      getDisplayName: _getTypeDisplayName,
      getIcon: _getTypeIcon,
    );
  }

  String _getTypeDisplayName(String type) {
    switch (type) {
      case 'vaccine':
        return 'Vacina';
      case 'medication':
        return 'Medicamento';
      case 'appointment':
        return 'Consulta';
      case 'weight':
        return 'Pesagem';
      case 'general':
        return 'Geral';
      default:
        return type;
    }
  }

  IconData _getTypeIcon(String type) {
    switch (type) {
      case 'vaccine':
        return Icons.vaccines;
      case 'medication':
        return Icons.medication;
      case 'appointment':
        return Icons.event;
      case 'weight':
        return Icons.monitor_weight;
      case 'general':
        return Icons.notification_important;
      default:
        return Icons.help;
    }
  }
}

/// Dropdown para tipos de medicamento
class MedicationTypeDropdownField extends StatelessWidget {
  final String? value;
  final ValueChanged<String?>? onChanged;
  final String? label;
  final bool isRequired;
  final bool enabled;

  const MedicationTypeDropdownField({
    super.key,
    required this.value,
    required this.onChanged,
    this.label,
    this.isRequired = false,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    // Lista simulada de tipos - ajustar conforme enum real
    final types = ['antibiotic', 'vitamin', 'antiparasitic', 'painkiller', 'other'];

    return TypeDropdownField<String>(
      value: value,
      items: types,
      onChanged: onChanged,
      label: label ?? 'Tipo de Medicamento',
      isRequired: isRequired,
      enabled: enabled,
      getDisplayName: _getTypeDisplayName,
      getIcon: _getTypeIcon,
      getColor: _getTypeColor,
    );
  }

  String _getTypeDisplayName(String type) {
    switch (type) {
      case 'antibiotic':
        return 'Antibiótico';
      case 'vitamin':
        return 'Vitamina';
      case 'antiparasitic':
        return 'Antiparasitário';
      case 'painkiller':
        return 'Analgésico';
      case 'other':
        return 'Outro';
      default:
        return type;
    }
  }

  IconData _getTypeIcon(String type) {
    switch (type) {
      case 'antibiotic':
        return Icons.biotech;
      case 'vitamin':
        return Icons.eco;
      case 'antiparasitic':
        return Icons.bug_report;
      case 'painkiller':
        return Icons.healing;
      case 'other':
        return Icons.medication;
      default:
        return Icons.help;
    }
  }

  Color _getTypeColor(String type) {
    switch (type) {
      case 'antibiotic':
        return Colors.blue;
      case 'vitamin':
        return Colors.green;
      case 'antiparasitic':
        return Colors.orange;
      case 'painkiller':
        return Colors.red;
      case 'other':
        return Colors.grey;
      default:
        return AppColors.textSecondary;
    }
  }
}
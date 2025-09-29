import 'package:flutter/material.dart';
import 'package:provider/provider.dart' as provider_lib;
import 'package:core/core.dart';

import '../providers/diagnosticos_praga_provider.dart';

/// Widget responsável pelos filtros de diagnósticos
/// 
/// Responsabilidade única: renderizar e gerenciar filtros de pesquisa e cultura
/// - Campo de busca por texto
/// - Dropdown de seleção de cultura
/// - Layout responsivo e design consistente
class DiagnosticoFilterWidget extends StatelessWidget {
  const DiagnosticoFilterWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: provider_lib.Consumer<DiagnosticosPragaProvider>(
        builder: (context, provider, child) {
          return Container(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  flex: 1,
                  child: _SearchField(
                    onChanged: provider.updateSearchQuery,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 1,
                  child: _CultureDropdown(
                    value: provider.selectedCultura,
                    cultures: provider.culturas,
                    onChanged: provider.updateSelectedCultura,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// Campo de busca personalizado
class _SearchField extends StatelessWidget {
  final ValueChanged<String> onChanged;

  const _SearchField({required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.3),
        ),
      ),
      child: TextField(
        onChanged: onChanged,
        decoration: const InputDecoration(
          hintText: 'Pesquisar diagnósticos...',
          border: InputBorder.none,
          prefixIcon: Icon(Icons.search),
        ),
      ),
    );
  }
}

/// Dropdown de seleção de cultura
class _CultureDropdown extends StatelessWidget {
  final String value;
  final List<String> cultures;
  final ValueChanged<String> onChanged;

  const _CultureDropdown({
    required this.value,
    required this.cultures,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.3),
        ),
      ),
      child: DropdownButton<String>(
        value: value,
        onChanged: (String? newValue) {
          if (newValue != null) {
            onChanged(newValue);
          }
        },
        isExpanded: true,
        underline: const SizedBox(),
        icon: Icon(
          Icons.keyboard_arrow_down,
          color: theme.colorScheme.onSurfaceVariant,
        ),
        items: cultures.map<DropdownMenuItem<String>>((String culture) {
          return DropdownMenuItem<String>(
            value: culture,
            child: Text(
              culture,
              style: TextStyle(
                fontSize: 16,
                color: theme.colorScheme.onSurface,
                fontWeight: FontWeight.w500,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
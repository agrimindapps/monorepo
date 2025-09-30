import 'package:flutter/material.dart';

import '../../../../core/widgets/design_system_components.dart';
import '../../domain/entities/calculator_category.dart';
import '../../domain/entities/calculator_entity.dart';
import '../../domain/services/calculator_search_service.dart' as search_service;

/// Widget para filtros avançados de busca
/// 
/// Implementa filtros expandíveis com chips e dropdowns
/// Centralizando lógica de filtros em um componente reutilizável
class CalculatorSearchFiltersWidget extends StatefulWidget {
  final CalculatorCategory? selectedCategory;
  final CalculatorComplexity? selectedComplexity;
  final List<String> selectedTags;
  final search_service.CalculatorSortOrder sortOrder;
  final bool showOnlyFavorites;
  final List<String> availableTags;
  final void Function(CalculatorCategory?) onCategoryChanged;
  final void Function(CalculatorComplexity?) onComplexityChanged;
  final void Function(List<String>) onTagsChanged;
  final void Function(search_service.CalculatorSortOrder) onSortOrderChanged;
  final void Function(bool) onFavoritesFilterChanged;
  final VoidCallback onClearFilters;
  final VoidCallback onApplyFilters;

  const CalculatorSearchFiltersWidget({
    super.key,
    this.selectedCategory,
    this.selectedComplexity,
    required this.selectedTags,
    required this.sortOrder,
    required this.showOnlyFavorites,
    required this.availableTags,
    required this.onCategoryChanged,
    required this.onComplexityChanged,
    required this.onTagsChanged,
    required this.onSortOrderChanged,
    required this.onFavoritesFilterChanged,
    required this.onClearFilters,
    required this.onApplyFilters,
  });

  @override
  State<CalculatorSearchFiltersWidget> createState() => _CalculatorSearchFiltersWidgetState();
}

class _CalculatorSearchFiltersWidgetState extends State<CalculatorSearchFiltersWidget> {
  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      title: const Text('Filtros Avançados'),
      leading: const Icon(Icons.filter_list),
      initiallyExpanded: false,
      shape: const Border(),
      tilePadding: const EdgeInsets.symmetric(horizontal: 16),
      childrenPadding: const EdgeInsets.all(16),
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Categoria
            _buildCategoryFilter(),
            const SizedBox(height: 16),
            
            // Complexidade
            _buildComplexityFilter(),
            const SizedBox(height: 16),
            
            // Tags
            _buildTagsFilter(),
            const SizedBox(height: 16),
            
            // Ordenação
            _buildSortOrderFilter(),
            const SizedBox(height: 16),
            
            // Favoritos
            _buildFavoritesFilter(),
            const SizedBox(height: 16),
            
            // Botões de ação
            _buildActionButtons(),
          ],
        ),
      ],
    );
  }

  Widget _buildCategoryFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Categoria',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            FilterChip(
              label: const Text('Todas'),
              selected: widget.selectedCategory == null,
              onSelected: (selected) {
                widget.onCategoryChanged(selected ? null : widget.selectedCategory);
              },
            ),
            ...CalculatorCategory.values.map((category) {
              return FilterChip(
                label: Text(category.displayName),
                selected: widget.selectedCategory == category,
                onSelected: (selected) {
                  widget.onCategoryChanged(selected ? category : null);
                },
              );
            }),
          ],
        ),
      ],
    );
  }

  Widget _buildComplexityFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Complexidade',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            FilterChip(
              label: const Text('Todas'),
              selected: widget.selectedComplexity == null,
              onSelected: (selected) {
                widget.onComplexityChanged(selected ? null : widget.selectedComplexity);
              },
            ),
            ...CalculatorComplexity.values.map((complexity) {
              return FilterChip(
                label: Text(_getComplexityName(complexity)),
                selected: widget.selectedComplexity == complexity,
                onSelected: (selected) {
                  widget.onComplexityChanged(selected ? complexity : null);
                },
              );
            }),
          ],
        ),
      ],
    );
  }

  Widget _buildTagsFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tags',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        if (widget.availableTags.isEmpty)
          Text(
            'Nenhuma tag disponível',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          )
        else
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: widget.availableTags.map((tag) {
              final isSelected = widget.selectedTags.contains(tag);
              return FilterChip(
                label: Text(tag),
                selected: isSelected,
                onSelected: (selected) {
                  final newTags = List<String>.from(widget.selectedTags);
                  if (selected) {
                    newTags.add(tag);
                  } else {
                    newTags.remove(tag);
                  }
                  widget.onTagsChanged(newTags);
                },
              );
            }).toList(),
          ),
      ],
    );
  }

  Widget _buildSortOrderFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Ordenação',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<search_service.CalculatorSortOrder>(
          value: widget.sortOrder,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            filled: true,
            fillColor: Theme.of(context).colorScheme.surface,
          ),
          items: search_service.CalculatorSortOrder.values.map((order) {
            return DropdownMenuItem(
              value: order,
              child: Text(_getSortOrderName(order)),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null) {
              widget.onSortOrderChanged(value);
            }
          },
        ),
      ],
    );
  }

  Widget _buildFavoritesFilter() {
    return Row(
      children: [
        Checkbox(
          value: widget.showOnlyFavorites,
          onChanged: (value) {
            widget.onFavoritesFilterChanged(value ?? false);
          },
        ),
        const SizedBox(width: 8),
        Text(
          'Mostrar apenas favoritas',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        DSSecondaryButton(
          text: 'Limpar Filtros',
          onPressed: widget.onClearFilters,
          width: 140,
        ),
        DSPrimaryButton(
          text: 'Aplicar Filtros',
          onPressed: widget.onApplyFilters,
          width: 140,
        ),
      ],
    );
  }

  String _getComplexityName(CalculatorComplexity complexity) {
    switch (complexity) {
      case CalculatorComplexity.low:
        return 'Simples';
      case CalculatorComplexity.medium:
        return 'Intermediária';
      case CalculatorComplexity.high:
        return 'Avançada';
    }
  }

  String _getSortOrderName(search_service.CalculatorSortOrder order) {
    switch (order) {
      case search_service.CalculatorSortOrder.nameAsc:
        return 'Nome (A-Z)';
      case search_service.CalculatorSortOrder.nameDesc:
        return 'Nome (Z-A)';
      case search_service.CalculatorSortOrder.categoryAsc:
        return 'Categoria';
      case search_service.CalculatorSortOrder.complexityAsc:
        return 'Complexidade (Crescente)';
      case search_service.CalculatorSortOrder.complexityDesc:
        return 'Complexidade (Decrescente)';
    }
  }
}
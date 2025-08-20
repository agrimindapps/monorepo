// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../../../../core/style/shadcn_style.dart';
import '../models/filter_models.dart';

/// Widget para barra de busca
class SearchBar extends StatefulWidget {
  final String? initialQuery;
  final void Function(String) onQueryChanged;
  final String hintText;
  final bool enabled;

  const SearchBar({
    super.key,
    this.initialQuery,
    required this.onQueryChanged,
    this.hintText = 'Buscar pluviômetros...',
    this.enabled = true,
  });

  @override
  State<SearchBar> createState() => _SearchBarState();
}

class _SearchBarState extends State<SearchBar> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialQuery);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          Icon(
            Icons.search,
            color: Colors.grey.shade600,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: _controller,
              enabled: widget.enabled,
              decoration: InputDecoration(
                hintText: widget.hintText,
                border: InputBorder.none,
                hintStyle: TextStyle(color: Colors.grey.shade500),
              ),
              onChanged: widget.onQueryChanged,
            ),
          ),
          if (_controller.text.isNotEmpty)
            IconButton(
              icon: Icon(Icons.clear, color: Colors.grey.shade600),
              onPressed: () {
                _controller.clear();
                widget.onQueryChanged('');
              },
            ),
        ],
      ),
    );
  }
}

/// Widget para filtros ativos (chips)
class ActiveFiltersChips extends StatelessWidget {
  final FilterSet filterSet;
  final void Function(FilterCriteria) onRemoveFilter;
  final VoidCallback onClearAll;

  const ActiveFiltersChips({
    super.key,
    required this.filterSet,
    required this.onRemoveFilter,
    required this.onClearAll,
  });

  @override
  Widget build(BuildContext context) {
    if (!filterSet.hasActiveFilters) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Filtros Ativos (${filterSet.activeFilterCount})',
                style: ShadcnStyle.subtitleStyle,
              ),
              TextButton(
                onPressed: onClearAll,
                child: const Text('Limpar Todos'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: [
              // Chip para busca
              if (filterSet.searchQuery != null &&
                  filterSet.searchQuery!.isNotEmpty)
                _SearchChip(
                  query: filterSet.searchQuery!,
                  onRemove: () => onRemoveFilter(const FilterCriteria(
                    type: FilterType.descricao,
                    operator: FilterOperator.contains,
                    value: '',
                  )),
                ),
              // Chips para filtros
              ...filterSet.filters.where((f) => f.isActive).map(
                    (filter) => _FilterChip(
                      filter: filter,
                      onRemove: () => onRemoveFilter(filter),
                    ),
                  ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Chip para busca
class _SearchChip extends StatelessWidget {
  final String query;
  final VoidCallback onRemove;

  const _SearchChip({
    required this.query,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: const Icon(Icons.search, size: 16),
      label: Text('Busca: "$query"'),
      backgroundColor: Colors.blue.shade50,
      side: BorderSide(color: Colors.blue.shade200),
      deleteIcon: const Icon(Icons.close, size: 16),
      onDeleted: onRemove,
    );
  }
}

/// Chip para filtro
class _FilterChip extends StatelessWidget {
  final FilterCriteria filter;
  final VoidCallback onRemove;

  const _FilterChip({
    required this.filter,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: _getFilterIcon(),
      label: Text(filter.toDisplayString()),
      backgroundColor: Colors.green.shade50,
      side: BorderSide(color: Colors.green.shade200),
      deleteIcon: const Icon(Icons.close, size: 16),
      onDeleted: onRemove,
    );
  }

  Widget _getFilterIcon() {
    switch (filter.type) {
      case FilterType.descricao:
        return const Icon(Icons.description, size: 16);
      case FilterType.quantidade:
        return const Icon(Icons.water_drop, size: 16);
      case FilterType.dataCreated:
        return const Icon(Icons.calendar_today, size: 16);
      case FilterType.grupo:
        return const Icon(Icons.group, size: 16);
      case FilterType.coordenadas:
        return const Icon(Icons.location_on, size: 16);
    }
  }
}

/// Widget para adicionar novos filtros
class AddFilterWidget extends StatefulWidget {
  final void Function(FilterCriteria) onAddFilter;

  const AddFilterWidget({
    super.key,
    required this.onAddFilter,
  });

  @override
  State<AddFilterWidget> createState() => _AddFilterWidgetState();
}

class _AddFilterWidgetState extends State<AddFilterWidget> {
  FilterType _selectedType = FilterType.descricao;
  FilterOperator _selectedOperator = FilterOperator.contains;
  final TextEditingController _valueController = TextEditingController();
  final TextEditingController _secondValueController = TextEditingController();
  DateTime? _selectedDate;
  DateTime? _secondSelectedDate;

  @override
  void dispose() {
    _valueController.dispose();
    _secondValueController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Adicionar Filtro',
            style: ShadcnStyle.subtitleStyle,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: _buildTypeDropdown(),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: _buildOperatorDropdown(),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 3,
                child: _buildValueInput(),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: _clearForm,
                child: const Text('Limpar'),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: _canAddFilter() ? _addFilter : null,
                child: const Text('Adicionar'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTypeDropdown() {
    return DropdownButtonFormField<FilterType>(
      value: _selectedType,
      decoration: const InputDecoration(
        labelText: 'Campo',
        border: OutlineInputBorder(),
      ),
      items: FilterType.values.map((type) {
        return DropdownMenuItem(
          value: type,
          child: Text(_getTypeDisplayName(type)),
        );
      }).toList(),
      onChanged: (value) {
        if (value != null) {
          setState(() {
            _selectedType = value;
            _selectedOperator = _getDefaultOperator(value);
            _clearValues();
          });
        }
      },
    );
  }

  Widget _buildOperatorDropdown() {
    final availableOperators = _getAvailableOperators(_selectedType);

    return DropdownButtonFormField<FilterOperator>(
      value: _selectedOperator,
      decoration: const InputDecoration(
        labelText: 'Operador',
        border: OutlineInputBorder(),
      ),
      items: availableOperators.map((operator) {
        return DropdownMenuItem(
          value: operator,
          child: Text(_getOperatorDisplayName(operator)),
        );
      }).toList(),
      onChanged: (value) {
        if (value != null) {
          setState(() {
            _selectedOperator = value;
            _clearValues();
          });
        }
      },
    );
  }

  Widget _buildValueInput() {
    if (_selectedOperator == FilterOperator.isEmpty ||
        _selectedOperator == FilterOperator.isNotEmpty) {
      return const SizedBox.shrink();
    }

    if (_selectedType == FilterType.dataCreated) {
      return _buildDateInput();
    }

    return Column(
      children: [
        TextField(
          controller: _valueController,
          decoration: InputDecoration(
            labelText: 'Valor',
            border: const OutlineInputBorder(),
            suffixText: _getValueSuffix(),
          ),
          keyboardType: _selectedType == FilterType.quantidade
              ? TextInputType.number
              : TextInputType.text,
        ),
        if (_selectedOperator == FilterOperator.between) ...[
          const SizedBox(height: 8),
          TextField(
            controller: _secondValueController,
            decoration: InputDecoration(
              labelText: 'Valor Final',
              border: const OutlineInputBorder(),
              suffixText: _getValueSuffix(),
            ),
            keyboardType: _selectedType == FilterType.quantidade
                ? TextInputType.number
                : TextInputType.text,
          ),
        ],
      ],
    );
  }

  Widget _buildDateInput() {
    return Column(
      children: [
        InkWell(
          onTap: () => _selectDate(context, true),
          child: InputDecorator(
            decoration: const InputDecoration(
              labelText: 'Data',
              border: OutlineInputBorder(),
            ),
            child: Text(
              _selectedDate != null
                  ? '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'
                  : 'Selecionar data',
            ),
          ),
        ),
        if (_selectedOperator == FilterOperator.between) ...[
          const SizedBox(height: 8),
          InkWell(
            onTap: () => _selectDate(context, false),
            child: InputDecorator(
              decoration: const InputDecoration(
                labelText: 'Data Final',
                border: OutlineInputBorder(),
              ),
              child: Text(
                _secondSelectedDate != null
                    ? '${_secondSelectedDate!.day}/${_secondSelectedDate!.month}/${_secondSelectedDate!.year}'
                    : 'Selecionar data final',
              ),
            ),
          ),
        ],
      ],
    );
  }

  Future<void> _selectDate(BuildContext context, bool isFirstDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        if (isFirstDate) {
          _selectedDate = picked;
        } else {
          _secondSelectedDate = picked;
        }
      });
    }
  }

  List<FilterOperator> _getAvailableOperators(FilterType type) {
    switch (type) {
      case FilterType.descricao:
      case FilterType.grupo:
        return [
          FilterOperator.contains,
          FilterOperator.equals,
          FilterOperator.startsWith,
          FilterOperator.endsWith,
          FilterOperator.isEmpty,
          FilterOperator.isNotEmpty,
        ];
      case FilterType.quantidade:
        return [
          FilterOperator.equals,
          FilterOperator.greaterThan,
          FilterOperator.lessThan,
          FilterOperator.between,
        ];
      case FilterType.dataCreated:
        return [
          FilterOperator.equals,
          FilterOperator.greaterThan,
          FilterOperator.lessThan,
          FilterOperator.between,
        ];
      case FilterType.coordenadas:
        return [
          FilterOperator.isEmpty,
          FilterOperator.isNotEmpty,
        ];
    }
  }

  FilterOperator _getDefaultOperator(FilterType type) {
    switch (type) {
      case FilterType.descricao:
      case FilterType.grupo:
        return FilterOperator.contains;
      case FilterType.quantidade:
      case FilterType.dataCreated:
        return FilterOperator.equals;
      case FilterType.coordenadas:
        return FilterOperator.isNotEmpty;
    }
  }

  String _getTypeDisplayName(FilterType type) {
    switch (type) {
      case FilterType.descricao:
        return 'Descrição';
      case FilterType.quantidade:
        return 'Quantidade';
      case FilterType.dataCreated:
        return 'Data de Criação';
      case FilterType.grupo:
        return 'Grupo';
      case FilterType.coordenadas:
        return 'Coordenadas';
    }
  }

  String _getOperatorDisplayName(FilterOperator operator) {
    switch (operator) {
      case FilterOperator.equals:
        return 'Igual a';
      case FilterOperator.contains:
        return 'Contém';
      case FilterOperator.startsWith:
        return 'Inicia com';
      case FilterOperator.endsWith:
        return 'Termina com';
      case FilterOperator.greaterThan:
        return 'Maior que';
      case FilterOperator.lessThan:
        return 'Menor que';
      case FilterOperator.between:
        return 'Entre';
      case FilterOperator.isEmpty:
        return 'Está vazio';
      case FilterOperator.isNotEmpty:
        return 'Não está vazio';
    }
  }

  String? _getValueSuffix() {
    if (_selectedType == FilterType.quantidade) {
      return 'mm';
    }
    return null;
  }

  bool _canAddFilter() {
    if (_selectedOperator == FilterOperator.isEmpty ||
        _selectedOperator == FilterOperator.isNotEmpty) {
      return true;
    }

    if (_selectedType == FilterType.dataCreated) {
      if (_selectedOperator == FilterOperator.between) {
        return _selectedDate != null && _secondSelectedDate != null;
      }
      return _selectedDate != null;
    }

    if (_selectedOperator == FilterOperator.between) {
      return _valueController.text.isNotEmpty &&
          _secondValueController.text.isNotEmpty;
    }

    return _valueController.text.isNotEmpty;
  }

  void _addFilter() {
    if (!_canAddFilter()) return;

    dynamic value;
    dynamic secondValue;

    if (_selectedOperator == FilterOperator.isEmpty ||
        _selectedOperator == FilterOperator.isNotEmpty) {
      value = null;
    } else if (_selectedType == FilterType.dataCreated) {
      value = _selectedDate;
      secondValue = _secondSelectedDate;
    } else {
      value = _valueController.text;
      if (_selectedOperator == FilterOperator.between) {
        secondValue = _secondValueController.text;
      }
    }

    final filter = FilterCriteria(
      type: _selectedType,
      operator: _selectedOperator,
      value: value,
      secondValue: secondValue,
    );

    widget.onAddFilter(filter);
    _clearForm();
  }

  void _clearForm() {
    setState(() {
      _valueController.clear();
      _secondValueController.clear();
      _selectedDate = null;
      _secondSelectedDate = null;
    });
  }

  void _clearValues() {
    _valueController.clear();
    _secondValueController.clear();
    _selectedDate = null;
    _secondSelectedDate = null;
  }
}

/// Widget para filtros rápidos/presets
class QuickFiltersWidget extends StatelessWidget {
  final void Function(FilterCriteria) onApplyFilter;

  const QuickFiltersWidget({
    super.key,
    required this.onApplyFilter,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Filtros Rápidos',
            style: ShadcnStyle.subtitleStyle,
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _QuickFilterChip(
                label: 'Quantidade Alta (>50mm)',
                icon: Icons.trending_up,
                onTap: () => onApplyFilter(PresetFilters.quantidadeAlta),
              ),
              _QuickFilterChip(
                label: 'Quantidade Baixa (<10mm)',
                icon: Icons.trending_down,
                onTap: () => onApplyFilter(PresetFilters.quantidadeBaixa),
              ),
              _QuickFilterChip(
                label: 'Sem Coordenadas',
                icon: Icons.location_off,
                onTap: () => onApplyFilter(PresetFilters.semCoordenadas),
              ),
              _QuickFilterChip(
                label: 'Com Coordenadas',
                icon: Icons.location_on,
                onTap: () => onApplyFilter(PresetFilters.comCoordenadas),
              ),
              _QuickFilterChip(
                label: 'Criados Recentemente',
                icon: Icons.new_releases,
                onTap: () => onApplyFilter(PresetFilters.criadosRecentemente()),
              ),
              _QuickFilterChip(
                label: 'Última Semana',
                icon: Icons.date_range,
                onTap: () => onApplyFilter(PresetFilters.criadosUltimaSemana()),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Chip para filtro rápido
class _QuickFilterChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _QuickFilterChip({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      avatar: Icon(icon, size: 16),
      label: Text(label),
      onPressed: onTap,
      backgroundColor: Colors.blue.shade50,
      side: BorderSide(color: Colors.blue.shade200),
    );
  }
}

/// Widget para ordenação
class SortWidget extends StatelessWidget {
  final SortConfiguration currentSort;
  final void Function(SortConfiguration) onSortChanged;

  const SortWidget({
    super.key,
    required this.currentSort,
    required this.onSortChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Text(
            'Ordenar por:',
            style: ShadcnStyle.subtitleStyle,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: DropdownButton<SortType>(
              value: currentSort.type,
              isExpanded: true,
              items: SortType.values.map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Text(_getSortTypeDisplayName(type)),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  onSortChanged(currentSort.copyWith(type: value));
                }
              },
            ),
          ),
          const SizedBox(width: 12),
          IconButton(
            onPressed: () {
              final newDirection =
                  currentSort.direction == SortDirection.ascending
                      ? SortDirection.descending
                      : SortDirection.ascending;
              onSortChanged(currentSort.copyWith(direction: newDirection));
            },
            icon: Icon(
              currentSort.direction == SortDirection.ascending
                  ? Icons.arrow_upward
                  : Icons.arrow_downward,
            ),
            tooltip: currentSort.direction == SortDirection.ascending
                ? 'Crescente'
                : 'Decrescente',
          ),
        ],
      ),
    );
  }

  String _getSortTypeDisplayName(SortType type) {
    switch (type) {
      case SortType.descricao:
        return 'Descrição';
      case SortType.quantidade:
        return 'Quantidade';
      case SortType.dataCreated:
        return 'Data de Criação';
      case SortType.dataUpdated:
        return 'Data de Atualização';
    }
  }
}

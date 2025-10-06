import 'package:flutter/material.dart';

import '../../domain/entities/expense.dart';

/// Widget responsible for search and filtering functionality following SRP
/// 
/// Single responsibility: Handle expense search and category/date filtering
class ExpenseSearchFiltersWidget extends StatefulWidget {
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<ExpenseCategory?> onCategoryChanged;
  final ValueChanged<DateTimeRange?> onDateRangeChanged;
  final ValueChanged<bool> onFiltersToggled;
  final bool showFilters;
  final String searchQuery;
  final ExpenseCategory? filterCategory;
  final DateTimeRange? dateRange;

  const ExpenseSearchFiltersWidget({
    super.key,
    required this.onSearchChanged,
    required this.onCategoryChanged,
    required this.onDateRangeChanged,
    required this.onFiltersToggled,
    required this.showFilters,
    required this.searchQuery,
    this.filterCategory,
    this.dateRange,
  });

  @override
  State<ExpenseSearchFiltersWidget> createState() => _ExpenseSearchFiltersWidgetState();
}

class _ExpenseSearchFiltersWidgetState extends State<ExpenseSearchFiltersWidget> {
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.searchQuery);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildSearchField(theme),
            const SizedBox(height: 12),
            _buildFilterToggle(theme),
            if (widget.showFilters) ...[
              const SizedBox(height: 16),
              _buildFiltersRow(theme),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSearchField(ThemeData theme) {
    return TextField(
      controller: _searchController,
      onChanged: widget.onSearchChanged,
      decoration: InputDecoration(
        hintText: 'Pesquisar despesas...',
        prefixIcon: const Icon(Icons.search),
        suffixIcon: widget.searchQuery.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  _searchController.clear();
                  widget.onSearchChanged('');
                },
              )
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  Widget _buildFilterToggle(ThemeData theme) {
    return Row(
      children: [
        Icon(
          Icons.tune,
          color: theme.colorScheme.primary,
          size: 20,
        ),
        const SizedBox(width: 8),
        Text(
          'Filtros',
          style: theme.textTheme.titleSmall?.copyWith(
            color: theme.colorScheme.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const Spacer(),
        Switch.adaptive(
          value: widget.showFilters,
          onChanged: widget.onFiltersToggled,
          activeColor: theme.colorScheme.primary,
        ),
      ],
    );
  }

  Widget _buildFiltersRow(ThemeData theme) {
    return Row(
      children: [
        Expanded(
          child: _buildCategoryFilter(theme),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildDateRangeFilter(theme),
        ),
      ],
    );
  }

  Widget _buildCategoryFilter(ThemeData theme) {
    return DropdownButtonFormField<ExpenseCategory?>(
      value: widget.filterCategory,
      decoration: InputDecoration(
        labelText: 'Categoria',
        prefixIcon: const Icon(Icons.category),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      items: [
        const DropdownMenuItem<ExpenseCategory?>(
          value: null,
          child: Text('Todas as categorias'),
        ),
        ...ExpenseCategory.values.map(
          (category) => DropdownMenuItem(
            value: category,
            child: Text(_getCategoryName(category)),
          ),
        ),
      ],
      onChanged: widget.onCategoryChanged,
    );
  }

  Widget _buildDateRangeFilter(ThemeData theme) {
    return InkWell(
      onTap: () async {
        final picked = await showDateRangePicker(
          context: context,
          firstDate: DateTime.now().subtract(const Duration(days: 365)),
          lastDate: DateTime.now().add(const Duration(days: 30)),
          initialDateRange: widget.dateRange,
        );
        if (picked != null) {
          widget.onDateRangeChanged(picked);
        }
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: 'Período',
          prefixIcon: const Icon(Icons.date_range),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Text(
          widget.dateRange != null
              ? '${_formatDate(widget.dateRange!.start)} - ${_formatDate(widget.dateRange!.end)}'
              : 'Selecionar período',
          style: theme.textTheme.bodyMedium,
        ),
      ),
    );
  }

  String _getCategoryName(ExpenseCategory category) {
    switch (category) {
      case ExpenseCategory.consultation:
        return 'Consulta';
      case ExpenseCategory.medication:
        return 'Medicamentos';
      case ExpenseCategory.vaccine:
        return 'Vacina';
      case ExpenseCategory.surgery:
        return 'Cirurgia';
      case ExpenseCategory.exam:
        return 'Exame';
      case ExpenseCategory.food:
        return 'Alimentação';
      case ExpenseCategory.accessory:
        return 'Acessórios';
      case ExpenseCategory.grooming:
        return 'Higiene';
      case ExpenseCategory.insurance:
        return 'Seguro';
      case ExpenseCategory.emergency:
        return 'Emergência';
      case ExpenseCategory.other:
        return 'Outros';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}

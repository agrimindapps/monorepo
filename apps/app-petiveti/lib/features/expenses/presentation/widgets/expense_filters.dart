import 'package:flutter/material.dart';

import '../../domain/constants/expense_constants.dart';
import '../../domain/entities/expense.dart';

/// Widget responsável por filtros de despesas
///
/// **SRP**: Única responsabilidade de gerenciar filtros
/// Extraído de ExpenseEnhancedList para reduzir complexidade
class ExpenseFilters extends StatefulWidget {
  final String searchQuery;
  final ExpenseCategory? filterCategory;
  final DateTimeRange? dateRange;
  final void Function(String) onSearchChanged;
  final void Function(ExpenseCategory?) onCategoryChanged;
  final void Function(DateTimeRange?) onDateRangeChanged;
  final VoidCallback onClearFilters;

  const ExpenseFilters({
    super.key,
    required this.searchQuery,
    required this.filterCategory,
    required this.dateRange,
    required this.onSearchChanged,
    required this.onCategoryChanged,
    required this.onDateRangeChanged,
    required this.onClearFilters,
  });

  @override
  State<ExpenseFilters> createState() => _ExpenseFiltersState();
}

class _ExpenseFiltersState extends State<ExpenseFilters> {
  late TextEditingController _searchController;

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
    final hasActiveFilters =
        widget.searchQuery.isNotEmpty ||
        widget.filterCategory != null ||
        widget.dateRange != null;

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Filtros',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (hasActiveFilters)
                  TextButton.icon(
                    onPressed: widget.onClearFilters,
                    icon: const Icon(Icons.clear_all, size: 18),
                    label: const Text('Limpar'),
                  ),
              ],
            ),
            const SizedBox(height: 16),

            // Search field
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Buscar por descrição...',
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
              onChanged: widget.onSearchChanged,
            ),
            const SizedBox(height: 16),

            // Category filter
            DropdownButtonFormField<ExpenseCategory>(
              initialValue: widget.filterCategory,
              decoration: InputDecoration(
                labelText: 'Categoria',
                prefixIcon: const Icon(Icons.category),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              items: [
                const DropdownMenuItem(
                  value: null,
                  child: Text('Todas as categorias'),
                ),
                ...ExpenseCategory.values.map((category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Text(_getCategoryName(category)),
                  );
                }),
              ],
              onChanged: widget.onCategoryChanged,
            ),
            const SizedBox(height: 16),

            // Date range filter
            OutlinedButton.icon(
              onPressed: () => _selectDateRange(context),
              icon: const Icon(Icons.date_range),
              label: Text(
                widget.dateRange != null
                    ? _formatDateRange(widget.dateRange!)
                    : 'Selecionar período',
              ),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            // Active filters summary
            if (hasActiveFilters) ...[
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  if (widget.searchQuery.isNotEmpty)
                    Chip(
                      label: Text('Busca: "${widget.searchQuery}"'),
                      onDeleted: () {
                        _searchController.clear();
                        widget.onSearchChanged('');
                      },
                    ),
                  if (widget.filterCategory != null)
                    Chip(
                      label: Text(_getCategoryName(widget.filterCategory!)),
                      onDeleted: () => widget.onCategoryChanged(null),
                    ),
                  if (widget.dateRange != null)
                    Chip(
                      label: Text(_formatDateRange(widget.dateRange!)),
                      onDeleted: () => widget.onDateRangeChanged(null),
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _selectDateRange(BuildContext context) async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: widget.dateRange,
      builder: (context, child) {
        return Theme(data: Theme.of(context), child: child!);
      },
    );

    if (picked != null) {
      widget.onDateRangeChanged(picked);
    }
  }

  String _getCategoryName(ExpenseCategory category) {
    return ExpenseConstants.getCategoryDisplayName(category.name);
  }

  String _formatDateRange(DateTimeRange range) {
    return '${_formatDate(range.start)} - ${_formatDate(range.end)}';
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}

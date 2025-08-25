import 'package:app_agrihurbi/features/news/domain/entities/news_article_entity.dart';
import 'package:flutter/material.dart';

/// News Filter Widget
/// 
/// Provides filtering options for news articles
class NewsFilterWidget extends StatefulWidget {
  final NewsFilter? currentFilter;
  final Function(NewsFilter) onApply;
  final VoidCallback onClear;

  const NewsFilterWidget({
    super.key,
    this.currentFilter,
    required this.onApply,
    required this.onClear,
  });

  @override
  State<NewsFilterWidget> createState() => _NewsFilterWidgetState();
}

class _NewsFilterWidgetState extends State<NewsFilterWidget> {
  late List<NewsCategory> _selectedCategories;
  late bool _showOnlyPremium;
  DateTime? _fromDate;
  DateTime? _toDate;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initializeFilter();
  }

  void _initializeFilter() {
    final filter = widget.currentFilter ?? const NewsFilter();
    _selectedCategories = List.from(filter.categories);
    _showOnlyPremium = filter.showOnlyPremium;
    _fromDate = filter.fromDate;
    _toDate = filter.toDate;
    _searchController.text = filter.searchQuery ?? '';
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 16),
          _buildSearchField(),
          const SizedBox(height: 16),
          _buildCategoriesSection(),
          const SizedBox(height: 16),
          _buildOptionsSection(),
          const SizedBox(height: 16),
          _buildDateRangeSection(),
          const SizedBox(height: 24),
          _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Text(
          'Filtrar Notícias',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const Spacer(),
        IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ],
    );
  }

  Widget _buildSearchField() {
    return TextField(
      controller: _searchController,
      decoration: const InputDecoration(
        labelText: 'Buscar por palavra-chave',
        hintText: 'Digite termos de busca...',
        prefixIcon: Icon(Icons.search),
        border: OutlineInputBorder(),
      ),
    );
  }

  Widget _buildCategoriesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Categorias',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: NewsCategory.values.map((category) {
            final isSelected = _selectedCategories.contains(category);
            return FilterChip(
              label: Text(category.displayName),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    _selectedCategories.add(category);
                  } else {
                    _selectedCategories.remove(category);
                  }
                });
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildOptionsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Opções',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        CheckboxListTile(
          title: const Text('Apenas conteúdo premium'),
          subtitle: const Text('Mostrar somente artigos premium'),
          value: _showOnlyPremium,
          onChanged: (value) {
            setState(() {
              _showOnlyPremium = value ?? false;
            });
          },
          contentPadding: EdgeInsets.zero,
        ),
      ],
    );
  }

  Widget _buildDateRangeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Período',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _buildDateField(
                label: 'Data inicial',
                date: _fromDate,
                onTap: () => _selectDate(context, true),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildDateField(
                label: 'Data final',
                date: _toDate,
                onTap: () => _selectDate(context, false),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            TextButton(
              onPressed: _setLastWeek,
              child: const Text('Última semana'),
            ),
            TextButton(
              onPressed: _setLastMonth,
              child: const Text('Último mês'),
            ),
            TextButton(
              onPressed: _clearDates,
              child: const Text('Limpar'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDateField({
    required String label,
    required DateTime? date,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          suffixIcon: const Icon(Icons.calendar_today),
        ),
        child: Text(
          date != null ? _formatDate(date) : 'Selecionar',
          style: TextStyle(
            color: date != null ? null : Colors.grey,
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () {
              widget.onClear();
              Navigator.pop(context);
            },
            child: const Text('Limpar Filtros'),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton(
            onPressed: _applyFilter,
            child: const Text('Aplicar Filtros'),
          ),
        ),
      ],
    );
  }

  void _applyFilter() {
    final filter = NewsFilter(
      categories: _selectedCategories,
      showOnlyPremium: _showOnlyPremium,
      fromDate: _fromDate,
      toDate: _toDate,
      searchQuery: _searchController.text.trim().isEmpty 
          ? null 
          : _searchController.text.trim(),
    );
    
    widget.onApply(filter);
  }

  Future<void> _selectDate(BuildContext context, bool isFromDate) async {
    final initialDate = isFromDate ? _fromDate : _toDate;
    final firstDate = DateTime.now().subtract(const Duration(days: 365));
    final lastDate = DateTime.now().add(const Duration(days: 30));

    final date = await showDatePicker(
      context: context,
      initialDate: initialDate ?? DateTime.now(),
      firstDate: firstDate,
      lastDate: lastDate,
    );

    if (date != null) {
      setState(() {
        if (isFromDate) {
          _fromDate = date;
          // If from date is after to date, clear to date
          if (_toDate != null && date.isAfter(_toDate!)) {
            _toDate = null;
          }
        } else {
          _toDate = date;
          // If to date is before from date, clear from date
          if (_fromDate != null && date.isBefore(_fromDate!)) {
            _fromDate = null;
          }
        }
      });
    }
  }

  void _setLastWeek() {
    final now = DateTime.now();
    setState(() {
      _fromDate = now.subtract(const Duration(days: 7));
      _toDate = now;
    });
  }

  void _setLastMonth() {
    final now = DateTime.now();
    setState(() {
      _fromDate = DateTime(now.year, now.month - 1, now.day);
      _toDate = now;
    });
  }

  void _clearDates() {
    setState(() {
      _fromDate = null;
      _toDate = null;
    });
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
           '${date.month.toString().padLeft(2, '0')}/'
           '${date.year}';
  }
}
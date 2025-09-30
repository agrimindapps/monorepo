import 'package:app_agrihurbi/core/theme/app_theme.dart';
import 'package:app_agrihurbi/features/markets/domain/entities/market_entity.dart';
import 'package:app_agrihurbi/features/markets/domain/entities/market_filter_entity.dart';
import 'package:flutter/material.dart';

/// Market Filter Sheet Widget
/// 
/// Bottom sheet for filtering markets by various criteria
class MarketFilterSheet extends StatefulWidget {
  final MarketFilter currentFilter;
  final void Function(MarketFilter) onFilterApplied;

  const MarketFilterSheet({
    super.key,
    required this.currentFilter,
    required this.onFilterApplied,
  });

  @override
  State<MarketFilterSheet> createState() => _MarketFilterSheetState();
}

class _MarketFilterSheetState extends State<MarketFilterSheet> {
  late MarketFilter _filter;
  List<MarketType> _selectedTypes = [];

  @override
  void initState() {
    super.initState();
    _filter = widget.currentFilter;
    _selectedTypes = widget.currentFilter.types ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Text(
                'Filtrar Mercados',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: _clearFilters,
                child: const Text('Limpar'),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          // Market Types
          Text(
            'Tipos de Mercado',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: MarketType.values.map((type) {
              final isSelected = _selectedTypes.contains(type);
              return FilterChip(
                label: Text(type.displayName),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      _selectedTypes.add(type);
                    } else {
                      _selectedTypes.remove(type);
                    }
                  });
                },
                selectedColor: AppTheme.primaryColor.withValues(alpha: 0.2),
                checkmarkColor: AppTheme.primaryColor,
              );
            }).toList(),
          ),
          
          const SizedBox(height: 32),
          
          // Apply Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _applyFilters,
              child: const Text('Aplicar Filtros'),
            ),
          ),
        ],
      ),
    );
  }

  void _clearFilters() {
    setState(() {
      _selectedTypes.clear();
    });
  }

  void _applyFilters() {
    final newFilter = _filter.copyWith(
      types: _selectedTypes.isEmpty ? null : _selectedTypes,
    );
    
    widget.onFilterApplied(newFilter);
    Navigator.pop(context);
  }
}
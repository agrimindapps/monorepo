import 'package:flutter/material.dart';

import '../../domain/entities/bovine_entity.dart';

/// Widget de filtros para livestock
/// 
/// Substitui os antigos filtros GetX com design Material 3
/// Suporta filtros específicos para bovinos e equinos
class LivestockFilterWidget extends StatelessWidget {
  final String? selectedBreed;
  final String? selectedOriginCountry;
  final BovineAptitude? selectedAptitude;
  final BreedingSystem? selectedBreedingSystem;
  final List<String> availableBreeds;
  final List<String> availableOriginCountries;
  final ValueChanged<String?>? onBreedChanged;
  final ValueChanged<String?>? onOriginCountryChanged;
  final ValueChanged<BovineAptitude?>? onAptitudeChanged;
  final ValueChanged<BreedingSystem?>? onBreedingSystemChanged;
  final VoidCallback? onClearFilters;
  final bool showClearButton;
  final bool isCollapsible;

  const LivestockFilterWidget({
    super.key,
    this.selectedBreed,
    this.selectedOriginCountry,
    this.selectedAptitude,
    this.selectedBreedingSystem,
    this.availableBreeds = const [],
    this.availableOriginCountries = const [],
    this.onBreedChanged,
    this.onOriginCountryChanged,
    this.onAptitudeChanged,
    this.onBreedingSystemChanged,
    this.onClearFilters,
    this.showClearButton = true,
    this.isCollapsible = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      elevation: 1.0,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header com título e botão limpar
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Filtros',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (showClearButton && _hasActiveFilters())
                  TextButton.icon(
                    onPressed: onClearFilters,
                    icon: const Icon(Icons.clear, size: 18.0),
                    label: const Text('Limpar'),
                    style: TextButton.styleFrom(
                      foregroundColor: Theme.of(context).colorScheme.error,
                    ),
                  ),
              ],
            ),
            
            const SizedBox(height: 16.0),
            
            // Grid de filtros
            _buildFiltersGrid(context),
          ],
        ),
      ),
    );
  }

  Widget _buildFiltersGrid(BuildContext context) {
    return Column(
      children: [
        // Primeira linha: Raça e País
        Row(
          children: [
            Expanded(
              child: _buildBreedFilter(context),
            ),
            const SizedBox(width: 12.0),
            Expanded(
              child: _buildOriginCountryFilter(context),
            ),
          ],
        ),
        
        const SizedBox(height: 16.0),
        
        // Segunda linha: Aptidão e Sistema de Criação
        Row(
          children: [
            Expanded(
              child: _buildAptitudeFilter(context),
            ),
            const SizedBox(width: 12.0),
            Expanded(
              child: _buildBreedingSystemFilter(context),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBreedFilter(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Raça',
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 8.0),
        DropdownButtonFormField<String>(
          value: selectedBreed,
          onChanged: onBreedChanged,
          decoration: InputDecoration(
            hintText: 'Todas as raças',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
          ),
          isExpanded: true,
          items: [
            const DropdownMenuItem<String>(
              value: null,
              child: Text('Todas as raças'),
            ),
            ...availableBreeds.map(
              (breed) => DropdownMenuItem<String>(
                value: breed,
                child: Text(breed),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildOriginCountryFilter(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'País de Origem',
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 8.0),
        DropdownButtonFormField<String>(
          value: selectedOriginCountry,
          onChanged: onOriginCountryChanged,
          decoration: InputDecoration(
            hintText: 'Todos os países',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
          ),
          isExpanded: true,
          items: [
            const DropdownMenuItem<String>(
              value: null,
              child: Text('Todos os países'),
            ),
            ...availableOriginCountries.map(
              (country) => DropdownMenuItem<String>(
                value: country,
                child: Text(country),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAptitudeFilter(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Aptidão',
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 8.0),
        DropdownButtonFormField<BovineAptitude>(
          value: selectedAptitude,
          onChanged: onAptitudeChanged,
          decoration: InputDecoration(
            hintText: 'Todas as aptidões',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
          ),
          isExpanded: true,
          items: [
            const DropdownMenuItem<BovineAptitude>(
              value: null,
              child: Text('Todas as aptidões'),
            ),
            ...BovineAptitude.values.map(
              (aptitude) => DropdownMenuItem<BovineAptitude>(
                value: aptitude,
                child: Text(aptitude.displayName),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBreedingSystemFilter(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Sistema de Criação',
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 8.0),
        DropdownButtonFormField<BreedingSystem>(
          value: selectedBreedingSystem,
          onChanged: onBreedingSystemChanged,
          decoration: InputDecoration(
            hintText: 'Todos os sistemas',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
          ),
          isExpanded: true,
          items: [
            const DropdownMenuItem<BreedingSystem>(
              value: null,
              child: Text('Todos os sistemas'),
            ),
            ...BreedingSystem.values.map(
              (system) => DropdownMenuItem<BreedingSystem>(
                value: system,
                child: Text(system.displayName),
              ),
            ),
          ],
        ),
      ],
    );
  }

  bool _hasActiveFilters() {
    return selectedBreed != null ||
           selectedOriginCountry != null ||
           selectedAptitude != null ||
           selectedBreedingSystem != null;
  }
}

/// Widget de filtros compactos em chips
/// 
/// Versão horizontal para telas menores ou filtros rápidos
class CompactLivestockFilterWidget extends StatelessWidget {
  final String? selectedBreed;
  final BovineAptitude? selectedAptitude;
  final BreedingSystem? selectedBreedingSystem;
  final ValueChanged<String?>? onBreedChanged;
  final ValueChanged<BovineAptitude?>? onAptitudeChanged;
  final ValueChanged<BreedingSystem?>? onBreedingSystemChanged;
  final VoidCallback? onClearFilters;
  final List<String> availableBreeds;

  const CompactLivestockFilterWidget({
    super.key,
    this.selectedBreed,
    this.selectedAptitude,
    this.selectedBreedingSystem,
    this.onBreedChanged,
    this.onAptitudeChanged,
    this.onBreedingSystemChanged,
    this.onClearFilters,
    this.availableBreeds = const [],
  });

  @override
  Widget build(BuildContext context) {
    final activeFilters = <Widget>[];

    // Chip de raça
    if (selectedBreed != null) {
      activeFilters.add(
        FilterChip(
          label: Text('Raça: $selectedBreed'),
          onSelected: (bool selected) {
            if (!selected) {
              onBreedChanged?.call(null);
            }
          },
          onDeleted: () => onBreedChanged?.call(null),
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        ),
      );
    }

    // Chip de aptidão
    if (selectedAptitude != null) {
      activeFilters.add(
        FilterChip(
          label: Text('Aptidão: ${selectedAptitude!.displayName}'),
          onSelected: (bool selected) {
            if (!selected) {
              onAptitudeChanged?.call(null);
            }
          },
          onDeleted: () => onAptitudeChanged?.call(null),
          backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
        ),
      );
    }

    // Chip de sistema
    if (selectedBreedingSystem != null) {
      activeFilters.add(
        FilterChip(
          label: Text('Sistema: ${selectedBreedingSystem!.displayName}'),
          onSelected: (bool selected) {
            if (!selected) {
              onBreedingSystemChanged?.call(null);
            }
          },
          onDeleted: () => onBreedingSystemChanged?.call(null),
          backgroundColor: Theme.of(context).colorScheme.tertiaryContainer,
        ),
      );
    }

    if (activeFilters.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Filtros ativos',
                style: Theme.of(context).textTheme.labelMedium,
              ),
              TextButton(
                onPressed: onClearFilters,
                child: const Text('Limpar todos'),
              ),
            ],
          ),
          const SizedBox(height: 8.0),
          Wrap(
            spacing: 8.0,
            runSpacing: 4.0,
            children: activeFilters,
          ),
        ],
      ),
    );
  }
}

/// Widget de filtros avançados com mais opções
/// 
/// Inclui range de datas, ordenação e outros filtros especializados
class AdvancedLivestockFilterWidget extends StatefulWidget {
  final String? selectedBreed;
  final String? selectedOriginCountry;
  final BovineAptitude? selectedAptitude;
  final BreedingSystem? selectedBreedingSystem;
  final DateTimeRange? dateRange;
  final String? sortBy;
  final bool sortAscending;
  final ValueChanged<String?>? onBreedChanged;
  final ValueChanged<String?>? onOriginCountryChanged;
  final ValueChanged<BovineAptitude?>? onAptitudeChanged;
  final ValueChanged<BreedingSystem?>? onBreedingSystemChanged;
  final ValueChanged<DateTimeRange?>? onDateRangeChanged;
  final ValueChanged<String?>? onSortChanged;
  final ValueChanged<bool>? onSortDirectionChanged;
  final VoidCallback? onClearFilters;
  final List<String> availableBreeds;
  final List<String> availableOriginCountries;

  const AdvancedLivestockFilterWidget({
    super.key,
    this.selectedBreed,
    this.selectedOriginCountry,
    this.selectedAptitude,
    this.selectedBreedingSystem,
    this.dateRange,
    this.sortBy,
    this.sortAscending = true,
    this.onBreedChanged,
    this.onOriginCountryChanged,
    this.onAptitudeChanged,
    this.onBreedingSystemChanged,
    this.onDateRangeChanged,
    this.onSortChanged,
    this.onSortDirectionChanged,
    this.onClearFilters,
    this.availableBreeds = const [],
    this.availableOriginCountries = const [],
  });

  @override
  State<AdvancedLivestockFilterWidget> createState() =>
      _AdvancedLivestockFilterWidgetState();
}

class _AdvancedLivestockFilterWidgetState
    extends State<AdvancedLivestockFilterWidget> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: ExpansionTile(
        title: const Text('Filtros Avançados'),
        subtitle: _buildActiveFiltersText(),
        initiallyExpanded: _expanded,
        onExpansionChanged: (expanded) {
          setState(() {
            _expanded = expanded;
          });
        },
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Filtros básicos
                LivestockFilterWidget(
                  selectedBreed: widget.selectedBreed,
                  selectedOriginCountry: widget.selectedOriginCountry,
                  selectedAptitude: widget.selectedAptitude,
                  selectedBreedingSystem: widget.selectedBreedingSystem,
                  availableBreeds: widget.availableBreeds,
                  availableOriginCountries: widget.availableOriginCountries,
                  onBreedChanged: widget.onBreedChanged,
                  onOriginCountryChanged: widget.onOriginCountryChanged,
                  onAptitudeChanged: widget.onAptitudeChanged,
                  onBreedingSystemChanged: widget.onBreedingSystemChanged,
                  showClearButton: false,
                ),

                const SizedBox(height: 16.0),

                // Filtros de data e ordenação
                Row(
                  children: [
                    Expanded(
                      child: _buildDateRangeFilter(context),
                    ),
                    const SizedBox(width: 12.0),
                    Expanded(
                      child: _buildSortFilter(context),
                    ),
                  ],
                ),

                const SizedBox(height: 16.0),

                // Botões de ação
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: widget.onClearFilters,
                      child: const Text('Limpar Filtros'),
                    ),
                    FilledButton(
                      onPressed: () {
                        setState(() {
                          _expanded = false;
                        });
                      },
                      child: const Text('Aplicar Filtros'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateRangeFilter(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Período',
          style: Theme.of(context).textTheme.labelMedium,
        ),
        const SizedBox(height: 8.0),
        OutlinedButton(
          onPressed: () async {
            final picked = await showDateRangePicker(
              context: context,
              firstDate: DateTime(2020),
              lastDate: DateTime.now(),
              initialDateRange: widget.dateRange,
            );
            if (picked != null) {
              widget.onDateRangeChanged?.call(picked);
            }
          },
          child: Text(
            widget.dateRange != null
                ? '${widget.dateRange!.start.day}/${widget.dateRange!.start.month} - ${widget.dateRange!.end.day}/${widget.dateRange!.end.month}'
                : 'Selecionar período',
          ),
        ),
      ],
    );
  }

  Widget _buildSortFilter(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Ordenação',
          style: Theme.of(context).textTheme.labelMedium,
        ),
        const SizedBox(height: 8.0),
        DropdownButtonFormField<String>(
          value: widget.sortBy,
          onChanged: widget.onSortChanged,
          decoration: InputDecoration(
            hintText: 'Ordenar por',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
          ),
          items: const [
            DropdownMenuItem(value: null, child: Text('Padrão')),
            DropdownMenuItem(value: 'name', child: Text('Nome')),
            DropdownMenuItem(value: 'breed', child: Text('Raça')),
            DropdownMenuItem(value: 'created', child: Text('Data de Criação')),
            DropdownMenuItem(value: 'updated', child: Text('Última Atualização')),
          ],
        ),
      ],
    );
  }

  Widget? _buildActiveFiltersText() {
    final activeCount = _countActiveFilters();
    if (activeCount == 0) return null;
    
    return Text('$activeCount filtro${activeCount > 1 ? 's' : ''} ativo${activeCount > 1 ? 's' : ''}');
  }

  int _countActiveFilters() {
    int count = 0;
    if (widget.selectedBreed != null) count++;
    if (widget.selectedOriginCountry != null) count++;
    if (widget.selectedAptitude != null) count++;
    if (widget.selectedBreedingSystem != null) count++;
    if (widget.dateRange != null) count++;
    if (widget.sortBy != null) count++;
    return count;
  }
}
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../domain/entities/animal_enums.dart';
import '../providers/animals_provider.dart';

class AnimalsAppBar extends ConsumerStatefulWidget implements PreferredSizeWidget {
  const AnimalsAppBar({super.key});

  @override
  ConsumerState<AnimalsAppBar> createState() => _AnimalsAppBarState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _AnimalsAppBarState extends ConsumerState<AnimalsAppBar> {
  bool _isSearching = false;
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final animalsState = ref.watch(animalsProvider);
    final hasActiveFilters = animalsState.filter.hasActiveFilters;

    return AppBar(
      title: _isSearching
          ? _buildSearchField()
          : Row(
              children: [
                const Text('Meus Pets'),
                if (hasActiveFilters) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${animalsState.displayedAnimals.length}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ],
            ),
      leading: _isSearching
          ? IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                setState(() {
                  _isSearching = false;
                });
                _searchController.clear();
                ref.read(animalsProvider.notifier).updateSearchQuery('');
              },
            )
          : null,
      actions: [
        if (!_isSearching) ...[
          IconButton(
            icon: Icon(
              Icons.search,
              color: hasActiveFilters
                  ? Theme.of(context).colorScheme.primary
                  : null,
            ),
            onPressed: () {
              setState(() {
                _isSearching = true;
              });
            },
          ),
          IconButton(
            icon: Icon(
              Icons.filter_list,
              color: hasActiveFilters
                  ? Theme.of(context).colorScheme.primary
                  : null,
            ),
            onPressed: () => _showFilterBottomSheet(context),
          ),
        ],
        if (_isSearching) ...[
          if (animalsState.filter.searchQuery.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () {
                _searchController.clear();
                ref.read(animalsProvider.notifier).updateSearchQuery('');
              },
            ),
        ],
        PopupMenuButton<String>(
          onSelected: (value) {
            switch (value) {
              case 'sync':
                _syncAnimals(context, ref);
                break;
              case 'settings':
                context.go('/settings');
                break;
              case 'clear_filters':
                _clearAllFilters();
                break;
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'sync',
              child: Row(
                children: [
                  Icon(Icons.sync),
                  SizedBox(width: 8),
                  Text('Sincronizar'),
                ],
              ),
            ),
            if (hasActiveFilters)
              const PopupMenuItem(
                value: 'clear_filters',
                child: Row(
                  children: [
                    Icon(Icons.clear_all),
                    SizedBox(width: 8),
                    Text('Limpar Filtros'),
                  ],
                ),
              ),
            const PopupMenuItem(
              value: 'settings',
              child: Row(
                children: [
                  Icon(Icons.settings),
                  SizedBox(width: 8),
                  Text('Configurações'),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSearchField() {
    return TextField(
      controller: _searchController,
      autofocus: true,
      style: const TextStyle(color: Colors.white),
      decoration: const InputDecoration(
        hintText: 'Buscar pets...',
        hintStyle: TextStyle(color: Colors.white70),
        border: InputBorder.none,
      ),
      onChanged: (query) {
        ref.read(animalsProvider.notifier).updateSearchQuery(query);
      },
    );
  }

  void _showFilterBottomSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) => const AnimalsFilterBottomSheet(),
    );
  }

  void _clearAllFilters() {
    ref.read(animalsProvider.notifier).clearFilters();
    _searchController.clear();
    if (_isSearching) {
      setState(() {
        _isSearching = false;
      });
    }
  }

  void _syncAnimals(BuildContext context, WidgetRef ref) async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            SizedBox(width: 12),
            Text('Sincronizando...'),
          ],
        ),
        duration: Duration(seconds: 2),
      ),
    );
    
    // Trigger sync through repository
    await ref.read(animalsProvider.notifier).loadAnimals();
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class AnimalsFilterBottomSheet extends ConsumerStatefulWidget {
  const AnimalsFilterBottomSheet({super.key});

  @override
  ConsumerState<AnimalsFilterBottomSheet> createState() => 
      _AnimalsFilterBottomSheetState();
}

class _AnimalsFilterBottomSheetState 
    extends ConsumerState<AnimalsFilterBottomSheet> {
  late AnimalsFilter _tempFilter;

  @override
  void initState() {
    super.initState();
    _tempFilter = ref.read(animalsProvider).filter;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Filtros',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: () {
                  setState(() {
                    _tempFilter = const AnimalsFilter();
                  });
                },
                child: const Text('Limpar Todos'),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () {
                  _applyFilters();
                  Navigator.of(context).pop();
                },
                child: const Text('Aplicar'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Species Filter
          _buildFilterSection(
            'Espécie',
            DropdownButton<AnimalSpecies?>(
              value: _tempFilter.speciesFilter,
              isExpanded: true,
              items: [
                const DropdownMenuItem<AnimalSpecies?>(
                  value: null,
                  child: Text('Todas as espécies'),
                ),
                ...AnimalSpecies.values.map((species) =>
                  DropdownMenuItem<AnimalSpecies?>(
                    value: species,
                    child: Text(species.displayName),
                  ),
                ),
              ],
              onChanged: (value) {
                setState(() {
                  _tempFilter = _tempFilter.copyWith(speciesFilter: value);
                });
              },
            ),
          ),

          // Gender Filter
          _buildFilterSection(
            'Gênero',
            DropdownButton<AnimalGender?>(
              value: _tempFilter.genderFilter,
              isExpanded: true,
              items: [
                const DropdownMenuItem<AnimalGender?>(
                  value: null,
                  child: Text('Todos os gêneros'),
                ),
                ...AnimalGender.values.map((gender) =>
                  DropdownMenuItem<AnimalGender?>(
                    value: gender,
                    child: Text(gender.displayName),
                  ),
                ),
              ],
              onChanged: (value) {
                setState(() {
                  _tempFilter = _tempFilter.copyWith(genderFilter: value);
                });
              },
            ),
          ),

          // Size Filter
          _buildFilterSection(
            'Porte',
            DropdownButton<AnimalSize?>(
              value: _tempFilter.sizeFilter,
              isExpanded: true,
              items: [
                const DropdownMenuItem<AnimalSize?>(
                  value: null,
                  child: Text('Todos os portes'),
                ),
                ...AnimalSize.values.where((size) => size != AnimalSize.unknown)
                    .map((size) =>
                  DropdownMenuItem<AnimalSize?>(
                    value: size,
                    child: Text(size.displayName),
                  ),
                ),
              ],
              onChanged: (value) {
                setState(() {
                  _tempFilter = _tempFilter.copyWith(sizeFilter: value);
                });
              },
            ),
          ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildFilterSection(String title, Widget child) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }

  void _applyFilters() {
    final notifier = ref.read(animalsProvider.notifier);
    
    // Apply each filter individually to trigger proper state updates
    notifier.updateSpeciesFilter(_tempFilter.speciesFilter);
    notifier.updateGenderFilter(_tempFilter.genderFilter);
    notifier.updateSizeFilter(_tempFilter.sizeFilter);
  }
}
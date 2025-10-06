import 'package:core/core.dart';
import 'package:flutter/material.dart';

import '../../../../shared/constants/animals_constants.dart';
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
                const Text(AnimalsConstants.myPets),
                if (hasActiveFilters) ...[
                  const SizedBox(width: 8),
                  Semantics(
                    label: '${animalsState.displayedAnimals.length} pets filtrados',
                    hint: 'Número de pets que atendem aos filtros aplicados',
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AnimalsConstants.badgeHorizontalPadding,
                        vertical: AnimalsConstants.badgeVerticalPadding,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(AnimalsConstants.badgeBorderRadius),
                      ),
                      child: Text(
                        '${animalsState.displayedAnimals.length}',
                        style: TextStyle(
                          fontSize: AnimalsConstants.badgeFontSize,
                          color: Theme.of(context).colorScheme.onPrimaryContainer,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
      leading: _isSearching
          ? Semantics(
              label: AnimalsConstants.backToList,
              hint: AnimalsConstants.backToListHint,
              button: true,
              child: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  setState(() {
                    _isSearching = false;
                  });
                  _searchController.clear();
                  ref.read(animalsProvider.notifier).updateSearchQuery('');
                },
              ),
            )
          : null,
      actions: [
        if (!_isSearching) ...[
          Semantics(
            label: AnimalsConstants.searchPets,
            hint: hasActiveFilters 
                ? AnimalsConstants.searchActiveHint
                : AnimalsConstants.searchPetsAccessibilityHint,
            button: true,
            child: IconButton(
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
          ),
          Semantics(
            label: hasActiveFilters 
                ? AnimalsConstants.filtersActiveLabel
                : AnimalsConstants.filtersLabel,
            hint: hasActiveFilters
                ? AnimalsConstants.filtersActiveHint
                : AnimalsConstants.filtersHint,
            button: true,
            child: IconButton(
              icon: Icon(
                Icons.filter_list,
                color: hasActiveFilters
                    ? Theme.of(context).colorScheme.primary
                    : null,
              ),
              onPressed: () => _showFilterBottomSheet(context),
            ),
          ),
        ],
        if (_isSearching) ...[
          if (animalsState.filter.searchQuery.isNotEmpty)
            Semantics(
              label: AnimalsConstants.clearSearch,
              hint: AnimalsConstants.clearSearchHint,
              button: true,
              child: IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  _searchController.clear();
                  ref.read(animalsProvider.notifier).updateSearchQuery('');
                },
              ),
            ),
        ],
        Semantics(
          label: AnimalsConstants.optionsMenu,
          hint: AnimalsConstants.optionsMenuHint,
          button: true,
          child: PopupMenuButton<String>(
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
              PopupMenuItem(
                value: 'sync',
                child: Semantics(
                  label: AnimalsConstants.syncPets,
                  hint: AnimalsConstants.syncPetsHint,
                  button: true,
                  child: const Row(
                    children: [
                      Icon(Icons.sync),
                      SizedBox(width: 8),
                      Text(AnimalsConstants.synchronize),
                    ],
                  ),
                ),
              ),
              if (hasActiveFilters)
                PopupMenuItem(
                  value: 'clear_filters',
                  child: Semantics(
                    label: AnimalsConstants.clearAllFilters,
                    hint: AnimalsConstants.clearAllFiltersHint,
                    button: true,
                    child: const Row(
                      children: [
                        Icon(Icons.clear_all),
                        SizedBox(width: 8),
                        Text(AnimalsConstants.clearFilters),
                      ],
                    ),
                  ),
                ),
              PopupMenuItem(
                value: 'settings',
                child: Semantics(
                  label: AnimalsConstants.settingsLabel,
                  hint: AnimalsConstants.settingsHint,
                  button: true,
                  child: const Row(
                    children: [
                      Icon(Icons.settings),
                      SizedBox(width: 8),
                      Text(AnimalsConstants.settings),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSearchField() {
    return Semantics(
      label: AnimalsConstants.searchFieldLabel,
      hint: AnimalsConstants.searchFieldHint,
      textField: true,
      child: TextField(
        controller: _searchController,
        autofocus: true,
        style: const TextStyle(color: Colors.white),
        decoration: const InputDecoration(
          hintText: AnimalsConstants.searchPetsHint,
          hintStyle: TextStyle(color: Colors.white70),
          border: InputBorder.none,
        ),
        onChanged: (query) {
          ref.read(animalsProvider.notifier).updateSearchQuery(query);
        },
      ),
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
            Text(AnimalsConstants.synchronizing),
          ],
        ),
        duration: Duration(seconds: AnimalsConstants.syncDurationSeconds),
      ),
    );
    await ref.read(animalsProvider.notifier).loadAnimals();
  }
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
      padding: const EdgeInsets.all(AnimalsConstants.filterContainerPadding),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                AnimalsConstants.filters,
                style: TextStyle(
                  fontSize: AnimalsConstants.filterHeaderFontSize,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Semantics(
                label: AnimalsConstants.clearAllFiltersDialog,
                hint: AnimalsConstants.clearAllFiltersDialogHint,
                button: true,
                child: TextButton(
                  onPressed: () {
                    setState(() {
                      _tempFilter = const AnimalsFilter();
                    });
                  },
                  child: const Text(AnimalsConstants.clearAll),
                ),
              ),
              const SizedBox(width: 8),
              Semantics(
                label: AnimalsConstants.applyFilters,
                hint: AnimalsConstants.applyFiltersHint,
                button: true,
                child: ElevatedButton(
                  onPressed: () {
                    _applyFilters();
                    Navigator.of(context).pop();
                  },
                  child: const Text(AnimalsConstants.apply),
                ),
              ),
            ],
          ),
          const SizedBox(height: AnimalsConstants.filterSectionSpacing),
          _buildFilterSection(
            AnimalsConstants.species,
            Semantics(
              label: AnimalsConstants.speciesFilterLabel,
              hint: AnimalsConstants.speciesFilterHint,
              button: true,
              child: DropdownButton<AnimalSpecies?>(
                value: _tempFilter.speciesFilter,
                isExpanded: true,
                items: [
                  const DropdownMenuItem<AnimalSpecies?>(
                    value: null,
                    child: Text(AnimalsConstants.allSpecies),
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
          ),
          _buildFilterSection(
            AnimalsConstants.gender,
            Semantics(
              label: AnimalsConstants.genderFilterLabel,
              hint: AnimalsConstants.genderFilterHint,
              button: true,
              child: DropdownButton<AnimalGender?>(
                value: _tempFilter.genderFilter,
                isExpanded: true,
                items: [
                  const DropdownMenuItem<AnimalGender?>(
                    value: null,
                    child: Text(AnimalsConstants.allGenders),
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
          ),
          _buildFilterSection(
            AnimalsConstants.size,
            Semantics(
              label: AnimalsConstants.sizeFilterLabel,
              hint: AnimalsConstants.sizeFilterHint,
              button: true,
              child: DropdownButton<AnimalSize?>(
                value: _tempFilter.sizeFilter,
                isExpanded: true,
                items: [
                  const DropdownMenuItem<AnimalSize?>(
                    value: null,
                    child: Text(AnimalsConstants.allSizes),
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
          ),

          const SizedBox(height: AnimalsConstants.filterSectionSpacing),
        ],
      ),
    );
  }

  Widget _buildFilterSection(String title, Widget child) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AnimalsConstants.filterSectionSpacing),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: AnimalsConstants.filterTitleFontSize,
            ),
          ),
          const SizedBox(height: AnimalsConstants.filterSectionSpacingSmall),
          child,
        ],
      ),
    );
  }

  void _applyFilters() {
    final notifier = ref.read(animalsProvider.notifier);
    notifier.updateSpeciesFilter(_tempFilter.speciesFilter);
    notifier.updateGenderFilter(_tempFilter.genderFilter);
    notifier.updateSizeFilter(_tempFilter.sizeFilter);
  }
}

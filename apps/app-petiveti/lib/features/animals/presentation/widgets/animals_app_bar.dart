import 'package:core/core.dart' hide Column;
import 'package:flutter/material.dart';

import '../../../../shared/constants/animals_constants.dart';
import '../providers/animals_providers.dart';

class AnimalsAppBar extends ConsumerStatefulWidget
    implements PreferredSizeWidget {
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
    // TODO: Re-implement filter detection with new filter strategy pattern
    // final hasActiveFilters = ...;

    return AppBar(
      title: _isSearching
          ? _buildSearchField()
          : const Row(
              children: [
                Text(AnimalsConstants.myPets),
                // TODO: Add filter badge when hasActiveFilters is implemented
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
                  // TODO: Re-implement search with new filter strategy
                  // ref.read(animalsProvider.notifier).updateSearchQuery('');
                },
              ),
            )
          : null,
      actions: [
        if (!_isSearching) ...[
          Semantics(
            label: AnimalsConstants.searchPets,
            hint: AnimalsConstants.searchPetsAccessibilityHint,
            button: true,
            child: IconButton(
              icon: const Icon(Icons.search),
              onPressed: () {
                setState(() {
                  _isSearching = true;
                });
              },
            ),
          ),
          Semantics(
            label: AnimalsConstants.filtersLabel,
            hint: AnimalsConstants.filtersHint,
            button: true,
            child: IconButton(
              icon: const Icon(Icons.filter_list),
              onPressed: () => _showFilterBottomSheet(context),
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
              // TODO: Add clear_filters menu item when hasActiveFilters is implemented
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
          // TODO: Re-implement search with new filter strategy
          // ref.read(animalsProvider.notifier).updateSearchQuery(query);
        },
      ),
    );
  }

  void _showFilterBottomSheet(BuildContext context) {
    // TODO: Re-implement filter bottom sheet with new filter strategy
    // showModalBottomSheet<void>(
    //   context: context,
    //   isScrollControlled: true,
    //   builder: (context) => const AnimalsFilterBottomSheet(),
    // );
  }

  void _clearAllFilters() {
    // TODO: Re-implement clear filters with new filter strategy
    // ref.read(animalsProvider.notifier).clearFilters();
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

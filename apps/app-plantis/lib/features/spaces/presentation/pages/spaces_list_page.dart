import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../providers/spaces_provider.dart';
import '../widgets/space_card.dart';
import '../widgets/space_list_tile.dart';
import '../widgets/empty_spaces_widget.dart';
import '../../domain/entities/space.dart';

class SpacesListPage extends StatefulWidget {
  const SpacesListPage({super.key});

  @override
  State<SpacesListPage> createState() => _SpacesListPageState();
}

class _SpacesListPageState extends State<SpacesListPage> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SpacesProvider>().loadSpaces();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Espaços'),
        actions: [
          Consumer<SpacesProvider>(
            builder: (context, provider, _) {
              return IconButton(
                icon: Icon(
                  provider.viewMode == ViewMode.grid 
                    ? Icons.view_list 
                    : Icons.grid_view,
                ),
                onPressed: () {
                  provider.setViewMode(
                    provider.viewMode == ViewMode.grid 
                      ? ViewMode.list 
                      : ViewMode.grid
                  );
                },
              );
            },
          ),
          PopupMenuButton<SortOption>(
            icon: const Icon(Icons.sort),
            onSelected: (option) {
              context.read<SpacesProvider>().setSortOption(option);
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: SortOption.name,
                child: Text('Nome'),
              ),
              const PopupMenuItem(
                value: SortOption.type,
                child: Text('Tipo'),
              ),
              const PopupMenuItem(
                value: SortOption.dateCreated,
                child: Text('Data de Criação'),
              ),
              const PopupMenuItem(
                value: SortOption.dateUpdated,
                child: Text('Última Modificação'),
              ),
            ],
          ),
        ],
      ),
      body: Consumer<SpacesProvider>(
        builder: (context, provider, _) {
          return Column(
            children: [
              // Search Bar
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Buscar espaços...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: provider.searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              provider.clearSearch();
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onChanged: (query) {
                    provider.searchSpaces(query);
                  },
                ),
              ),
              
              // Error Message
              if (provider.hasError)
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.errorContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.error_outline,
                        color: Theme.of(context).colorScheme.onErrorContainer,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          provider.errorMessage!,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onErrorContainer,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: provider.clearError,
                        child: const Text('OK'),
                      ),
                    ],
                  ),
                ),
              
              const SizedBox(height: 8),
              
              // Content
              Expanded(
                child: _buildContent(provider),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.push('/spaces/add');
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildContent(SpacesProvider provider) {
    if (provider.isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (!provider.hasSpaces) {
      return EmptySpacesWidget(
        isSearching: provider.searchQuery.isNotEmpty,
        onAddSpace: () {
          context.push('/spaces/add');
        },
        onClearSearch: provider.searchQuery.isNotEmpty 
            ? () {
                _searchController.clear();
                provider.clearSearch();
              }
            : null,
      );
    }

    return RefreshIndicator(
      onRefresh: provider.refresh,
      child: provider.viewMode == ViewMode.grid
          ? _buildGridView(provider.spaces)
          : _buildListView(provider.spaces),
    );
  }

  Widget _buildGridView(List<Space> spaces) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.8,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: spaces.length,
      itemBuilder: (context, index) {
        final space = spaces[index];
        return SpaceCard(
          space: space,
          onTap: () {
            context.push('/spaces/${space.id}');
          },
        );
      },
    );
  }

  Widget _buildListView(List<Space> spaces) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: spaces.length,
      separatorBuilder: (context, index) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final space = spaces[index];
        return SpaceListTile(
          space: space,
          onTap: () {
            context.push('/spaces/${space.id}');
          },
        );
      },
    );
  }
}
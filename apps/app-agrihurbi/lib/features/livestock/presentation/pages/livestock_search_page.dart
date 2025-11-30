import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../domain/entities/animal_base_entity.dart';
import '../../domain/entities/bovine_entity.dart';
import '../../domain/entities/equine_entity.dart';
import '../providers/livestock_provider.dart';
import '../widgets/bovine_card_widget.dart';

/// Página dedicada para busca avançada de animais
///
/// Permite filtros complexos, ordenação e visualização unificada
/// de bovinos e equinos com busca em tempo real
class LivestockSearchPage extends ConsumerStatefulWidget {
  const LivestockSearchPage({super.key});

  @override
  ConsumerState<LivestockSearchPage> createState() =>
      _LivestockSearchPageState();
}

class _LivestockSearchPageState extends ConsumerState<LivestockSearchPage> {
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();
  String _searchQuery = '';
  Set<String> _selectedAnimalTypes = {'bovine', 'equine'};
  String? _selectedBreed;
  String? _selectedOriginCountry;
  BovineAptitude? _selectedAptitude;
  EquineTemperament? _selectedTemperament;
  String _sortBy = 'name'; // name, date, breed
  bool _sortAscending = true;
  bool _showActiveOnly = true;
  bool _showFilters = false;

  List<AnimalBaseEntity> _searchResults = [];
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    _performInitialSearch();
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    if (_searchController.text != _searchQuery) {
      setState(() {
        _searchQuery = _searchController.text;
      });
      _performSearch();
    }
  }

  Future<void> _performInitialSearch() async {
    final provider = ref.read(livestockProviderProvider);
    await provider.loadBovines();
    await provider.loadEquines();
    _performSearch();
  }

  void _performSearch() {
    setState(() {
      _isSearching = true;
    });

    final provider = ref.read(livestockProviderProvider);
    List<AnimalBaseEntity> results = [];
    if (_selectedAnimalTypes.contains('bovine')) {
      final bovines = provider.filteredBovines
          .where((bovine) {
            return _matchesFilters(bovine) && _matchesSearch(bovine);
          })
          .cast<AnimalBaseEntity>()
          .toList();
      results.addAll(bovines);
    }
    _sortResults(results);

    setState(() {
      _searchResults = results;
      _isSearching = false;
    });
  }

  bool _matchesFilters(AnimalBaseEntity animal) {
    if (_showActiveOnly && !animal.isActive) return false;
    if (animal is BovineEntity) {
      if (_selectedBreed != null && animal.breed != _selectedBreed) {
        return false;
      }
      if (_selectedAptitude != null && animal.aptitude != _selectedAptitude) {
        return false;
      }
    } else if (animal is EquineEntity) {
      if (_selectedTemperament != null &&
          animal.temperament != _selectedTemperament) {
        return false;
      }
    }
    if (_selectedOriginCountry != null &&
        animal.originCountry != _selectedOriginCountry) {
      return false;
    }

    return true;
  }

  bool _matchesSearch(AnimalBaseEntity animal) {
    if (_searchQuery.isEmpty) return true;

    final query = _searchQuery.toLowerCase();
    final searchFields = [
      animal.commonName.toLowerCase(),
      animal.registrationId.toLowerCase(),
      animal.originCountry.toLowerCase(),
    ];
    if (animal is BovineEntity) {
      searchFields.addAll([
        animal.breed.toLowerCase(),
        animal.purpose.toLowerCase(),
        animal.aptitude.displayName.toLowerCase(),
        animal.breedingSystem.displayName.toLowerCase(),
        ...animal.tags.map((tag) => tag.toLowerCase()),
      ]);
    } else if (animal is EquineEntity) {
      searchFields.addAll([
        animal.temperament.displayName.toLowerCase(),
        animal.coat.displayName.toLowerCase(),
        animal.primaryUse.displayName.toLowerCase(),
        animal.geneticInfluences.toLowerCase(),
      ]);
    }

    return searchFields.any((field) => field.contains(query));
  }

  void _sortResults(List<AnimalBaseEntity> results) {
    results.sort((a, b) {
      int comparison = 0;

      switch (_sortBy) {
        case 'name':
          comparison = a.commonName.compareTo(b.commonName);
          break;
        case 'date':
          comparison = (a.createdAt ?? DateTime.now()).compareTo(
            b.createdAt ?? DateTime.now(),
          );
          break;
        case 'breed':
          if (a is BovineEntity && b is BovineEntity) {
            comparison = a.breed.compareTo(b.breed);
          } else if (a is EquineEntity && b is EquineEntity) {
            comparison = a.temperament.displayName.compareTo(
              b.temperament.displayName,
            );
          } else {
            comparison = a.runtimeType.toString().compareTo(
              b.runtimeType.toString(),
            );
          }
          break;
      }

      return _sortAscending ? comparison : -comparison;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Busca Avançada'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: Icon(
              _showFilters ? Icons.filter_list : Icons.filter_list_off,
            ),
            onPressed: () {
              setState(() {
                _showFilters = !_showFilters;
              });
            },
            tooltip: _showFilters ? 'Ocultar filtros' : 'Mostrar filtros',
          ),
          PopupMenuButton<String>(
            onSelected: _handleMenuAction,
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'clear',
                child: Row(
                  children: [
                    Icon(Icons.clear_all),
                    SizedBox(width: 8),
                    Text('Limpar Filtros'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'refresh',
                child: Row(
                  children: [
                    Icon(Icons.refresh),
                    SizedBox(width: 8),
                    Text('Atualizar'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          if (_showFilters) _buildFiltersSection(),
          _buildResultsHeader(),
          Expanded(child: _buildSearchResults()),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Buscar por nome, raça, origem...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                  },
                )
              : null,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  Widget _buildFiltersSection() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Filtros Avançados',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 16),
              Text(
                'Tipos de Animal:',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  FilterChip(
                    label: const Text('Bovinos'),
                    selected: _selectedAnimalTypes.contains('bovine'),
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _selectedAnimalTypes.add('bovine');
                        } else {
                          _selectedAnimalTypes.remove('bovine');
                        }
                      });
                      _performSearch();
                    },
                  ),
                  const SizedBox(width: 8),
                  FilterChip(
                    label: const Text('Equinos'),
                    selected: _selectedAnimalTypes.contains('equine'),
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _selectedAnimalTypes.add('equine');
                        } else {
                          _selectedAnimalTypes.remove('equine');
                        }
                      });
                      _performSearch();
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      initialValue: _sortBy,
                      decoration: const InputDecoration(
                        labelText: 'Ordenar por',
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'name', child: Text('Nome')),
                        DropdownMenuItem(value: 'date', child: Text('Data')),
                        DropdownMenuItem(
                          value: 'breed',
                          child: Text('Raça/Tipo'),
                        ),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _sortBy = value;
                          });
                          _performSearch();
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: Icon(
                      _sortAscending
                          ? Icons.arrow_upward
                          : Icons.arrow_downward,
                    ),
                    onPressed: () {
                      setState(() {
                        _sortAscending = !_sortAscending;
                      });
                      _performSearch();
                    },
                    tooltip: _sortAscending ? 'Crescente' : 'Decrescente',
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('Apenas ativos'),
                value: _showActiveOnly,
                onChanged: (value) {
                  setState(() {
                    _showActiveOnly = value;
                  });
                  _performSearch();
                },
                contentPadding: EdgeInsets.zero,
                dense: true,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResultsHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        children: [
          Icon(
            Icons.search_outlined,
            size: 16,
            color: Theme.of(context).colorScheme.outline,
          ),
          const SizedBox(width: 4),
          Text(
            '${_searchResults.length} resultado(s) encontrado(s)',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.outline,
            ),
          ),
          const Spacer(),
          if (_isSearching)
            const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
        ],
      ),
    );
  }

  Widget _buildSearchResults() {
    if (_isSearching) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Buscando...'),
          ],
        ),
      );
    }

    if (_searchResults.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text(
              'Nenhum resultado encontrado',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Tente ajustar os filtros ou termos de busca',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _clearAllFilters,
              child: const Text('Limpar Filtros'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _performInitialSearch,
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.all(8.0),
        itemCount: _searchResults.length,
        itemBuilder: (context, index) {
          final animal = _searchResults[index];

          if (animal is BovineEntity) {
            return BovineCardWidget(
              bovine: animal,
              onTap: () =>
                  context.push('/home/livestock/bovines/detail/${animal.id}'),
              onEdit: () =>
                  context.push('/home/livestock/bovines/edit/${animal.id}'),
              onDelete: () => _confirmDeleteAnimal(animal),
            );
          } else if (animal is EquineEntity) {
            return _buildEquineCard(animal);
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildEquineCard(EquineEntity equine) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
          child: Icon(
            Icons.pets,
            color: Theme.of(context).colorScheme.onSecondaryContainer,
          ),
        ),
        title: Text(equine.commonName),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Temperamento: ${equine.temperament.displayName}'),
            Text('Origem: ${equine.originCountry}'),
            Text('Uso: ${equine.primaryUse.displayName}'),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (action) => _handleEquineAction(action, equine),
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'detail',
              child: Row(
                children: [
                  Icon(Icons.visibility),
                  SizedBox(width: 8),
                  Text('Ver Detalhes'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  Icon(Icons.edit),
                  SizedBox(width: 8),
                  Text('Editar'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Excluir', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
        ),
        onTap: () =>
            context.push('/home/livestock/equines/detail/${equine.id}'),
      ),
    );
  }

  void _handleMenuAction(String action) {
    switch (action) {
      case 'clear':
        _clearAllFilters();
        break;
      case 'refresh':
        _performInitialSearch();
        break;
    }
  }

  void _handleEquineAction(String action, EquineEntity equine) {
    switch (action) {
      case 'detail':
        context.push('/home/livestock/equines/detail/${equine.id}');
        break;
      case 'edit':
        context.push('/home/livestock/equines/edit/${equine.id}');
        break;
      case 'delete':
        _confirmDeleteAnimal(equine);
        break;
    }
  }

  void _clearAllFilters() {
    setState(() {
      _searchController.clear();
      _searchQuery = '';
      _selectedAnimalTypes = {'bovine', 'equine'};
      _selectedBreed = null;
      _selectedOriginCountry = null;
      _selectedAptitude = null;
      _selectedTemperament = null;
      _sortBy = 'name';
      _sortAscending = true;
      _showActiveOnly = true;
    });
    _performSearch();
  }

  void _confirmDeleteAnimal(AnimalBaseEntity animal) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Exclusão'),
        content: Text(
          'Tem certeza que deseja excluir "${animal.commonName}"?\n\n'
          'Esta ação não pode ser desfeita.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _deleteAnimal(animal);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
  }

  void _deleteAnimal(AnimalBaseEntity animal) async {
    final provider = ref.read(livestockProviderProvider);
    bool success = false;

    if (animal is BovineEntity) {
      success = await provider.deleteBovine(animal.id);
    } else if (animal is EquineEntity) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Exclusão de equinos em desenvolvimento')),
      );
      return;
    }

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${animal.commonName} excluído com sucesso'),
          backgroundColor: Theme.of(context).colorScheme.primary,
        ),
      );
      _performSearch(); // Refresh results
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao excluir: ${provider.errorMessage}'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }
}

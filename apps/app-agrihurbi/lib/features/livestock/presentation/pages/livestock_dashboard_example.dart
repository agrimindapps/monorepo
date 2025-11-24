import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/bovine_entity.dart';
import '../providers/livestock_coordinator_provider.dart';

/// Exemplo de uso do sistema refatorado seguindo Single Responsibility Principle
///
/// ANTES: 1 LivestockProvider monolítico (475 linhas, múltiplas responsabilidades)
/// DEPOIS: Composição de providers especializados via LivestockCoordinatorProvider
class LivestockDashboardExample extends ConsumerStatefulWidget {
  const LivestockDashboardExample({super.key});

  @override
  ConsumerState<LivestockDashboardExample> createState() =>
      _LivestockDashboardExampleState();
}

class _LivestockDashboardExampleState
    extends ConsumerState<LivestockDashboardExample> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final coordinator = ref.read(livestockCoordinatorProvider);
      coordinator?.initializeSystem();
    });
  }

  @override
  Widget build(BuildContext context) {
    final coordinator = ref.watch(livestockCoordinatorProvider);
    if (coordinator == null) {
      return const Scaffold(
        body: Center(child: Text('Coordinator not available')),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('Livestock Dashboard'),
        actions: [
          IconButton(
            icon: coordinator.syncProvider.isSyncing
                ? const CircularProgressIndicator()
                : const Icon(Icons.sync),
            onPressed: coordinator.syncProvider.isSyncing
                ? null
                : () => coordinator.performCompleteSync(),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildStatisticsSection(coordinator),
          _buildFiltersSection(coordinator),
          Expanded(child: _buildBovinesList(coordinator)),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddBovineDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  /// Seção de estatísticas usando provider especializado
  Widget _buildStatisticsSection(LivestockCoordinatorProvider coordinator) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Estatísticas',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatCard(
                  'Total Bovinos',
                  '${coordinator.bovinesProvider.totalBovines}',
                  Icons.pets,
                  Colors.blue,
                ),
                _buildStatCard(
                  'Bovinos Ativos',
                  '${coordinator.bovinesProvider.totalActiveBovines}',
                  Icons.check_circle,
                  Colors.green,
                ),
                _buildStatCard(
                  'Equinos',
                  '${coordinator.equinesProvider.totalEquines}',
                  Icons.directions_run,
                  Colors.orange,
                ),
              ],
            ),
            if (coordinator.statisticsProvider.isLoading)
              const LinearProgressIndicator(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Icon(icon, color: color, size: 32),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        Text(title, style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  /// Seção de filtros usando provider especializado
  Widget _buildFiltersSection(LivestockCoordinatorProvider coordinator) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              decoration: const InputDecoration(
                labelText: 'Buscar bovinos',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: coordinator.filtersProvider.updateSearchQuery,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    decoration: const InputDecoration(labelText: 'Raça'),
                    initialValue: coordinator.filtersProvider.selectedBreed,
                    items: coordinator.filtersProvider.availableBreeds
                        .map(
                          (breed) => DropdownMenuItem(
                            value: breed,
                            child: Text(breed),
                          ),
                        )
                        .toList(),
                    onChanged: coordinator.filtersProvider.updateBreedFilter,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: DropdownButtonFormField<BovineAptitude>(
                    decoration: const InputDecoration(labelText: 'Aptidão'),
                    initialValue: coordinator.filtersProvider.selectedAptitude,
                    items: coordinator.filtersProvider.availableAptitudes
                        .map(
                          (aptitude) => DropdownMenuItem(
                            value: aptitude,
                            child: Text(aptitude.displayName),
                          ),
                        )
                        .toList(),
                    onChanged: coordinator.filtersProvider.updateAptitudeFilter,
                  ),
                ),
              ],
            ),
            if (coordinator.filtersProvider.hasActiveFilters)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${coordinator.filtersProvider.activeFiltersCount} filtros ativos',
                    ),
                    TextButton(
                      onPressed: coordinator.filtersProvider.clearAllFilters,
                      child: const Text('Limpar filtros'),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// Lista de bovinos usando provider especializado
  Widget _buildBovinesList(LivestockCoordinatorProvider coordinator) {
    if (coordinator.bovinesProvider.isLoadingBovines) {
      return const Center(child: CircularProgressIndicator());
    }

    final filteredBovines = coordinator.filteredBovines.cast<BovineEntity>();

    if (filteredBovines.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.pets, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('Nenhum bovino encontrado'),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: filteredBovines.length,
      itemBuilder: (context, index) {
        final bovine = filteredBovines[index];
        return Card(
          child: ListTile(
            leading: CircleAvatar(
              child: Text(bovine.commonName[0].toUpperCase()),
            ),
            title: Text(bovine.commonName),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Raça: ${bovine.breed}'),
                Text('Aptidão: ${bovine.aptitude.displayName}'),
                Text('ID: ${bovine.registrationId}'),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (bovine.isActive)
                  const Icon(Icons.check_circle, color: Colors.green)
                else
                  const Icon(Icons.cancel, color: Colors.red),
                PopupMenuButton<String>(
                  onSelected: (action) => _handleBovineAction(
                    context,
                    coordinator,
                    bovine,
                    action,
                  ),
                  itemBuilder: (context) => [
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
                          Text('Excluir'),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            onTap: () => coordinator.bovinesProvider.selectBovine(bovine),
            selected:
                coordinator.bovinesProvider.selectedBovine?.id == bovine.id,
          ),
        );
      },
    );
  }

  void _handleBovineAction(
    BuildContext context,
    LivestockCoordinatorProvider coordinator,
    BovineEntity bovine,
    String action,
  ) {
    switch (action) {
      case 'edit':
        _showEditBovineDialog(context, coordinator, bovine);
        break;
      case 'delete':
        _showDeleteConfirmation(context, coordinator, bovine);
        break;
    }
  }

  void _showAddBovineDialog(BuildContext context) {}

  void _showEditBovineDialog(
    BuildContext context,
    LivestockCoordinatorProvider coordinator,
    BovineEntity bovine,
  ) {}

  void _showDeleteConfirmation(
    BuildContext context,
    LivestockCoordinatorProvider coordinator,
    BovineEntity bovine,
  ) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar exclusão'),
        content: Text('Deseja excluir o bovino "${bovine.commonName}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await coordinator.bovinesProvider.deleteBovine(bovine.id);

              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Bovino "${bovine.commonName}" excluído'),
                  ),
                );
              }
            },
            child: const Text(
              'Excluir',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}

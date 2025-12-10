import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/bovine_entity.dart';
import '../providers/bovines_provider.dart';
import '../providers/equines_provider.dart';
import '../providers/livestock_sync_provider.dart';

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
    // Initialization is handled by Riverpod providers automatically
  }

  @override
  Widget build(BuildContext context) {
    final bovinesState = ref.watch(bovinesProvider);
    final equinesState = ref.watch(equinesProvider);
    final syncState = ref.watch(livestockSyncProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Livestock Dashboard'),
        actions: [
          IconButton(
            icon: syncState.isSyncing
                ? const CircularProgressIndicator()
                : const Icon(Icons.sync),
            onPressed: syncState.isSyncing
                ? null
                : () => ref.read(livestockSyncProvider.notifier).forceSyncNow(),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildStatisticsSection(bovinesState, equinesState),
          _buildFiltersSection(),
          Expanded(child: _buildBovinesList(bovinesState)),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddBovineDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  /// Seção de estatísticas usando provider especializado
  Widget _buildStatisticsSection(
    BovinesState bovinesState,
    EquinesState equinesState,
  ) {
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
                  '${bovinesState.bovines.length}',
                  Icons.pets,
                  Colors.blue,
                ),
                _buildStatCard(
                  'Bovinos Ativos',
                  '${bovinesState.bovines.where((b) => b.isActive).length}',
                  Icons.check_circle,
                  Colors.green,
                ),
                _buildStatCard(
                  'Equinos',
                  '${equinesState.equines.length}',
                  Icons.directions_run,
                  Colors.orange,
                ),
              ],
            ),
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
  Widget _buildFiltersSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: TextField(
          decoration: const InputDecoration(
            labelText: 'Buscar bovinos',
            prefixIcon: Icon(Icons.search),
            border: OutlineInputBorder(),
          ),
          onChanged: (query) {
            // TODO: Implement search functionality
          },
        ),
      ),
    );
  }

  /// Lista de bovinos usando provider especializado
  Widget _buildBovinesList(BovinesState bovinesState) {
    final bovines = bovinesState.bovines;

    if (bovines.isEmpty) {
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
      itemCount: bovines.length,
      itemBuilder: (context, index) {
        final bovine = bovines[index];
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
                    bovinesState,
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
            onTap: () {
              // TODO: Navigate to bovine details
            },
          ),
        );
      },
    );
  }

  void _handleBovineAction(
    BuildContext context,
    BovinesState bovinesState,
    BovineEntity bovine,
    String action,
  ) {
    switch (action) {
      case 'edit':
        _showEditBovineDialog(context, bovinesState, bovine);
        break;
      case 'delete':
        _showDeleteConfirmation(context, bovinesState, bovine);
        break;
    }
  }

  void _showAddBovineDialog(BuildContext context) {}

  void _showEditBovineDialog(
    BuildContext context,
    BovinesState bovinesState,
    BovineEntity bovine,
  ) {
    // TODO: Implement edit dialog
  }

  void _showDeleteConfirmation(
    BuildContext context,
    BovinesState bovinesState,
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
              // TODO: Implement delete functionality
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Bovino "${bovine.commonName}" excluído'),
                  ),
                );
              }
            },
            child: const Text('Excluir', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

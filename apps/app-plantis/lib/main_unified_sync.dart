import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Core imports - Sistema unificado
import 'package:core/core.dart';

// App specific imports
import 'core/plantis_sync_config.dart';

/// Main entry point usando sistema unificado de sincronização
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Configurar sistema de sincronização unificado para Plantis
  await PlantisSyncConfig.configure();
  
  runApp(const PlantisAppWithUnifiedSync());
}

class PlantisAppWithUnifiedSync extends StatelessWidget {
  const PlantisAppWithUnifiedSync({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Provider único para toda sincronização
        ChangeNotifierProvider<UnifiedSyncProvider>(
          create: (_) => UnifiedSyncProvider.instance..initializeForApp('plantis'),
        ),
      ],
      child: MaterialApp(
        title: 'Plantis - Unified Sync',
        theme: ThemeData(
          primarySwatch: Colors.green,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: const PlantisHomePage(),
      ),
    );
  }
}

/// Home page do Plantis com sistema unificado
class PlantisHomePage extends StatefulWidget {
  const PlantisHomePage({Key? key}) : super(key: key);

  @override
  State<PlantisHomePage> createState() => _PlantisHomePageState();
}

class _PlantisHomePageState extends State<PlantisHomePage>
    with SyncProviderMixin<PlantisHomePage> {

  @override
  void initState() {
    super.initState();
    // Inicializar sync provider para plantis
    initializeSyncProvider('plantis');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Plants'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        actions: [
          // Status de sincronização
          Consumer<UnifiedSyncProvider>(
            builder: (context, syncProvider, _) {
              return _buildSyncStatusIcon(syncProvider.syncStatus);
            },
          ),
          // Botão de sync manual
          IconButton(
            onPressed: _forceSync,
            icon: const Icon(Icons.sync),
            tooltip: 'Sync Plants',
          ),
        ],
      ),
      body: Column(
        children: [
          // Card com estatísticas simples
          _buildStatsCard(),
          
          // Lista de plantas
          Expanded(
            child: _buildPlantsGrid(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addPlant,
        backgroundColor: Colors.green,
        child: const Icon(Icons.add),
        tooltip: 'Add Plant',
      ),
    );
  }

  Widget _buildSyncStatusIcon(SyncStatus status) {
    switch (status) {
      case SyncStatus.synced:
        return Container(
          margin: const EdgeInsets.only(right: 8),
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: Colors.green.withOpacity(0.2),
            borderRadius: BorderRadius.circular(4),
          ),
          child: const Icon(Icons.cloud_done, color: Colors.green, size: 20),
        );
      case SyncStatus.syncing:
        return Container(
          margin: const EdgeInsets.only(right: 8),
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.2),
            borderRadius: BorderRadius.circular(4),
          ),
          child: const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
            ),
          ),
        );
      case SyncStatus.offline:
        return Container(
          margin: const EdgeInsets.only(right: 8),
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: Colors.orange.withOpacity(0.2),
            borderRadius: BorderRadius.circular(4),
          ),
          child: const Icon(Icons.cloud_off, color: Colors.orange, size: 20),
        );
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildStatsCard() {
    return Consumer<UnifiedSyncProvider>(
      builder: (context, syncProvider, _) {
        return Card(
          margin: const EdgeInsets.all(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Sync Status',
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        syncProvider.syncStatus.name.toUpperCase(),
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: _getStatusColor(syncProvider.syncStatus),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: StreamBuilder<List<Plant>>(
                    stream: streamEntities<Plant>(),
                    builder: (context, snapshot) {
                      final plantCount = snapshot.data?.length ?? 0;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            'Plants',
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '$plantCount',
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
                Expanded(
                  child: StreamBuilder<List<PlantCare>>(
                    stream: streamEntities<PlantCare>(),
                    builder: (context, snapshot) {
                      final careCount = snapshot.data?.where((c) => !c.isCompleted).length ?? 0;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'Pending Care',
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '$careCount',
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              color: careCount > 0 ? Colors.orange : Colors.green,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Color _getStatusColor(SyncStatus status) {
    switch (status) {
      case SyncStatus.synced:
        return Colors.green;
      case SyncStatus.syncing:
        return Colors.blue;
      case SyncStatus.offline:
        return Colors.orange;
      case SyncStatus.error:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Widget _buildPlantsGrid() {
    return StreamBuilder<List<Plant>>(
      stream: streamEntities<Plant>(), // Usar mixin helper
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(color: Colors.green),
                SizedBox(height: 16),
                Text('Loading your plants...'),
              ],
            ),
          );
        }
        
        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                Text(
                  'Error loading plants',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  '${snapshot.error}',
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: _forceSync,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Try Again'),
                ),
              ],
            ),
          );
        }
        
        final plants = snapshot.data ?? [];
        
        if (plants.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.local_florist_outlined,
                  size: 80,
                  color: Colors.green.withOpacity(0.5),
                ),
                const SizedBox(height: 24),
                Text(
                  'No plants yet!',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.green,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Tap the + button to add your first plant',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          );
        }
        
        return GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 0.8,
          ),
          itemCount: plants.length,
          itemBuilder: (context, index) {
            return _buildPlantCard(plants[index]);
          },
        );
      },
    );
  }

  Widget _buildPlantCard(Plant plant) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _showPlantDetails(plant),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Status indicators
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (plant.isDirty)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'SYNCING',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  if (!plant.isActive)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.grey,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'INACTIVE',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  PopupMenuButton<String>(
                    onSelected: (value) => _handlePlantAction(plant, value),
                    itemBuilder: (context) => [
                      const PopupMenuItem(value: 'care', child: Text('Add Care')),
                      const PopupMenuItem(value: 'reminder', child: Text('Set Reminder')),
                      const PopupMenuItem(value: 'edit', child: Text('Edit')),
                      const PopupMenuItem(value: 'delete', child: Text('Delete')),
                    ],
                    child: const Icon(Icons.more_vert, size: 16),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              
              // Plant icon
              Center(
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Icon(
                    _getPlantIcon(plant.species),
                    size: 32,
                    color: Colors.green,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              
              // Plant name
              Text(
                plant.name,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              
              // Plant species
              Text(
                plant.species,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const Spacer(),
              
              // Notes preview
              if (plant.notes.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    plant.notes,
                    style: Theme.of(context).textTheme.bodySmall,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getPlantIcon(String species) {
    final speciesLower = species.toLowerCase();
    if (speciesLower.contains('flower')) return Icons.local_florist;
    if (speciesLower.contains('tree')) return Icons.park;
    if (speciesLower.contains('cactus')) return Icons.filter_vintage;
    if (speciesLower.contains('fern')) return Icons.grass;
    return Icons.eco; // Default plant icon
  }

  Future<void> _forceSync() async {
    final syncProvider = Provider.of<UnifiedSyncProvider>(context, listen: false);
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
            SizedBox(width: 12),
            Text('Syncing plants...'),
          ],
        ),
        backgroundColor: Colors.blue,
      ),
    );
    
    final result = await syncProvider.forceSync();
    
    result.fold(
      (failure) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Sync failed: ${failure.message}'),
            backgroundColor: Colors.red,
          ),
        );
      },
      (_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 12),
                Text('Plants synced successfully'),
              ],
            ),
            backgroundColor: Colors.green,
          ),
        );
      },
    );
  }

  Future<void> _addPlant() async {
    final result = await showDialog<Plant>(
      context: context,
      builder: (context) => _AddPlantDialog(),
    );
    
    if (result != null) {
      final createResult = await createEntity<Plant>(result);
      
      createResult.fold(
        (failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to add plant: ${failure.message}'),
              backgroundColor: Colors.red,
            ),
          );
        },
        (id) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${result.name} added successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        },
      );
    }
  }

  void _handlePlantAction(Plant plant, String action) {
    switch (action) {
      case 'care':
        _addCare(plant);
        break;
      case 'reminder':
        _addReminder(plant);
        break;
      case 'edit':
        _editPlant(plant);
        break;
      case 'delete':
        _deletePlant(plant);
        break;
    }
  }

  Future<void> _addCare(Plant plant) async {
    final care = PlantCare(
      id: '',
      plantId: plant.id,
      careType: 'watering',
      notes: 'Added via quick action',
      isCompleted: false,
    );
    
    final result = await createEntity<PlantCare>(care);
    
    result.fold(
      (failure) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add care: ${failure.message}')),
        );
      },
      (_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Care task added for ${plant.name}')),
        );
      },
    );
  }

  Future<void> _addReminder(Plant plant) async {
    final reminder = PlantReminder(
      id: '',
      plantId: plant.id,
      title: 'Water ${plant.name}',
      reminderDate: DateTime.now().add(const Duration(days: 1)),
      isActive: true,
    );
    
    final result = await createEntity<PlantReminder>(reminder);
    
    result.fold(
      (failure) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add reminder: ${failure.message}')),
        );
      },
      (_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Reminder set for ${plant.name}')),
        );
      },
    );
  }

  Future<void> _editPlant(Plant plant) async {
    // Simulação simples de edição
    final updated = plant.copyWith(
      notes: '${plant.notes}\nEdited on ${DateTime.now().toString().substring(0, 19)}',
    );
    
    final result = await updateEntity<Plant>(plant.id, updated);
    
    result.fold(
      (failure) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update plant: ${failure.message}')),
        );
      },
      (_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${plant.name} updated successfully')),
        );
      },
    );
  }

  Future<void> _deletePlant(Plant plant) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Plant'),
        content: Text('Are you sure you want to delete ${plant.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    
    if (confirmed == true) {
      final result = await deleteEntity<Plant>(plant.id);
      
      result.fold(
        (failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to delete plant: ${failure.message}')),
          );
        },
        (_) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${plant.name} deleted successfully')),
          );
        },
      );
    }
  }

  void _showPlantDetails(Plant plant) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(plant.name),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailRow('Species', plant.species),
              _buildDetailRow('Status', plant.isActive ? 'Active' : 'Inactive'),
              _buildDetailRow('Version', plant.version.toString()),
              _buildDetailRow('Needs Sync', plant.needsSync ? 'Yes' : 'No'),
              if (plant.createdAt != null)
                _buildDetailRow('Created', plant.createdAt!.toString().substring(0, 19)),
              if (plant.lastSyncAt != null)
                _buildDetailRow('Last Sync', plant.lastSyncAt!.toString().substring(0, 19)),
              if (plant.notes.isNotEmpty) ...[
                const SizedBox(height: 12),
                const Text('Notes:', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(plant.notes),
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}

/// Dialog simples para adicionar plantas
class _AddPlantDialog extends StatefulWidget {
  @override
  State<_AddPlantDialog> createState() => _AddPlantDialogState();
}

class _AddPlantDialogState extends State<_AddPlantDialog> {
  final _nameController = TextEditingController();
  final _speciesController = TextEditingController();
  final _notesController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add New Plant'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Plant Name',
                hintText: 'e.g., My Rose',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _speciesController,
              decoration: const InputDecoration(
                labelText: 'Species',
                hintText: 'e.g., Rose, Cactus, Fern',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'Notes (optional)',
                hintText: 'Care instructions, location, etc.',
              ),
              maxLines: 3,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_nameController.text.isNotEmpty && _speciesController.text.isNotEmpty) {
              final plant = Plant(
                id: '',
                name: _nameController.text,
                species: _speciesController.text,
                notes: _notesController.text,
                isActive: true,
              );
              Navigator.of(context).pop(plant);
            }
          },
          child: const Text('Add Plant'),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _speciesController.dispose();
    _notesController.dispose();
    super.dispose();
  }
}
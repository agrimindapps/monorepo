import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Core imports - Sistema unificado
import 'package:core/core.dart';

// App specific imports
import 'core/gasometer_sync_config.dart';
import 'features/vehicles/domain/entities/vehicle_entity.dart';
import 'features/fuel/data/models/fuel_supply_model.dart';

/// Main entry point usando sistema unificado de sincronização
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Configurar sistema de sincronização unificado
  await GasometerSyncConfig.configure();
  
  runApp(const GasometerAppWithUnifiedSync());
}

class GasometerAppWithUnifiedSync extends StatelessWidget {
  const GasometerAppWithUnifiedSync({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Provider único para toda sincronização
        ChangeNotifierProvider<UnifiedSyncProvider>(
          create: (_) => UnifiedSyncProvider.instance..initializeForApp('gasometer'),
        ),
        
        // Outros providers do app podem continuar normalmente
        // Provider<VehicleService>(...),
        // Provider<FuelService>(...),
      ],
      child: MaterialApp(
        title: 'Gasometer - Unified Sync',
        home: const GasometerHomePage(),
      ),
    );
  }
}

/// Home page demonstrando uso do sistema unificado
class GasometerHomePage extends StatefulWidget {
  const GasometerHomePage({Key? key}) : super(key: key);

  @override
  State<GasometerHomePage> createState() => _GasometerHomePageState();
}

class _GasometerHomePageState extends State<GasometerHomePage> 
    with SyncProviderMixin<GasometerHomePage> {

  @override
  void initState() {
    super.initState();
    // Inicializar sync provider
    initializeSyncProvider('gasometer');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gasometer - Unified Sync'),
        actions: [
          // Status de sincronização no app bar
          Consumer<UnifiedSyncProvider>(
            builder: (context, syncProvider, _) {
              return _buildSyncStatusIcon(syncProvider.syncStatus);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Status card
          _buildSyncStatusCard(),
          
          // Vehicles section
          Expanded(
            child: _buildVehiclesList(),
          ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // Força sincronização
          FloatingActionButton.small(
            onPressed: _forceSync,
            child: const Icon(Icons.sync),
            tooltip: 'Force Sync',
          ),
          const SizedBox(height: 8),
          
          // Adiciona veículo
          FloatingActionButton(
            onPressed: _addVehicle,
            child: const Icon(Icons.add),
            tooltip: 'Add Vehicle',
          ),
        ],
      ),
    );
  }

  Widget _buildSyncStatusIcon(SyncStatus status) {
    IconData icon;
    Color color;
    
    switch (status) {
      case SyncStatus.synced:
        icon = Icons.cloud_done;
        color = Colors.green;
        break;
      case SyncStatus.syncing:
        icon = Icons.sync;
        color = Colors.blue;
        break;
      case SyncStatus.offline:
        icon = Icons.cloud_off;
        color = Colors.red;
        break;
      case SyncStatus.error:
        icon = Icons.error;
        color = Colors.orange;
        break;
      default:
        icon = Icons.cloud_queue;
        color = Colors.grey;
    }
    
    return Icon(icon, color: color);
  }

  Widget _buildSyncStatusCard() {
    return Consumer<UnifiedSyncProvider>(
      builder: (context, syncProvider, _) {
        final status = syncProvider.syncStatus;
        final debugInfo = syncProvider.debugInfo;
        
        return Card(
          margin: const EdgeInsets.all(8),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _buildSyncStatusIcon(status),
                    const SizedBox(width: 8),
                    Text(
                      'Sync Status: ${status.name.toUpperCase()}',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Local Items: ${debugInfo['local_items_count'] ?? 0}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                Text(
                  'Unsynced Items: ${debugInfo['unsynced_items_count'] ?? 0}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                Text(
                  'Last Sync: ${debugInfo['last_sync_time'] ?? 'Never'}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildVehiclesList() {
    return Card(
      margin: const EdgeInsets.all(8),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Icon(Icons.directions_car),
                const SizedBox(width: 8),
                Text(
                  'Vehicles',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
          ),
          Expanded(
            // Usar StreamBuilder com o sistema unificado
            child: StreamBuilder<List<VehicleEntity>>(
              stream: streamEntities<VehicleEntity>(), // Mixin helper
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                
                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error, size: 48, color: Colors.red),
                        const SizedBox(height: 16),
                        Text('Error: ${snapshot.error}'),
                        ElevatedButton(
                          onPressed: _forceSync,
                          child: const Text('Retry Sync'),
                        ),
                      ],
                    ),
                  );
                }
                
                final vehicles = snapshot.data ?? <VehicleEntity>[];
                
                if (vehicles.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.directions_car_outlined, size: 48),
                        SizedBox(height: 16),
                        Text('No vehicles yet'),
                        Text('Tap + to add your first vehicle'),
                      ],
                    ),
                  );
                }
                
                return ListView.builder(
                  itemCount: vehicles.length,
                  itemBuilder: (context, index) {
                    final vehicle = vehicles[index];
                    return _buildVehicleTile(vehicle);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVehicleTile(VehicleEntity vehicle) {
    return ListTile(
      leading: CircleAvatar(
        child: Text(vehicle.licensePlate.substring(0, 2)),
      ),
      title: Text(vehicle.licensePlate),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Type: ${vehicle.type.displayName}'),
          Row(
            children: [
              if (vehicle.isDirty)
                const Chip(
                  label: Text('Syncing...'),
                  backgroundColor: Colors.blue,
                  labelStyle: TextStyle(color: Colors.white, fontSize: 10),
                ),
              if (!vehicle.isDirty && vehicle.lastSyncAt != null)
                Chip(
                  label: Text('Synced ${_formatSyncTime(vehicle.lastSyncAt!)}'),
                  backgroundColor: Colors.green,
                  labelStyle: const TextStyle(color: Colors.white, fontSize: 10),
                ),
            ],
          ),
        ],
      ),
      trailing: PopupMenuButton<String>(
        onSelected: (value) => _handleVehicleAction(vehicle, value),
        itemBuilder: (context) => [
          const PopupMenuItem(value: 'edit', child: Text('Edit')),
          const PopupMenuItem(value: 'delete', child: Text('Delete')),
          const PopupMenuItem(value: 'fuel', child: Text('Add Fuel')),
        ],
      ),
      onTap: () => _showVehicleDetails(vehicle),
    );
  }

  String _formatSyncTime(DateTime syncTime) {
    final diff = DateTime.now().difference(syncTime);
    if (diff.inSeconds < 60) return '${diff.inSeconds}s ago';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  Future<void> _forceSync() async {
    final syncProvider = Provider.of<UnifiedSyncProvider>(context, listen: false);
    
    // Mostrar loading
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Syncing...')),
    );
    
    final result = await syncProvider.forceSync();
    
    result.fold(
      (failure) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Sync failed: ${failure.message}')),
        );
      },
      (_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Sync completed successfully')),
        );
      },
    );
  }

  Future<void> _addVehicle() async {
    // Simular adição de veículo
    final vehicle = VehicleEntity(
      id: '', // Será gerado automaticamente
      name: 'Veículo Teste',
      brand: 'Toyota',
      model: 'Corolla',
      year: 2023,
      color: 'Branco',
      licensePlate: 'ABC-${DateTime.now().millisecond}',
      type: VehicleType.car,
      supportedFuels: [FuelType.gasoline],
      currentOdometer: 0.0,
    );
    
    final result = await createEntity<VehicleEntity>(vehicle); // Mixin helper
    
    result.fold(
      (failure) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add vehicle: ${failure.message}')),
        );
      },
      (id) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Vehicle added successfully')),
        );
      },
    );
  }

  void _handleVehicleAction(VehicleEntity vehicle, String action) {
    switch (action) {
      case 'edit':
        _editVehicle(vehicle);
        break;
      case 'delete':
        _deleteVehicle(vehicle);
        break;
      case 'fuel':
        _addFuelRecord(vehicle);
        break;
    }
  }

  Future<void> _editVehicle(VehicleEntity vehicle) async {
    // Simular edição
    final updated = vehicle.copyWith(
      name: '${vehicle.name} (Edited)',
    );
    
    final result = await updateEntity<VehicleEntity>(vehicle.id, updated); // Mixin helper
    
    result.fold(
      (failure) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update vehicle: ${failure.message}')),
        );
      },
      (_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Vehicle updated successfully')),
        );
      },
    );
  }

  Future<void> _deleteVehicle(VehicleEntity vehicle) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Vehicle'),
        content: Text('Are you sure you want to delete ${vehicle.licensePlate}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    
    if (confirmed == true) {
      final result = await deleteEntity<VehicleEntity>(vehicle.id); // Mixin helper
      
      result.fold(
        (failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to delete vehicle: ${failure.message}')),
          );
        },
        (_) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Vehicle deleted successfully')),
          );
        },
      );
    }
  }

  Future<void> _addFuelRecord(VehicleEntity vehicle) async {
    final fuelSupply = FuelSupplyModel.create(
      vehicleId: vehicle.id,
      date: DateTime.now().millisecondsSinceEpoch,
      odometer: vehicle.currentOdometer + 100, // Simular odômetro
      liters: 50.0 + (DateTime.now().millisecond % 30), // Simular quantidade
      totalPrice: 200.0, // Simular preço
      pricePerLiter: 5.0, // Simular preço por litro
      fuelType: 0, // Gasolina
    );
    
    final result = await createEntity<FuelSupplyModel>(fuelSupply); // Mixin helper
    
    result.fold(
      (failure) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add fuel record: ${failure.message}')),
        );
      },
      (_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Fuel record added for ${vehicle.licensePlate}')),
        );
      },
    );
  }

  void _showVehicleDetails(VehicleEntity vehicle) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(vehicle.licensePlate),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Type: ${vehicle.type.displayName}'),
            Text('Version: ${vehicle.version}'),
            Text('Created: ${vehicle.createdAt?.toString() ?? 'Unknown'}'),
            Text('Updated: ${vehicle.updatedAt?.toString() ?? 'Never'}'),
            Text('Last Sync: ${vehicle.lastSyncAt?.toString() ?? 'Never'}'),
            Text('Needs Sync: ${vehicle.needsSync ? 'Yes' : 'No'}'),
            if (vehicle.metadata.isNotEmpty)
              Text('Settings: ${vehicle.metadata.length} items'),
          ],
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
}
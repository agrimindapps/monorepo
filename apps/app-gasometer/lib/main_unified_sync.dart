import 'package:core/core.dart';
import 'package:flutter/material.dart';

import 'core/gasometer_sync_config.dart';
import 'features/vehicles/domain/entities/vehicle_entity.dart';

/// Main entry point usando sistema unificado de sincronização
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Configurar sistema de sincronização unificado
  await GasometerSyncConfig.configure();
  
  runApp(const GasometerAppWithUnifiedSync());
}

class GasometerAppWithUnifiedSync extends ConsumerWidget {
  const GasometerAppWithUnifiedSync({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // TODO: Initialize sync provider using Riverpod
    // final syncProvider = ref.watch(unifiedSyncProvider);
    
    return ProviderScope(
      // TODO: Override providers as needed
      // overrides: [
      //   unifiedSyncProvider.overrideWith((ref) => UnifiedSyncProvider.instance..initializeForApp('gasometer')),
      // ],
      child: const MaterialApp(
        title: 'Gasometer - Unified Sync',
        home: GasometerHomePage(),
      ),
    );
  }
}

/// Home page demonstrando uso do sistema unificado
class GasometerHomePage extends ConsumerStatefulWidget {
  const GasometerHomePage({super.key});

  @override
  ConsumerState<GasometerHomePage> createState() => _GasometerHomePageState();
}

class _GasometerHomePageState extends ConsumerState<GasometerHomePage> {
  // TODO: Replace SyncProviderMixin with Riverpod providers

  @override
  void initState() {
    super.initState();
    // TODO: Initialize sync provider using Riverpod
    // initializeSyncProvider('gasometer');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gasometer - Unified Sync'),
        actions: [
          // Status de sincronização no app bar
          Consumer(
            builder: (context, ref, _) {
              // TODO: Watch sync provider status
              // final syncProvider = ref.watch(unifiedSyncProvider);
              // return _buildSyncStatusIcon(syncProvider.syncStatus);
              return const Icon(Icons.sync); // Placeholder
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Status card
          _buildSyncStatusCard(),
          
          // Demo buttons
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Wrap(
              spacing: 8,
              children: [
                ElevatedButton(
                  onPressed: _triggerSync,
                  child: const Text('Trigger Sync'),
                ),
                ElevatedButton(
                  onPressed: _addVehicle,
                  child: const Text('Add Vehicle'),
                ),
                ElevatedButton(
                  onPressed: _addFuelRecord,
                  child: const Text('Add Fuel Record'),
                ),
              ],
            ),
          ),
          Expanded(
            // Usar StreamBuilder com o sistema unificado
            child: StreamBuilder<List<VehicleEntity>>(
              // TODO: Replace with Riverpod stream provider
              // stream: streamEntities<VehicleEntity>(), // Mixin helper
              stream: const Stream.empty(), // Placeholder
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                
                final vehicles = snapshot.data ?? [];
                
                if (vehicles.isEmpty) {
                  return const Center(
                    child: Text('No vehicles found.\nTap "Add Vehicle" to create one.'),
                  );
                }
                
                return ListView.builder(
                  itemCount: vehicles.length,
                  itemBuilder: (context, index) {
                    final vehicle = vehicles[index];
                    return Card(
                      margin: const EdgeInsets.all(8),
                      child: ListTile(
                        title: Text(vehicle.name),
                        subtitle: Text(
                          'Year: ${vehicle.year} | Brand: ${vehicle.brand} | Model: ${vehicle.model}',
                        ),
                        trailing: PopupMenuButton<String>(
                          onSelected: (action) => _handleVehicleAction(vehicle, action),
                          itemBuilder: (context) => [
                            const PopupMenuItem(value: 'edit', child: Text('Edit')),
                            const PopupMenuItem(value: 'delete', child: Text('Delete')),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // TODO: Implement with Riverpod sync provider
  // Widget _buildSyncStatusIcon(String status) {
  //   IconData icon;
  //   Color color;
  //   
  //   switch (status) {
  //     case 'syncing':
  //       icon = Icons.sync;
  //       color = Colors.blue;
  //       break;
  //     case 'connected':
  //       icon = Icons.cloud_done;
  //       color = Colors.green;
  //       break;
  //     case 'error':
  //       icon = Icons.error;
  //       color = Colors.red;
  //       break;
  //     default:
  //       icon = Icons.cloud_queue;
  //       color = Colors.grey;
  //   }
  //   
  //   return Icon(icon, color: color);
  // }

  Widget _buildSyncStatusCard() {
    return Consumer(
      builder: (context, ref, _) {
        // TODO: Watch sync provider
        // final syncProvider = ref.watch(unifiedSyncProvider);
        // final status = syncProvider.syncStatus;
        // final debugInfo = syncProvider.debugInfo;
        
        // Placeholder values
        const status = 'idle';
        const debugInfo = 'Sync provider not implemented yet';
        
        return Card(
          margin: const EdgeInsets.all(8),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Sync Status: $status',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text('Debug: $debugInfo'),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _triggerSync() async {
    // TODO: Replace with Riverpod sync trigger
    try {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sync triggered (placeholder)')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Sync failed: $e')),
      );
    }
  }

  Future<void> _addVehicle() async {
    // TODO: Replace with Riverpod entity creation
    // Placeholder vehicle creation (commented out due to missing provider)
    // final vehicle = VehicleEntity(
    //   id: DateTime.now().millisecondsSinceEpoch.toString(),
    //   name: 'Test Vehicle ${DateTime.now().millisecond}',
    //   brand: 'Toyota',
    //   model: 'Corolla',
    //   year: 2023,
    //   licensePlate: 'ABC-1234',
    //   color: 'White',
    //   type: VehicleType.car, // Added required parameter
    //   supportedFuels: const [FuelType.gasoline],
    //   currentOdometer: 0.0,
    // );
    
    try {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vehicle added successfully (placeholder)')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add vehicle: $e')),
      );
    }
  }

  void _handleVehicleAction(VehicleEntity vehicle, String action) {
    switch (action) {
      case 'edit':
        _editVehicle(vehicle);
        break;
      case 'delete':
        _deleteVehicle(vehicle);
        break;
    }
  }

  Future<void> _editVehicle(VehicleEntity vehicle) async {
    // TODO: Replace with Riverpod entity update
    // Placeholder vehicle update (commented out due to missing provider)
    // final updated = vehicle.copyWith(
    //   name: '${vehicle.name} (Edited)',
    // );
    
    try {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vehicle updated successfully (placeholder)')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update vehicle: $e')),
      );
    }
  }

  Future<void> _deleteVehicle(VehicleEntity vehicle) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Vehicle'),
        content: Text('Are you sure you want to delete ${vehicle.name}?'),
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
      // TODO: Replace with Riverpod entity deletion
      try {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Vehicle deleted successfully (placeholder)')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete vehicle: $e')),
        );
      }
    }
  }

  Future<void> _addFuelRecord() async {
    // TODO: Replace with Riverpod entity creation
    // Placeholder fuel supply creation (commented out due to model parameter issues)
    // final fuelSupply = FuelSupplyModel(
    //   id: DateTime.now().millisecondsSinceEpoch.toString(),
    //   vehicleId: 'test-vehicle-id',
    //   date: DateTime.now().millisecondsSinceEpoch, // Fixed: should be int timestamp
    //   odometer: 12345,
    //   // Note: Check FuelSupplyModel for correct parameter names
    //   // fuelAmount: 40.0,
    //   // totalCost: 200.0,
    //   pricePerLiter: 5.0,
    //   fuelType: 0, // Gasolina
    // );
    
    try {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Fuel record added successfully (placeholder)')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add fuel record: $e')),
      );
    }
  }
}
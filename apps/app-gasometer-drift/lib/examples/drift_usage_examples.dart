import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../database/providers/providers.dart';
import '../database/repositories/repositories.dart';

/// Exemplos de uso dos repositórios e providers Drift
///
/// Este arquivo demonstra como usar os repositórios e providers
/// em diferentes cenários comuns da aplicação

// ========== EXEMPLO 1: Listar Veículos do Usuário ==========

class VehicleListScreen extends ConsumerWidget {
  const VehicleListScreen({super.key, required this.userId});

  final String userId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Assiste o stream de veículos ativos do usuário
    final vehiclesAsync = ref.watch(activeVehiclesStreamProvider(userId));

    return Scaffold(
      appBar: AppBar(title: const Text('Meus Veículos')),
      body: vehiclesAsync.when(
        data: (vehicles) {
          if (vehicles.isEmpty) {
            return const Center(child: Text('Nenhum veículo cadastrado'));
          }

          return ListView.builder(
            itemCount: vehicles.length,
            itemBuilder: (context, index) {
              final vehicle = vehicles[index];
              return ListTile(
                title: Text('${vehicle.marca} ${vehicle.modelo}'),
                subtitle: Text('Placa: ${vehicle.placa}'),
                trailing: Text('${vehicle.ano}'),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Erro: $error')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navegar para tela de adicionar veículo
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

// ========== EXEMPLO 2: Adicionar Novo Veículo ==========

class AddVehicleExample extends ConsumerWidget {
  const AddVehicleExample({super.key});

  Future<void> _addVehicle(WidgetRef ref) async {
    final repo = ref.read(vehicleRepositoryProvider);

    final newVehicle = VehicleData(
      id: 0, // Será gerado automaticamente
      userId: 'user123',
      moduleName: 'gasometer',
      createdAt: DateTime.now(),
      updatedAt: null,
      lastSyncAt: null,
      isDirty: true, // Precisa ser sincronizado
      isDeleted: false,
      version: 1,
      marca: 'Toyota',
      modelo: 'Corolla',
      ano: 2023,
      placa: 'ABC-1234',
      cor: 'Prata',
      odometroInicial: 0.0,
      odometroAtual: 15000.0,
      combustivel: 0, // Gasolina
      renavan: '12345678901',
      chassi: 'ABC123XYZ456',
      foto: null,
      vendido: false,
      valorVenda: 0.0,
    );

    try {
      final id = await repo.insert(newVehicle);
      print('Veículo adicionado com ID: $id');
    } catch (e) {
      print('Erro ao adicionar veículo: $e');
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ElevatedButton(
      onPressed: () => _addVehicle(ref),
      child: const Text('Adicionar Veículo'),
    );
  }
}

// ========== EXEMPLO 3: Listar Abastecimentos de um Veículo ==========

class FuelSuppliesScreen extends ConsumerWidget {
  const FuelSuppliesScreen({super.key, required this.vehicleId});

  final int vehicleId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final suppliesAsync = ref.watch(
      vehicleFuelSuppliesStreamProvider(vehicleId),
    );
    final totalSpentAsync = ref.watch(vehicleTotalFuelSpentProvider(vehicleId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Abastecimentos'),
        actions: [
          totalSpentAsync.when(
            data: (total) =>
                Chip(label: Text('Total: R\$ ${total.toStringAsFixed(2)}')),
            loading: () => const CircularProgressIndicator(),
            error: (_, __) => const SizedBox.shrink(),
          ),
        ],
      ),
      body: suppliesAsync.when(
        data: (supplies) {
          if (supplies.isEmpty) {
            return const Center(child: Text('Nenhum abastecimento registrado'));
          }

          return ListView.builder(
            itemCount: supplies.length,
            itemBuilder: (context, index) {
              final supply = supplies[index];
              return ListTile(
                title: Text('${supply.liters.toStringAsFixed(2)} L'),
                subtitle: Text(
                  'R\$ ${supply.totalPrice.toStringAsFixed(2)} - ${supply.dateTime.toString()}',
                ),
                trailing: supply.fullTank == true
                    ? const Icon(Icons.local_gas_station)
                    : null,
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Erro: $error')),
      ),
    );
  }
}

// ========== EXEMPLO 4: Adicionar Abastecimento ==========

class AddFuelSupplyExample extends ConsumerWidget {
  const AddFuelSupplyExample({super.key, required this.vehicleId});

  final int vehicleId;

  Future<void> _addFuelSupply(WidgetRef ref) async {
    final repo = ref.read(fuelSupplyRepositoryProvider);

    final newSupply = FuelSupplyData(
      id: 0,
      userId: 'user123',
      moduleName: 'gasometer',
      vehicleId: vehicleId,
      createdAt: DateTime.now(),
      updatedAt: null,
      lastSyncAt: null,
      isDirty: true,
      isDeleted: false,
      version: 1,
      date: DateTime.now().millisecondsSinceEpoch,
      odometer: 15500.0,
      liters: 45.5,
      pricePerLiter: 5.89,
      totalPrice: 268.0,
      fullTank: true,
      fuelType: 0, // Gasolina
      gasStationName: 'Posto Shell',
      notes: null,
      receiptImageUrl: null,
      receiptImagePath: null,
    );

    try {
      final id = await repo.insert(newSupply);
      print('Abastecimento adicionado com ID: $id');
    } catch (e) {
      print('Erro ao adicionar abastecimento: $e');
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ElevatedButton(
      onPressed: () => _addFuelSupply(ref),
      child: const Text('Adicionar Abastecimento'),
    );
  }
}

// ========== EXEMPLO 5: Dashboard com Estatísticas ==========

class VehicleDashboardScreen extends ConsumerWidget {
  const VehicleDashboardScreen({super.key, required this.vehicleId});

  final int vehicleId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vehicleAsync = ref.watch(vehicleByIdProvider(vehicleId));
    final totalFuelAsync = ref.watch(vehicleTotalFuelSpentProvider(vehicleId));
    final totalMaintenanceAsync = ref.watch(
      vehicleTotalMaintenanceCostProvider(vehicleId),
    );
    final totalExpensesAsync = ref.watch(
      vehicleTotalExpensesProvider(vehicleId),
    );
    final pendingMaintenancesAsync = ref.watch(
      pendingMaintenancesCountProvider(vehicleId),
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          vehicleAsync.when(
            data: (vehicle) => vehicle != null
                ? Card(
                    child: ListTile(
                      title: Text('${vehicle.marca} ${vehicle.modelo}'),
                      subtitle: Text('${vehicle.ano} - ${vehicle.placa}'),
                    ),
                  )
                : const SizedBox.shrink(),
            loading: () => const CircularProgressIndicator(),
            error: (_, __) => const SizedBox.shrink(),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  title: 'Combustível',
                  value: totalFuelAsync,
                  icon: Icons.local_gas_station,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _StatCard(
                  title: 'Manutenções',
                  value: totalMaintenanceAsync,
                  icon: Icons.build,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  title: 'Despesas',
                  value: totalExpensesAsync,
                  icon: Icons.payment,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: pendingMaintenancesAsync.when(
                  data: (count) => Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          const Icon(Icons.pending_actions),
                          const SizedBox(height: 8),
                          Text('$count Pendentes'),
                        ],
                      ),
                    ),
                  ),
                  loading: () => const CircularProgressIndicator(),
                  error: (_, __) => const SizedBox.shrink(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatCard extends ConsumerWidget {
  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
  });

  final String title;
  final AsyncValue<double> value;
  final IconData icon;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon),
            const SizedBox(height: 8),
            Text(title),
            const SizedBox(height: 4),
            value.when(
              data: (val) => Text(
                'R\$ ${val.toStringAsFixed(2)}',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              loading: () => const CircularProgressIndicator(),
              error: (_, __) => const Text('--'),
            ),
          ],
        ),
      ),
    );
  }
}

// ========== EXEMPLO 6: Sincronização de Dados ==========

class SyncButton extends ConsumerWidget {
  const SyncButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final syncState = ref.watch(syncStateProvider);
    final dirtyCountAsync = ref.watch(dirtyRecordsCountProvider);

    return dirtyCountAsync.when(
      data: (count) {
        if (count == 0 && !syncState.isInProgress) {
          return const Chip(
            label: Text('Sincronizado'),
            avatar: Icon(Icons.cloud_done, size: 16),
          );
        }

        return ElevatedButton.icon(
          onPressed: syncState.isInProgress
              ? null
              : () {
                  ref.read(syncStateProvider.notifier).startSync();
                },
          icon: syncState.isInProgress
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.cloud_upload),
          label: Text(
            syncState.isInProgress
                ? 'Sincronizando... ${(syncState.progress * 100).toStringAsFixed(0)}%'
                : 'Sincronizar ($count)',
          ),
        );
      },
      loading: () => const CircularProgressIndicator(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}

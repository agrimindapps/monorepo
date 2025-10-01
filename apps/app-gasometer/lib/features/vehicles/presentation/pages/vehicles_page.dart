import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

import '../../../../core/widgets/enhanced_empty_state.dart';
import '../../../../core/widgets/standard_loading_view.dart';
import '../../domain/entities/vehicle_entity.dart';
import '../providers/vehicles_notifier.dart';
import '../widgets/vehicle_card.dart';

class VehiclesPage extends ConsumerStatefulWidget {
  const VehiclesPage({super.key});

  @override
  ConsumerState<VehiclesPage> createState() => _VehiclesPageState();
}

class _VehiclesPageState extends ConsumerState<VehiclesPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meus Veículos'),
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.surface,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _navigateToAddVehicle,
            tooltip: 'Adicionar veículo',
          ),
        ],
      ),
      body: const _OptimizedVehiclesContent(),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAddVehicle,
        tooltip: 'Adicionar veículo',
        child: const Icon(Icons.add),
      ),
    );
  }

  void _navigateToAddVehicle() {
    context.push('/vehicles/add');
  }
}

class _OptimizedVehiclesContent extends ConsumerWidget {
  const _OptimizedVehiclesContent();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vehiclesAsync = ref.watch(vehiclesNotifierProvider);

    return vehiclesAsync.when(
      data: (vehicles) {
        if (vehicles.isEmpty) {
          return _buildEmptyState(context, ref);
        }
        return _buildVehiclesList(context, ref, vehicles);
      },
      loading: () => const StandardLoadingView(
        message: 'Carregando seus veículos...',
        showProgress: true,
      ),
      error: (error, stack) => EnhancedEmptyState(
        title: 'Ops! Algo deu errado',
        description: error.toString(),
        icon: Icons.error_outline,
        actionLabel: 'Tentar novamente',
        onAction: () {
          ref.read(vehiclesNotifierProvider.notifier).refresh();
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, WidgetRef ref) {
    return EnhancedEmptyState(
      title: 'Nenhum veículo cadastrado',
      description: 'Adicione seu primeiro veículo para começar a controlar seus gastos e manutenções.',
      icon: Icons.directions_car_outlined,
      actionLabel: 'Adicionar veículo',
      onAction: () => context.push('/vehicles/add'),
    );
  }

  Widget _buildVehiclesList(BuildContext context, WidgetRef ref, List<VehicleEntity> vehicles) {
    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(vehiclesNotifierProvider.notifier).refresh();
      },
      child: _buildStaggeredGrid(vehicles),
    );
  }

  Widget _buildStaggeredGrid(List<VehicleEntity> vehicles) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: StaggeredGrid.count(
        crossAxisCount: _calculateCrossAxisCount(),
        mainAxisSpacing: 16.0,
        crossAxisSpacing: 16.0,
        children: vehicles.map((vehicle) {
          return StaggeredGridTile.count(
            crossAxisCellCount: 1,
            mainAxisCellCount: 1,
            child: VehicleCard(
              vehicle: vehicle,
              onTap: () => _navigateToVehicleDetails(vehicle),
            ),
          );
        }).toList(),
      ),
    );
  }

  int _calculateCrossAxisCount() {
    // Responsividade básica baseada na largura da tela
    return 2; // Para mobile sempre 2 colunas
  }

  void _navigateToVehicleDetails(VehicleEntity vehicle) {
    // TODO: Implementar navegação para detalhes do veículo
    // context.push('/vehicles/${vehicle.id}');
  }
}
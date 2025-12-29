import 'package:core/core.dart' ;
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

import '../../../../core/enums/dialog_mode.dart';
import '../../../../core/widgets/enhanced_empty_state.dart';
import '../../../../core/widgets/semantic_widgets.dart';
import '../../../../core/widgets/standard_loading_view.dart';
import '../../domain/entities/vehicle_entity.dart';
import '../providers/vehicles_notifier.dart';
import '../widgets/vehicle_card.dart';
import 'add_vehicle_page.dart';

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
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            const Expanded(child: _OptimizedVehiclesContent()),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAddVehicle,
        tooltip: 'Adicionar veículo',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
      child: Container(
        margin: const EdgeInsets.fromLTRB(0, 0, 0, 0),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
              blurRadius: 9,
              offset: const Offset(0, 3),
              spreadRadius: 0,
            ),
          ],
        ),
        child: Row(
          children: [
            Semantics(
              label: 'Seção de veículos',
              hint: 'Página principal para gerenciar veículos',
              child: Container(
                padding: const EdgeInsets.all(9),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: const Icon(
                  Icons.directions_car,
                  color: Colors.white,
                  size: 19,
                ),
              ),
            ),
            const SizedBox(width: 13),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  SemanticText.heading(
                    'Meus Veículos',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      height: 1.2,
                    ),
                  ),
                  SizedBox(height: 3),
                  SemanticText.subtitle(
                    'Gerencie seus veículos e informações',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                      height: 1.3,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToAddVehicle() {
    showDialog<bool>(
      context: context,
      builder: (context) => const AddVehiclePage(),
    ).then((result) {
      if (result == true) {
        // Refresh vehicles list after adding
        ref.read(vehiclesProvider.notifier).refresh();
      }
    });
  }
}

class _OptimizedVehiclesContent extends ConsumerWidget {
  const _OptimizedVehiclesContent();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vehiclesAsync = ref.watch(vehiclesProvider);

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
          ref.read(vehiclesProvider.notifier).refresh();
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, WidgetRef ref) {
    return const EnhancedEmptyState(
      title: 'Nenhum veículo cadastrado',
      description:
          'Adicione seu primeiro veículo para começar a controlar seus gastos e manutenções.',
      icon: Icons.directions_car_outlined,
    );
  }

  Widget _buildVehiclesList(
    BuildContext context,
    WidgetRef ref,
    List<VehicleEntity> vehicles,
  ) {
    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(vehiclesProvider.notifier).refresh();
      },
      child: _buildStaggeredGrid(context, ref, vehicles),
    );
  }

  Widget _buildStaggeredGrid(BuildContext context, WidgetRef ref, List<VehicleEntity> vehicles) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = _calculateCrossAxisCount(constraints.maxWidth);
        return Padding(
          padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 16.0),
          child: MasonryGridView.count(
            crossAxisCount: crossAxisCount,
            mainAxisSpacing: 16.0,
            crossAxisSpacing: 16.0,
            itemCount: vehicles.length,
            itemBuilder: (context, index) {
              final vehicle = vehicles[index];
              return VehicleCard(
                vehicle: vehicle,
                onTap: () => _openVehicleDialog(context, ref, vehicle, DialogMode.view),
                onEdit: () => _openVehicleDialog(context, ref, vehicle, DialogMode.edit),
                onDelete: () => ref.read(vehiclesProvider.notifier).removeOptimistic(vehicle),
                onRestore: () => ref.read(vehiclesProvider.notifier).restoreVehicle(vehicle.id),
                enableSwipeToDelete: true,
              );
            },
          ),
        );
      },
    );
  }

  int _calculateCrossAxisCount(double width) {
    // Tela pequena (< 600px): 1 coluna
    if (width < 600) return 1;
    // Tela média (600-900px): 2 colunas
    if (width < 900) return 2;
    // Tela grande (900-1200px): 3 colunas
    if (width < 1200) return 3;
    // Tela muito grande (>= 1200px): 4 colunas
    return 4;
  }

  void _openVehicleDialog(BuildContext context, WidgetRef ref, VehicleEntity vehicle, DialogMode mode) {
    showDialog<bool>(
      context: context,
      builder: (context) => AddVehiclePage(
        vehicle: vehicle,
        initialMode: mode,
      ),
    ).then((result) {
      if (result == true) {
        ref.read(vehiclesProvider.notifier).refresh();
      }
    });
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:provider/provider.dart';

import '../../../../core/presentation/widgets/enhanced_empty_state.dart';
import '../../../../core/presentation/widgets/standard_card.dart';
import '../../../../core/theme/design_tokens.dart';
import '../../domain/entities/vehicle_entity.dart';
import '../providers/vehicles_provider.dart';
import 'add_vehicle_page.dart';

class VehiclesPage extends StatefulWidget {
  const VehiclesPage({super.key});

  @override
  State<VehiclesPage> createState() => _VehiclesPageState();
}

class _VehiclesPageState extends State<VehiclesPage> {
  @override
  void initState() {
    super.initState();
    // Inicializar provider de forma lazy
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<VehiclesProvider>().initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerLowest,
      body: SafeArea(
        child: Column(
          children: [
            // Header fixo otimizado
            _OptimizedHeader(),
            
            // Conteúdo com scroll
            Expanded(
              child: SingleChildScrollView(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1200),
                    child: Padding(
                      padding: GasometerDesignTokens.paddingAll(GasometerDesignTokens.spacingPagePadding),
                      child: _OptimizedVehiclesContent(),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: _OptimizedFloatingActionButton(),
    );
  }

  // Widget removido - agora usando _OptimizedHeader

  // Widget removido - agora usando _OptimizedVehiclesContent

  // Widget removido - agora usando _OptimizedVehiclesContent

  // Widget removido - agora usando _OptimizedVehiclesContent

  // Widget removido - agora usando _OptimizedVehiclesContent

  // Widget removido - agora usando componentes otimizados

  // Widget removido - agora usando componentes otimizados

  // Widget removido - agora usando componentes otimizados

  // Widget removido - agora usando componentes otimizados

  // Widget removido - agora usando componentes otimizados

  // Widget removido - agora usando _OptimizedFloatingActionButton

  // Método removido - agora usando provider

  // Método removido - agora usando provider

  // Método removido - agora usando provider
}

/// Header otimizado com Selector para performance
class _OptimizedHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Color(0xFF2C2C2E),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.directions_car,
                color: Colors.white,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Veículos',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    'Gerencie sua frota de veículos',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Conteúdo principal otimizado com Selector
class _OptimizedVehiclesContent extends StatelessWidget {
  
  Future<void> _navigateToAddVehicle(BuildContext context) async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (context) => const AddVehiclePage(),
      ),
    );
    
    // Se resultado for true, atualizar lista
    if (result == true && context.mounted) {
      await context.read<VehiclesProvider>().loadVehicles();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Selector<VehiclesProvider, (bool, bool, List<VehicleEntity>, String?)>(
      selector: (context, provider) => (
        provider.isLoading,
        provider.isInitialized,
        provider.vehicles,
        provider.errorMessage,
      ),
      builder: (context, data, child) {
        final (isLoading, isInitialized, vehicles, errorMessage) = data;
        
        if (!isInitialized || isLoading) {
          return _LoadingState();
        }
        
        if (errorMessage != null) {
          return _ErrorState(errorMessage: errorMessage);
        }
        
        if (vehicles.isEmpty) {
          return EnhancedEmptyState.generic(
            icon: Icons.directions_car_outlined,
            title: 'Nenhum veículo cadastrado',
            description: 'Cadastre seu primeiro veículo para começar a controlar seus gastos com combustível e manutenção',
            actionLabel: 'Cadastrar Veículo',
            onAction: () => _navigateToAddVehicle(context),
            height: MediaQuery.of(context).size.height - 200,
          );
        }
        
        return _VehicleGrid(vehicles: vehicles);
      },
    );
  }
}

/// Estado de carregamento otimizado
class _LoadingState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 300,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 16),
            Text(
              'Carregando veículos...',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Estado de erro otimizado
class _ErrorState extends StatelessWidget {
  final String errorMessage;
  
  const _ErrorState({required this.errorMessage});
  
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 300,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              color: Theme.of(context).colorScheme.error,
              size: 64,
            ),
            const SizedBox(height: 16),
            Text(
              'Erro ao carregar veículos',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.error,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              errorMessage,
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => context.read<VehiclesProvider>().loadVehicles(),
              icon: const Icon(Icons.refresh),
              label: const Text('Tentar novamente'),
            ),
          ],
        ),
      ),
    );
  }
}


/// Grid de veículos otimizado
class _VehicleGrid extends StatelessWidget {
  final List<VehicleEntity> vehicles;
  
  const _VehicleGrid({required this.vehicles});
  
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        int crossAxisCount = 1;
        if (constraints.maxWidth > 1200) {
          crossAxisCount = 3;
        } else if (constraints.maxWidth > 800) {
          crossAxisCount = 2;
        }

        return AlignedGridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: crossAxisCount,
          mainAxisSpacing: GasometerDesignTokens.spacingLg,
          crossAxisSpacing: GasometerDesignTokens.spacingLg,
          itemCount: vehicles.length,
          itemBuilder: (context, index) {
            return _OptimizedVehicleCard(vehicle: vehicles[index]);
          },
        );
      },
    );
  }
}

/// Card de veículo otimizado
class _OptimizedVehicleCard extends StatelessWidget {
  final VehicleEntity vehicle;
  
  const _OptimizedVehicleCard({required this.vehicle});
  
  @override
  Widget build(BuildContext context) {
    return StandardCard.standard(
      child: Column(
        children: [
          _VehicleCardHeader(vehicle: vehicle),
          Divider(
            height: 1,
            color: Theme.of(context).colorScheme.outlineVariant,
          ),
          _VehicleCardContent(vehicle: vehicle),
          _VehicleCardActions(vehicle: vehicle),
        ],
      ),
    );
  }
}

/// Header do card de veículo
class _VehicleCardHeader extends StatelessWidget {
  final VehicleEntity vehicle;
  
  const _VehicleCardHeader({required this.vehicle});
  
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: GasometerDesignTokens.paddingAll(
        GasometerDesignTokens.spacingLg,
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: GasometerDesignTokens.iconSizeAvatar / 2,
            backgroundColor: Theme.of(context).colorScheme.primary.withValues(
              alpha: GasometerDesignTokens.opacityOverlay,
            ),
            child: Icon(
              Icons.directions_car,
              color: Theme.of(context).colorScheme.primary,
              size: GasometerDesignTokens.iconSizeListItem,
            ),
          ),
          SizedBox(width: GasometerDesignTokens.spacingMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${vehicle.brand} ${vehicle.model}',
                  style: TextStyle(
                    fontSize: GasometerDesignTokens.fontSizeLg,
                    fontWeight: GasometerDesignTokens.fontWeightBold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '${vehicle.year} • ${vehicle.color}',
                  style: TextStyle(
                    fontSize: GasometerDesignTokens.fontSizeMd,
                    color: Theme.of(context).colorScheme.onSurface.withValues(
                      alpha: GasometerDesignTokens.opacitySecondary,
                    ),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Conteúdo do card de veículo
class _VehicleCardContent extends StatelessWidget {
  final VehicleEntity vehicle;
  
  const _VehicleCardContent({required this.vehicle});
  
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: GasometerDesignTokens.paddingAll(
        GasometerDesignTokens.spacingLg,
      ),
      child: Column(
        children: [
          CardInfoRow(
            label: 'Placa',
            value: vehicle.licensePlate,
            icon: Icons.credit_card,
          ),
          SizedBox(height: GasometerDesignTokens.spacingMd),
          CardInfoRow(
            label: 'Combustível',
            value: vehicle.supportedFuels.map((f) => f.displayName).join(', '),
            icon: Icons.local_gas_station,
          ),
          SizedBox(height: GasometerDesignTokens.spacingMd),
          CardInfoRow(
            label: 'Km Inicial',
            value: '${vehicle.currentOdometer.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')} km',
            icon: Icons.speed,
          ),
          SizedBox(height: GasometerDesignTokens.spacingMd),
          CardInfoRow(
            label: 'Km Atual',
            value: '${vehicle.currentOdometer.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')} km',
            icon: Icons.trending_up,
          ),
        ],
      ),
    );
  }
}


/// Ações do card de veículo
class _VehicleCardActions extends StatelessWidget {
  final VehicleEntity vehicle;
  
  const _VehicleCardActions({required this.vehicle});
  
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: GasometerDesignTokens.paddingOnly(
        left: GasometerDesignTokens.spacingSm,
        right: GasometerDesignTokens.spacingSm,
        top: GasometerDesignTokens.spacingXs,
        bottom: GasometerDesignTokens.spacingXs,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          TextButton.icon(
            icon: Icon(Icons.edit, size: GasometerDesignTokens.iconSizeXs),
            label: const Text('Editar'),
            onPressed: () => _editVehicle(context, vehicle),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.primary,
              padding: GasometerDesignTokens.paddingOnly(
                left: GasometerDesignTokens.spacingMd,
                right: GasometerDesignTokens.spacingMd,
                top: GasometerDesignTokens.spacingSm,
                bottom: GasometerDesignTokens.spacingSm,
              ),
            ),
          ),
          TextButton.icon(
            icon: Icon(Icons.delete, size: GasometerDesignTokens.iconSizeXs),
            label: const Text('Excluir'),
            onPressed: () => _deleteVehicle(context, vehicle),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
              padding: GasometerDesignTokens.paddingOnly(
                left: GasometerDesignTokens.spacingMd,
                right: GasometerDesignTokens.spacingMd,
                top: GasometerDesignTokens.spacingSm,
                bottom: GasometerDesignTokens.spacingSm,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  void _editVehicle(BuildContext context, VehicleEntity vehicle) async {
    // Converter VehicleEntity para Map para compatibilidade com AddVehiclePage
    final vehicleMap = {
      'id': vehicle.id,
      'marca': vehicle.brand,
      'modelo': vehicle.model,
      'ano': vehicle.year,
      'cor': vehicle.color,
      'placa': vehicle.licensePlate,
      'chassi': vehicle.metadata['chassi'] ?? '',
      'renavam': vehicle.metadata['renavam'] ?? '',
      'odometroInicial': vehicle.currentOdometer,
      'combustivel': vehicle.supportedFuels.isNotEmpty ? vehicle.supportedFuels.first.displayName : 'Gasolina',
    };
    
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (context) => AddVehiclePage(vehicle: vehicleMap),
      ),
    );
    
    // Se resultado for true, atualizar lista
    if (result == true && context.mounted) {
      await context.read<VehiclesProvider>().loadVehicles();
    }
  }
  
  void _deleteVehicle(BuildContext context, VehicleEntity vehicle) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Confirmar exclusão'),
        content: Text(
          'Tem certeza que deseja excluir o veículo ${vehicle.brand} ${vehicle.model}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(dialogContext).pop();
              final success = await context.read<VehiclesProvider>().deleteVehicle(vehicle.id);
              if (success && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Veículo excluído com sucesso'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            style: TextButton.styleFrom(foregroundColor: Theme.of(context).colorScheme.error),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
  }
}

/// FloatingActionButton otimizado
class _OptimizedFloatingActionButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () => _addVehicle(context),
      backgroundColor: Theme.of(context).colorScheme.primary,
      foregroundColor: Theme.of(context).colorScheme.onPrimary,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      tooltip: 'Cadastrar novo veículo',
      child: const Icon(Icons.add),
    );
  }
  
  void _addVehicle(BuildContext context) async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (context) => const AddVehiclePage(),
      ),
    );
    
    // Se resultado for true, atualizar lista
    if (result == true && context.mounted) {
      await context.read<VehiclesProvider>().loadVehicles();
    }
  }
}

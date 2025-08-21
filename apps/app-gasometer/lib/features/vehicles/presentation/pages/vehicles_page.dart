import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:provider/provider.dart';
import '../providers/vehicles_provider.dart';
import '../../domain/entities/vehicle_entity.dart';
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
                      padding: const EdgeInsets.all(16.0),
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
    return Selector<VehiclesProvider, (bool, int)>(
      selector: (context, provider) => (provider.isLoading, provider.vehicleCount),
      builder: (context, data, child) {
        final (isLoading, vehicleCount) = data;
        
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).shadowColor.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1200),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.directions_car,
                      color: Theme.of(context).colorScheme.primary,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Meus Veículos',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        Text(
                          vehicleCount == 0 
                            ? 'Nenhum veículo cadastrado'
                            : '$vehicleCount veículo${vehicleCount == 1 ? '' : 's'} cadastrado${vehicleCount == 1 ? '' : 's'}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isLoading)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: 12,
                            height: 12,
                            child: CircularProgressIndicator(
                              strokeWidth: 1.5,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Carregando...',
                            style: TextStyle(
                              fontSize: 12,
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Conteúdo principal otimizado com Selector
class _OptimizedVehiclesContent extends StatelessWidget {
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
          return _EmptyState();
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

/// Estado vazio otimizado
class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height - 200,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.directions_car_outlined,
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4),
              size: 64,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Nenhum veículo cadastrado',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Cadastre seu primeiro veículo para começar',
            style: TextStyle(
              fontSize: 14,
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ],
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
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
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
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: Theme.of(context).colorScheme.outlineVariant,
          width: 1,
        ),
      ),
      color: Theme.of(context).colorScheme.surface,
      child: Column(
        children: [
          _VehicleCardHeader(vehicle: vehicle),
          const Divider(height: 1),
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
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
            child: Icon(
              Icons.directions_car,
              color: Theme.of(context).colorScheme.primary,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${vehicle.brand} ${vehicle.model}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '${vehicle.year} • ${vehicle.color}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
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
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _InfoRow(
            label: 'Placa',
            value: vehicle.licensePlate,
            icon: Icons.credit_card,
          ),
          const SizedBox(height: 12),
          _InfoRow(
            label: 'Combustível',
            value: vehicle.supportedFuels.map((f) => f.displayName).join(', '),
            icon: Icons.local_gas_station,
          ),
          const SizedBox(height: 12),
          _InfoRow(
            label: 'Km Inicial',
            value: '${vehicle.currentOdometer.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')} km',
            icon: Icons.speed,
          ),
          const SizedBox(height: 12),
          _InfoRow(
            label: 'Km Atual',
            value: '${vehicle.currentOdometer.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')} km',
            icon: Icons.trending_up,
          ),
        ],
      ),
    );
  }
}

/// Row de informação otimizada
class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  
  const _InfoRow({
    required this.label,
    required this.value,
    required this.icon,
  });
  
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 14,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ],
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
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          TextButton.icon(
            icon: const Icon(Icons.edit, size: 16),
            label: const Text('Editar'),
            onPressed: () => _editVehicle(context, vehicle),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.primary,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
          ),
          TextButton.icon(
            icon: const Icon(Icons.delete, size: 16),
            label: const Text('Excluir'),
            onPressed: () => _deleteVehicle(context, vehicle),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
    
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AddVehiclePage(vehicle: vehicleMap),
      ),
    );
    
    // Se resultado for true, atualizar lista
    if (result == true && context.mounted) {
      await context.read<VehiclesProvider>().loadVehicles();
    }
  }
  
  void _deleteVehicle(BuildContext context, VehicleEntity vehicle) {
    showDialog(
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
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const AddVehiclePage(),
      ),
    );
    
    // Se resultado for true, atualizar lista
    if (result == true && context.mounted) {
      await context.read<VehiclesProvider>().loadVehicles();
    }
  }
}

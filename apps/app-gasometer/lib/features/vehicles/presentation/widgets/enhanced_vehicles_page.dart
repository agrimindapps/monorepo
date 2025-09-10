/// Enhanced vehicles page with responsive design
/// Demonstrates the new responsive layout system with desktop/mobile adaptations
library enhanced_vehicles_page;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../pages/add_vehicle_page.dart';
import '../providers/vehicles_provider.dart';
import '../../domain/entities/vehicle_entity.dart';
import '../../../../core/constants/responsive_constants.dart';
import '../../../../core/presentation/widgets/enhanced_empty_state.dart';
import '../../../../core/presentation/widgets/responsive_content_area.dart';
import '../../../../core/presentation/widgets/standard_loading_view.dart';
import '../../../../shared/widgets/adaptive_main_navigation.dart';

/// Enhanced responsive vehicles page
class EnhancedVehiclesPage extends StatefulWidget {
  const EnhancedVehiclesPage({super.key});

  @override
  State<EnhancedVehiclesPage> createState() => _EnhancedVehiclesPageState();
}

class _EnhancedVehiclesPageState extends State<EnhancedVehiclesPage> {
  late final VehiclesProvider _vehiclesProvider;
  
  @override
  void initState() {
    super.initState();
    _vehiclesProvider = context.read<VehiclesProvider>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _vehiclesProvider.initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerLowest,
      body: SafeArea(
        child: Column(
          children: [
            // Mobile header - only show on mobile
            if (ResponsiveLayout.isMobile(context))
              _MobileHeader(),
            
            // Desktop/Tablet content with responsive container
            Expanded(
              child: ResponsiveContentArea(
                child: Column(
                  children: [
                    // Desktop header
                    if (!ResponsiveLayout.isMobile(context))
                      ResponsivePageHeader(
                        title: 'Gerenciamento de Veículos',
                        subtitle: 'Controle sua frota de veículos',
                        icon: Icons.directions_car,
                        actions: [
                          _AddVehicleButton(),
                        ],
                      ),
                    
                    Expanded(
                      child: _ResponsiveVehiclesList(),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: AdaptiveFloatingActionButton(
        onPressed: _addVehicle,
        tooltip: 'Cadastrar novo veículo',
        child: const Icon(Icons.add),
      ),
    );
  }
  
  void _addVehicle() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => const AddVehiclePage(),
    );
    
    if (result == true && mounted) {
      await _vehiclesProvider.loadVehicles();
    }
  }
}

/// Mobile header component
class _MobileHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AdaptiveSpacing.md(context)),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(AdaptiveSpacing.lg(context)),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Theme.of(context).colorScheme.primary,
              Theme.of(context).colorScheme.primary.withValues(alpha: 0.8),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(AdaptiveSpacing.md(context)),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.directions_car,
                color: Colors.white,
                size: 28,
              ),
            ),
            SizedBox(width: AdaptiveSpacing.md(context)),
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

/// Add vehicle button for desktop header
class _AddVehicleButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () => _addVehicle(context),
      icon: const Icon(Icons.add),
      label: const Text('Novo Veículo'),
      style: ElevatedButton.styleFrom(
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        padding: EdgeInsets.symmetric(
          horizontal: AdaptiveSpacing.lg(context),
          vertical: AdaptiveSpacing.md(context),
        ),
      ),
    );
  }
  
  void _addVehicle(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => const AddVehiclePage(),
    );
    
    if (result == true && context.mounted) {
      await context.read<VehiclesProvider>().loadVehicles();
    }
  }
}

/// Responsive vehicles list with adaptive grid
class _ResponsiveVehiclesList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Selector<VehiclesProvider, Map<String, dynamic>>(
      selector: (context, provider) => {
        'isLoading': provider.isLoading,
        'isInitialized': provider.isInitialized,
        'vehicles': provider.vehicles,
        'errorMessage': provider.errorMessage,
      },
      builder: (context, data, child) {
        final isLoading = data['isLoading'] as bool;
        final isInitialized = data['isInitialized'] as bool;
        final vehicles = data['vehicles'] as List<VehicleEntity>;
        final errorMessage = data['errorMessage'] as String?;
        
        if (!isInitialized) {
          return StandardLoadingView.initial(
            message: 'Carregando veículos...',
            height: 300,
          );
        }
        
        if (errorMessage != null) {
          return _ErrorState(errorMessage: errorMessage);
        }
        
        if (isLoading && vehicles.isEmpty) {
          return StandardLoadingView.refresh(message: 'Carregando...');
        }
        
        if (vehicles.isEmpty) {
          return EnhancedEmptyState.generic(
            icon: Icons.directions_car_outlined,
            title: 'Nenhum veículo cadastrado',
            description: 'Cadastre seu primeiro veículo para começar a controlar seus gastos',
            actionLabel: 'Cadastrar Veículo',
            onAction: () => _addVehicle(context),
            height: MediaQuery.of(context).size.height - 300,
          );
        }
        
        return _ResponsiveVehiclesGrid(vehicles: vehicles);
      },
    );
  }
  
  void _addVehicle(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => const AddVehiclePage(),
    );
    
    if (result == true && context.mounted) {
      await context.read<VehiclesProvider>().loadVehicles();
    }
  }
}

/// Responsive grid that adapts to screen size and uses full width available (1120px)
class _ResponsiveVehiclesGrid extends StatelessWidget {
  final List<VehicleEntity> vehicles;
  
  const _ResponsiveVehiclesGrid({required this.vehicles});
  
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = ResponsiveBreakpoints.getGridColumns(constraints.maxWidth);
        final spacing = AdaptiveSpacing.md(context);
        
        // Calcular largura efetiva para distribuir uniformemente na largura total
        final double availableWidth = constraints.maxWidth;
        final double totalSpacing = (columns - 1) * spacing + (2 * spacing); // spacing lateral
        final double effectiveWidth = availableWidth - totalSpacing;
        final double cardWidth = effectiveWidth / columns;
        
        return GridView.builder(
          padding: EdgeInsets.all(spacing),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            mainAxisSpacing: spacing,
            crossAxisSpacing: spacing,
            childAspectRatio: ResponsiveLayout.isDesktop(context) ? 1.1 : 1.2,
          ),
          itemCount: vehicles.length,
          itemBuilder: (context, index) {
            return SizedBox(
              width: cardWidth,
              child: _ResponsiveVehicleCard(
                key: ValueKey(vehicles[index].id),
                vehicle: vehicles[index],
              ),
            );
          },
        );
      },
    );
  }
}

/// Enhanced vehicle card with responsive design
class _ResponsiveVehicleCard extends StatelessWidget {
  final VehicleEntity vehicle;
  
  const _ResponsiveVehicleCard({
    super.key, 
    required this.vehicle,
  });
  
  @override
  Widget build(BuildContext context) {
    final isDesktop = ResponsiveLayout.isDesktop(context);
    
    return ResponsiveCard(
      padding: EdgeInsets.all(AdaptiveSpacing.md(context)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Vehicle header with icon and info
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(AdaptiveSpacing.sm(context)),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.directions_car,
                  color: Theme.of(context).colorScheme.primary,
                  size: isDesktop ? 24 : 20,
                ),
              ),
              SizedBox(width: AdaptiveSpacing.sm(context)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${vehicle.brand} ${vehicle.model}',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: isDesktop ? 16 : 14,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      '${vehicle.year} • ${vehicle.color}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                        fontSize: isDesktop ? 14 : 12,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          SizedBox(height: AdaptiveSpacing.md(context)),
          
          // Vehicle details
          Expanded(
            child: Column(
              children: [
                _InfoRow(
                  icon: Icons.credit_card,
                  label: 'Placa',
                  value: vehicle.licensePlate,
                ),
                SizedBox(height: AdaptiveSpacing.xs(context)),
                _InfoRow(
                  icon: Icons.local_gas_station,
                  label: 'Combustível',
                  value: vehicle.supportedFuels.map((f) => f.displayName).join(', '),
                ),
                SizedBox(height: AdaptiveSpacing.xs(context)),
                _InfoRow(
                  icon: Icons.speed,
                  label: 'Km Atual',
                  value: '${_formatNumber(vehicle.currentOdometer)} km',
                ),
                const Spacer(),
                
                // Action buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    TextButton.icon(
                      onPressed: () => _editVehicle(context, vehicle),
                      icon: const Icon(Icons.edit, size: 16),
                      label: const Text('Editar'),
                      style: TextButton.styleFrom(
                        foregroundColor: Theme.of(context).colorScheme.primary,
                        padding: EdgeInsets.symmetric(
                          horizontal: AdaptiveSpacing.sm(context),
                        ),
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () => _deleteVehicle(context, vehicle),
                      icon: const Icon(Icons.delete, size: 16),
                      label: const Text('Excluir'),
                      style: TextButton.styleFrom(
                        foregroundColor: Theme.of(context).colorScheme.error,
                        padding: EdgeInsets.symmetric(
                          horizontal: AdaptiveSpacing.sm(context),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  String _formatNumber(num number) {
    return number.toInt().toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), 
      (Match m) => '${m[1]}.',
    );
  }
  
  void _editVehicle(BuildContext context, VehicleEntity vehicle) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AddVehiclePage(vehicle: vehicle),
    );
    
    if (result == true && context.mounted) {
      await context.read<VehiclesProvider>().loadVehicles();
    }
  }
  
  void _deleteVehicle(BuildContext context, VehicleEntity vehicle) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Confirmar exclusão'),
        content: Text('Tem certeza que deseja excluir o veículo ${vehicle.brand} ${vehicle.model}?'),
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

/// Info row widget for vehicle details
class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
        ),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

/// Error state widget
class _ErrorState extends StatelessWidget {
  final String errorMessage;
  
  const _ErrorState({required this.errorMessage});
  
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            color: Theme.of(context).colorScheme.error,
            size: 64,
          ),
          SizedBox(height: AdaptiveSpacing.md(context)),
          Text(
            'Erro ao carregar veículos',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Theme.of(context).colorScheme.error,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: AdaptiveSpacing.sm(context)),
          Text(
            errorMessage,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: AdaptiveSpacing.lg(context)),
          ElevatedButton.icon(
            onPressed: () => context.read<VehiclesProvider>().loadVehicles(),
            icon: const Icon(Icons.refresh),
            label: const Text('Tentar novamente'),
          ),
        ],
      ),
    );
  }
}
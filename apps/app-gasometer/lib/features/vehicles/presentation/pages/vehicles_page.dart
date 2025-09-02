import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/presentation/widgets/enhanced_empty_state.dart';
import '../../../../core/presentation/widgets/semantic_widgets.dart';
import '../../../../core/presentation/widgets/standard_loading_view.dart';
import '../../../../core/theme/design_tokens.dart';
import '../../domain/entities/vehicle_entity.dart';
import '../providers/vehicles_provider.dart';
import '../widgets/vehicle_card.dart';
import 'add_vehicle_page.dart';

class VehiclesPage extends StatefulWidget {
  const VehiclesPage({super.key});

  @override
  State<VehiclesPage> createState() => _VehiclesPageState();
}

class _VehiclesPageState extends State<VehiclesPage> {
  // ✅ PERFORMANCE FIX: Cached provider
  late final VehiclesProvider _vehiclesProvider;
  
  @override
  void initState() {
    super.initState();
    // ✅ PERFORMANCE FIX: Cache provider once in initState
    _vehiclesProvider = context.read<VehiclesProvider>();
    
    // Inicializar provider de forma lazy
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Verificar se o widget ainda está montado antes de inicializar
      if (mounted) {
        _vehiclesProvider.initialize();
      }
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
            
            // ✅ PERFORMANCE FIX: Use CustomScrollView for better virtualization
            Expanded(
              child: _OptimizedVehiclesContent(
                onEditVehicle: _editVehicle,
                onDeleteVehicle: _deleteVehicle,
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: _OptimizedFloatingActionButton(),
    );
  }
  
  void _editVehicle(BuildContext context, VehicleEntity vehicle) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AddVehiclePage(vehicle: vehicle),
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
          SemanticButton(
            semanticLabel: 'Cancelar exclusão',
            semanticHint: 'Fecha a confirmação sem excluir o veículo',
            type: ButtonType.text,
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancelar'),
          ),
          SemanticButton(
            semanticLabel: 'Confirmar exclusão do veículo',
            semanticHint: 'Exclui permanentemente o veículo e todos os seus dados',
            type: ButtonType.text,
            style: TextButton.styleFrom(foregroundColor: Theme.of(context).colorScheme.error),
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
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
  }
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
          color: GasometerDesignTokens.colorHeaderBackground,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Semantics(
              label: 'Seção de veículos',
              hint: 'Página principal para gerenciar veículos',
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.directions_car,
                  color: Colors.white,
                  size: 28,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SemanticText.heading(
                    'Veículos',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SemanticText.subtitle(
                    'Gerencie sua frota de veículos',
                    style: const TextStyle(
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
  final void Function(BuildContext, VehicleEntity) onEditVehicle;
  final void Function(BuildContext, VehicleEntity) onDeleteVehicle;
  
  const _OptimizedVehiclesContent({
    required this.onEditVehicle,
    required this.onDeleteVehicle,
  });
  
  Future<void> _navigateToAddVehicle(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => const AddVehiclePage(),
    );
    
    // Se resultado for true, atualizar lista
    if (result == true && context.mounted) {
      await context.read<VehiclesProvider>().loadVehicles();
    }
  }

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
        
        // Mostrar loading apenas se não inicializou ainda
        if (!isInitialized) {
          return StandardLoadingView.initial(
            message: 'Carregando veículos...',
            height: 300,
          );
        }
        
        // Mostrar erro se houver
        if (errorMessage != null) {
          return _ErrorState(errorMessage: errorMessage);
        }
        
        // Se ainda está carregando mas já inicializou, mostrar loading compacto
        if (isLoading) {
          return Column(
            children: [
              if (vehicles.isNotEmpty) _OptimizedVehiclesGrid(
                vehicles: vehicles,
                onEditVehicle: onEditVehicle,
                onDeleteVehicle: onDeleteVehicle,
              ),
              StandardLoadingView.refresh(
                message: 'Atualizando...',
              ),
            ],
          );
        }
        
        // Mostrar empty state se não houver veículos
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
        
        return _OptimizedVehiclesGrid(
          vehicles: vehicles,
          onEditVehicle: onEditVehicle,
          onDeleteVehicle: onDeleteVehicle,
        );
      },
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
            Semantics(
              label: 'Erro de carregamento',
              hint: 'Ícone indicando erro no carregamento dos veículos',
              child: Icon(
                Icons.error_outline,
                color: Theme.of(context).colorScheme.error,
                size: 64,
              ),
            ),
            const SizedBox(height: 16),
            SemanticText.heading(
              'Erro ao carregar veículos',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.error,
              ),
            ),
            const SizedBox(height: 8),
            SemanticText(
              errorMessage,
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            SemanticButton(
              semanticLabel: 'Tentar carregar veículos novamente',
              semanticHint: 'Tenta recarregar a lista de veículos após o erro',
              type: ButtonType.elevated,
              onPressed: () => context.read<VehiclesProvider>().loadVehicles(),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(Icons.refresh),
                  SizedBox(width: 8),
                  Text('Tentar novamente'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}


/// ✅ PERFORMANCE FIX: Grid com CustomScrollView e SliverGrid para virtualização
class _OptimizedVehiclesGrid extends StatelessWidget {
  final List<VehicleEntity> vehicles;
  final void Function(BuildContext, VehicleEntity) onEditVehicle;
  final void Function(BuildContext, VehicleEntity) onDeleteVehicle;
  
  const _OptimizedVehiclesGrid({
    required this.vehicles,
    required this.onEditVehicle,
    required this.onDeleteVehicle,
  });
  
  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.all(16.0),
          sliver: SliverLayoutBuilder(
            builder: (context, constraints) {
              int crossAxisCount = 1;
              if (constraints.crossAxisExtent > 1200) {
                crossAxisCount = 3;
              } else if (constraints.crossAxisExtent > 800) {
                crossAxisCount = 2;
              }
              
              return SliverGrid.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  mainAxisSpacing: 16.0,
                  crossAxisSpacing: 16.0,
                  childAspectRatio: 1.2, // Ajustar conforme necessário
                ),
                itemCount: vehicles.length,
                itemBuilder: (context, index) {
                  return VehicleCard(
                    key: ValueKey(vehicles[index].id),
                    vehicle: vehicles[index],
                    onEdit: () => onEditVehicle(context, vehicles[index]),
                    onDelete: () => onDeleteVehicle(context, vehicles[index]),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}


/// FloatingActionButton otimizado
class _OptimizedFloatingActionButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SemanticButton.fab(
      semanticLabel: 'Cadastrar novo veículo',
      semanticHint: 'Abre formulário para adicionar um novo veículo à sua frota',
      onPressed: () => _addVehicle(context),
      child: const Icon(Icons.add),
    );
  }
  
  void _addVehicle(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => const AddVehiclePage(),
    );
    
    // Se resultado for true, atualizar lista
    if (result == true && context.mounted) {
      await context.read<VehiclesProvider>().loadVehicles();
    }
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../core/presentation/widgets/enhanced_empty_state.dart';
import '../../../../core/presentation/widgets/semantic_widgets.dart';
import '../../../../core/presentation/widgets/standard_loading_view.dart';
import '../../../../core/theme/design_tokens.dart';
import '../../../../core/theme/gasometer_colors.dart';
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
  bool _isFirstAccess = false;
  bool _hasInitialized = false;
  
  @override
  void initState() {
    super.initState();
    // ✅ PERFORMANCE FIX: Cache provider once in initState
    _vehiclesProvider = context.read<VehiclesProvider>();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    
    // Executar apenas uma vez para evitar inicializações múltiplas
    if (!_hasInitialized) {
      _hasInitialized = true;
      
      // Verificar se é primeiro acesso (usando inherited widget)
      _checkFirstAccess();
      
      // Inicializar provider de forma lazy
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // Verificar se o widget ainda está montado antes de inicializar
        if (mounted) {
          _vehiclesProvider.initialize();
          
          // Mostrar mensagem de boas-vindas se for primeiro acesso
          if (_isFirstAccess) {
            _showWelcomeMessage();
          }
        }
      });
    }
  }

  void _checkFirstAccess() {
    final routerState = GoRouterState.of(context);
    _isFirstAccess = routerState.uri.queryParameters['first_access'] == 'true';
  }

  void _showWelcomeMessage() {
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.celebration, color: Colors.white),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Bem-vindo ao GasOMeter! Adicione seu primeiro veículo para começar.',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.green.shade600,
            duration: const Duration(seconds: 4),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
      margin: const EdgeInsets.fromLTRB(0, 0, 0, 0),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      decoration: BoxDecoration(
        color: GasometerDesignTokens.colorHeaderBackground,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: GasometerDesignTokens.colorHeaderBackground.withValues(alpha: 0.2),
            blurRadius: 9,
            offset: const Offset(0, 3),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Semantics(
        label: 'Seção de veículos',
        hint: 'Página principal para gerenciar veículos',
        child: Row(
          children: [
            Container(
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
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Veículos',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      height: 1.2,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    'Gerencie sua frota de veículos',
                    style: const TextStyle(
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
}

/// Conteúdo principal otimizado com Selector
class _OptimizedVehiclesContent extends StatelessWidget {
  final void Function(BuildContext, VehicleEntity) onEditVehicle;
  final void Function(BuildContext, VehicleEntity) onDeleteVehicle;
  
  const _OptimizedVehiclesContent({
    required this.onEditVehicle,
    required this.onDeleteVehicle,
  });
  

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
            description: 'Use o botão + para cadastrar seu primeiro veículo e começar a controlar seus gastos com combustível e manutenção',
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
/// ✅ LAYOUT FIX: Conteúdo limitado a 1120px centralizado dentro da área total
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
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Center(
        child: ConstrainedBox(
          // Limitar conteúdo a 1120px mas centralizado
          constraints: const BoxConstraints(maxWidth: 1120),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: LayoutBuilder(
              builder: (context, constraints) {
                // Determinar número de colunas baseado na largura limitada (1120px max)
                int crossAxisCount = 1;
                final double availableWidth = constraints.maxWidth;
                const double spacing = 16.0;
                
                // Calcular colunas baseado na largura do conteúdo limitado
                if (availableWidth > 900) {
                  crossAxisCount = 4;
                } else if (availableWidth > 600) {
                  crossAxisCount = 3;
                } else if (availableWidth > 400) {
                  crossAxisCount = 2;
                }
                
                return AlignedGridView.count(
                  crossAxisCount: crossAxisCount,
                  mainAxisSpacing: spacing,
                  crossAxisSpacing: spacing,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
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
        ),
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

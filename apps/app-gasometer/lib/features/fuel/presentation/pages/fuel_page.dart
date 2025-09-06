import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/presentation/widgets/semantic_widgets.dart';
import '../../../../core/presentation/widgets/standard_loading_view.dart';
import '../../../../core/theme/design_tokens.dart';
import '../../../../shared/widgets/enhanced_vehicle_selector.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../vehicles/presentation/pages/add_vehicle_page.dart';
import '../../../vehicles/presentation/providers/vehicles_provider.dart';
import '../../domain/entities/fuel_record_entity.dart';
import '../pages/add_fuel_page.dart';
import '../providers/fuel_form_provider.dart';
import '../providers/fuel_provider.dart';
import '../widgets/fuel_empty_state.dart';
import '../widgets/fuel_error_state.dart';
import '../widgets/fuel_statistics_row.dart';

class FuelPage extends StatefulWidget {
  const FuelPage({super.key});

  @override
  State<FuelPage> createState() => _FuelPageState();
}

class _FuelPageState extends State<FuelPage> {
  String? _selectedVehicleId;
  
  // ✅ PERFORMANCE FIX: Cached providers
  late final FuelProvider _fuelProvider;
  late final VehiclesProvider _vehiclesProvider;

  @override
  void initState() {
    super.initState();
    // ✅ PERFORMANCE FIX: Cache providers once in initState
    _fuelProvider = context.read<FuelProvider>();
    _vehiclesProvider = context.read<VehiclesProvider>();
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Verificar se o widget ainda está montado antes de carregar dados
      if (mounted) {
        _loadData();
      }
    });
  }

  void _loadData() {
    // ✅ PERFORMANCE FIX: Use cached providers
    
    _vehiclesProvider.initialize().then((_) {
      if (_selectedVehicleId?.isNotEmpty == true) {
        _fuelProvider.loadFuelRecordsByVehicle(_selectedVehicleId!);
      } else {
        _fuelProvider.loadAllFuelRecords();
      }
    });
  }

  // ✅ PERFORMANCE FIX: Use cached provider instead of context.read()
  List<FuelRecordEntity> get _filteredRecords {
    return _fuelProvider.fuelRecords;
  }

  // ✅ PERFORMANCE FIX: Use cached provider instead of context.read()
  String _getVehicleName(String vehicleId) {
    final vehicle = _vehiclesProvider.vehicles.where((v) => v.id == vehicleId).firstOrNull;
    return vehicle?.displayName ?? 'Veículo desconhecido';
  }

  @override
  Widget build(BuildContext context) {
    // ✅ PERFORMANCE FIX: Use Selector2 instead of Consumer2 to prevent unnecessary rebuilds
    return Selector2<FuelProvider, VehiclesProvider, Map<String, dynamic>>(
      selector: (context, fuelProvider, vehiclesProvider) => {
        'isLoading': fuelProvider.isLoading,
        'hasError': fuelProvider.hasError,
        'fuelRecords': fuelProvider.fuelRecords,
        'fuelError': fuelProvider.errorMessage,
        'vehiclesError': vehiclesProvider.errorMessage,
      },
      builder: (context, data, child) {
        final isLoading = data['isLoading'] as bool;
        final hasError = data['hasError'] as bool;
        final fuelRecords = data['fuelRecords'] as List<FuelRecordEntity>;
        final fuelError = data['fuelError'] as String?;
        final vehiclesError = data['vehiclesError'] as String?;
        
        return Scaffold(
          backgroundColor: Theme.of(context).colorScheme.surface,
          body: SafeArea(
            child: Column(
              children: [
                _buildHeader(context),
                Expanded(
                  child: SingleChildScrollView(
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 1200),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: _buildContentOptimized(context, isLoading, hasError, fuelRecords, fuelError),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          floatingActionButton: _buildFloatingActionButton(context),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context) {
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
      child: Row(
        children: [
          Semantics(
            label: 'Seção de abastecimentos',
            hint: 'Página principal para gerenciar abastecimentos',
            child: Container(
              padding: const EdgeInsets.all(9),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(9),
              ),
              child: const Icon(
                Icons.local_gas_station,
                color: Colors.white,
                size: 19,
              ),
            ),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                SemanticText.heading(
                  'Abastecimentos',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 3),
                SemanticText.subtitle(
                  'Histórico de abastecimentos dos seus veículos',
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
    );
  }


  // ✅ PERFORMANCE FIX: Optimized content builder with selective data consumption
  Widget _buildContentOptimized(BuildContext context, bool isLoading, bool hasError, List<FuelRecordEntity> fuelRecords, String? errorMessage) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Use Consumer only for the specific parts that need provider access
        Consumer<VehiclesProvider>(
          builder: (context, vehiclesProvider, child) {
            return EnhancedVehicleSelector(
              selectedVehicleId: _selectedVehicleId,
              onVehicleChanged: (String? vehicleId) {
                setState(() {
                  _selectedVehicleId = vehicleId;
                });
                
                if (_fuelProvider.searchQuery.isNotEmpty) {
                  _fuelProvider.clearSearch();
                }
                
                if (vehicleId?.isNotEmpty == true) {
                  _fuelProvider.loadFuelRecordsByVehicle(vehicleId!);
                } else {
                  _fuelProvider.loadAllFuelRecords();
                }
              },
            );
          }
        ),
        const SizedBox(height: 16),
        
        
        // Show error state
        if (hasError && errorMessage != null)
          _buildErrorState(errorMessage, () => _loadData())
        else if (isLoading)
          StandardLoadingView.initial(
            message: 'Carregando abastecimentos...',
            height: 400,
          )
        else if (fuelRecords.isEmpty)
          _buildEmptyState()
        else ...[
          // Statistics with Consumer for live updates
          Consumer<FuelProvider>(
            builder: (context, fuelProvider, child) => _buildStatistics(fuelProvider),
          ),
          const SizedBox(height: 24),
          _buildVirtualizedRecordsList(fuelRecords),
        ],
      ],
    );
  }

  Widget _buildContent(BuildContext context, FuelProvider fuelProvider, VehiclesProvider vehiclesProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        EnhancedVehicleSelector(
          selectedVehicleId: _selectedVehicleId,
          onVehicleChanged: (String? vehicleId) {
            setState(() {
              _selectedVehicleId = vehicleId;
            });
            
            if (_fuelProvider.searchQuery.isNotEmpty) {
              _fuelProvider.clearSearch();
            }
            
            if (vehicleId?.isNotEmpty == true) {
              _fuelProvider.loadFuelRecordsByVehicle(vehicleId!);
            } else {
              _fuelProvider.loadAllFuelRecords();
            }
          },
        ),
        SizedBox(height: GasometerDesignTokens.spacingMd),
        
        
        if (fuelProvider.hasActiveFilters) ...[
          _buildFilterStatus(fuelProvider),
          SizedBox(height: GasometerDesignTokens.spacingSectionSpacing),
        ],
        
        if (fuelProvider.isLoading)
          StandardLoadingView.initial(
            message: 'Carregando abastecimentos...',
            height: 400,
          )
        else if (fuelProvider.hasError)
          _buildErrorState(fuelProvider.errorMessage!, () => _loadData())
        else if (_filteredRecords.isEmpty)
          _buildEmptyState()
        else ...[
          _buildStatistics(fuelProvider),
          SizedBox(height: GasometerDesignTokens.spacingSectionSpacing),
          _buildRecordsList(_filteredRecords, vehiclesProvider),
        ],
      ],
    );
  }

  Widget _buildStatistics(FuelProvider fuelProvider) {
    // Use cached statistics from provider instead of calculating in build method
    final statistics = fuelProvider.statistics;
    return FuelStatisticsRow(statistics: statistics);
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return SemanticCard(
      semanticLabel: 'Estatística de $title: $value',
      semanticHint: 'Informação sobre $title dos abastecimentos',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: GasometerDesignTokens.paddingAll(
                  GasometerDesignTokens.spacingSm,
                ),
                decoration: BoxDecoration(
                  color: GasometerDesignTokens.withOpacity(color, 0.1),
                  borderRadius: GasometerDesignTokens.borderRadius(
                    GasometerDesignTokens.radiusMd,
                  ),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: GasometerDesignTokens.iconSizeButton,
                ),
              ),
              SizedBox(width: GasometerDesignTokens.spacingMd),
              SemanticText.label(
                title,
                style: TextStyle(
                  fontSize: GasometerDesignTokens.fontSizeMd,
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(GasometerDesignTokens.opacitySecondary),
                ),
              ),
            ],
          ),
          SizedBox(height: GasometerDesignTokens.spacingMd),
          SemanticText(
            value,
            style: TextStyle(
              fontSize: GasometerDesignTokens.fontSizeXxxl,
              fontWeight: GasometerDesignTokens.fontWeightBold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  // ✅ PERFORMANCE FIX: Virtualized list that can handle 1000+ records efficiently
  Widget _buildVirtualizedRecordsList(List<FuelRecordEntity> records) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SemanticText.heading(
          'Histórico de Abastecimentos',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 16),
        // ✅ PERFORMANCE FIX: Properly virtualized list with fixed height
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.6, // Dynamic height based on screen
          child: ListView.builder(
            // ✅ Remove shrinkWrap and NeverScrollableScrollPhysics for proper virtualization
            itemCount: records.length,
            itemExtent: 120.0, // Fixed item height for better performance
            itemBuilder: (context, index) {
              return Consumer<VehiclesProvider>(
                builder: (context, vehiclesProvider, child) {
                  return _OptimizedFuelRecordCard(
                    key: ValueKey(records[index].id),
                    record: records[index],
                    vehiclesProvider: vehiclesProvider,
                    onLongPress: () => _showRecordMenu(records[index]),
                    onTap: () => _showRecordDetails(records[index], vehiclesProvider),
                    getVehicleName: _getVehicleName,
                  );
                }
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildRecordsList(List<FuelRecordEntity> records, VehiclesProvider vehiclesProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SemanticText.heading(
          'Histórico de Abastecimentos',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 16),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: records.length,
          itemBuilder: (context, index) {
            return _OptimizedFuelRecordCard(
              key: ValueKey(records[index].id),
              record: records[index],
              vehiclesProvider: vehiclesProvider,
              onLongPress: () => _showRecordMenu(records[index]),
              onTap: () => _showRecordDetails(records[index], vehiclesProvider),
              getVehicleName: _getVehicleName,
            );
          },
        ),
      ],
    );
  }



  Widget _buildFullTankBadge(BuildContext context) {
    return Semantics(
      label: 'Abastecimento com tanque cheio',
      child: Container(
        padding: GasometerDesignTokens.paddingOnly(
          left: GasometerDesignTokens.spacingSm,
          right: GasometerDesignTokens.spacingSm,
          top: GasometerDesignTokens.spacingXs,
          bottom: GasometerDesignTokens.spacingXs,
        ),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary.withOpacity(GasometerDesignTokens.opacityOverlay),
          borderRadius: GasometerDesignTokens.borderRadius(
            GasometerDesignTokens.radiusSm,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.check_circle,
              size: GasometerDesignTokens.fontSizeMd,
              color: Theme.of(context).colorScheme.primary,
            ),
            SizedBox(width: GasometerDesignTokens.spacingXs),
            Text(
              'Tanque cheio',
              style: TextStyle(
                fontSize: GasometerDesignTokens.fontSizeSm,
                color: Theme.of(context).colorScheme.primary,
                fontWeight: GasometerDesignTokens.fontWeightMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildEmptyState() {
    return Center(
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.6,
        child: FuelEmptyState(),
      ),
    );
  }

  Widget _buildFloatingActionButton(BuildContext context) {
    final hasSelectedVehicle = _selectedVehicleId != null;
    
    return FloatingActionButton(
      onPressed: hasSelectedVehicle ? _showAddFuelDialog : _showSelectVehicleMessage,
      backgroundColor: hasSelectedVehicle 
          ? Theme.of(context).colorScheme.primary
          : Theme.of(context).disabledColor,
      foregroundColor: hasSelectedVehicle 
          ? Theme.of(context).colorScheme.onPrimary
          : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.38),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      tooltip: hasSelectedVehicle 
          ? 'Adicionar registro de abastecimento' 
          : 'Selecione um veículo primeiro',
      child: const Icon(Icons.add),
    );
  }

  void _showSelectVehicleMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Selecione um veículo primeiro'),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: GasometerDesignTokens.borderRadius(
            GasometerDesignTokens.radiusInput,
          ),
        ),
      ),
    );
  }

  Future<void> _showAddVehicleDialog(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => const AddVehiclePage(),
    );
    
    if (result == true && context.mounted) {
      await _vehiclesProvider.initialize();
    }
  }

  Future<void> _showAddFuelDialog() async {
    try {
      // Get providers before opening dialog to avoid context issues
      final authProvider = context.read<AuthProvider>();
      
      final result = await showDialog<bool>(
        context: context,
        builder: (dialogContext) => MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => FuelFormProvider()),
            ChangeNotifierProvider.value(value: _vehiclesProvider),
            ChangeNotifierProvider.value(value: authProvider),
          ],
          builder: (context, child) => AddFuelPage(vehicleId: _selectedVehicleId),
        ),
      );
      
      if (result == true && mounted) {
        // Recarregar dados após adicionar combustível
        _loadData();
      }
    } catch (e) {
      debugPrint('Error opening add fuel dialog: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erro ao abrir formulário de combustível')),
        );
      }
    }
  }

  Future<void> _showEditFuelDialog(String fuelRecordId, String vehicleId) async {
    // Get providers before opening dialog to avoid context issues
    final authProvider = context.read<AuthProvider>();
    
    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => FuelFormProvider()),
          ChangeNotifierProvider.value(value: _vehiclesProvider),
          ChangeNotifierProvider.value(value: authProvider),
        ],
        builder: (context, child) => AddFuelPage(
          vehicleId: vehicleId,
          editFuelRecordId: fuelRecordId,
        ),
      ),
    );
    
    if (result == true && mounted) {
      // Recarregar dados após editar combustível
      _loadData();
    }
  }

  void _showRecordDetails(FuelRecordEntity record, VehiclesProvider vehiclesProvider) {
    final vehicleName = _getVehicleName(record.veiculoId);
    final formattedDate = '${record.data.day}/${record.data.month}/${record.data.year}';
    
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Semantics(
              label: 'Ícone de posto de combustível',
              child: Icon(Icons.local_gas_station, color: Theme.of(context).colorScheme.primary),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: SemanticText.heading(vehicleName),
            ),
          ],
        ),
        content: Semantics(
          label: 'Detalhes do abastecimento de $vehicleName em $formattedDate',
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailRow('Posto', record.nomePosto ?? 'Não informado'),
              _buildDetailRow('Combustível', record.tipoCombustivel.displayName),
              _buildDetailRow('Litros', record.litrosFormatados),
              _buildDetailRow('Preço/L', record.precoPorLitroFormatado),
              _buildDetailRow('Total', record.valorTotalFormatado),
              _buildDetailRow('Odômetro', record.odometroFormatado),
              _buildDetailRow('Tanque cheio', record.tanqueCheio ? 'Sim' : 'Não'),
              if (record.temObservacoes)
                _buildDetailRow('Observações', record.observacoes!),
            ],
          ),
        ),
        actions: [
          SemanticButton(
            semanticLabel: 'Fechar detalhes',
            semanticHint: 'Fecha a janela de detalhes do abastecimento',
            type: ButtonType.text,
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }

  void _showRecordMenu(FuelRecordEntity record) {
    final vehicleName = _getVehicleName(record.veiculoId);
    final formattedDate = '${record.data.day}/${record.data.month}/${record.data.year}';
    final recordDescription = 'abastecimento de $vehicleName em $formattedDate';
    
    showModalBottomSheet<void>(
      context: context,
      builder: (context) => SafeArea(
        child: Semantics(
          label: 'Menu de opções para $recordDescription',
          child: Wrap(
            children: [
              Semantics(
                label: 'Editar $recordDescription',
                hint: 'Abre formulário de edição para modificar os dados deste abastecimento',
                button: true,
                onTap: () {
                  Navigator.pop(context);
                  _showEditFuelDialog(record.id, record.veiculoId);
                },
                child: ListTile(
                  leading: const Icon(Icons.edit),
                  title: const Text('Editar'),
                  onTap: () {
                    Navigator.pop(context);
                    _showEditFuelDialog(record.id, record.veiculoId);
                  },
                ),
              ),
              Semantics(
                label: 'Excluir $recordDescription',
                hint: 'Remove permanentemente este registro de abastecimento',
                button: true,
                onTap: () {
                  Navigator.pop(context);
                  _confirmDeleteRecord(record);
                },
                child: ListTile(
                  leading: const Icon(Icons.delete, color: Colors.red),
                  title: const Text('Excluir', style: TextStyle(color: Colors.red)),
                  onTap: () {
                    Navigator.pop(context);
                    _confirmDeleteRecord(record);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmDeleteRecord(FuelRecordEntity record) {
    final vehicleName = _getVehicleName(record.veiculoId);
    final recordDescription = 'abastecimento de $vehicleName realizado em ${record.data.day}/${record.data.month}/${record.data.year}';
    
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: SemanticText.heading('Confirmar exclusão'),
        content: SemanticText(
          'Tem certeza que deseja excluir este registro de abastecimento?\n\nEsta ação não pode ser desfeita.',
        ),
        actions: [
          SemanticButton(
            semanticLabel: 'Cancelar exclusão',
            semanticHint: 'Fecha a confirmação sem excluir o registro de abastecimento',
            type: ButtonType.text,
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          SemanticButton(
            semanticLabel: 'Confirmar exclusão do registro',
            semanticHint: 'Remove permanentemente este $recordDescription',
            type: ButtonType.elevated,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              Navigator.pop(context);
              
              final success = await _fuelProvider.deleteFuelRecord(record.id);
              
              if (mounted) {
                final scaffoldMessenger = ScaffoldMessenger.of(context);
                final message = success 
                  ? 'Registro excluído com sucesso!'
                  : _fuelProvider.errorMessage ?? 'Erro ao excluir registro';
                final backgroundColor = success ? Colors.green : Colors.red;
                
                scaffoldMessenger.showSnackBar(
                  SnackBar(
                    content: Text(message),
                    backgroundColor: backgroundColor,
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


  Widget _buildErrorState(String error, VoidCallback onRetry) {
    return FuelErrorState(
      error: error,
      onRetry: onRetry,
    );
  }

  Widget _buildFilterStatus(FuelProvider fuelProvider) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            Icons.filter_alt,
            color: Theme.of(context).colorScheme.primary,
            size: 18,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              fuelProvider.activeFiltersDescription,
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          if (fuelProvider.hasActiveFilters)
            TextButton(
              onPressed: () => _fuelProvider.clearAllFilters(),
              style: TextButton.styleFrom(
                minimumSize: const Size(60, 30),
                padding: const EdgeInsets.symmetric(horizontal: 8),
              ),
              child: Text(
                'Limpar',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontSize: 12,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              fontSize: 14,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

/// Widget otimizado para card de abastecimento
class _OptimizedFuelRecordCard extends StatelessWidget {
  final FuelRecordEntity record;
  final VehiclesProvider vehiclesProvider;
  final VoidCallback onLongPress;
  final VoidCallback onTap;
  final String Function(String) getVehicleName;

  const _OptimizedFuelRecordCard({
    super.key,
    required this.record,
    required this.vehiclesProvider,
    required this.onLongPress,
    required this.onTap,
    required this.getVehicleName,
  });

  @override
  Widget build(BuildContext context) {
    final date = record.data;
    final formattedDate = '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
    final vehicleName = getVehicleName(record.veiculoId);
    final semanticLabel = 'Abastecimento $vehicleName em $formattedDate, ${record.litros.toStringAsFixed(1)} litros, R\$ ${record.valorTotal.toStringAsFixed(2)}${record.tanqueCheio ? ', tanque cheio' : ''}';

    return SemanticCard(
      semanticLabel: semanticLabel,
      semanticHint: 'Toque para ver detalhes completos, mantenha pressionado para editar ou excluir',
      onTap: onTap,
      onLongPress: onLongPress,
      margin: EdgeInsets.only(bottom: GasometerDesignTokens.spacingMd),
      child: Column(
        children: [
          _buildRecordHeader(context, vehicleName, formattedDate),
          _buildRecordDivider(context),
          _buildRecordStats(context),
        ],
      ),
    );
  }

  Widget _buildRecordHeader(BuildContext context, String vehicleName, String formattedDate) {
    return Row(
      children: [
        _buildRecordIcon(context),
        SizedBox(width: GasometerDesignTokens.spacingLg),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SemanticText.heading(
                    vehicleName,
                    style: TextStyle(
                      fontSize: GasometerDesignTokens.fontSizeLg,
                      fontWeight: GasometerDesignTokens.fontWeightBold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  SemanticText.label(
                    formattedDate,
                    style: TextStyle(
                      fontSize: GasometerDesignTokens.fontSizeMd,
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(GasometerDesignTokens.opacitySecondary),
                    ),
                  ),
                ],
              ),
              SizedBox(height: GasometerDesignTokens.spacingXs),
              SemanticText.subtitle(
                record.nomePosto ?? 'Posto não informado',
                style: TextStyle(
                  fontSize: GasometerDesignTokens.fontSizeMd,
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(GasometerDesignTokens.opacitySecondary),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRecordIcon(BuildContext context) {
    return Container(
      padding: GasometerDesignTokens.paddingAll(
        GasometerDesignTokens.spacingMd - 2,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withOpacity(GasometerDesignTokens.opacityOverlay),
        borderRadius: GasometerDesignTokens.borderRadius(
          GasometerDesignTokens.radiusMd + 2,
        ),
      ),
      child: Icon(
        Icons.local_gas_station,
        color: Theme.of(context).colorScheme.primary,
        size: GasometerDesignTokens.iconSizeListItem,
      ),
    );
  }

  Widget _buildRecordDivider(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: GasometerDesignTokens.spacingMd),
        Divider(
          height: 1,
          color: Theme.of(context).colorScheme.outline.withOpacity(GasometerDesignTokens.opacityDivider),
        ),
        SizedBox(height: GasometerDesignTokens.spacingMd),
      ],
    );
  }

  Widget _buildRecordStats(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildInfoItem(
          context,
          Icons.water_drop_outlined,
          '${record.litros.toStringAsFixed(1)} L',
          'Litros',
        ),
        _buildInfoItem(
          context,
          Icons.speed,
          '${record.odometro.toStringAsFixed(0)} km',
          'Odômetro',
        ),
        _buildInfoItem(
          context,
          Icons.attach_money,
          'R\$ ${record.valorTotal.toStringAsFixed(2)}',
          'Total',
        ),
        if (record.tanqueCheio) _buildFullTankBadge(context),
      ],
    );
  }

  Widget _buildInfoItem(BuildContext context, IconData icon, String value, String label) {
    return Semantics(
      label: '$label: $value',
      child: Column(
        children: [
          Icon(
            icon,
            size: 20,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 4),
          SemanticText(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          SemanticText.label(
            label,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFullTankBadge(BuildContext context) {
    return SemanticStatusIndicator(
      status: 'Tanque cheio',
      description: 'Abastecimento realizado com o tanque completamente cheio',
      child: Container(
        padding: GasometerDesignTokens.paddingOnly(
          left: GasometerDesignTokens.spacingSm,
          right: GasometerDesignTokens.spacingSm,
          top: GasometerDesignTokens.spacingXs,
          bottom: GasometerDesignTokens.spacingXs,
        ),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary.withOpacity(GasometerDesignTokens.opacityOverlay),
          borderRadius: GasometerDesignTokens.borderRadius(
            GasometerDesignTokens.radiusSm,
          ),
        ),
        child: SemanticText.label(
          'Cheio',
          style: TextStyle(
            color: Theme.of(context).colorScheme.primary,
            fontSize: GasometerDesignTokens.fontSizeSm,
            fontWeight: GasometerDesignTokens.fontWeightMedium,
          ),
        ),
      ),
    );
  }
}
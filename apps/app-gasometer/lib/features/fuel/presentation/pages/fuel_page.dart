import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../core/presentation/widgets/standard_card.dart';
import '../../../../core/presentation/widgets/enhanced_empty_state.dart';
import '../../../../core/theme/design_tokens.dart';
import '../../../../shared/widgets/vehicle_selector.dart';
import '../../../vehicles/presentation/providers/vehicles_provider.dart';
import '../../../vehicles/presentation/pages/add_vehicle_page.dart';
import '../../domain/entities/fuel_record_entity.dart';
import '../providers/fuel_provider.dart';

class FuelPage extends StatefulWidget {
  const FuelPage({super.key});

  @override
  State<FuelPage> createState() => _FuelPageState();
}

class _FuelPageState extends State<FuelPage> {
  String _selectedFilter = 'all';
  String? _selectedVehicleId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  void _loadData() {
    final fuelProvider = context.read<FuelProvider>();
    final vehiclesProvider = context.read<VehiclesProvider>();
    
    // Load vehicles first, then fuel records
    vehiclesProvider.loadVehicles().then((_) {
      if (_selectedVehicleId?.isNotEmpty == true) {
        fuelProvider.loadFuelRecordsByVehicle(_selectedVehicleId!);
      } else {
        fuelProvider.loadAllFuelRecords();
      }
    });
  }

  List<FuelRecordEntity> get _filteredRecords {
    final fuelProvider = context.read<FuelProvider>();
    var filtered = fuelProvider.fuelRecords;

    // Aplicar filtro por veículo
    if (_selectedFilter != 'all') {
      filtered = filtered.where((r) => r.vehicleId == _selectedFilter).toList();
    }

    // Aplicar busca - já está sendo filtrado pelo provider
    // O provider já gerencia a busca através do searchFuelRecords()

    return filtered;
  }

  String _getVehicleName(String vehicleId) {
    final vehiclesProvider = context.read<VehiclesProvider>();
    // Busca na lista carregada localmente em vez de fazer chamada async
    final vehicle = vehiclesProvider.vehicles.where((v) => v.id == vehicleId).firstOrNull;
    return vehicle?.displayName ?? 'Veículo desconhecido';
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<FuelProvider, VehiclesProvider>(
      builder: (context, fuelProvider, vehiclesProvider, child) {
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
                          child: _buildContent(context, fuelProvider, vehiclesProvider),
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
                Icons.local_gas_station,
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
                    'Abastecimentos',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    'Histórico de abastecimentos dos seus veículos',
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


  Widget _buildContent(BuildContext context, FuelProvider fuelProvider, VehiclesProvider vehiclesProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        VehicleSelector(
          selectedVehicleId: _selectedVehicleId,
          onVehicleChanged: (vehicleId) {
            setState(() {
              _selectedVehicleId = vehicleId;
              _selectedFilter = vehicleId ?? 'all';
            });
            
            // Load records for selected vehicle
            if (vehicleId?.isNotEmpty == true) {
              fuelProvider.loadFuelRecordsByVehicle(vehicleId!);
            } else {
              fuelProvider.loadAllFuelRecords();
            }
          },
          showEmptyOption: true,
        ),
        SizedBox(height: GasometerDesignTokens.spacingSectionSpacing),
        
        // Show loading state
        if (fuelProvider.isLoading)
          _buildLoadingState()
        // Show error state  
        else if (fuelProvider.hasError)
          _buildErrorState(fuelProvider.errorMessage!, () => _loadData())
        // Show empty state
        else if (_filteredRecords.isEmpty)
          _buildEmptyState()
        // Show content
        else ...[
          _buildStatistics(_filteredRecords),
          SizedBox(height: GasometerDesignTokens.spacingSectionSpacing),
          _buildRecordsList(_filteredRecords, vehiclesProvider),
        ],
      ],
    );
  }

  Widget _buildStatistics(List<FuelRecordEntity> records) {
    final totalLiters = records.fold<double>(
      0,
      (sum, record) => sum + record.liters,
    );
    final totalCost = records.fold<double>(
      0,
      (sum, record) => sum + record.totalPrice,
    );
    final avgPrice = records.isEmpty
        ? 0.0
        : records.fold<double>(
              0,
              (sum, record) => sum + record.pricePerLiter,
            ) /
            records.length;

    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'Total de Litros',
            '${totalLiters.toStringAsFixed(1)} L',
            Icons.water_drop,
            Colors.blue,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            'Gasto Total',
            'R\$ ${totalCost.toStringAsFixed(2)}',
            Icons.attach_money,
            Colors.green,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            'Preço Médio',
            'R\$ ${avgPrice.toStringAsFixed(2)}/L',
            Icons.trending_up,
            Colors.orange,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Semantics(
      label: '$title: $value',
      child: StandardCard.compact(
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
                Text(
                  title,
                  style: TextStyle(
                    fontSize: GasometerDesignTokens.fontSizeMd,
                    color: Theme.of(context).colorScheme.onSurface.withValues(
                      alpha: GasometerDesignTokens.opacitySecondary,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: GasometerDesignTokens.spacingMd),
            Text(
              value,
              style: TextStyle(
                fontSize: GasometerDesignTokens.fontSizeXxxl,
                fontWeight: GasometerDesignTokens.fontWeightBold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecordsList(List<FuelRecordEntity> records, VehiclesProvider vehiclesProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Histórico de Abastecimentos',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 16),
        ...records.map((record) => _buildRecordCard(record, vehiclesProvider)),
      ],
    );
  }

  Widget _buildRecordCard(FuelRecordEntity record, VehiclesProvider vehiclesProvider) {
    final date = record.date;
    final formattedDate = '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
    final vehicleName = _getVehicleName(record.vehicleId);

    return Semantics(
      label: 'Abastecimento $vehicleName, ${record.liters.toStringAsFixed(1)} litros, R\$ ${record.totalPrice.toStringAsFixed(2)}',
      hint: 'Toque para ver detalhes, mantenha pressionado para opções',
      child: GestureDetector(
        onLongPress: () => _showRecordMenu(record),
        child: StandardCard.standard(
          margin: EdgeInsets.only(bottom: GasometerDesignTokens.spacingMd),
          onTap: () => _showRecordDetails(record, vehiclesProvider),
          child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: GasometerDesignTokens.paddingAll(
                  GasometerDesignTokens.spacingMd - 2,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withValues(
                    alpha: GasometerDesignTokens.opacityOverlay,
                  ),
                  borderRadius: GasometerDesignTokens.borderRadius(
                    GasometerDesignTokens.radiusMd + 2,
                  ),
                ),
                child: Icon(
                  Icons.local_gas_station,
                  color: Theme.of(context).colorScheme.primary,
                  size: GasometerDesignTokens.iconSizeListItem,
                ),
              ),
              SizedBox(width: GasometerDesignTokens.spacingLg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          vehicleName,
                          style: TextStyle(
                            fontSize: GasometerDesignTokens.fontSizeLg,
                            fontWeight: GasometerDesignTokens.fontWeightBold,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        Text(
                          formattedDate,
                          style: TextStyle(
                            fontSize: GasometerDesignTokens.fontSizeMd,
                            color: Theme.of(context).colorScheme.onSurface.withValues(
                              alpha: GasometerDesignTokens.opacitySecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: GasometerDesignTokens.spacingXs),
                    Text(
                      record.gasStationName ?? 'Posto não informado',
                      style: TextStyle(
                        fontSize: GasometerDesignTokens.fontSizeMd,
                        color: Theme.of(context).colorScheme.onSurface.withValues(
                          alpha: GasometerDesignTokens.opacitySecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: GasometerDesignTokens.spacingMd),
          Divider(
            height: 1,
            color: Theme.of(context).colorScheme.outline.withValues(
              alpha: GasometerDesignTokens.opacityDivider,
            ),
          ),
          SizedBox(height: GasometerDesignTokens.spacingMd),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildInfoItem(
                Icons.water_drop_outlined,
                '${record.liters.toStringAsFixed(1)} L',
                'Litros',
              ),
              _buildInfoItem(
                Icons.speed,
                '${record.odometer.toStringAsFixed(0)} km',
                'Odômetro',
              ),
              _buildInfoItem(
                Icons.attach_money,
                'R\$ ${record.totalPrice.toStringAsFixed(2)}',
                'Total',
              ),
              if (record.fullTank)
                Container(
                  padding: GasometerDesignTokens.paddingOnly(
                    left: GasometerDesignTokens.spacingSm,
                    right: GasometerDesignTokens.spacingSm,
                    top: GasometerDesignTokens.spacingXs,
                    bottom: GasometerDesignTokens.spacingXs,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withValues(
                      alpha: GasometerDesignTokens.opacityOverlay,
                    ),
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
            ],
          ),
        ],
      ),
    ),
    ),
    );
  }

  Widget _buildInfoItem(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(
          icon,
          size: 18,
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return EnhancedEmptyState.generic(
      icon: Icons.local_gas_station_outlined,
      title: 'Nenhum abastecimento encontrado',
      description: 'Registre seu primeiro abastecimento para começar a controlar o consumo do seu veículo',
      actionLabel: 'Registrar Abastecimento',
      onAction: () => context.go('/fuel/add'),
      height: 400,
    );
  }

  Widget _buildFloatingActionButton(BuildContext context) {
    final vehiclesProvider = context.watch<VehiclesProvider>();
    final hasSelectedVehicle = vehiclesProvider.vehicles.isNotEmpty;
    
    return Semantics(
      label: hasSelectedVehicle ? 'Registrar novo abastecimento' : 'Selecione um veículo primeiro',
      hint: hasSelectedVehicle 
          ? 'Abre formulário para cadastrar um novo abastecimento'
          : 'É necessário ter pelo menos um veículo cadastrado',
      child: FloatingActionButton(
        onPressed: hasSelectedVehicle ? () => context.go('/fuel/add') : _showSelectVehicleMessage,
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        shape: RoundedRectangleBorder(
          borderRadius: GasometerDesignTokens.borderRadius(
            GasometerDesignTokens.radiusLg,
          ),
        ),
        tooltip: hasSelectedVehicle 
            ? 'Novo Abastecimento'
            : 'Cadastre um veículo primeiro',
        child: Icon(
          Icons.add,
          size: GasometerDesignTokens.iconSizeLg,
        ),
      ),
    );
  }

  void _showSelectVehicleMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Cadastre um veículo primeiro para registrar abastecimentos'),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: GasometerDesignTokens.borderRadius(
            GasometerDesignTokens.radiusInput,
          ),
        ),
        action: SnackBarAction(
          label: 'Cadastrar',
          onPressed: () => _showAddVehicleDialog(context),
        ),
      ),
    );
  }

  Future<void> _showAddVehicleDialog(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => const AddVehiclePage(),
    );
    
    // Se resultado for true, recarregar veículos
    if (result == true && context.mounted) {
      await context.read<VehiclesProvider>().loadVehicles();
    }
  }

  void _showRecordDetails(FuelRecordEntity record, VehiclesProvider vehiclesProvider) {
    final vehicleName = _getVehicleName(record.vehicleId);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.local_gas_station, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 8),
            Text(vehicleName),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('Posto', record.gasStationName ?? 'Não informado'),
            _buildDetailRow('Combustível', record.fuelType.displayName),
            _buildDetailRow('Litros', record.formattedLiters),
            _buildDetailRow('Preço/L', record.formattedPricePerLiter),
            _buildDetailRow('Total', record.formattedTotalPrice),
            _buildDetailRow('Odômetro', record.formattedOdometer),
            _buildDetailRow('Tanque cheio', record.fullTank ? 'Sim' : 'Não'),
            if (record.hasNotes)
              _buildDetailRow('Observações', record.notes!),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }

  void _showRecordMenu(FuelRecordEntity record) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Editar'),
              onTap: () {
                Navigator.pop(context);
                context.go('/fuel/add', extra: {
                  'editFuelRecordId': record.id,
                  'vehicleId': record.vehicleId,
                });
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Excluir', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                _confirmDeleteRecord(record);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDeleteRecord(FuelRecordEntity record) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar exclusão'),
        content: const Text('Tem certeza que deseja excluir este registro de abastecimento?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              
              final fuelProvider = context.read<FuelProvider>();
              final success = await fuelProvider.deleteFuelRecord(record.id);
              
              if (mounted) {
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Registro excluído com sucesso!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(fuelProvider.errorMessage ?? 'Erro ao excluir registro'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(48.0),
        child: CircularProgressIndicator(),
      ),
    );
  }

  Widget _buildErrorState(String error, VoidCallback onRetry) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(48.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Erro ao carregar dados',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onRetry,
              child: const Text('Tentar novamente'),
            ),
          ],
        ),
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
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
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
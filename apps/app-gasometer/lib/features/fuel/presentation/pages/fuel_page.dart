import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../core/presentation/widgets/standard_card.dart';
import '../../../../core/presentation/widgets/enhanced_empty_state.dart';
import '../../../../core/theme/design_tokens.dart';
import '../../../../shared/widgets/enhanced_vehicle_selector.dart';
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
    
    vehiclesProvider.initialize().then((_) {
      if (_selectedVehicleId?.isNotEmpty == true) {
        fuelProvider.loadFuelRecordsByVehicle(_selectedVehicleId!);
      } else {
        fuelProvider.loadAllFuelRecords();
      }
    });
  }

  List<FuelRecordEntity> get _filteredRecords {
    return context.read<FuelProvider>().fuelRecords;
  }

  String _getVehicleName(String vehicleId) {
    final vehicle = context.read<VehiclesProvider>().vehicles.where((v) => v.id == vehicleId).firstOrNull;
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
            Semantics(
              label: 'Ícone de abastecimentos',
              child: Container(
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
        EnhancedVehicleSelector(
          selectedVehicleId: _selectedVehicleId,
          onVehicleChanged: (String? vehicleId) {
            setState(() {
              _selectedVehicleId = vehicleId;
            });
            
            if (fuelProvider.searchQuery.isNotEmpty) {
              fuelProvider.clearSearch();
            }
            
            if (vehicleId?.isNotEmpty == true) {
              fuelProvider.loadFuelRecordsByVehicle(vehicleId!);
            } else {
              fuelProvider.loadAllFuelRecords();
            }
          },
        ),
        SizedBox(height: GasometerDesignTokens.spacingMd),
        
        // Campo de busca
        TextField(
          decoration: InputDecoration(
            hintText: 'Buscar por posto, marca ou observação...',
            prefixIcon: const Icon(Icons.search),
            suffixIcon: fuelProvider.searchQuery.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () => fuelProvider.clearSearch(),
                  )
                : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            filled: true,
            fillColor: Theme.of(context).colorScheme.surface,
          ),
          onChanged: (value) => fuelProvider.searchFuelRecords(value),
        ),
        SizedBox(height: GasometerDesignTokens.spacingSectionSpacing),
        
        if (fuelProvider.hasActiveFilters) ...[
          _buildFilterStatus(fuelProvider),
          SizedBox(height: GasometerDesignTokens.spacingSectionSpacing),
        ],
        
        if (fuelProvider.isLoading)
          _buildLoadingState()
        else if (fuelProvider.hasError)
          _buildErrorState(fuelProvider.errorMessage!, () => _loadData())
        else if (_filteredRecords.isEmpty)
          _buildEmptyState()
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
      (sum, record) => sum + record.litros,
    );
    final totalCost = records.fold<double>(
      0,
      (sum, record) => sum + record.valorTotal,
    );
    final avgPrice = records.isEmpty
        ? 0.0
        : records.fold<double>(
              0,
              (sum, record) => sum + record.precoPorLitro,
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
    final date = record.data;
    final formattedDate = '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
    final vehicleName = _getVehicleName(record.veiculoId);

    return Semantics(
      label: 'Abastecimento $vehicleName, ${record.litros.toStringAsFixed(1)} litros, R\$ ${record.valorTotal.toStringAsFixed(2)}',
      hint: 'Toque para ver detalhes, mantenha pressionado para opções',
      child: GestureDetector(
        onLongPress: () => _showRecordMenu(record),
        child: StandardCard.standard(
          margin: EdgeInsets.only(bottom: GasometerDesignTokens.spacingMd),
          onTap: () => _showRecordDetails(record, vehiclesProvider),
          child: Column(
            children: [
              _buildRecordHeader(context, vehicleName, formattedDate, record),
              _buildRecordDivider(context),
              _buildRecordStats(context, record),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecordHeader(BuildContext context, String vehicleName, String formattedDate, FuelRecordEntity record) {
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
                record.nomePosto ?? 'Posto não informado',
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
    );
  }

  Widget _buildRecordIcon(BuildContext context) {
    return Container(
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
    );
  }

  Widget _buildRecordDivider(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: GasometerDesignTokens.spacingMd),
        Divider(
          height: 1,
          color: Theme.of(context).colorScheme.outline.withValues(
            alpha: GasometerDesignTokens.opacityDivider,
          ),
        ),
        SizedBox(height: GasometerDesignTokens.spacingMd),
      ],
    );
  }

  Widget _buildRecordStats(BuildContext context, FuelRecordEntity record) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildInfoItem(
          Icons.water_drop_outlined,
          '${record.litros.toStringAsFixed(1)} L',
          'Litros',
        ),
        _buildInfoItem(
          Icons.speed,
          '${record.odometro.toStringAsFixed(0)} km',
          'Odômetro',
        ),
        _buildInfoItem(
          Icons.attach_money,
          'R\$ ${record.valorTotal.toStringAsFixed(2)}',
          'Total',
        ),
        if (record.tanqueCheio) _buildFullTankBadge(context),
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
    );
  }

  Widget _buildInfoItem(IconData icon, String value, String label) {
    return Semantics(
      label: '$label: $value',
      child: Column(
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
      ),
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
    
    if (result == true && context.mounted) {
      await context.read<VehiclesProvider>().initialize();
    }
  }

  void _showRecordDetails(FuelRecordEntity record, VehiclesProvider vehiclesProvider) {
    final vehicleName = _getVehicleName(record.veiculoId);
    
    showDialog<void>(
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
    showModalBottomSheet<void>(
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
                  'vehicleId': record.veiculoId,
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
    showDialog<void>(
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
                final scaffoldMessenger = ScaffoldMessenger.of(context);
                final message = success 
                  ? 'Registro excluído com sucesso!'
                  : fuelProvider.errorMessage ?? 'Erro ao excluir registro';
                final backgroundColor = success ? Colors.green : Colors.red;
                
                scaffoldMessenger.showSnackBar(
                  SnackBar(
                    content: Text(message),
                    backgroundColor: backgroundColor,
                  ),
                );
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

  Widget _buildFilterStatus(FuelProvider fuelProvider) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
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
              onPressed: () => fuelProvider.clearAllFilters(),
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
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../shared/widgets/vehicle_selector.dart';
import '../providers/fuel_provider.dart';
import '../../domain/entities/fuel_record_entity.dart';
import '../../../vehicles/presentation/providers/vehicles_provider.dart';

class FuelPage extends StatefulWidget {
  const FuelPage({super.key});

  @override
  State<FuelPage> createState() => _FuelPageState();
}

class _FuelPageState extends State<FuelPage> {
  String _selectedFilter = 'all';
  String _searchQuery = '';
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
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.local_gas_station,
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
                          'Abastecimentos',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        Text(
                          'Histórico de abastecimentos dos seus veículos',
                          style: TextStyle(
                            fontSize: 14,
                            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildFilters(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilters(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: TextField(
            onChanged: (value) {
              setState(() => _searchQuery = value);
              
              // Perform search using the provider
              final fuelProvider = context.read<FuelProvider>();
              if (value.isNotEmpty) {
                fuelProvider.searchFuelRecords(value);
              } else {
                fuelProvider.clearSearch();
              }
            },
            decoration: InputDecoration(
              hintText: 'Buscar por veículo ou posto...',
              prefixIcon: const Icon(Icons.search, size: 20),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Theme.of(context).colorScheme.outline),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Theme.of(context).colorScheme.outline),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 2),
              ),
              filled: true,
              fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Theme.of(context).colorScheme.outline),
          ),
          child: Consumer<VehiclesProvider>(
            builder: (context, vehiclesProvider, child) {
              final vehicles = vehiclesProvider.vehicles;
              
              return DropdownButton<String>(
                value: _selectedFilter,
                underline: const SizedBox(),
                icon: const Icon(Icons.arrow_drop_down),
                items: [
                  const DropdownMenuItem(value: 'all', child: Text('Todos os veículos')),
                  ...vehicles.map((vehicle) => DropdownMenuItem(
                    value: vehicle.id,
                    child: Text(vehicle.displayName),
                  )),
                ],
                onChanged: (value) {
                  setState(() => _selectedFilter = value!);
                  
                  // Update the fuel records based on selection
                  final fuelProvider = context.read<FuelProvider>();
                  if (value == 'all') {
                    fuelProvider.loadAllFuelRecords();
                  } else if (value != null) {
                    fuelProvider.loadFuelRecordsByVehicle(value);
                  }
                },
              );
            },
          ),
        ),
      ],
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
        const SizedBox(height: 24),
        
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
          const SizedBox(height: 24),
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
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Theme.of(context).colorScheme.outline),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
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

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Theme.of(context).colorScheme.outline),
      ),
      child: InkWell(
        onTap: () => _showRecordDetails(record, vehiclesProvider),
        onLongPress: () => _showRecordMenu(record),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.local_gas_station,
                      color: Theme.of(context).colorScheme.primary,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
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
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                            Text(
                              formattedDate,
                              style: TextStyle(
                                fontSize: 14,
                                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          record.gasStationName ?? 'Posto não informado',
                          style: TextStyle(
                            fontSize: 14,
                            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Divider(height: 1),
              const SizedBox(height: 12),
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
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.check_circle,
                            size: 14,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Tanque cheio',
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
    return SizedBox(
      height: 400,
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
              Icons.local_gas_station_outlined,
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4),
              size: 64,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Nenhum abastecimento encontrado',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Registre seu primeiro abastecimento',
            style: TextStyle(
              fontSize: 14,
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingActionButton(BuildContext context) {
    return FloatingActionButton(
      onPressed: () => context.go('/fuel/add'),
      backgroundColor: Theme.of(context).colorScheme.primary,
      foregroundColor: Theme.of(context).colorScheme.onPrimary,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      tooltip: 'Novo Abastecimento',
      child: const Icon(Icons.add),
    );
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
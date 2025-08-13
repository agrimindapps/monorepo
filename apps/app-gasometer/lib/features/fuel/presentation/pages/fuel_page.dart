import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class FuelPage extends StatefulWidget {
  const FuelPage({super.key});

  @override
  State<FuelPage> createState() => _FuelPageState();
}

class _FuelPageState extends State<FuelPage> {
  final List<Map<String, dynamic>> _fuelRecords = [
    {
      'id': '1',
      'vehicleId': '1',
      'vehicleName': 'Honda Civic',
      'date': DateTime.now().subtract(const Duration(days: 2)),
      'liters': 45.5,
      'pricePerLiter': 5.89,
      'totalCost': 268.00,
      'odometer': 25150,
      'gasStation': 'Posto Shell',
      'fuelType': 'Gasolina Aditivada',
      'isFullTank': true,
    },
    {
      'id': '2',
      'vehicleId': '1',
      'vehicleName': 'Honda Civic',
      'date': DateTime.now().subtract(const Duration(days: 10)),
      'liters': 40.0,
      'pricePerLiter': 5.75,
      'totalCost': 230.00,
      'odometer': 24750,
      'gasStation': 'Posto Ipiranga',
      'fuelType': 'Gasolina Comum',
      'isFullTank': true,
    },
    {
      'id': '3',
      'vehicleId': '2',
      'vehicleName': 'Toyota Corolla',
      'date': DateTime.now().subtract(const Duration(days: 5)),
      'liters': 50.0,
      'pricePerLiter': 5.95,
      'totalCost': 297.50,
      'odometer': 18200,
      'gasStation': 'Posto BR',
      'fuelType': 'Gasolina Aditivada',
      'isFullTank': true,
    },
  ];

  String _selectedFilter = 'all';
  String _searchQuery = '';

  List<Map<String, dynamic>> get _filteredRecords {
    var filtered = _fuelRecords;

    // Aplicar filtro por veículo
    if (_selectedFilter != 'all') {
      filtered = filtered.where((r) => r['vehicleId'] == _selectedFilter).toList();
    }

    // Aplicar busca
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((r) {
        final vehicleName = r['vehicleName'].toString().toLowerCase();
        final gasStation = r['gasStation'].toString().toLowerCase();
        final query = _searchQuery.toLowerCase();
        return vehicleName.contains(query) || gasStation.contains(query);
      }).toList();
    }

    // Ordenar por data (mais recente primeiro)
    filtered.sort((a, b) => b['date'].compareTo(a['date']));

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
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
                      child: _buildContent(context),
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
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
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
                      color: Colors.green.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.local_gas_station,
                      color: Colors.green,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Abastecimentos',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        Text(
                          'Histórico de abastecimentos dos seus veículos',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
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
            onChanged: (value) => setState(() => _searchQuery = value),
            decoration: InputDecoration(
              hintText: 'Buscar por veículo ou posto...',
              prefixIcon: const Icon(Icons.search, size: 20),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Colors.green, width: 2),
              ),
              filled: true,
              fillColor: Colors.grey.shade50,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: DropdownButton<String>(
            value: _selectedFilter,
            underline: const SizedBox(),
            icon: const Icon(Icons.arrow_drop_down),
            items: const [
              DropdownMenuItem(value: 'all', child: Text('Todos os veículos')),
              DropdownMenuItem(value: '1', child: Text('Honda Civic')),
              DropdownMenuItem(value: '2', child: Text('Toyota Corolla')),
            ],
            onChanged: (value) => setState(() => _selectedFilter = value!),
          ),
        ),
      ],
    );
  }

  Widget _buildContent(BuildContext context) {
    if (_filteredRecords.isEmpty) {
      return _buildEmptyState();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildStatistics(),
        const SizedBox(height: 24),
        _buildRecordsList(),
      ],
    );
  }

  Widget _buildStatistics() {
    final totalLiters = _filteredRecords.fold<double>(
      0,
      (sum, record) => sum + (record['liters'] as double),
    );
    final totalCost = _filteredRecords.fold<double>(
      0,
      (sum, record) => sum + (record['totalCost'] as double),
    );
    final avgPrice = _filteredRecords.isEmpty
        ? 0.0
        : _filteredRecords.fold<double>(
              0,
              (sum, record) => sum + (record['pricePerLiter'] as double),
            ) /
            _filteredRecords.length;

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
        side: BorderSide(color: Colors.grey.shade200),
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
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecordsList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Histórico de Abastecimentos',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
        ..._filteredRecords.map((record) => _buildRecordCard(record)),
      ],
    );
  }

  Widget _buildRecordCard(Map<String, dynamic> record) {
    final date = record['date'] as DateTime;
    final formattedDate = '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: InkWell(
        onTap: () => _showRecordDetails(record),
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
                      color: Colors.green.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.local_gas_station,
                      color: Colors.green,
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
                              record['vehicleName'],
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            Text(
                              formattedDate,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          record['gasStation'],
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
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
                    '${record['liters']} L',
                    'Litros',
                  ),
                  _buildInfoItem(
                    Icons.speed,
                    '${record['odometer']} km',
                    'Odômetro',
                  ),
                  _buildInfoItem(
                    Icons.attach_money,
                    'R\$ ${record['totalCost'].toStringAsFixed(2)}',
                    'Total',
                  ),
                  if (record['isFullTank'])
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.green.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Row(
                        children: [
                          Icon(
                            Icons.check_circle,
                            size: 14,
                            color: Colors.green,
                          ),
                          SizedBox(width: 4),
                          Text(
                            'Tanque cheio',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.green,
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
          color: Colors.grey.shade500,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade500,
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
              color: Colors.grey.shade100,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.local_gas_station_outlined,
              color: Colors.grey.shade400,
              size: 64,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Nenhum abastecimento encontrado',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Registre seu primeiro abastecimento',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingActionButton(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: () => context.go('/fuel/add'),
      backgroundColor: Colors.green,
      foregroundColor: Colors.white,
      icon: const Icon(Icons.add),
      label: const Text('Novo Abastecimento'),
    );
  }

  void _showRecordDetails(Map<String, dynamic> record) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.local_gas_station, color: Colors.green),
            const SizedBox(width: 8),
            Text(record['vehicleName']),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('Posto', record['gasStation']),
            _buildDetailRow('Combustível', record['fuelType']),
            _buildDetailRow('Litros', '${record['liters']} L'),
            _buildDetailRow('Preço/L', 'R\$ ${record['pricePerLiter']}'),
            _buildDetailRow('Total', 'R\$ ${record['totalCost']}'),
            _buildDetailRow('Odômetro', '${record['odometer']} km'),
            _buildDetailRow('Tanque cheio', record['isFullTank'] ? 'Sim' : 'Não'),
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

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.grey.shade600,
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
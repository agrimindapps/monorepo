import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/providers/dependency_providers.dart' as deps;
import '../../../../core/widgets/semantic_widgets.dart';
import '../../../vehicles/presentation/providers/vehicles_notifier.dart';

/// Cost per km calculator page
class CostPerKmCalculatorPage extends ConsumerStatefulWidget {
  const CostPerKmCalculatorPage({super.key});

  @override
  ConsumerState<CostPerKmCalculatorPage> createState() => _CostPerKmCalculatorPageState();
}

class _CostPerKmCalculatorPageState extends ConsumerState<CostPerKmCalculatorPage> {
  String? _selectedVehicleId;
  int _selectedPeriodDays = 30; // Default: último mês
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void initState() {
    super.initState();
    _calculateDates();
  }

  void _calculateDates() {
    _endDate = DateTime.now();
    _startDate = _endDate!.subtract(Duration(days: _selectedPeriodDays));
  }

  void _onPeriodChanged(int days) {
    setState(() {
      _selectedPeriodDays = days;
      _calculateDates();
    });
  }

  @override
  Widget build(BuildContext context) {
    final vehiclesAsync = ref.watch(vehiclesProvider);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: vehiclesAsync.when(
                data: (vehicles) {
                  if (vehicles.isEmpty) {
                    return _buildEmptyState();
                  }

                  // Se não tem veículo selecionado, seleciona o primeiro
                  if (_selectedVehicleId == null && vehicles.isNotEmpty) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (mounted) {
                        setState(() {
                          _selectedVehicleId = vehicles.first.id;
                        });
                      }
                    });
                  }

                  return SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildVehicleSelector(vehicles),
                        const SizedBox(height: 16),
                        _buildPeriodSelector(),
                        const SizedBox(height: 24),
                        if (_selectedVehicleId != null) ...[
                          _buildCalculationResults(),
                        ],
                      ],
                    ),
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stack) => Center(
                  child: Text('Erro ao carregar veículos: $error'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).primaryColor.withValues(alpha: 0.2),
              blurRadius: 9,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.of(context).pop(),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.all(9),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(9),
              ),
              child: const Icon(
                Icons.attach_money,
                color: Colors.white,
                size: 19,
              ),
            ),
            const SizedBox(width: 13),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  SemanticText.heading(
                    'Custo por Km',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      height: 1.2,
                    ),
                  ),
                  SizedBox(height: 3),
                  SemanticText.subtitle(
                    'Quanto custa cada quilômetro',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                      height: 1.2,
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

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.directions_car_outlined, size: 80, color: Colors.grey.shade400),
            const SizedBox(height: 24),
            Text(
              'Nenhum veículo cadastrado',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Cadastre um veículo para calcular o custo por km',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVehicleSelector(List vehicles) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.directions_car, color: Colors.blue.shade700, size: 20),
              const SizedBox(width: 8),
              Text(
                'Veículo',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.blue.shade900,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: _selectedVehicleId,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.blue.shade300),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            items: vehicles.map<DropdownMenuItem<String>>((vehicle) {
              return DropdownMenuItem<String>(
                value: vehicle.id as String,
                child: Text('${vehicle.brand} ${vehicle.model} - ${vehicle.licensePlate}'),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedVehicleId = value;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodSelector() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.calendar_today, color: Colors.orange.shade700, size: 20),
              const SizedBox(width: 8),
              Text(
                'Período',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.orange.shade900,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _PeriodChip(
                label: 'Último mês',
                days: 30,
                selected: _selectedPeriodDays == 30,
                onTap: () => _onPeriodChanged(30),
              ),
              _PeriodChip(
                label: 'Últimos 3 meses',
                days: 90,
                selected: _selectedPeriodDays == 90,
                onTap: () => _onPeriodChanged(90),
              ),
              _PeriodChip(
                label: 'Últimos 6 meses',
                days: 180,
                selected: _selectedPeriodDays == 180,
                onTap: () => _onPeriodChanged(180),
              ),
              _PeriodChip(
                label: 'Último ano',
                days: 365,
                selected: _selectedPeriodDays == 365,
                onTap: () => _onPeriodChanged(365),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'De ${DateFormat('dd/MM/yyyy').format(_startDate!)} até ${DateFormat('dd/MM/yyyy').format(_endDate!)}',
            style: TextStyle(
              fontSize: 12,
              color: Colors.orange.shade800,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalculationResults() {
    return FutureBuilder(
      future: _fetchData(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Text('Erro: ${snapshot.error}');
        }

        if (!snapshot.hasData) {
          return const Text('Sem dados');
        }

        final data = snapshot.data as Map<String, dynamic>;
        final totalCost = data['totalCost'] as double;
        final totalKm = data['totalKm'] as double;
        final costPerKm = totalKm > 0 ? totalCost / totalKm : 0.0;

        return Column(
          children: [
            _buildMainResultCard(costPerKm, totalCost, totalKm),
            const SizedBox(height: 16),
            _buildDetailsCard(data),
          ],
        );
      },
    );
  }

  Future<Map<String, dynamic>> _fetchData() async {
    final fuelResult = await ref.read(deps.getAllFuelRecordsProvider).call();

    double totalCost = 0;
    double totalKm = 0;
    int recordCount = 0;

    fuelResult.fold(
      (failure) => null,
      (allRecords) {
        // Filter by vehicle and date
        final records = allRecords.where((record) {
          return record.vehicleId == _selectedVehicleId &&
                 record.date.isAfter(_startDate!) &&
                 record.date.isBefore(_endDate!);
        }).toList();

        if (records.isNotEmpty) {
          final sortedRecords = records.toList()..sort((a, b) => a.odometer.compareTo(b.odometer));
          final initialKm = sortedRecords.first.odometer;
          final finalKm = sortedRecords.last.odometer;
          totalKm = finalKm - initialKm;
          totalCost = records.fold(0.0, (sum, record) => sum + record.totalPrice);
          recordCount = records.length;
        }
      },
    );

    return {
      'totalCost': totalCost,
      'totalKm': totalKm,
      'recordCount': recordCount,
    };
  }

  Widget _buildMainResultCard(double costPerKm, double totalCost, double totalKm) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.green.shade400, Colors.green.shade600],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          const Icon(Icons.trending_down, color: Colors.white, size: 40),
          const SizedBox(height: 16),
          const Text(
            'Custo por Quilômetro',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'R\$ ${costPerKm.toStringAsFixed(2)}/km',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 36,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          Divider(color: Colors.white.withValues(alpha: 0.3)),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Column(
                children: [
                  const Text(
                    'Total Gasto',
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'R\$ ${totalCost.toStringAsFixed(2)}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Container(
                width: 1,
                height: 40,
                color: Colors.white.withValues(alpha: 0.3),
              ),
              Column(
                children: [
                  const Text(
                    'Km Rodados',
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${totalKm.toStringAsFixed(0)} km',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsCard(Map<String, dynamic> data) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, color: Colors.grey.shade700, size: 20),
              const SizedBox(width: 8),
              const Text(
                'Informações do Período',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildInfoRow('Abastecimentos', '${data['recordCount']}'),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
          ),
          Text(
            value,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

/// Period selection chip
class _PeriodChip extends StatelessWidget {
  const _PeriodChip({
    required this.label,
    required this.days,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final int days;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? Colors.orange.shade600 : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? Colors.orange.shade600 : Colors.orange.shade300,
            width: selected ? 0 : 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: selected ? Colors.white : Colors.orange.shade900,
          ),
        ),
      ),
    );
  }
}

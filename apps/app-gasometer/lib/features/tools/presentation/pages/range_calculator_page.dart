import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/providers/dependency_providers.dart' as deps;
import '../../../../core/widgets/semantic_widgets.dart';
import '../../../vehicles/presentation/providers/vehicles_notifier.dart';

/// Range calculator page - estimates how many km you can drive with remaining fuel
class RangeCalculatorPage extends ConsumerStatefulWidget {
  const RangeCalculatorPage({super.key});

  @override
  ConsumerState<RangeCalculatorPage> createState() =>
      _RangeCalculatorPageState();
}

class _RangeCalculatorPageState extends ConsumerState<RangeCalculatorPage> {
  String? _selectedVehicleId;
  final _fuelRemainingController = TextEditingController();
  final _destinationKmController = TextEditingController();

  double? _fuelRemaining;
  double? _destinationKm;
  bool _usePercentage = false;

  @override
  void dispose() {
    _fuelRemainingController.dispose();
    _destinationKmController.dispose();
    super.dispose();
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
                      setState(() {
                        _selectedVehicleId = vehicles.first.id;
                      });
                    });
                  }

                  return SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildInfoCard(),
                        const SizedBox(height: 16),
                        _buildVehicleSelector(vehicles),
                        const SizedBox(height: 16),
                        if (_selectedVehicleId != null) ...[
                          _buildAverageConsumptionCard(),
                          const SizedBox(height: 16),
                          _buildFuelRemainingInput(),
                          const SizedBox(height: 16),
                          _buildDestinationInput(),
                          const SizedBox(height: 24),
                          _buildCalculationResults(),
                        ],
                      ],
                    ),
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stack) =>
                    Center(child: Text('Erro ao carregar veículos: $error')),
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
              child: const Icon(Icons.speed, color: Colors.white, size: 19),
            ),
            const SizedBox(width: 13),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  SemanticText.heading(
                    'Autonomia',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      height: 1.2,
                    ),
                  ),
                  SizedBox(height: 3),
                  SemanticText.subtitle(
                    'Calcule quantos km você pode rodar',
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
            Icon(
              Icons.directions_car_outlined,
              size: 80,
              color: Colors.grey.shade400,
            ),
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
              'Cadastre um veículo e registre abastecimentos para calcular a autonomia',
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: Colors.blue.shade700, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Informe o combustível restante para descobrir quantos km você ainda pode rodar',
              style: TextStyle(color: Colors.blue.shade900, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVehicleSelector(List<dynamic> vehicles) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.directions_car, color: Colors.grey.shade700, size: 20),
              const SizedBox(width: 8),
              Text(
                'Veículo',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade900,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            initialValue: _selectedVehicleId,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
            items: vehicles.map((vehicle) {
              return DropdownMenuItem<String>(
                value: vehicle.id as String,
                child: Text(
                  '${vehicle.brand} ${vehicle.model} - ${vehicle.licensePlate}',
                ),
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

  Widget _buildAverageConsumptionCard() {
    return FutureBuilder(
      future: ref.read(deps.getAllFuelRecordsProvider).call(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Text('Erro: ${snapshot.error}');
        }

        if (!snapshot.hasData) {
          return const SizedBox.shrink();
        }

        final result = snapshot.data!;

        return result.fold(
          (failure) => Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.orange.shade200),
            ),
            child: Text('Erro ao carregar dados'),
          ),
          (allRecords) {
            // Filter by vehicle
            final records = allRecords
                .where((r) => r.vehicleId == _selectedVehicleId)
                .toList();
            if (records.isEmpty) {
              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.orange.shade200),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.warning_amber,
                      color: Colors.orange.shade700,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Nenhum abastecimento registrado. Registre abastecimentos para calcular a autonomia.',
                        style: TextStyle(fontSize: 13),
                      ),
                    ),
                  ],
                ),
              );
            }

            // Calculate average consumption
            double totalLiters = 0;
            double totalKm = 0;

            final sortedRecords = records.toList()
              ..sort((a, b) => a.date.compareTo(b.date));

            for (int i = 1; i < sortedRecords.length; i++) {
              final current = sortedRecords[i];
              final previous = sortedRecords[i - 1];

              if (current.fullTank && previous.fullTank) {
                final kmDiff = current.odometer - previous.odometer;
                if (kmDiff > 0) {
                  totalKm += kmDiff;
                  totalLiters += current.liters;
                }
              }
            }

            final averageConsumption = totalLiters > 0
                ? totalKm / totalLiters
                : 0.0;

            return Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.purple.shade400, Colors.purple.shade600],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.purple.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.local_gas_station,
                    color: Colors.white,
                    size: 32,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Consumo Médio',
                    style: TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    averageConsumption > 0
                        ? '${averageConsumption.toStringAsFixed(1)} km/L'
                        : 'Dados insuficientes',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Baseado em ${sortedRecords.length} abastecimentos',
                    style: const TextStyle(color: Colors.white70, fontSize: 11),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildFuelRemainingInput() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.battery_charging_full,
                    color: Colors.green.shade700,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Combustível Restante',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.green.shade900,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Text(
                    _usePercentage ? '%' : 'Litros',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.green.shade700,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Switch(
                    value: _usePercentage,
                    activeThumbColor: Colors.green.shade600,
                    onChanged: (value) {
                      setState(() {
                        _usePercentage = value;
                        _fuelRemainingController.clear();
                        _fuelRemaining = null;
                      });
                    },
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _fuelRemainingController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
            ],
            decoration: InputDecoration(
              suffixText: _usePercentage ? '%' : 'L',
              hintText: _usePercentage ? '0 - 100' : '0,0',
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.green.shade300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.green.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.green.shade700, width: 2),
              ),
            ),
            onChanged: (value) {
              setState(() {
                _fuelRemaining = double.tryParse(value.replaceAll(',', '.'));
              });
            },
          ),
          if (_usePercentage) ...[
            const SizedBox(height: 8),
            Text(
              'Informe a porcentagem do tanque (0-100%)',
              style: TextStyle(fontSize: 11, color: Colors.green.shade700),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDestinationInput() {
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
              Icon(Icons.place, color: Colors.orange.shade700, size: 20),
              const SizedBox(width: 8),
              Text(
                'Destino (Opcional)',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.orange.shade900,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _destinationKmController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,1}')),
            ],
            decoration: InputDecoration(
              suffixText: 'km',
              hintText: 'Distância até o destino',
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.orange.shade300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.orange.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.orange.shade700, width: 2),
              ),
            ),
            onChanged: (value) {
              setState(() {
                _destinationKm = double.tryParse(value.replaceAll(',', '.'));
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCalculationResults() {
    final vehiclesAsync = ref.watch(vehiclesProvider);

    return vehiclesAsync.when(
      data: (vehicles) {
        return FutureBuilder(
          future: ref.read(deps.getAllFuelRecordsProvider).call(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData) {
              return const SizedBox.shrink();
            }

            final result = snapshot.data!;

            return result.fold((failure) => const Text('Erro ao carregar dados'), (
              allRecords,
            ) {
              // Filter by vehicle
              final records = allRecords
                  .where((r) => r.vehicleId == _selectedVehicleId)
                  .toList();
              if (records.isEmpty || _fuelRemaining == null) {
                return const SizedBox.shrink();
              }

              final vehicle = vehicles.firstWhere(
                (v) => v.id == _selectedVehicleId,
              );

              // Calculate average consumption
              double totalLiters = 0;
              double totalKm = 0;

              final sortedRecords = records.toList()
                ..sort((a, b) => a.date.compareTo(b.date));

              for (int i = 1; i < sortedRecords.length; i++) {
                final current = sortedRecords[i];
                final previous = sortedRecords[i - 1];

                if (current.fullTank && previous.fullTank) {
                  final kmDiff = current.odometer - previous.odometer;
                  if (kmDiff > 0) {
                    totalKm += kmDiff;
                    totalLiters += current.liters;
                  }
                }
              }

              final averageConsumption = totalLiters > 0
                  ? totalKm / totalLiters
                  : 0.0;

              if (averageConsumption == 0) {
                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.orange.shade200),
                  ),
                  child: const Text(
                    'Dados insuficientes para calcular autonomia. Registre mais abastecimentos completos.',
                    style: TextStyle(fontSize: 13),
                    textAlign: TextAlign.center,
                  ),
                );
              }

              // Convert percentage to liters if needed
              double fuelInLiters = _fuelRemaining!;
              if (_usePercentage && vehicle.tankCapacity != null) {
                fuelInLiters = (vehicle.tankCapacity! * _fuelRemaining!) / 100;
              } else if (_usePercentage) {
                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.orange.shade200),
                  ),
                  child: const Text(
                    'Configure a capacidade do tanque nas informações do veículo para usar porcentagem.',
                    style: TextStyle(fontSize: 13),
                    textAlign: TextAlign.center,
                  ),
                );
              }

              final estimatedRange = fuelInLiters * averageConsumption;

              return Column(
                children: [
                  _buildRangeResultCard(
                    estimatedRange,
                    fuelInLiters,
                    averageConsumption,
                  ),
                  if (_destinationKm != null) ...[
                    const SizedBox(height: 16),
                    _buildDestinationResultCard(
                      estimatedRange,
                      _destinationKm!,
                    ),
                  ],
                ],
              );
            });
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Text('Erro: $error'),
    );
  }

  Widget _buildRangeResultCard(
    double range,
    double fuelLiters,
    double consumption,
  ) {
    final color = range < 50
        ? Colors.red
        : range < 100
        ? Colors.orange
        : Colors.green;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.shade400, color.shade600],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            range < 50 ? Icons.warning : Icons.check_circle,
            color: Colors.white,
            size: 48,
          ),
          const SizedBox(height: 16),
          const Text(
            'Autonomia Estimada',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${range.toStringAsFixed(0)} km',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 48,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          Divider(color: Colors.white.withValues(alpha: 0.3)),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Column(
                children: [
                  const Text(
                    'Combustível',
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${fuelLiters.toStringAsFixed(1)} L',
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
                    'Consumo Médio',
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${consumption.toStringAsFixed(1)} km/L',
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
          if (range < 50) ...[
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                children: [
                  Icon(Icons.warning_amber, color: Colors.white, size: 20),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Autonomia baixa! Abasteça o quanto antes.',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDestinationResultCard(double range, double destinationKm) {
    final canReach = range >= destinationKm;
    final color = canReach ? Colors.green : Colors.red;
    final difference = (range - destinationKm).abs();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.shade300, width: 2),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                canReach ? Icons.check_circle : Icons.cancel,
                color: color.shade700,
                size: 32,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      canReach
                          ? 'Você consegue chegar!'
                          : 'Combustível insuficiente',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: color.shade900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      canReach
                          ? 'Sobrará cerca de ${difference.toStringAsFixed(0)} km de autonomia'
                          : 'Faltam cerca de ${difference.toStringAsFixed(0)} km',
                      style: TextStyle(fontSize: 13, color: color.shade700),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (!canReach) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.local_gas_station,
                    color: Colors.red.shade700,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Você precisará abastecer antes de chegar ao destino',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

import 'package:core/core.dart';
import 'package:flutter/material.dart';

import '../../../../core/widgets/semantic_widgets.dart';
import '../../../../shared/widgets/enhanced_vehicle_selector.dart';
import '../../../expenses/domain/entities/expense_entity.dart';
import '../../../fuel/domain/entities/fuel_record_entity.dart';
import '../../../maintenance/domain/entities/maintenance_entity.dart';
import '../../../odometer/domain/entities/odometer_entity.dart';
import '../../../vehicles/presentation/providers/vehicles_notifier.dart';
import '../providers/activities_providers.dart';
import '../widgets/expense_record_item.dart';
import '../widgets/fuel_record_item.dart';
import '../widgets/maintenance_record_item.dart';
import '../widgets/odometer_record_item.dart';
import '../widgets/recent_records_card.dart';

/// Activities page showing recent records from all categories
///
/// Displays last 3 records from:
/// - Odometer readings
/// - Fuel records
/// - Expenses
/// - Maintenance records
///
/// Follows exact patterns from expenses_page.dart and fuel_page.dart
class ActivitiesPage extends ConsumerStatefulWidget {
  const ActivitiesPage({super.key});

  @override
  ConsumerState<ActivitiesPage> createState() => _ActivitiesPageState();
}

class _ActivitiesPageState extends ConsumerState<ActivitiesPage> {
  String? _selectedVehicleId;

  @override
  Widget build(BuildContext context) {
    final vehiclesAsync = ref.watch(vehiclesProvider);

    return SafeArea(
      child: Column(
        children: [
          // Header (always visible)
          _buildHeader(context),

          // Vehicle Selector
          _buildVehicleSelector(context),

          // Content area
          Expanded(
            child: vehiclesAsync.when(
              data: (vehicles) {
                // Sempre mostra os cards, mesmo sem veículos
                return _buildCardsContent(context, hasVehicles: vehicles.isNotEmpty);
              },
              loading: () => const Center(
                child: CircularProgressIndicator(),
              ),
              error: (error, stack) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 48, color: Colors.red),
                    const SizedBox(height: 16),
                    Text(
                      'Erro ao carregar veículos',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      error.toString(),
                      style: Theme.of(context).textTheme.bodySmall,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
      child: Container(
        margin: const EdgeInsets.fromLTRB(0, 0, 0, 0),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).primaryColor.withValues(alpha: 0.2),
              blurRadius: 9,
              offset: const Offset(0, 3),
              spreadRadius: 0,
            ),
          ],
        ),
        child: Row(
          children: [
            Semantics(
              label: 'Seção de atividades',
              hint: 'Página principal para visualizar atividades recentes dos veículos',
              child: Container(
                padding: const EdgeInsets.all(9),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: const Icon(
                  Icons.history,
                  color: Colors.white,
                  size: 19,
                ),
              ),
            ),
            const SizedBox(width: 13),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  SemanticText.heading(
                    'Atividades',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      height: 1.2,
                    ),
                  ),
                  SizedBox(height: 3),
                  SemanticText.subtitle(
                    'Últimas atividades dos seus veículos',
                    style: TextStyle(
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

  Widget _buildVehicleSelector(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      child: EnhancedVehicleSelector(
        selectedVehicleId: _selectedVehicleId,
        onVehicleChanged: (vehicleId) {
          setState(() {
            _selectedVehicleId = vehicleId;
          });
        },
      ),
    );
  }

  Widget _buildCardsContent(BuildContext context, {required bool hasVehicles}) {
    final primaryColor = Theme.of(context).primaryColor;

    // Se não há veículos, mostra os cards vazios com mensagem apropriada
    if (!hasVehicles) {
      return SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        child: Column(
          children: [
            // Odometer Card
            RecentRecordsCard(
              title: 'Odômetro',
              icon: Icons.speed,
              iconColor: primaryColor,
              recordItems: const [],
              onViewAll: () => context.push('/vehicles/add'),
              isEmpty: true,
              emptyMessage: 'Nenhum veículo cadastrado',
            ),

            // Fuel Card
            RecentRecordsCard(
              title: 'Abastecimentos',
              icon: Icons.local_gas_station,
              iconColor: primaryColor,
              recordItems: const [],
              onViewAll: () => context.push('/vehicles/add'),
              isEmpty: true,
              emptyMessage: 'Nenhum veículo cadastrado',
            ),

            // Expenses Card
            RecentRecordsCard(
              title: 'Despesas',
              icon: Icons.attach_money,
              iconColor: primaryColor,
              recordItems: const [],
              onViewAll: () => context.push('/vehicles/add'),
              isEmpty: true,
              emptyMessage: 'Nenhum veículo cadastrado',
            ),

            // Maintenance Card
            RecentRecordsCard(
              title: 'Manutenções',
              icon: Icons.build,
              iconColor: primaryColor,
              recordItems: const [],
              onViewAll: () => context.push('/vehicles/add'),
              isEmpty: true,
              emptyMessage: 'Nenhum veículo cadastrado',
            ),
          ],
        ),
      );
    }

    // Se há veículos mas nenhum selecionado, também mostra cards vazios
    if (_selectedVehicleId == null) {
      return SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        child: Column(
          children: [
            // Odometer Card
            RecentRecordsCard(
              title: 'Odômetro',
              icon: Icons.speed,
              iconColor: primaryColor,
              recordItems: const [],
              onViewAll: () {},
              isEmpty: true,
              emptyMessage: 'Selecione um veículo acima',
              onAddFirst: null,
            ),

            // Fuel Card
            RecentRecordsCard(
              title: 'Abastecimentos',
              icon: Icons.local_gas_station,
              iconColor: primaryColor,
              recordItems: const [],
              onViewAll: () {},
              isEmpty: true,
              emptyMessage: 'Selecione um veículo acima',
              onAddFirst: null,
            ),

            // Expenses Card
            RecentRecordsCard(
              title: 'Despesas',
              icon: Icons.attach_money,
              iconColor: primaryColor,
              recordItems: const [],
              onViewAll: () {},
              isEmpty: true,
              emptyMessage: 'Selecione um veículo acima',
              onAddFirst: null,
            ),

            // Maintenance Card
            RecentRecordsCard(
              title: 'Manutenções',
              icon: Icons.build,
              iconColor: primaryColor,
              recordItems: const [],
              onViewAll: () {},
              isEmpty: true,
              emptyMessage: 'Selecione um veículo acima',
              onAddFirst: null,
            ),
          ],
        ),
      );
    }

    // Se há veículos e um está selecionado, busca as atividades
    final activitiesAsync = ref.watch(activitiesProvider(_selectedVehicleId!));

    return activitiesAsync.when(
      data: (activities) {
        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Column(
            children: [
              // Odometer Card
              RecentRecordsCard(
                title: 'Odômetro',
                icon: Icons.speed,
                iconColor: primaryColor,
                recordItems: activities.odometerRecords
                    .map((OdometerEntity record) => OdometerRecordItem(
                          record: record,
                          onTap: () => context.push('/odometer'),
                        ))
                    .toList(),
                onViewAll: () => context.push('/odometer'),
                isEmpty: activities.odometerRecords.isEmpty,
                emptyMessage: 'Nenhuma leitura de odômetro registrada',
              ),

              // Fuel Card
              RecentRecordsCard(
                title: 'Abastecimentos',
                icon: Icons.local_gas_station,
                iconColor: primaryColor,
                recordItems: activities.fuelRecords
                    .map((FuelRecordEntity record) => FuelRecordItem(
                          record: record,
                          onTap: () => context.push('/fuel'),
                        ))
                    .toList(),
                onViewAll: () => context.push('/fuel'),
                isEmpty: activities.fuelRecords.isEmpty,
                emptyMessage: 'Nenhum abastecimento registrado',
              ),

              // Expenses Card
              RecentRecordsCard(
                title: 'Despesas',
                icon: Icons.attach_money,
                iconColor: primaryColor,
                recordItems: activities.expenses
                    .map((ExpenseEntity record) => ExpenseRecordItem(
                          record: record,
                          onTap: () => context.push('/expenses'),
                        ))
                    .toList(),
                onViewAll: () => context.push('/expenses'),
                isEmpty: activities.expenses.isEmpty,
                emptyMessage: 'Nenhuma despesa registrada',
              ),

              // Maintenance Card
              RecentRecordsCard(
                title: 'Manutenções',
                icon: Icons.build,
                iconColor: primaryColor,
                recordItems: activities.maintenanceRecords
                    .map((MaintenanceEntity record) => MaintenanceRecordItem(
                          record: record,
                          onTap: () => context.push('/maintenance'),
                        ))
                    .toList(),
                onViewAll: () => context.push('/maintenance'),
                isEmpty: activities.maintenanceRecords.isEmpty,
                emptyMessage: 'Nenhuma manutenção registrada',
              ),
            ],
          ),
        );
      },
      loading: () => const Center(
        child: CircularProgressIndicator(),
      ),
      error: (error, stack) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                'Erro ao carregar atividades',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                error.toString(),
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: () {
                  ref.invalidate(activitiesProvider(_selectedVehicleId!));
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Tentar Novamente'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

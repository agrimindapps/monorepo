import 'package:core/core.dart';
import 'package:flutter/material.dart';

import '../../../../core/utils/date_utils.dart' as local_date_utils;
import '../../../../core/widgets/enhanced_empty_state.dart';
import '../../../../core/widgets/semantic_widgets.dart';
import '../../../../core/widgets/standard_loading_view.dart';
import '../../../../shared/widgets/enhanced_vehicle_selector.dart';
import '../../../vehicles/presentation/providers/vehicles_notifier.dart';
import '../../domain/entities/expense_entity.dart';
import '../notifiers/expenses_notifier.dart';
import '../state/expenses_state.dart';
import 'add_expense_page.dart';

class ExpensesPage extends ConsumerStatefulWidget {
  const ExpensesPage({super.key});

  @override
  ConsumerState<ExpensesPage> createState() => _ExpensesPageState();
}

class _ExpensesPageState extends ConsumerState<ExpensesPage> {
  String? _selectedVehicleId;

  @override
  Widget build(BuildContext context) {
    final vehiclesAsync = ref.watch(vehiclesNotifierProvider);
    final expensesState = ref.watch(expensesNotifierProvider);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            _buildVehicleSelector(context),
            if (_selectedVehicleId != null &&
                (vehiclesAsync.value?.isNotEmpty ?? false))
              _buildMonthSelector(expensesState),
            Expanded(
              child: vehiclesAsync.when(
                data: (vehicles) {
                  if (_selectedVehicleId == null) {
                    return _buildSelectVehicleState();
                  }
                  return _buildContent(context, expensesState);
                },
                loading: () => const StandardLoadingView(
                  message: 'Carregando veículos...',
                  showProgress: true,
                ),
                error: (error, _) => EnhancedEmptyState(
                  title: 'Erro ao carregar veículos',
                  description: error.toString(),
                  icon: Icons.error_outline,
                  actionLabel: 'Tentar novamente',
                  onAction: () {
                    ref.read(vehiclesNotifierProvider.notifier).refresh();
                  },
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
              label: 'Seção de despesas',
              hint: 'Página principal para gerenciar despesas do veículo',
              child: Container(
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
            ),
            const SizedBox(width: 13),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  SemanticText.heading(
                    'Despesas',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      height: 1.2,
                    ),
                  ),
                  SizedBox(height: 3),
                  SemanticText.subtitle(
                    'Histórico de despesas dos seus veículos',
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
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
      child: EnhancedVehicleSelector(
        selectedVehicleId: _selectedVehicleId,
        onVehicleChanged: (vehicleId) {
          setState(() {
            _selectedVehicleId = vehicleId;
          });
          if (vehicleId != null) {
            ref
                .read(expensesNotifierProvider.notifier)
                .loadExpensesByVehicle(vehicleId);
          }
        },
        hintText: 'Selecione um veículo',
      ),
    );
  }

  Widget _buildMonthSelector(ExpensesState state) {
    final vehicleRecords =
        state.expenses.where((r) => r.vehicleId == _selectedVehicleId).toList();

    final months = _getMonths(vehicleRecords);
    final selectedMonth = state.filtersConfig.selectedMonth;

    return Container(
      height: 50,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: months.length,
        itemBuilder: (context, index) {
          final month = months[index];
          final isSelected = selectedMonth != null &&
              month.year == selectedMonth.year &&
              month.month == selectedMonth.month;

          final monthName = DateFormat('MMM yy', 'pt_BR').format(month);
          final formattedMonth =
              monthName[0].toUpperCase() + monthName.substring(1);

          return GestureDetector(
            onTap: () {
              if (isSelected) {
                ref.read(expensesNotifierProvider.notifier).clearMonthFilter();
              } else {
                ref.read(expensesNotifierProvider.notifier).selectMonth(month);
              }
            },
            child: Container(
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected
                    ? Theme.of(context).primaryColor
                    : Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected
                      ? Theme.of(context).primaryColor
                      : Theme.of(context).dividerColor.withValues(alpha: 0.2),
                ),
              ),
              child: Center(
                child: Text(
                  formattedMonth,
                  style: TextStyle(
                    color: isSelected
                        ? Colors.white
                        : Theme.of(context).textTheme.bodyMedium?.color,
                    fontWeight:
                        isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildContent(BuildContext context, ExpensesState state) {
    if (state.isLoading && !state.hasActiveFilters) {
      return const StandardLoadingView(
        message: 'Carregando despesas...',
        showProgress: true,
      );
    }

    if (state.error != null && state.filteredExpenses.isEmpty) {
      return EnhancedEmptyState(
        title: 'Erro ao carregar',
        description: state.error!,
        icon: Icons.error_outline,
        actionLabel: 'Tentar novamente',
        onAction: () {
          if (_selectedVehicleId != null) {
            ref
                .read(expensesNotifierProvider.notifier)
                .loadExpensesByVehicle(_selectedVehicleId!);
          }
        },
      );
    }

    final records = state.filteredExpenses;

    if (records.isEmpty) {
      return EnhancedEmptyState(
        title: 'Nenhuma despesa',
        description: state.hasActiveFilters
            ? 'Nenhum registro encontrado com os filtros aplicados.'
            : 'Adicione sua primeira despesa para começar a acompanhar seus gastos.',
        icon: Icons.attach_money_outlined,
        actionLabel: state.hasActiveFilters ? 'Limpar filtros' : null,
        onAction: state.hasActiveFilters
            ? () => ref.read(expensesNotifierProvider.notifier).clearFilters()
            : null,
      );
    }

    return _buildExpenseList(records);
  }

  Widget _buildExpenseList(List<ExpenseEntity> records) {
    return RefreshIndicator(
      onRefresh: () async {
        if (_selectedVehicleId != null) {
          await ref
              .read(expensesNotifierProvider.notifier)
              .loadExpensesByVehicle(_selectedVehicleId!);
        }
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: records.length,
        itemBuilder: (context, index) {
          final record = records[index];
          return _buildExpenseCard(record);
        },
      ),
    );
  }

  Widget _buildExpenseCard(ExpenseEntity record) {
    final date = record.date;
    final formattedDate = '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    record.title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  'R\$ ${record.amount.toStringAsFixed(2)}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  size: 16,
                  color: Theme.of(context).textTheme.bodySmall?.color,
                ),
                const SizedBox(width: 4),
                Text(
                  formattedDate,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(width: 16),
                Icon(
                  Icons.speed,
                  size: 16,
                  color: Theme.of(context).textTheme.bodySmall?.color,
                ),
                const SizedBox(width: 4),
                Text(
                  '${record.odometer.toStringAsFixed(0)} km',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: record.type.color.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        record.type.icon,
                        size: 12,
                        color: record.type.color,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        record.type.displayName,
                        style: TextStyle(
                          color: record.type.color,
                          fontSize: 12,
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
    );
  }

  Widget _buildFloatingActionButton(BuildContext context) {
    final vehiclesAsync = ref.watch(vehiclesNotifierProvider);
    final hasVehicles = vehiclesAsync.value?.isNotEmpty ?? false;
    final isEnabled = hasVehicles && _selectedVehicleId != null;

    return FloatingActionButton(
      onPressed: () {
        if (_selectedVehicleId == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Selecione um veículo primeiro'),
              duration: Duration(seconds: 2),
            ),
          );
          return;
        }
        showDialog<bool>(
          context: context,
          builder: (context) => AddExpensePage(vehicleId: _selectedVehicleId),
        ).then((result) {
          if (result == true && _selectedVehicleId != null) {
            ref
                .read(expensesNotifierProvider.notifier)
                .loadExpensesByVehicle(_selectedVehicleId!);
          }
        });
      },
      backgroundColor: isEnabled ? null : Colors.grey,
      tooltip: 'Adicionar despesa',
      child: const Icon(Icons.add),
    );
  }

  Widget _buildSelectVehicleState() {
    return const EnhancedEmptyState(
      title: 'Selecione um veículo',
      description: 'Escolha um veículo acima para visualizar suas despesas.',
      icon: Icons.attach_money_outlined,
    );
  }

  List<DateTime> _getMonths(List<ExpenseEntity> records) {
    final dates = records.map((e) => e.date).toList();
    final dateUtils = local_date_utils.DateUtils();
    return dateUtils.generateMonthRange(dates);
  }
}

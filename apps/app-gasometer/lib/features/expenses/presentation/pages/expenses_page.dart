import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/presentation/widgets/semantic_widgets.dart';
import '../../../../core/presentation/widgets/standard_loading_view.dart';
import '../../../../core/theme/design_tokens.dart';
import '../../../../shared/widgets/enhanced_vehicle_selector.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../vehicles/presentation/pages/add_vehicle_page.dart';
import '../../../vehicles/presentation/providers/vehicles_provider.dart';
import '../../domain/entities/expense_entity.dart';
import '../pages/add_expense_page.dart';
import '../providers/expense_form_provider.dart';
import '../providers/expenses_provider.dart';
import '../widgets/expenses_empty_state.dart';
import '../widgets/expenses_error_state.dart';
import '../widgets/expenses_statistics_row.dart';

class ExpensesPage extends StatefulWidget {
  const ExpensesPage({super.key});

  @override
  State<ExpensesPage> createState() => _ExpensesPageState();
}

class _ExpensesPageState extends State<ExpensesPage> {
  String? _selectedVehicleId;
  
  // Performance fix: Cached providers
  late final ExpensesProvider _expensesProvider;
  late final VehiclesProvider _vehiclesProvider;

  @override
  void initState() {
    super.initState();
    // Performance fix: Cache providers once in initState
    _expensesProvider = context.read<ExpensesProvider>();
    _vehiclesProvider = context.read<VehiclesProvider>();
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Verificar se o widget ainda está montado antes de carregar dados
      if (mounted) {
        _loadData();
      }
    });
  }

  void _loadData() {
    // Performance fix: Use cached providers
    _vehiclesProvider.initialize().then((_) {
      if (_selectedVehicleId?.isNotEmpty == true) {
        _expensesProvider.loadExpensesByVehicle(_selectedVehicleId!);
      } else {
        _expensesProvider.loadExpenses();
      }
    });
  }


  // Performance fix: Use cached provider instead of context.read()
  String _getVehicleName(String vehicleId) {
    final vehicle = _vehiclesProvider.vehicles.where((v) => v.id == vehicleId).firstOrNull;
    return vehicle?.displayName ?? 'Veículo desconhecido';
  }

  @override
  Widget build(BuildContext context) {
    // Performance fix: Use Selector2 instead of Consumer2 to prevent unnecessary rebuilds
    return Selector2<ExpensesProvider, VehiclesProvider, Map<String, dynamic>>(
      selector: (context, expensesProvider, vehiclesProvider) => {
        'isLoading': expensesProvider.isLoading,
        'hasError': expensesProvider.hasError,
        'expenses': expensesProvider.expenses,
        'expensesError': expensesProvider.error?.displayMessage,
        'vehiclesError': vehiclesProvider.errorMessage,
      },
      builder: (context, data, child) {
        final isLoading = data['isLoading'] as bool;
        final hasError = data['hasError'] as bool;
        final expenses = data['expenses'] as List<ExpenseEntity>;
        final expensesError = data['expensesError'] as String?;
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
                          child: _buildContentOptimized(context, isLoading, hasError, expenses, expensesError),
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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                SemanticText.heading(
                  'Despesas',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 3),
                SemanticText.subtitle(
                  'Histórico de despesas dos seus veículos',
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

  // Performance fix: Optimized content builder with selective data consumption
  Widget _buildContentOptimized(BuildContext context, bool isLoading, bool hasError, List<ExpenseEntity> expenses, String? errorMessage) {
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
                
                if (_expensesProvider.searchQuery.isNotEmpty) {
                  _expensesProvider.search('');
                }
                
                if (vehicleId?.isNotEmpty == true) {
                  _expensesProvider.loadExpensesByVehicle(vehicleId!);
                } else {
                  _expensesProvider.loadExpenses();
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
            message: 'Carregando despesas...',
            height: 400,
          )
        else if (expenses.isEmpty)
          _buildEmptyState()
        else ...[
          // Statistics with Consumer for live updates
          Consumer<ExpensesProvider>(
            builder: (context, expensesProvider, child) => _buildStatistics(expensesProvider),
          ),
          const SizedBox(height: 24),
          _buildVirtualizedRecordsList(expenses),
        ],
      ],
    );
  }

  Widget _buildStatistics(ExpensesProvider expensesProvider) {
    // Use cached statistics from provider instead of calculating in build method
    final statistics = expensesProvider.stats;
    return ExpensesStatisticsRow(statistics: statistics);
  }

  // Performance fix: Virtualized list that can handle 1000+ records efficiently
  Widget _buildVirtualizedRecordsList(List<ExpenseEntity> records) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SemanticText.heading(
          'Histórico de Despesas',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 16),
        // Performance fix: Properly virtualized list with fixed height
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.6, // Dynamic height based on screen
          child: ListView.builder(
            // Remove shrinkWrap and NeverScrollableScrollPhysics for proper virtualization
            itemCount: records.length,
            // Removed itemExtent to allow dynamic height based on content
            itemBuilder: (context, index) {
              return Consumer<VehiclesProvider>(
                builder: (context, vehiclesProvider, child) {
                  return _OptimizedExpenseRecordCard(
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

  Widget _buildEmptyState() {
    return Center(
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.6,
        child: ExpensesEmptyState(),
      ),
    );
  }

  Widget _buildFloatingActionButton(BuildContext context) {
    final hasSelectedVehicle = _selectedVehicleId != null;
    
    return FloatingActionButton(
      onPressed: hasSelectedVehicle ? _showAddExpenseDialog : _showSelectVehicleMessage,
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
          ? 'Adicionar registro de despesa' 
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

  Future<void> _showAddExpenseDialog() async {
    try {
      // Get providers before opening dialog to avoid context issues
      final authProvider = context.read<AuthProvider>();
      final userId = authProvider.currentUser?.uid;
      
      if (userId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Usuário não autenticado')),
        );
        return;
      }
      
      final result = await showDialog<dynamic>(
        context: context,
        builder: (dialogContext) => MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => ExpenseFormProvider(
              initialVehicleId: _selectedVehicleId,
              userId: userId,
            )),
            ChangeNotifierProvider.value(value: _vehiclesProvider),
            ChangeNotifierProvider.value(value: authProvider),
          ],
          builder: (context, child) => AddExpensePage(
            vehicleId: _selectedVehicleId,
          ),
        ),
      );
      
      // Handle dialog result
      if (result != null && mounted) {
        if (result is Map<String, dynamic> && result['success'] == true) {
          // Recarregar dados após adicionar despesa
          _loadData();
          
          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message']?.toString() ?? 'Despesa adicionada com sucesso!'),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
            ),
          );
        } else if (result == true) {
          // Fallback for old boolean return
          _loadData();
        }
      }
    } catch (e) {
      debugPrint('Error opening add expense dialog: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erro ao abrir formulário de despesa')),
        );
      }
    }
  }

  Future<void> _showEditExpenseDialog(String expenseId, String vehicleId) async {
    // Get providers before opening dialog to avoid context issues
    final authProvider = context.read<AuthProvider>();
    final userId = authProvider.currentUser?.uid;
    
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Usuário não autenticado')),
      );
      return;
    }
    
    // Get the expense to edit
    final expenseToEdit = _expensesProvider.getExpenseById(expenseId);
    if (expenseToEdit == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Despesa não encontrada')),
      );
      return;
    }
    
    final result = await showDialog<dynamic>(
      context: context,
      builder: (dialogContext) => MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => ExpenseFormProvider(
            initialVehicleId: vehicleId,
            userId: userId,
          )),
          ChangeNotifierProvider.value(value: _vehiclesProvider),
          ChangeNotifierProvider.value(value: authProvider),
        ],
        builder: (context, child) => AddExpensePage(
          vehicleId: vehicleId,
          editExpenseId: expenseToEdit.id,
        ),
      ),
    );
    
    // Handle dialog result
    if (result != null && mounted) {
      if (result is Map<String, dynamic> && result['success'] == true) {
        // Recarregar dados após editar despesa
        _loadData();
        
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message']?.toString() ?? 'Despesa editada com sucesso!'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else if (result == true) {
        // Fallback for old boolean return
        _loadData();
      }
    }
  }

  void _showRecordDetails(ExpenseEntity record, VehiclesProvider vehiclesProvider) {
    final vehicleName = _getVehicleName(record.vehicleId);
    final formattedDate = '${record.date.day}/${record.date.month}/${record.date.year}';
    
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Semantics(
              label: 'Ícone de despesa',
              child: Icon(record.type.icon, color: record.type.color),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: SemanticText.heading(vehicleName),
            ),
          ],
        ),
        content: Semantics(
          label: 'Detalhes da despesa de $vehicleName em $formattedDate',
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailRow('Tipo', record.type.displayName),
              _buildDetailRow('Descrição', record.description),
              _buildDetailRow('Valor', record.formattedAmount),
              _buildDetailRow('Odômetro', record.formattedOdometer),
              _buildDetailRow('Data', formattedDate),
              if (record.hasLocation)
                _buildDetailRow('Local', record.location!),
              if (record.hasNotes)
                _buildDetailRow('Observações', record.notes!),
            ],
          ),
        ),
        actions: [
          SemanticButton(
            semanticLabel: 'Fechar detalhes',
            semanticHint: 'Fecha a janela de detalhes da despesa',
            type: ButtonType.text,
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }

  void _showRecordMenu(ExpenseEntity record) {
    final vehicleName = _getVehicleName(record.vehicleId);
    final formattedDate = '${record.date.day}/${record.date.month}/${record.date.year}';
    final recordDescription = 'despesa de $vehicleName em $formattedDate';
    
    showModalBottomSheet<void>(
      context: context,
      builder: (context) => SafeArea(
        child: Semantics(
          label: 'Menu de opções para $recordDescription',
          child: Wrap(
            children: [
              Semantics(
                label: 'Editar $recordDescription',
                hint: 'Abre formulário de edição para modificar os dados desta despesa',
                button: true,
                onTap: () {
                  Navigator.pop(context);
                  _showEditExpenseDialog(record.id, record.vehicleId);
                },
                child: ListTile(
                  leading: const Icon(Icons.edit),
                  title: const Text('Editar'),
                  onTap: () {
                    Navigator.pop(context);
                    _showEditExpenseDialog(record.id, record.vehicleId);
                  },
                ),
              ),
              Semantics(
                label: 'Excluir $recordDescription',
                hint: 'Remove permanentemente este registro de despesa',
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

  void _confirmDeleteRecord(ExpenseEntity record) {
    final vehicleName = _getVehicleName(record.vehicleId);
    final recordDescription = 'despesa de $vehicleName realizada em ${record.date.day}/${record.date.month}/${record.date.year}';
    
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: SemanticText.heading('Confirmar exclusão'),
        content: SemanticText(
          'Tem certeza que deseja excluir este registro de despesa?\n\nEsta ação não pode ser desfeita.',
        ),
        actions: [
          SemanticButton(
            semanticLabel: 'Cancelar exclusão',
            semanticHint: 'Fecha a confirmação sem excluir o registro de despesa',
            type: ButtonType.text,
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          SemanticButton(
            semanticLabel: 'Confirmar exclusão do registro',
            semanticHint: 'Remove permanentemente esta $recordDescription',
            type: ButtonType.elevated,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              Navigator.pop(context);
              
              final success = await _expensesProvider.removeExpense(record.id);
              
              if (mounted) {
                final scaffoldMessenger = ScaffoldMessenger.of(context);
                final message = success 
                  ? 'Registro excluído com sucesso!'
                  : _expensesProvider.error?.displayMessage ?? 'Erro ao excluir registro';
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
    return ExpensesErrorState(
      error: error,
      onRetry: onRetry,
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

/// Widget otimizado para card de despesa
class _OptimizedExpenseRecordCard extends StatelessWidget {
  final ExpenseEntity record;
  final VehiclesProvider vehiclesProvider;
  final VoidCallback onLongPress;
  final VoidCallback onTap;
  final String Function(String) getVehicleName;

  const _OptimizedExpenseRecordCard({
    super.key,
    required this.record,
    required this.vehiclesProvider,
    required this.onLongPress,
    required this.onTap,
    required this.getVehicleName,
  });

  @override
  Widget build(BuildContext context) {
    final date = record.date;
    final formattedDate = '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
    final vehicleName = getVehicleName(record.vehicleId);
    final semanticLabel = 'Despesa $vehicleName em $formattedDate, ${record.type.displayName}, ${record.formattedAmount}${record.hasLocation ? ', ${record.location}' : ''}';

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
                record.description,
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
        color: record.type.color.withOpacity(GasometerDesignTokens.opacityOverlay),
        borderRadius: GasometerDesignTokens.borderRadius(
          GasometerDesignTokens.radiusMd + 2,
        ),
      ),
      child: Icon(
        record.type.icon,
        color: record.type.color,
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
      children: [
        Expanded(
          child: _buildInfoItem(
            context,
            record.type.icon,
            record.type.displayName,
            'Tipo',
          ),
        ),
        Expanded(
          child: _buildInfoItem(
            context,
            Icons.speed,
            '${record.odometer.toStringAsFixed(0)} km',
            'Odômetro',
          ),
        ),
        Expanded(
          child: _buildInfoItem(
            context,
            Icons.attach_money,
            record.formattedAmount,
            'Valor',
          ),
        ),
        if (record.hasReceipt) 
          Flexible(
            child: _buildReceiptBadge(context),
          ),
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
            color: record.type.color,
          ),
          const SizedBox(height: 4),
          SemanticText(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          SemanticText.label(
            label,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildReceiptBadge(BuildContext context) {
    return SemanticStatusIndicator(
      status: 'Comprovante anexado',
      description: 'Esta despesa possui comprovante/foto anexada',
      child: Container(
        padding: GasometerDesignTokens.paddingOnly(
          left: GasometerDesignTokens.spacingSm,
          right: GasometerDesignTokens.spacingSm,
          top: GasometerDesignTokens.spacingXs,
          bottom: GasometerDesignTokens.spacingXs,
        ),
        decoration: BoxDecoration(
          color: Colors.green.withOpacity(GasometerDesignTokens.opacityOverlay),
          borderRadius: GasometerDesignTokens.borderRadius(
            GasometerDesignTokens.radiusSm,
          ),
        ),
        child: SemanticText.label(
          'Recibo',
          style: TextStyle(
            color: Colors.green,
            fontSize: GasometerDesignTokens.fontSizeSm,
            fontWeight: GasometerDesignTokens.fontWeightMedium,
          ),
        ),
      ),
    );
  }
}
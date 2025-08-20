import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/expense_form_provider.dart';
import '../providers/expenses_provider.dart';
import '../../../vehicles/presentation/providers/vehicles_provider.dart';
import '../widgets/expense_form_view.dart';
import '../../domain/entities/expense_entity.dart';
import '../../../../core/presentation/widgets/common_app_bar.dart';
import '../../../../core/presentation/widgets/loading_overlay.dart';
import '../../../../core/presentation/theme/app_theme.dart';

/// Página para adicionar/editar despesas
class AddExpensePage extends StatefulWidget {
  final String? vehicleId;
  final String? userId;
  final ExpenseEntity? expenseToEdit;
  final String? title;

  const AddExpensePage({
    super.key,
    this.vehicleId,
    this.userId,
    this.expenseToEdit,
    this.title,
  });

  @override
  State<AddExpensePage> createState() => _AddExpensePageState();
}

class _AddExpensePageState extends State<AddExpensePage> {
  late ExpenseFormProvider _formProvider;
  bool _isInitialized = false;
  String? _initializationError;

  @override
  void initState() {
    super.initState();
    _initializeProvider();
  }

  void _initializeProvider() async {
    try {
      final vehiclesProvider = context.read<VehiclesProvider>();
      _formProvider = ExpenseFormProvider(
        vehiclesProvider,
        initialVehicleId: widget.vehicleId,
        userId: widget.userId,
      );

      // Inicializar com dados existentes se for edição
      if (widget.expenseToEdit != null) {
        await _formProvider.initializeWithExpense(widget.expenseToEdit!);
      } else {
        await _formProvider.initialize(
          vehicleId: widget.vehicleId,
          userId: widget.userId,
        );
      }

      setState(() {
        _isInitialized = true;
      });
    } catch (e) {
      setState(() {
        _initializationError = e.toString();
      });
    }
  }

  @override
  void dispose() {
    if (_isInitialized) {
      _formProvider.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return Scaffold(
        appBar: CommonAppBar(
          title: _getPageTitle(),
          showBackButton: true,
        ),
        body: _buildLoadingOrError(),
      );
    }

    return ChangeNotifierProvider.value(
      value: _formProvider,
      child: Consumer2<ExpenseFormProvider, ExpensesProvider>(
        builder: (context, formProvider, expensesProvider, child) {
          return LoadingOverlay(
            isLoading: formProvider.isUpdating || expensesProvider.isLoading,
            child: Scaffold(
              appBar: CommonAppBar(
                title: _getPageTitle(),
                showBackButton: true,
                actions: [
                  if (formProvider.formModel.hasChanges)
                    TextButton(
                      onPressed: _handleSave,
                      child: const Text('Salvar'),
                    ),
                ],
              ),
              body: _buildBody(formProvider, expensesProvider),
              bottomNavigationBar: _buildBottomActions(formProvider),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLoadingOrError() {
    if (_initializationError != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: AppTheme.colors.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Erro ao carregar',
              style: AppTheme.textStyles.titleMedium,
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                _initializationError!,
                style: AppTheme.textStyles.bodyMedium?.copyWith(
                  color: AppTheme.colors.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.arrow_back),
              label: const Text('Voltar'),
            ),
          ],
        ),
      );
    }

    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Carregando...'),
        ],
      ),
    );
  }

  Widget _buildBody(ExpenseFormProvider formProvider, ExpensesProvider expensesProvider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Mostrar erro geral se existir
          if (formProvider.formModel.lastError != null ||
              expensesProvider.error != null) ...[
            _buildErrorCard(
              formProvider.formModel.lastError ?? expensesProvider.error!,
            ),
            const SizedBox(height: 16),
          ],

          // Formulário principal
          ExpenseFormView(
            formProvider: formProvider,
            showTitle: false, // Título já está na AppBar
          ),

          const SizedBox(height: 24),

          // Informações do veículo selecionado
          if (formProvider.formModel.vehicle != null) ...[
            _buildVehicleInfo(formProvider.formModel.vehicle!),
            const SizedBox(height: 16),
          ],

          // Dicas contextual baseada no tipo
          _buildTypeHints(formProvider.formModel.expenseType),
        ],
      ),
    );
  }

  Widget _buildErrorCard(String error) {
    return Card(
      color: AppTheme.colors.errorContainer,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            Icon(
              Icons.error_outline,
              color: AppTheme.colors.onErrorContainer,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                error,
                style: AppTheme.textStyles.bodySmall?.copyWith(
                  color: AppTheme.colors.onErrorContainer,
                ),
              ),
            ),
            IconButton(
              onPressed: () {
                _formProvider.clearError();
                context.read<ExpensesProvider>().clearError();
              },
              icon: Icon(
                Icons.close,
                size: 18,
                color: AppTheme.colors.onErrorContainer,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVehicleInfo(dynamic vehicle) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            Icon(
              Icons.directions_car,
              color: AppTheme.colors.primary,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${vehicle.marca} ${vehicle.modelo}',
                    style: AppTheme.textStyles.titleSmall,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Placa: ${vehicle.placa} • ${vehicle.currentOdometer.toStringAsFixed(0)} km',
                    style: AppTheme.textStyles.bodySmall?.copyWith(
                      color: AppTheme.colors.onSurfaceVariant,
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

  Widget _buildTypeHints(ExpenseType type) {
    String hint = '';
    IconData hintIcon = Icons.info_outline;
    
    switch (type) {
      case ExpenseType.insurance:
        hint = 'Seguro anual do veículo. Valor varia conforme cobertura e perfil.';
        hintIcon = Icons.security;
        break;
      case ExpenseType.ipva:
        hint = 'IPVA é calculado sobre o valor venal do veículo.';
        hintIcon = Icons.description;
        break;
      case ExpenseType.fine:
        hint = 'Registre multas para acompanhar infrações de trânsito.';
        hintIcon = Icons.report_problem;
        break;
      case ExpenseType.licensing:
        hint = 'Licenciamento anual obrigatório para circulação.';
        hintIcon = Icons.assignment;
        break;
      default:
        return const SizedBox.shrink();
    }

    return Card(
      color: AppTheme.colors.surfaceVariant.withOpacity(0.3),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            Icon(
              hintIcon,
              color: AppTheme.colors.primary.withOpacity(0.7),
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                hint,
                style: AppTheme.textStyles.bodySmall?.copyWith(
                  color: AppTheme.colors.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomActions(ExpenseFormProvider formProvider) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: AppTheme.colors.surface,
        border: Border(
          top: BorderSide(
            color: AppTheme.colors.outline.withOpacity(0.12),
          ),
        ),
      ),
      child: SafeArea(
        child: Row(
          children: [
            // Botão Limpar
            if (formProvider.formModel.hasChanges) ...[
              OutlinedButton.icon(
                onPressed: _handleClear,
                icon: const Icon(Icons.clear_all),
                label: const Text('Limpar'),
              ),
              const SizedBox(width: 12),
            ],

            // Botão Salvar
            Expanded(
              child: FilledButton.icon(
                onPressed: formProvider.formModel.canSubmit ? _handleSave : null,
                icon: Icon(widget.expenseToEdit != null 
                  ? Icons.save 
                  : Icons.add),
                label: Text(widget.expenseToEdit != null 
                  ? 'Salvar Alterações'
                  : 'Adicionar Despesa'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleSave() async {
    if (!_formProvider.validateForm()) {
      _showErrorSnackBar('Por favor, corrija os erros do formulário');
      return;
    }

    final expensesProvider = context.read<ExpensesProvider>();
    
    bool success;
    if (widget.expenseToEdit != null) {
      success = await expensesProvider.updateExpense(_formProvider.formModel);
    } else {
      success = await expensesProvider.addExpense(_formProvider.formModel);
    }

    if (success) {
      if (mounted) {
        _showSuccessSnackBar(widget.expenseToEdit != null 
          ? 'Despesa atualizada com sucesso!'
          : 'Despesa adicionada com sucesso!');
        Navigator.of(context).pop(true);
      }
    } else {
      _showErrorSnackBar('Erro ao salvar despesa');
    }
  }

  void _handleClear() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Limpar formulário?'),
        content: const Text('Todos os dados não salvos serão perdidos.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
              _formProvider.clearForm();
            },
            child: const Text('Limpar'),
          ),
        ],
      ),
    );
  }

  String _getPageTitle() {
    if (widget.title != null) return widget.title!;
    return widget.expenseToEdit != null ? 'Editar Despesa' : 'Nova Despesa';
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 8),
            Text(message),
          ],
        ),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error, color: Colors.white),
            const SizedBox(width: 8),
            Text(message),
          ],
        ),
        backgroundColor: AppTheme.colors.error,
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: 'OK',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }
}
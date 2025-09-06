import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/presentation/errors/unified_error_handler.dart';
import '../../../../core/presentation/theme/app_theme.dart';
import '../../../../core/presentation/widgets/common_app_bar.dart';
import '../../../../core/presentation/widgets/loading_overlay.dart';
import '../../../vehicles/presentation/providers/vehicles_provider.dart';
import '../../domain/entities/expense_entity.dart';
import '../providers/expense_form_provider.dart';
import '../providers/expenses_provider.dart';
import '../widgets/expense_form_view.dart';

/// Exceção específica para erros de inicialização
class InitializationException implements Exception {
  final String message;
  final dynamic originalError;
  final StackTrace? stackTrace;
  final Map<String, dynamic> context;
  final DateTime timestamp;

  InitializationException({
    required this.message,
    this.originalError,
    this.stackTrace,
    this.context = const {},
  }) : timestamp = DateTime.now();

  @override
  String toString() {
    final buffer = StringBuffer('InitializationException: $message');
    if (originalError != null) {
      buffer.write('\nCaused by: $originalError');
    }
    return buffer.toString();
  }
}

/// Página para adicionar/editar despesas
class AddExpensePage extends StatefulWidget {
  final String? vehicleId;
  final String? userId;
  final ExpenseEntity? expenseToEdit;
  final String? title;

  const AddExpensePage({
    super.key,
    this.vehicleId,
    required this.userId,
    this.expenseToEdit,
    this.title,
  });

  @override
  State<AddExpensePage> createState() => _AddExpensePageState();
}

class _AddExpensePageState extends State<AddExpensePage> {
  ExpenseFormProvider? _formProvider;
  late Future<ExpenseFormProvider> _initializationFuture;
  
  // Progress tracking for better UX
  String _currentStep = '';
  double _progress = 0.0;
  
  @override
  void initState() {
    super.initState();
    // Inicializar usando Future em vez de void async pattern
    _initializationFuture = _initializeProvider();
  }

  /// Inicializa o provider de forma assíncrona e retórna o provider configurado
  Future<ExpenseFormProvider> _initializeProvider() async {
    try {
      debugPrint('🚀 Iniciando inicialização do AddExpensePage...');
      
      // Step 1: Verificações iniciais
      _updateProgress('Verificando estado da aplicação...', 0.1);
      if (!mounted) {
        throw StateError('Widget was disposed during initialization');
      }
      
      // Step 2: Inicializando provider de veículos
      _updateProgress('Carregando dados de veículos...', 0.3);
      final vehiclesProvider = context.read<VehiclesProvider>();
      
      if (!vehiclesProvider.isInitialized) {
        debugPrint('🚗 Inicializando VehiclesProvider...');
        await vehiclesProvider.initialize();
      }
      
      // Step 3: Criando provider do formulário
      _updateProgress('Configurando formulário...', 0.5);
      final formProvider = ExpenseFormProvider(
        initialVehicleId: widget.vehicleId,
        userId: widget.userId,
      );

      // Set context for dependency injection access
      formProvider.setContext(context);

      if (!mounted) {
        formProvider.dispose();
        throw StateError('Widget was disposed during provider initialization');
      }

      // Step 4: Inicializando dados específicos
      if (widget.expenseToEdit != null) {
        _updateProgress('Carregando dados da despesa...', 0.7);
        debugPrint('✏️ Inicializando para edição...');
        await formProvider.initializeWithExpense(widget.expenseToEdit!);
      } else {
        _updateProgress('Preparando nova despesa...', 0.7);
        debugPrint('➕ Inicializando para nova despesa...');
        await formProvider.initialize(
          vehicleId: widget.vehicleId,
          userId: widget.userId,
        );
      }

      if (!mounted) {
        formProvider.dispose();
        throw StateError('Widget was disposed during form initialization');
      }
      
      // Step 5: Finalizando
      _updateProgress('Finalizando...', 1.0);
      debugPrint('✅ Inicialização do AddExpensePage concluída com sucesso');
      _formProvider = formProvider;
      return formProvider;
      
    } catch (e, stackTrace) {
      // Log do erro completo para debugging
      debugPrint('❌ Erro na inicialização do AddExpensePage: $e');
      debugPrint('Stack trace: $stackTrace');
      
      // Re-throw com contexto adicional
      throw InitializationException(
        message: _getFormattedError(e),
        originalError: e,
        stackTrace: stackTrace,
        context: {
          'widget_mounted': mounted,
          'vehicle_id': widget.vehicleId,
          'user_id': widget.userId,
          'is_editing': widget.expenseToEdit != null,
        },
      );
    }
  }
  
  /// Atualiza o progresso da inicialização
  void _updateProgress(String step, double progress) {
    if (mounted) {
      setState(() {
        _currentStep = step;
        _progress = progress;
      });
    }
  }

  /// Formata erro de forma mais amigável para o usuário
  String _getFormattedError(dynamic error) {
    final errorString = error.toString();
    
    if (errorString.contains('Nenhum veículo selecionado')) {
      return 'Nenhum veículo foi selecionado. Por favor, selecione um veículo.';
    } else if (errorString.contains('Veículo não encontrado')) {
      return 'O veículo selecionado não foi encontrado. Tente novamente.';
    } else if (errorString.contains('network')) {
      return 'Erro de conexão. Verifique sua internet e tente novamente.';
    } else if (errorString.contains('auth')) {
      return 'Erro de autenticação. Faça login novamente.';
    } else {
      return 'Erro inesperado: $errorString';
    }
  }

  @override
  void dispose() {
    _formProvider?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<ExpenseFormProvider>(
      future: _initializationFuture,
      builder: (context, snapshot) {
        return Scaffold(
          appBar: CommonAppBar(
            title: _getPageTitle(),
            showBackButton: true,
            actions: [
              // Mostrar ações apenas quando inicializado com sucesso
              if (snapshot.hasData && snapshot.data!.formModel.hasChanges)
                TextButton(
                  onPressed: () => _handleSave(snapshot.data!),
                  child: const Text('Salvar'),
                ),
            ],
          ),
          body: _buildAsyncBody(snapshot),
        );
      },
    );
  }

  /// Constrói o corpo da página baseado no estado do Future
  Widget _buildAsyncBody(AsyncSnapshot<ExpenseFormProvider> snapshot) {
    // Loading state
    if (snapshot.connectionState == ConnectionState.waiting) {
      return _buildLoadingState();
    }
    
    // Error state
    if (snapshot.hasError) {
      return _buildErrorState(snapshot.error!);
    }
    
    // Success state
    if (snapshot.hasData) {
      final formProvider = snapshot.data!;
      return ChangeNotifierProvider.value(
        value: formProvider,
        child: Consumer2<ExpenseFormProvider, ExpensesProvider>(
          builder: (context, formProvider, expensesProvider, child) {
            return LoadingOverlay(
              isLoading: formProvider.isUpdating || expensesProvider.isLoading,
              child: Column(
                children: [
                  Expanded(
                    child: _buildBody(formProvider, expensesProvider),
                  ),
                  _buildBottomActions(formProvider),
                ],
              ),
            );
          },
        ),
      );
    }
    
    // Fallback state (shouldn't happen)
    return _buildUnexpectedState();
  }

  /// Estado de carregamento melhorado com progress indicators
  Widget _buildLoadingState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Progress circular with percentage
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 80,
                  height: 80,
                  child: CircularProgressIndicator(
                    value: _progress,
                    strokeWidth: 6,
                    backgroundColor: AppTheme.colors.outline.withOpacity(0.2),
                  ),
                ),
                Text(
                  '${(_progress * 100).round()}%',
                  style: AppTheme.textStyles.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              'Inicializando formulário',
              style: AppTheme.textStyles.titleMedium,
            ),
            const SizedBox(height: 12),
            // Current step indicator
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: AppTheme.colors.surfaceVariant.withOpacity(0.5),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppTheme.colors.primary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _currentStep,
                    style: AppTheme.textStyles.bodySmall?.copyWith(
                      color: AppTheme.colors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Linear progress bar
            LinearProgressIndicator(
              value: _progress,
              backgroundColor: AppTheme.colors.outline.withOpacity(0.2),
              minHeight: 6,
              borderRadius: BorderRadius.circular(3),
            ),
          ],
        ),
      ),
    );
  }

  /// Estado de erro melhorado com contexto e recovery options
  Widget _buildErrorState(Object error) {
    final initError = error is InitializationException ? error : null;
    final errorMessage = initError?.message ?? _getFormattedError(error);
    
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
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
              'Erro ao inicializar',
              style: AppTheme.textStyles.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              errorMessage,
              style: AppTheme.textStyles.bodyMedium?.copyWith(
                color: AppTheme.colors.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            
            // Mostrar detalhes técnicos em modo debug
            if (kDebugMode && initError != null) ...[
              const SizedBox(height: 16),
              ExpansionTile(
                title: const Text('Detalhes técnicos'),
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'Erro original: ${initError.originalError}\n'
                      'Contexto: ${initError.context}',
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 10,
                      ),
                    ),
                  ),
                ],
              ),
            ],
            
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                OutlinedButton.icon(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('Voltar'),
                ),
                const SizedBox(width: 16),
                FilledButton.icon(
                  onPressed: () {
                    // Reiniciar o Future
                    setState(() {
                      _initializationFuture = _initializeProvider();
                    });
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('Tentar Novamente'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Estado inesperado (fallback)
  Widget _buildUnexpectedState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.help_outline,
            size: 64,
            color: AppTheme.colors.outline,
          ),
          const SizedBox(height: 16),
          Text(
            'Estado inesperado',
            style: AppTheme.textStyles.titleMedium,
          ),
          const SizedBox(height: 8),
          const Text(
            'Algo inesperado aconteceu. Tente voltar e abrir novamente.',
            textAlign: TextAlign.center,
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
              formProvider.formModel.lastError ?? expensesProvider.error?.toString() ?? '',
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
            _buildVehicleInfo(formProvider.formModel.vehicle),
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
                _formProvider?.clearError();
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
                onPressed: () => _handleClear(formProvider),
                icon: const Icon(Icons.clear_all),
                label: const Text('Limpar'),
              ),
              const SizedBox(width: 12),
            ],

            // Botão Salvar
            Expanded(
              child: FilledButton.icon(
                onPressed: formProvider.formModel.canSubmit ? () => _handleSave(formProvider) : null,
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

  Future<void> _handleSave(ExpenseFormProvider formProvider) async {
    if (!formProvider.validateForm()) {
      _showErrorSnackBar('Por favor, corrija os erros do formulário');
      return;
    }

    final expensesProvider = context.read<ExpensesProvider>();
    
    bool success;
    if (widget.expenseToEdit != null) {
      success = await expensesProvider.updateExpense(formProvider.formModel);
    } else {
      success = await expensesProvider.addExpense(formProvider.formModel);
    }

    if (success) {
      if (mounted) {
        // Fechar o dialog imediatamente após sucesso local
        Navigator.of(context).pop(true);
        
        // Mostrar confirmação após fechar o dialog
        _showSuccessSnackBar(widget.expenseToEdit != null 
          ? 'Despesa atualizada com sucesso!'
          : 'Despesa adicionada com sucesso!');
      }
    } else {
      _showErrorSnackBar('Erro ao salvar despesa');
    }
  }

  void _handleClear(ExpenseFormProvider formProvider) {
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
              formProvider.clearForm();
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

  /// ✅ UNIFIED ERROR HANDLING: Using UnifiedErrorHandler
  void _showSuccessSnackBar(String message) {
    UnifiedErrorHandler.showSuccess(context, message);
  }

  void _showErrorSnackBar(String message) {
    UnifiedErrorHandler.showErrorSnackbar(context, message);
  }
}
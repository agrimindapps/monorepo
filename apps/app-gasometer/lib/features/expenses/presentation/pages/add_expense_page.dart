import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/widgets/form_dialog.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/expense_form_provider.dart';
import '../providers/expenses_provider.dart';
import '../widgets/expense_form_view.dart';

/// Dialog modal para adicionar/editar despesas
class AddExpensePage extends StatefulWidget {
  final String? vehicleId;
  final String? editExpenseId;
  
  const AddExpensePage({
    super.key,
    this.vehicleId,
    this.editExpenseId,
  });

  @override
  State<AddExpensePage> createState() => _AddExpensePageState();
}

class _AddExpensePageState extends State<AddExpensePage> {
  late ExpenseFormProvider _formProvider;
  
  // Rate limiting and loading state
  bool _isInitialized = false;
  bool _isSubmitting = false;
  Timer? _debounceTimer;
  Timer? _timeoutTimer;
  
  // Rate limiting constants
  static const Duration _debounceDuration = Duration(milliseconds: 500);
  static const Duration _submitTimeout = Duration(seconds: 30);

  bool get isEditMode => widget.editExpenseId != null;

  @override
  void initState() {
    super.initState();
    // Initialization will be done in didChangeDependencies
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      _initializeProviders();
      _isInitialized = true;
    }
  }
  
  void _initializeProviders() {
    _formProvider = Provider.of<ExpenseFormProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    // Set context for dependency injection access
    _formProvider.setContext(context);

    // Use addPostFrameCallback to avoid setState during build
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _formProvider.initialize(
        vehicleId: widget.vehicleId,
        userId: authProvider.userId,
      );
      
        if (widget.editExpenseId != null) {
          await _loadExpenseForEdit(_formProvider);
        }
      });
    
    // No need for manual setState here - providers will handle notifications
    // The Consumer<ExpenseFormProvider> will automatically rebuild when provider state changes
  }

  Future<void> _loadExpenseForEdit(ExpenseFormProvider provider) async {
    try {
      final expensesProvider = context.read<ExpensesProvider>();
      // Primeiro garantir que os dados foram carregados
      await expensesProvider.loadExpenses();
      
      final expense = expensesProvider.getExpenseById(widget.editExpenseId!);
      
      if (expense != null) {
        await provider.initializeWithExpense(expense);
      } else {
        throw Exception('Registro de despesa não encontrado');
      }
    } catch (e) {
      throw Exception('Erro ao carregar registro para edição: $e');
    }
  }
  
  @override
  void dispose() {
    // Clean up timers to prevent memory leaks
    _debounceTimer?.cancel();
    _timeoutTimer?.cancel();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Consumer<ExpenseFormProvider>(
      builder: (context, formProvider, child) {
        // Generate subtitle based on vehicle information
        String subtitle = 'Registre uma despesa do seu veículo';
        if (formProvider.isInitialized && formProvider.formModel.vehicle != null) {
          final vehicle = formProvider.formModel.vehicle!;
          final odometer = vehicle.currentOdometer;
          subtitle = '${vehicle.brand} ${vehicle.model} • ${_formatOdometer(odometer)} km';
        }

        return FormDialog(
          title: 'Despesa',
          subtitle: subtitle,
          headerIcon: Icons.attach_money,
          isLoading: formProvider.isLoading || _isSubmitting,
          confirmButtonText: 'Salvar',
          onCancel: () => Navigator.of(context).pop(),
          onConfirm: _submitFormWithRateLimit,
          content: !formProvider.isInitialized
              ? const Center(child: CircularProgressIndicator())
              : ExpenseFormView(formProvider: formProvider),
        );
      },
    );
  }

  String _formatOdometer(num odometer) {
    return odometer.toInt().toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
  }

  /// Rate-limited submit method that implements debouncing and prevents rapid clicks
  void _submitFormWithRateLimit() {
    // Prevent multiple rapid clicks
    if (_isSubmitting) {
      debugPrint('Submit already in progress, ignoring duplicate request');
      return;
    }

    // Cancel any existing debounce timer
    _debounceTimer?.cancel();
    
    // Set debounce timer to prevent rapid consecutive submissions
    _debounceTimer = Timer(_debounceDuration, () {
      if (mounted && !_isSubmitting) {
        _submitForm();
      }
    });
  }

  /// Internal submit method with enhanced protection and timeout handling
  Future<void> _submitForm() async {
    // Double-check form validation
    if (!_formProvider.validateForm()) {
      return;
    }

    // Prevent concurrent submissions
    if (_isSubmitting) {
      debugPrint('Submit already in progress, aborting duplicate submission');
      return;
    }

    // Set submitting state
    setState(() {
      _isSubmitting = true;
    });

    final formProvider = _formProvider;
    final expensesProvider = Provider.of<ExpensesProvider>(context, listen: false);

    try {
      // Setup timeout protection
      _timeoutTimer = Timer(_submitTimeout, () {
        if (mounted && _isSubmitting) {
          debugPrint('Submit timeout reached, resetting state');
          setState(() {
            _isSubmitting = false;
          });
          _showErrorDialog(
            'Timeout',
            'A operação demorou muito para ser concluída. Tente novamente.',
          );
        }
      });

      // Provider will handle its own loading state

      final expenseModel = formProvider.formModel;
      
      bool success;
      if (widget.editExpenseId != null) {
        success = await expensesProvider.updateExpense(expenseModel);
      } else {
        success = await expensesProvider.addExpense(expenseModel);
      }

      if (success) {
        if (mounted) {
          // Close dialog with success result for parent context to handle
          Navigator.of(context).pop({
            'success': true,
            'action': widget.editExpenseId != null ? 'edit' : 'create',
            'message': widget.editExpenseId != null 
                ? 'Despesa editada com sucesso!'
                : 'Despesa adicionada com sucesso!',
          });
        }
      } else {
        if (mounted) {
          // Show error in dialog context (before closing)
          final errorMessage = expensesProvider.error?.displayMessage ?? 'Erro ao salvar despesa';
          _showErrorDialog('Erro', errorMessage);
        }
      }
    } catch (e) {
      debugPrint('Error submitting form: $e');
      if (mounted) {
        _showErrorDialog(
          'Erro',
          'Erro inesperado: $e',
        );
      }
    } finally {
      // Clean up timeout timer
      _timeoutTimer?.cancel();
      
      // Loading state managed by provider
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  void _showErrorDialog(String title, String message) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }



}
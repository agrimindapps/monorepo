import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/widgets/form_dialog.dart';
import '../../../auth/presentation/notifiers/notifiers.dart';
import '../models/expense_form_model.dart';
import '../notifiers/expense_form_notifier.dart';
import '../notifiers/expense_form_state.dart';
import '../notifiers/expenses_notifier.dart';
import '../widgets/expense_form_view.dart';

/// Dialog modal para adicionar/editar despesas
class AddExpensePage extends ConsumerStatefulWidget {
  
  const AddExpensePage({
    super.key,
    this.vehicleId,
    this.editExpenseId,
  });
  final String? vehicleId;
  final String? editExpenseId;

  @override
  ConsumerState<AddExpensePage> createState() => _AddExpensePageState();
}

class _AddExpensePageState extends ConsumerState<AddExpensePage> {
  bool _isInitialized = false;
  bool _isSubmitting = false;
  Timer? _debounceTimer;
  Timer? _timeoutTimer;
  static const Duration _debounceDuration = Duration(milliseconds: 500);
  static const Duration _submitTimeout = Duration(seconds: 30);

  bool get isEditMode => widget.editExpenseId != null;

  @override
  void initState() {
    super.initState();
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
    final authState = ref.read(authProvider);
    final formNotifier = ref.read(expenseFormNotifierProvider.notifier);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await formNotifier.initialize(
        vehicleId: widget.vehicleId ?? '',
        userId: authState.userId,
      );

      if (widget.editExpenseId != null) {
        await _loadExpenseForEdit();
      }
    });
  }

  Future<void> _loadExpenseForEdit() async {
    try {
      final expensesNotifier = ref.read(expensesNotifierProvider.notifier);
      final formNotifier = ref.read(expenseFormNotifierProvider.notifier);
      await expensesNotifier.loadExpenses();

      final expensesState = ref.read(expensesNotifierProvider);
      final expense = expensesState.expenses.firstWhere(
        (e) => e.id == widget.editExpenseId,
        orElse: () => throw Exception('Registro de despesa não encontrado'),
      );

      await formNotifier.initializeWithExpense(expense);
    } catch (e) {
      throw Exception('Erro ao carregar registro para edição: $e');
    }
  }
  
  @override
  void dispose() {
    _debounceTimer?.cancel();
    _timeoutTimer?.cancel();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    final formState = ref.watch(expenseFormNotifierProvider);
    final isInitialized = formState.vehicle != null;
    String subtitle = 'Registre uma despesa do seu veículo';
    if (isInitialized && formState.vehicle != null) {
      final vehicle = formState.vehicle!;
      final odometer = vehicle.currentOdometer;
      subtitle = '${vehicle.brand} ${vehicle.model} • ${_formatOdometer(odometer)} km';
    }

    return FormDialog(
      title: 'Despesa',
      subtitle: subtitle,
      headerIcon: Icons.attach_money,
      isLoading: formState.isLoading || _isSubmitting,
      confirmButtonText: 'Salvar',
      onCancel: () => Navigator.of(context).pop(),
      onConfirm: _submitFormWithRateLimit,
      content: !isInitialized
          ? const Center(child: CircularProgressIndicator())
          : const ExpenseFormView(),
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
    if (_isSubmitting) {
      debugPrint('Submit already in progress, ignoring duplicate request');
      return;
    }
    _debounceTimer?.cancel();
    _debounceTimer = Timer(_debounceDuration, () {
      if (mounted && !_isSubmitting) {
        _submitForm();
      }
    });
  }

  /// Internal submit method with enhanced protection and timeout handling
  Future<void> _submitForm() async {
    final formNotifier = ref.read(expenseFormNotifierProvider.notifier);
    if (!formNotifier.validateForm()) {
      return;
    }
    if (_isSubmitting) {
      debugPrint('Submit already in progress, aborting duplicate submission');
      return;
    }
    setState(() {
      _isSubmitting = true;
    });

    final expensesNotifier = ref.read(expensesNotifierProvider.notifier);

    try {
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

      final formState = ref.read(expenseFormNotifierProvider);
      final formModel = _stateToModel(formState);

      bool success;
      if (widget.editExpenseId != null) {
        success = await expensesNotifier.updateExpense(formModel);
      } else {
        success = await expensesNotifier.addExpense(formModel);
      }

      if (success) {
        if (mounted) {
          Navigator.of(context).pop({
            'success': true,
            'action': widget.editExpenseId != null ? 'edit' : 'create',
          });
        }
      } else {
        if (mounted) {
          final expensesState = ref.read(expensesNotifierProvider);
          final errorMessage = expensesState.error ?? 'Erro ao salvar despesa';
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
      _timeoutTimer?.cancel();
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

  /// Converte ExpenseFormState para ExpenseFormModel
  ExpenseFormModel _stateToModel(ExpenseFormState state) {
    return ExpenseFormModel(
      id: state.id,
      userId: state.userId,
      vehicleId: state.vehicleId,
      vehicle: state.vehicle,
      expenseType: state.expenseType,
      description: state.description,
      amount: state.amount,
      odometer: state.odometer,
      date: state.date ?? DateTime.now(),
      location: state.location,
      notes: state.notes,
      receiptImagePath: state.receiptImagePath,
      isLoading: state.isLoading,
      hasChanges: state.hasChanges,
      errors: state.fieldErrors,
      lastError: state.errorMessage,
    );
  }
}
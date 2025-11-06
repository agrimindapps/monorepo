import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/widgets/error_header.dart';
import '../../../../core/widgets/form_dialog.dart';
import '../../../auth/presentation/notifiers/notifiers.dart';
import '../notifiers/expense_form_notifier.dart';
import '../widgets/expense_form_view.dart';

/// Dialog modal para adicionar/editar despesas
class AddExpensePage extends ConsumerStatefulWidget {
  const AddExpensePage({super.key, this.vehicleId, this.editExpenseId});
  final String? vehicleId;
  final String? editExpenseId;

  @override
  ConsumerState<AddExpensePage> createState() => _AddExpensePageState();
}

class _AddExpensePageState extends ConsumerState<AddExpensePage>
    with FormErrorHandlerMixin {
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

      // TODO: Implementar carga de despesa para edição
      // if (widget.editExpenseId != null) {
      //   await _loadExpenseForEdit();
      // }
    });
  }

  // TODO: Implementar carga de despesa para edição
  // Future<void> _loadExpenseForEdit() async {
  //   try {
  //     final formNotifier = ref.read(expenseFormNotifierProvider.notifier);
  //     // Carregar despesa aqui
  //     // await formNotifier.initializeWithExpense(expense);
  //   } catch (e) {
  //     throw Exception('Erro ao carregar registro para edição: $e');
  //   }
  // }

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
      subtitle =
          '${vehicle.brand} ${vehicle.model} • ${_formatOdometer(odometer)} km';
    }

    return FormDialog(
      title: 'Despesa',
      subtitle: subtitle,
      headerIcon: Icons.attach_money,
      isLoading: formState.isLoading || _isSubmitting,
      confirmButtonText: 'Salvar',
      onCancel: () {
        final formNotifier = ref.read(expenseFormNotifierProvider.notifier);
        formNotifier.clearForm();
        Navigator.of(context).pop();
      },
      onConfirm: _submitFormWithRateLimit,
      errorMessage: formErrorMessage,
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
    clearFormError();

    if (!formNotifier.validateForm()) {
      // Pega o primeiro erro para exibir
      final formState = ref.read(expenseFormNotifierProvider);
      if (formState.fieldErrors.isNotEmpty) {
        setFormError(formState.fieldErrors.values.first);
      } else {
        setFormError('Por favor, corrija os campos destacados');
      }
      return;
    }

    if (_isSubmitting) {
      debugPrint('Submit already in progress, aborting duplicate submission');
      return;
    }
    setState(() {
      _isSubmitting = true;
    });

    try {
      _timeoutTimer = Timer(_submitTimeout, () {
        if (mounted && _isSubmitting) {
          debugPrint('Submit timeout reached, resetting state');
          setState(() {
            _isSubmitting = false;
          });
          setFormError(
            'A operação demorou muito para ser concluída. Tente novamente.',
          );
        }
      });

      // Salva o registro usando o UseCase
      final result = await formNotifier.saveExpenseRecord();

      if (mounted) {
        result.fold(
          (failure) {
            debugPrint('[EXPENSE DEBUG] FAILURE - ${failure.message}');
            setFormError(failure.message);
          },
          (success) {
            debugPrint('[EXPENSE DEBUG] SUCCESS - Closing dialog');
            Navigator.of(context).pop({
              'success': true,
              'action': widget.editExpenseId != null ? 'edit' : 'create',
            });
          },
        );
      }
    } catch (e) {
      debugPrint('Error submitting form: $e');
      if (mounted) {
        setFormError('Erro inesperado: $e');
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
}

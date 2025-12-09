import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/widgets/crud_form_dialog.dart';
import '../../../auth/presentation/notifiers/auth_notifier.dart';
import '../notifiers/expense_form_notifier.dart';
import '../notifiers/expenses_notifier.dart';
import '../widgets/expense_form_view.dart';

/// Página de formulário de despesa com suporte a 3 modos:
/// - Create: Novo registro
/// - View: Visualização (campos readonly)
/// - Edit: Edição de registro existente
class ExpenseFormPage extends ConsumerStatefulWidget {
  const ExpenseFormPage({
    super.key,
    this.expenseId,
    this.vehicleId,
    this.initialMode = CrudDialogMode.create,
  });

  /// ID do registro de despesa (para view/edit)
  final String? expenseId;

  /// ID do veículo (para create)
  final String? vehicleId;

  /// Modo inicial do formulário
  final CrudDialogMode initialMode;

  @override
  ConsumerState<ExpenseFormPage> createState() => _ExpenseFormPageState();
}

class _ExpenseFormPageState extends ConsumerState<ExpenseFormPage> {
  final Map<String, FocusNode> _focusNodes = {};
  
  late CrudDialogMode _mode;
  bool _isInitialized = false;
  bool _isSubmitting = false;
  String? _formErrorMessage;
  Timer? _debounceTimer;
  Timer? _timeoutTimer;
  String? _resolvedVehicleId;

  static const Duration _debounceDuration = Duration(milliseconds: 500);
  static const Duration _submitTimeout = Duration(seconds: 30);

  void _setFormError(String? message) {
    setState(() => _formErrorMessage = message);
  }

  @override
  void initState() {
    super.initState();
    _mode = widget.initialMode;
    _focusNodes['description'] = FocusNode();
    _focusNodes['amount'] = FocusNode();
    _focusNodes['odometer'] = FocusNode();
    _focusNodes['location'] = FocusNode();
    _focusNodes['notes'] = FocusNode();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      _isInitialized = true;
      Future.microtask(() => _initializeProviders());
    }
  }

  Future<void> _initializeProviders() async {
    final authState = ref.read(authProvider);
    final userId = authState.userId;

    // Se é view/edit, carregar pelo ID do registro
    if (widget.expenseId != null && widget.expenseId!.isNotEmpty) {
      final expense = ref.read(expensesProvider.notifier)
          .getExpenseById(widget.expenseId!);
      
      if (expense != null) {
        _resolvedVehicleId = expense.vehicleId;
        
        final notifier = ref.read(expenseFormProvider.notifier);
        await notifier.initialize(vehicleId: expense.vehicleId, userId: userId);
        await notifier.initializeWithExpense(expense);
      }
    }
    // Se é create, inicializar com veículo
    else if (widget.vehicleId != null && widget.vehicleId!.isNotEmpty) {
      _resolvedVehicleId = widget.vehicleId;
      final notifier = ref.read(expenseFormProvider.notifier);
      notifier.clearForm();
      await notifier.initialize(vehicleId: widget.vehicleId!, userId: userId);
    }

    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _timeoutTimer?.cancel();
    for (final node in _focusNodes.values) {
      node.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final formState = ref.watch(expenseFormProvider);
    final isReadOnly = _mode == CrudDialogMode.view;

    String subtitle = 'Registre uma despesa do seu veículo';
    if (formState.vehicle != null) {
      final vehicle = formState.vehicle!;
      final odometer = vehicle.currentOdometer;
      subtitle =
          '${vehicle.brand} ${vehicle.model} • ${_formatOdometer(odometer)} km';
    }

    // Se ainda não inicializou, mostrar loading
    if (_resolvedVehicleId == null && _mode != CrudDialogMode.create) {
      return CrudFormDialog(
        mode: _mode,
        title: 'Despesa',
        subtitle: 'Carregando...',
        headerIcon: Icons.attach_money,
        isLoading: true,
        onCancel: () => Navigator.of(context).pop(),
        content: const Center(child: CircularProgressIndicator()),
      );
    }

    return CrudFormDialog(
      mode: _mode,
      title: 'Despesa',
      subtitle: subtitle,
      headerIcon: Icons.attach_money,
      isLoading: formState.isLoading,
      isSaving: _isSubmitting,
      canSave: formState.vehicle != null && !formState.isLoading,
      errorMessage: _formErrorMessage,
      showDeleteButton: _mode != CrudDialogMode.create,
      onModeChange: (newMode) {
        setState(() => _mode = newMode);
      },
      onSave: _submitFormWithRateLimit,
      onCancel: () {
        final formNotifier = ref.read(expenseFormProvider.notifier);
        formNotifier.clearForm();
        Navigator.of(context).pop();
      },
      onDelete: _mode != CrudDialogMode.create ? _handleDelete : null,
      content: formState.vehicle == null
          ? const Center(child: CircularProgressIndicator())
          : ExpenseFormView(
              focusNodes: _focusNodes,
              isReadOnly: isReadOnly,
            ),
    );
  }

  String _formatOdometer(num odometer) {
    return odometer.toInt().toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        );
  }

  void _submitFormWithRateLimit() {
    if (_isSubmitting) return;
    _debounceTimer?.cancel();
    _debounceTimer = Timer(_debounceDuration, () {
      if (mounted && !_isSubmitting) {
        _submitForm();
      }
    });
  }

  Future<void> _submitForm() async {
    final formNotifier = ref.read(expenseFormProvider.notifier);
    _setFormError(null);

    if (!formNotifier.validateForm()) {
      final formState = ref.read(expenseFormProvider);
      if (formState.fieldErrors.isNotEmpty) {
        final firstErrorField = formState.fieldErrors.keys.first;
        _focusNodes[firstErrorField]?.requestFocus();
        _setFormError(formState.fieldErrors.values.first);
      } else {
        _setFormError('Por favor, corrija os campos destacados');
      }
      return;
    }

    if (_isSubmitting) return;
    setState(() => _isSubmitting = true);

    try {
      _timeoutTimer = Timer(_submitTimeout, () {
        if (mounted && _isSubmitting) {
          setState(() => _isSubmitting = false);
          _setFormError('A operação demorou muito. Tente novamente.');
        }
      });

      final result = await formNotifier.saveExpenseRecord();

      if (mounted) {
        result.fold(
          (failure) => _setFormError(failure.message),
          (success) {
            formNotifier.clearForm();
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted && context.mounted) {
                Navigator.of(context).pop(true);
              }
            });
          },
        );
      }
    } catch (e) {
      if (mounted) {
        _setFormError('Erro inesperado: $e');
      }
    } finally {
      _timeoutTimer?.cancel();
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  Future<void> _handleDelete() async {
    final expenseId = widget.expenseId;
    if (expenseId == null || expenseId.isEmpty) return;

    // Fecha o dialog e retorna
    Navigator.of(context).pop();

    // Executa o delete via notifier da lista (com undo)
    await ref.read(expensesProvider.notifier).deleteOptimistic(expenseId);
  }
}

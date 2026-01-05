import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/widgets/crud_form_dialog.dart';
import '../providers/medication_form_notifier.dart';
import '../providers/medications_providers.dart';
import '../widgets/medication_form_view.dart';

class MedicationFormPage extends ConsumerStatefulWidget {
  const MedicationFormPage({
    this.medicationId,
    this.animalId,
    this.initialMode = CrudDialogMode.create,
    super.key,
  });

  final String? medicationId;
  final String? animalId;
  final CrudDialogMode initialMode;

  @override
  ConsumerState<MedicationFormPage> createState() => _MedicationFormPageState();
}

class _MedicationFormPageState extends ConsumerState<MedicationFormPage> {
  late CrudDialogMode _mode;
  bool _isInitialized = false;
  String? _formErrorMessage;
  String? _resolvedAnimalId;
  final _formKey = GlobalKey<FormState>();

  void _setFormError(String? message) {
    setState(() => _formErrorMessage = message);
  }

  @override
  void initState() {
    super.initState();
    _mode = widget.initialMode;
    _resolvedAnimalId = widget.animalId;
    WidgetsBinding.instance.addPostFrameCallback((_) => _initializeForm());
  }

  Future<void> _initializeForm() async {
    if (_isInitialized) return;

    final notifier = ref.read(medicationFormProvider(_resolvedAnimalId).notifier);

    try {
      await notifier.initialize(medicationId: widget.medicationId);

      if (widget.medicationId != null) {
        final state = ref.read(medicationFormProvider(_resolvedAnimalId));
        setState(() {
          _resolvedAnimalId = state.animalId;
        });
      }

      setState(() => _isInitialized = true);
    } catch (e) {
      _setFormError('Erro ao carregar medicamento: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(medicationFormProvider(_resolvedAnimalId));

    if (state.errorMessage != null && _formErrorMessage != state.errorMessage) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _setFormError(state.errorMessage);
      });
    }

    return CrudFormDialog(
      mode: _mode,
      title: 'Medicamento',
      subtitle: _getSubtitle(),
      headerIcon: Icons.medication,
      isLoading: state.isLoading,
      errorMessage: _formErrorMessage,
      showDeleteButton: _mode != CrudDialogMode.create,
      onModeChange: (newMode) => setState(() => _mode = newMode),
      onSave: _handleSave,
      onCancel: () => Navigator.of(context).pop(),
      onDelete: widget.medicationId != null ? _handleDelete : null,
      content: MedicationFormView(
        animalId: _resolvedAnimalId,
        formKey: _formKey,
        isReadOnly: _mode == CrudDialogMode.view,
      ),
    );
  }

  String _getSubtitle() {
    switch (_mode) {
      case CrudDialogMode.create:
        return 'Novo medicamento';
      case CrudDialogMode.view:
        return 'Detalhes do medicamento';
      case CrudDialogMode.edit:
        return 'Editar medicamento';
    }
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) {
      _setFormError('Por favor, corrija os campos inválidos');
      return;
    }

    final notifier = ref.read(medicationFormProvider(_resolvedAnimalId).notifier);
    final success = await notifier.save();

    if (success) {
      ref.invalidate(medicationsProvider);
      if (mounted) Navigator.of(context).pop();
    } else {
      final state = ref.read(medicationFormProvider(_resolvedAnimalId));
      _setFormError(state.errorMessage);
    }
  }

  Future<void> _handleDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar exclusão'),
        content: const Text('Deseja realmente excluir este medicamento?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final notifier = ref.read(medicationFormProvider(_resolvedAnimalId).notifier);
    final success = await notifier.delete();

    if (success) {
      ref.invalidate(medicationsProvider);
      if (mounted) Navigator.of(context).pop();
    } else {
      final state = ref.read(medicationFormProvider(_resolvedAnimalId));
      _setFormError(state.errorMessage);
    }
  }
}

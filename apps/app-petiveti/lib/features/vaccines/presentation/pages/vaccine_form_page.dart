import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/widgets/crud_form_dialog.dart';
import '../../domain/entities/vaccine.dart';
import '../providers/vaccine_form_notifier.dart';
import '../providers/vaccines_provider.dart';
import '../widgets/vaccine_form_view.dart';

/// Página de formulário de vacina com suporte a 3 modos:
/// - Create: Nova vacina
/// - View: Visualização (campos readonly)
/// - Edit: Edição de vacina existente
class VaccineFormPage extends ConsumerStatefulWidget {
  const VaccineFormPage({
    super.key,
    this.vaccineId,
    this.animalId,
    this.initialMode = CrudDialogMode.create,
  });

  /// ID da vacina (para view/edit)
  final String? vaccineId;

  /// ID do animal (para create)
  final String? animalId;

  /// Modo inicial do formulário
  final CrudDialogMode initialMode;

  @override
  ConsumerState<VaccineFormPage> createState() => _VaccineFormPageState();
}

class _VaccineFormPageState extends ConsumerState<VaccineFormPage> {
  late CrudDialogMode _mode;
  bool _isInitialized = false;
  String? _formErrorMessage;
  String? _resolvedAnimalId;

  void _setFormError(String? message) {
    setState(() => _formErrorMessage = message);
  }

  @override
  void initState() {
    super.initState();
    _mode = widget.initialMode;
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
    // Se é view/edit, carregar pelo ID da vacina
    if (widget.vaccineId != null && widget.vaccineId!.isNotEmpty) {
      final vaccinesState = ref.read(vaccinesProvider);
      final vaccine = vaccinesState.vaccines.firstWhere(
        (v) => v.id == widget.vaccineId,
        orElse: () => throw Exception('Vacina não encontrada'),
      );

      _resolvedAnimalId = vaccine.animalId;

      final notifier = ref.read(vaccineFormProvider(vaccine.animalId).notifier);
      await notifier.initialize(
        animalId: vaccine.animalId,
        vaccine: vaccine,
      );
    }
    // Se é create, inicializar com animal
    else if (widget.animalId != null && widget.animalId!.isNotEmpty) {
      _resolvedAnimalId = widget.animalId;
      final notifier = ref.read(vaccineFormProvider(widget.animalId!).notifier);
      notifier.clearForm();
      await notifier.initialize(animalId: widget.animalId!);
    }

    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final animalId = _resolvedAnimalId ?? widget.animalId ?? '';

    if (animalId.isEmpty && _mode == CrudDialogMode.create) {
      return const Center(child: Text('Nenhum animal selecionado'));
    }

    // Se ainda não inicializou, mostrar loading
    if (animalId.isEmpty) {
      return CrudFormDialog(
        mode: _mode,
        title: 'Vacina',
        subtitle: 'Carregando...',
        headerIcon: Icons.vaccines,
        isLoading: true,
        onCancel: () => Navigator.of(context).pop(),
        content: const Center(child: CircularProgressIndicator()),
      );
    }

    final formState = ref.watch(vaccineFormProvider(animalId));
    final isReadOnly = _mode == CrudDialogMode.view;

    String subtitle = 'Registre a vacina do seu pet';
    if (formState.isInitialized && formState.animal != null) {
      final animal = formState.animal!;
      subtitle = '${animal.name} • ${animal.species.name}';
    }

    return CrudFormDialog(
      mode: _mode,
      title: 'Vacina',
      subtitle: subtitle,
      headerIcon: Icons.vaccines,
      isLoading: formState.isLoading,
      isSaving: formState.isSaving,
      canSave: formState.canSave,
      errorMessage: _formErrorMessage,
      showDeleteButton: _mode != CrudDialogMode.create,
      onModeChange: (newMode) {
        setState(() => _mode = newMode);
      },
      onSave: _submitForm,
      onCancel: () {
        final formNotifier = ref.read(vaccineFormProvider(animalId).notifier);
        formNotifier.clearForm();
        Navigator.of(context).pop();
      },
      onDelete: _mode != CrudDialogMode.create ? _handleDelete : null,
      content: !formState.isInitialized
          ? const Center(child: CircularProgressIndicator())
          : VaccineFormView(
              animalId: animalId,
              readOnly: isReadOnly,
            ),
    );
  }

  Future<void> _submitForm() async {
    final animalId = _resolvedAnimalId ?? widget.animalId;
    if (animalId == null) return;

    _setFormError(null);

    try {
      final formNotifier = ref.read(vaccineFormProvider(animalId).notifier);
      final success = await formNotifier.submit();

      if (success && mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      _setFormError('Erro ao salvar vacina: ${e.toString()}');
    }
  }

  Future<void> _handleDelete() async {
    final animalId = _resolvedAnimalId ?? widget.animalId;
    if (animalId == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir Vacina'),
        content: const Text('Tem certeza que deseja excluir esta vacina?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      try {
        final formNotifier = ref.read(vaccineFormProvider(animalId).notifier);
        final success = await formNotifier.delete();

        if (success && mounted) {
          Navigator.of(context).pop(true);
        }
      } catch (e) {
        _setFormError('Erro ao excluir vacina: ${e.toString()}');
      }
    }
  }
}

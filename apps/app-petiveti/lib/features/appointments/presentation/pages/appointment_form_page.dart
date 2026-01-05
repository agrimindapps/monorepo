import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/widgets/crud_form_dialog.dart';
import '../providers/appointment_form_notifier.dart';
import '../providers/appointments_providers.dart';
import '../widgets/appointment_form_view.dart';

class AppointmentFormPage extends ConsumerStatefulWidget {
  const AppointmentFormPage({
    required this.animalId,
    this.appointmentId,
    this.initialMode = CrudDialogMode.create,
    super.key,
  });

  final String animalId;
  final String? appointmentId;
  final CrudDialogMode initialMode;

  @override
  ConsumerState<AppointmentFormPage> createState() => _AppointmentFormPageState();
}

class _AppointmentFormPageState extends ConsumerState<AppointmentFormPage> {
  late CrudDialogMode _mode;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _mode = widget.initialMode;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeForm();
    });
  }

  Future<void> _initializeForm() async {
    if (_isInitialized) return;

    final notifier = ref.read(
      appointmentFormProvider(widget.animalId).notifier,
    );

    // Inicializar (carregar animal e appointment se necessário)
    try {
      await notifier.initialize(
        appointmentId: widget.appointmentId,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao carregar consulta: $e')),
        );
        Navigator.of(context).pop(false);
      }
      return;
    }

    setState(() {
      _isInitialized = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(appointmentFormProvider(widget.animalId));
    final notifier = ref.read(
      appointmentFormProvider(widget.animalId).notifier,
    );

    if (!_isInitialized) {
      return const Dialog(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Carregando...'),
            ],
          ),
        ),
      );
    }

    return CrudFormDialog(
      mode: _mode,
      title: _getTitle(),
      canSave: state.canSave,
      isSaving: state.isSaving,
      onModeChanged: (newMode) {
        setState(() {
          _mode = newMode;
        });
      },
      onSave: () async {
        final success = await notifier.submit();
        if (success && mounted) {
          Navigator.of(context).pop(true);
        }
      },
      onDelete: widget.appointmentId != null
          ? () async {
              final confirmed = await _showDeleteConfirmation();
              if (confirmed && mounted) {
                final success = await notifier.delete();
                if (success && mounted) {
                  Navigator.of(context).pop(true);
                }
              }
            }
          : null,
      onCancel: () {
        Navigator.of(context).pop(false);
      },
      child: AppointmentFormView(
        animalId: widget.animalId,
        readOnly: _mode == CrudDialogMode.view,
      ),
    );
  }

  String _getTitle() {
    switch (_mode) {
      case CrudDialogMode.create:
        return 'Nova Consulta';
      case CrudDialogMode.view:
        return 'Detalhes da Consulta';
      case CrudDialogMode.edit:
        return 'Editar Consulta';
    }
  }

  Future<bool> _showDeleteConfirmation() async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Confirmar Exclusão'),
            content: const Text(
              'Tem certeza que deseja excluir esta consulta? '
              'Esta ação não pode ser desfeita.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancelar'),
              ),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.red,
                ),
                child: const Text('Excluir'),
              ),
            ],
          ),
        ) ??
        false;
  }
}

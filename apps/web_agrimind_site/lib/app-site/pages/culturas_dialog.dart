import 'package:flutter/material.dart';
import '../classes/cultura_class.dart';
import '../repository/culturas_repository.dart';
import '../core/utils/form_validators.dart';
import '../core/utils/secure_logger.dart';
import '../services/feedback_service.dart';

class CulturaDialog extends StatefulWidget {
  final Cultura? cultura;

  const CulturaDialog({super.key, this.cultura});

  @override
  State<CulturaDialog> createState() => _CulturaDialogState();
}

class _CulturaDialogState extends State<CulturaDialog> {
  final _formKey = GlobalKey<FormState>();
  final _repository = CulturaRepository();
  late String _cultura;
  late int _status;
  String? _culturaError;
  String? _statusError;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _cultura = widget.cultura?.cultura ?? '';
    _status = widget.cultura?.status ?? 1;
  }

  Future<void> _save() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isLoading = true;
      });

      try {
        _formKey.currentState?.save();

        // Sanitizar dados antes de salvar
        final sanitizedCultura = FormValidators.sanitizeInput(_cultura);

        final cultura = Cultura(
          objectId: widget.cultura?.objectId ?? '',
          cultura: sanitizedCultura,
          status: _status,
        );

        if (widget.cultura == null) {
          await _repository.createCultura(cultura);
          FeedbackService.showActionSuccess('Cultura criada com sucesso');
        } else {
          await _repository.updateCultura(widget.cultura!.objectId, cultura);
          FeedbackService.showActionSuccess('Cultura atualizada com sucesso');
        }

        if (mounted) {
          Navigator.of(context).pop(true);
        }
      } catch (e) {
        SecureLogger.error('Erro ao salvar cultura', error: e);
        if (mounted) {
          FeedbackService.showActionError(
              'salvar cultura', SecureLogger.getUserFriendlyError(e));
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.cultura == null ? 'Nova Cultura' : 'Editar Cultura'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              initialValue: _cultura,
              decoration: InputDecoration(
                labelText: 'Cultura',
                helperText: 'Mínimo 2 caracteres, máximo 100',
                errorText: _culturaError,
                counterText: '',
              ),
              maxLength: 100,
              validator: FormValidators.validateCultura,
              onChanged: (value) {
                FormValidators.validateWithDebounce(
                  value,
                  (error) {
                    if (mounted) {
                      setState(() {
                        _culturaError = error;
                      });
                    }
                  },
                  FormValidators.validateCultura,
                );
              },
              onSaved: (value) =>
                  _cultura = FormValidators.sanitizeInput(value ?? ''),
            ),
            TextFormField(
              initialValue: _status.toString(),
              decoration: InputDecoration(
                labelText: 'Status',
                helperText: '0 = Inativo, 1 = Ativo',
                errorText: _statusError,
              ),
              keyboardType: TextInputType.number,
              validator: FormValidators.validateStatus,
              onChanged: (value) {
                FormValidators.validateWithDebounce(
                  value,
                  (error) {
                    if (mounted) {
                      setState(() {
                        _statusError = error;
                      });
                    }
                  },
                  FormValidators.validateStatus,
                );
              },
              onSaved: (value) => _status = int.parse(value ?? '1'),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(false),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _save,
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Salvar'),
        ),
      ],
    );
  }
}

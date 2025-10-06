import 'package:flutter/material.dart';

import '../classes/pragas_class.dart';
import '../repository/pragas_repository.dart';
import '../core/utils/form_validators.dart';
import '../core/utils/secure_logger.dart';
import '../services/feedback_service.dart';

class PragasDialog extends StatefulWidget {
  final Pragas? praga;

  const PragasDialog({super.key, this.praga});

  @override
  _PragasDialogState createState() => _PragasDialogState();
}

class _PragasDialogState extends State<PragasDialog> {
  final _formKey = GlobalKey<FormState>();
  final PragasRepository _repository = PragasRepository();

  late String _nomeComum;
  late String _nomeCientifico;
  late String _tipoPraga;
  String? _nomeComumError;
  String? _nomeCientificoError;
  String? _tipoPragaError;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nomeComum = widget.praga?.nomeComum ?? '';
    _nomeCientifico = widget.praga?.nomeCientifico ?? '';
    _tipoPraga = widget.praga?.tipoPraga ?? '';
  }

  Future<void> _save() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isLoading = true;
      });

      try {
        _formKey.currentState?.save();
        final sanitizedNomeComum = FormValidators.sanitizeInput(_nomeComum);
        final sanitizedNomeCientifico =
            FormValidators.sanitizeInput(_nomeCientifico);
        final sanitizedTipoPraga = FormValidators.sanitizeInput(_tipoPraga);

        final praga = Pragas(
          objectId: widget.praga?.objectId ?? '',
          nomeComum: sanitizedNomeComum,
          nomeCientifico: sanitizedNomeCientifico,
          tipoPraga: sanitizedTipoPraga,
        );

        if (widget.praga == null) {
          await _repository.createPraga(praga);
          FeedbackService.showActionSuccess('Praga criada com sucesso');
        } else {
          await _repository.updatePraga(widget.praga!.objectId, praga);
          FeedbackService.showActionSuccess('Praga atualizada com sucesso');
        }

        if (mounted) {
          Navigator.of(context).pop(true);
        }
      } catch (e) {
        SecureLogger.error('Erro ao salvar praga', error: e);
        if (mounted) {
          FeedbackService.showActionError(
              'salvar praga', SecureLogger.getUserFriendlyError(e));
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
      title: Text(widget.praga == null ? 'Nova Praga' : 'Editar Praga'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              initialValue: _nomeComum,
              decoration: InputDecoration(
                labelText: 'Nome Comum',
                helperText: 'Mínimo 2 caracteres, máximo 200',
                errorText: _nomeComumError,
                counterText: '',
              ),
              maxLength: 200,
              validator: FormValidators.validateNomeComum,
              onChanged: (value) {
                FormValidators.validateWithDebounce(
                  value,
                  (error) {
                    if (mounted) {
                      setState(() {
                        _nomeComumError = error;
                      });
                    }
                  },
                  FormValidators.validateNomeComum,
                );
              },
              onSaved: (value) =>
                  _nomeComum = FormValidators.sanitizeInput(value ?? ''),
            ),
            TextFormField(
              initialValue: _nomeCientifico,
              decoration: InputDecoration(
                labelText: 'Nome Científico',
                helperText: 'Formato: Genus species',
                errorText: _nomeCientificoError,
                counterText: '',
              ),
              maxLength: 200,
              validator: FormValidators.validateNomeCientifico,
              onChanged: (value) {
                FormValidators.validateWithDebounce(
                  value,
                  (error) {
                    if (mounted) {
                      setState(() {
                        _nomeCientificoError = error;
                      });
                    }
                  },
                  FormValidators.validateNomeCientifico,
                );
              },
              onSaved: (value) =>
                  _nomeCientifico = FormValidators.sanitizeInput(value ?? ''),
            ),
            TextFormField(
              initialValue: _tipoPraga,
              decoration: InputDecoration(
                labelText: 'Tipo de Praga (opcional)',
                helperText: 'Máximo 50 caracteres',
                errorText: _tipoPragaError,
                counterText: '',
              ),
              maxLength: 50,
              validator: FormValidators.validateTipoPraga,
              onChanged: (value) {
                FormValidators.validateWithDebounce(
                  value,
                  (error) {
                    if (mounted) {
                      setState(() {
                        _tipoPragaError = error;
                      });
                    }
                  },
                  FormValidators.validateTipoPraga,
                );
              },
              onSaved: (value) =>
                  _tipoPraga = FormValidators.sanitizeInput(value ?? ''),
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

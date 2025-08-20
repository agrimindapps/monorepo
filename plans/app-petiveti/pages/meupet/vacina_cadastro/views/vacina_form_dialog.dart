// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../../../models/16_vacina_model.dart';
import 'widgets/vacina_form_widget.dart';

/// Dialog for vaccine registration using MVC architecture
class VacinaFormDialog {
  /// Shows the vaccine registration dialog
  /// 
  /// Returns `true` if vaccine was saved successfully, `false` or `null` otherwise
  static Future<bool?> show({
    required BuildContext context,
    VacinaVet? vacina,
    String? selectedAnimalId,
  }) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => _VacinaFormDialogContent(
        vacina: vacina,
        selectedAnimalId: selectedAnimalId,
      ),
    );
  }
}

/// Internal dialog content widget to handle form submission
class _VacinaFormDialogContent extends StatefulWidget {
  final VacinaVet? vacina;
  final String? selectedAnimalId;

  const _VacinaFormDialogContent({
    this.vacina,
    this.selectedAnimalId,
  });

  @override
  State<_VacinaFormDialogContent> createState() => _VacinaFormDialogContentState();
}

class _VacinaFormDialogContentState extends State<_VacinaFormDialogContent> {
  final GlobalKey<VacinaFormMVCWidgetState> _formKey = GlobalKey<VacinaFormMVCWidgetState>();
  bool _isSubmitting = false;

  Future<void> _handleSave() async {
    if (_isSubmitting) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      final success = await _formKey.currentState?.submitForm() ?? false;
      if (mounted) {
        Navigator.of(context).pop(success);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao salvar: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        constraints: const BoxConstraints(
          maxWidth: 500,
          maxHeight: 500,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.vacina == null ? 'Nova Vacina' : 'Editar Vacina',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: _isSubmitting ? null : () => Navigator.of(context).pop(false),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),
            // Form content
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: VacinaFormMVCWidget(
                  key: _formKey,
                  vacina: widget.vacina,
                  selectedAnimalId: widget.selectedAnimalId,
                ),
              ),
            ),
            // Buttons
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: _isSubmitting ? null : () => Navigator.of(context).pop(false),
                    child: const Text('Cancelar'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _isSubmitting ? null : _handleSave,
                    child: _isSubmitting
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text('Salvar'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Legacy function for backward compatibility
/// 
/// This function maintains the same signature as the old vacinaCadastro function
/// but uses the new MVC architecture internally
Future<bool?> vacinaCadastro(BuildContext context, VacinaVet? vacina) {
  return VacinaFormDialog.show(
    context: context,
    vacina: vacina,
  );
}

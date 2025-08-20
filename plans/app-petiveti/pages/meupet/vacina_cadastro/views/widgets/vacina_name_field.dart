// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../utils/form_helpers.dart';
import '../styles/form_constants.dart';
import '../styles/form_styles.dart';

/// Vaccine name input field widget
class VacinaNameField extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode? focusNode;
  final String? errorText;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onFieldSubmitted;
  final bool enabled;

  const VacinaNameField({
    super.key,
    required this.controller,
    this.focusNode,
    this.errorText,
    this.onChanged,
    this.onFieldSubmitted,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: controller,
          focusNode: focusNode,
          enabled: enabled,
          maxLength: FormConstants.maxVaccineNameLength,
          textCapitalization: TextCapitalization.words,
          textInputAction: TextInputAction.next,
          decoration: FormStyles.getFieldDecoration(
            labelText: FormHelpers.getFieldLabel('nomeVacina'),
            hintText: FormHelpers.getFieldHint('nomeVacina'),
            errorText: errorText,
            enabled: enabled,
          ),
          style: FormStyles.fieldTextStyle,
          onChanged: (value) {
            final formatted = FormHelpers.formatVaccineName(value);
            if (formatted != value) {
              controller.value = controller.value.copyWith(
                text: formatted,
                selection: TextSelection.collapsed(offset: formatted.length),
              );
            }
            onChanged?.call(formatted);
          },
          onFieldSubmitted: onFieldSubmitted,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Nome da vacina é obrigatório';
            }
            
            if (value.trim().length < FormConstants.minVaccineNameLength) {
              return 'Nome deve ter pelo menos ${FormConstants.minVaccineNameLength} caracteres';
            }
            
            if (!FormHelpers.hasValidCharacters(value)) {
              return 'Nome contém caracteres inválidos';
            }
            
            return null;
          },
          buildCounter: (context, {required currentLength, required isFocused, maxLength}) {
            if (maxLength == null) return null;
            
            return Text(
              FormHelpers.getCharacterCountText(controller.text, 'nomeVacina'),
              style: FormStyles.getCounterStyle(currentLength, maxLength),
            );
          },
        ),
        
        // Additional help text
        if (enabled && focusNode?.hasFocus == true)
          Padding(
            padding: const EdgeInsets.only(
              top: FormConstants.spacingXSmall,
              left: FormConstants.spacingMedium,
            ),
            child: Text(
              'Ex: V8, V10, Raiva, Múltipla, Antirrábica',
              style: FormStyles.hintStyle.copyWith(
                fontSize: 12,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
      ],
    );
  }
}

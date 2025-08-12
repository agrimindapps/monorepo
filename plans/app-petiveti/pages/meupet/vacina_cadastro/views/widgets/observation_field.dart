// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../utils/form_helpers.dart';
import '../styles/form_constants.dart';
import '../styles/form_styles.dart';

/// Observation field widget for additional notes
class ObservationField extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode? focusNode;
  final String? errorText;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onFieldSubmitted;
  final bool enabled;

  const ObservationField({
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
          maxLength: FormConstants.maxObservationsLength,
          maxLines: 3,
          minLines: 2,
          textCapitalization: TextCapitalization.sentences,
          textInputAction: TextInputAction.done,
          decoration: FormStyles.getFieldDecoration(
            labelText: FormHelpers.getFieldLabel('observacoes'),
            hintText: FormHelpers.getFieldHint('observacoes'),
            errorText: errorText,
            enabled: enabled,
          ),
          style: FormStyles.fieldTextStyle,
          onChanged: (value) {
            final cleaned = FormHelpers.cleanObservations(value);
            if (cleaned != value) {
              controller.value = controller.value.copyWith(
                text: cleaned,
                selection: TextSelection.collapsed(offset: cleaned.length),
              );
            }
            onChanged?.call(cleaned);
          },
          onFieldSubmitted: onFieldSubmitted,
          validator: (value) {
            if (value != null && value.length > FormConstants.maxObservationsLength) {
              return 'Observações devem ter no máximo ${FormConstants.maxObservationsLength} caracteres';
            }
            
            if (value != null && !FormHelpers.hasValidCharacters(value)) {
              return 'Observações contêm caracteres inválidos';
            }
            
            return null;
          },
          buildCounter: (context, {required currentLength, required isFocused, maxLength}) {
            if (maxLength == null) return null;
            
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (isFocused)
                  Text(
                    'Opcional - informações adicionais',
                    style: FormStyles.hintStyle.copyWith(fontSize: 12),
                  )
                else
                  const SizedBox.shrink(),
                Text(
                  FormHelpers.getCharacterCountText(controller.text, 'observacoes'),
                  style: FormStyles.getCounterStyle(currentLength, maxLength),
                ),
              ],
            );
          },
        ),
        
        // Additional help text when focused
        if (enabled && focusNode?.hasFocus == true)
          Padding(
            padding: const EdgeInsets.only(
              top: FormConstants.spacingXSmall,
              left: FormConstants.spacingMedium,
            ),
            child: Text(
              'Ex: Reação alérgica anterior, lembrete especial, etc.',
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

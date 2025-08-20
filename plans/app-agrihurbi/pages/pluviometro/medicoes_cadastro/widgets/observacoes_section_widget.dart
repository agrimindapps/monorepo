// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../../../../../core/style/shadcn_style.dart';

class ObservacoesSectionWidget extends StatelessWidget {
  final String? observacoes;
  final Function(String?) onObservacoesChanged;

  const ObservacoesSectionWidget({
    super.key,
    required this.observacoes,
    required this.onObservacoesChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Text(
          'Observações (opcional)',
          style: ShadcnStyle.labelStyle,
        ),
        const SizedBox(height: 8),
        TextFormField(
          initialValue: observacoes,
          decoration: ShadcnStyle.inputDecoration(
            label: 'Adicione observações sobre a medição',
            suffixIcon: const Icon(
              Icons.note_alt_outlined,
              size: 20,
            ),
          ),
          maxLines: 3,
          maxLength: 500,
          onChanged: onObservacoesChanged,
          validator: (value) {
            if (value != null && value.length > 500) {
              return 'Observação deve ter no máximo 500 caracteres';
            }
            return null;
          },
          textCapitalization: TextCapitalization.sentences,
          keyboardType: TextInputType.multiline,
        ),
      ],
    );
  }
}

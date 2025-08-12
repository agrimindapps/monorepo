// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Project imports:
import '../../../../../core/style/shadcn_style.dart';

class GenericNumericField extends StatelessWidget {
  final TextEditingController textController;
  final String label;
  final String? prefix;
  final Widget? suffixIcon;
  final List<TextInputFormatter> inputFormatters;
  final String? Function(String?)? validator;
  final void Function(String) onChanged;
  final void Function(String?)? onSaved;
  final TextInputType keyboardType;
  final Key? fieldKey;

  const GenericNumericField({
    super.key,
    required this.textController,
    required this.label,
    this.prefix,
    this.suffixIcon,
    required this.inputFormatters,
    this.validator,
    required this.onChanged,
    this.onSaved,
    this.keyboardType = const TextInputType.numberWithOptions(
      decimal: true,
      signed: false,
    ),
    this.fieldKey,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      key: fieldKey,
      controller: textController,
      textAlign: TextAlign.right,
      keyboardType: keyboardType,
      decoration: ShadcnStyle.inputDecoration(
        label: label,
        prefix: prefix,
        suffixIcon: suffixIcon,
      ),
      inputFormatters: inputFormatters,
      validator: validator,
      onSaved: onSaved,
      onChanged: onChanged,
    );
  }
}

class CurrencyInputField extends StatelessWidget {
  final TextEditingController textController;
  final String label;
  final String? Function(String?)? validator;
  final void Function(String) onChanged;
  final void Function(String?)? onSaved;

  const CurrencyInputField({
    super.key,
    required this.textController,
    required this.label,
    this.validator,
    required this.onChanged,
    this.onSaved,
  });

  @override
  Widget build(BuildContext context) {
    return GenericNumericField(
      textController: textController,
      label: label,
      prefix: 'R\$ ',
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'[0-9,.]')),
        // TODO: Adicionar um formatador de moeda genérico
      ],
      validator: validator,
      onChanged: onChanged,
      onSaved: onSaved,
    );
  }
}

class SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;

  const SectionCard({
    super.key,
    required this.title,
    required this.icon,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(4, 8, 4, 8),
          child: Row(
            children: [
              Icon(icon, size: 16, color: ShadcnStyle.mutedTextColor),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        Card(
          elevation: 0,
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(color: ShadcnStyle.borderColor),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: child,
          ),
        ),
      ],
    );
  }
}

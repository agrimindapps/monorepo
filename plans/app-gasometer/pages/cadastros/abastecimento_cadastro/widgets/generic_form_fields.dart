// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Project imports:
import '../../../../../core/style/shadcn_style.dart';
import '../../../../../core/themes/manager.dart';

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
  final Color? sectionColor;

  const SectionCard({
    super.key,
    required this.title,
    required this.icon,
    required this.child,
    this.sectionColor,
  });

  @override
  Widget build(BuildContext context) {
    final color = sectionColor ?? _getSectionColor(title);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withValues(alpha: 0.03),
            Colors.transparent,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header da seção
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    size: 18,
                    color: color,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: ThemeManager().isDark.value
                        ? Colors.white
                        : ShadcnStyle.textColor,
                  ),
                ),
              ],
            ),
          ),
          // Conteúdo
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Container(
              decoration: BoxDecoration(
                color: ThemeManager().isDark.value
                    ? Colors.grey.shade900
                    : Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: ShadcnStyle.borderColor.withValues(alpha: 0.3),
                ),
              ),
              padding: const EdgeInsets.all(16),
              child: child,
            ),
          ),
        ],
      ),
    );
  }

  Color _getSectionColor(String title) {
    switch (title.toLowerCase()) {
      case 'informações básicas':
      case 'informacoes basicas':
        return Colors.blue;
      case 'valores':
        return Colors.green;
      case 'observação':
      case 'observacao':
        return Colors.purple;
      default:
        return ShadcnStyle.primaryColor;
    }
  }
}

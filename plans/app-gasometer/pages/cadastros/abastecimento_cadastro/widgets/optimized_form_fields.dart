// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Project imports:
import '../../../../../core/style/shadcn_style.dart';
import '../controller/abastecimento_form_controller.dart';
import '../services/formatting_service.dart';

/// Widget otimizado para campos numéricos com formatação em tempo real
/// Reduz rebuilds desnecessários e melhora performance
class OptimizedNumericField extends StatefulWidget {
  final AbastecimentoFormController controller;
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

  const OptimizedNumericField({
    super.key,
    required this.controller,
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
  State<OptimizedNumericField> createState() => _OptimizedNumericFieldState();
}

class _OptimizedNumericFieldState extends State<OptimizedNumericField> {
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      key: widget.fieldKey,
      controller: widget.textController,
      focusNode: _focusNode,
      textAlign: TextAlign.right,
      keyboardType: widget.keyboardType,
      decoration: ShadcnStyle.inputDecoration(
        label: widget.label,
        prefix: widget.prefix,
        suffixIcon: widget.suffixIcon,
      ),
      inputFormatters: widget.inputFormatters,
      validator: widget.validator,
      onSaved: widget.onSaved,
      onChanged: (value) {
        // onChanged direto do TextFormField para máxima responsividade
        widget.onChanged(value);
      },
      onEditingComplete: () {
        _focusNode.unfocus();
      },
      onTapOutside: (_) {
        _focusNode.unfocus();
      },
    );
  }
}

/// Widget otimizado para display de valores calculados
/// Usa ValueListenableBuilder para rebuilds específicos
class OptimizedCalculatedField extends StatelessWidget {
  final AbastecimentoFormController controller;
  final String label;
  final Widget? prefixIcon;
  final String Function(double) formatter;
  final ValueNotifier<double> valueNotifier;

  const OptimizedCalculatedField({
    super.key,
    required this.controller,
    required this.label,
    this.prefixIcon,
    required this.formatter,
    required this.valueNotifier,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<double>(
      valueListenable: valueNotifier,
      builder: (context, value, child) {
        return InputDecorator(
          decoration: ShadcnStyle.inputDecoration(
            label: label,
            prefixIcon: prefixIcon,
          ),
          child: Text(
            formatter(value),
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        );
      },
    );
  }
}

/// Mixin para widgets com formatação otimizada
mixin FormattingMixin {
  final FormattingService _formattingService = FormattingService();

  FormattingService get formatting => _formattingService;

  /// Cria sufixIcon otimizado com menos rebuilds
  Widget? createOptimizedSuffixIcon({
    required bool showClear,
    required VoidCallback onClear,
    double iconSize = 18,
  }) {
    if (!showClear) return null;

    return IconButton(
      icon: Icon(Icons.clear, size: iconSize),
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(),
      onPressed: onClear,
    );
  }
}

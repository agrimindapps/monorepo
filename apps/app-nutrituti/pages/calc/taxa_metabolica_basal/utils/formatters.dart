// Package imports:
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

class TMBFormatters {
  static final pesoMask = MaskTextInputFormatter(
    mask: '###,##',
    filter: {'#': RegExp(r'[0-9]')},
    type: MaskAutoCompletionType.lazy,
  );

  static final alturaMask = MaskTextInputFormatter(
    mask: '###',
    filter: {'#': RegExp(r'[0-9]')},
    type: MaskAutoCompletionType.lazy,
  );

  static final idadeMask = MaskTextInputFormatter(
    mask: '###',
    filter: {'#': RegExp(r'[0-9]')},
    type: MaskAutoCompletionType.lazy,
  );
}

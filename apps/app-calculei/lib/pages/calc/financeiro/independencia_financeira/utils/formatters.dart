// DEPRECATED: Use FormattingService instead
// This file is kept for backward compatibility

// Flutter imports:
import 'package:flutter/services.dart';

// Project imports:
import 'package:app_calculei/services/formatting_service.dart';

export '../services/formatting_service.dart' show 
  OptimizedMoneyInputFormatter,
  PercentInputFormatter,
  FormattingService;

/// @deprecated Use PercentInputFormatter from FormattingService instead
class NumericInputFormatter extends TextInputFormatter {
  final _delegate = PercentInputFormatter();

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    return _delegate.formatEditUpdate(oldValue, newValue);
  }
}

/// @deprecated Use OptimizedMoneyInputFormatter from FormattingService instead
class MoneyInputFormatter extends TextInputFormatter {
  final _delegate = OptimizedMoneyInputFormatter();

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return _delegate.formatEditUpdate(oldValue, newValue);
  }

  /// Retorna o valor numérico sem formatação
  double getUnmaskedDouble(String text) {
    return _delegate.getUnmaskedDouble(text);
  }

  /// Limpa o cache
  void dispose() {
    // Delegate não tem dispose, mas mantemos para compatibilidade
  }
}

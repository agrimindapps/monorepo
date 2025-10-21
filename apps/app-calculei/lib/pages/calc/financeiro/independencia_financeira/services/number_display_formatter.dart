// DEPRECATED: Use FormattingService instead
// This file is kept for backward compatibility

// Project imports:
import 'formatting_service.dart';

/// @deprecated Use FormattingService instead
class NumberDisplayFormatter {
  final _formattingService = FormattingService();

  /// @deprecated Use FormattingService.formatarMoedaCompacta instead
  String formatarValorParaExibicao(double valor) {
    return _formattingService.formatarMoedaCompacta(valor);
  }

  /// @deprecated Use FormattingService.formatarPercentual instead
  String formatarPercentual(double valor) {
    return _formattingService.formatarPercentual(valor);
  }

  /// @deprecated Use FormattingService.formatarAnos instead
  String formatarAnos(double anos) {
    return _formattingService.formatarAnos(anos);
  }
}

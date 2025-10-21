// Flutter imports:
import 'package:flutter/services.dart';

// Project imports:
import '../services/security_service.dart';

/// Input formatter com validação de segurança em tempo real
///
/// 🔒 IMPLEMENTA ISSUE #3 - SECURITY: Validação robusta durante digitação
class SecureNumericInputFormatter extends TextInputFormatter {
  final int decimalPlaces;
  final bool allowNegative;
  final double? minValue;
  final double? maxValue;
  final String fieldName;
  final Function(String)? onSecurityViolation;

  SecureNumericInputFormatter({
    this.decimalPlaces = 2,
    this.allowNegative = false,
    this.minValue,
    this.maxValue,
    this.fieldName = 'campo numérico',
    this.onSecurityViolation,
  });

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Se o texto está vazio, permite
    if (newValue.text.isEmpty) {
      return newValue;
    }

    // 🔒 VALIDAÇÃO DE SEGURANÇA EM TEMPO REAL
    final securityResult =
        VolumeSanguineoSecurityService.validateSecureNumericInput(
      newValue.text,
      fieldName: fieldName,
      allowNegative: allowNegative,
      minValue: minValue,
      maxValue: maxValue,
    );

    // Se entrada não é segura, bloqueia ou sanitiza
    if (!securityResult.isSecure) {
      // Log da violação
      VolumeSanguineoSecurityService.logSecurityViolation(
        input: newValue.text,
        reason: securityResult.vulnerabilityReason ?? 'Entrada insegura',
        threatLevel: securityResult.threatLevel,
        fieldName: fieldName,
      );

      // Notifica callback se definido
      if (onSecurityViolation != null) {
        onSecurityViolation!(
            securityResult.vulnerabilityReason ?? 'Entrada rejeitada');
      }

      // Para ameaças altas, bloqueia completamente a entrada
      if (securityResult.threatLevel.index >=
          SecurityThreatLevel.medium.index) {
        return oldValue; // Mantém valor anterior
      }

      // Para ameaças baixas, usa valor sanitizado se disponível
      if (securityResult.sanitizedValue != null) {
        return TextEditingValue(
          text: securityResult.sanitizedValue!,
          selection: TextSelection.collapsed(
            offset: securityResult.sanitizedValue!.length,
          ),
        );
      }

      // Se não há valor sanitizado, bloqueia
      return oldValue;
    }

    // Aplica formatação decimal padrão no valor seguro
    return _applyDecimalFormatting(
        newValue, securityResult.sanitizedValue ?? newValue.text);
  }

  /// Aplica formatação decimal no valor já validado por segurança
  TextEditingValue _applyDecimalFormatting(
      TextEditingValue originalValue, String secureText) {
    // Remove caracteres não numéricos exceto vírgula, ponto e sinal negativo
    String text = secureText.replaceAll(RegExp(r'[^\d,.\-]'), '');

    // Normaliza separador decimal
    text = text.replaceAll(',', '.');

    // Controla quantidade de pontos decimais
    if (text.split('.').length > 2) {
      // Mais de um ponto decimal - mantém apenas o primeiro
      final parts = text.split('.');
      text = '${parts[0]}.${parts.sublist(1).join('')}';
    }

    // Limita casas decimais
    if (text.contains('.')) {
      final parts = text.split('.');
      if (parts.length == 2 && parts[1].length > decimalPlaces) {
        text = '${parts[0]}.${parts[1].substring(0, decimalPlaces)}';
      }
    }

    // Controla sinal negativo (apenas no início)
    if (!allowNegative) {
      text = text.replaceAll('-', '');
    } else {
      // Remove sinais negativos que não estão no início
      if (text.startsWith('-')) {
        text = '-${text.substring(1).replaceAll('-', '')}';
      } else {
        text = text.replaceAll('-', '');
      }
    }

    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(
        offset: text.length.clamp(0, text.length),
      ),
    );
  }
}

/// Input formatter específico para peso corporal com validação de segurança
class SecurePesoInputFormatter extends SecureNumericInputFormatter {
  final Function(String)? onSecurityAlert;

  SecurePesoInputFormatter({
    this.onSecurityAlert,
  }) : super(
          decimalPlaces: 2,
          allowNegative: false,
          minValue: 0.5,
          maxValue: 700.0,
          fieldName: 'peso corporal',
          onSecurityViolation: onSecurityAlert,
        );
}

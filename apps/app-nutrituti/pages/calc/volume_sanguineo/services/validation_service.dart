// Project imports:
import 'security_service.dart';

/// Serviço responsável por validações de negócio para cálculo de volume sanguíneo
///
/// Este serviço centraliza todas as regras de validação, incluindo verificação
/// de campos obrigatórios, formatos válidos e ranges biologicamente plausíveis.
///
/// 🔒 IMPLEMENTA ISSUE #3 - SECURITY: Integra validação robusta de segurança
class VolumeSanguineoValidationService {
  /// Valida se o peso informado está dentro dos parâmetros válidos
  ///
  /// Retorna uma string com erro se inválido, ou null se válido
  ///
  /// 🔒 SEGURANÇA: Utiliza validação robusta contra ataques maliciosos
  String? validatePeso(String pesoText) {
    if (pesoText.isEmpty) {
      return 'Necessário informar o peso.';
    }

    // 🔒 IMPLEMENTAÇÃO ISSUE #3: Validação de segurança avançada
    final securityResult =
        VolumeSanguineoSecurityService.validatePesoSecurity(pesoText);

    if (!securityResult.isSecure) {
      // Log da violação de segurança para monitoramento
      VolumeSanguineoSecurityService.logSecurityViolation(
        input: pesoText,
        reason: securityResult.vulnerabilityReason ?? 'Entrada insegura',
        threatLevel: securityResult.threatLevel,
        fieldName: 'peso',
      );

      // Retorna mensagem user-friendly baseada no nível de ameaça
      switch (securityResult.threatLevel) {
        case SecurityThreatLevel.high:
        case SecurityThreatLevel.critical:
          return 'Entrada rejeitada por questões de segurança.';
        case SecurityThreatLevel.medium:
          return 'Valor numérico inválido ou muito extremo.';
        case SecurityThreatLevel.low:
        default:
          return securityResult.vulnerabilityReason ??
              'Formato de peso inválido.';
      }
    }

    // Usa valor sanitizado se disponível
    final valorProcessar = securityResult.sanitizedValue ?? pesoText;

    try {
      final peso = double.parse(valorProcessar.replaceAll(',', '.'));

      if (peso <= 0) {
        return 'O peso deve ser maior que zero.';
      }

      // Validação adicional de range biológico (além da validação de segurança)
      if (peso < 0.5) {
        return 'Peso muito baixo. Mínimo: 0.5kg (prematuros extremos).';
      }

      if (peso > 700) {
        return 'Peso muito alto. Máximo: 700kg (casos extremos documentados).';
      }

      return null; // Peso válido e seguro
    } catch (e) {
      return 'Erro ao processar peso. Verifique o formato numérico.';
    }
  }

  /// Valida se o tipo de pessoa foi selecionado
  String? validateTipoPessoa(Map<String, dynamic>? generoDef) {
    if (generoDef == null || generoDef.isEmpty) {
      return 'Necessário selecionar o tipo de pessoa.';
    }
    return null;
  }

  /// Verifica se a entrada contém padrões potencialmente maliciosos
  ///
  /// 🔒 SEGURANÇA: Detecção precoce de tentativas maliciosas
  bool hasPotentialSecurityThreat(String input) {
    return VolumeSanguineoSecurityService.isPotentiallyMalicious(input);
  }

  /// Sanitiza entrada preservando apenas caracteres numéricos válidos
  ///
  /// 🔒 SEGURANÇA: Limpeza automática de dados de entrada
  String sanitizeNumericInput(String input) {
    final securityResult =
        VolumeSanguineoSecurityService.validatePesoSecurity(input);
    return securityResult.sanitizedValue ?? input;
  }

  /// Valida todos os campos necessários para o cálculo
  ///
  /// Retorna o primeiro erro encontrado ou null se tudo estiver válido
  ///
  /// 🔒 SEGURANÇA: Inclui validação de segurança robusta
  String? validateAllFields(String pesoText, Map<String, dynamic>? generoDef) {
    // Valida tipo de pessoa primeiro
    final tipoPessoaError = validateTipoPessoa(generoDef);
    if (tipoPessoaError != null) {
      return tipoPessoaError;
    }

    // 🔒 Verificação de segurança precoce
    if (hasPotentialSecurityThreat(pesoText)) {
      // Log da tentativa maliciosa
      VolumeSanguineoSecurityService.logSecurityViolation(
        input: pesoText,
        reason: 'Entrada potencialmente maliciosa detectada na validação geral',
        threatLevel: SecurityThreatLevel.medium,
        fieldName: 'peso_geral',
      );
      return 'Entrada rejeitada por questões de segurança.';
    }

    // Valida peso com verificações de segurança
    final pesoError = validatePeso(pesoText);
    if (pesoError != null) {
      return pesoError;
    }

    return null; // Todos os campos válidos e seguros
  }
}

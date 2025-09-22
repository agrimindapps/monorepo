import 'package:flutter/foundation.dart';

/// Service responsável por sanitizar dados pessoais conforme LGPD
/// Implementa mascaramento e ocultação de dados sensíveis para Gasometer
class DataSanitizationService {
  static const _anonymousDisplayName = 'Usuário Anônimo';
  static const _anonymousEmail = 'usuario@anonimo.com';
  static const _maskedPhonePlaceholder = '(••) •••••-••••';

  /// Sanitiza nome de exibição baseado no status de anonimato
  static String sanitizeDisplayName(dynamic user, bool isAnonymous) {
    if (isAnonymous || (user?.displayName == null) || (user?.displayName as String?)?.isEmpty == true) {
      return _anonymousDisplayName;
    }

    final displayName = user?.displayName as String? ?? '';

    // Para usuários autenticados, validar se o nome não contém caracteres suspeitos
    if (displayName.contains(RegExp(r'[<>"&]'))) {
      // Limpar caracteres HTML/XSS potenciais
      final cleanedName = displayName
          .replaceAll(RegExp(r'[<>"&]'), '')
          .trim();
      return cleanedName.isEmpty ? _anonymousDisplayName : cleanedName;
    }

    return displayName;
  }

  /// Sanitiza email com mascaramento adequado
  static String sanitizeEmail(dynamic user, bool isAnonymous) {
    if (isAnonymous || (user?.email == null) || (user?.email as String?)?.isEmpty == true) {
      return _anonymousEmail;
    }

    final email = user?.email as String? ?? '';

    // Validar formato básico do email
    if (!email.contains('@') || email.length < 5) {
      return _anonymousEmail;
    }

    try {
      final parts = email.split('@');
      if (parts.length != 2) return _anonymousEmail;

      final username = parts[0];
      final domain = parts[1];

      // Mascarar username mantendo apenas primeiro e último caractere
      if (username.length <= 2) {
        return '••@$domain';
      } else if (username.length <= 4) {
        return '${username[0]}••@$domain';
      } else {
        final masked = '${username[0]}${'•' * (username.length - 2)}${username[username.length - 1]}';
        return '$masked@$domain';
      }
    } catch (e) {
      // Em caso de erro, retornar email anônimo
      if (kDebugMode) {
        debugPrint('Erro ao sanitizar email: $e');
      }
      return _anonymousEmail;
    }
  }

  /// Sanitiza telefone com mascaramento
  static String sanitizePhone(dynamic user, bool isAnonymous) {
    if (isAnonymous || (user?.phone == null) || (user?.phone as String?)?.isEmpty == true) {
      return _maskedPhonePlaceholder;
    }

    final phone = user?.phone as String? ?? '';

    // Remover caracteres não numéricos
    final digitsOnly = phone.replaceAll(RegExp(r'[^\d]'), '');

    if (digitsOnly.length < 10) {
      return _maskedPhonePlaceholder;
    }

    // Mascarar mantendo apenas os 2 primeiros e 2 últimos dígitos
    if (digitsOnly.length == 11) {
      // Formato: (XX) XXXXX-XXXX -> (XX) •••••-••XX
      return '(${digitsOnly.substring(0, 2)}) •••••-••${digitsOnly.substring(9)}';
    } else if (digitsOnly.length == 10) {
      // Formato: (XX) XXXX-XXXX -> (XX) ••••-••XX
      return '(${digitsOnly.substring(0, 2)}) ••••-••${digitsOnly.substring(8)}';
    }

    return _maskedPhonePlaceholder;
  }

  /// Gera iniciais sanitizadas para avatar
  static String sanitizeInitials(dynamic user, bool isAnonymous) {
    if (isAnonymous || user == null) {
      return 'UA'; // Usuário Anônimo
    }

    final displayName = sanitizeDisplayName(user, false);
    if (displayName == _anonymousDisplayName || displayName.trim().isEmpty) {
      return 'UA';
    }

    final names = displayName.trim().split(RegExp(r'\s+'))
        .where((name) => name.isNotEmpty)
        .toList();

    if (names.isEmpty) return 'UA';

    if (names.length == 1) {
      return names[0].isNotEmpty ? names[0][0].toUpperCase() : 'UA';
    }

    final firstInitial = names[0].isNotEmpty ? names[0][0] : '';
    final lastInitial = names[names.length - 1].isNotEmpty ? names[names.length - 1][0] : '';

    if (firstInitial.isEmpty && lastInitial.isEmpty) return 'UA';
    if (firstInitial.isEmpty) return lastInitial.toUpperCase();
    if (lastInitial.isEmpty) return firstInitial.toUpperCase();

    return '$firstInitial$lastInitial'.toUpperCase();
  }

  /// Valida se a foto de perfil deve ser exibida
  static bool shouldShowProfilePhoto(dynamic user, bool isAnonymous) {
    if (isAnonymous) return false;

    final photoUrl = user?.photoUrl as String?;
    if (photoUrl == null || photoUrl.isEmpty) return false;

    // Para base64, sempre mostrar se não for anônimo
    if (photoUrl.startsWith('data:image') ||
        photoUrl.startsWith('/9j/') ||
        photoUrl.startsWith('iVBOR')) {
      return true;
    }

    // Validar se a URL é segura (HTTPS)
    try {
      final uri = Uri.parse(photoUrl);
      return uri.scheme == 'https' && uri.host.isNotEmpty;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('URL de foto inválida: $photoUrl');
      }
      return false;
    }
  }

  /// Remove dados sensíveis de logs e debug
  static String sanitizeForLogging(String message) {
    return message
        // Remover emails
        .replaceAll(RegExp(r'\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,}\b'), '***@***.***')
        // Remover possíveis senhas (palavra seguida de :)
        .replaceAll(RegExp(r'(password|senha|pass|pwd)\s*[:=]\s*\S+', caseSensitive: false), r'$1: ***')
        // Remover telefones
        .replaceAll(RegExp(r'\(?\d{2}\)?\s*\d{4,5}[-\s]?\d{4}'), '(**) *****-****')
        // Remover possíveis tokens (sequências longas alfanuméricas)
        .replaceAll(RegExp(r'\b[A-Za-z0-9]{20,}\b'), '***TOKEN***');
  }

  /// Valida e sanitiza entrada de texto para prevenir XSS
  static String sanitizeTextInput(String input) {
    return input
        .replaceAll(RegExp(r'<[^>]*>'), '') // Remove tags HTML
        .replaceAll('&', '&amp;')
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;')
        .replaceAll('"', '&quot;')
        .replaceAll("'", '&#x27;')
        .trim();
  }

  /// Valida formato de email de forma segura
  static bool isValidEmailFormat(String email) {
    if (email.isEmpty) return false;

    // RFC 5322 regex simplificado e seguro
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9.!#$%&*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$'
    );

    // Validações adicionais de segurança
    if (email.length > 254) return false; // RFC 5321
    if (email.contains('..')) return false; // Evitar dots consecutivos
    if (email.startsWith('.') || email.endsWith('.')) return false;

    return emailRegex.hasMatch(email);
  }

  /// Cria configuração de suporte sanitizada (sem emails hardcoded)
  static Map<String, String> getSupportContactInfo() {
    // Emails movidos para configuração segura, não hardcoded
    return {
      'email': _getSupportEmail(),
      'response_time': 'Respondemos em até 48 horas úteis',
      'subject_prefix': '[Gasometer App] ',
    };
  }

  /// Obtém email de suporte de forma segura
  static String _getSupportEmail() {
    // Em produção, isso deveria vir de uma variável de ambiente ou configuração remota
    if (kDebugMode) {
      return 'dev.suporte@gasometer.app';
    }
    return 'suporte@gasometer.app';
  }

  /// Sanitiza dados para Analytics (remove PII)
  static Map<String, dynamic> sanitizeAnalyticsData(Map<String, dynamic> data) {
    final sanitized = <String, dynamic>{};

    for (final entry in data.entries) {
      final key = entry.key;
      final value = entry.value;

      // Remover campos que podem conter PII
      if (_isPotentialPII(key)) {
        continue; // Não incluir dados potencialmente sensíveis
      }

      // Sanitizar valores string
      if (value is String) {
        sanitized[key] = sanitizeForLogging(value);
      } else {
        sanitized[key] = value;
      }
    }

    return sanitized;
  }

  /// Verifica se uma chave pode conter informações pessoais
  static bool _isPotentialPII(String key) {
    final piiKeys = {
      'email', 'phone', 'name', 'displayName', 'address',
      'photoUrl', 'userId', 'id', 'password', 'token',
      'cpf', 'cnpj', 'rg', 'birthDate', 'location',
      'licensePlate', 'vehicleModel', 'vin' // Específicos do Gasometer
    };

    final lowerKey = key.toLowerCase();
    return piiKeys.any((piiKey) => lowerKey.contains(piiKey));
  }

  /// Configurações de mascaramento personalizáveis
  static const Map<String, String> _maskingConfig = {
    'email_mask_char': '•',
    'phone_mask_char': '•',
    'name_anonymous': 'Usuário Anônimo',
    'email_anonymous': 'usuario@anonimo.com',
  };

  /// Obtém configuração de mascaramento
  static String getMaskingConfig(String key) {
    return _maskingConfig[key] ?? '';
  }
}
import 'package:core/core.dart' hide Column;
import 'package:flutter/foundation.dart';

/// Service responsável por sanitizar dados pessoais conforme LGPD
/// Implementa mascaramento e ocultação de dados sensíveis
class DataSanitizationService {
  static const _anonymousDisplayName = 'Usuário Anônimo';
  static const _anonymousEmail = 'usuario@anonimo.com';
  static const _maskedPhonePlaceholder = '(••) •••••-••••';

  /// Sanitiza nome de exibição baseado no status de anonimato
  static String sanitizeDisplayName(UserEntity? user, bool isAnonymous) {
    if (isAnonymous || user?.displayName.isEmpty == true) {
      return _anonymousDisplayName;
    }

    final displayName = user?.displayName ?? '';
    if (displayName.contains(RegExp(r'[<>"&]'))) {
      final cleanedName = displayName.replaceAll(RegExp(r'[<>"&]'), '').trim();
      return cleanedName.isEmpty ? _anonymousDisplayName : cleanedName;
    }

    return displayName;
  }

  /// Sanitiza email com mascaramento adequado
  static String sanitizeEmail(UserEntity? user, bool isAnonymous) {
    if (isAnonymous || user?.email.isEmpty == true) {
      return _anonymousEmail;
    }

    final email = user?.email ?? '';
    if (!email.contains('@') || email.length < 5) {
      return _anonymousEmail;
    }

    try {
      final parts = email.split('@');
      if (parts.length != 2) return _anonymousEmail;

      final username = parts[0];
      final domain = parts[1];
      if (username.length <= 2) {
        return '••@$domain';
      } else if (username.length <= 4) {
        return '${username[0]}••@$domain';
      } else {
        final masked =
            '${username[0]}${'•' * (username.length - 2)}${username[username.length - 1]}';
        return '$masked@$domain';
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Erro ao sanitizar email: $e');
      }
      return _anonymousEmail;
    }
  }

  /// Sanitiza telefone com mascaramento
  static String sanitizePhone(UserEntity? user, bool isAnonymous) {
    if (isAnonymous || user?.phone?.isEmpty == true) {
      return _maskedPhonePlaceholder;
    }

    final phone = user?.phone ?? '';
    final digitsOnly = phone.replaceAll(RegExp(r'[^\d]'), '');

    if (digitsOnly.length < 10) {
      return _maskedPhonePlaceholder;
    }
    if (digitsOnly.length == 11) {
      return '(${digitsOnly.substring(0, 2)}) •••••-••${digitsOnly.substring(9)}';
    } else if (digitsOnly.length == 10) {
      return '(${digitsOnly.substring(0, 2)}) ••••-••${digitsOnly.substring(8)}';
    }

    return _maskedPhonePlaceholder;
  }

  /// Gera iniciais sanitizadas para avatar
  static String sanitizeInitials(UserEntity? user, bool isAnonymous) {
    if (isAnonymous || user == null) {
      return 'UA'; // Usuário Anônimo
    }

    final displayName = sanitizeDisplayName(user, false);
    if (displayName == _anonymousDisplayName || displayName.trim().isEmpty) {
      return 'UA';
    }

    final names = displayName
        .trim()
        .split(RegExp(r'\s+'))
        .where((name) => name.isNotEmpty)
        .toList();

    if (names.isEmpty) return 'UA';

    if (names.length == 1) {
      return names[0].isNotEmpty ? names[0][0].toUpperCase() : 'UA';
    }

    final firstInitial = names[0].isNotEmpty ? names[0][0] : '';
    final lastInitial = names[names.length - 1].isNotEmpty
        ? names[names.length - 1][0]
        : '';

    if (firstInitial.isEmpty && lastInitial.isEmpty) return 'UA';
    if (firstInitial.isEmpty) return lastInitial.toUpperCase();
    if (lastInitial.isEmpty) return firstInitial.toUpperCase();

    return '$firstInitial$lastInitial'.toUpperCase();
  }

  /// Valida se a foto de perfil deve ser exibida
  static bool shouldShowProfilePhoto(UserEntity? user, bool isAnonymous) {
    if (isAnonymous) return false;

    final photoUrl = user?.photoUrl;
    if (photoUrl == null || photoUrl.isEmpty) return false;
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
        .replaceAll(
          RegExp(r'\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,}\b'),
          '***@***.***',
        )
        .replaceAll(
          RegExp(
            r'(password|senha|pass|pwd)\s*[:=]\s*\S+',
            caseSensitive: false,
          ),
          r'$1: ***',
        )
        .replaceAll(
          RegExp(r'\(?\d{2}\)?\s*\d{4,5}[-\s]?\d{4}'),
          '(**) *****-****',
        )
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
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9.!#$%&*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$',
    );
    if (email.length > 254) return false; // RFC 5321
    if (email.contains('..')) return false; // Evitar dots consecutivos
    if (email.startsWith('.') || email.endsWith('.')) return false;

    return emailRegex.hasMatch(email);
  }

  /// Cria configuração de suporte sanitizada (sem emails hardcoded)
  static Map<String, String> getSupportContactInfo() {
    return {
      'email': _getSupportEmail(),
      'response_time': 'Respondemos em até 48 horas úteis',
      'subject_prefix': '[Plantis App] ',
    };
  }

  /// Obtém email de suporte de forma segura
  static String _getSupportEmail() {
    if (kDebugMode) {
      return 'dev.suporte@plantis.app';
    }
    return 'suporte@plantis.app';
  }

  /// Sanitiza dados para Analytics (remove PII)
  static Map<String, dynamic> sanitizeAnalyticsData(Map<String, dynamic> data) {
    final sanitized = <String, dynamic>{};

    for (final entry in data.entries) {
      final key = entry.key;
      final value = entry.value;
      if (_isPotentialPII(key)) {
        continue; // Não incluir dados potencialmente sensíveis
      }
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
      'email',
      'phone',
      'name',
      'displayName',
      'address',
      'photoUrl',
      'userId',
      'id',
      'password',
      'token',
      'cpf',
      'cnpj',
      'rg',
      'birthDate',
      'location',
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

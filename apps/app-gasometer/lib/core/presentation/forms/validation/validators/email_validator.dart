import '../../architecture/i_form_validator.dart';
import 'base_validator.dart';

/// Validator for email addresses
/// 
/// This validator checks if a string is a valid email address format.
/// Supports various validation modes from simple to strict RFC compliance.
/// Follows Single Responsibility Principle by focusing solely on email validation.
class EmailValidator extends StringValidator {
  
  const EmailValidator({
    this.mode = EmailValidationMode.standard,
    this.allowInternational = true,
    super.errorMessage = 'Email inválido',
    super.metadata,
  });
  
  /// Create simple email validator
  factory EmailValidator.simple({String? errorMessage}) {
    return EmailValidator(
      mode: EmailValidationMode.simple,
      errorMessage: errorMessage ?? 'Email inválido',
    );
  }
  
  /// Create standard email validator
  factory EmailValidator.standard({String? errorMessage}) {
    return EmailValidator(
      mode: EmailValidationMode.standard,
      errorMessage: errorMessage ?? 'Email inválido',
    );
  }
  
  /// Create strict email validator
  factory EmailValidator.strict({String? errorMessage}) {
    return EmailValidator(
      mode: EmailValidationMode.strict,
      errorMessage: errorMessage ?? 'Email inválido',
    );
  }
  
  /// Create RFC 5322 compliant email validator
  factory EmailValidator.rfc5322({String? errorMessage}) {
    return EmailValidator(
      mode: EmailValidationMode.rfc5322,
      errorMessage: errorMessage ?? 'Email inválido',
    );
  }
  final EmailValidationMode mode;
  final bool allowInternational;
  
  @override
  String get validatorType => 'email';
  
  @override
  ValidationResult validateString(String value) {
    final email = value.trim().toLowerCase();
    
    if (!_isValidEmailFormat(email)) {
      return ValidationResult.invalid(errorMessage);
    }
    
    return ValidationResult.valid();
  }
  
  /// Check if email format is valid based on validation mode
  bool _isValidEmailFormat(String email) {
    switch (mode) {
      case EmailValidationMode.simple:
        return _simpleEmailValidation(email);
      case EmailValidationMode.standard:
        return _standardEmailValidation(email);
      case EmailValidationMode.strict:
        return _strictEmailValidation(email);
      case EmailValidationMode.rfc5322:
        return _rfc5322EmailValidation(email);
    }
  }
  
  /// Simple email validation (basic @ and . check)
  bool _simpleEmailValidation(String email) {
    return email.contains('@') && email.contains('.') && email.length > 5;
  }
  
  /// Standard email validation (commonly used pattern)
  bool _standardEmailValidation(String email) {
    final pattern = allowInternational
        ? r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'
        : r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';
    
    return RegExp(pattern, unicode: allowInternational).hasMatch(email);
  }
  
  /// Strict email validation (more comprehensive)
  bool _strictEmailValidation(String email) {
    // Check overall structure
    if (!email.contains('@') || email.split('@').length != 2) {
      return false;
    }
    
    final parts = email.split('@');
    final localPart = parts[0];
    final domain = parts[1];
    
    // Validate local part
    if (!_isValidLocalPart(localPart)) {
      return false;
    }
    
    // Validate domain
    if (!_isValidDomain(domain)) {
      return false;
    }
    
    return true;
  }
  
  /// RFC 5322 compliant email validation (most strict)
  bool _rfc5322EmailValidation(String email) {
    // This is a simplified version of RFC 5322
    // Full RFC 5322 implementation would be extremely complex
    const pattern = r'^[a-zA-Z0-9!#$%&\*+/=?^_`{|}~-]+(?:\.[a-zA-Z0-9!#$%&\*+/=?^_`{|}~-]+)*@(?:[a-zA-Z0-9](?:[a-zA-Z0-9-]*[a-zA-Z0-9])?\.)+[a-zA-Z0-9](?:[a-zA-Z0-9-]*[a-zA-Z0-9])?$';
    
    return RegExp(pattern).hasMatch(email);
  }
  
  /// Validate local part of email (before @)
  bool _isValidLocalPart(String localPart) {
    if (localPart.isEmpty || localPart.length > 64) {
      return false;
    }
    
    // Cannot start or end with dot
    if (localPart.startsWith('.') || localPart.endsWith('.')) {
      return false;
    }
    
    // Cannot have consecutive dots
    if (localPart.contains('..')) {
      return false;
    }
    
    // Check allowed characters
    const allowedChars = r'^[a-zA-Z0-9._%+-]+$';
    return RegExp(allowedChars).hasMatch(localPart);
  }
  
  /// Validate domain part of email (after @)
  bool _isValidDomain(String domain) {
    if (domain.isEmpty || domain.length > 253) {
      return false;
    }
    
    // Cannot start or end with dot or hyphen
    if (domain.startsWith('.') || domain.endsWith('.') ||
        domain.startsWith('-') || domain.endsWith('-')) {
      return false;
    }
    
    // Must contain at least one dot
    if (!domain.contains('.')) {
      return false;
    }
    
    // Check domain parts
    final domainParts = domain.split('.');
    for (final part in domainParts) {
      if (!_isValidDomainPart(part)) {
        return false;
      }
    }
    
    // TLD must be at least 2 characters
    final tld = domainParts.last;
    if (tld.length < 2) {
      return false;
    }
    
    return true;
  }
  
  /// Validate individual domain part
  bool _isValidDomainPart(String part) {
    if (part.isEmpty || part.length > 63) {
      return false;
    }
    
    // Cannot start or end with hyphen
    if (part.startsWith('-') || part.endsWith('-')) {
      return false;
    }
    
    // Check allowed characters
    const allowedChars = r'^[a-zA-Z0-9-]+$';
    return RegExp(allowedChars).hasMatch(part);
  }
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is EmailValidator &&
           other.mode == mode &&
           other.allowInternational == allowInternational &&
           other.errorMessage == errorMessage;
  }
  
  @override
  int get hashCode => Object.hash(
    validatorType,
    mode,
    allowInternational,
    errorMessage,
  );
}

/// Email validation modes
enum EmailValidationMode {
  /// Simple validation (basic @ and . check)
  simple,
  
  /// Standard validation (commonly used regex pattern)
  standard,
  
  /// Strict validation (comprehensive format checking)
  strict,
  
  /// RFC 5322 compliant validation
  rfc5322,
}

/// Email domain validator
class EmailDomainValidator extends StringValidator {
  
  const EmailDomainValidator({
    this.allowedDomains = const [],
    this.blockedDomains = const [],
    this.caseSensitive = false,
    super.errorMessage = 'Domínio de email não permitido',
    super.metadata,
  });
  
  /// Create validator with allowed domains
  factory EmailDomainValidator.allowOnly(
    List<String> domains, {
    String? errorMessage,
    bool caseSensitive = false,
  }) {
    return EmailDomainValidator(
      allowedDomains: domains,
      caseSensitive: caseSensitive,
      errorMessage: errorMessage ?? 'Apenas emails dos domínios ${domains.join(', ')} são permitidos',
    );
  }
  
  /// Create validator with blocked domains
  factory EmailDomainValidator.block(
    List<String> domains, {
    String? errorMessage,
    bool caseSensitive = false,
  }) {
    return EmailDomainValidator(
      blockedDomains: domains,
      caseSensitive: caseSensitive,
      errorMessage: errorMessage ?? 'Emails dos domínios ${domains.join(', ')} não são permitidos',
    );
  }
  
  /// Create validator for corporate emails only
  factory EmailDomainValidator.corporateOnly({String? errorMessage}) {
    const blockedDomains = [
      'gmail.com', 'hotmail.com', 'yahoo.com', 'outlook.com',
      'live.com', 'aol.com', 'icloud.com', 'protonmail.com',
    ];
    
    return EmailDomainValidator(
      blockedDomains: blockedDomains,
      errorMessage: errorMessage ?? 'Use um email corporativo',
    );
  }
  final List<String> allowedDomains;
  final List<String> blockedDomains;
  final bool caseSensitive;
  
  @override
  String get validatorType => 'email_domain';
  
  @override
  ValidationResult validateString(String value) {
    final email = caseSensitive ? value.trim() : value.trim().toLowerCase();
    
    // Basic email format check
    if (!email.contains('@')) {
      return ValidationResult.invalid('Email inválido');
    }
    
    final domain = email.split('@').last;
    
    // Check blocked domains
    if (blockedDomains.isNotEmpty) {
      final normalizedBlockedDomains = caseSensitive 
          ? blockedDomains 
          : blockedDomains.map((d) => d.toLowerCase()).toList();
      
      if (normalizedBlockedDomains.contains(domain)) {
        return ValidationResult.invalid(errorMessage);
      }
    }
    
    // Check allowed domains
    if (allowedDomains.isNotEmpty) {
      final normalizedAllowedDomains = caseSensitive 
          ? allowedDomains 
          : allowedDomains.map((d) => d.toLowerCase()).toList();
      
      if (!normalizedAllowedDomains.contains(domain)) {
        return ValidationResult.invalid(errorMessage);
      }
    }
    
    return ValidationResult.valid();
  }
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is EmailDomainValidator &&
           _listEquals(other.allowedDomains, allowedDomains) &&
           _listEquals(other.blockedDomains, blockedDomains) &&
           other.caseSensitive == caseSensitive &&
           other.errorMessage == errorMessage;
  }
  
  @override
  int get hashCode => Object.hash(
    validatorType,
    allowedDomains,
    blockedDomains,
    caseSensitive,
    errorMessage,
  );
  
  bool _listEquals<T>(List<T> a, List<T> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
import 'base_validator.dart';
import '../../architecture/i_form_validator.dart';

/// Validator for string and collection length constraints
/// 
/// This validator checks minimum and maximum length for strings,
/// lists, and other collections. Follows Single Responsibility
/// Principle by focusing solely on length validation.
class LengthValidator extends BaseFieldValidator {
  final int? minLength;
  final int? maxLength;
  final bool trimWhitespace;
  
  LengthValidator({
    this.minLength,
    this.maxLength,
    String? errorMessage,
    this.trimWhitespace = true,
    super.metadata,
  }) : super(errorMessage: errorMessage ?? _generateErrorMessage(minLength, maxLength));
  
  @override
  String get validatorType => 'length';
  
  @override
  bool isValidType(dynamic value) {
    return value is String || value is Iterable || value is Map;
  }
  
  @override
  String getTypeErrorMessage(dynamic value) {
    return 'Valor deve ser texto ou coleção';
  }
  
  @override
  ValidationResult performValidation(dynamic value) {
    final length = _getLength(value);
    
    // Check minimum length
    if (minLength != null && length < minLength!) {
      return ValidationResult.invalid(_getMinLengthMessage());
    }
    
    // Check maximum length
    if (maxLength != null && length > maxLength!) {
      return ValidationResult.invalid(_getMaxLengthMessage());
    }
    
    return ValidationResult.valid();
  }
  
  /// Get the length of a value
  int _getLength(dynamic value) {
    if (value is String) {
      return trimWhitespace ? value.trim().length : value.length;
    }
    if (value is Iterable) {
      return value.length;
    }
    if (value is Map) {
      return value.length;
    }
    return 0;
  }
  
  /// Generate default error message
  static String _generateErrorMessage(int? minLength, int? maxLength) {
    if (minLength != null && maxLength != null) {
      if (minLength == maxLength) {
        return 'Deve ter exatamente $minLength caractere(s)';
      }
      return 'Deve ter entre $minLength e $maxLength caractere(s)';
    }
    if (minLength != null) {
      return 'Deve ter pelo menos $minLength caractere(s)';
    }
    if (maxLength != null) {
      return 'Deve ter no máximo $maxLength caractere(s)';
    }
    return 'Comprimento inválido';
  }
  
  /// Get minimum length error message
  String _getMinLengthMessage() {
    if (minLength == null) return errorMessage;
    return 'Deve ter pelo menos $minLength caractere(s)';
  }
  
  /// Get maximum length error message
  String _getMaxLengthMessage() {
    if (maxLength == null) return errorMessage;
    return 'Deve ter no máximo $maxLength caractere(s)';
  }
  
  /// Create minimum length validator
  factory LengthValidator.min(int minLength, {String? errorMessage}) {
    return LengthValidator(
      minLength: minLength,
      errorMessage: errorMessage,
    );
  }
  
  /// Create maximum length validator
  factory LengthValidator.max(int maxLength, {String? errorMessage}) {
    return LengthValidator(
      maxLength: maxLength,
      errorMessage: errorMessage,
    );
  }
  
  /// Create exact length validator
  factory LengthValidator.exact(int length, {String? errorMessage}) {
    return LengthValidator(
      minLength: length,
      maxLength: length,
      errorMessage: errorMessage ?? 'Deve ter exatamente $length caractere(s)',
    );
  }
  
  /// Create range length validator
  factory LengthValidator.range(int minLength, int maxLength, {String? errorMessage}) {
    assert(minLength <= maxLength, 'minLength must be <= maxLength');
    return LengthValidator(
      minLength: minLength,
      maxLength: maxLength,
      errorMessage: errorMessage,
    );
  }
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is LengthValidator &&
           other.minLength == minLength &&
           other.maxLength == maxLength &&
           other.trimWhitespace == trimWhitespace &&
           other.errorMessage == errorMessage;
  }
  
  @override
  int get hashCode => Object.hash(
    validatorType,
    minLength,
    maxLength,
    trimWhitespace,
    errorMessage,
  );
}

/// Validator for word count in text
class WordCountValidator extends StringValidator {
  final int? minWords;
  final int? maxWords;
  
  WordCountValidator({
    this.minWords,
    this.maxWords,
    String? errorMessage,
    super.metadata,
  }) : super(errorMessage: errorMessage ?? _generateErrorMessage(minWords, maxWords));
  
  @override
  String get validatorType => 'word_count';
  
  @override
  ValidationResult validateString(String value) {
    final wordCount = _countWords(value.trim());
    
    // Check minimum words
    if (minWords != null && wordCount < minWords!) {
      return ValidationResult.invalid(_getMinWordsMessage());
    }
    
    // Check maximum words
    if (maxWords != null && wordCount > maxWords!) {
      return ValidationResult.invalid(_getMaxWordsMessage());
    }
    
    return ValidationResult.valid();
  }
  
  /// Count words in text
  int _countWords(String text) {
    if (text.isEmpty) return 0;
    return text.split(RegExp(r'\s+')).where((word) => word.isNotEmpty).length;
  }
  
  /// Generate default error message
  static String _generateErrorMessage(int? minWords, int? maxWords) {
    if (minWords != null && maxWords != null) {
      if (minWords == maxWords) {
        return 'Deve ter exatamente $minWords palavra(s)';
      }
      return 'Deve ter entre $minWords e $maxWords palavra(s)';
    }
    if (minWords != null) {
      return 'Deve ter pelo menos $minWords palavra(s)';
    }
    if (maxWords != null) {
      return 'Deve ter no máximo $maxWords palavra(s)';
    }
    return 'Número de palavras inválido';
  }
  
  /// Get minimum words error message
  String _getMinWordsMessage() {
    if (minWords == null) return errorMessage;
    return 'Deve ter pelo menos $minWords palavra(s)';
  }
  
  /// Get maximum words error message
  String _getMaxWordsMessage() {
    if (maxWords == null) return errorMessage;
    return 'Deve ter no máximo $maxWords palavra(s)';
  }
  
  /// Create minimum word count validator
  factory WordCountValidator.min(int minWords, {String? errorMessage}) {
    return WordCountValidator(
      minWords: minWords,
      errorMessage: errorMessage,
    );
  }
  
  /// Create maximum word count validator
  factory WordCountValidator.max(int maxWords, {String? errorMessage}) {
    return WordCountValidator(
      maxWords: maxWords,
      errorMessage: errorMessage,
    );
  }
  
  /// Create exact word count validator
  factory WordCountValidator.exact(int words, {String? errorMessage}) {
    return WordCountValidator(
      minWords: words,
      maxWords: words,
      errorMessage: errorMessage ?? 'Deve ter exatamente $words palavra(s)',
    );
  }
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is WordCountValidator &&
           other.minWords == minWords &&
           other.maxWords == maxWords &&
           other.errorMessage == errorMessage;
  }
  
  @override
  int get hashCode => Object.hash(validatorType, minWords, maxWords, errorMessage);
}

/// Validator for character count excluding whitespace
class CharacterCountValidator extends StringValidator {
  final int? minChars;
  final int? maxChars;
  final bool excludeWhitespace;
  
  CharacterCountValidator({
    this.minChars,
    this.maxChars,
    this.excludeWhitespace = false,
    String? errorMessage,
    super.metadata,
  }) : super(errorMessage: errorMessage ?? _generateErrorMessage(minChars, maxChars));
  
  @override
  String get validatorType => 'character_count';
  
  @override
  ValidationResult validateString(String value) {
    final charCount = excludeWhitespace 
        ? value.replaceAll(RegExp(r'\s'), '').length
        : value.length;
    
    // Check minimum characters
    if (minChars != null && charCount < minChars!) {
      return ValidationResult.invalid(_getMinCharsMessage());
    }
    
    // Check maximum characters
    if (maxChars != null && charCount > maxChars!) {
      return ValidationResult.invalid(_getMaxCharsMessage());
    }
    
    return ValidationResult.valid();
  }
  
  /// Generate default error message
  static String _generateErrorMessage(int? minChars, int? maxChars) {
    if (minChars != null && maxChars != null) {
      if (minChars == maxChars) {
        return 'Deve ter exatamente $minChars caractere(s)';
      }
      return 'Deve ter entre $minChars e $maxChars caractere(s)';
    }
    if (minChars != null) {
      return 'Deve ter pelo menos $minChars caractere(s)';
    }
    if (maxChars != null) {
      return 'Deve ter no máximo $maxChars caractere(s)';
    }
    return 'Número de caracteres inválido';
  }
  
  /// Get minimum characters error message
  String _getMinCharsMessage() {
    if (minChars == null) return errorMessage;
    return 'Deve ter pelo menos $minChars caractere(s)';
  }
  
  /// Get maximum characters error message
  String _getMaxCharsMessage() {
    if (maxChars == null) return errorMessage;
    return 'Deve ter no máximo $maxChars caractere(s)';
  }
  
  /// Create minimum character count validator
  factory CharacterCountValidator.min(int minChars, {String? errorMessage}) {
    return CharacterCountValidator(
      minChars: minChars,
      errorMessage: errorMessage,
    );
  }
  
  /// Create maximum character count validator
  factory CharacterCountValidator.max(int maxChars, {String? errorMessage}) {
    return CharacterCountValidator(
      maxChars: maxChars,
      errorMessage: errorMessage,
    );
  }
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CharacterCountValidator &&
           other.minChars == minChars &&
           other.maxChars == maxChars &&
           other.excludeWhitespace == excludeWhitespace &&
           other.errorMessage == errorMessage;
  }
  
  @override
  int get hashCode => Object.hash(
    validatorType,
    minChars,
    maxChars,
    excludeWhitespace,
    errorMessage,
  );
}
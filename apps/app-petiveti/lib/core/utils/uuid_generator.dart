import 'dart:math';

/// Simple UUID generator for the app
/// Generates a pseudo-UUID compatible with our needs
class UuidGenerator {
  static final Random _random = Random();
  
  /// Generates a UUID-like string
  /// Format: xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx
  static String generate() {
    return '${_generateGroup(8)}-${_generateGroup(4)}-4${_generateGroup(3)}-${_generateVariant()}${_generateGroup(3)}-${_generateGroup(12)}';
  }
  
  /// Generates a simple short ID (8 characters)
  static String generateShort() {
    return _generateGroup(8);
  }
  
  /// Generates a timestamp-based ID
  static String generateTimestamp() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final randomSuffix = _generateGroup(4);
    return '$timestamp-$randomSuffix';
  }
  
  static String _generateGroup(int length) {
    const chars = '0123456789abcdef';
    return List.generate(length, (index) => chars[_random.nextInt(16)]).join();
  }
  
  static String _generateVariant() {
    // UUID version 4 variant bits
    const variants = ['8', '9', 'a', 'b'];
    return variants[_random.nextInt(4)];
  }
}
/// Registro de SharedPreferences para inspeção
class SharedPreferencesRecord {
  const SharedPreferencesRecord({
    required this.key,
    required this.value,
    required this.type,
  });

  /// Chave do SharedPreferences
  final String key;
  
  /// Valor armazenado
  final dynamic value;
  
  /// Tipo do valor (String, int, bool, List<String>, double)
  final String type;

  /// Tamanho aproximado dos dados em bytes
  int get sizeInBytes {
    final stringValue = value?.toString() ?? '';
    return stringValue.length * 2; // Aproximação UTF-16
  }

  /// Se o valor é uma string
  bool get isString => type == 'String';

  /// Se o valor é um inteiro
  bool get isInt => type == 'int';

  /// Se o valor é um boolean
  bool get isBool => type == 'bool';

  /// Se o valor é uma lista
  bool get isList => type == 'List<String>';

  /// Se o valor é um double
  bool get isDouble => type == 'double';

  /// Converte para Map para serialização
  Map<String, dynamic> toJson() {
    return {
      'key': key,
      'value': value,
      'type': type,
      'sizeInBytes': sizeInBytes,
    };
  }

  /// Cria SharedPreferencesRecord a partir de Map
  factory SharedPreferencesRecord.fromJson(Map<String, dynamic> json) {
    return SharedPreferencesRecord(
      key: json['key'] as String,
      value: json['value'],
      type: json['type'] as String,
    );
  }

  /// Cria uma cópia com modificações
  SharedPreferencesRecord copyWith({
    String? key,
    dynamic value,
    String? type,
  }) {
    return SharedPreferencesRecord(
      key: key ?? this.key,
      value: value ?? this.value,
      type: type ?? this.type,
    );
  }

  /// Formata o valor para exibição
  String get formattedValue {
    if (value == null) return 'null';
    
    if (isList) {
      final list = value as List<String>;
      return '[${list.join(', ')}]';
    }
    
    if (isString) {
      return '"$value"';
    }
    
    return value.toString();
  }

  @override
  String toString() {
    return 'SharedPreferencesRecord(key: $key, type: $type, size: ${sizeInBytes}B)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SharedPreferencesRecord &&
        other.key == key &&
        other.type == type;
  }

  @override
  int get hashCode => Object.hash(key, type);
}

/// Registro de dados para inspeção de database
class DatabaseRecord {
  const DatabaseRecord({
    required this.id,
    required this.data,
    this.boxKey,
  });

  /// ID do registro
  final String id;
  
  /// Dados do registro como Map
  final Map<String, dynamic> data;
  
  /// Chave da box que contém este registro
  final String? boxKey;

  /// Campos disponíveis no registro
  List<String> get fields => data.keys.toList();

  /// Converte para Map para serialização
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'data': data,
      'boxKey': boxKey,
    };
  }

  /// Cria DatabaseRecord a partir de Map
  factory DatabaseRecord.fromJson(Map<String, dynamic> json) {
    return DatabaseRecord(
      id: json['id'] as String,
      data: json['data'] as Map<String, dynamic>,
      boxKey: json['boxKey'] as String?,
    );
  }

  /// Cria uma cópia com modificações
  DatabaseRecord copyWith({
    String? id,
    Map<String, dynamic>? data,
    String? boxKey,
  }) {
    return DatabaseRecord(
      id: id ?? this.id,
      data: data ?? this.data,
      boxKey: boxKey ?? this.boxKey,
    );
  }

  @override
  String toString() {
    return 'DatabaseRecord(id: $id, boxKey: $boxKey, fields: ${fields.length})';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DatabaseRecord &&
        other.id == id &&
        other.boxKey == boxKey;
  }

  @override
  int get hashCode => Object.hash(id, boxKey);
}
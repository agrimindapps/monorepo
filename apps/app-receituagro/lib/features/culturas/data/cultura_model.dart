import 'dart:convert';

/// Model para Cultura (Data Layer)
/// Sincronizado com CulturaEntity do Domain Layer
class CulturaModel {
  final String id;
  final String nome;
  final String? grupo;
  final String? descricao;
  final bool isActive;

  const CulturaModel({
    required this.id,
    required this.nome,
    this.grupo,
    this.descricao,
    this.isActive = true,
  });

  /// Factory para criar a partir de Map (ex: JSON, API response)
  factory CulturaModel.fromMap(Map<String, dynamic> map) {
    return CulturaModel(
      id: map['id']?.toString() ?? map['idReg']?.toString() ?? '',
      nome:
          map['nome']?.toString() ??
          map['cultura']?.toString() ??
          'Cultura desconhecida',
      grupo: map['grupo']?.toString(),
      descricao: map['descricao']?.toString(),
      isActive: map['isActive'] as bool? ?? true,
    );
  }

  /// Converter Model para Map (para enviar para API)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nome': nome,
      'grupo': grupo,
      'descricao': descricao,
      'isActive': isActive,
    };
  }

  /// Converter Model para JSON string
  String toJson() => jsonEncode(toMap());

  /// Factory para criar a partir de JSON string
  factory CulturaModel.fromJson(String json) {
    return CulturaModel.fromMap(jsonDecode(json) as Map<String, dynamic>);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CulturaModel &&
        other.id == id &&
        other.nome == nome &&
        other.grupo == grupo &&
        other.descricao == descricao &&
        other.isActive == isActive;
  }

  @override
  int get hashCode =>
      id.hashCode ^
      nome.hashCode ^
      grupo.hashCode ^
      descricao.hashCode ^
      isActive.hashCode;

  @override
  String toString() {
    return 'CulturaModel(id: $id, nome: $nome, grupo: $grupo, isActive: $isActive)';
  }
}

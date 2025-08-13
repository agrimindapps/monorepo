class DefensivoItemModel {
  final String idReg;
  final String line1;
  final String line2;
  final String avatar;
  final String? ingredienteAtivo;

  DefensivoItemModel({
    required this.idReg,
    required this.line1,
    required this.line2,
    required this.avatar,
    this.ingredienteAtivo,
  });

  factory DefensivoItemModel.fromMap(Map<String, dynamic> map) {
    return DefensivoItemModel(
      idReg: map['idReg'] ?? '',
      line1: map['line1'] ?? '',
      line2: map['line2'] ?? '',
      avatar: map['avatar'] ?? '',
      ingredienteAtivo: map['ingredienteAtivo']?.toString(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'idReg': idReg,
      'line1': line1,
      'line2': line2,
      'avatar': avatar,
      if (ingredienteAtivo != null) 'ingredienteAtivo': ingredienteAtivo,
    };
  }

  @override
  String toString() {
    return 'DefensivoItemModel(idReg: $idReg, line1: $line1, line2: $line2, avatar: $avatar, ingredienteAtivo: $ingredienteAtivo)';
  }

  /// Cria uma cópia do modelo com alguns campos alterados
  DefensivoItemModel copyWith({
    String? idReg,
    String? line1,
    String? line2,
    String? avatar,
    String? ingredienteAtivo,
  }) {
    return DefensivoItemModel(
      idReg: idReg ?? this.idReg,
      line1: line1 ?? this.line1,
      line2: line2 ?? this.line2,
      avatar: avatar ?? this.avatar,
      ingredienteAtivo: ingredienteAtivo ?? this.ingredienteAtivo,
    );
  }

  /// Compara dois modelos para verificar se são iguais
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DefensivoItemModel &&
        other.idReg == idReg &&
        other.line1 == line1 &&
        other.line2 == line2 &&
        other.avatar == avatar &&
        other.ingredienteAtivo == ingredienteAtivo;
  }

  @override
  int get hashCode {
    return idReg.hashCode ^ line1.hashCode ^ line2.hashCode ^ avatar.hashCode ^ ingredienteAtivo.hashCode;
  }

  bool get isDefensivo => line2.isNotEmpty && ingredienteAtivo != null;
}

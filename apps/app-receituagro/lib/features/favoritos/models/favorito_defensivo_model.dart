class FavoritoDefensivoModel {
  final int id;
  final String idReg;
  final String line1;
  final String line2;
  final String? nomeComum;
  final String? ingredienteAtivo;
  final String? classeAgronomica;
  final String? fabricante;
  final String? modoAcao;
  final DateTime dataCriacao;
  final String? userId;
  final bool synchronized;
  final DateTime? syncedAt;
  final DateTime? updatedAt;

  const FavoritoDefensivoModel({
    required this.id,
    required this.idReg,
    required this.line1,
    required this.line2,
    this.nomeComum,
    this.ingredienteAtivo,
    this.classeAgronomica,
    this.fabricante,
    this.modoAcao,
    required this.dataCriacao,
    this.userId,
    this.synchronized = false,
    this.syncedAt,
    this.updatedAt,
  });

  factory FavoritoDefensivoModel.fromMap(Map<String, dynamic> map) {
    return FavoritoDefensivoModel(
      id: map['id'] as int? ?? 0,
      idReg: map['idReg']?.toString() ?? '',
      line1: map['line1']?.toString() ?? map['nomeComum']?.toString() ?? 'Defensivo desconhecido',
      line2: map['line2']?.toString() ?? map['ingredienteAtivo']?.toString() ?? 'Sem ingrediente ativo',
      nomeComum: map['nomeComum']?.toString(),
      ingredienteAtivo: map['ingredienteAtivo']?.toString(),
      classeAgronomica: map['classeAgronomica']?.toString(),
      fabricante: map['fabricante']?.toString(),
      modoAcao: map['modoAcao']?.toString(),
      dataCriacao: DateTime.tryParse(map['dataCriacao']?.toString() ?? '') ?? DateTime.now(),
      userId: map['userId']?.toString(),
      synchronized: map['synchronized'] == true,
      syncedAt: map['syncedAt'] != null
          ? DateTime.tryParse(map['syncedAt'].toString())
          : null,
      updatedAt: map['updatedAt'] != null
          ? DateTime.tryParse(map['updatedAt'].toString())
          : null,
    );
  }

  String get displayName => nomeComum ?? line1;
  String get displayIngredient => ingredienteAtivo ?? line2;
  String get displayClass => classeAgronomica ?? 'Não especificado';
  String get displayFabricante => fabricante ?? 'Não informado';
  String get displayModoAcao => modoAcao ?? 'Não especificado';

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'idReg': idReg,
      'line1': line1,
      'line2': line2,
      'nomeComum': nomeComum,
      'ingredienteAtivo': ingredienteAtivo,
      'classeAgronomica': classeAgronomica,
      'fabricante': fabricante,
      'modoAcao': modoAcao,
      'dataCriacao': dataCriacao.toIso8601String(),
      'userId': userId,
      'synchronized': synchronized,
      'syncedAt': syncedAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  FavoritoDefensivoModel copyWith({
    int? id,
    String? idReg,
    String? line1,
    String? line2,
    String? nomeComum,
    String? ingredienteAtivo,
    String? classeAgronomica,
    String? fabricante,
    String? modoAcao,
    DateTime? dataCriacao,
    String? userId,
    bool? synchronized,
    DateTime? syncedAt,
    DateTime? updatedAt,
  }) {
    return FavoritoDefensivoModel(
      id: id ?? this.id,
      idReg: idReg ?? this.idReg,
      line1: line1 ?? this.line1,
      line2: line2 ?? this.line2,
      nomeComum: nomeComum ?? this.nomeComum,
      ingredienteAtivo: ingredienteAtivo ?? this.ingredienteAtivo,
      classeAgronomica: classeAgronomica ?? this.classeAgronomica,
      fabricante: fabricante ?? this.fabricante,
      modoAcao: modoAcao ?? this.modoAcao,
      dataCriacao: dataCriacao ?? this.dataCriacao,
      userId: userId ?? this.userId,
      synchronized: synchronized ?? this.synchronized,
      syncedAt: syncedAt ?? this.syncedAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  FavoritoDefensivoModel markAsUnsynchronized() {
    return copyWith(
      synchronized: false,
      updatedAt: DateTime.now(),
    );
  }

  FavoritoDefensivoModel markAsSynchronized() {
    return copyWith(
      synchronized: true,
      syncedAt: DateTime.now(),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FavoritoDefensivoModel &&
        other.id == id &&
        other.idReg == idReg;
  }

  @override
  int get hashCode => id.hashCode ^ idReg.hashCode;

  @override
  String toString() {
    return 'FavoritoDefensivoModel(id: $id, idReg: $idReg, nomeComum: $nomeComum)';
  }
}
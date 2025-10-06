class ComentarioModel {
  final String id;
  final String idReg;
  final String titulo;
  final String conteudo;
  final String ferramenta;
  final String pkIdentificador;
  final bool status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? userId;
  final bool synchronized;
  final DateTime? syncedAt;

  const ComentarioModel({
    required this.id,
    required this.idReg,
    required this.titulo,
    required this.conteudo,
    required this.ferramenta,
    required this.pkIdentificador,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.userId,
    this.synchronized = false,
    this.syncedAt,
  });

  factory ComentarioModel.fromMap(Map<String, dynamic> map) {
    return ComentarioModel(
      id: map['id']?.toString() ?? '',
      idReg: map['idReg']?.toString() ?? '',
      titulo: map['titulo']?.toString() ?? '',
      conteudo: map['conteudo']?.toString() ?? '',
      ferramenta: map['ferramenta']?.toString() ?? '',
      pkIdentificador: map['pkIdentificador']?.toString() ?? '',
      status: map['status'] == true || map['status'] == 1,
      createdAt: DateTime.tryParse(map['createdAt']?.toString() ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(map['updatedAt']?.toString() ?? '') ?? DateTime.now(),
      userId: map['userId']?.toString(),
      synchronized: map['synchronized'] == true,
      syncedAt: map['syncedAt'] != null
          ? DateTime.tryParse(map['syncedAt'].toString())
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'idReg': idReg,
      'titulo': titulo,
      'conteudo': conteudo,
      'ferramenta': ferramenta,
      'pkIdentificador': pkIdentificador,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'userId': userId,
      'synchronized': synchronized,
      'syncedAt': syncedAt?.toIso8601String(),
    };
  }

  ComentarioModel copyWith({
    String? id,
    String? idReg,
    String? titulo,
    String? conteudo,
    String? ferramenta,
    String? pkIdentificador,
    bool? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? userId,
    bool? synchronized,
    DateTime? syncedAt,
  }) {
    return ComentarioModel(
      id: id ?? this.id,
      idReg: idReg ?? this.idReg,
      titulo: titulo ?? this.titulo,
      conteudo: conteudo ?? this.conteudo,
      ferramenta: ferramenta ?? this.ferramenta,
      pkIdentificador: pkIdentificador ?? this.pkIdentificador,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      userId: userId ?? this.userId,
      synchronized: synchronized ?? this.synchronized,
      syncedAt: syncedAt ?? this.syncedAt,
    );
  }

  ComentarioModel markAsUnsynchronized() {
    return copyWith(
      synchronized: false,
      updatedAt: DateTime.now(),
    );
  }

  ComentarioModel markAsSynchronized() {
    return copyWith(
      synchronized: true,
      syncedAt: DateTime.now(),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ComentarioModel &&
        other.id == id &&
        other.conteudo == conteudo &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode => id.hashCode ^ conteudo.hashCode ^ updatedAt.hashCode;

  @override
  String toString() {
    return 'ComentarioModel(id: $id, conteudo: ${conteudo.substring(0, conteudo.length > 50 ? 50 : conteudo.length)}...)';
  }
}

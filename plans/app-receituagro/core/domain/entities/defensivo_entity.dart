/// Entity que representa um defensivo no domínio
/// 
/// Contém apenas dados e regras de negócio essenciais,
/// sem dependências de frameworks ou bibliotecas externas
class DefensivoEntity {
  final String id;
  final String nomeComercial;
  final String fabricante;
  final String classeAgronomica;
  final String ingredienteAtivo;
  final String modoDeAcao;
  final bool isNew;
  final DateTime? lastAccessed;

  const DefensivoEntity({
    required this.id,
    required this.nomeComercial,
    required this.fabricante,
    required this.classeAgronomica,
    required this.ingredienteAtivo,
    required this.modoDeAcao,
    this.isNew = false,
    this.lastAccessed,
  });

  /// Regra de negócio: um defensivo é considerado recente se foi acessado nos últimos 30 dias
  bool get isRecentlyAccessed {
    if (lastAccessed == null) return false;
    final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
    return lastAccessed!.isAfter(thirtyDaysAgo);
  }

  /// Regra de negócio: validação de dados obrigatórios
  bool get isValid {
    return id.isNotEmpty &&
        nomeComercial.isNotEmpty &&
        fabricante.isNotEmpty &&
        classeAgronomica.isNotEmpty &&
        ingredienteAtivo.isNotEmpty;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DefensivoEntity &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'DefensivoEntity{id: $id, nomeComercial: $nomeComercial, fabricante: $fabricante}';
  }

  DefensivoEntity copyWith({
    String? id,
    String? nomeComercial,
    String? fabricante,
    String? classeAgronomica,
    String? ingredienteAtivo,
    String? modoDeAcao,
    bool? isNew,
    DateTime? lastAccessed,
  }) {
    return DefensivoEntity(
      id: id ?? this.id,
      nomeComercial: nomeComercial ?? this.nomeComercial,
      fabricante: fabricante ?? this.fabricante,
      classeAgronomica: classeAgronomica ?? this.classeAgronomica,
      ingredienteAtivo: ingredienteAtivo ?? this.ingredienteAtivo,
      modoDeAcao: modoDeAcao ?? this.modoDeAcao,
      isNew: isNew ?? this.isNew,
      lastAccessed: lastAccessed ?? this.lastAccessed,
    );
  }
}
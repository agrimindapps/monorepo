/// DTO para transferência de dados de defensivo entre camadas
/// 
/// Usado para isolar as camadas e permitir mudanças independentes
/// sem afetar outras partes do sistema
class DefensivoDto {
  final String id;
  final String nomeComercial;
  final String fabricante;
  final String classeAgronomica;
  final String ingredienteAtivo;
  final String modoDeAcao;
  final bool isNew;
  final String? lastAccessedTimestamp;

  const DefensivoDto({
    required this.id,
    required this.nomeComercial,
    required this.fabricante,
    required this.classeAgronomica,
    required this.ingredienteAtivo,
    required this.modoDeAcao,
    this.isNew = false,
    this.lastAccessedTimestamp,
  });

  /// Cria DTO a partir de Map (vindo da camada de infraestrutura)
  factory DefensivoDto.fromMap(Map<String, dynamic> map) {
    return DefensivoDto(
      id: map['id']?.toString() ?? '',
      nomeComercial: map['nomeComercial']?.toString() ?? '',
      fabricante: map['fabricante']?.toString() ?? '',
      classeAgronomica: map['classeAgronomica']?.toString() ?? '',
      ingredienteAtivo: map['ingredienteAtivo']?.toString() ?? '',
      modoDeAcao: map['modoDeAcao']?.toString() ?? '',
      isNew: map['isNew'] == true || map['isNew'] == 'true',
      lastAccessedTimestamp: map['lastAccessed']?.toString(),
    );
  }

  /// Converte DTO para Map (para envio à camada de infraestrutura)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nomeComercial': nomeComercial,
      'fabricante': fabricante,
      'classeAgronomica': classeAgronomica,
      'ingredienteAtivo': ingredienteAtivo,
      'modoDeAcao': modoDeAcao,
      'isNew': isNew,
      'lastAccessed': lastAccessedTimestamp,
    };
  }

  @override
  String toString() {
    return 'DefensivoDto{id: $id, nomeComercial: $nomeComercial}';
  }

  DefensivoDto copyWith({
    String? id,
    String? nomeComercial,
    String? fabricante,
    String? classeAgronomica,
    String? ingredienteAtivo,
    String? modoDeAcao,
    bool? isNew,
    String? lastAccessedTimestamp,
  }) {
    return DefensivoDto(
      id: id ?? this.id,
      nomeComercial: nomeComercial ?? this.nomeComercial,
      fabricante: fabricante ?? this.fabricante,
      classeAgronomica: classeAgronomica ?? this.classeAgronomica,
      ingredienteAtivo: ingredienteAtivo ?? this.ingredienteAtivo,
      modoDeAcao: modoDeAcao ?? this.modoDeAcao,
      isNew: isNew ?? this.isNew,
      lastAccessedTimestamp: lastAccessedTimestamp ?? this.lastAccessedTimestamp,
    );
  }
}
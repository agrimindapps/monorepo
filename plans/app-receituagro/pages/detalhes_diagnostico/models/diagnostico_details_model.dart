// MÓDULO: Detalhes de Diagnóstico
// ARQUIVO: Model Principal de Diagnóstico
// DESCRIÇÃO: Modelo completo com todos os detalhes de um diagnóstico
// RESPONSABILIDADES: Estruturar dados completos do diagnóstico
// DEPENDÊNCIAS: Nenhuma (modelo puro)
// CRIADO: 2025-06-22 | ATUALIZADO: 2025-06-22
// AUTOR: Sistema de Desenvolvimento ReceituAgro

class DiagnosticoDetailsModel {
  final String idReg;
  final String nomeDefensivo;
  final String nomePraga;
  final String nomeCientifico;
  final String cultura;
  final String ingredienteAtivo;
  final String toxico;
  final String classAmbiental;
  final String classeAgronomica;
  final String formulacao;
  final String modoAcao;
  final String mapa;
  final String dosagem;
  final String vazaoTerrestre;
  final String vazaoAerea;
  final String intervaloAplicacao;
  final String intervaloSeguranca;
  final String tecnologia;

  const DiagnosticoDetailsModel({
    required this.idReg,
    required this.nomeDefensivo,
    required this.nomePraga,
    required this.nomeCientifico,
    required this.cultura,
    required this.ingredienteAtivo,
    required this.toxico,
    required this.classAmbiental,
    required this.classeAgronomica,
    required this.formulacao,
    required this.modoAcao,
    required this.mapa,
    required this.dosagem,
    required this.vazaoTerrestre,
    required this.vazaoAerea,
    required this.intervaloAplicacao,
    required this.intervaloSeguranca,
    required this.tecnologia,
  });

  factory DiagnosticoDetailsModel.empty() {
    return const DiagnosticoDetailsModel(
      idReg: '',
      nomeDefensivo: '',
      nomePraga: '',
      nomeCientifico: '',
      cultura: '',
      ingredienteAtivo: '',
      toxico: '',
      classAmbiental: '',
      classeAgronomica: '',
      formulacao: '',
      modoAcao: '',
      mapa: '',
      dosagem: '',
      vazaoTerrestre: '',
      vazaoAerea: '',
      intervaloAplicacao: '',
      intervaloSeguranca: '',
      tecnologia: '',
    );
  }

  DiagnosticoDetailsModel copyWith({
    String? idReg,
    String? nomeDefensivo,
    String? nomePraga,
    String? nomeCientifico,
    String? cultura,
    String? ingredienteAtivo,
    String? toxico,
    String? classAmbiental,
    String? classeAgronomica,
    String? formulacao,
    String? modoAcao,
    String? mapa,
    String? dosagem,
    String? vazaoTerrestre,
    String? vazaoAerea,
    String? intervaloAplicacao,
    String? intervaloSeguranca,
    String? tecnologia,
  }) {
    return DiagnosticoDetailsModel(
      idReg: idReg ?? this.idReg,
      nomeDefensivo: nomeDefensivo ?? this.nomeDefensivo,
      nomePraga: nomePraga ?? this.nomePraga,
      nomeCientifico: nomeCientifico ?? this.nomeCientifico,
      cultura: cultura ?? this.cultura,
      ingredienteAtivo: ingredienteAtivo ?? this.ingredienteAtivo,
      toxico: toxico ?? this.toxico,
      classAmbiental: classAmbiental ?? this.classAmbiental,
      classeAgronomica: classeAgronomica ?? this.classeAgronomica,
      formulacao: formulacao ?? this.formulacao,
      modoAcao: modoAcao ?? this.modoAcao,
      mapa: mapa ?? this.mapa,
      dosagem: dosagem ?? this.dosagem,
      vazaoTerrestre: vazaoTerrestre ?? this.vazaoTerrestre,
      vazaoAerea: vazaoAerea ?? this.vazaoAerea,
      intervaloAplicacao: intervaloAplicacao ?? this.intervaloAplicacao,
      intervaloSeguranca: intervaloSeguranca ?? this.intervaloSeguranca,
      tecnologia: tecnologia ?? this.tecnologia,
    );
  }

  bool get isEmpty => idReg.isEmpty;
  bool get isNotEmpty => !isEmpty;

  Map<String, dynamic> toMap() {
    return {
      'idReg': idReg,
      'nomeDefensivo': nomeDefensivo,
      'nomePraga': nomePraga,
      'nomeCientifico': nomeCientifico,
      'cultura': cultura,
      'ingredienteAtivo': ingredienteAtivo,
      'toxico': toxico,
      'classAmbiental': classAmbiental,
      'classeAgronomica': classeAgronomica,
      'formulacao': formulacao,
      'modoAcao': modoAcao,
      'mapa': mapa,
      'dosagem': dosagem,
      'vazaoTerrestre': vazaoTerrestre,
      'vazaoAerea': vazaoAerea,
      'intervaloAplicacao': intervaloAplicacao,
      'intervaloSeguranca': intervaloSeguranca,
      'tecnologia': tecnologia,
    };
  }
}

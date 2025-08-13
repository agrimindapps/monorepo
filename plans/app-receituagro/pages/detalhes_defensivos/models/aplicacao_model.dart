class AplicacaoModel {
  final String tecnologia;
  final String embalagens;
  final String manejoIntegrado;
  final String manejoResistencia;
  final String pHumanas;
  final String pAmbientais;
  final String compatibilidade;

  const AplicacaoModel({
    required this.tecnologia,
    required this.embalagens,
    required this.manejoIntegrado,
    required this.manejoResistencia,
    required this.pHumanas,
    required this.pAmbientais,
    required this.compatibilidade,
  });

  factory AplicacaoModel.fromMap(Map<String, dynamic> map) {
    return AplicacaoModel(
      tecnologia: map['tecnologia'] ?? '',
      embalagens: map['embalagens'] ?? '',
      manejoIntegrado: map['manejoIntegrado'] ?? '',
      manejoResistencia: map['manejoResistencia'] ?? '',
      pHumanas: map['pHumanas'] ?? '',
      pAmbientais: map['pAmbientais'] ?? '',
      compatibilidade: map['compatibilidade'] ?? '',
    );
  }

  factory AplicacaoModel.empty() {
    return const AplicacaoModel(
      tecnologia: '',
      embalagens: '',
      manejoIntegrado: '',
      manejoResistencia: '',
      pHumanas: '',
      pAmbientais: '',
      compatibilidade: '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'tecnologia': tecnologia,
      'embalagens': embalagens,
      'manejoIntegrado': manejoIntegrado,
      'manejoResistencia': manejoResistencia,
      'pHumanas': pHumanas,
      'pAmbientais': pAmbientais,
      'compatibilidade': compatibilidade,
    };
  }

  bool get isEmpty => 
      tecnologia.isEmpty && 
      embalagens.isEmpty && 
      manejoIntegrado.isEmpty &&
      manejoResistencia.isEmpty &&
      pHumanas.isEmpty &&
      pAmbientais.isEmpty &&
      compatibilidade.isEmpty;
}
// Dart imports:
import 'dart:convert';

/// Modelo para informação de texto estruturado usado em várias listas de detalhes
class InfoItem {
  final String titulo;
  final String descricao;

  InfoItem({
    required this.titulo,
    required this.descricao,
  });

  Map<String, dynamic> toMap() {
    return {
      'titulo': titulo,
      'descricao': descricao,
    };
  }

  factory InfoItem.fromMap(Map<String, dynamic> map) {
    return InfoItem(
      titulo: map['titulo'] ?? '',
      descricao: map['descricao'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory InfoItem.fromJson(String source) =>
      InfoItem.fromMap(json.decode(source));

  @override
  String toString() => 'InfoItem(titulo: $titulo, descricao: $descricao)';
}

/// Classe modelo para armazenar dados de uma praga específica
class PragaUnica {
  String idReg;
  String nomeComum;
  String nomeSecundario;
  String nomeCientifico;
  String nomeImagem;
  String tipoPraga;
  List<InfoItem> infoPlanta;
  List<InfoItem> infoFlores;
  List<InfoItem> infoFrutos;
  List<InfoItem> infoFolhas;
  List<InfoItem> infoPraga;
  String observacoes;
  List<Map<String, dynamic>> defensivos;

  // Propriedades adicionais para informações detalhadas
  String descricao;
  String biologia;
  String sintomas;
  String ocorrencia;
  String sinonimias;
  String nomesVulgares;
  String controle;
  String imagem;
  String linkExterno;

  /// Enum para os tipos de praga
  static const String TIPO_INSETO = '1';
  static const String TIPO_DOENCA = '2';
  static const String TIPO_PLANTA = '3';

  PragaUnica({
    this.idReg = '',
    this.nomeComum = '',
    this.nomeSecundario = '',
    this.nomeCientifico = '',
    this.nomeImagem = '',
    this.tipoPraga = '',
    List<InfoItem>? infoPlanta,
    List<InfoItem>? infoFlores,
    List<InfoItem>? infoFrutos,
    List<InfoItem>? infoFolhas,
    List<InfoItem>? infoPraga,
    this.observacoes = '',
    List<Map<String, dynamic>>? defensivos,
    this.descricao = '',
    this.biologia = '',
    this.sintomas = '',
    this.ocorrencia = '',
    this.sinonimias = '',
    this.nomesVulgares = '',
    this.controle = '',
    this.imagem = '',
    this.linkExterno = '',
  })  : infoPlanta = infoPlanta ?? [],
        infoFlores = infoFlores ?? [],
        infoFrutos = infoFrutos ?? [],
        infoFolhas = infoFolhas ?? [],
        infoPraga = infoPraga ?? [],
        defensivos = defensivos ?? [];

  /// Factory para criar uma instância vazia
  factory PragaUnica.empty() {
    return PragaUnica();
  }

  /// Converte o objeto para um Map para compatibilidade com o código existente
  Map<String, dynamic> toMap() {
    return {
      'idReg': idReg,
      'nomeComum': nomeComum,
      'nomeSecundario': nomeSecundario,
      'nomeCientifico': nomeCientifico,
      'nomeImagem': nomeImagem,
      'tipoPraga': tipoPraga,
      'infoPlanta': infoPlanta.map((info) => info.toMap()).toList(),
      'infoFlores': infoFlores.map((info) => info.toMap()).toList(),
      'infoFrutos': infoFrutos.map((info) => info.toMap()).toList(),
      'infoFolhas': infoFolhas.map((info) => info.toMap()).toList(),
      'infoPraga': infoPraga.map((info) => info.toMap()).toList(),
      'observacoes': observacoes,
      'defensivos': defensivos,
      'descricao': descricao,
      'biologia': biologia,
      'sintomas': sintomas,
      'ocorrencia': ocorrencia,
      'sinonimias': sinonimias,
      'nomesVulgares': nomesVulgares,
      'controle': controle,
      'imagem': imagem,
      'linkExterno': linkExterno,
    };
  }

  /// Cria uma instância de PragaUnica a partir de um Map
  factory PragaUnica.fromMap(Map<String, dynamic> map) {
    return PragaUnica(
      idReg: map['idReg']?.toString() ?? '',
      nomeComum: map['nomeComum']?.toString() ?? '',
      nomeSecundario: map['nomeSecundario']?.toString() ?? '',
      nomeCientifico: map['nomeCientifico']?.toString() ?? '',
      nomeImagem: map['nomeImagem']?.toString() ?? '',
      tipoPraga: map['tipoPraga']?.toString() ?? '',
      infoPlanta: _convertToInfoItemList(map['infoPlanta']),
      infoFlores: _convertToInfoItemList(map['infoFlores']),
      infoFrutos: _convertToInfoItemList(map['infoFrutos']),
      infoFolhas: _convertToInfoItemList(map['infoFolhas']),
      infoPraga: _convertToInfoItemList(map['infoPraga']),
      observacoes: map['observacoes']?.toString() ?? '',
      defensivos: _convertToMapList(map['defensivos']),
      descricao: map['descricao']?.toString() ?? '',
      biologia: map['biologia']?.toString() ?? '',
      sintomas: map['sintomas']?.toString() ?? '',
      ocorrencia: map['ocorrencia']?.toString() ?? '',
      sinonimias: map['sinonimias']?.toString() ?? '',
      nomesVulgares: map['nomesVulgares']?.toString() ?? '',
      controle: map['controle']?.toString() ?? '',
      imagem: map['imagem']?.toString() ?? '',
      linkExterno: map['linkExterno']?.toString() ?? '',
    );
  }

  /// Utilitário para converter uma lista dinâmica para lista de InfoItem
  static List<InfoItem> _convertToInfoItemList(dynamic list) {
    if (list == null) return [];
    if (list is! List) return [];

    return List<Map<String, dynamic>>.from(list)
        .map((map) => InfoItem.fromMap(map))
        .toList();
  }

  /// Utilitário para converter uma lista dinâmica para lista de Map<String, dynamic>
  static List<Map<String, dynamic>> _convertToMapList(dynamic list) {
    if (list == null) return [];
    if (list is! List) return [];

    return List<Map<String, dynamic>>.from(list);
  }

  /// Reseta o objeto para o estado inicial
  void reset() {
    idReg = '';
    nomeComum = '';
    nomeSecundario = '';
    nomeCientifico = '';
    nomeImagem = '';
    tipoPraga = '';
    infoPlanta = [];
    infoFlores = [];
    infoFrutos = [];
    infoFolhas = [];
    infoPraga = [];
    observacoes = '';
    defensivos = [];
    descricao = '';
    biologia = '';
    sintomas = '';
    ocorrencia = '';
    sinonimias = '';
    nomesVulgares = '';
    controle = '';
    imagem = '';
    linkExterno = '';
  }

  /// Atualiza os dados a partir de um Map
  void updateFromMap(Map<String, dynamic> data) {
    idReg = data['idReg']?.toString() ?? '';
    nomeComum = data['nomeComum']?.toString() ?? '';
    nomeCientifico = data['nomeCientifico']?.toString() ?? '';
    nomeImagem = data['nomeCientifico']?.toString() ??
        ''; // Usa o nome científico como base para o nome da imagem
    tipoPraga = data['tipoPraga']?.toString() ?? '';
    infoPlanta = [];
    infoFlores = [];
    infoFrutos = [];
    infoFolhas = [];
    infoPraga = [];
    observacoes = '';
    defensivos = [];
    descricao = '';
    biologia = '';
    sintomas = '';
    ocorrencia = '';
    sinonimias = '';
    nomesVulgares = '';
    controle = '';
    imagem = '';
    linkExterno = '';
  }

  /// Adiciona um item de informação à lista apropriada baseado no nome da lista
  void addInfoItem(String listName, InfoItem item) {
    switch (listName) {
      case 'infoPlanta':
        infoPlanta.add(item);
        break;
      case 'infoFlores':
        infoFlores.add(item);
        break;
      case 'infoFrutos':
        infoFrutos.add(item);
        break;
      case 'infoFolhas':
        infoFolhas.add(item);
        break;
      case 'infoPraga':
        infoPraga.add(item);
        break;
    }
  }

  /// Retorna o tipo de praga em formato legível
  String getTipoText() {
    switch (tipoPraga) {
      case TIPO_INSETO:
        return 'Inseto';
      case TIPO_DOENCA:
        return 'Doença';
      case TIPO_PLANTA:
        return 'Planta Invasora';
      default:
        return 'Desconhecido';
    }
  }

  /// Serializa para JSON
  String toJson() => json.encode(toMap());

  /// Cria uma instância a partir de JSON
  factory PragaUnica.fromJson(String source) =>
      PragaUnica.fromMap(json.decode(source));

  @override
  String toString() {
    return 'PragaUnica(idReg: $idReg, nomeComum: $nomeComum, nomeCientifico: $nomeCientifico, tipoPraga: $tipoPraga)';
  }
}

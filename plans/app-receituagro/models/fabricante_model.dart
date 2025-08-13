/// Modelo para representar um fabricante de defensivos agrícolas.
///
/// Este modelo encapsula todas as informações relativas a um fabricante,
/// incluindo seu identificador, nome, contato e estatísticas associadas.
class FabricanteModel {
  /// Identificador único do fabricante
  final String id;

  /// Nome do fabricante
  final String nome;

  /// Quantidade de produtos/registros associados a este fabricante
  final int quantidadeProdutos;

  /// CNPJ do fabricante (quando disponível)
  final String cnpj;

  /// Endereço do fabricante
  final String endereco;

  /// Telefone de contato
  final String telefone;

  /// E-mail de contato
  final String email;

  /// Website do fabricante
  final String website;

  /// Descrição ou observações adicionais
  final String descricao;

  /// Avatar ou iniciais para representação visual
  final String avatar;

  /// Construtor principal
  FabricanteModel({
    required this.id,
    required this.nome,
    this.quantidadeProdutos = 0,
    this.cnpj = '',
    this.endereco = '',
    this.telefone = '',
    this.email = '',
    this.website = '',
    this.descricao = '',
    this.avatar = '',
  });

  /// Cria um FabricanteModel a partir de um Map
  factory FabricanteModel.fromMap(Map<String, dynamic> map) {
    return FabricanteModel(
      id: map['idReg']?.toString() ?? '',
      nome: map['fabricante']?.toString() ?? '',
      quantidadeProdutos: int.tryParse(map['count']?.toString() ?? '0') ?? 0,
      cnpj: map['cnpj']?.toString() ?? '',
      endereco: map['endereco']?.toString() ?? '',
      telefone: map['telefone']?.toString() ?? '',
      email: map['email']?.toString() ?? '',
      website: map['website']?.toString() ?? '',
      descricao: map['descricao']?.toString() ?? '',
      avatar: map['avatar']?.toString() ?? '',
    );
  }

  /// Método alternativo para criar a partir de um map formatado específico
  /// utilizado nas listas de fabricantes
  factory FabricanteModel.fromFormattedMap(Map<String, dynamic> map) {
    return FabricanteModel(
      id: map['idReg']?.toString() ?? '',
      nome: map['line1']?.toString() ?? '',
      avatar: map['avatar']?.toString() ?? '',
      // Extrai o número de registros a partir do texto "X Registros"
      quantidadeProdutos:
          _extractNumberFromString(map['line2']?.toString() ?? '0 Registros'),
    );
  }

  /// Extrai o número a partir de um texto no formato "X Registros"
  static int _extractNumberFromString(String text) {
    final RegExp regExp = RegExp(r'(\d+)');
    final match = regExp.firstMatch(text);
    if (match != null && match.group(1) != null) {
      return int.tryParse(match.group(1)!) ?? 0;
    }
    return 0;
  }

  /// Converte o modelo para um Map
  Map<String, dynamic> toMap() {
    return {
      'idReg': id,
      'fabricante': nome,
      'count': quantidadeProdutos.toString(),
      'cnpj': cnpj,
      'endereco': endereco,
      'telefone': telefone,
      'email': email,
      'website': website,
      'descricao': descricao,
      'avatar': avatar,
    };
  }

  /// Converte para o formato específico usado nas listas
  Map<String, dynamic> toFormattedMap() {
    return {
      'idReg': id,
      'line1': nome,
      'line2': '$quantidadeProdutos Registros',
      'avatar': avatar,
    };
  }

  /// Cria uma cópia do modelo com alguns campos alterados
  FabricanteModel copyWith({
    String? id,
    String? nome,
    int? quantidadeProdutos,
    String? cnpj,
    String? endereco,
    String? telefone,
    String? email,
    String? website,
    String? descricao,
    String? avatar,
  }) {
    return FabricanteModel(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      quantidadeProdutos: quantidadeProdutos ?? this.quantidadeProdutos,
      cnpj: cnpj ?? this.cnpj,
      endereco: endereco ?? this.endereco,
      telefone: telefone ?? this.telefone,
      email: email ?? this.email,
      website: website ?? this.website,
      descricao: descricao ?? this.descricao,
      avatar: avatar ?? this.avatar,
    );
  }

  @override
  String toString() {
    return 'FabricanteModel(id: $id, nome: $nome, quantidadeProdutos: $quantidadeProdutos)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FabricanteModel && other.id == id && other.nome == nome;
  }

  @override
  int get hashCode => id.hashCode ^ nome.hashCode;
}

/// Modelo para representar uma categoria de defensivos.
///
/// Este modelo pode ser utilizado para classes agronômicas,
/// modos de ação, ou ingredientes ativos.
class CategoriaModel {
  /// Identificador único da categoria
  final String id;

  /// Nome da categoria
  final String nome;

  /// Quantidade de produtos/registros associados a esta categoria
  final int quantidadeProdutos;

  /// Descrição ou informações adicionais
  final String descricao;

  /// Avatar ou iniciais para representação visual
  final String avatar;

  /// Construtor principal
  CategoriaModel({
    required this.id,
    required this.nome,
    this.quantidadeProdutos = 0,
    this.descricao = '',
    this.avatar = '',
  });

  /// Cria um CategoriaModel a partir de um Map
  factory CategoriaModel.fromMap(Map<String, dynamic> map) {
    return CategoriaModel(
      id: map['idReg']?.toString() ?? '',
      nome: map['nome']?.toString() ?? '',
      quantidadeProdutos: int.tryParse(map['count']?.toString() ?? '0') ?? 0,
      descricao: map['descricao']?.toString() ?? '',
      avatar: map['avatar']?.toString() ?? '',
    );
  }

  /// Método alternativo para criar a partir de um map formatado específico
  /// utilizado nas listas de categorias
  factory CategoriaModel.fromFormattedMap(Map<String, dynamic> map) {
    return CategoriaModel(
      id: map['idReg']?.toString() ?? '',
      nome: map['line1']?.toString() ?? '',
      avatar: map['avatar']?.toString() ?? '',
      // Extrai o número de registros a partir do texto "X Registros"
      quantidadeProdutos:
          _extractNumberFromString(map['line2']?.toString() ?? '0 Registros'),
    );
  }

  /// Extrai o número a partir de um texto no formato "X Registros"
  static int _extractNumberFromString(String text) {
    final RegExp regExp = RegExp(r'(\d+)');
    final match = regExp.firstMatch(text);
    if (match != null && match.group(1) != null) {
      return int.tryParse(match.group(1)!) ?? 0;
    }
    return 0;
  }

  /// Converte o modelo para um Map
  Map<String, dynamic> toMap() {
    return {
      'idReg': id,
      'nome': nome,
      'count': quantidadeProdutos.toString(),
      'descricao': descricao,
      'avatar': avatar,
    };
  }

  /// Converte para o formato específico usado nas listas
  Map<String, dynamic> toFormattedMap() {
    return {
      'idReg': id,
      'line1': nome,
      'line2': '$quantidadeProdutos Registros',
      'avatar': avatar,
    };
  }

  /// Cria uma cópia do modelo com alguns campos alterados
  CategoriaModel copyWith({
    String? id,
    String? nome,
    int? quantidadeProdutos,
    String? descricao,
    String? avatar,
  }) {
    return CategoriaModel(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      quantidadeProdutos: quantidadeProdutos ?? this.quantidadeProdutos,
      descricao: descricao ?? this.descricao,
      avatar: avatar ?? this.avatar,
    );
  }

  @override
  String toString() {
    return 'CategoriaModel(id: $id, nome: $nome, quantidadeProdutos: $quantidadeProdutos)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CategoriaModel && other.id == id && other.nome == nome;
  }

  @override
  int get hashCode => id.hashCode ^ nome.hashCode;
}

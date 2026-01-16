import 'package:core/core.dart' show Equatable;

/// TODO: Definir categorias de implementos
/// 
/// Exemplos:
/// - preparo_solo: Preparo de Solo
/// - plantio: Plantio
/// - tratos_culturais: Tratos Culturais
/// - colheita: Colheita
/// - outros: Outros
enum ImplementCategory {
  preparoSolo('Preparo de Solo'),
  plantio('Plantio'),
  tratosCulturais('Tratos Culturais'),
  colheita('Colheita'),
  outros('Outros');

  const ImplementCategory(this.displayName);
  final String displayName;
}

/// TODO: Definir tipos de implementos
/// 
/// Exemplos:
/// - tracionado: Implemento tracionado (rebocado por trator)
/// - acoplado: Acoplado ao trator
/// - automotriz: Autopropelido
enum ImplementType {
  tracionado('Tracionado'),
  acoplado('Acoplado'),
  automotriz('Automotriz');

  const ImplementType(this.displayName);
  final String displayName;
}

/// Entidade de Implemento Agrícola
/// 
/// TODO: Revisar e completar campos conforme necessário
class ImplementEntity extends Equatable {
  const ImplementEntity({
    required this.id,
    required this.nome,
    required this.categoria,
    required this.tipo,
    required this.fabricante,
    required this.modelo,
    required this.aplicacao,
    required this.caracteristicas,
    required this.imageUrls,
    required this.isActive,
    required this.createdAt,
    this.larguraTrabalho,
    this.potenciaRequerida,
    this.pesoAproximado,
    this.capacidade,
    this.updatedAt,
    this.description,
  });

  /// ID único do implemento
  final String id;

  /// Nome do implemento
  final String nome;

  /// Categoria (preparo, plantio, etc)
  final ImplementCategory categoria;

  /// Tipo (tracionado, acoplado, automotriz)
  final ImplementType tipo;

  /// Fabricante
  final String fabricante;

  /// Modelo
  final String modelo;

  /// Largura de trabalho em metros (opcional)
  final double? larguraTrabalho;

  /// Potência requerida em CV/HP (opcional)
  final double? potenciaRequerida;

  /// Peso aproximado em kg (opcional)
  final double? pesoAproximado;

  /// Capacidade (ex: "5000L", "10 linhas") (opcional)
  final String? capacidade;

  /// Aplicação/finalidade
  final String aplicacao;

  /// Características técnicas
  final List<String> caracteristicas;

  /// URLs das imagens
  final List<String> imageUrls;

  /// Descrição detalhada (opcional)
  final String? description;

  /// Se está ativo
  final bool isActive;

  /// Data de criação
  final DateTime createdAt;

  /// Data de atualização
  final DateTime? updatedAt;

  @override
  List<Object?> get props => [
        id,
        nome,
        categoria,
        tipo,
        fabricante,
        modelo,
        larguraTrabalho,
        potenciaRequerida,
        pesoAproximado,
        capacidade,
        aplicacao,
        caracteristicas,
        imageUrls,
        description,
        isActive,
        createdAt,
        updatedAt,
      ];

  /// CopyWith para imutabilidade
  ImplementEntity copyWith({
    String? id,
    String? nome,
    ImplementCategory? categoria,
    ImplementType? tipo,
    String? fabricante,
    String? modelo,
    double? larguraTrabalho,
    double? potenciaRequerida,
    double? pesoAproximado,
    String? capacidade,
    String? aplicacao,
    List<String>? caracteristicas,
    List<String>? imageUrls,
    String? description,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ImplementEntity(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      categoria: categoria ?? this.categoria,
      tipo: tipo ?? this.tipo,
      fabricante: fabricante ?? this.fabricante,
      modelo: modelo ?? this.modelo,
      larguraTrabalho: larguraTrabalho ?? this.larguraTrabalho,
      potenciaRequerida: potenciaRequerida ?? this.potenciaRequerida,
      pesoAproximado: pesoAproximado ?? this.pesoAproximado,
      capacidade: capacidade ?? this.capacidade,
      aplicacao: aplicacao ?? this.aplicacao,
      caracteristicas: caracteristicas ?? this.caracteristicas,
      imageUrls: imageUrls ?? this.imageUrls,
      description: description ?? this.description,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

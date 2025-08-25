import 'package:equatable/equatable.dart';

/// Entidade base para todos os objetos de domínio
/// Garante que todas as entidades tenham um ID único e sejam comparáveis
abstract class BaseEntity extends Equatable {
  /// Cria uma instância da entidade base
  const BaseEntity({
    required this.id,
    this.createdAt,
    this.updatedAt,
  });

  /// Identificador único da entidade
  final String id;

  /// Data de criação da entidade
  final DateTime? createdAt;

  /// Data da última atualização da entidade
  final DateTime? updatedAt;

  /// Retorna true se a entidade é nova (não foi salva ainda)
  bool get isNew => createdAt == null;

  /// Cria uma nova instância da entidade com campos atualizados
  BaseEntity copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
  });

  @override
  List<Object?> get props => [id, createdAt, updatedAt];

  @override
  bool get stringify => true;
}
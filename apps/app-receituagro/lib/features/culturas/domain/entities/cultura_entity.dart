import 'package:core/core.dart';

/// Entity para Cultura seguindo princípios Clean Architecture
/// Representa uma cultura agrícola no domínio da aplicação
class CulturaEntity extends Equatable {
  final String id;
  final String nome;
  final String? grupo;
  final String? descricao;
  final bool isActive;

  const CulturaEntity({
    required this.id,
    required this.nome,
    this.grupo,
    this.descricao,
    this.isActive = true,
  });

  @override
  List<Object?> get props => [id, nome, grupo, descricao, isActive];

  @override
  String toString() {
    return 'CulturaEntity(id: $id, nome: $nome, grupo: $grupo)';
  }
}
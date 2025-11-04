import 'package:equatable/equatable.dart';

/// Diagnostico entity
///
/// TODO: Implement in FASE 2-3
/// Represents a diagnostic record in the domain layer
class DiagnosticoEntity extends Equatable {
  final String id;
  final String descricao;

  const DiagnosticoEntity({
    required this.id,
    required this.descricao,
  });

  @override
  List<Object?> get props => [id, descricao];
}

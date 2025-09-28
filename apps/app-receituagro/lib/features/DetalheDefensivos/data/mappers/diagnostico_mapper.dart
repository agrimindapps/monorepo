import '../../../diagnosticos/domain/entities/diagnostico_entity.dart' as diag_entity;
import '../../domain/entities/diagnostico_entity.dart';

/// Mapper para converter entre diferentes representações de diagnóstico
/// Segue padrão de conversão entre camadas
class DiagnosticoMapper {
  
  /// Converte da entity de diagnósticos para entity local
  static DiagnosticoEntity fromDiagnosticosEntity(diag_entity.DiagnosticoEntity entity) {
    return DiagnosticoEntity(
      id: entity.id,
      idDefensivo: entity.idDefensivo,
      nomeDefensivo: entity.nomeDefensivo,
      nomeCultura: entity.nomeCultura,
      nomePraga: entity.nomePraga,
      dosagem: entity.dosagem.displayDosagem,
      ingredienteAtivo: entity.idDefensivo,
      cultura: entity.nomeCultura ?? 'Não especificado',
      grupo: entity.nomePraga ?? 'Não especificado',
    );
  }

  /// Converte lista de entities
  static List<DiagnosticoEntity> fromDiagnosticosEntityList(List<diag_entity.DiagnosticoEntity> entities) {
    return entities.map((entity) => fromDiagnosticosEntity(entity)).toList();
  }
}
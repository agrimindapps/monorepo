import '../../../diagnosticos/domain/entities/diagnostico_entity.dart' as DiagEntity;
import '../../domain/entities/diagnostico_entity.dart';

/// Mapper para converter entre diferentes representações de diagnóstico
/// Segue padrão de conversão entre camadas
class DiagnosticoMapper {
  
  /// Converte da entity de diagnósticos para entity local
  static DiagnosticoEntity fromDiagnosticosEntity(DiagEntity.DiagnosticoEntity entity) {
    return DiagnosticoEntity(
      id: entity.id,
      nome: entity.nomeDefensivo ?? 'Nome não informado',
      ingredienteAtivo: entity.idDefensivo,
      dosagem: entity.dosagem.toString(),
      cultura: entity.nomeCultura ?? 'Não especificado',
      grupo: entity.nomePraga ?? 'Não especificado',
    );
  }

  /// Converte lista de entities
  static List<DiagnosticoEntity> fromDiagnosticosEntityList(List<DiagEntity.DiagnosticoEntity> entities) {
    return entities.map((entity) => fromDiagnosticosEntity(entity)).toList();
  }
}
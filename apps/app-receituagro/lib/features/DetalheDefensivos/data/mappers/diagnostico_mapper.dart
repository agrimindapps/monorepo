import '../../../../core/di/injection_container.dart';
import '../../../../core/data/repositories/cultura_hive_repository.dart';
import '../../../../core/data/repositories/pragas_hive_repository.dart';
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
      grupo: entity.nomePraga ?? 'Praga não identificada',
    );
  }

  /// Converte da entity de diagnósticos para entity local com resolução de nomes
  static Future<DiagnosticoEntity> fromDiagnosticosEntityWithResolution(
    diag_entity.DiagnosticoEntity entity,
  ) async {
    // Resolver nome da cultura se não estiver disponível
    String culturaNome = entity.nomeCultura ?? 'Não especificado';
    if (culturaNome == 'Não especificado' && entity.idCultura.isNotEmpty) {
      culturaNome = await _resolveCulturaNome(entity.idCultura);
    }

    // Resolver nome da praga se não estiver disponível
    String pragaNome = entity.nomePraga ?? 'Praga não identificada';
    if (pragaNome == 'Praga não identificada' && entity.idPraga.isNotEmpty) {
      pragaNome = await _resolvePragaNome(entity.idPraga);
    }

    return DiagnosticoEntity(
      id: entity.id,
      idDefensivo: entity.idDefensivo,
      nomeDefensivo: entity.nomeDefensivo,
      nomeCultura: culturaNome,
      nomePraga: pragaNome,
      dosagem: entity.dosagem.displayDosagem,
      ingredienteAtivo: entity.idDefensivo,
      cultura: culturaNome,
      grupo: pragaNome,
    );
  }

  /// Resolve o nome da cultura pelo ID
  static Future<String> _resolveCulturaNome(String idCultura) async {
    try {
      final culturaRepository = sl<CulturaHiveRepository>();
      final culturaData = await culturaRepository.getById(idCultura);
      if (culturaData != null && culturaData.cultura.isNotEmpty) {
        return culturaData.cultura;
      }
    } catch (e) {
      // Silently fail
    }
    return 'Não especificado';
  }

  /// Resolve o nome da praga pelo ID
  static Future<String> _resolvePragaNome(String idPraga) async {
    try {
      final pragaRepository = sl<PragasHiveRepository>();
      final pragaData = await pragaRepository.getById(idPraga);
      if (pragaData != null && pragaData.nomeComum.isNotEmpty) {
        return pragaData.nomeComum;
      }
    } catch (e) {
      // Silently fail
    }
    return 'Praga não identificada';
  }

  /// Converte lista de entities
  static List<DiagnosticoEntity> fromDiagnosticosEntityList(List<diag_entity.DiagnosticoEntity> entities) {
    return entities.map((entity) => fromDiagnosticosEntity(entity)).toList();
  }

  /// Converte lista de entities com resolução de nomes
  static Future<List<DiagnosticoEntity>> fromDiagnosticosEntityListWithResolution(
    List<diag_entity.DiagnosticoEntity> entities,
  ) async {
    final results = <DiagnosticoEntity>[];
    for (final entity in entities) {
      results.add(await fromDiagnosticosEntityWithResolution(entity));
    }
    return results;
  }
}
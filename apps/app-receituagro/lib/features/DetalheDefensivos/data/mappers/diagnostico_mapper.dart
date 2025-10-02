import '../../../../core/di/injection_container.dart';
import '../../../../core/data/repositories/cultura_hive_repository.dart';
import '../../../../core/data/repositories/pragas_hive_repository.dart';
import '../../../../core/data/repositories/fitossanitario_hive_repository.dart';
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
  /// ✅ CORRETO: SEMPRE resolve usando IDs, NUNCA confia em campos cached
  static Future<DiagnosticoEntity> fromDiagnosticosEntityWithResolution(
    diag_entity.DiagnosticoEntity entity,
  ) async {
    // ✅ SEMPRE resolve nome da cultura usando fkIdCultura (NUNCA usa nomeCultura cached)
    String culturaNome = 'Não especificado';
    if (entity.idCultura.isNotEmpty) {
      culturaNome = await _resolveCulturaNome(entity.idCultura);
    }

    // ✅ SEMPRE resolve nome da praga usando fkIdPraga (NUNCA usa nomePraga cached)
    String pragaNome = 'Praga não identificada';
    if (entity.idPraga.isNotEmpty) {
      pragaNome = await _resolvePragaNome(entity.idPraga);
    }

    // ✅ SEMPRE resolve nome do defensivo usando fkIdDefensivo
    String defensivoNome = 'Defensivo não identificado';
    if (entity.idDefensivo.isNotEmpty) {
      defensivoNome = await _resolveDefensivoNome(entity.idDefensivo);
    }

    return DiagnosticoEntity(
      id: entity.id,
      idDefensivo: entity.idDefensivo,
      nomeDefensivo: defensivoNome,
      nomeCultura: culturaNome,
      nomePraga: pragaNome,
      dosagem: entity.dosagem.displayDosagem,
      ingredienteAtivo: entity.idDefensivo,
      cultura: culturaNome,
      grupo: pragaNome,
    );
  }

  /// Resolve o nome do defensivo pelo ID
  static Future<String> _resolveDefensivoNome(String idDefensivo) async {
    try {
      final defensivoRepository = sl<FitossanitarioHiveRepository>();
      final defensivoData = await defensivoRepository.getById(idDefensivo);
      if (defensivoData != null && defensivoData.nomeComum.isNotEmpty) {
        return defensivoData.nomeComum;
      }
    } catch (e) {
      // Silently fail
    }
    return 'Defensivo não identificado';
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
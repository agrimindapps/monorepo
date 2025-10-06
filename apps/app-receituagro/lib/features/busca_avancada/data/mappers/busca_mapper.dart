import '../../../../core/data/models/cultura_hive.dart';
import '../../../../core/data/models/diagnostico_hive.dart';
import '../../../../core/data/models/fitossanitario_hive.dart';
import '../../../../core/data/models/pragas_hive.dart';
import '../../../../core/data/repositories/cultura_hive_repository.dart';
import '../../../../core/data/repositories/fitossanitario_hive_repository.dart';
import '../../../../core/data/repositories/pragas_hive_repository.dart';
import '../../../../core/di/injection_container.dart';
import '../../domain/entities/busca_entity.dart';

/// Mapper para conversão entre diferentes modelos e BuscaResultEntity
class BuscaMapper {
  /// Converte DiagnosticoHive para BuscaResultEntity
  /// ✅ CORRETO: Resolve nomes usando repositories, NUNCA usa campos cached
  static Future<BuscaResultEntity> diagnosticoToEntity(
    DiagnosticoHive diagnostico,
  ) async {
    // Resolve nomes dinamicamente usando repositories
    String defensivoNome = 'Defensivo não encontrado';
    String culturaNome = 'Cultura não encontrada';
    String pragaNome = 'Praga não encontrada';

    try {
      // Resolve defensivo
      final defensivoRepo = sl<FitossanitarioHiveRepository>();
      final defensivo = await defensivoRepo.getById(diagnostico.fkIdDefensivo);
      if (defensivo != null && defensivo.nomeComum.isNotEmpty) {
        defensivoNome = defensivo.nomeComum;
      }

      // Resolve cultura
      final culturaRepo = sl<CulturaHiveRepository>();
      final cultura = await culturaRepo.getById(diagnostico.fkIdCultura);
      if (cultura != null && cultura.cultura.isNotEmpty) {
        culturaNome = cultura.cultura;
      }

      // Resolve praga
      final pragaRepo = sl<PragasHiveRepository>();
      final praga = await pragaRepo.getById(diagnostico.fkIdPraga);
      if (praga != null && praga.nomeComum.isNotEmpty) {
        pragaNome = praga.nomeComum;
      }
    } catch (e) {
      // Falha silenciosamente para não quebrar a UI
    }

    return BuscaResultEntity(
      id: diagnostico.objectId,
      tipo: 'diagnostico',
      titulo: defensivoNome,
      subtitulo: culturaNome,
      descricao: '$pragaNome - ${diagnostico.dsMax}${diagnostico.um}',
      metadata: {
        'idCultura': diagnostico.fkIdCultura,
        'idPraga': diagnostico.fkIdPraga,
        'idDefensivo': diagnostico.fkIdDefensivo,
        'cultura': culturaNome,
        'praga': pragaNome,
        'defensivo': defensivoNome,
        'dosagem': '${diagnostico.dsMax}${diagnostico.um}',
      },
      relevancia: 1.0,
    );
  }

  /// Converte PragasHive para BuscaResultEntity
  static BuscaResultEntity pragaToEntity(PragasHive praga) {
    final nomeExibicao =
        (praga.nomeComum.isNotEmpty == true)
            ? praga.nomeComum
            : praga.nomeCientifico;

    return BuscaResultEntity(
      id: praga.objectId,
      tipo: 'praga',
      titulo: nomeExibicao,
      subtitulo:
          praga.nomeCientifico != nomeExibicao ? praga.nomeCientifico : null,
      descricao:
          'Praga identificada', // Simplified - TODO: usar propriedade correta
      metadata: {
        'nomeCientifico': praga.nomeCientifico,
        'nomeComum': praga.nomeComum,
        'reino': praga.reino,
        'ordem': praga.ordem,
        'familia': praga.familia,
      },
      relevancia: 1.0,
    );
  }

  /// Converte FitossanitarioHive para BuscaResultEntity
  static BuscaResultEntity defensivoToEntity(FitossanitarioHive defensivo) {
    final nomeExibicao =
        defensivo.nomeComum.isNotEmpty
            ? defensivo.nomeComum
            : defensivo.nomeTecnico;

    return BuscaResultEntity(
      id: defensivo.objectId ?? defensivo.idReg, // objectId pode ser null
      tipo: 'defensivo',
      titulo: nomeExibicao,
      subtitulo: defensivo.ingredienteAtivo,
      descricao: defensivo.modoAcao,
      metadata: {
        'nomeTecnico': defensivo.nomeTecnico,
        'nomeComum': defensivo.nomeComum,
        'ingredienteAtivo': defensivo.ingredienteAtivo ?? '',
        'formulacao': defensivo.formulacao ?? '',
        'modoAcao': defensivo.modoAcao ?? '',
        'classeAgronomica': defensivo.classeAgronomica ?? '',
        'fabricante': defensivo.fabricante ?? '',
      },
      relevancia: 1.0,
    );
  }

  /// Converte CulturaHive para BuscaResultEntity - SIMPLIFICADO
  static BuscaResultEntity culturaToEntity(CulturaHive cultura) {
    // TODO: Implementar após verificar propriedades corretas do CulturaHive
    return BuscaResultEntity(
      id: cultura.objectId,
      tipo: 'cultura',
      titulo: 'Cultura', // TODO: usar propriedade correta
      subtitulo: null,
      metadata: const {},
      relevancia: 1.0,
    );
  }

  /// Converte lista de diagnósticos com resolução assíncrona
  static Future<List<BuscaResultEntity>> diagnosticosToEntityList(
    List<DiagnosticoHive> diagnosticos,
  ) async {
    final results = <BuscaResultEntity>[];
    for (final d in diagnosticos) {
      results.add(await diagnosticoToEntity(d));
    }
    return results;
  }

  /// Converte lista de pragas
  static List<BuscaResultEntity> pragasToEntityList(List<PragasHive> pragas) {
    return pragas.map((p) => pragaToEntity(p)).toList();
  }

  /// Converte lista de defensivos
  static List<BuscaResultEntity> defensivosToEntityList(
    List<FitossanitarioHive> defensivos,
  ) {
    return defensivos.map((d) => defensivoToEntity(d)).toList();
  }

  /// Converte lista de culturas
  static List<BuscaResultEntity> culturasToEntityList(
    List<CulturaHive> culturas,
  ) {
    return culturas.map((c) => culturaToEntity(c)).toList();
  }

  /// Converte CulturaHive para DropdownItemEntity - SIMPLIFICADO
  static DropdownItemEntity culturaToDropdownItem(CulturaHive cultura) {
    return DropdownItemEntity(
      id: cultura.objectId,
      nome: 'Cultura', // TODO: usar propriedade correta
      grupo: 'Grupo não definido', // TODO: usar propriedade correta
      isActive: true,
    );
  }

  /// Converte PragasHive para DropdownItemEntity
  static DropdownItemEntity pragaToDropdownItem(PragasHive praga) {
    final nomeExibicao =
        (praga.nomeComum.isNotEmpty == true)
            ? praga.nomeComum
            : praga.nomeCientifico;

    return DropdownItemEntity(
      id: praga.objectId,
      nome: nomeExibicao,
      grupo: praga.familia ?? 'Família não informada',
      isActive: true,
    );
  }

  /// Converte FitossanitarioHive para DropdownItemEntity
  static DropdownItemEntity defensivoToDropdownItem(
    FitossanitarioHive defensivo,
  ) {
    final nomeExibicao =
        defensivo.nomeComum.isNotEmpty
            ? defensivo.nomeComum
            : defensivo.nomeTecnico;

    return DropdownItemEntity(
      id: defensivo.objectId ?? defensivo.idReg,
      nome: nomeExibicao,
      grupo: defensivo.classeAgronomica ?? 'Classe não informada',
      isActive: true,
    );
  }
}

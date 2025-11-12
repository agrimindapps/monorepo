import '../../../../database/repositories/culturas_repository.dart';
import '../../../../database/repositories/fitossanitarios_repository.dart';
import '../../../../database/repositories/pragas_repository.dart';
import '../../../../core/di/injection_container.dart';
import '../../domain/entities/busca_entity.dart';

/// Mapper para conversão entre diferentes modelos e BuscaResultEntity
class BuscaMapper {
  /// Converte Diagnostico para BuscaResultEntity
  /// ✅ CORRETO: Resolve nomes usando repositories, NUNCA usa campos cached
  static Future<BuscaResultEntity> diagnosticoToEntity(
    Diagnostico diagnostico,
  ) async {
    String defensivoNome = 'Defensivo não encontrado';
    String culturaNome = 'Cultura não encontrada';
    String pragaNome = 'Praga não encontrada';

    try {
      final defensivoRepo = sl<FitossanitariosRepository>();
      final defensivo = await defensivoRepo.findByIdDefensivo(
        diagnostico.fkIdDefensivo,
      );
      if (defensivo != null && defensivo.nome.isNotEmpty) {
        defensivoNome = defensivo.nome;
      }
      final culturaRepo = sl<CulturasRepository>();
      final culturaIdInt = int.tryParse(diagnostico.fkIdCultura);
      if (culturaIdInt != null) {
        final cultura = await culturaRepo.findById(culturaIdInt);
        if (cultura != null && cultura.nome.isNotEmpty) {
          culturaNome = cultura.nome;
        }
      }
      final pragaRepo = sl<PragasRepository>();
      final praga = await pragaRepo.findByIdPraga(diagnostico.fkIdPraga);
      if (praga != null && praga.nome.isNotEmpty) {
        pragaNome = praga.nome;
      }
    } catch (e) {}

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

  /// Converte Praga para BuscaResultEntity
  static BuscaResultEntity pragaToEntity(Praga praga) {
    final nomeExibicao = (praga.nomeComum.isNotEmpty == true)
        ? praga.nomeComum
        : praga.nomeCientifico;

    return BuscaResultEntity(
      id: praga.objectId,
      tipo: 'praga',
      titulo: nomeExibicao,
      subtitulo: praga.nomeCientifico != nomeExibicao
          ? praga.nomeCientifico
          : null,
      descricao: 'Praga identificada',
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

  /// Converte Fitossanitario para BuscaResultEntity
  static BuscaResultEntity defensivoToEntity(Fitossanitario defensivo) {
    final nomeExibicao = defensivo.nomeComum.isNotEmpty
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

  /// Converte Cultura para BuscaResultEntity - SIMPLIFICADO
  static BuscaResultEntity culturaToEntity(Cultura cultura) {
    return BuscaResultEntity(
      id: cultura.objectId,
      tipo: 'cultura',
      titulo: 'Cultura',
      subtitulo: null,
      metadata: const {},
      relevancia: 1.0,
    );
  }

  /// Converte lista de diagnósticos com resolução assíncrona
  static Future<List<BuscaResultEntity>> diagnosticosToEntityList(
    List<Diagnostico> diagnosticos,
  ) async {
    final results = <BuscaResultEntity>[];
    for (final d in diagnosticos) {
      results.add(await diagnosticoToEntity(d));
    }
    return results;
  }

  /// Converte lista de pragas
  static List<BuscaResultEntity> pragasToEntityList(List<Praga> pragas) {
    return pragas.map((p) => pragaToEntity(p)).toList();
  }

  /// Converte lista de defensivos
  static List<BuscaResultEntity> defensivosToEntityList(
    List<Fitossanitario> defensivos,
  ) {
    return defensivos.map((d) => defensivoToEntity(d)).toList();
  }

  /// Converte lista de culturas
  static List<BuscaResultEntity> culturasToEntityList(
    List<Cultura> culturas,
  ) {
    return culturas.map((c) => culturaToEntity(c)).toList();
  }

  /// Converte Cultura para DropdownItemEntity - SIMPLIFICADO
  static DropdownItemEntity culturaToDropdownItem(Cultura cultura) {
    return DropdownItemEntity(
      id: cultura.objectId,
      nome: 'Cultura',
      grupo: 'Grupo não definido',
      isActive: true,
    );
  }

  /// Converte Praga para DropdownItemEntity
  static DropdownItemEntity pragaToDropdownItem(Praga praga) {
    final nomeExibicao = (praga.nomeComum.isNotEmpty == true)
        ? praga.nomeComum
        : praga.nomeCientifico;

    return DropdownItemEntity(
      id: praga.objectId,
      nome: nomeExibicao,
      grupo: praga.familia ?? 'Família não informada',
      isActive: true,
    );
  }

  /// Converte Fitossanitario para DropdownItemEntity
  static DropdownItemEntity defensivoToDropdownItem(
    Fitossanitario defensivo,
  ) {
    final nomeExibicao = defensivo.nomeComum.isNotEmpty
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

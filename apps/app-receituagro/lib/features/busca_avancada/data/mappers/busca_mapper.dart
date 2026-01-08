import '../../../../database/receituagro_database.dart';
import '../../../../database/repositories/culturas_repository.dart';
import '../../../../database/repositories/fitossanitarios_repository.dart';
import '../../../../database/repositories/pragas_repository.dart';
import '../../domain/entities/busca_entity.dart';

/// Mapper para conversão entre diferentes modelos e BuscaResultEntity
class BuscaMapper {
  /// Converte Diagnostico para BuscaResultEntity
  /// ✅ CORRETO: Resolve nomes usando repositories, NUNCA usa campos cached
  static Future<BuscaResultEntity> diagnosticoToEntity(
    Diagnostico diagnostico, {
    required FitossanitariosRepository fitossanitariosRepo,
    required CulturasRepository culturasRepo,
    required PragasRepository pragasRepo,
  }) async {
    String defensivoNome = 'Defensivo não encontrado';
    String culturaNome = 'Cultura não encontrada';
    String pragaNome = 'Praga não encontrada';

    try {
      final defensivo = await fitossanitariosRepo.findByIdDefensivo(
        diagnostico.fkIdDefensivo,
      );
      if (defensivo != null && defensivo.nome.isNotEmpty) {
        defensivoNome = defensivo.nome;
      }

      final cultura = await culturasRepo.findByIdCultura(diagnostico.fkIdCultura);
      if (cultura != null && cultura.nome.isNotEmpty) {
        culturaNome = cultura.nome;
      }

      final praga =
          await pragasRepo.findByIdPraga(diagnostico.fkIdPraga);
      if (praga != null && praga.nome.isNotEmpty) {
        pragaNome = praga.nome;
      }
    } catch (e) {}

    return BuscaResultEntity(
      id: diagnostico.idReg,
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
    final nomeExibicao =
        (praga.nome.isNotEmpty == true) ? praga.nome : praga.nomeLatino ?? '';

    return BuscaResultEntity(
      id: praga.idPraga,
      tipo: 'praga',
      titulo: nomeExibicao,
      subtitulo: praga.nomeLatino != nomeExibicao ? praga.nomeLatino : null,
      descricao: 'Praga identificada',
      metadata: {
        'nomeCientifico': praga.nomeLatino ?? '',
        'nomeComum': praga.nome,
        'tipo': praga.tipo ?? '',
      },
      relevancia: 1.0,
    );
  }

  /// Converte Fitossanitario para BuscaResultEntity
  static BuscaResultEntity defensivoToEntity(Fitossanitario defensivo) {
    final nomeExibicao = (defensivo.nomeTecnico?.isNotEmpty ?? false)
        ? defensivo.nomeTecnico!
        : defensivo.nome;

    return BuscaResultEntity(
      id: defensivo.idDefensivo,
      tipo: 'defensivo',
      titulo: nomeExibicao,
      subtitulo: defensivo.ingredienteAtivo,
      descricao: defensivo.classeAgronomica ?? '',
      metadata: {
        'nome': defensivo.nome,
        'nomeTecnico': defensivo.nomeTecnico ?? '',
        'ingredienteAtivo': defensivo.ingredienteAtivo ?? '',
        'classeAgronomica': defensivo.classeAgronomica ?? '',
        'fabricante': defensivo.fabricante ?? '',
      },
      relevancia: 1.0,
    );
  }

  /// Converte Cultura para BuscaResultEntity - SIMPLIFICADO
  static BuscaResultEntity culturaToEntity(Cultura cultura) {
    return BuscaResultEntity(
      id: cultura.idCultura,
      tipo: 'cultura',
      titulo: cultura.nome,
      subtitulo: null, // Cultura doesn't have nomeLatino in new schema
      metadata: {
        'nome': cultura.nome,
      },
      relevancia: 1.0,
    );
  }

  /// Converte lista de diagnósticos com resolução assíncrona
  static Future<List<BuscaResultEntity>> diagnosticosToEntityList(
    List<Diagnostico> diagnosticos, {
    required FitossanitariosRepository fitossanitariosRepo,
    required CulturasRepository culturasRepo,
    required PragasRepository pragasRepo,
  }) async {
    final results = <BuscaResultEntity>[];
    for (final d in diagnosticos) {
      results.add(await diagnosticoToEntity(
        d,
        fitossanitariosRepo: fitossanitariosRepo,
        culturasRepo: culturasRepo,
        pragasRepo: pragasRepo,
      ));
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
      id: cultura.idCultura,
      nome: cultura.nome,
      grupo: 'Cultura', // Cultura doesn't have familia in new schema
      isActive: true,
    );
  }

  /// Converte Praga para DropdownItemEntity
  static DropdownItemEntity pragaToDropdownItem(Praga praga) {
    final nomeExibicao =
        (praga.nome.isNotEmpty == true) ? praga.nome : praga.nomeLatino ?? '';

    return DropdownItemEntity(
      id: praga.idPraga,
      nome: nomeExibicao,
      grupo: praga.tipo ?? 'Tipo não informado',
      isActive: true,
    );
  }

  /// Converte Fitossanitario para DropdownItemEntity
  static DropdownItemEntity defensivoToDropdownItem(
    Fitossanitario defensivo,
  ) {
    final nomeExibicao = (defensivo.nomeTecnico?.isNotEmpty ?? false)
        ? defensivo.nomeTecnico!
        : defensivo.nome;

    return DropdownItemEntity(
      id: defensivo.idDefensivo,
      nome: nomeExibicao,
      grupo: defensivo.classeAgronomica ?? 'Classe não informada',
      isActive: true,
    );
  }
}

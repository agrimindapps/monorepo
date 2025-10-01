import '../../../../core/data/models/cultura_hive.dart';
import '../../../../core/data/models/diagnostico_hive.dart';
import '../../../../core/data/models/fitossanitario_hive.dart';
import '../../../../core/data/models/pragas_hive.dart';
import '../../domain/entities/busca_entity.dart';

/// Mapper para conversão entre diferentes modelos e BuscaResultEntity
/// TEMPORARIAMENTE SIMPLIFICADO para resolver build blockers
/// TODO: Revisar e implementar mapeamentos corretos após análise das propriedades dos modelos
class BuscaMapper {
  /// Converte DiagnosticoHive para BuscaResultEntity
  static BuscaResultEntity diagnosticoToEntity(DiagnosticoHive diagnostico) {
    return BuscaResultEntity(
      id: diagnostico.objectId,
      tipo: 'diagnostico',
      titulo: diagnostico.nomeDefensivo ?? 'Defensivo não informado',
      subtitulo: diagnostico.nomeCultura ?? 'Cultura não informada',
      descricao: '${diagnostico.nomePraga ?? "Praga não informada"} - ${diagnostico.dsMax}${diagnostico.um}',
      metadata: {
        'cultura': diagnostico.nomeCultura ?? '',
        'praga': diagnostico.nomePraga ?? '',
        'defensivo': diagnostico.nomeDefensivo ?? '',
        'dosagem': '${diagnostico.dsMax}${diagnostico.um}',
      },
      relevancia: 1.0,
    );
  }

  /// Converte PragasHive para BuscaResultEntity  
  static BuscaResultEntity pragaToEntity(PragasHive praga) {
    final nomeExibicao = (praga.nomeComum.isNotEmpty == true) ? praga.nomeComum : praga.nomeCientifico;
    
    return BuscaResultEntity(
      id: praga.objectId,
      tipo: 'praga',
      titulo: nomeExibicao,
      subtitulo: praga.nomeCientifico != nomeExibicao ? praga.nomeCientifico : null,
      descricao: 'Praga identificada', // Simplified - TODO: usar propriedade correta
      metadata: {
        'nomeCientifico': praga.nomeCientifico,
        'nomeComum': praga.nomeComum ?? '',
        'reino': praga.reino ?? '',
        'ordem': praga.ordem ?? '',
        'familia': praga.familia ?? '',
      },
      relevancia: 1.0,
    );
  }

  /// Converte FitossanitarioHive para BuscaResultEntity
  static BuscaResultEntity defensivoToEntity(FitossanitarioHive defensivo) {
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

  /// Converte CulturaHive para BuscaResultEntity - SIMPLIFICADO
  static BuscaResultEntity culturaToEntity(CulturaHive cultura) {
    // TODO: Implementar após verificar propriedades corretas do CulturaHive
    return BuscaResultEntity(
      id: cultura.objectId ?? 'cultura_${DateTime.now().millisecondsSinceEpoch}',
      tipo: 'cultura',
      titulo: 'Cultura', // TODO: usar propriedade correta
      subtitulo: null,
      metadata: const {},
      relevancia: 1.0,
    );
  }

  /// Converte lista de diagnósticos
  static List<BuscaResultEntity> diagnosticosToEntityList(List<DiagnosticoHive> diagnosticos) {
    return diagnosticos.map((d) => diagnosticoToEntity(d)).toList();
  }

  /// Converte lista de pragas
  static List<BuscaResultEntity> pragasToEntityList(List<PragasHive> pragas) {
    return pragas.map((p) => pragaToEntity(p)).toList();
  }

  /// Converte lista de defensivos
  static List<BuscaResultEntity> defensivosToEntityList(List<FitossanitarioHive> defensivos) {
    return defensivos.map((d) => defensivoToEntity(d)).toList();
  }

  /// Converte lista de culturas
  static List<BuscaResultEntity> culturasToEntityList(List<CulturaHive> culturas) {
    return culturas.map((c) => culturaToEntity(c)).toList();
  }

  /// Converte CulturaHive para DropdownItemEntity - SIMPLIFICADO
  static DropdownItemEntity culturaToDropdownItem(CulturaHive cultura) {
    return DropdownItemEntity(
      id: cultura.objectId ?? 'cultura_${DateTime.now().millisecondsSinceEpoch}',
      nome: 'Cultura', // TODO: usar propriedade correta
      grupo: 'Grupo não definido', // TODO: usar propriedade correta
      isActive: true,
    );
  }

  /// Converte PragasHive para DropdownItemEntity
  static DropdownItemEntity pragaToDropdownItem(PragasHive praga) {
    final nomeExibicao = (praga.nomeComum.isNotEmpty == true) ? praga.nomeComum : praga.nomeCientifico;
    
    return DropdownItemEntity(
      id: praga.objectId,
      nome: nomeExibicao,
      grupo: praga.familia ?? 'Família não informada',
      isActive: true,
    );
  }

  /// Converte FitossanitarioHive para DropdownItemEntity
  static DropdownItemEntity defensivoToDropdownItem(FitossanitarioHive defensivo) {
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
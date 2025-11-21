import '../../database/receituagro_database.dart';
import '../../database/repositories/culturas_repository.dart';
import '../../database/repositories/fitossanitarios_repository.dart';
import '../../database/repositories/pragas_repository.dart';
import '../di/injection_container.dart' as di;
import '../utils/data_with_warnings.dart';
import '../utils/diagnostico_logger.dart';

/// Extensão para Diagnostico (Drift) com métodos display e formatação
extension DiagnosticoDriftExtension on Diagnostico {
  /// Retorna o nome do defensivo SEMPRE resolvendo dinamicamente usando defensivoId
  /// NUNCA usa dados armazenados (sempre busca do banco)
  Future<String> getDisplayNomeDefensivo() async {
    final result = await getDisplayNomeDefensivoWithWarnings();
    return result.data;
  }

  /// Retorna o nome do defensivo com warnings de validação
  Future<DataWithWarnings<String>> getDisplayNomeDefensivoWithWarnings() async {
    try {
      final repository = di.sl<FitossanitariosRepository>();
      final defensivo = await repository.findById(defensivoId);
      if (defensivo != null && defensivo.nomeComum?.isNotEmpty == true) {
        return DataWithWarnings(data: defensivo.nomeComum!);
      } else if (defensivo != null && defensivo.nome.isNotEmpty) {
        return DataWithWarnings(data: defensivo.nome);
      }
    } catch (e, stackTrace) {
      DiagnosticoLogger.dataResolutionFailure(
        'defensivo',
        defensivoId.toString(),
        e,
      );
      DiagnosticoLogger.error(
        'Erro ao resolver nome do defensivo',
        e,
        stackTrace,
      );
      return DataWithWarnings(
        data: 'Defensivo não identificado',
        warnings: ['Erro ao carregar dados do defensivo: $e'],
      );
    }

    DiagnosticoLogger.dataResolutionFailure(
      'defensivo',
      defensivoId.toString(),
      'Defensivo não encontrado',
    );
    return DataWithWarnings(
      data: 'Defensivo não identificado',
      warnings: [
        'Defensivo com ID $defensivoId não encontrado na base de dados',
      ],
    );
  }

  /// Retorna o nome da cultura SEMPRE resolvendo dinamicamente usando culturaId
  Future<String> getDisplayNomeCultura() async {
    final result = await getDisplayNomeCulturaWithWarnings();
    return result.data;
  }

  /// Retorna o nome da cultura com warnings de validação
  Future<DataWithWarnings<String>> getDisplayNomeCulturaWithWarnings() async {
    try {
      final repository = di.sl<CulturasRepository>();
      final cultura = await repository.findById(culturaId);
      if (cultura != null && cultura.nome.isNotEmpty) {
        return DataWithWarnings(data: cultura.nome);
      }
    } catch (e, stackTrace) {
      DiagnosticoLogger.dataResolutionFailure(
        'cultura',
        culturaId.toString(),
        e,
      );
      DiagnosticoLogger.error(
        'Erro ao resolver nome da cultura',
        e,
        stackTrace,
      );
      return DataWithWarnings(
        data: 'Cultura não identificada',
        warnings: ['Erro ao carregar dados da cultura: $e'],
      );
    }

    DiagnosticoLogger.dataResolutionFailure(
      'cultura',
      culturaId.toString(),
      'Cultura não encontrada',
    );
    return DataWithWarnings(
      data: 'Cultura não identificada',
      warnings: ['Cultura com ID $culturaId não encontrada na base de dados'],
    );
  }

  /// Retorna o nome da praga SEMPRE resolvendo dinamicamente usando pragaId
  Future<String> getDisplayNomePraga() async {
    final result = await getDisplayNomePragaWithWarnings();
    return result.data;
  }

  /// Retorna o nome da praga com warnings de validação
  Future<DataWithWarnings<String>> getDisplayNomePragaWithWarnings() async {
    try {
      final repository = di.sl<PragasRepository>();
      final praga = await repository.findById(pragaId);
      if (praga != null && praga.nome.isNotEmpty) {
        return DataWithWarnings(data: praga.nome);
      }
    } catch (e, stackTrace) {
      DiagnosticoLogger.dataResolutionFailure('praga', pragaId.toString(), e);
      DiagnosticoLogger.error('Erro ao resolver nome da praga', e, stackTrace);
      return DataWithWarnings(
        data: 'Praga não identificada',
        warnings: ['Erro ao carregar dados da praga: $e'],
      );
    }

    DiagnosticoLogger.dataResolutionFailure(
      'praga',
      pragaId.toString(),
      'Praga não encontrada',
    );
    return DataWithWarnings(
      data: 'Praga não identificada',
      warnings: ['Praga com ID $pragaId não encontrada na base de dados'],
    );
  }

  /// Retorna a dosagem formatada
  String get displayDosagem {
    if (dsMin?.isNotEmpty == true && dsMax.isNotEmpty) {
      return '$dsMin - $dsMax $um';
    } else if (dsMax.isNotEmpty) {
      return '$dsMax $um';
    }
    return 'Dosagem não especificada';
  }

  /// Retorna a vazão terrestre formatada
  String get displayVazaoTerrestre {
    if (minAplicacaoT?.isNotEmpty == true &&
        maxAplicacaoT?.isNotEmpty == true) {
      return '$minAplicacaoT - $maxAplicacaoT ${umT ?? "L/ha"}';
    } else if (maxAplicacaoT?.isNotEmpty == true) {
      return '$maxAplicacaoT ${umT ?? "L/ha"}';
    }
    return 'Não especificada';
  }

  /// Retorna a vazão aérea formatada
  String get displayVazaoAerea {
    if (minAplicacaoA?.isNotEmpty == true &&
        maxAplicacaoA?.isNotEmpty == true) {
      return '$minAplicacaoA - $maxAplicacaoA ${umA ?? "L/ha"}';
    } else if (maxAplicacaoA?.isNotEmpty == true) {
      return '$maxAplicacaoA ${umA ?? "L/ha"}';
    }
    return 'Não especificada';
  }

  /// Retorna o intervalo de aplicação formatado
  String get displayIntervaloAplicacao {
    if (intervalo?.isNotEmpty == true) {
      return '$intervalo dias';
    } else if (intervalo2?.isNotEmpty == true) {
      return '$intervalo2 dias';
    }
    return 'Não especificado';
  }

  /// Retorna a época de aplicação formatada
  String get displayEpocaAplicacao => epocaAplicacao?.isNotEmpty == true
      ? epocaAplicacao!
      : 'Época não especificada';

  /// Converte para mapa de dados resolvendo informações técnicas dinamicamente
  Future<Map<String, String>> toDataMap() async {
    final result = await toDataMapWithWarnings();
    return result.data;
  }

  /// Converte para mapa de dados com warnings de validação
  Future<DataWithWarnings<Map<String, String>>> toDataMapWithWarnings() async {
    List<String> warnings = [];
    String ingredienteAtivo = 'Consulte a bula do produto';
    String toxico = 'Consulte a bula do produto';
    String formulacao = 'Consulte a bula do produto';
    String modoAcao = 'Consulte a bula do produto';
    String nomeCientifico = 'N/A';

    // Resolver dados do defensivo
    try {
      final fitossanitarioRepo = di.sl<FitossanitariosRepository>();
      final defensivo = await fitossanitarioRepo.findById(defensivoId);
      if (defensivo != null) {
        if (defensivo.ingredienteAtivo?.isNotEmpty == true) {
          ingredienteAtivo = defensivo.ingredienteAtivo!;
        } else {
          warnings.add('Ingrediente ativo não disponível para o defensivo');
        }
        // Note: O modelo Fitossanitario não tem campos toxico, formulacao, modoAcao
        // Estes campos estão na tabela FitossanitariosInfo
        // Por enquanto, mantemos os valores padrão
      } else {
        warnings.add('Defensivo não encontrado na base de dados');
      }
    } catch (e, stackTrace) {
      warnings.add('Erro ao carregar dados do defensivo: $e');
      DiagnosticoLogger.error(
        'Erro ao resolver dados do defensivo em toDataMap',
        e,
        stackTrace,
      );
    }

    // Resolver dados da praga
    try {
      final pragaRepo = di.sl<PragasRepository>();
      final praga = await pragaRepo.findById(pragaId);
      if (praga != null && praga.nomeLatino?.isNotEmpty == true) {
        nomeCientifico = praga.nomeLatino!;
      } else {
        warnings.add('Nome científico da praga não disponível');
      }
    } catch (e, stackTrace) {
      warnings.add('Erro ao carregar dados da praga: $e');
      DiagnosticoLogger.error(
        'Erro ao resolver dados da praga em toDataMap',
        e,
        stackTrace,
      );
    }

    // Resolver nomes com warnings
    final nomeDefensivoResult = await getDisplayNomeDefensivoWithWarnings();
    final nomeCulturaResult = await getDisplayNomeCulturaWithWarnings();
    final nomePragaResult = await getDisplayNomePragaWithWarnings();

    warnings.addAll(nomeDefensivoResult.warnings);
    warnings.addAll(nomeCulturaResult.warnings);
    warnings.addAll(nomePragaResult.warnings);

    final dataMap = {
      'nomeDefensivo': nomeDefensivoResult.data,
      'nomeCultura': nomeCulturaResult.data,
      'nomePraga': nomePragaResult.data,
      'nomeCientifico': nomeCientifico,
      'dosagem': displayDosagem,
      'vazaoTerrestre': displayVazaoTerrestre,
      'vazaoAerea': displayVazaoAerea,
      'intervaloAplicacao': displayIntervaloAplicacao,
      'epocaAplicacao': displayEpocaAplicacao,
      'ingredienteAtivo': ingredienteAtivo,
      'toxico': toxico,
      'classificacaoToxicologica':
          toxico, // Alias para compatibilidade com widgets
      'formulacao': formulacao,
      'modoAcao': modoAcao,
      'intervaloSeguranca': 'Consulte a bula do produto',
      'classAmbiental': 'Consulte a bula do produto',
      'classificacaoAmbiental':
          'Consulte a bula do produto', // Alias para compatibilidade
      'classeAgronomica': 'Consulte a bula do produto',
      'mapa': 'Consulte o registro MAPA',
      'numeroAplicacoes':
          maxAplicacaoT ?? 'N/A', // Para instruções de aplicação
      'intervaloAplicacoes': intervalo ?? 'N/A',
      'volumeCalda': minAplicacaoA != null && maxAplicacaoA != null
          ? '$minAplicacaoA - $maxAplicacaoA $umA'
          : 'N/A',
      'tecnologia':
          'Aplicar conforme recomendações técnicas. Consulte um engenheiro agrônomo.',
    };

    if (warnings.isNotEmpty) {
      DiagnosticoLogger.incompleteData('Diagnóstico $idReg', warnings);
    }

    return DataWithWarnings(data: dataMap, warnings: warnings);
  }
}

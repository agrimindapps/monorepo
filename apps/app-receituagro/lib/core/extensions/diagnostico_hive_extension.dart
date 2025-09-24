import '../di/injection_container.dart' as di;
import '../models/diagnostico_hive.dart';
import '../repositories/cultura_hive_repository.dart';
import '../repositories/fitossanitario_hive_repository.dart';
import '../repositories/pragas_hive_repository.dart';

/// Extensão para DiagnosticoHive com métodos display e formatação
extension DiagnosticoHiveExtension on DiagnosticoHive {
  /// Retorna o nome do defensivo resolvendo dinamicamente se necessário
  String get displayNomeDefensivo {
    // Primeiro tenta usar o nome já armazenado
    if (nomeDefensivo?.isNotEmpty == true) {
      return nomeDefensivo!;
    }
    
    // Se não tiver, resolve dinamicamente usando o repository
    try {
      final repository = di.sl<FitossanitarioHiveRepository>();
      final defensivo = repository.getById(fkIdDefensivo);
      if (defensivo != null && defensivo.nomeComum.isNotEmpty) {
        return defensivo.nomeComum;
      }
    } catch (e) {
      // Falha silenciosamente para não quebrar a UI
    }
    
    return 'Defensivo não identificado';
  }

  /// Retorna o nome da cultura resolvendo dinamicamente se necessário
  String get displayNomeCultura {
    // Primeiro tenta usar o nome já armazenado
    if (nomeCultura?.isNotEmpty == true) {
      return nomeCultura!;
    }
    
    // Se não tiver, resolve dinamicamente usando o repository
    try {
      final repository = di.sl<CulturaHiveRepository>();
      final cultura = repository.getById(fkIdCultura);
      if (cultura != null && cultura.cultura.isNotEmpty) {
        return cultura.cultura;
      }
    } catch (e) {
      // Falha silenciosamente para não quebrar a UI
    }
    
    return 'Cultura não identificada';
  }

  /// Retorna o nome da praga resolvendo dinamicamente se necessário
  String get displayNomePraga {
    // Primeiro tenta usar o nome já armazenado
    if (nomePraga?.isNotEmpty == true) {
      return nomePraga!;
    }
    
    // Se não tiver, resolve dinamicamente usando o repository
    try {
      final repository = di.sl<PragasHiveRepository>();
      final praga = repository.getById(fkIdPraga);
      if (praga != null && praga.nomeComum.isNotEmpty) {
        return praga.nomeComum;
      }
    } catch (e) {
      // Falha silenciosamente para não quebrar a UI
    }
    
    return 'Praga não identificada';
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
    if (minAplicacaoT?.isNotEmpty == true && maxAplicacaoT?.isNotEmpty == true) {
      return '$minAplicacaoT - $maxAplicacaoT ${umT ?? "L/ha"}';
    } else if (maxAplicacaoT?.isNotEmpty == true) {
      return '$maxAplicacaoT ${umT ?? "L/ha"}';
    }
    return 'Não especificada';
  }

  /// Retorna a vazão aérea formatada  
  String get displayVazaoAerea {
    if (minAplicacaoA?.isNotEmpty == true && maxAplicacaoA?.isNotEmpty == true) {
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
  Map<String, String> toDataMap() {
    // Resolve entidades relacionadas para obter dados técnicos
    String ingredienteAtivo = 'Consulte a bula do produto';
    String toxico = 'Consulte a bula do produto';
    String formulacao = 'Consulte a bula do produto';
    String modoAcao = 'Consulte a bula do produto';
    String nomeCientifico = 'N/A';
    
    // Busca dados técnicos do defensivo
    try {
      final fitossanitarioRepo = di.sl<FitossanitarioHiveRepository>();
      final defensivo = fitossanitarioRepo.getById(fkIdDefensivo);
      if (defensivo != null) {
        if (defensivo.ingredienteAtivo?.isNotEmpty == true) {
          ingredienteAtivo = defensivo.ingredienteAtivo!;
        }
        if (defensivo.toxico?.isNotEmpty == true) {
          toxico = defensivo.toxico!;
        }
        if (defensivo.formulacao?.isNotEmpty == true) {
          formulacao = defensivo.formulacao!;
        }
        if (defensivo.modoAcao?.isNotEmpty == true) {
          modoAcao = defensivo.modoAcao!;
        }
      }
    } catch (e) {
      // Falha silenciosamente para não quebrar a UI
    }
    
    // Busca nome científico da praga
    try {
      final pragaRepo = di.sl<PragasHiveRepository>();
      final praga = pragaRepo.getById(fkIdPraga);
      if (praga != null && praga.nomeCientifico.isNotEmpty) {
        nomeCientifico = praga.nomeCientifico;
      }
    } catch (e) {
      // Falha silenciosamente para não quebrar a UI
    }

    return {
      'nomeDefensivo': displayNomeDefensivo,
      'nomeCultura': displayNomeCultura,
      'nomePraga': displayNomePraga,
      'nomeCientifico': nomeCientifico,
      'dosagem': displayDosagem,
      'vazaoTerrestre': displayVazaoTerrestre,
      'vazaoAerea': displayVazaoAerea,
      'intervaloAplicacao': displayIntervaloAplicacao,
      'epocaAplicacao': displayEpocaAplicacao,
      'ingredienteAtivo': ingredienteAtivo,
      'toxico': toxico,
      'formulacao': formulacao,
      'modoAcao': modoAcao,
      'intervaloSeguranca': 'Consulte a bula do produto',
      'classAmbiental': 'Consulte a bula do produto',
      'classeAgronomica': 'Consulte a bula do produto',
      'mapa': 'Consulte o registro MAPA',
      'tecnologia': 'Aplicar conforme recomendações técnicas. Consulte um engenheiro agrônomo.',
    };
  }
}
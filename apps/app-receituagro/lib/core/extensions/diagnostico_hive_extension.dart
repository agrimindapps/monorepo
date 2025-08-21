import '../models/diagnostico_hive.dart';

/// Extensão para DiagnosticoHive com métodos display e formatação
extension DiagnosticoHiveExtension on DiagnosticoHive {
  /// Retorna o nome do defensivo ou um padrão
  String get displayNomeDefensivo => nomeDefensivo?.isNotEmpty == true 
      ? nomeDefensivo! 
      : 'Defensivo não informado';

  /// Retorna o nome da cultura ou um padrão
  String get displayNomeCultura => nomeCultura?.isNotEmpty == true 
      ? nomeCultura! 
      : 'Cultura não informada';

  /// Retorna o nome da praga ou um padrão
  String get displayNomePraga => nomePraga?.isNotEmpty == true 
      ? nomePraga! 
      : 'Praga não informada';

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

  /// Converte para mapa de dados para compatibilidade
  Map<String, String> toDataMap() {
    return {
      'nomeDefensivo': displayNomeDefensivo,
      'nomeCultura': displayNomeCultura,
      'nomePraga': displayNomePraga,
      'dosagem': displayDosagem,
      'vazaoTerrestre': displayVazaoTerrestre,
      'vazaoAerea': displayVazaoAerea,
      'intervaloAplicacao': displayIntervaloAplicacao,
      'epocaAplicacao': displayEpocaAplicacao,
      'intervaloSeguranca': 'Consulte a bula do produto',
      'ingredienteAtivo': 'Consulte a bula do produto',
      'toxico': 'Consulte a bula do produto',
      'classAmbiental': 'Consulte a bula do produto',
      'classeAgronomica': 'Consulte a bula do produto',
      'formulacao': 'Consulte a bula do produto',
      'modoAcao': 'Consulte a bula do produto',
      'mapa': 'Consulte o registro MAPA',
      'tecnologia': 'Aplicar conforme recomendações técnicas. Consulte um engenheiro agrônomo.',
    };
  }
}
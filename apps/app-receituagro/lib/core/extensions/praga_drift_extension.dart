import '../../database/receituagro_database.dart';

/// Extensão para Praga (Drift) com métodos display compatíveis com PragaModel
extension PragaDriftExtension on Praga {
  String get displayName => nome;

  String get displaySecondaryName =>
      nomeLatino?.isNotEmpty == true ? nomeLatino! : '';

  String get displayType {
    switch (tipo?.toLowerCase()) {
      case 'inseto':
      case '1':
        return 'Inseto';
      case 'fungo':
      case 'bacteria':
      case 'virus':
      case '2':
        return 'Doença';
      case 'nematoide':
        return 'Nematoide';
      case 'planta daninha':
      case '3':
        return 'Planta Daninha';
      default:
        return tipo?.isNotEmpty == true ? tipo! : 'Praga';
    }
  }

  /// Descrição não está mais no modelo Praga - consultar PragasInf
  String get displayDescription => 'Consulte informações detalhadas';

  /// Retorna sintomas consultando a tabela PragasInf
  Future<String> getDisplaySintomas() async {
    try {
      // TODO: Implementar consulta à tabela PragasInf quando necessário
      // Por enquanto retorna valor padrão
      return 'Sintomas específicos da espécie';
    } catch (e) {
      return 'Sintomas específicos da espécie';
    }
  }

  /// Retorna controle consultando a tabela PragasInf
  Future<String> getDisplayControle() async {
    try {
      // TODO: Implementar consulta à tabela PragasInf quando necessário
      // Por enquanto retorna valor padrão
      return 'Consulte métodos de controle recomendados';
    } catch (e) {
      return 'Consulte métodos de controle recomendados';
    }
  }

  /// Deriva um nome secundário alternativo se não houver nome científico
  String get nomeSecundario =>
      nomeLatino?.isNotEmpty == true ? nomeLatino! : nome;

  /// Converte para Map de String para dynamic para compatibilidade
  Map<String, dynamic> toDataMap() {
    return {
      'idPraga': idPraga,
      'nome': nome,
      'nomeLatino': nomeLatino,
      'tipo': tipo,
      'status': status,
      'dominio': dominio,
      'reino': reino,
      'familia': familia,
      'genero': genero,
      'especie': especie,
    };
  }
}

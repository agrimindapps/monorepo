import '../../database/receituagro_database.dart';

/// Extensão para Praga (Drift) com métodos display compatíveis com PragaModel
extension PragaDriftExtension on Praga {
  String get displayName => nome;

  String get displaySecondaryName =>
      nomeLatino?.isNotEmpty == true ? nomeLatino! : '';

  String get displayType {
    switch (tipo?.toLowerCase()) {
      case 'inseto':
        return 'Inseto';
      case 'fungo':
        return 'Doença';
      case 'bacteria':
        return 'Doença';
      case 'virus':
        return 'Doença';
      case 'nematoide':
        return 'Nematoide';
      case 'planta daninha':
        return 'Planta Daninha';
      default:
        return tipo?.isNotEmpty == true ? tipo! : 'Praga';
    }
  }

  String get displayDescription =>
      descricao?.isNotEmpty == true ? descricao! : 'Descrição não disponível';

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
      'id': id,
      'idPraga': idPraga,
      'nome': nome,
      'nomeLatino': nomeLatino,
      'tipo': tipo,
      'imagemUrl': imagemUrl,
      'descricao': descricao,
    };
  }
}

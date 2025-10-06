import '../data/models/pragas_hive.dart';

/// Extensão para PragasHive com métodos display compatíveis com PragaModel
extension PragasHiveExtension on PragasHive {
  String get displayName => nomeComum;
  
  String get displaySecondaryName => nomeCientifico.isNotEmpty ? nomeCientifico : '';
  
  String get displayType {
    switch (tipoPraga) {
      case '1':
        return 'Inseto';
      case '2':
        return 'Doença';
      case '3':
        return 'Planta Daninha';
      default:
        return 'Praga';
    }
  }
  String get displayDescription => 
      ordem?.isNotEmpty == true 
          ? 'Ordem: $ordem${familia?.isNotEmpty == true ? ', Família: $familia' : ''}' 
          : 'Descrição não disponível';

  String get displaySintomas => 'Sintomas específicos da espécie';
  
  String get displayControle => 'Consulte métodos de controle recomendados';

  /// Deriva um nome secundário alternativo se não houver nome científico
  String get nomeSecundario => nomeCientifico.isNotEmpty ? nomeCientifico : nomeComum;
}

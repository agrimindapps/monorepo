// Project imports:
import '../../../core/utils/string_formatters.dart';
import '../../models/defensivo_item_model.dart';
import '../../models/diagnostico_item_model.dart';

/// Formatter Service para Defensivos
/// Responsabilidade única: formatação de dados para apresentação
class DefensivosFormatter {
  
  /// Formata lista de defensivos para exibição
  List<Map<String, dynamic>> formatDefensivosItems(
    List<Map<String, dynamic>> items,
  ) {
    final formattedItems = items.map((row) {
      final model = DefensivoItemModel(
        idReg: row['idReg'] ?? '',
        line1: StringFormatters.capitalizeFirstLetter(row['nomeComum'] ?? ''),
        line2: StringFormatters.processIngredientQuantity(
          row['ingredienteAtivo'] ?? '',
          row['quantProduto'] ?? '',
        ),
        avatar: StringFormatters.createAvatar(row['nomeComum'] ?? ''),
        ingredienteAtivo: row['ingredienteAtivo'] ?? '',
      );
      return model.toMap();
    }).toList();

    formattedItems
        .sort((a, b) => (a['line1'] as String).compareTo(b['line1'] as String));
    return formattedItems;
  }
  
  /// Formata itens de categoria (classe agronômica, modo de ação, etc)
  List<Map<String, dynamic>> formatCategoryItems(
    List<Map<String, dynamic>> items,
    bool showIngrediente,
  ) {
    return items.map((row) {
      final model = DefensivoItemModel(
        idReg: row['idReg'] ?? '',
        line1: row['nomeComum'] ?? '',
        line2: showIngrediente
            ? row['ingredienteAtivo'] ?? ''
            : StringFormatters.processIngredientQuantity(
                row['ingredienteAtivo'] ?? '', row['quantProduto'] ?? ''),
        avatar: StringFormatters.createAvatar(row['nomeComum'] ?? ''),
        ingredienteAtivo: row['ingredienteAtivo'] ?? '',
      );
      return model.toMap();
    }).toList();
  }
  
  /// Cria item de categoria com contagem
  Map<String, dynamic> createCategoryItem(String item, int count) {
    final model = DefensivoItemModel(
      idReg: item,
      line1: StringFormatters.capitalizeFirstLetter(item),
      line2: '$count Registros',
      avatar: StringFormatters.createAvatar(item),
    );
    return model.toMap();
  }
  
  /// Formata lista de fabricantes
  List<Map<String, dynamic>> formatManufacturers(
    List<String> manufacturers,
    int Function(String) countCallback,
  ) {
    return manufacturers.map((manufacturer) {
      final count = countCallback(manufacturer);
      return {
        'idReg': manufacturer,
        'line1': StringFormatters.capitalizeFirstLetter(manufacturer),
        'line2': '$count Registros',
        'avatar': StringFormatters.createAvatar(manufacturer),
      };
    }).toList();
  }
  
  /// Cria item de diagnóstico base formatado
  DiagnosticoItemModel createBaseDiagnosticItem(Map<String, dynamic> row) {
    final formattedDosagem =
        StringFormatters.formatDosagem(row['dsMin'], row['dsMax'], row['um']);

    final formattedVazaoTerrestre = StringFormatters.formatAplicacao(
      row['minAplicacaoT'],
      row['maxAplicacaoT'],
      row['umT'],
      'Não Especificado',
    );

    final formattedVazaoAerea = StringFormatters.formatAplicacao(
      row['minAplicacaoA'],
      row['maxAplicacaoA'],
      row['umA'],
      'Não indicado para aplicações aéreas',
    );

    final formattedIntervaloAplicacao =
        StringFormatters.formatIntervalo(row['intervalo']);

    final formattedIntervaloSeguranca =
        StringFormatters.formatIntervalo(row['intervalo2']);

    return DiagnosticoItemModel(
      idReg: row['idReg'] ?? '',
      nomePraga: '',
      nomeCientifico: '',
      fkIdCultura: row['fkIdCultura'] ?? '',
      cultura: '',
      fkIdDefensivo: row['fkIdDefensivo'] ?? '',
      nomeDefensivo: '',
      ingredienteAtivo: '',
      fkIdPraga: row['fkIdPraga'] ?? '',
      dosagem: formattedDosagem,
      vazaoTerrestre: formattedVazaoTerrestre,
      vazaoAerea: formattedVazaoAerea,
      intervaloAplicacao: formattedIntervaloAplicacao,
      intervaloSeguranca: formattedIntervaloSeguranca,
    );
  }
  
  /// Enriquece item de diagnóstico com dados relacionados
  void enrichDiagnosticItem({
    required Map<String, dynamic> item,
    required Map<String, dynamic> row,
    required List<Map<String, dynamic>> pragas,
    required List<Map<String, dynamic>> culturas,
    required List<Map<String, dynamic>> defensivos,
  }) {
    final cultura = culturas.firstWhere(
      (r) => r['idReg'] == row['fkIdCultura'],
      orElse: () => {'cultura': ''},
    );
    item['cultura'] = cultura['cultura'];

    final praga = pragas.firstWhere(
      (r) => r['idReg'] == row['fkIdPraga'],
      orElse: () => {'nomeComum': '', 'nomeCientifico': ''},
    );

    if (praga.isNotEmpty) {
      item['nomePraga'] = praga['nomeComum'];
      item['nomeCientifico'] = praga['nomeCientifico'];

      final defensivo = defensivos.firstWhere(
        (r) => r['idReg'] == row['fkIdDefensivo'],
        orElse: () => {
          'nomeComum': '',
          'ingredienteAtivo': '',
          'quantProduto': '',
        },
      );

      item['nomeDefensivo'] = defensivo['nomeComum'];
      item['ingredienteAtivo'] = StringFormatters.processIngredientQuantity(
        defensivo['ingredienteAtivo'],
        defensivo['quantProduto'],
      );
    }
  }
}
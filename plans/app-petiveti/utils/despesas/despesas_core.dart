class DespesasCore {
  static List<String> getAvailableTipos() {
    return [
      'Veterinário',
      'Medicamento',
      'Ração',
      'Brinquedo',
      'Higiene',
      'Transporte',
      'Hotel',
      'Estética',
      'Vacina',
      'Cirurgia',
      'Exame',
      'Emergência',
      'Petshop',
      'Outros',
    ];
  }

  static List<String> getCommonTipos() {
    return [
      'Veterinário',
      'Medicamento',
      'Ração',
      'Higiene',
      'Brinquedo',
    ];
  }

  static String? getDefaultTipo() {
    final tipos = getAvailableTipos();
    return tipos.isNotEmpty ? tipos.first : null;
  }

  static bool isTipoValid(String tipo) {
    return getAvailableTipos().contains(tipo);
  }

  static String normalizeTipo(String tipo) {
    final found = getAvailableTipos()
        .where((t) => t.toLowerCase() == tipo.toLowerCase())
        .firstOrNull;
    return found ?? tipo;
  }

  static bool isValidValor(double valor) {
    return valor > 0 && valor <= 99999.99;
  }

  static bool isValidDescricao(String descricao) {
    return descricao.trim().isNotEmpty && descricao.length <= 255;
  }

  static bool isValidObservacao(String? observacao) {
    return observacao == null || observacao.length <= 500;
  }

  static String? generateSuggestion(String tipo, String? currentText) {
    final suggestions = {
      'Veterinário': 'Consulta veterinária de rotina',
      'Medicamento': 'Medicamento prescrito pelo veterinário',
      'Ração': 'Ração premium para alimentação',
      'Brinquedo': 'Brinquedo para entretenimento',
      'Higiene': 'Produtos de higiene e limpeza',
      'Transporte': 'Transporte para consulta veterinária',
      'Hotel': 'Hospedagem em hotel para pets',
      'Estética': 'Serviços de estética e tosquia',
      'Vacina': 'Vacinação preventiva',
      'Cirurgia': 'Procedimento cirúrgico',
      'Exame': 'Exames laboratoriais ou de imagem',
      'Emergência': 'Atendimento de emergência',
      'Petshop': 'Compras em petshop',
      'Outros': 'Outras despesas relacionadas ao pet',
    };

    if (currentText == null || currentText.trim().isEmpty) {
      return suggestions[tipo];
    }

    return null;
  }

  static Map<String, dynamic> exportToJson({
    required String animalId,
    required DateTime data,
    required String tipo,
    required double valor,
    required String descricao,
    String? observacao,
  }) {
    return {
      'animalId': animalId,
      'data': data.toIso8601String(),
      'tipo': tipo,
      'valor': valor,
      'descricao': descricao,
      'observacao': observacao,
    };
  }

  static double roundToTwoDecimals(double value) {
    return double.parse(value.toStringAsFixed(2));
  }

  static bool isValidValueRange(double value) {
    return value >= 0.01 && value <= 99999.99;
  }

  static bool isValidDescriptionLength(String description) {
    return description.length <= 255;
  }

  static String limitDescription(String description) {
    if (description.length <= 255) {
      return description;
    }
    return description.substring(0, 255);
  }

  static double calculatePercentage(double value, double total) {
    if (total == 0) return 0;
    return (value / total) * 100;
  }
}
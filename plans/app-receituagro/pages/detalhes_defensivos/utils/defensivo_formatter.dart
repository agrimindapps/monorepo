/// Utilitário completo para formatação de textos e dados de defensivos
class DefensivoFormatter {
  
  // ========== FORMATAÇÃO GERAL DE TEXTO ==========
  
  /// Remove tags HTML básicas e formata texto para exibição
  static String formatText(String text) {
    if (text.isEmpty) return text;
    
    return text
        .replaceAll(RegExp(r'<br\s*\/?>', caseSensitive: false), '\n')
        .replaceAll(RegExp(r'<p>', caseSensitive: false), '')
        .replaceAll(RegExp(r'</p>', caseSensitive: false), '\n')
        .replaceAll(RegExp(r'<div>', caseSensitive: false), '')
        .replaceAll(RegExp(r'</div>', caseSensitive: false), '\n')
        .replaceAll(RegExp(r'&nbsp;'), ' ')
        .replaceAll(RegExp(r'&amp;'), '&')
        .replaceAll(RegExp(r'&lt;'), '<')
        .replaceAll(RegExp(r'&gt;'), '>')
        .replaceAll(RegExp(r'&quot;'), '"')
        .replaceAll(RegExp(r'&#39;'), "'")
        .trim();
  }

  /// Remove todas as tags HTML de um texto
  static String stripHtml(String text) {
    if (text.isEmpty) return text;
    
    return text
        .replaceAll(RegExp(r'<[^>]*>'), '')
        .replaceAll(RegExp(r'&nbsp;'), ' ')
        .replaceAll(RegExp(r'&amp;'), '&')
        .replaceAll(RegExp(r'&lt;'), '<')
        .replaceAll(RegExp(r'&gt;'), '>')
        .replaceAll(RegExp(r'&quot;'), '"')
        .replaceAll(RegExp(r'&#39;'), "'")
        .trim();
  }

  /// Limita o texto a um número máximo de caracteres
  static String truncate(String text, int maxLength, {String suffix = '...'}) {
    if (text.length <= maxLength) return text;
    return text.substring(0, maxLength - suffix.length) + suffix;
  }

  /// Capitaliza a primeira letra de cada palavra
  static String toTitleCase(String text) {
    if (text.isEmpty) return text;
    
    return text.split(' ').map((word) {
      if (word.isEmpty) return word;
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }

  /// Remove espaços extras e normaliza quebras de linha
  static String normalizeWhitespace(String text) {
    return text
        .replaceAll(RegExp(r'\s+'), ' ')
        .replaceAll(RegExp(r'\n\s*\n'), '\n\n')
        .trim();
  }

  // ========== FORMATAÇÃO ESPECÍFICA DE DEFENSIVOS ==========

  /// Formata ingrediente ativo para exibição
  static String formatIngredienteAtivo(String ingrediente) {
    if (ingrediente.isEmpty) return 'Não informado';
    
    String formatted = ingrediente
        .replaceAll(RegExp(r'[^\w\s+\-%(),.]+'), '')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
    
    if (formatted.isNotEmpty) {
      formatted = formatted[0].toUpperCase() + 
                 (formatted.length > 1 ? formatted.substring(1) : '');
    }
    
    return formatted;
  }

  /// Formata nome comercial para exibição
  static String formatNomeComercial(String nome) {
    if (nome.isEmpty) return 'Nome não informado';
    
    return nome
        .split(' ')
        .map((word) {
          if (word.isEmpty) return word;
          if (word.length == 1) return word.toUpperCase();
          return word[0].toUpperCase() + word.substring(1).toLowerCase();
        })
        .join(' ');
  }

  /// Formata classe toxicológica
  static String formatClasseToxicologica(dynamic classe) {
    if (classe == null) return 'Não classificado';
    
    final classeStr = classe.toString().toLowerCase();
    
    final Map<String, String> classeMap = {
      '1': 'Classe I - Extremamente Tóxico',
      '2': 'Classe II - Altamente Tóxico',  
      '3': 'Classe III - Medianamente Tóxico',
      '4': 'Classe IV - Pouco Tóxico',
      'i': 'Classe I - Extremamente Tóxico',
      'ii': 'Classe II - Altamente Tóxico',
      'iii': 'Classe III - Medianamente Tóxico',
      'iv': 'Classe IV - Pouco Tóxico',
    };
    
    return classeMap[classeStr] ?? 'Classe não identificada';
  }

  /// Formata modo de ação
  static String formatModoAcao(String modo) {
    if (modo.isEmpty) return 'Modo de ação não informado';
    
    return modo
        .replaceAll(RegExp(r'[,;]\s*'), '\n• ')
        .replaceAll(RegExp(r'^\s*'), '• ')
        .trim();
  }

  /// Formata grupo químico
  static String formatGrupoQuimico(String grupo) {
    if (grupo.isEmpty) return 'Grupo químico não informado';
    
    final preposicoes = {'de', 'da', 'do', 'das', 'dos', 'e', 'ou'};
    
    return grupo.split(' ').map((word) {
      if (word.isEmpty) return word;
      if (preposicoes.contains(word.toLowerCase())) {
        return word.toLowerCase();
      }
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }

  /// Formata dosagem com unidade
  static String formatDosagem(dynamic dosagem, {String? unidade}) {
    if (dosagem == null) return 'Dosagem não informada';
    
    final dosStr = dosagem.toString();
    if (dosStr.isEmpty || dosStr == '0') return 'Dosagem não informada';
    
    final unidadeStr = unidade ?? '';
    return unidadeStr.isEmpty ? dosStr : '$dosStr $unidadeStr';
  }

  /// Formata período de carência
  static String formatPeriodoCarencia(dynamic periodo) {
    if (periodo == null) return 'Não informado';
    
    final periodoStr = periodo.toString();
    if (periodoStr.isEmpty || periodoStr == '0') return 'Não há';
    
    final dias = int.tryParse(periodoStr);
    if (dias != null) {
      if (dias == 1) return '1 dia';
      if (dias < 30) return '$dias dias';
      if (dias == 30) return '1 mês';
      
      final meses = (dias / 30).round();
      return '$meses ${meses == 1 ? 'mês' : 'meses'}';
    }
    
    return periodoStr;
  }

  /// Formata intervalo de aplicação
  static String formatIntervaloAplicacao(dynamic intervalo) {
    if (intervalo == null) return 'Não informado';
    
    final intervaloStr = intervalo.toString();
    if (intervaloStr.isEmpty || intervaloStr == '0') return 'Não especificado';
    
    final dias = int.tryParse(intervaloStr);
    if (dias != null) {
      if (dias == 1) return 'Diário';
      if (dias == 7) return 'Semanal';
      if (dias == 14) return 'Quinzenal';
      if (dias == 30) return 'Mensal';
      return '$dias dias';
    }
    
    return intervaloStr;
  }

  /// Formata lista de culturas
  static String formatCulturas(List<dynamic>? culturas) {
    if (culturas == null || culturas.isEmpty) {
      return 'Culturas não informadas';
    }
    
    final culturasFormatadas = culturas
        .map((cultura) => cultura.toString().trim())
        .where((cultura) => cultura.isNotEmpty)
        .map((cultura) => formatNomeComercial(cultura))
        .toList();
    
    if (culturasFormatadas.isEmpty) return 'Culturas não informadas';
    
    if (culturasFormatadas.length == 1) return culturasFormatadas.first;
    if (culturasFormatadas.length == 2) {
      return '${culturasFormatadas[0]} e ${culturasFormatadas[1]}';
    }
    
    final ultimaCultura = culturasFormatadas.removeLast();
    return '${culturasFormatadas.join(', ')} e $ultimaCultura';
  }

  /// Formata número de registro
  static String formatNumeroRegistro(dynamic registro) {
    if (registro == null) return 'Registro não informado';
    
    final regStr = registro.toString().trim();
    if (regStr.isEmpty) return 'Registro não informado';
    
    if (RegExp(r'^\d+$').hasMatch(regStr) && regStr.length >= 8) {
      return '${regStr.substring(0, 4)}.${regStr.substring(4)}';
    }
    
    return regStr;
  }
}
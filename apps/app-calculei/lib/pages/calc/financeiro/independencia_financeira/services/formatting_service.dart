// Flutter imports:
import 'package:flutter/services.dart';

// Package imports:
import 'package:intl/intl.dart';

/// Serviço unificado para todas as formatações do módulo de independência financeira
class FormattingService {
  static final FormattingService _instance = FormattingService._internal();
  factory FormattingService() => _instance;
  FormattingService._internal();

  // Formatadores monetários
  final _brCurrencyFormatter = NumberFormat.currency(
    locale: 'pt_BR',
    symbol: 'R\$ ',
    decimalDigits: 2,
  );

  final _brNumberFormatter = NumberFormat.decimalPattern('pt_BR');
  // Cache para otimização
  final _cache = <String, String>{};
  static const int _maxCacheSize = 200;

  /// Formata valor monetário para exibição
  String formatarMoeda(double valor) {
    if (valor.isNaN || valor.isInfinite) return 'R\$ 0,00';
    
    final key = 'moeda_$valor';
    if (_cache.containsKey(key)) {
      return _cache[key]!;
    }

    final result = _brCurrencyFormatter.format(valor);
    _updateCache(key, result);
    return result;
  }

  /// Formata valor monetário compacto (1M, 1K, etc.)
  String formatarMoedaCompacta(double valor) {
    if (valor.isNaN || valor.isInfinite) return 'R\$ 0';
    
    final key = 'moeda_compacta_$valor';
    if (_cache.containsKey(key)) {
      return _cache[key]!;
    }

    String result;
    if (valor >= 1000000000) {
      result = 'R\$ ${(valor / 1000000000).toStringAsFixed(2)}B';
    } else if (valor >= 1000000) {
      result = 'R\$ ${(valor / 1000000).toStringAsFixed(2)}M';
    } else if (valor >= 1000) {
      result = 'R\$ ${(valor / 1000).toStringAsFixed(2)}K';
    } else {
      result = formatarMoeda(valor);
    }

    _updateCache(key, result);
    return result;
  }

  /// Formata número para exibição
  String formatarNumero(double valor) {
    if (valor.isNaN || valor.isInfinite) return '0';
    
    final key = 'numero_$valor';
    if (_cache.containsKey(key)) {
      return _cache[key]!;
    }

    final result = _brNumberFormatter.format(valor);
    _updateCache(key, result);
    return result;
  }

  /// Formata percentual para exibição
  String formatarPercentual(double valor) {
    if (valor.isNaN || valor.isInfinite) return '0%';
    
    final key = 'percentual_$valor';
    if (_cache.containsKey(key)) {
      return _cache[key]!;
    }

    final result = '${valor.toStringAsFixed(2)}%';
    _updateCache(key, result);
    return result;
  }

  /// Formata anos para exibição
  String formatarAnos(double anos) {
    if (anos.isNaN || anos.isInfinite) return 'Indefinido';
    
    final key = 'anos_$anos';
    if (_cache.containsKey(key)) {
      return _cache[key]!;
    }

    String result;
    if (anos == 0) {
      result = 'Já atingida';
    } else if (anos < 1) {
      final meses = (anos * 12).round();
      result = '$meses ${meses == 1 ? "mês" : "meses"}';
    } else {
      final anosInteiros = anos.floor();
      final meses = ((anos - anosInteiros) * 12).round();
      
      if (meses == 0) {
        result = '$anosInteiros ${anosInteiros == 1 ? "ano" : "anos"}';
      } else {
        result = '$anosInteiros ${anosInteiros == 1 ? "ano" : "anos"} e $meses ${meses == 1 ? "mês" : "meses"}';
      }
    }

    _updateCache(key, result);
    return result;
  }

  /// Formata valor para entrada (usado nos inputs)
  String formatarParaEntrada(double valor) {
    if (valor.isNaN || valor.isInfinite) return '';
    return valor.toStringAsFixed(2).replaceAll('.', ',');
  }

  /// Parser para valores monetários
  double parseMoeda(String texto) {
    if (texto.isEmpty) return 0.0;
    
    try {
      String limpo = texto
          .replaceAll('R\$', '')
          .replaceAll(' ', '')
          .replaceAll('.', '')
          .replaceAll(',', '.');
      
      return double.parse(limpo);
    } catch (e) {
      return 0.0;
    }
  }

  /// Parser para percentuais
  double parsePercentual(String texto) {
    if (texto.isEmpty) return 0.0;
    
    try {
      String limpo = texto
          .replaceAll('%', '')
          .replaceAll(' ', '')
          .replaceAll(',', '.');
      
      return double.parse(limpo);
    } catch (e) {
      return 0.0;
    }
  }

  /// Valida se string é um número válido
  bool isNumeroValido(String texto) {
    if (texto.isEmpty) return false;
    
    try {
      String limpo = texto.replaceAll(',', '.');
      double.parse(limpo);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Valida se string é uma moeda válida
  bool isMoedaValida(String texto) {
    if (texto.isEmpty) return false;
    return parseMoeda(texto) >= 0;
  }

  /// Sanitiza entrada removendo caracteres inválidos
  String sanitizarEntrada(String texto) {
    return texto.replaceAll(RegExp(r'[^\d.,]'), '');
  }

  /// Limita o número de decimais
  String limitarDecimais(String texto, int decimais) {
    if (!texto.contains(',')) return texto;
    
    final partes = texto.split(',');
    if (partes.length != 2) return texto;
    
    final parteDecimal = partes[1].length > decimais 
        ? partes[1].substring(0, decimais)
        : partes[1];
    
    return '${partes[0]},$parteDecimal';
  }

  /// Formata tempo em segundos para exibição
  String formatarTempo(Duration duracao) {
    final key = 'tempo_${duracao.inMilliseconds}';
    if (_cache.containsKey(key)) {
      return _cache[key]!;
    }

    String result;
    if (duracao.inMinutes > 0) {
      result = '${duracao.inMinutes}min ${duracao.inSeconds % 60}s';
    } else {
      result = '${duracao.inSeconds}s';
    }

    _updateCache(key, result);
    return result;
  }

  /// Atualiza cache mantendo limite
  void _updateCache(String key, String value) {
    if (_cache.length >= _maxCacheSize) {
      _cache.remove(_cache.keys.first);
    }
    _cache[key] = value;
  }

  /// Limpa cache
  void clearCache() {
    _cache.clear();
  }

  /// Obtém estatísticas do cache
  Map<String, int> getCacheStats() {
    return {
      'size': _cache.length,
      'maxSize': _maxCacheSize,
    };
  }
}

/// Input formatter otimizado para valores monetários
class OptimizedMoneyInputFormatter extends TextInputFormatter {
  final FormattingService _formatter = FormattingService();
  
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Limpa entrada mantendo apenas números
    String newText = newValue.text.replaceAll(RegExp(r'[^\d]'), '');

    if (newText.isEmpty) {
      return newValue.copyWith(text: '');
    }

    // Normaliza para centavos
    if (newText.length == 1) {
      newText = '0000$newText';
    } else if (newText.length == 2) {
      newText = '000$newText';
    } else if (newText.length == 3) {
      newText = '00$newText';
    } else if (newText.length == 4) {
      newText = '0$newText';
    }

    // Separa reais e centavos
    String reais = newText.substring(0, newText.length - 2);
    final centavos = newText.substring(newText.length - 2);

    if (reais.isEmpty) reais = '0';
    reais = reais.replaceFirst(RegExp(r'^0+'), '');
    if (reais.isEmpty) reais = '0';

    // Formata com separadores
    final chars = reais.split('').reversed.toList();
    final formatted = StringBuffer();
    for (var i = 0; i < chars.length; i++) {
      if (i > 0 && i % 3 == 0) {
        formatted.write('.');
      }
      formatted.write(chars[i]);
    }
    reais = formatted.toString().split('').reversed.join();

    final result = 'R\$ $reais,$centavos';

    return TextEditingValue(
      text: result,
      selection: TextSelection.collapsed(offset: result.length),
    );
  }

  double getUnmaskedDouble(String text) {
    return _formatter.parseMoeda(text);
  }
}

/// Input formatter para percentuais
class PercentInputFormatter extends TextInputFormatter {
  final FormattingService _formatter = FormattingService();
  
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    String newText = _formatter.sanitizarEntrada(newValue.text);
    newText = _formatter.limitarDecimais(newText, 2);
    
    return newValue.copyWith(
      text: newText,
      selection: TextSelection.collapsed(offset: newText.length),
    );
  }
}

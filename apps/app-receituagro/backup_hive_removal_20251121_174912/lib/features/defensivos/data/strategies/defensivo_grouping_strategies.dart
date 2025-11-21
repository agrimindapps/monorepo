import '../../domain/entities/defensivo_entity.dart';
import 'i_defensivo_grouping_strategy.dart';

/// Agrupa defensivos por fabricante
class ByFabricanteGrouping implements IDefensivoGroupingStrategy {
  @override
  String get name => 'Fabricante';

  @override
  String get id => 'fabricante';

  @override
  String get description => 'Agrupa defensivos por fabricante';

  @override
  Map<String, List<DefensivoEntity>> group(List<DefensivoEntity> defensivos) {
    final Map<String, List<DefensivoEntity>> grupos = {};
    
    for (final defensivo in defensivos) {
      final chave = defensivo.displayFabricante;
      grupos.putIfAbsent(chave, () => <DefensivoEntity>[]);
      grupos[chave]!.add(defensivo);
    }
    
    return grupos;
  }
}

/// Agrupa defensivos por ingrediente ativo
class ByIngredienteAtivoGrouping implements IDefensivoGroupingStrategy {
  @override
  String get name => 'Ingrediente Ativo';

  @override
  String get id => 'ingrediente_ativo';

  @override
  String get description => 'Agrupa defensivos por ingrediente ativo';

  @override
  Map<String, List<DefensivoEntity>> group(List<DefensivoEntity> defensivos) {
    final Map<String, List<DefensivoEntity>> grupos = {};
    
    for (final defensivo in defensivos) {
      final ingredientes = _extrairIngredientes(defensivo);
      
      for (final ingrediente in ingredientes) {
        grupos.putIfAbsent(ingrediente, () => <DefensivoEntity>[]);
        grupos[ingrediente]!.add(defensivo);
      }
    }
    
    return grupos;
  }

  /// Extrai ingredientes ativos separados por "+"
  List<String> _extrairIngredientes(DefensivoEntity defensivo) {
    final ingredientesText = defensivo.displayIngredient;

    if (ingredientesText.isEmpty || ingredientesText == 'Sem ingrediente ativo') {
      return ['Não informado'];
    }

    final ingredientes = ingredientesText
        .split('+')
        .map((ingrediente) => _normalize(ingrediente))
        .where((ingrediente) => ingrediente.isNotEmpty && ingrediente.length >= 3)
        .toList();

    return ingredientes.isEmpty ? ['Não informado'] : ingredientes;
  }

  String _normalize(String text) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return trimmed;

    return trimmed
        .split(' ')
        .map((word) {
          if (word.isEmpty) return word;
          if (['de', 'da', 'do', 'e', 'a', 'o'].contains(word.toLowerCase())) {
            return word.toLowerCase();
          }
          return word[0].toUpperCase() + word.substring(1).toLowerCase();
        })
        .join(' ');
  }
}

/// Agrupa defensivos por modo de ação
class ByModoAcaoGrouping implements IDefensivoGroupingStrategy {
  @override
  String get name => 'Modo de Ação';

  @override
  String get id => 'modo_acao';

  @override
  String get description => 'Agrupa defensivos por modo de ação';

  @override
  Map<String, List<DefensivoEntity>> group(List<DefensivoEntity> defensivos) {
    final Map<String, List<DefensivoEntity>> grupos = {};
    
    for (final defensivo in defensivos) {
      final modosAcao = _extrairModosAcao(defensivo);
      
      for (final modo in modosAcao) {
        grupos.putIfAbsent(modo, () => <DefensivoEntity>[]);
        grupos[modo]!.add(defensivo);
      }
    }
    
    return grupos;
  }

  List<String> _extrairModosAcao(DefensivoEntity defensivo) {
    final modoAcaoText = defensivo.displayModoAcao;

    if (modoAcaoText.isEmpty || modoAcaoText == 'Não especificado') {
      return ['Não especificado'];
    }

    final modosAcao = modoAcaoText
        .split(',')
        .map((modo) => _normalize(modo))
        .where((modo) => modo.isNotEmpty && modo.length >= 3)
        .toList();

    return modosAcao.isEmpty ? ['Não especificado'] : modosAcao;
  }

  String _normalize(String text) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return trimmed;

    return trimmed
        .split(' ')
        .map((word) {
          if (word.isEmpty) return word;
          if (['de', 'da', 'do', 'e', 'a', 'o'].contains(word.toLowerCase())) {
            return word.toLowerCase();
          }
          return word[0].toUpperCase() + word.substring(1).toLowerCase();
        })
        .join(' ');
  }
}

/// Agrupa defensivos por classe agronômica
class ByClasseAgronomicaGrouping implements IDefensivoGroupingStrategy {
  @override
  String get name => 'Classe Agronômica';

  @override
  String get id => 'classe_agronomica';

  @override
  String get description => 'Agrupa defensivos por classe agronômica';

  @override
  Map<String, List<DefensivoEntity>> group(List<DefensivoEntity> defensivos) {
    final Map<String, List<DefensivoEntity>> grupos = {};
    
    for (final defensivo in defensivos) {
      final classes = _extrairClasses(defensivo);
      
      for (final classe in classes) {
        grupos.putIfAbsent(classe, () => <DefensivoEntity>[]);
        grupos[classe]!.add(defensivo);
      }
    }
    
    return grupos;
  }

  List<String> _extrairClasses(DefensivoEntity defensivo) {
    final classeText = defensivo.displayClass;

    if (classeText.isEmpty || classeText == 'Não especificado') {
      return ['Não especificado'];
    }

    final classes = classeText
        .split(',')
        .map((classe) => _normalize(classe))
        .where((classe) => classe.isNotEmpty && classe.length >= 3)
        .toList();

    return classes.isEmpty ? ['Não especificado'] : classes;
  }

  String _normalize(String text) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return trimmed;

    return trimmed
        .split(' ')
        .map((word) {
          if (word.isEmpty) return word;
          if (['de', 'da', 'do', 'e', 'a', 'o'].contains(word.toLowerCase())) {
            return word.toLowerCase();
          }
          return word[0].toUpperCase() + word.substring(1).toLowerCase();
        })
        .join(' ');
  }
}

/// Agrupa defensivos por toxicidade
class ByToxicidadeGrouping implements IDefensivoGroupingStrategy {
  @override
  String get name => 'Toxicidade';

  @override
  String get id => 'toxicidade';

  @override
  String get description => 'Agrupa defensivos por toxicidade';

  @override
  Map<String, List<DefensivoEntity>> group(List<DefensivoEntity> defensivos) {
    final Map<String, List<DefensivoEntity>> grupos = {};
    
    for (final defensivo in defensivos) {
      final chave = defensivo.displayToxico;
      grupos.putIfAbsent(chave, () => <DefensivoEntity>[]);
      grupos[chave]!.add(defensivo);
    }
    
    return grupos;
  }
}

/// Agrupa defensivos por categoria
class ByCategoriaGrouping implements IDefensivoGroupingStrategy {
  @override
  String get name => 'Categoria';

  @override
  String get id => 'categoria';

  @override
  String get description => 'Agrupa defensivos por categoria';

  @override
  Map<String, List<DefensivoEntity>> group(List<DefensivoEntity> defensivos) {
    final Map<String, List<DefensivoEntity>> grupos = {};
    
    for (final defensivo in defensivos) {
      final chave = defensivo.displayCategoria;
      grupos.putIfAbsent(chave, () => <DefensivoEntity>[]);
      grupos[chave]!.add(defensivo);
    }
    
    return grupos;
  }
}

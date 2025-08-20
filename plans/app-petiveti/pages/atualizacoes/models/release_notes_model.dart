class ReleaseNote {
  final String texto;
  final TipoNota tipo;
  final String? categoria;
  final bool isDestaque;

  const ReleaseNote({
    required this.texto,
    this.tipo = TipoNota.feature,
    this.categoria,
    this.isDestaque = false,
  });

  String get icone {
    switch (tipo) {
      case TipoNota.feature:
        return '✨';
      case TipoNota.bugfix:
        return '🐛';
      case TipoNota.improvement:
        return '⚡';
      case TipoNota.breaking:
        return '💥';
      case TipoNota.security:
        return '🔒';
      case TipoNota.deprecated:
        return '⚠️';
      case TipoNota.removed:
        return '🗑️';
      case TipoNota.docs:
        return '📚';
      case TipoNota.style:
        return '🎨';
      case TipoNota.refactor:
        return '♻️';
      case TipoNota.performance:
        return '⚡';
      case TipoNota.test:
        return '✅';
    }
  }

  String get textoFormatado => '$icone $texto';

  static ReleaseNote fromString(String texto) {
    // Tentar detectar o tipo baseado no conteúdo
    final textoLower = texto.toLowerCase();
    
    TipoNota tipo = TipoNota.feature;
    
    if (textoLower.contains('corrig') || textoLower.contains('fix') || textoLower.contains('bug')) {
      tipo = TipoNota.bugfix;
    } else if (textoLower.contains('melhor') || textoLower.contains('otimiz') || textoLower.contains('performance')) {
      tipo = TipoNota.improvement;
    } else if (textoLower.contains('seguranç') || textoLower.contains('security')) {
      tipo = TipoNota.security;
    } else if (textoLower.contains('deprec') || textoLower.contains('obsoleto')) {
      tipo = TipoNota.deprecated;
    } else if (textoLower.contains('remo') || textoLower.contains('exclu')) {
      tipo = TipoNota.removed;
    } else if (textoLower.contains('document') || textoLower.contains('doc')) {
      tipo = TipoNota.docs;
    } else if (textoLower.contains('test') || textoLower.contains('teste')) {
      tipo = TipoNota.test;
    } else if (textoLower.contains('refator') || textoLower.contains('refactor')) {
      tipo = TipoNota.refactor;
    } else if (textoLower.contains('visual') || textoLower.contains('design') || textoLower.contains('interface')) {
      tipo = TipoNota.style;
    }

    return ReleaseNote(
      texto: texto,
      tipo: tipo,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'texto': texto,
      'tipo': tipo.name,
      'categoria': categoria,
      'isDestaque': isDestaque,
    };
  }

  static ReleaseNote fromJson(Map<String, dynamic> json) {
    return ReleaseNote(
      texto: json['texto'] ?? '',
      tipo: TipoNota.values.firstWhere(
        (t) => t.name == json['tipo'],
        orElse: () => TipoNota.feature,
      ),
      categoria: json['categoria'],
      isDestaque: json['isDestaque'] ?? false,
    );
  }
}

enum TipoNota {
  feature,      // Nova funcionalidade
  bugfix,       // Correção de bug
  improvement,  // Melhoria
  breaking,     // Mudança que quebra compatibilidade
  security,     // Relacionado à segurança
  deprecated,   // Funcionalidade depreciada
  removed,      // Funcionalidade removida
  docs,         // Documentação
  style,        // Mudanças visuais/UI
  refactor,     // Refatoração de código
  performance,  // Melhoria de performance
  test,         // Testes
}

class ReleaseNotesHelper {
  static List<ReleaseNote> parseFromStringList(List<String> notasTexto) {
    return notasTexto.map((texto) => ReleaseNote.fromString(texto)).toList();
  }

  static Map<TipoNota, List<ReleaseNote>> groupByType(List<ReleaseNote> notas) {
    final Map<TipoNota, List<ReleaseNote>> grouped = {};
    
    for (final nota in notas) {
      grouped.putIfAbsent(nota.tipo, () => []).add(nota);
    }
    
    return grouped;
  }

  static List<ReleaseNote> sortByImportance(List<ReleaseNote> notas) {
    final sorted = List<ReleaseNote>.from(notas);
    
    // Ordem de importância dos tipos
    final importanceOrder = {
      TipoNota.breaking: 0,
      TipoNota.security: 1,
      TipoNota.feature: 2,
      TipoNota.improvement: 3,
      TipoNota.bugfix: 4,
      TipoNota.performance: 5,
      TipoNota.deprecated: 6,
      TipoNota.removed: 7,
      TipoNota.refactor: 8,
      TipoNota.style: 9,
      TipoNota.docs: 10,
      TipoNota.test: 11,
    };
    
    sorted.sort((a, b) {
      // Primeiro por destaque
      if (a.isDestaque != b.isDestaque) {
        return a.isDestaque ? -1 : 1;
      }
      
      // Depois por importância do tipo
      final importanceA = importanceOrder[a.tipo] ?? 99;
      final importanceB = importanceOrder[b.tipo] ?? 99;
      
      return importanceA.compareTo(importanceB);
    });
    
    return sorted;
  }

  static String getTypeDisplayName(TipoNota tipo) {
    switch (tipo) {
      case TipoNota.feature:
        return 'Nova Funcionalidade';
      case TipoNota.bugfix:
        return 'Correção de Bug';
      case TipoNota.improvement:
        return 'Melhoria';
      case TipoNota.breaking:
        return 'Mudança Importante';
      case TipoNota.security:
        return 'Segurança';
      case TipoNota.deprecated:
        return 'Depreciado';
      case TipoNota.removed:
        return 'Removido';
      case TipoNota.docs:
        return 'Documentação';
      case TipoNota.style:
        return 'Interface';
      case TipoNota.refactor:
        return 'Refatoração';
      case TipoNota.performance:
        return 'Performance';
      case TipoNota.test:
        return 'Testes';
    }
  }

  static List<String> getHighlightKeywords() {
    return [
      'novo', 'nova', 'adicionado', 'implementado',
      'corrigido', 'resolvido', 'ajustado',
      'melhorado', 'otimizado', 'aprimorado',
      'atualizado', 'modificado', 'alterado',
    ];
  }

  static bool containsHighlightKeyword(String texto) {
    final textoLower = texto.toLowerCase();
    return getHighlightKeywords().any((keyword) => textoLower.contains(keyword));
  }
}
class Atualizacao {
  final String versao;
  final List<String> notas;
  final DateTime? dataLancamento;
  final bool isImportante;
  final String? categoria;

  const Atualizacao({
    required this.versao,
    required this.notas,
    this.dataLancamento,
    this.isImportante = false,
    this.categoria,
  });

  bool get hasNotas => notas.isNotEmpty;
  int get totalNotas => notas.length;

  String get versaoFormatada {
    if (versao.startsWith('v') || versao.startsWith('V')) {
      return versao;
    }
    return 'v$versao';
  }

  String get resumo {
    if (notas.isEmpty) return 'Sem notas de versão';
    if (notas.length == 1) return notas.first;
    return '${notas.first}... (+${notas.length - 1} itens)';
  }

  String get notasCompletas => notas.join('\n');

  Map<String, dynamic> toJson() {
    return {
      'versao': versao,
      'notas': notas,
      'dataLancamento': dataLancamento?.toIso8601String(),
      'isImportante': isImportante,
      'categoria': categoria,
    };
  }

  static Atualizacao fromJson(Map<String, dynamic> json) {
    return Atualizacao(
      versao: json['versao'] ?? '',
      notas: List<String>.from(json['notas'] ?? []),
      dataLancamento: json['dataLancamento'] != null
          ? DateTime.parse(json['dataLancamento'])
          : null,
      isImportante: json['isImportante'] ?? false,
      categoria: json['categoria'],
    );
  }

  static Atualizacao fromGlobalEnvironment(Map<String, dynamic> data) {
    return Atualizacao(
      versao: data['versao'] ?? '',
      notas: List<String>.from(data['notas'] ?? []),
      isImportante: data['isImportante'] ?? false,
      categoria: data['categoria'],
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Atualizacao &&
          runtimeType == other.runtimeType &&
          versao == other.versao;

  @override
  int get hashCode => versao.hashCode;

  @override
  String toString() {
    return 'Atualizacao{versao: $versao, notas: ${notas.length} itens}';
  }
}

class AtualizacaoRepository {
  static List<Atualizacao> parseFromGlobalEnvironment(
      List<Map<String, dynamic>> atualizacoesData) {
    return atualizacoesData
        .map((data) => Atualizacao.fromGlobalEnvironment(data))
        .toList();
  }

  static List<Atualizacao> sortByVersion(List<Atualizacao> atualizacoes) {
    final sorted = List<Atualizacao>.from(atualizacoes);
    sorted.sort((a, b) => _compareVersions(b.versao, a.versao)); // Mais recente primeiro
    return sorted;
  }

  static List<Atualizacao> filterByImportance(
      List<Atualizacao> atualizacoes, bool onlyImportant) {
    if (!onlyImportant) return atualizacoes;
    return atualizacoes.where((a) => a.isImportante).toList();
  }

  static List<Atualizacao> filterByCategory(
      List<Atualizacao> atualizacoes, String? categoria) {
    if (categoria == null || categoria.isEmpty) return atualizacoes;
    return atualizacoes.where((a) => a.categoria == categoria).toList();
  }

  static int _compareVersions(String version1, String version2) {
    // Remove prefixos como 'v' ou 'V'
    final v1 = version1.replaceAll(RegExp(r'^[vV]'), '');
    final v2 = version2.replaceAll(RegExp(r'^[vV]'), '');

    final parts1 = v1.split('.').map((e) => int.tryParse(e) ?? 0).toList();
    final parts2 = v2.split('.').map((e) => int.tryParse(e) ?? 0).toList();

    final maxLength = parts1.length > parts2.length ? parts1.length : parts2.length;

    for (int i = 0; i < maxLength; i++) {
      final p1 = i < parts1.length ? parts1[i] : 0;
      final p2 = i < parts2.length ? parts2[i] : 0;

      if (p1 != p2) {
        return p1.compareTo(p2);
      }
    }

    return 0;
  }

  static Map<String, int> getStatistics(List<Atualizacao> atualizacoes) {
    final totalNotas = atualizacoes.fold<int>(0, (sum, a) => sum + a.totalNotas);
    final importantes = atualizacoes.where((a) => a.isImportante).length;
    final categorias = atualizacoes
        .where((a) => a.categoria != null)
        .map((a) => a.categoria!)
        .toSet()
        .length;

    return {
      'totalVersions': atualizacoes.length,
      'totalNotas': totalNotas,
      'importantes': importantes,
      'categorias': categorias,
    };
  }

  static Atualizacao? getLatestVersion(List<Atualizacao> atualizacoes) {
    if (atualizacoes.isEmpty) return null;
    final sorted = sortByVersion(atualizacoes);
    return sorted.first;
  }

  static List<String> getAllCategories(List<Atualizacao> atualizacoes) {
    return atualizacoes
        .where((a) => a.categoria != null && a.categoria!.isNotEmpty)
        .map((a) => a.categoria!)
        .toSet()
        .toList()
      ..sort();
  }
}
// Project imports:
import '../models/atualizacao_model.dart';

// Simulação temporária - em produção seria importado do intermediate.dart
class _MockGlobalEnvironment {
  static final List<Map<String, dynamic>> _mockData = [
    {
      'versao': '2024.07.14v1',
      'notas': [
        'Implementação do padrão MVC nas páginas principais',
        'Refatoração do dashboard com widgets modulares',
        'Melhoria na organização do código',
        'Correção de bugs menores'
      ],
    },
    {
      'versao': '2024.07.13v3',
      'notas': [
        'Adição de novas funcionalidades de relatórios',
        'Otimização de performance',
        'Correções de interface'
      ],
    },
  ];
  
  List<Map<String, dynamic>> get atualizacoesText => _mockData;
}

class AtualizacoesService {
  Future<List<Atualizacao>> loadAtualizacoes() async {
    try {
      // Simular carregamento assíncrono
      await Future.delayed(const Duration(milliseconds: 300));
      
      final atualizacoesData = _MockGlobalEnvironment().atualizacoesText;
      
      if (atualizacoesData.isEmpty) {
        return [];
      }
      
      return AtualizacaoRepository.parseFromGlobalEnvironment(atualizacoesData);
    } catch (e) {
      throw Exception('Erro ao carregar atualizações: $e');
    }
  }

  Future<bool> hasAtualizacoes() async {
    try {
      final atualizacoes = await loadAtualizacoes();
      return atualizacoes.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  Future<Atualizacao?> getLatestVersion() async {
    try {
      final atualizacoes = await loadAtualizacoes();
      return AtualizacaoRepository.getLatestVersion(atualizacoes);
    } catch (e) {
      return null;
    }
  }

  Future<List<Atualizacao>> getAtualizacoesSorted() async {
    final atualizacoes = await loadAtualizacoes();
    return AtualizacaoRepository.sortByVersion(atualizacoes);
  }

  Future<List<Atualizacao>> getAtualizacoesImportantes() async {
    final atualizacoes = await loadAtualizacoes();
    return AtualizacaoRepository.filterByImportance(atualizacoes, true);
  }

  Future<List<String>> getAvailableCategories() async {
    final atualizacoes = await loadAtualizacoes();
    return AtualizacaoRepository.getAllCategories(atualizacoes);
  }

  Future<Map<String, int>> getStatistics() async {
    final atualizacoes = await loadAtualizacoes();
    return AtualizacaoRepository.getStatistics(atualizacoes);
  }

  List<Atualizacao> filterAtualizacoes({
    required List<Atualizacao> atualizacoes,
    String? searchTerm,
    String? categoria,
    bool? onlyImportant,
  }) {
    var filtered = List<Atualizacao>.from(atualizacoes);

    // Filtrar por termo de busca
    if (searchTerm != null && searchTerm.isNotEmpty) {
      final term = searchTerm.toLowerCase();
      filtered = filtered.where((atualizacao) {
        return atualizacao.versao.toLowerCase().contains(term) ||
               atualizacao.notasCompletas.toLowerCase().contains(term) ||
               (atualizacao.categoria?.toLowerCase().contains(term) ?? false);
      }).toList();
    }

    // Filtrar por categoria
    if (categoria != null && categoria.isNotEmpty) {
      filtered = AtualizacaoRepository.filterByCategory(filtered, categoria);
    }

    // Filtrar por importância
    if (onlyImportant == true) {
      filtered = AtualizacaoRepository.filterByImportance(filtered, true);
    }

    return filtered;
  }

  String formatVersionForDisplay(String version) {
    if (version.isEmpty) return 'Versão desconhecida';
    
    // Adicionar 'v' se não tiver
    if (!version.startsWith('v') && !version.startsWith('V')) {
      return 'v$version';
    }
    
    return version;
  }

  bool isNewerVersion(String version1, String version2) {
    // Remove prefixos
    final v1 = version1.replaceAll(RegExp(r'^[vV]'), '');
    final v2 = version2.replaceAll(RegExp(r'^[vV]'), '');

    final parts1 = v1.split('.').map((e) => int.tryParse(e) ?? 0).toList();
    final parts2 = v2.split('.').map((e) => int.tryParse(e) ?? 0).toList();

    final maxLength = parts1.length > parts2.length ? parts1.length : parts2.length;

    for (int i = 0; i < maxLength; i++) {
      final p1 = i < parts1.length ? parts1[i] : 0;
      final p2 = i < parts2.length ? parts2[i] : 0;

      if (p1 != p2) {
        return p1 > p2;
      }
    }

    return false;
  }

  String getVersionSummary(List<Atualizacao> atualizacoes) {
    if (atualizacoes.isEmpty) {
      return 'Nenhuma atualização disponível';
    }

    final total = atualizacoes.length;
    final importantes = atualizacoes.where((a) => a.isImportante).length;
    final latest = AtualizacaoRepository.getLatestVersion(atualizacoes);

    final buffer = StringBuffer();
    buffer.write('$total ${total == 1 ? 'versão' : 'versões'}');
    
    if (importantes > 0) {
      buffer.write(', $importantes ${importantes == 1 ? 'importante' : 'importantes'}');
    }
    
    if (latest != null) {
      buffer.write('\nÚltima versão: ${latest.versaoFormatada}');
    }

    return buffer.toString();
  }

  Future<void> refreshData() async {
    // Em uma implementação real, aqui poderia buscar dados de uma API
    // Por enquanto, apenas recarrega do GlobalEnvironment
    await Future.delayed(const Duration(milliseconds: 500));
  }

  bool validateAtualizacao(Atualizacao atualizacao) {
    return atualizacao.versao.isNotEmpty && atualizacao.notas.isNotEmpty;
  }

  List<Atualizacao> removeDuplicates(List<Atualizacao> atualizacoes) {
    final seen = <String>{};
    return atualizacoes.where((atualizacao) => seen.add(atualizacao.versao)).toList();
  }
}

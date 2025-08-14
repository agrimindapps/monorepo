import '../models/atualizacao_model.dart';

/// Interface for loading update data following SOLID principles
abstract class IAtualizacaoDataService {
  /// Load all available updates from data source
  Future<List<AtualizacaoModel>> loadAtualizacoes();
  
  /// Refresh/reload update data
  Future<void> refresh();
  
  /// Check if service has cached data
  bool get hasCachedData;
}

/// Mock implementation for development and testing
class MockAtualizacaoDataService implements IAtualizacaoDataService {
  List<AtualizacaoModel>? _cachedData;
  
  @override
  bool get hasCachedData => _cachedData != null;

  @override
  Future<List<AtualizacaoModel>> loadAtualizacoes() async {
    // Simulate API call delay
    await Future.delayed(const Duration(milliseconds: 500));
    
    // Return cached data if available
    if (_cachedData != null) {
      return _cachedData!;
    }

    // Mock data - in real implementation this would come from GlobalEnvironment
    final mockData = _getMockUpdateData();
    
    // Convert raw data to models
    _cachedData = mockData
        .map((data) => AtualizacaoModel.fromMap(data))
        .toList();
    
    return _cachedData!;
  }

  @override
  Future<void> refresh() async {
    _cachedData = null;
    await loadAtualizacoes();
  }

  /// Mock update data - replace with GlobalEnvironment().atualizacoesText in real app
  List<Map<String, dynamic>> _getMockUpdateData() {
    return [
      {
        'versao': '2.1.0',
        'notas': [
          'Melhorias na interface de busca',
          'Correção de bugs na sincronização',
          'Otimizações de performance',
          'Nova funcionalidade de exportação',
        ],
      },
      {
        'versao': '2.0.5',
        'notas': [
          'Correção de crash no Android 12',
          'Melhorias na tela de configurações',
          'Atualização de dependências de segurança',
        ],
      },
      {
        'versao': '2.0.4',
        'notas': [
          'Correções de layout em tablets',
          'Melhor suporte para modo escuro',
          'Correção de memoria em listas grandes',
        ],
      },
      {
        'versao': '2.0.3',
        'notas': [
          'Correção de bugs menores',
          'Melhorias na estabilidade',
        ],
      },
    ];
  }
}

/// Real implementation using GlobalEnvironment (commented for reference)
/*
class GlobalEnvironmentAtualizacaoDataService implements IAtualizacaoDataService {
  List<AtualizacaoModel>? _cachedData;
  
  @override
  bool get hasCachedData => _cachedData != null;

  @override
  Future<List<AtualizacaoModel>> loadAtualizacoes() async {
    try {
      if (_cachedData != null) {
        return _cachedData!;
      }

      final atualizacoesData = GlobalEnvironment().atualizacoesText;
      _cachedData = atualizacoesData
          .map((item) => AtualizacaoModel.fromMap(item))
          .toList();
      
      return _cachedData!;
    } catch (e) {
      throw Exception('Failed to load updates: $e');
    }
  }

  @override
  Future<void> refresh() async {
    _cachedData = null;
    await loadAtualizacoes();
  }
}
*/
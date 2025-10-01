import 'package:core/core.dart';
import 'package:flutter/foundation.dart';

import '../../../../core/data/repositories/cultura_hive_repository.dart';
import '../../../../core/services/app_data_manager.dart';
import '../../domain/entities/praga_entity.dart';
import '../providers/pragas_provider.dart';

/// Provider para gerenciamento de estado da página Home de Pragas
/// 
/// Responsável por:
/// - Coordenação entre PragasProvider e dados de culturas
/// - Gerenciamento de estado de inicialização
/// - Controle de carrossel de sugestões
/// - Estados de loading e erro específicos da home
class HomePragasProvider extends ChangeNotifier {
  late final PragasProvider _pragasProvider;
  late final CulturaHiveRepository _culturaRepository;
  late final IAppDataManager _appDataManager;

  HomePragasProvider() {
    _initializeDependencies();
    _initialize();
  }

  void _initializeDependencies() {
    _pragasProvider = GetIt.instance<PragasProvider>();
    _culturaRepository = GetIt.instance<CulturaHiveRepository>();
    _appDataManager = GetIt.instance<IAppDataManager>();
  }

  // Estados de inicialização
  bool _isInitializing = true;
  bool _initializationFailed = false;
  String? _initializationError;
  bool _disposed = false;

  // Dados de culturas
  int _totalCulturas = 0;

  // Controle de carrossel
  int _currentCarouselIndex = 0;

  // Getters
  bool get isInitializing => _isInitializing;
  bool get initializationFailed => _initializationFailed;
  String? get initializationError => _initializationError;
  int get totalCulturas => _totalCulturas;
  int get currentCarouselIndex => _currentCarouselIndex;

  // Delegação para PragasProvider
  bool get isLoading => _pragasProvider.isLoading;
  String? get errorMessage => _pragasProvider.errorMessage;
  dynamic get stats => _pragasProvider.stats;
  List<PragaEntity> get suggestedPragas => _pragasProvider.suggestedPragas;
  List<PragaEntity> get recentPragas => _pragasProvider.recentPragas;

  /// Inicializa o provider e carrega dados necessários
  Future<void> _initialize() async {
    try {
      // Carrega dados de culturas
      await _loadCulturaData();
      
      // Inicializa pragas com retry logic
      await _initializePragasWithRetry();
      
      if (!_disposed) {
        _isInitializing = false;
        _initializationFailed = false;
        _initializationError = null;
      }
    } catch (e) {
      if (!_disposed) {
        _isInitializing = false;
        _initializationFailed = true;
        _initializationError = e.toString();
      }
    }
    
    if (!_disposed) {
      notifyListeners();
    }
  }

  /// Carrega dados de culturas do repositório
  Future<void> _loadCulturaData() async {
    try {
      final culturasResult = await _culturaRepository.getAll();
      culturasResult.fold(
        (failure) => _totalCulturas = 0,
        (culturas) => _totalCulturas = culturas.length,
      );
    } catch (e) {
      _totalCulturas = 0;
    }
  }

  /// Inicializa pragas com retry logic para aguardar dados estarem prontos
  Future<void> _initializePragasWithRetry([int attempts = 0]) async {
    const int maxAttempts = 10;
    const Duration delayBetweenAttempts = Duration(milliseconds: 500);
    
    if (_disposed) return;
    
    try {
      // Aguarda dados estarem prontos
      final isDataReady = await _appDataManager.isDataReady();
      
      if (_disposed) return;
      
      if (isDataReady) {
        await _pragasProvider.initialize();
        return;
      }
      
      // Verifica se atingiu o limite de tentativas
      if (attempts >= maxAttempts - 1) {
        // Fallback: inicializa mesmo sem dados prontos
        if (!_disposed) {
          await _pragasProvider.initialize();
        }
        return;
      }
      
      // Se dados não estão prontos, aguarda e tenta novamente
      await Future<void>.delayed(delayBetweenAttempts);
      if (!_disposed) {
        await _initializePragasWithRetry(attempts + 1);
      }
    } catch (e) {
      if (_disposed) return;
      
      // Se ainda há tentativas, tenta novamente
      if (attempts < maxAttempts - 1) {
        await Future<void>.delayed(delayBetweenAttempts);
        if (!_disposed) {
          await _initializePragasWithRetry(attempts + 1);
        }
      } else {
        // Último recurso: inicializa diretamente
        if (!_disposed) {
          try {
            await _pragasProvider.initialize();
          } catch (finalError) {
            rethrow;
          }
        }
      }
    }
  }

  /// Atualiza o índice do carrossel
  void updateCarouselIndex(int index) {
    if (!_disposed && _currentCarouselIndex != index) {
      _currentCarouselIndex = index;
      notifyListeners();
    }
  }

  /// Força atualização dos dados de pragas
  Future<void> refreshPragasData() async {
    if (!_disposed) {
      await _pragasProvider.initialize();
    }
  }

  /// Registra acesso a uma praga
  void recordPragaAccess(PragaEntity praga) {
    if (!_disposed) {
      _pragasProvider.recordPragaAccess(praga);
    }
  }

  /// Força recarregamento completo de todos os dados
  Future<void> forceRefresh() async {
    if (_disposed) return;
    
    _isInitializing = true;
    _initializationFailed = false;
    _initializationError = null;
    notifyListeners();
    
    await _initialize();
  }

  /// Gera lista de sugestões formatada para o carrossel
  List<Map<String, dynamic>> getSuggestionsList() {
    if (isLoading || suggestedPragas.isEmpty) {
      return [];
    }
    
    return suggestedPragas.map((praga) {
      String emoji = '🐛';
      String type = 'Inseto';
      
      switch (praga.tipoPraga) {
        case '1':
          emoji = '🐛';
          type = 'Inseto';
          break;
        case '2':
          emoji = '🦠';
          type = 'Doença';
          break;
        case '3':
          emoji = '🌿';
          type = 'Planta';
          break;
      }
      
      return {
        'id': praga.idReg, // Include ID for better navigation precision
        'name': praga.nomeComum,
        'scientific': praga.nomeCientifico,
        'type': type,
        'emoji': emoji,
      };
    }).toList();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

}
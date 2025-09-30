import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/interfaces/i_premium_service.dart';
import '../../../../core/models/plantas_inf_hive.dart';
import '../../../../core/models/pragas_hive.dart';
import '../../../../core/models/pragas_inf_hive.dart';
import '../../../../core/repositories/favoritos_hive_repository.dart';
import '../../../../core/repositories/plantas_inf_hive_repository.dart';
import '../../../../core/repositories/pragas_hive_repository.dart';
import '../../../../core/repositories/pragas_inf_hive_repository.dart';
import '../../../../core/services/premium_status_notifier.dart';
import '../../../comentarios/models/comentario_model.dart';
import '../../../comentarios/services/comentarios_service.dart';
import '../../../favoritos/favoritos_di.dart';
import '../../../favoritos/presentation/providers/favoritos_provider_simplified.dart';

/// Provider para gerenciar estado da página de detalhes da praga
/// Responsabilidade única: coordenar dados e estado da praga
class DetalhePragaProvider extends ChangeNotifier {
  // Services e Repositories
  late final FavoritosHiveRepository _favoritosRepository;
  late final PragasHiveRepository _pragasRepository;
  late final PragasInfHiveRepository _pragasInfRepository;
  late final PlantasInfHiveRepository _plantasInfRepository;
  late final IPremiumService _premiumService;
  late final ComentariosService _comentariosService;
  late final FavoritosProviderSimplified _favoritosProvider;

  DetalhePragaProvider() {
    _initializeDependencies();
  }

  void _initializeDependencies() {
    _favoritosRepository = sl<FavoritosHiveRepository>();
    _pragasRepository = sl<PragasHiveRepository>();
    _pragasInfRepository = sl<PragasInfHiveRepository>();
    _plantasInfRepository = sl<PlantasInfHiveRepository>();
    _premiumService = sl<IPremiumService>();
    _comentariosService = sl<ComentariosService>();
    _favoritosProvider = FavoritosDI.get<FavoritosProviderSimplified>();
  }

  // Estado da praga
  String _pragaName = '';
  String _pragaScientificName = '';
  PragasHive? _pragaData;
  bool _isFavorited = false;
  bool _isPremium = false;
  
  // Estados de carregamento
  bool _isLoading = false;
  bool _isLoadingComments = false;
  String? _errorMessage;

  // Dados relacionados
  List<ComentarioModel> _comentarios = [];
  Map<String, dynamic>? _defensivoData;
  PragasInfHive? _pragaInfo;
  PlantasInfHive? _plantaInfo;
  
  // Subscription para mudanças no status premium
  StreamSubscription<bool>? _premiumStatusSubscription;

  // Getters
  String get pragaName => _pragaName;
  String get pragaScientificName => _pragaScientificName;
  PragasHive? get pragaData => _pragaData;
  bool get isFavorited => _isFavorited;
  bool get isPremium => _isPremium;
  bool get isLoading => _isLoading;
  bool get isLoadingComments => _isLoadingComments;
  String? get errorMessage => _errorMessage;
  List<ComentarioModel> get comentarios => _comentarios;
  Map<String, dynamic>? get defensivoData => _defensivoData;
  PragasInfHive? get pragaInfo => _pragaInfo;
  PlantasInfHive? get plantaInfo => _plantaInfo;

  /// Inicializa o provider com dados da praga
  Future<void> initialize(String pragaName, String pragaScientificName) async {
    _setLoading(true);
    try {
      _pragaName = pragaName;
      _pragaScientificName = pragaScientificName;
      
      await _loadFavoritoState();
      _loadPremiumStatus();
      await _loadComentarios();
    } finally {
      _setLoading(false);
    }
  }

  /// Versão assíncrona de initialize que aguarda dados estarem disponíveis
  Future<void> initializeAsync(String pragaName, String pragaScientificName) async {
    _setLoading(true);
    try {
      _pragaName = pragaName;
      _pragaScientificName = pragaScientificName;
      
      await _loadFavoritoStateAsync();
      await _loadPragaSpecificInfo();
      _loadPremiumStatus();
      await _loadComentarios();
    } catch (e) {
      _errorMessage = 'Erro ao inicializar dados da praga: $e';
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  /// Initialize usando ID da praga para melhor precisão
  Future<void> initializeById(String pragaId) async {
    debugPrint('🔍 [PRAGA] Inicializando por ID: $pragaId');
    _setLoading(true);
    try {
      // Buscar praga pelo ID
      debugPrint('🔍 [PRAGA] Buscando todas as pragas...');
      final allPragasResult = await _pragasRepository.getAll();
      allPragasResult.fold(
        (failure) {
          debugPrint('❌ [PRAGA] Erro ao carregar pragas: ${failure.toString()}');
          _pragaData = null;
        },
        (allPragas) {
          debugPrint('🔍 [PRAGA] Pragas encontradas: ${allPragas.length}');
          final matchingPragas = allPragas
              .where((PragasHive p) => p.idReg == pragaId || p.objectId == pragaId);
          _pragaData = matchingPragas.isNotEmpty ? matchingPragas.first : null;
          debugPrint('🔍 [PRAGA] Pragas correspondentes: ${matchingPragas.length}');
        },
      );
    
    if (_pragaData != null) {
      _pragaName = _pragaData!.nomeComum;
      _pragaScientificName = _pragaData!.nomeCientifico;
      
      debugPrint('✅ [PRAGA] Praga carregada por ID: $pragaId -> ${_pragaData!.nomeComum}');
      
      await _loadFavoritoStateAsync();
      await _loadPragaSpecificInfo();
      _loadPremiumStatus();
      await _loadComentarios();
    } else {
      debugPrint('❌ [PRAGA] Praga não encontrada para ID: $pragaId');
      // Fallback: deixar campos vazios para mostrar erro na UI
      _pragaName = '';
      _pragaScientificName = '';
    }
    } finally {
      _setLoading(false);
    }
  }

  /// Carrega estado de favorito da praga usando sistema simplificado consistente
  Future<void> _loadFavoritoState() async {
    // Busca a praga real pelo nome para obter o ID único
    final allPragasResult = await _pragasRepository.getAll();
    allPragasResult.fold(
      (failure) {
        debugPrint('❌ [PRAGA] Erro ao carregar pragas: ${failure.toString()}');
        _pragaData = null;
      },
      (allPragas) {
        final pragas = allPragas.where((PragasHive p) => p.nomeComum == _pragaName);
        _pragaData = pragas.isNotEmpty ? pragas.first : null;
      },
    );
    
    debugPrint('🔍 [PRAGA] Buscando praga: $_pragaName');
    debugPrint('🔍 [PRAGA] Praga encontrada: ${_pragaData != null ? _pragaData!.idReg : "null"}');
    
    final itemId = _pragaData?.idReg ?? _pragaName;
    
    try {
      _isFavorited = await _favoritosProvider.isFavorito('praga', itemId);
    } catch (e) {
      // Fallback para repository direto em caso de erro - usando tipo singular
      _isFavorited = await _favoritosRepository.isFavorito('praga', itemId);
    }
    
    notifyListeners();
  }

  /// Versão assíncrona que aguarda dados estarem disponíveis
  Future<void> _loadFavoritoStateAsync() async {
    debugPrint('🔍 Buscando praga: $_pragaName');
    
    // Tenta usar dados síncronos primeiro
    final allPragasResult = await _pragasRepository.getAll();
    allPragasResult.fold(
      (failure) {
        debugPrint('❌ [PRAGA] Erro ao carregar pragas: ${failure.toString()}');
        _pragaData = null;
      },
      (allPragas) {
        final pragas = allPragas.where((PragasHive p) => p.nomeComum == _pragaName);
        
        // Se não encontrou, usa a lista completa já carregada
        if (pragas.isEmpty) {
          debugPrint('⏳ Praga não encontrada nos dados disponíveis');
          _pragaData = null;
        } else {
          _pragaData = pragas.first;
        }
      },
    );
    
    final itemId = _pragaData?.idReg ?? _pragaName;
    
    if (_pragaData != null) {
      debugPrint('✅ Praga encontrada: ${_pragaData!.idReg} - ${_pragaData!.nomeComum}');
    } else {
      debugPrint('❌ Praga não encontrada: $_pragaName');
    }
    
    try {
      _isFavorited = await _favoritosProvider.isFavorito('praga', itemId);
    } catch (e) {
      // Fallback para repository direto em caso de erro - usando tipo singular
      _isFavorited = await _favoritosRepository.isFavorito('praga', itemId);
    }
    
    notifyListeners();
  }

  /// Carrega informações específicas baseado no tipo da praga
  Future<void> _loadPragaSpecificInfo() async {
    if (_pragaData == null) return;
    
    debugPrint('🔍 Carregando informações específicas para praga tipo: ${_pragaData!.tipoPraga}');
    
    try {
      // Para pragas do tipo "inseto" (tipoPraga = "1"), usa PragasInfHive
      if (_pragaData!.tipoPraga == '1') {
        _pragaInfo = await _pragasInfRepository.findByIdReg(_pragaData!.idReg);
        debugPrint('📋 PragaInfo carregada: ${_pragaInfo != null ? 'Sim' : 'Não'}');
      }
      
      // Para pragas do tipo "planta" (tipoPraga = "3"), usa PlantasInfHive  
      else if (_pragaData!.tipoPraga == '3') {
        _plantaInfo = await _plantasInfRepository.findByIdReg(_pragaData!.idReg);
        debugPrint('🌿 PlantaInfo carregada: ${_plantaInfo != null ? 'Sim' : 'Não'}');
      }
      
      // Para doenças (tipoPraga = "2"), também pode usar PragasInfHive
      else if (_pragaData!.tipoPraga == '2') {
        _pragaInfo = await _pragasInfRepository.findByIdReg(_pragaData!.idReg);
        debugPrint('🦠 DoençaInfo carregada: ${_pragaInfo != null ? 'Sim' : 'Não'}');
      }
      
    } catch (e) {
      debugPrint('❌ Erro ao carregar informações específicas: $e');
    }
    
    notifyListeners();
  }

  /// Carrega status premium do usuário
  void _loadPremiumStatus() {
    _isPremium = _premiumService.isPremium;
    
    // Configura listener para mudanças no status premium
    _setupPremiumStatusListener();
    notifyListeners();
  }
  
  /// Configura listener para mudanças automáticas no status premium
  void _setupPremiumStatusListener() {
    _premiumStatusSubscription?.cancel();
    _premiumStatusSubscription = PremiumStatusNotifier.instance
        .premiumStatusStream
        .listen((isPremiumStatus) {
      debugPrint('📱 DetalhePraga: Received premium status change = $isPremiumStatus');
      _isPremium = isPremiumStatus;
      notifyListeners();
    });
  }

  /// Carrega comentários da praga
  Future<void> _loadComentarios() async {
    _isLoadingComments = true;
    notifyListeners();
    
    try {
      // Usa ID real da praga se disponível, senão usa nome
      final pkIdentificador = _pragaData?.idReg ?? _pragaName;
      
      final comentarios = await _comentariosService.getAllComentarios(
        pkIdentificador: pkIdentificador,
      );
      
      _comentarios = comentarios;
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Erro ao carregar comentários: $e';
      debugPrint(_errorMessage);
    } finally {
      _isLoadingComments = false;
      notifyListeners();
    }
  }

  /// Adiciona um novo comentário
  Future<bool> addComentario(String content) async {
    if (!_comentariosService.isValidContent(content)) {
      _errorMessage = _comentariosService.getValidationErrorMessage();
      notifyListeners();
      return false;
    }

    if (!_comentariosService.canAddComentario(_comentarios.length)) {
      _errorMessage = 'Limite de comentários atingido. Assine o plano premium para mais.';
      notifyListeners();
      return false;
    }
    
    try {
      final newComment = ComentarioModel(
        id: _comentariosService.generateId(),
        idReg: _comentariosService.generateIdReg(),
        titulo: '',
        conteudo: content,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        ferramenta: 'Pragas - $_pragaName',
        pkIdentificador: _pragaName.toLowerCase().replaceAll(' ', '_'),
        status: true,
      );
      
      await _comentariosService.addComentario(newComment);
      _comentarios.insert(0, newComment);
      _errorMessage = null;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Erro ao adicionar comentário: $e';
      notifyListeners();
      return false;
    }
  }

  /// Remove um comentário
  Future<bool> deleteComentario(String commentId) async {
    try {
      await _comentariosService.deleteComentario(commentId);
      _comentarios.removeWhere((comment) => comment.id == commentId);
      _errorMessage = null;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Erro ao excluir comentário: $e';
      notifyListeners();
      return false;
    }
  }

  /// Alterna estado de favorito usando sistema simplificado consistente
  Future<bool> toggleFavorito() async {
    final wasAlreadyFavorited = _isFavorited;
    
    // Usa ID único do repositório se disponível, senão fallback para nome
    final itemId = _pragaData?.idReg ?? _pragaName;
    
    debugPrint('🔄 [FAVORITO] Iniciando toggle favorito');
    debugPrint('🔄 [FAVORITO] wasAlreadyFavorited: $wasAlreadyFavorited');
    debugPrint('🔄 [FAVORITO] itemId: $itemId');
    debugPrint('🔄 [FAVORITO] pragaName: $_pragaName');

    // Atualiza UI imediatamente
    _isFavorited = !wasAlreadyFavorited;
    notifyListeners();

    try {
      // Usa o sistema simplificado de favoritos
      debugPrint('🔄 [FAVORITO] Chamando favoritosProvider.toggleFavorito...');
      final success = await _favoritosProvider.toggleFavorito('praga', itemId);
      debugPrint('🔄 [FAVORITO] Resultado do provider: $success');

      if (!success) {
        // Revert on failure
        debugPrint('❌ [FAVORITO] Provider falhou, revertendo estado');
        _isFavorited = wasAlreadyFavorited;
        _errorMessage = 'Erro ao ${wasAlreadyFavorited ? 'remover' : 'adicionar'} favorito';
        notifyListeners();
        return false;
      }

      debugPrint('✅ [FAVORITO] Provider teve sucesso');
      _errorMessage = null;
      return true;
    } catch (e) {
      // Fallback para sistema antigo em caso de erro
      debugPrint('❌ [FAVORITO] Provider falhou, tentando fallback repository: $e');
      try {
        final itemData = {
          'nome': _pragaData?.nomeComum ?? _pragaName,
          'nomeCientifico': _pragaData?.nomeCientifico ?? _pragaScientificName,
          'idReg': itemId,
        };

        debugPrint('🔄 [FAVORITO] Chamando repository direto...');
        final success = wasAlreadyFavorited
            ? await _favoritosRepository.removeFavorito('praga', itemId)
            : await _favoritosRepository.addFavorito('praga', itemId, itemData);
        debugPrint('🔄 [FAVORITO] Resultado do repository: $success');

        if (!success) {
          debugPrint('❌ [FAVORITO] Repository também falhou, revertendo estado');
          _isFavorited = wasAlreadyFavorited;
          _errorMessage = 'Erro ao ${wasAlreadyFavorited ? 'remover' : 'adicionar'} favorito';
          notifyListeners();
          return false;
        }

        debugPrint('✅ [FAVORITO] Repository teve sucesso');
        _errorMessage = null;
        return true;
      } catch (fallbackError) {
        // Revert on error
        debugPrint('❌ [FAVORITO] Fallback repository também falhou: $fallbackError');
        _isFavorited = wasAlreadyFavorited;
        _errorMessage = 'Erro ao ${wasAlreadyFavorited ? 'remover' : 'adicionar'} favorito';
        notifyListeners();
        return false;
      }
    }
  }

  /// Limpa mensagem de erro
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Define estado de loading
  void _setLoading(bool loading) {
    if (_isLoading != loading) {
      _isLoading = loading;
      notifyListeners();
    }
  }

  /// Recarrega comentários
  Future<void> reloadComentarios() async {
    await _loadComentarios();
  }

  /// Navega para tela premium
  void navigateToPremium() {
    _premiumService.navigateToPremium();
  }

  @override
  void dispose() {
    _premiumStatusSubscription?.cancel();
    super.dispose();
  }
}
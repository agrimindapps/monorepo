import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/interfaces/i_premium_service.dart';
import '../../../../core/models/pragas_hive.dart';
import '../../../../core/models/pragas_inf_hive.dart';
import '../../../../core/models/plantas_inf_hive.dart';
import '../../../../core/repositories/favoritos_hive_repository.dart';
import '../../../favoritos/favoritos_di.dart';
import '../../../favoritos/presentation/providers/favoritos_provider_simplified.dart';
import '../../../../core/repositories/pragas_hive_repository.dart';
import '../../../../core/repositories/pragas_inf_hive_repository.dart';
import '../../../../core/repositories/plantas_inf_hive_repository.dart';
import '../../../../core/services/premium_status_notifier.dart';
import '../../../comentarios/models/comentario_model.dart';
import '../../../comentarios/services/comentarios_service.dart';

/// Provider para gerenciar estado da página de detalhes da praga
/// Responsabilidade única: coordenar dados e estado da praga
class DetalhePragaProvider extends ChangeNotifier {
  // Services e Repositories
  final FavoritosHiveRepository _favoritosRepository = sl<FavoritosHiveRepository>();
  final PragasHiveRepository _pragasRepository = sl<PragasHiveRepository>();
  final PragasInfHiveRepository _pragasInfRepository = sl<PragasInfHiveRepository>();
  final PlantasInfHiveRepository _plantasInfRepository = sl<PlantasInfHiveRepository>();
  final IPremiumService _premiumService = sl<IPremiumService>();
  final ComentariosService _comentariosService = sl<ComentariosService>();
  late final FavoritosProviderSimplified _favoritosProvider;

  DetalhePragaProvider() {
    _favoritosProvider = FavoritosDI.get<FavoritosProviderSimplified>();
  }

  // Estado da praga
  String _pragaName = '';
  String _pragaScientificName = '';
  PragasHive? _pragaData;
  bool _isFavorited = false;
  bool _isPremium = false;
  
  // Estados de carregamento
  final bool _isLoading = false;
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
    _pragaName = pragaName;
    _pragaScientificName = pragaScientificName;
    
    await _loadFavoritoState();
    _loadPremiumStatus();
    await _loadComentarios();
  }

  /// Versão assíncrona de initialize que aguarda dados estarem disponíveis
  Future<void> initializeAsync(String pragaName, String pragaScientificName) async {
    _pragaName = pragaName;
    _pragaScientificName = pragaScientificName;
    
    await _loadFavoritoStateAsync();
    await _loadPragaSpecificInfo();
    _loadPremiumStatus();
    await _loadComentarios();
  }

  /// Carrega estado de favorito da praga usando sistema simplificado consistente
  Future<void> _loadFavoritoState() async {
    // Busca a praga real pelo nome para obter o ID único
    final pragas = _pragasRepository.getAll()
        .where((p) => p.nomeComum == _pragaName);
    _pragaData = pragas.isNotEmpty ? pragas.first : null;
    
    final itemId = _pragaData?.idReg ?? _pragaName;
    
    try {
      _isFavorited = await _favoritosProvider.isFavorito('praga', itemId);
    } catch (e) {
      // Fallback para repository direto em caso de erro
      _isFavorited = _favoritosRepository.isFavorito('pragas', itemId);
    }
    
    notifyListeners();
  }

  /// Versão assíncrona que aguarda dados estarem disponíveis
  Future<void> _loadFavoritoStateAsync() async {
    debugPrint('🔍 Buscando praga: $_pragaName');
    
    // Tenta usar dados síncronos primeiro
    final pragas = _pragasRepository.getAll()
        .where((p) => p.nomeComum == _pragaName);
    
    // Se não encontrou, tenta versão assíncrona
    if (pragas.isEmpty) {
      debugPrint('⏳ Dados síncronos não encontrados, tentando busca assíncrona...');
      final allPragas = await _pragasRepository.getAllAsync();
      final pragasAsync = allPragas.where((p) => p.nomeComum == _pragaName);
      _pragaData = pragasAsync.isNotEmpty ? pragasAsync.first : null;
    } else {
      _pragaData = pragas.first;
    }
    
    final itemId = _pragaData?.idReg ?? _pragaName;
    
    if (_pragaData != null) {
      debugPrint('✅ Praga encontrada: ${_pragaData!.idReg} - ${_pragaData!.nomeComum}');
    } else {
      debugPrint('❌ Praga não encontrada: $_pragaName');
    }
    
    try {
      _isFavorited = await _favoritosProvider.isFavorito('praga', itemId);
    } catch (e) {
      // Fallback para repository direto em caso de erro  
      _isFavorited = _favoritosRepository.isFavorito('pragas', itemId);
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
        _pragaInfo = _pragasInfRepository.findByIdReg(_pragaData!.idReg);
        debugPrint('📋 PragaInfo carregada: ${_pragaInfo != null ? 'Sim' : 'Não'}');
      }
      
      // Para pragas do tipo "planta" (tipoPraga = "3"), usa PlantasInfHive  
      else if (_pragaData!.tipoPraga == '3') {
        _plantaInfo = _plantasInfRepository.findByIdReg(_pragaData!.idReg);
        debugPrint('🌿 PlantaInfo carregada: ${_plantaInfo != null ? 'Sim' : 'Não'}');
      }
      
      // Para doenças (tipoPraga = "2"), também pode usar PragasInfHive
      else if (_pragaData!.tipoPraga == '2') {
        _pragaInfo = _pragasInfRepository.findByIdReg(_pragaData!.idReg);
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

    // Atualiza UI imediatamente
    _isFavorited = !wasAlreadyFavorited;
    notifyListeners();

    try {
      // Usa o sistema simplificado de favoritos
      final success = await _favoritosProvider.toggleFavorito('praga', itemId);

      if (!success) {
        // Revert on failure
        _isFavorited = wasAlreadyFavorited;
        _errorMessage = 'Erro ao ${wasAlreadyFavorited ? 'remover' : 'adicionar'} favorito';
        notifyListeners();
        return false;
      }

      _errorMessage = null;
      return true;
    } catch (e) {
      // Fallback para sistema antigo em caso de erro
      try {
        final itemData = {
          'nome': _pragaData?.nomeComum ?? _pragaName,
          'nomeCientifico': _pragaData?.nomeCientifico ?? _pragaScientificName,
          'idReg': itemId,
        };

        final success = wasAlreadyFavorited
            ? await _favoritosRepository.removeFavorito('pragas', itemId)
            : await _favoritosRepository.addFavorito('pragas', itemId, itemData);

        if (!success) {
          _isFavorited = wasAlreadyFavorited;
          _errorMessage = 'Erro ao ${wasAlreadyFavorited ? 'remover' : 'adicionar'} favorito';
          notifyListeners();
          return false;
        }

        _errorMessage = null;
        return true;
      } catch (fallbackError) {
        // Revert on error
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
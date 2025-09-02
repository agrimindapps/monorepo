import 'package:flutter/foundation.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/interfaces/i_premium_service.dart';
import '../../../../core/models/pragas_hive.dart';
import '../../../../core/repositories/favoritos_hive_repository.dart';
import '../../../../core/repositories/pragas_hive_repository.dart';
import '../../../comentarios/models/comentario_model.dart';
import '../../../comentarios/services/comentarios_service.dart';

/// Provider para gerenciar estado da página de detalhes da praga
/// Responsabilidade única: coordenar dados e estado da praga
class DetalhePragaProvider extends ChangeNotifier {
  // Services e Repositories
  final FavoritosHiveRepository _favoritosRepository = sl<FavoritosHiveRepository>();
  final PragasHiveRepository _pragasRepository = sl<PragasHiveRepository>();
  final IPremiumService _premiumService = sl<IPremiumService>();
  final ComentariosService _comentariosService = sl<ComentariosService>();

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
  
  // Listener para premium status
  VoidCallback? _premiumStatusListener;

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

  /// Inicializa o provider com dados da praga
  void initialize(String pragaName, String pragaScientificName) {
    _pragaName = pragaName;
    _pragaScientificName = pragaScientificName;
    
    _loadFavoritoState();
    _loadPremiumStatus();
    _loadComentarios();
  }

  /// Versão assíncrona de initialize que aguarda dados estarem disponíveis
  Future<void> initializeAsync(String pragaName, String pragaScientificName) async {
    _pragaName = pragaName;
    _pragaScientificName = pragaScientificName;
    
    await _loadFavoritoStateAsync();
    _loadPremiumStatus();
    await _loadComentarios();
  }

  /// Carrega estado de favorito da praga
  void _loadFavoritoState() {
    // Busca a praga real pelo nome para obter o ID único
    final pragas = _pragasRepository.getAll()
        .where((p) => p.nomeComum == _pragaName);
    _pragaData = pragas.isNotEmpty ? pragas.first : null;
    
    if (_pragaData != null) {
      _isFavorited = _favoritosRepository.isFavorito('praga', _pragaData!.idReg);
    } else {
      // Fallback para nome se não encontrar no repositório
      _isFavorited = _favoritosRepository.isFavorito('praga', _pragaName);
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
    
    if (_pragaData != null) {
      debugPrint('✅ Praga encontrada: ${_pragaData!.idReg} - ${_pragaData!.nomeComum}');
      _isFavorited = _favoritosRepository.isFavorito('praga', _pragaData!.idReg);
    } else {
      debugPrint('❌ Praga não encontrada: $_pragaName');
      // Fallback para nome se não encontrar no repositório
      _isFavorited = _favoritosRepository.isFavorito('praga', _pragaName);
    }
    
    notifyListeners();
  }

  /// Carrega status premium do usuário
  void _loadPremiumStatus() {
    _isPremium = _premiumService.isPremium;
    
    // Remove listener anterior se existir
    if (_premiumStatusListener != null) {
      _premiumService.removeListener(_premiumStatusListener!);
    }
    
    // Cria novo listener
    _premiumStatusListener = () {
      _isPremium = _premiumService.isPremium;
      notifyListeners();
    };
    
    // Escuta mudanças no status premium
    _premiumService.addListener(_premiumStatusListener!);
    notifyListeners();
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

  /// Alterna estado de favorito
  Future<bool> toggleFavorito() async {
    final wasAlreadyFavorited = _isFavorited;
    
    // Usa ID único do repositório se disponível, senão fallback para nome
    final itemId = _pragaData?.idReg ?? _pragaName;
    final itemData = {
      'nome': _pragaData?.nomeComum ?? _pragaName,
      'nomeCientifico': _pragaData?.nomeCientifico ?? _pragaScientificName,
      'idReg': itemId,
    };

    // Atualiza UI imediatamente
    _isFavorited = !wasAlreadyFavorited;
    notifyListeners();

    final success = wasAlreadyFavorited
        ? await _favoritosRepository.removeFavorito('praga', itemId)
        : await _favoritosRepository.addFavorito('praga', itemId, itemData);

    if (!success) {
      // Reverter estado em caso de falha
      _isFavorited = wasAlreadyFavorited;
      _errorMessage = 'Erro ao ${wasAlreadyFavorited ? 'remover' : 'adicionar'} favorito';
      notifyListeners();
      return false;
    }

    _errorMessage = null;
    return true;
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
    // Remove listener do premium service
    if (_premiumStatusListener != null) {
      _premiumService.removeListener(_premiumStatusListener!);
      _premiumStatusListener = null;
    }
    super.dispose();
  }
}
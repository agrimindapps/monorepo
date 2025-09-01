import 'package:flutter/foundation.dart';
import '../../../../core/interfaces/i_premium_service.dart';
import '../../../../core/repositories/favoritos_hive_repository.dart';
import '../../../../core/repositories/fitossanitario_hive_repository.dart';
import '../../../../core/models/fitossanitario_hive.dart';
import '../../../comentarios/services/comentarios_service.dart';
import '../../../comentarios/models/comentario_model.dart';

/// Provider principal para gerenciamento de estado da página detalhe defensivo
/// Responsabilidade: coordenar estado da página, favoritos, premium, comentários
class DetalheDefensivoProvider extends ChangeNotifier {
  final FavoritosHiveRepository _favoritosRepository;
  final FitossanitarioHiveRepository _fitossanitarioRepository;
  final ComentariosService _comentariosService;
  final IPremiumService _premiumService;

  DetalheDefensivoProvider({
    required FavoritosHiveRepository favoritosRepository,
    required FitossanitarioHiveRepository fitossanitarioRepository,
    required ComentariosService comentariosService,
    required IPremiumService premiumService,
  })  : _favoritosRepository = favoritosRepository,
        _fitossanitarioRepository = fitossanitarioRepository,
        _comentariosService = comentariosService,
        _premiumService = premiumService;

  // Estados da página
  bool _isLoading = false;
  bool _hasError = false;
  String _errorMessage = '';
  FitossanitarioHive? _defensivoData;
  bool _isFavorited = false;

  // Estado dos comentários
  List<ComentarioModel> _comentarios = [];
  bool _isLoadingComments = false;

  // Getters
  bool get isLoading => _isLoading;
  bool get hasError => _hasError;
  String get errorMessage => _errorMessage;
  FitossanitarioHive? get defensivoData => _defensivoData;
  bool get isFavorited => _isFavorited;
  bool get isPremium => _premiumService.isPremium;
  List<ComentarioModel> get comentarios => _comentarios;
  bool get isLoadingComments => _isLoadingComments;

  /// Inicializa os dados do defensivo
  Future<void> initializeData(String defensivoName, String fabricante) async {
    _setLoading(true);

    try {
      await _loadDefensivoData(defensivoName);
      await _loadFavoritoState(defensivoName);
      await loadComentarios();
      _listenToPremiumChanges();
      
      _setLoading(false);
    } catch (e) {
      _setError('Erro ao carregar dados: $e');
    }
  }

  /// Carrega dados reais do defensivo
  Future<void> _loadDefensivoData(String defensivoName) async {
    final defensivos = _fitossanitarioRepository.getAll().where(
      (d) => d.nomeComum == defensivoName || d.nomeTecnico == defensivoName,
    );
    
    _defensivoData = defensivos.isNotEmpty ? defensivos.first : null;
    
    if (_defensivoData == null) {
      throw Exception('Defensivo não encontrado');
    }
    
    notifyListeners();
  }

  /// Carrega estado de favorito
  Future<void> _loadFavoritoState(String defensivoName) async {
    final itemId = _defensivoData?.idReg ?? defensivoName;
    _isFavorited = _favoritosRepository.isFavorito('defensivo', itemId);
    notifyListeners();
  }

  /// Carrega comentários do defensivo
  Future<void> loadComentarios() async {
    _setLoadingComments(true);

    try {
      final pkIdentificador = _defensivoData?.idReg ?? '';
      final comentarios = await _comentariosService.getAllComentarios(
        pkIdentificador: pkIdentificador,
      );

      _comentarios = comentarios;
      _setLoadingComments(false);
    } catch (e) {
      _setLoadingComments(false);
      debugPrint('Erro ao carregar comentários: $e');
    }
  }

  /// Adiciona novo comentário
  Future<bool> addComment(String content) async {
    if (!_comentariosService.isValidContent(content)) {
      return false;
    }

    if (!_comentariosService.canAddComentario(_comentarios.length)) {
      return false;
    }

    final newComment = ComentarioModel(
      id: _comentariosService.generateId(),
      idReg: _comentariosService.generateIdReg(),
      titulo: '',
      conteudo: content,
      ferramenta: 'defensivos',
      pkIdentificador: _defensivoData?.idReg ?? '',
      status: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    try {
      await _comentariosService.addComentario(newComment);
      _comentarios.add(newComment);
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Erro ao adicionar comentário: $e');
      return false;
    }
  }

  /// Remove comentário
  Future<bool> deleteComment(String commentId) async {
    try {
      await _comentariosService.deleteComentario(commentId);
      _comentarios.removeWhere((comment) => comment.id == commentId);
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Erro ao excluir comentário: $e');
      return false;
    }
  }

  /// Toggle favorito
  Future<bool> toggleFavorito(String defensivoName, String fabricante) async {
    final wasAlreadyFavorited = _isFavorited;
    final itemId = _defensivoData?.idReg ?? defensivoName;
    final itemData = {
      'nome': _defensivoData?.nomeComum ?? defensivoName,
      'fabricante': _defensivoData?.fabricante ?? fabricante,
      'idReg': itemId,
    };

    // Otimistic update
    _isFavorited = !wasAlreadyFavorited;
    notifyListeners();

    try {
      final success = wasAlreadyFavorited
          ? await _favoritosRepository.removeFavorito('defensivo', itemId)
          : await _favoritosRepository.addFavorito('defensivo', itemId, itemData);

      if (!success) {
        // Revert on failure
        _isFavorited = wasAlreadyFavorited;
        notifyListeners();
        return false;
      }

      return true;
    } catch (e) {
      // Revert on error
      _isFavorited = wasAlreadyFavorited;
      notifyListeners();
      debugPrint('Erro ao toggle favorito: $e');
      return false;
    }
  }

  /// Recarrega dados
  Future<void> refresh(String defensivoName, String fabricante) async {
    await initializeData(defensivoName, fabricante);
  }

  // Helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    _hasError = false;
    _errorMessage = '';
    notifyListeners();
  }

  void _setError(String message) {
    _isLoading = false;
    _hasError = true;
    _errorMessage = message;
    notifyListeners();
  }

  void _setLoadingComments(bool loading) {
    _isLoadingComments = loading;
    notifyListeners();
  }

  void _listenToPremiumChanges() {
    _premiumService.addListener(() {
      notifyListeners();
    });
  }

  // Public getters for external access
  String getValidationErrorMessage() => _comentariosService.getValidationErrorMessage();
  
  bool canAddComentario(int currentCount) => _comentariosService.canAddComentario(currentCount);
  
  bool isValidContent(String content) => _comentariosService.isValidContent(content);
}
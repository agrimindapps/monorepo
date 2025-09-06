import 'package:flutter/foundation.dart';

import '../../../../core/interfaces/i_premium_service.dart';
import '../../../../core/models/fitossanitario_hive.dart';
import '../../../../core/repositories/favoritos_hive_repository.dart';
import '../../../../core/repositories/fitossanitario_hive_repository.dart';
import '../../../comentarios/models/comentario_model.dart';
import '../../../comentarios/services/comentarios_service.dart';
import '../../../favoritos/favoritos_di.dart';
import '../../../favoritos/presentation/providers/favoritos_provider_simplified.dart';

/// Provider principal para gerenciamento de estado da página detalhe defensivo
/// Responsabilidade: coordenar estado da página, favoritos, premium, comentários
class DetalheDefensivoProvider extends ChangeNotifier {
  final FavoritosHiveRepository _favoritosRepository;
  final FitossanitarioHiveRepository _fitossanitarioRepository;
  final ComentariosService _comentariosService;
  final IPremiumService _premiumService;
  late final FavoritosProviderSimplified _favoritosProvider;

  DetalheDefensivoProvider({
    required FavoritosHiveRepository favoritosRepository,
    required FitossanitarioHiveRepository fitossanitarioRepository,
    required ComentariosService comentariosService,
    required IPremiumService premiumService,
  })  : _favoritosRepository = favoritosRepository,
        _fitossanitarioRepository = fitossanitarioRepository,
        _comentariosService = comentariosService,
        _premiumService = premiumService {
    _favoritosProvider = FavoritosDI.get<FavoritosProviderSimplified>();
  }

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

  /// Inicializa os dados do defensivo com carregamento otimizado
  Future<void> initializeData(String defensivoName, String fabricante) async {
    _setLoading(true);

    try {
      // Carrega dados essenciais primeiro
      await _loadDefensivoData(defensivoName);
      
      // Carrega dados secundários em paralelo para otimizar performance
      await Future.wait([
        _loadFavoritoState(defensivoName),
        loadComentarios(),
      ]);
      
      _listenToPremiumChanges();
      _setLoading(false);
    } catch (e) {
      _setError('Erro ao carregar dados: $e');
    }
  }

  /// Carrega dados reais do defensivo com cache otimizado
  Future<void> _loadDefensivoData(String defensivoName) async {
    // Busca por nome comum primeiro (mais comum)
    var defensivos = _fitossanitarioRepository.getAll().where(
      (d) => d.nomeComum == defensivoName,
    );
    
    // Se não encontrar, busca por nome técnico
    if (defensivos.isEmpty) {
      defensivos = _fitossanitarioRepository.getAll().where(
        (d) => d.nomeTecnico == defensivoName,
      );
    }
    
    _defensivoData = defensivos.isNotEmpty ? defensivos.first : null;
    
    if (_defensivoData == null) {
      throw Exception('Defensivo não encontrado');
    }
    
    notifyListeners();
  }

  /// Carrega estado de favorito
  Future<void> _loadFavoritoState(String defensivoName) async {
    final itemId = _defensivoData?.idReg ?? defensivoName;
    try {
      _isFavorited = await _favoritosRepository.isFavoritoAsync('defensivos', itemId);
    } catch (e) {
      // Fallback to synchronous method
      _isFavorited = _favoritosRepository.isFavorito('defensivos', itemId);
    }
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
      return false;
    }
  }

  /// Toggle favorito usando sistema simplificado
  Future<bool> toggleFavorito(String defensivoName, String fabricante) async {
    final wasAlreadyFavorited = _isFavorited;
    final itemId = _defensivoData?.idReg ?? defensivoName;

    // Otimistic update
    _isFavorited = !wasAlreadyFavorited;
    notifyListeners();

    try {
      // Usa o sistema simplificado de favoritos
      final success = await _favoritosProvider.toggleFavorito('defensivo', itemId);

      if (!success) {
        // Revert on failure
        _isFavorited = wasAlreadyFavorited;
        notifyListeners();
        return false;
      }

      return true;
    } catch (e) {
      // Fallback para sistema antigo em caso de erro
      try {
        final itemData = {
          'nome': _defensivoData?.nomeComum ?? defensivoName,
          'fabricante': _defensivoData?.fabricante ?? fabricante,
          'idReg': itemId,
        };

        final success = wasAlreadyFavorited
            ? await _favoritosRepository.removeFavorito('defensivos', itemId)
            : await _favoritosRepository.addFavorito('defensivos', itemId, itemData);

        if (!success) {
          _isFavorited = wasAlreadyFavorited;
          notifyListeners();
          return false;
        }

        return true;
      } catch (fallbackError) {
        // Revert on error
        _isFavorited = wasAlreadyFavorited;
        notifyListeners();
        // Erro silencioso para não poluir logs em produção
        return false;
      }
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
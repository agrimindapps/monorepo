
import '../../../../../core/constants/app_constants.dart';
import '../../../../../core/services/localstorage_service.dart';
import '../../models/categoria_model.dart';
import '../../models/termo_model.dart';
import 'database_datasource.dart';

/// Abstract contract for local termos operations
abstract class TermosLocalDataSource {
  /// Load all terms from all categories
  Future<List<TermoModel>> loadAllTermos();

  /// Get list of favorited term IDs
  Future<List<String>> getFavoritos();

  /// Toggle favorite status for a term
  Future<bool> setFavorito(String termoId);

  /// Check if a term is favorited
  Future<bool> isFavorito(String termoId);

  /// Get the currently selected category
  Future<CategoriaModel?> getCategoriaAtual();

  /// Set the currently selected category
  Future<void> setCategoria(CategoriaModel categoria);

  /// Get all available categories
  List<CategoriaModel> getCategorias();
}

/// Implementation of local termos data source
/// Coordinates between database assets and local storage
class TermosLocalDataSourceImpl implements TermosLocalDataSource {
  final DatabaseDataSource _databaseDataSource;
  final LocalStorageService _localStorageService;

  TermosLocalDataSourceImpl(
    this._databaseDataSource,
    this._localStorageService,
  );

  @override
  Future<List<TermoModel>> loadAllTermos() async {
    try {
      // Get favorited term IDs
      final List<String> favoritos = await getFavoritos();

      // Get all categories
      final List<CategoriaModel> categorias = getCategorias();

      List<TermoModel> allTermos = [];

      // Load terms from each category
      for (final categoria in categorias) {
        // Load raw data from JSON assets
        final List<Map<String, dynamic>> rawData =
            await _databaseDataSource.loadTermosFromAsset(categoria.keytermo);

        // Process each term
        for (final Map<String, dynamic> termoData in rawData) {
          // Decrypt description
          final String encryptedDesc = termoData['descricao']?.toString() ?? '';
          final String decryptedDesc = _databaseDataSource.decryptDescription(
            encryptedDesc,
            categoria.keydecripy,
          );

          // Create TermoModel with decrypted description
          final termo = TermoModel.fromJson(
            {
              ...termoData,
              'descricao': decryptedDesc,
            },
            categoria: categoria.descricao,
            favorito: favoritos.contains(termoData['id']?.toString() ?? ''),
          );

          allTermos.add(termo);
        }
      }

      return allTermos;
    } catch (e) {
      throw Exception('Failed to load all termos: $e');
    }
  }

  @override
  Future<List<String>> getFavoritos() async {
    try {
      return await _localStorageService.getFavoritos(
        AppConstants.favoritosKey,
      );
    } catch (e) {
      // Return empty list if no favorites exist yet
      return [];
    }
  }

  @override
  Future<bool> setFavorito(String termoId) async {
    try {
      return await _localStorageService.setFavorito(
        AppConstants.favoritosKey,
        termoId,
      );
    } catch (e) {
      throw Exception('Failed to set favorito: $e');
    }
  }

  @override
  Future<bool> isFavorito(String termoId) async {
    try {
      return await _localStorageService.validFavorito(
        AppConstants.favoritosKey,
        termoId,
      );
    } catch (e) {
      return false;
    }
  }

  @override
  Future<CategoriaModel?> getCategoriaAtual() async {
    try {
      final Map<String, dynamic> data = await _localStorageService.carregar(
        AppConstants.categoriaKey,
      );

      if (data.isEmpty) {
        // Return first category as default
        final defaultCategoria = getCategorias().first;
        await setCategoria(defaultCategoria);
        return defaultCategoria;
      }

      return CategoriaModel.fromJson(data);
    } catch (e) {
      // Return first category as fallback
      return getCategorias().first;
    }
  }

  @override
  Future<void> setCategoria(CategoriaModel categoria) async {
    try {
      await _localStorageService.adicionar(
        AppConstants.categoriaKey,
        categoria.toJson(),
      );
    } catch (e) {
      throw Exception('Failed to set categoria: $e');
    }
  }

  @override
  List<CategoriaModel> getCategorias() {
    // Convert AppConstants categorias to CategoriaModel list
    return AppConstants.categorias
        .map((catJson) => CategoriaModel.fromJson(catJson))
        .toList();
  }
}

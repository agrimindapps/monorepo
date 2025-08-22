import '../repositories/calculator_repository.dart';

/// Use case para gerenciar calculadoras favoritas
class ManageFavorites {
  const ManageFavorites(this._repository);
  
  final CalculatorRepository _repository;

  /// Adiciona uma calculadora aos favoritos
  /// 
  /// [calculatorId] - ID da calculadora
  Future<void> addFavorite(String calculatorId) async {
    await _repository.addFavoriteCalculator(calculatorId);
  }

  /// Remove uma calculadora dos favoritos
  /// 
  /// [calculatorId] - ID da calculadora
  Future<void> removeFavorite(String calculatorId) async {
    await _repository.removeFavoriteCalculator(calculatorId);
  }

  /// Alterna o status de favorito de uma calculadora
  /// 
  /// [calculatorId] - ID da calculadora
  /// Retorna true se agora é favorita, false se foi removida
  Future<bool> toggleFavorite(String calculatorId) async {
    final isFavorite = await _repository.isFavoriteCalculator(calculatorId);
    
    if (isFavorite) {
      await _repository.removeFavoriteCalculator(calculatorId);
      return false;
    } else {
      await _repository.addFavoriteCalculator(calculatorId);
      return true;
    }
  }

  /// Verifica se uma calculadora é favorita
  /// 
  /// [calculatorId] - ID da calculadora
  /// Retorna true se for favorita
  Future<bool> isFavorite(String calculatorId) async {
    return await _repository.isFavoriteCalculator(calculatorId);
  }

  /// Obtém lista de IDs das calculadoras favoritas
  Future<List<String>> getFavoriteIds() async {
    return await _repository.getFavoriteCalculatorIds();
  }
}
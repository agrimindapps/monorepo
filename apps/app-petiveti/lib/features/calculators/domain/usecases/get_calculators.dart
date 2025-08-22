import '../entities/calculator.dart';
import '../repositories/calculator_repository.dart';

/// Use case para obter lista de calculadoras
class GetCalculators {
  const GetCalculators(this._repository);
  
  final CalculatorRepository _repository;

  /// Obtém todas as calculadoras disponíveis
  Future<List<Calculator>> call() async {
    return await _repository.getCalculators();
  }
}

/// Use case para obter calculadoras por categoria
class GetCalculatorsByCategory {
  const GetCalculatorsByCategory(this._repository);
  
  final CalculatorRepository _repository;

  /// Obtém calculadoras de uma categoria específica
  /// 
  /// [category] - Categoria das calculadoras desejadas
  /// Retorna lista de calculadoras da categoria
  Future<List<Calculator>> call(CalculatorCategory category) async {
    return await _repository.getCalculatorsByCategory(category);
  }
}

/// Use case para obter calculadora por ID
class GetCalculatorById {
  const GetCalculatorById(this._repository);
  
  final CalculatorRepository _repository;

  /// Obtém uma calculadora específica por ID
  /// 
  /// [id] - ID da calculadora
  /// Retorna a calculadora ou null se não encontrada
  Future<Calculator?> call(String id) async {
    return await _repository.getCalculatorById(id);
  }
}

/// Use case para obter calculadoras favoritas
class GetFavoriteCalculators {
  const GetFavoriteCalculators(this._repository);
  
  final CalculatorRepository _repository;

  /// Obtém lista de calculadoras marcadas como favoritas
  Future<List<Calculator>> call() async {
    final favoriteIds = await _repository.getFavoriteCalculatorIds();
    final allCalculators = await _repository.getCalculators();
    
    return allCalculators
        .where((calc) => favoriteIds.contains(calc.id))
        .toList();
  }
}

/// Use case para obter calculadoras mais utilizadas
class GetMostUsedCalculators {
  const GetMostUsedCalculators(this._repository);
  
  final CalculatorRepository _repository;

  /// Obtém calculadoras ordenadas por uso (mais utilizadas primeiro)
  /// 
  /// [limit] - Número máximo de calculadoras a retornar
  Future<List<Calculator>> call({int limit = 10}) async {
    final usageStats = await _repository.getCalculatorUsageStats();
    final allCalculators = await _repository.getCalculators();
    
    // Ordenar por quantidade de uso (decrescente)
    allCalculators.sort((a, b) {
      final usageA = usageStats[a.id] ?? 0;
      final usageB = usageStats[b.id] ?? 0;
      return usageB.compareTo(usageA);
    });
    
    return allCalculators.take(limit).toList();
  }
}
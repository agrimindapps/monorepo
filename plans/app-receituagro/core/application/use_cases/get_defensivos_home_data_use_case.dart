// Project imports:
import '../../domain/entities/defensivo_entity.dart';
import '../../domain/entities/defensivos_stats_entity.dart';
import '../../domain/repositories/i_defensivos_repository.dart';
import '../../error/result.dart';
import '../dtos/defensivo_dto.dart';
import '../dtos/defensivos_home_data_dto.dart';
import '../mappers/defensivos_mapper.dart';

/// UseCase responsável por carregar todos os dados necessários para a tela home dos defensivos
/// 
/// Coordena múltiplas operações de repositório e aplica regras de negócio específicas
/// para a tela home, como filtrar defensivos recentes e novos
class GetDefensivosHomeDataUseCase {
  final IDefensivosRepository _repository;
  final DefensivosMapper _mapper;

  const GetDefensivosHomeDataUseCase(
    this._repository,
    this._mapper,
  );

  /// Executa o caso de uso para obter dados da home
  /// 
  /// Retorna [Result] com [DefensivosHomeDataDto] ou erro
  Future<Result<DefensivosHomeDataDto>> execute() async {
    try {
      // Verifica se o repositório está inicializado
      if (!_repository.isDataLoaded) {
        final initResult = await _repository.initialize();
        if (initResult.isFailure) {
          return Result.failure(initResult.errorOrNull!);
        }
      }

      // Carrega dados em paralelo para melhor performance
      final results = await Future.wait([
        _repository.getDefensivosStats(),
        _repository.getRecentlyAccessedDefensivos(),
        _repository.getNewDefensivos(),
      ]);

      final statsResult = results[0];
      final recentResult = results[1];
      final newResult = results[2];

      // Verifica se alguma operação falhou
      if (statsResult.isFailure) {
        return Result.failure(statsResult.errorOrNull!);
      }

      if (recentResult.isFailure) {
        return Result.failure(recentResult.errorOrNull!);
      }

      if (newResult.isFailure) {
        return Result.failure(newResult.errorOrNull!);
      }

      // Converte entities para DTOs
      final statsDto = _mapper.statsEntityToDto(statsResult.valueOrNull! as DefensivosStatsEntity);
      final recentDtos = (recentResult.valueOrNull! as List<DefensivoEntity>)
          .map((entity) => _mapper.defensivoEntityToDto(entity))
          .toList();
      final newDtos = (newResult.valueOrNull! as List<DefensivoEntity>)
          .map((entity) => _mapper.defensivoEntityToDto(entity))
          .toList();

      // Aplica regras de negócio específicas da home
      final homeData = DefensivosHomeDataDto(
        stats: statsDto,
        recentlyAccessed: _limitAndSortRecentlyAccessed(recentDtos),
        newProducts: _limitNewProducts(newDtos),
      );

      return Result.success(homeData);

    } catch (e) {
      return Result.failure(RepositoryError(
        repositoryName: 'DefensivosRepository',
        operation: 'getDefensivosHomeData',
        message: 'Erro ao carregar dados da home: ${e.toString()}',
      ));
    }
  }

  /// Regra de negócio: limita e ordena defensivos recentemente acessados
  List<DefensivoDto> _limitAndSortRecentlyAccessed(List<DefensivoDto> items) {
    // Filtra apenas items com timestamp válido e ordena por data de acesso
    final validItems = items
        .where((item) => item.lastAccessedTimestamp != null)
        .toList();

    validItems.sort((a, b) {
      final dateA = DateTime.tryParse(a.lastAccessedTimestamp!) ?? DateTime(1970);
      final dateB = DateTime.tryParse(b.lastAccessedTimestamp!) ?? DateTime(1970);
      return dateB.compareTo(dateA); // Mais recente primeiro
    });

    // Limita a 7 items conforme regra de negócio
    return validItems.take(7).toList();
  }

  /// Regra de negócio: limita produtos novos
  List<DefensivoDto> _limitNewProducts(List<DefensivoDto> items) {
    // Filtra apenas produtos marcados como novos e limita a 10
    return items.where((item) => item.isNew).take(10).toList();
  }
}
// Project imports:
import '../../../../models/medicoes_models.dart';
import '../../../../models/pluviometros_models.dart';
import '../repository/medicoes_page_repository.dart';
import 'cache_service.dart';
import 'validation_service.dart';

/// Service responsável por operações de dados relacionadas às medições
class DataService {
  final MedicoesPageRepository _repository;
  final CacheService _cache = CacheService();

  DataService({MedicoesPageRepository? repository})
      : _repository = repository ?? MedicoesPageRepository();

  /// Carrega lista de pluviômetros disponíveis
  Future<List<Pluviometro>> getPluviometros() async {
    // Rate limiting para operações sensíveis
    if (ValidationService.isRateLimited('getPluviometros')) {
      throw DataServiceException(
          'Muitas tentativas de acesso. Tente novamente em alguns segundos.');
    }

    try {
      final pluviometros = await _repository.getPluviometros();

      // Validação básica dos dados retornados
      for (final pluviometro in pluviometros) {
        final validationResult =
            ValidationService.validatePluviometro(pluviometro);
        if (!validationResult.isValid) {
          throw DataServiceException(
              'Pluviômetro inválido encontrado: ${validationResult.errors.first}');
        }
      }

      return pluviometros;
    } catch (e) {
      throw DataServiceException('Erro ao carregar pluviômetros: $e');
    }
  }

  /// Carrega medições para um pluviômetro específico
  Future<List<Medicoes>> getMedicoes(String pluviometroId) async {
    // Validação de segurança do ID
    if (!ValidationService.isValidId(pluviometroId)) {
      throw DataServiceException(
          'ID do pluviômetro inválido ou potencialmente perigoso');
    }

    // Rate limiting para operações sensíveis
    if (ValidationService.isRateLimited('getMedicoes_$pluviometroId')) {
      throw DataServiceException(
          'Muitas tentativas de acesso. Tente novamente em alguns segundos.');
    }

    try {
      final medicoes = await _repository.getMedicoes(pluviometroId);

      // Validação dos dados retornados
      final validationResult = ValidationService.validateMedicoesList(medicoes);
      if (validationResult.hasErrors) {
        throw DataServiceException(
            'Dados retornados contêm erros: ${validationResult.allErrors.take(3).join(', ')}');
      }

      return medicoes;
    } catch (e) {
      throw DataServiceException('Erro ao carregar medições: $e');
    }
  }

  /// Filtra medições por mês específico
  List<Medicoes> getMedicoesDoMes(List<Medicoes> medicoes, DateTime date) {
    return medicoes.where((medicao) {
      final medicaoDate =
          DateTime.fromMillisecondsSinceEpoch(medicao.dtMedicao);
      return medicaoDate.year == date.year && medicaoDate.month == date.month;
    }).toList();
  }

  /// Extrai lista de meses únicos das medições com cache
  List<DateTime> getMonthsList(List<Medicoes> medicoes) {
    // Verifica cache primeiro
    final cached = _cache.getCachedMonthsList(medicoes);
    if (cached != null) {
      return cached;
    }

    final Set<DateTime> monthsSet = {};

    for (var medicao in medicoes) {
      final date = DateTime.fromMillisecondsSinceEpoch(medicao.dtMedicao);
      final monthDate = DateTime(date.year, date.month);
      monthsSet.add(monthDate);
    }

    final months = monthsSet.toList();
    months.sort((a, b) => a.compareTo(b));

    // Armazena no cache
    _cache.cacheMonthsList(medicoes, months);
    return months;
  }

  /// Encontra medição para uma data específica
  Medicoes findMedicaoForDate(
      List<Medicoes> medicoesDoMes, DateTime currentDate) {
    return medicoesDoMes.firstWhere(
      (m) {
        final medicaoDate = DateTime.fromMillisecondsSinceEpoch(m.dtMedicao);
        return medicaoDate.year == currentDate.year &&
            medicaoDate.month == currentDate.month &&
            medicaoDate.day == currentDate.day;
      },
      orElse: () => _createEmptyMedicao(currentDate),
    );
  }

  /// Cria uma medição vazia para uma data específica
  Medicoes _createEmptyMedicao(DateTime currentDate) {
    return Medicoes(
      id: '',
      createdAt: 0,
      updatedAt: 0,
      fkPluviometro: '',
      dtMedicao: currentDate.millisecondsSinceEpoch,
      quantidade: 0,
    );
  }
}

/// Exceção específica para erros do DataService
class DataServiceException implements Exception {
  final String message;

  DataServiceException(this.message);

  @override
  String toString() => 'DataServiceException: $message';
}

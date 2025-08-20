// Project imports:
import '../../../../models/medicoes_models.dart';
import '../../../../models/pluviometros_models.dart';

/// Interface para o repositório de dados de pluviometria
abstract class IResultadosPluviometroRepository {
  /// Carrega lista de pluviômetros
  Future<List<Pluviometro>> carregarPluviometros();

  /// Carrega medições de um pluviômetro específico
  Future<List<Medicoes>> carregarMedicoes(String pluviometroId);

  /// Carrega dados completos (pluviômetros e medições)
  Future<Map<String, dynamic>> carregarDadosCompletos();

  /// Carrega medições por período
  Future<List<Medicoes>> carregarMedicoesPorPeriodo(
    String pluviometroId,
    DateTime inicio,
    DateTime fim,
  );

  /// Carrega estatísticas básicas
  Future<Map<String, dynamic>> carregarEstatisticasBasicas(
      String pluviometroId);
}

/// Interface para cache de dados
abstract class ICacheRepository {
  /// Salva dados no cache
  Future<void> salvarCache<T>(String key, T data, {Duration? ttl});

  /// Recupera dados do cache
  Future<T?> obterCache<T>(String key);

  /// Remove dados do cache
  Future<void> removerCache(String key);

  /// Limpa todo o cache
  Future<void> limparCache();

  /// Verifica se item existe no cache
  Future<bool> existeNoCache(String key);
}

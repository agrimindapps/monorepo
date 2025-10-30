import 'package:core/core.dart';

/// Interface para data source local de conta
/// Abstração para acesso a Hive ou outro storage local
abstract class AccountLocalDataSource {
  /// Obtém informações da conta armazenadas localmente
  Future<UserEntity?> getLocalAccountInfo();

  /// Limpa dados locais de conteúdo do usuário
  Future<int> clearLocalUserData();

  /// Remove todos os dados da conta localmente
  Future<void> clearAccountData();
}

/// Implementação do data source local usando Hive
class AccountLocalDataSourceImpl implements AccountLocalDataSource {
  final HiveService hiveService;

  const AccountLocalDataSourceImpl(this.hiveService);

  @override
  Future<UserEntity?> getLocalAccountInfo() async {
    try {
      // Implementação depende da estrutura atual do Hive
      // Por enquanto retorna null, será implementado conforme necessário
      return null;
    } catch (e) {
      throw CacheFailure('Erro ao buscar dados locais: $e');
    }
  }

  @override
  Future<int> clearLocalUserData() async {
    try {
      int totalCleared = 0;
      
      // Limpa boxes de plantas
      final plantsBox = await hiveService.openBox('plantas');
      totalCleared += plantsBox.length;
      await plantsBox.clear();

      // Limpa boxes de tarefas
      final tasksBox = await hiveService.openBox('tarefas');
      totalCleared += tasksBox.length;
      await tasksBox.clear();

      // Limpa outros boxes de conteúdo conforme necessário
      
      return totalCleared;
    } catch (e) {
      throw CacheFailure('Erro ao limpar dados locais: $e');
    }
  }

  @override
  Future<void> clearAccountData() async {
    try {
      await clearLocalUserData();
      // Limpa também dados de configuração da conta se necessário
    } catch (e) {
      throw CacheFailure('Erro ao limpar dados da conta: $e');
    }
  }
}

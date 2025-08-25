import 'package:hive_flutter/hive_flutter.dart';
import '../../../../shared/utils/result.dart';

/// Interface para gerenciamento centralizado do Hive
/// Define contratos para inicialização, abertura e fechamento de boxes
abstract class IHiveManager {
  /// Inicializa o Hive com configurações específicas do app
  /// [appName] usado para criar path único de armazenamento
  Future<Result<void>> initialize(String appName);

  /// Obtém uma box do Hive, abrindo se necessário
  /// Retorna a box tipada ou erro se houver falha
  Future<Result<Box<T>>> getBox<T>(String boxName);

  /// Fecha uma box específica e remove do cache
  /// Libera recursos de memória
  Future<Result<void>> closeBox(String boxName);

  /// Fecha todas as boxes abertas
  /// Útil para cleanup durante logout ou reset
  Future<Result<void>> closeAllBoxes();

  /// Verifica se uma box está aberta
  bool isBoxOpen(String boxName);

  /// Verifica se o Hive foi inicializado
  bool get isInitialized;

  /// Lista todas as boxes abertas
  List<String> get openBoxNames;

  /// Registra um adapter personalizado
  /// Deve ser chamado antes de abrir boxes que usam o adapter
  Future<Result<void>> registerAdapter<T>(TypeAdapter<T> adapter);

  /// Verifica se um adapter está registrado para um tipo
  bool isAdapterRegistered<T>();

  /// Limpa completamente todos os dados do Hive
  /// CUIDADO: Operação destrutiva
  Future<Result<void>> clearAllData();

  /// Obtém estatísticas de uso das boxes
  Map<String, int> getBoxStatistics();
}
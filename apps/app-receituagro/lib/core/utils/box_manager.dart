import 'package:core/core.dart';

/// Utilitário para gerenciamento seguro de boxes (Legacy storage)
///
/// Fornece métodos para executar operações com boxes garantindo
/// abertura e fechamento adequados dos recursos.
///
/// Nota: Este é um wrapper para o sistema legado de storage.
/// Novas implementações devem usar Drift diretamente.
class BoxManager {
  /// Executa uma operação com uma única box (sem fechar automaticamente)
  ///
  /// [T] - Tipo dos dados na box
  /// [R] - Tipo do resultado da operação
  ///
  /// ATENÇÃO: A box NÃO é fechada automaticamente. O caller é responsável por fechá-la.
  static Future<Result<R>> readBox<T, R>({
    required IHiveManager hiveManager,
    required String boxName,
    required Future<R> Function(Box<T> box) operation,
  }) async {
    try {
      // Abrir box
      final boxResult = await hiveManager.getBox<T>(boxName);
      if (boxResult.isError) {
        return Result.error(boxResult.error!);
      }

      final box = boxResult.data!;

      // Executar operação (sem fechar a box)
      final result = await operation(box);

      return Result.success(result);
    } catch (e) {
      return Result.error(AppError.custom(message: 'Operation failed: $e'));
    }
  }

  /// Executa uma operação com uma única box
  ///
  /// [T] - Tipo dos dados na box
  /// [R] - Tipo do resultado da operação
  ///
  /// A box será automaticamente fechada após a operação.
  static Future<Result<R>> withBox<T, R>({
    required IHiveManager hiveManager,
    required String boxName,
    required Future<R> Function(Box<T> box) operation,
  }) async {
    try {
      // Abrir box
      final boxResult = await hiveManager.getBox<T>(boxName);
      if (boxResult.isError) {
        return Result.error(boxResult.error!);
      }

      final box = boxResult.data!;

      // Executar operação
      final result = await operation(box);

      // Fechar box
      await hiveManager.closeBox(boxName);

      return Result.success(result);
    } catch (e) {
      // Garantir fechamento mesmo em caso de erro
      try {
        await hiveManager.closeBox(boxName);
      } catch (_) {
        // Ignorar erros de fechamento se já houve erro na operação
      }
      return Result.error(AppError.custom(message: 'Operation failed: $e'));
    }
  }

  /// Executa uma operação com múltiplas boxes simultaneamente
  ///
  /// [R] - Tipo do resultado da operação
  ///
  /// Todas as boxes serão abertas antes da operação e fechadas após.
  /// Útil para operações que precisam acessar múltiplas boxes atomicamente.
  static Future<Result<R>> withMultipleBoxes<R>({
    required IHiveManager hiveManager,
    required List<String> boxNames,
    required Future<R> Function(Map<String, Box<dynamic>> boxes) operation,
  }) async {
    final openedBoxes = <String>[];
    final boxes = <String, Box<dynamic>>{};

    try {
      // Abrir todas as boxes
      for (final boxName in boxNames) {
        final boxResult = await hiveManager.getBox<dynamic>(boxName);
        if (boxResult.isError) {
          return Result.error(boxResult.error!);
        }
        boxes[boxName] = boxResult.data!;
        openedBoxes.add(boxName);
      }

      // Executar operação
      final result = await operation(boxes);

      return Result.success(result);
    } catch (e) {
      return Result.error(AppError.custom(message: 'Operation failed: $e'));
    } finally {
      // Fechar todas as boxes abertas
      for (final boxName in openedBoxes) {
        try {
          await hiveManager.closeBox(boxName);
        } catch (_) {
          // Ignorar erros individuais de fechamento
        }
      }
    }
  }
}

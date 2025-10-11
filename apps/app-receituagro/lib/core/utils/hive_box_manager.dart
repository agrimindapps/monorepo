import 'dart:developer' as developer;

import 'package:core/core.dart';

/// Helper centralizado para gerenciar abertura/fechamento seguro de Hive boxes
///
/// Implementa o padrão try-finally garantindo que boxes sejam sempre fechadas
/// após operações, prevenindo memory leaks.
///
/// Uso:
/// ```dart
/// final result = await HiveBoxManager.withBox<DiagnosticoHive, List<DiagnosticoHive>>(
///   hiveManager: hiveManager,
///   boxName: 'diagnosticos',
///   operation: (box) async {
///     return box.values.toList();
///   },
/// );
/// ```
class HiveBoxManager {
  HiveBoxManager._(); // Private constructor - utility class

  /// Executa uma operação em uma box específica, garantindo abertura e fechamento seguros
  ///
  /// [hiveManager] - Instância do IHiveManager para gerenciar boxes
  /// [boxName] - Nome da box a ser aberta
  /// [operation] - Operação assíncrona a ser executada com a box
  ///
  /// Retorna um `Result<R>` com o resultado da operação ou erro
  static Future<Result<R>> withBox<T, R>({
    required IHiveManager hiveManager,
    required String boxName,
    required Future<R> Function(Box<T>) operation,
  }) async {
    Box<T>? box;
    bool wasBoxAlreadyOpen = false;

    try {
      // Log início da operação em debug mode
      developer.log(
        'Opening box for operation: $boxName',
        name: 'HiveBoxManager.withBox',
      );

      // Verifica se box já estava aberta antes
      wasBoxAlreadyOpen = hiveManager.isBoxOpen(boxName);

      // Obtém a box através do HiveManager
      final boxResult = await hiveManager.getBox<T>(boxName);

      if (boxResult.isError) {
        developer.log(
          'Failed to open box: $boxName - ${boxResult.error}',
          name: 'HiveBoxManager.withBox',
          level: 900, // Error level
        );
        return Result.error(boxResult.error!);
      }

      final boxData = boxResult.data;
      if (boxData == null) {
        return Result.error(
          StorageError(
            message: 'Box data is null for: $boxName',
            code: 'NULL_BOX_DATA',
          ),
        );
      }

      box = boxData;

      // Executa a operação
      final result = await operation(box);

      developer.log(
        'Operation completed successfully on box: $boxName',
        name: 'HiveBoxManager.withBox',
      );

      return Result.success(result);
    } catch (e, stackTrace) {
      developer.log(
        'Error during operation on box: $boxName - $e',
        name: 'HiveBoxManager.withBox',
        error: e,
        stackTrace: stackTrace,
        level: 1000, // Severe error
      );

      return Result.error(
        StorageError(
          message: 'Failed to execute operation on box: $boxName - $e',
          code: 'HIVE_OPERATION_ERROR',
          stackTrace: stackTrace,
        ),
      );
    } finally {
      // SEMPRE fecha a box se ela não estava aberta antes (evita leak)
      if (box != null && !wasBoxAlreadyOpen) {
        try {
          await hiveManager.closeBox(boxName);
          developer.log(
            'Box closed after operation: $boxName',
            name: 'HiveBoxManager.withBox',
          );
        } catch (e, stackTrace) {
          developer.log(
            'Warning: Failed to close box: $boxName - $e',
            name: 'HiveBoxManager.withBox',
            error: e,
            stackTrace: stackTrace,
            level: 800, // Warning level
          );
          // Não propaga o erro de fechamento - já retornamos o resultado da operação
        }
      } else if (box != null && wasBoxAlreadyOpen) {
        developer.log(
          'Box was already open, not closing: $boxName',
          name: 'HiveBoxManager.withBox',
        );
      }
    }
  }

  /// Executa uma operação em múltiplas boxes simultaneamente
  ///
  /// [hiveManager] - Instância do IHiveManager
  /// [boxNames] - Lista de nomes das boxes a serem abertas
  /// [operation] - Operação assíncrona recebendo Map de boxes (nome -> box)
  ///
  /// Retorna `Result<R>` com resultado da operação ou erro
  ///
  /// Exemplo:
  /// ```dart
  /// final result = await HiveBoxManager.withMultipleBoxes(
  ///   hiveManager: hiveManager,
  ///   boxNames: ['diagnosticos', 'defensivos', 'pragas'],
  ///   operation: (boxes) async {
  ///     final diagnosticoBox = boxes['diagnosticos'] as Box<DiagnosticoHive>;
  ///     final defensivoBox = boxes['defensivos'] as Box<FitossanitarioHive>;
  ///     // ... realizar operação com múltiplas boxes
  ///   },
  /// );
  /// ```
  static Future<Result<R>> withMultipleBoxes<R>({
    required IHiveManager hiveManager,
    required List<String> boxNames,
    required Future<R> Function(Map<String, Box<dynamic>>) operation,
  }) async {
    final Map<String, Box<dynamic>> boxes = {};
    final Map<String, bool> wasOpenBefore = {};

    try {
      developer.log(
        'Opening multiple boxes: ${boxNames.join(", ")}',
        name: 'HiveBoxManager.withMultipleBoxes',
      );

      // Abre todas as boxes
      for (final boxName in boxNames) {
        wasOpenBefore[boxName] = hiveManager.isBoxOpen(boxName);

        final boxResult = await hiveManager.getBox<dynamic>(boxName);

        if (boxResult.isError) {
          developer.log(
            'Failed to open box: $boxName - ${boxResult.error}',
            name: 'HiveBoxManager.withMultipleBoxes',
            level: 900,
          );
          return Result.error(boxResult.error!);
        }

        boxes[boxName] = boxResult.data!;
      }

      // Executa a operação com todas as boxes abertas
      final result = await operation(boxes);

      developer.log(
        'Multi-box operation completed successfully',
        name: 'HiveBoxManager.withMultipleBoxes',
      );

      return Result.success(result);
    } catch (e, stackTrace) {
      developer.log(
        'Error during multi-box operation - $e',
        name: 'HiveBoxManager.withMultipleBoxes',
        error: e,
        stackTrace: stackTrace,
        level: 1000,
      );

      return Result.error(
        StorageError(
          message: 'Failed to execute multi-box operation - $e',
          code: 'HIVE_MULTI_BOX_ERROR',
          stackTrace: stackTrace,
        ),
      );
    } finally {
      // SEMPRE fecha as boxes que não estavam abertas antes
      // Fecha APENAS boxes que foram abertas com sucesso (estão no Map boxes)
      final List<String> failedToClose = [];

      for (final boxName in boxes.keys) {
        if (!(wasOpenBefore[boxName] ?? false)) {
          try {
            await hiveManager.closeBox(boxName);
            developer.log(
              'Box closed: $boxName',
              name: 'HiveBoxManager.withMultipleBoxes',
            );
          } catch (e, stackTrace) {
            failedToClose.add(boxName);
            developer.log(
              'Warning: Failed to close box: $boxName - $e',
              name: 'HiveBoxManager.withMultipleBoxes',
              error: e,
              stackTrace: stackTrace,
              level: 800,
            );
          }
        }
      }

      if (failedToClose.isNotEmpty) {
        developer.log(
          'Some boxes failed to close: ${failedToClose.join(", ")}',
          name: 'HiveBoxManager.withMultipleBoxes',
          level: 800,
        );
      }
    }
  }

  /// Conveniência: executa operação read-only em uma box
  ///
  /// Idêntico ao withBox, mas semanticamente indica operação de leitura
  static Future<Result<R>> readBox<T, R>({
    required IHiveManager hiveManager,
    required String boxName,
    required Future<R> Function(Box<T>) operation,
  }) {
    return withBox<T, R>(
      hiveManager: hiveManager,
      boxName: boxName,
      operation: operation,
    );
  }

  /// Conveniência: executa operação write em uma box
  ///
  /// Idêntico ao withBox, mas semanticamente indica operação de escrita
  static Future<Result<R>> writeBox<T, R>({
    required IHiveManager hiveManager,
    required String boxName,
    required Future<R> Function(Box<T>) operation,
  }) {
    return withBox<T, R>(
      hiveManager: hiveManager,
      boxName: boxName,
      operation: operation,
    );
  }
}

import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../../models/license_model.dart';
import '../../domain/services/i_box_registry_service.dart';
import '../../shared/utils/failure.dart';
import '../models/box_configuration.dart';

/// Implementação do serviço de registro de boxes
/// Gerencia o ciclo de vida das boxes e garante isolamento entre apps
class BoxRegistryService implements IBoxRegistryService {
  /// Registry de configurações de boxes
  final Map<String, BoxConfiguration> _boxConfigurations = {};

  /// Registry de boxes abertas
  final Map<String, Box<dynamic>> _openBoxes = {};

  /// Flag de inicialização
  bool _isInitialized = false;

  @override
  Future<Either<Failure, void>> initialize() async {
    try {
      if (_isInitialized) return const Right(null);

      await Hive.initFlutter();
      _registerLicenseAdapters();

      _isInitialized = true;

      return const Right(null);
    } catch (e) {
      return Left(CacheFailure('Erro ao inicializar BoxRegistryService: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> registerBox(BoxConfiguration config) async {
    try {
      await _ensureInitialized();

      if (_boxConfigurations.containsKey(config.name)) {
        return Left(
          CacheFailure(
            'Box "${config.name}" já está registrada por app "${_boxConfigurations[config.name]!.appId}"',
          ),
        );
      }

      // Registrar adapters customizados se necessário
      if (config.customAdapters != null) {
        for (final adapter in config.customAdapters!) {
          if (!Hive.isAdapterRegistered(adapter.typeId)) {
            Hive.registerAdapter(adapter);
          }
        }
      }

      // Adicionar configuração ao registry
      _boxConfigurations[config.name] = config;

      if (kDebugMode) {
        debugPrint(
          '📝 [BoxRegistryService.registerBox] Box "${config.name}" registrada (persistent: ${config.persistent}, appId: ${config.appId})',
        );
      }

      // Se persistent, abrir automaticamente
      if (config.persistent) {
        if (kDebugMode) {
          debugPrint(
            '🔑 [BoxRegistryService.registerBox] Box "${config.name}" é persistent, abrindo automaticamente...',
          );
        }

        final boxResult = await _openBox(config);
        if (boxResult.isLeft()) {
          if (kDebugMode) {
            debugPrint(
              '❌ [BoxRegistryService.registerBox] Falha ao abrir box "${config.name}"',
            );
          }
          _boxConfigurations.remove(config.name);
          return boxResult.fold(
            (failure) => Left(failure),
            (_) => const Right(null),
          );
        }

        if (kDebugMode) {
          debugPrint(
            '✅ [BoxRegistryService.registerBox] Box "${config.name}" aberta e pronta para uso',
          );
        }
      }

      return const Right(null);
    } catch (e) {
      return Left(CacheFailure('Erro ao registrar box "${config.name}": $e'));
    }
  }

  @override
  Future<Either<Failure, Box<dynamic>>> getBox(String boxName) async {
    try {
      await _ensureInitialized();

      // 1. Verificar se box está registrada
      if (!_boxConfigurations.containsKey(boxName)) {
        return Left(CacheFailure('Box "$boxName" não está registrada'));
      }

      // 2. Verificar cache local
      if (_openBoxes.containsKey(boxName)) {
        return Right(_openBoxes[boxName]!);
      }

      // 3. ✅ Verificar se box JÁ está aberta (SEMPRE PRIMEIRO)
      //    Isso resolve race condition com outros gerenciadores
      if (Hive.isBoxOpen(boxName)) {
        final box = Hive.box<dynamic>(boxName);
        _openBoxes[boxName] = box;
        return Right(box);
      }

      // 4. Box não está aberta, verificar se devemos abrir
      final config = _boxConfigurations[boxName]!;

      if (config.persistent) {
        // Box persistente, abrir normalmente
        final boxResult = await _openBox(config);
        return boxResult.fold(
          (failure) => Left(failure),
          (box) => Right(box),
        );
      }

      // 5. Box non-persistent e não aberta
      // ✅ TOLERÂNCIA: Registrar a box mesmo que não esteja aberta
      // Ela pode ser aberta depois pelo HiveManager ou outros sistemas
      if (kDebugMode) {
        debugPrint(
          '⚠️ [BoxRegistryService.getBox] Box "$boxName" é non-persistent e não está aberta. '
          'Box será aberta externamente quando necessário.',
        );
      }
      return Left(
        CacheFailure(
          'Box "$boxName" está marcada como non-persistent e não foi aberta. '
          'Abra a box externamente com o tipo correto antes de usá-la.',
        ),
      );
    } catch (e) {
      return Left(CacheFailure('Erro ao obter box "$boxName": $e'));
    }
  }

  @override
  bool isBoxRegistered(String boxName) {
    return _boxConfigurations.containsKey(boxName);
  }

  @override
  List<String> getRegisteredBoxes() {
    return _boxConfigurations.keys.toList();
  }

  @override
  List<String> getRegisteredBoxesForApp(String appId) {
    return _boxConfigurations.entries
        .where((entry) => entry.value.appId == appId)
        .map((entry) => entry.key)
        .toList();
  }

  @override
  Future<Either<Failure, void>> unregisterBox(String boxName) async {
    try {
      if (!_boxConfigurations.containsKey(boxName)) {
        return Left(CacheFailure('Box "$boxName" não está registrada'));
      }
      _boxConfigurations.remove(boxName);

      return const Right(null);
    } catch (e) {
      return Left(CacheFailure('Erro ao desregistrar box "$boxName": $e'));
    }
  }

  @override
  Future<Either<Failure, void>> closeBox(String boxName) async {
    try {
      if (!_boxConfigurations.containsKey(boxName)) {
        return Left(CacheFailure('Box "$boxName" não está registrada'));
      }
      if (_openBoxes.containsKey(boxName)) {
        await _openBoxes[boxName]!.close();
        _openBoxes.remove(boxName);
      }
      _boxConfigurations.remove(boxName);

      return const Right(null);
    } catch (e) {
      return Left(CacheFailure('Erro ao fechar box "$boxName": $e'));
    }
  }

  @override
  Future<Either<Failure, void>> closeBoxesForApp(String appId) async {
    try {
      final boxesToClose = getRegisteredBoxesForApp(appId);

      for (final boxName in boxesToClose) {
        final result = await closeBox(boxName);
        if (result.isLeft()) {
          if (kDebugMode) {
            debugPrint('Error closing box "$boxName" for app "$appId"');
          }
        }
      }

      return const Right(null);
    } catch (e) {
      return Left(CacheFailure('Erro ao fechar boxes do app "$appId": $e'));
    }
  }

  @override
  bool canAppAccessBox(String boxName, String requestingAppId) {
    final config = _boxConfigurations[boxName];
    if (config == null) return false;
    return config.appId == requestingAppId;
  }

  @override
  Future<Either<Failure, void>> dispose() async {
    try {
      final boxNames = _openBoxes.keys.toList();
      for (final boxName in boxNames) {
        await _openBoxes[boxName]!.close();
      }
      _openBoxes.clear();
      _boxConfigurations.clear();
      _isInitialized = false;

      return const Right(null);
    } catch (e) {
      return Left(
        CacheFailure('Erro ao fazer dispose do BoxRegistryService: $e'),
      );
    }
  }

  /// Abre uma box com base na configuração
  /// IMPORTANTE: Verifica se box já está aberta para evitar conflito de tipos
  /// (ex: evita reabrir `Box<ComentarioHive>` como `Box<dynamic>`)
  Future<Either<Failure, Box<dynamic>>> _openBox(
    BoxConfiguration config,
  ) async {
    try {
      Box<dynamic> box;

      // 🔍 VERIFICAR SE BOX JÁ ESTÁ ABERTA
      // Se já está aberta (ex: por HiveAdapterRegistry ou HiveManager),
      // usar instância existente ao invés de tentar reabrir
      if (Hive.isBoxOpen(config.name)) {
        if (kDebugMode) {
          debugPrint(
            '♻️ [BoxRegistryService._openBox] Box "${config.name}" já está aberta. '
            'Usando instância existente para evitar conflito de tipos.',
          );
        }
        box = Hive.box<dynamic>(config.name);
        _openBoxes[config.name] = box;
        return Right(box);
      }

      // Box não está aberta, abrir normalmente
      if (kDebugMode) {
        debugPrint(
          '🔓 [BoxRegistryService._openBox] Abrindo box "${config.name}" (persistent: ${config.persistent})...',
        );
      }

      if (config.encryption != null) {
        box = await Hive.openBox(
          config.name,
          encryptionCipher: HiveAesCipher(config.encryption!.key),
          path: config.customPath,
        );
      } else {
        box = await Hive.openBox(config.name, path: config.customPath);
      }

      _openBoxes[config.name] = box;

      if (kDebugMode) {
        debugPrint(
          '✅ [BoxRegistryService._openBox] Box "${config.name}" aberta com sucesso (${box.length} items)',
        );
      }

      return Right(box);
    } catch (e) {
      return Left(CacheFailure('Erro ao abrir box "${config.name}": $e'));
    }
  }

  /// Garante que o serviço está inicializado
  Future<void> _ensureInitialized() async {
    if (!_isInitialized) {
      final result = await initialize();
      if (result.isLeft()) {
        throw Exception('Falha ao inicializar BoxRegistryService');
      }
    }
  }

  /// Obtém informações de debug sobre boxes registradas
  Map<String, dynamic> getDebugInfo() {
    return {
      'initialized': _isInitialized,
      'registered_boxes': _boxConfigurations.length,
      'open_boxes': _openBoxes.length,
      'boxes_by_app': _groupBoxesByApp(),
      'box_details': _boxConfigurations.map(
        (name, config) => MapEntry(name, {
          'appId': config.appId,
          'persistent': config.persistent,
          'encrypted': config.encryption != null,
          'version': config.version,
          'is_open': _openBoxes.containsKey(name),
        }),
      ),
    };
  }

  /// Agrupa boxes por app para debug
  Map<String, List<String>> _groupBoxesByApp() {
    final grouped = <String, List<String>>{};

    for (final entry in _boxConfigurations.entries) {
      final appId = entry.value.appId;
      if (!grouped.containsKey(appId)) {
        grouped[appId] = [];
      }
      grouped[appId]!.add(entry.key);
    }

    return grouped;
  }

  /// Register License Model adapters for Hive
  void _registerLicenseAdapters() {
    if (!Hive.isAdapterRegistered(10)) {
      Hive.registerAdapter(LicenseModelAdapter());
    }
    if (!Hive.isAdapterRegistered(11)) {
      Hive.registerAdapter(LicenseTypeAdapter());
    }
  }
}

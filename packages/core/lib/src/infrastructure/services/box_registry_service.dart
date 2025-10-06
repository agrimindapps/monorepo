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
  final Map<String, Box> _openBoxes = {};

  /// Flag de inicialização
  bool _isInitialized = false;

  @override
  Future<Either<Failure, void>> initialize() async {
    try {
      if (_isInitialized) return const Right(null);

      await Hive.initFlutter();

      // Register License Model adapters
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

      // Verifica se já existe box com este nome
      if (_boxConfigurations.containsKey(config.name)) {
        return Left(
          CacheFailure(
            'Box "${config.name}" já está registrada por app "${_boxConfigurations[config.name]!.appId}"',
          ),
        );
      }

      // Registra adapters customizados se houver
      if (config.customAdapters != null) {
        for (final adapter in config.customAdapters!) {
          if (!Hive.isAdapterRegistered(adapter.typeId)) {
            Hive.registerAdapter(adapter);
          }
        }
      }

      // Armazena configuração
      _boxConfigurations[config.name] = config;

      // Abre a box imediatamente se for persistente
      if (config.persistent) {
        final boxResult = await _openBox(config);
        if (boxResult.isLeft()) {
          // Remove do registry se falhou ao abrir
          _boxConfigurations.remove(config.name);
          return boxResult.fold(
            (failure) => Left(failure),
            (_) => const Right(null),
          );
        }
      }

      return const Right(null);
    } catch (e) {
      return Left(CacheFailure('Erro ao registrar box "${config.name}": $e'));
    }
  }

  @override
  Future<Either<Failure, Box>> getBox(String boxName) async {
    try {
      await _ensureInitialized();

      // Verifica se a box está registrada
      if (!_boxConfigurations.containsKey(boxName)) {
        return Left(CacheFailure('Box "$boxName" não está registrada'));
      }

      // Se já está aberta, retorna
      if (_openBoxes.containsKey(boxName)) {
        return Right(_openBoxes[boxName]!);
      }

      // Abre a box
      final config = _boxConfigurations[boxName]!;
      final boxResult = await _openBox(config);

      return boxResult.fold((failure) => Left(failure), (box) => Right(box));
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

      // Remove do registry (mas não fecha a box)
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

      // Fecha a box se estiver aberta
      if (_openBoxes.containsKey(boxName)) {
        await _openBoxes[boxName]!.close();
        _openBoxes.remove(boxName);
      }

      // Remove do registry
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
          // Log erro mas continua fechando outras boxes
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

    // Por agora, apenas o app proprietário pode acessar a box
    // No futuro, pode-se implementar sistema de permissões mais sofisticado
    return config.appId == requestingAppId;
  }

  @override
  Future<Either<Failure, void>> dispose() async {
    try {
      // Fecha todas as boxes abertas
      final boxNames = _openBoxes.keys.toList();
      for (final boxName in boxNames) {
        await _openBoxes[boxName]!.close();
      }

      // Limpa registries
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
  Future<Either<Failure, Box>> _openBox(BoxConfiguration config) async {
    try {
      Box box;

      if (config.encryption != null) {
        // Box criptografada
        box = await Hive.openBox(
          config.name,
          encryptionCipher: HiveAesCipher(config.encryption!.key),
          path: config.customPath,
        );
      } else {
        // Box normal
        box = await Hive.openBox(config.name, path: config.customPath);
      }

      _openBoxes[config.name] = box;
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
    // Register LicenseModel adapter (typeId: 10)
    if (!Hive.isAdapterRegistered(10)) {
      Hive.registerAdapter(LicenseModelAdapter());
    }

    // Register LicenseType adapter (typeId: 11)
    if (!Hive.isAdapterRegistered(11)) {
      Hive.registerAdapter(LicenseTypeAdapter());
    }
  }
}

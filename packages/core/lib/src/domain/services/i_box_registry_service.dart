import 'package:dartz/dartz.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../infrastructure/models/box_configuration.dart';
import '../../shared/utils/failure.dart';

/// Interface para serviço de registro de boxes do Hive
/// Permite que cada app registre suas próprias boxes dinamicamente
/// sem contaminar o core package com conhecimento específico dos apps
abstract class IBoxRegistryService {
  /// Registra uma nova box no sistema
  /// [config] - Configuração da box incluindo nome, app proprietário e adapters
  Future<Either<Failure, void>> registerBox(BoxConfiguration config);

  /// Obtém uma box já registrada
  /// [boxName] - Nome da box a ser obtida
  /// Retorna erro se a box não estiver registrada
  Future<Either<Failure, Box<dynamic>>> getBox(String boxName);

  /// Verifica se uma box está registrada
  /// [boxName] - Nome da box a verificar
  bool isBoxRegistered(String boxName);

  /// Obtém lista de todas as boxes registradas
  /// Retorna apenas os nomes das boxes, não suas instâncias
  List<String> getRegisteredBoxes();

  /// Obtém lista de boxes registradas por um app específico
  /// [appId] - Identificador do app
  List<String> getRegisteredBoxesForApp(String appId);

  /// Remove registro de uma box (não fecha a box)
  /// [boxName] - Nome da box a ser removida do registro
  /// Usado principalmente para limpeza durante testes
  Future<Either<Failure, void>> unregisterBox(String boxName);

  /// Fecha uma box e remove do registro
  /// [boxName] - Nome da box a ser fechada
  Future<Either<Failure, void>> closeBox(String boxName);

  /// Fecha todas as boxes registradas por um app
  /// [appId] - Identificador do app
  /// Útil durante cleanup de app específico
  Future<Either<Failure, void>> closeBoxesForApp(String appId);

  /// Verifica se um app tem permissão para acessar uma box
  /// [boxName] - Nome da box
  /// [requestingAppId] - ID do app que está tentando acessar
  /// Previne acesso cross-app não autorizado
  bool canAppAccessBox(String boxName, String requestingAppId);

  /// Inicializa o serviço de registro
  /// Deve ser chamado antes de registrar qualquer box
  Future<Either<Failure, void>> initialize();

  /// Libera recursos e fecha todas as boxes
  /// Chamado durante shutdown da aplicação
  Future<Either<Failure, void>> dispose();
}

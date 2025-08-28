import 'dart:convert';

import 'package:core/core.dart';
import 'package:dartz/dartz.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

import '../models/backup_model.dart';

/// Interface do repositório de backup
abstract class IBackupRepository {
  Future<Either<Failure, BackupResult>> uploadBackup(BackupModel backup);
  Future<Either<Failure, List<BackupInfo>>> listBackups(String userId);
  Future<Either<Failure, BackupModel>> downloadBackup(String backupId);
  Future<Either<Failure, void>> deleteBackup(String backupId);
  Future<Either<Failure, void>> deleteOldBackups(String userId, int maxBackups);
}

/// Implementação do repositório de backup usando Firebase Storage
@LazySingleton(as: IBackupRepository)
class BackupRepository implements IBackupRepository {
  final FirebaseStorage _storage;
  final IAuthRepository _authRepository;
  
  static const String _backupsPath = 'user_backups';
  static const int _maxRetries = 3;
  static const int _timeoutSeconds = 60;

  BackupRepository({
    required FirebaseStorage storage,
    required IAuthRepository authRepository,
  }) : _storage = storage,
       _authRepository = authRepository;

  @override
  Future<Either<Failure, BackupResult>> uploadBackup(BackupModel backup) async {
    try {
      final user = await _getCurrentUser();
      if (user == null) {
        return const Left(AuthFailure('Usuário não autenticado'));
      }

      // Converte backup para bytes
      final jsonString = backup.toJsonString();
      final bytes = Uint8List.fromList(utf8.encode(jsonString));

      // Define o caminho no Firebase Storage
      final path = '$_backupsPath/${user.id}/${backup.fileName}';
      final ref = _storage.ref().child(path);

      // Metadata do arquivo
      final metadata = SettableMetadata(
        contentType: 'application/json',
        customMetadata: {
          'userId': user.id,
          'timestamp': backup.timestamp.toIso8601String(),
          'version': backup.version,
          'plantsCount': backup.metadata.plantsCount.toString(),
          'tasksCount': backup.metadata.tasksCount.toString(),
          'spacesCount': backup.metadata.spacesCount.toString(),
        },
      );

      // Upload com retry logic
      UploadTask? uploadTask;
      for (int attempt = 0; attempt < _maxRetries; attempt++) {
        try {
          uploadTask = ref.putData(bytes, metadata);
          
          // Timeout para o upload
          final result = await uploadTask.timeout(
            const Duration(seconds: _timeoutSeconds),
          );

          if (result.state == TaskState.success) {
            return Right(BackupResult.success(
              backupId: ref.name,
              fileName: backup.fileName,
              sizeInBytes: backup.sizeInBytes,
            ));
          }
        } catch (e) {
          if (attempt == _maxRetries - 1) rethrow;
          await Future<void>.delayed(Duration(seconds: attempt + 1));
        }
      }

      return const Left(NetworkFailure('Falha no upload após $_maxRetries tentativas'));
    } catch (e) {
      return Left(_handleError(e));
    }
  }

  @override
  Future<Either<Failure, List<BackupInfo>>> listBackups(String userId) async {
    try {
      final user = await _getCurrentUser();
      if (user == null) {
        return const Left(AuthFailure('Usuário não autenticado'));
      }

      final path = '$_backupsPath/$userId/';
      final ref = _storage.ref().child(path);

      final result = await ref.listAll();
      final backupInfos = <BackupInfo>[];

      // Processa cada arquivo de backup
      for (final item in result.items) {
        try {
          final metadata = await item.getMetadata();
          final downloadUrl = await item.getDownloadURL();

          // Extrai informações dos metadados
          final customMeta = metadata.customMetadata ?? {};
          final timestampStr = customMeta['timestamp'];
          final plantsCount = int.tryParse(customMeta['plantsCount'] ?? '0') ?? 0;
          final tasksCount = int.tryParse(customMeta['tasksCount'] ?? '0') ?? 0;
          final spacesCount = int.tryParse(customMeta['spacesCount'] ?? '0') ?? 0;

          if (timestampStr != null) {
            final timestamp = DateTime.parse(timestampStr);
            
            final backupInfo = BackupInfo(
              id: item.name,
              fileName: item.name,
              timestamp: timestamp,
              metadata: BackupMetadata(
                plantsCount: plantsCount,
                tasksCount: tasksCount,
                spacesCount: spacesCount,
                appVersion: customMeta['version'] ?? '1.0',
                platform: customMeta['platform'] ?? 'unknown',
              ),
              downloadUrl: downloadUrl,
              sizeInBytes: metadata.size ?? 0,
            );

            backupInfos.add(backupInfo);
          }
        } catch (e) {
          // Log erro para item específico, mas continua processando outros
          debugPrint('Erro ao processar backup ${item.name}: $e');
        }
      }

      // Ordena por data (mais recente primeiro)
      backupInfos.sort((a, b) => b.timestamp.compareTo(a.timestamp));

      return Right(backupInfos);
    } catch (e) {
      return Left(_handleError(e));
    }
  }

  @override
  Future<Either<Failure, BackupModel>> downloadBackup(String backupId) async {
    try {
      final user = await _getCurrentUser();
      if (user == null) {
        return const Left(AuthFailure('Usuário não autenticado'));
      }

      final path = '$_backupsPath/${user.id}/$backupId';
      final ref = _storage.ref().child(path);

      // Download com retry logic
      for (int attempt = 0; attempt < _maxRetries; attempt++) {
        try {
          final bytes = await ref.getData().timeout(
            const Duration(seconds: _timeoutSeconds),
          );

          if (bytes != null) {
            final jsonString = utf8.decode(bytes);
            final backup = BackupModel.fromJsonString(jsonString);
            return Right(backup);
          }
        } catch (e) {
          if (attempt == _maxRetries - 1) rethrow;
          await Future<void>.delayed(Duration(seconds: attempt + 1));
        }
      }

      return const Left(NetworkFailure('Falha no download após $_maxRetries tentativas'));
    } catch (e) {
      return Left(_handleError(e));
    }
  }

  @override
  Future<Either<Failure, void>> deleteBackup(String backupId) async {
    try {
      final user = await _getCurrentUser();
      if (user == null) {
        return const Left(AuthFailure('Usuário não autenticado'));
      }

      final path = '$_backupsPath/${user.id}/$backupId';
      final ref = _storage.ref().child(path);

      await ref.delete();
      return const Right(null);
    } catch (e) {
      return Left(_handleError(e));
    }
  }

  @override
  Future<Either<Failure, void>> deleteOldBackups(String userId, int maxBackups) async {
    try {
      final backupsResult = await listBackups(userId);
      
      return await backupsResult.fold(
        (failure) async => Left(failure),
        (backups) async {
          if (backups.length <= maxBackups) {
            return const Right(null);
          }

          // Remove backups mais antigos
          final backupsToDelete = backups.skip(maxBackups);
          
          for (final backup in backupsToDelete) {
            await deleteBackup(backup.id);
          }

          return const Right(null);
        },
      );
    } catch (e) {
      return Left(_handleError(e));
    }
  }

  /// Obtém o usuário atual autenticado
  Future<UserEntity?> _getCurrentUser() async {
    try {
      return await _authRepository.currentUser.first;
    } catch (e) {
      return null;
    }
  }

  /// Trata erros e converte para tipos apropriados de Failure
  Failure _handleError(dynamic error) {
    if (error is FirebaseException) {
      switch (error.code) {
        case 'storage/unauthorized':
          return const AuthFailure('Acesso negado ao storage');
        case 'storage/canceled':
          return const NetworkFailure('Upload cancelado');
        case 'storage/quota-exceeded':
          return const StorageFailure('Cota de armazenamento excedida');
        case 'storage/invalid-format':
          return const ValidationFailure('Formato de arquivo inválido');
        case 'storage/object-not-found':
          return const NotFoundFailure('Backup não encontrado');
        default:
          return NetworkFailure('Erro no Firebase Storage: ${error.message}');
      }
    }

    if (error.toString().contains('TimeoutException') || 
        error.toString().contains('timeout')) {
      return const NetworkFailure('Timeout na operação de backup');
    }

    return UnknownFailure('Erro inesperado: ${error.toString()}');
  }
}

/// Failure específico para operações de storage
class StorageFailure extends Failure {
  const StorageFailure(String message) : super(message: message);
  
  @override
  List<Object?> get props => [message];
}
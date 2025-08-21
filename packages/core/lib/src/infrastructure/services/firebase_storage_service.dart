import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:dartz/dartz.dart';
import 'dart:developer' as developer;
import '../../domain/repositories/i_storage_repository.dart';
import '../../shared/utils/failure.dart';

/// Implementação concreta do repositório de storage usando Firebase Storage
class FirebaseStorageService implements IStorageRepository {
  final FirebaseStorage _storage;

  FirebaseStorageService({
    FirebaseStorage? storage,
  }) : _storage = storage ?? FirebaseStorage.instance;

  @override
  Future<Either<Failure, String>> uploadFile({
    required File file,
    required String path,
    String? contentType,
    Map<String, String>? metadata,
    Function(double)? onProgress,
  }) async {
    try {
      final ref = _storage.ref().child(path);
      
      // Configurar metadados se fornecidos
      SettableMetadata? settableMetadata;
      if (contentType != null || metadata != null) {
        settableMetadata = SettableMetadata(
          contentType: contentType,
          customMetadata: metadata,
        );
      }

      final uploadTask = settableMetadata != null
          ? ref.putFile(file, settableMetadata)
          : ref.putFile(file);

      // Monitorar progresso se callback fornecido
      if (onProgress != null) {
        uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
          final progress = snapshot.bytesTransferred / snapshot.totalBytes;
          onProgress(progress);
        });
      }

      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();

      return Right(downloadUrl);
    } on FirebaseException catch (e) {
      return Left(FirebaseFailure(_mapStorageError(e)));
    } catch (e) {
      return Left(ServerFailure('Erro no upload: $e'));
    }
  }

  @override
  Future<Either<Failure, String>> uploadImage({
    required File imageFile,
    required String path,
    int? maxWidth,
    int? maxHeight,
    int? quality,
    Function(double)? onProgress,
  }) async {
    try {
      File processedImage = imageFile;

      // TODO: Implementar redimensionamento de imagem se necessário
      // Requer package como image ou flutter_image_compress
      
      return uploadFile(
        file: processedImage,
        path: path,
        contentType: 'image/jpeg',
        metadata: {
          'original_name': imageFile.path.split('/').last,
          'uploaded_at': DateTime.now().toIso8601String(),
          if (maxWidth != null) 'max_width': maxWidth.toString(),
          if (maxHeight != null) 'max_height': maxHeight.toString(),
          if (quality != null) 'quality': quality.toString(),
        },
        onProgress: onProgress,
      );
    } catch (e) {
      return Left(ServerFailure('Erro ao processar imagem: $e'));
    }
  }

  @override
  Future<Either<Failure, File>> downloadFile({
    required String url,
    required String localPath,
    Function(double)? onProgress,
  }) async {
    try {
      final ref = _storage.refFromURL(url);
      final file = File(localPath);

      // Criar diretório se não existir
      await file.parent.create(recursive: true);

      // Download com monitoramento de progresso
      final downloadTask = ref.writeToFile(file);

      if (onProgress != null) {
        downloadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
          final progress = snapshot.bytesTransferred / snapshot.totalBytes;
          onProgress(progress);
        });
      }

      await downloadTask;
      return Right(file);
    } on FirebaseException catch (e) {
      return Left(FirebaseFailure(_mapStorageError(e)));
    } catch (e) {
      return Left(ServerFailure('Erro no download: $e'));
    }
  }

  @override
  Future<Either<Failure, String>> getDownloadUrl({
    required String path,
  }) async {
    try {
      final ref = _storage.ref().child(path);
      final url = await ref.getDownloadURL();
      return Right(url);
    } on FirebaseException catch (e) {
      return Left(FirebaseFailure(_mapStorageError(e)));
    } catch (e) {
      return Left(ServerFailure('Erro ao obter URL: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteFile({
    required String path,
  }) async {
    try {
      final ref = _storage.ref().child(path);
      await ref.delete();
      return const Right(null);
    } on FirebaseException catch (e) {
      return Left(FirebaseFailure(_mapStorageError(e)));
    } catch (e) {
      return Left(ServerFailure('Erro ao deletar arquivo: $e'));
    }
  }

  @override
  Future<Either<Failure, List<StorageItem>>> listFiles({
    required String path,
    int? maxResults,
  }) async {
    try {
      final ref = _storage.ref().child(path);
      final result = await ref.listAll();

      final items = <StorageItem>[];

      for (final item in result.items) {
        try {
          final metadata = await item.getMetadata();
          items.add(StorageItem(
            name: item.name,
            path: path,
            fullPath: item.fullPath,
            bucket: item.bucket,
            size: metadata.size,
            contentType: metadata.contentType,
            timeCreated: metadata.timeCreated,
            updated: metadata.updated,
            metadata: metadata.customMetadata,
          ));
        } catch (e) {
          // Ignorar itens com erro de metadados
          items.add(StorageItem(
            name: item.name,
            path: path,
            fullPath: item.fullPath,
            bucket: item.bucket,
          ));
        }
      }

      // Aplicar limite se especificado
      if (maxResults != null && items.length > maxResults) {
        return Right(items.take(maxResults).toList());
      }

      return Right(items);
    } on FirebaseException catch (e) {
      return Left(FirebaseFailure(_mapStorageError(e)));
    } catch (e) {
      return Left(ServerFailure('Erro ao listar arquivos: $e'));
    }
  }

  @override
  Future<Either<Failure, bool>> fileExists({
    required String path,
  }) async {
    try {
      final ref = _storage.ref().child(path);
      await ref.getMetadata();
      return const Right(true);
    } on FirebaseException catch (e) {
      if (e.code == 'object-not-found') {
        return const Right(false);
      }
      return Left(FirebaseFailure(_mapStorageError(e)));
    } catch (e) {
      return Left(ServerFailure('Erro ao verificar arquivo: $e'));
    }
  }

  @override
  Future<Either<Failure, StorageMetadata>> getMetadata({
    required String path,
  }) async {
    try {
      final ref = _storage.ref().child(path);
      final metadata = await ref.getMetadata();

      return Right(StorageMetadata(
        bucket: metadata.bucket ?? '',
        fullPath: metadata.fullPath,
        name: metadata.name,
        size: metadata.size,
        contentType: metadata.contentType,
        timeCreated: metadata.timeCreated,
        updated: metadata.updated,
        md5Hash: metadata.md5Hash,
        cacheControl: metadata.cacheControl,
        contentDisposition: metadata.contentDisposition,
        contentEncoding: metadata.contentEncoding,
        contentLanguage: metadata.contentLanguage,
        customMetadata: metadata.customMetadata,
      ));
    } on FirebaseException catch (e) {
      return Left(FirebaseFailure(_mapStorageError(e)));
    } catch (e) {
      return Left(ServerFailure('Erro ao obter metadados: $e'));
    }
  }

  @override
  Future<Either<Failure, StorageMetadata>> updateMetadata({
    required String path,
    required Map<String, String> metadata,
  }) async {
    try {
      final ref = _storage.ref().child(path);
      final settableMetadata = SettableMetadata(
        customMetadata: metadata,
      );

      final updatedMetadata = await ref.updateMetadata(settableMetadata);

      return Right(StorageMetadata(
        bucket: updatedMetadata.bucket ?? '',
        fullPath: updatedMetadata.fullPath,
        name: updatedMetadata.name,
        size: updatedMetadata.size,
        contentType: updatedMetadata.contentType,
        timeCreated: updatedMetadata.timeCreated,
        updated: updatedMetadata.updated,
        md5Hash: updatedMetadata.md5Hash,
        cacheControl: updatedMetadata.cacheControl,
        contentDisposition: updatedMetadata.contentDisposition,
        contentEncoding: updatedMetadata.contentEncoding,
        contentLanguage: updatedMetadata.contentLanguage,
        customMetadata: updatedMetadata.customMetadata,
      ));
    } on FirebaseException catch (e) {
      return Left(FirebaseFailure(_mapStorageError(e)));
    } catch (e) {
      return Left(ServerFailure('Erro ao atualizar metadados: $e'));
    }
  }

  @override
  Future<Either<Failure, String>> copyFile({
    required String sourcePath,
    required String destinationPath,
  }) async {
    try {
      // Firebase Storage não tem API de cópia direta
      // Precisamos fazer download e re-upload
      final sourceRef = _storage.ref().child(sourcePath);
      final data = await sourceRef.getData();

      if (data == null) {
        return const Left(ServerFailure('Arquivo não encontrado para cópia'));
      }

      final destRef = _storage.ref().child(destinationPath);
      
      // Obter metadados originais
      final originalMetadata = await sourceRef.getMetadata();
      final settableMetadata = SettableMetadata(
        contentType: originalMetadata.contentType,
        customMetadata: {
          ...?originalMetadata.customMetadata,
          'copied_from': sourcePath,
          'copied_at': DateTime.now().toIso8601String(),
        },
      );

      await destRef.putData(data, settableMetadata);
      final downloadUrl = await destRef.getDownloadURL();

      return Right(downloadUrl);
    } on FirebaseException catch (e) {
      return Left(FirebaseFailure(_mapStorageError(e)));
    } catch (e) {
      return Left(ServerFailure('Erro ao copiar arquivo: $e'));
    }
  }

  @override
  Future<Either<Failure, String>> moveFile({
    required String sourcePath,
    required String destinationPath,
  }) async {
    try {
      // Copiar arquivo
      final copyResult = await copyFile(
        sourcePath: sourcePath,
        destinationPath: destinationPath,
      );

      return copyResult.fold(
        (failure) => Left(failure),
        (url) async {
          // Deletar arquivo original após cópia bem-sucedida
          final deleteResult = await deleteFile(path: sourcePath);
          return deleteResult.fold(
            (failure) => Left(failure),
            (_) => Right(url),
          );
        },
      );
    } catch (e) {
      return Left(ServerFailure('Erro ao mover arquivo: $e'));
    }
  }

  @override
  Future<Either<Failure, StorageImageUploadResult>> uploadImageWithVariants({
    required File imageFile,
    required String basePath,
    List<ImageVariant>? variants,
    Function(double)? onProgress,
  }) async {
    try {
      // Upload da imagem original
      final originalResult = await uploadImage(
        imageFile: imageFile,
        path: basePath,
        onProgress: onProgress != null ? (p) => onProgress(p * 0.5) : null,
      );

      return originalResult.fold(
        (failure) => Left(failure),
        (originalUrl) async {
          final variantUrls = <String, String>{};

          // Upload das variantes se especificadas
          if (variants != null) {
            for (int i = 0; i < variants.length; i++) {
              final variant = variants[i];
              
              // TODO: Implementar redimensionamento para cada variante
              // Por enquanto, apenas fazemos upload da imagem original
              final variantPath = basePath.replaceAll(
                basePath.split('/').last,
                '${basePath.split('/').last.split('.').first}${variant.suffix}.${basePath.split('/').last.split('.').last}',
              );

              final variantResult = await uploadImage(
                imageFile: imageFile, // TODO: Usar imagem redimensionada
                path: variantPath,
                onProgress: onProgress != null 
                    ? (p) => onProgress(0.5 + (p * 0.5 * (i + 1) / variants.length))
                    : null,
              );

              variantResult.fold(
                (failure) {
                  // Ignorar falhas de variantes por enquanto
                  developer.log('Erro ao fazer upload de variante ${variant.suffix}: $failure', name: 'FirebaseStorage');
                },
                (variantUrl) {
                  variantUrls[variant.suffix] = variantUrl;
                },
              );
            }
          }

          return Right(StorageImageUploadResult(
            originalUrl: originalUrl,
            variants: variantUrls,
          ));
        },
      );
    } catch (e) {
      return Left(ServerFailure('Erro ao fazer upload com variantes: $e'));
    }
  }

  /// Mapeia erros do Firebase Storage para mensagens user-friendly
  String _mapStorageError(FirebaseException e) {
    switch (e.code) {
      case 'object-not-found':
        return 'Arquivo não encontrado.';
      case 'bucket-not-found':
        return 'Local de armazenamento não encontrado.';
      case 'project-not-found':
        return 'Projeto não encontrado.';
      case 'quota-exceeded':
        return 'Cota de armazenamento excedida.';
      case 'unauthenticated':
        return 'Usuário não autenticado.';
      case 'unauthorized':
        return 'Sem permissão para esta operação.';
      case 'retry-limit-exceeded':
        return 'Limite de tentativas excedido. Tente novamente.';
      case 'invalid-checksum':
        return 'Arquivo corrompido durante o upload.';
      case 'canceled':
        return 'Operação cancelada.';
      case 'invalid-event-name':
        return 'Nome de evento inválido.';
      case 'invalid-url':
        return 'URL inválida.';
      case 'invalid-argument':
        return 'Argumento inválido.';
      case 'no-default-bucket':
        return 'Bucket padrão não configurado.';
      case 'cannot-slice-blob':
        return 'Erro ao processar arquivo.';
      case 'server-file-wrong-size':
        return 'Tamanho do arquivo incorreto.';
      default:
        return e.message ?? 'Erro de armazenamento desconhecido.';
    }
  }
}
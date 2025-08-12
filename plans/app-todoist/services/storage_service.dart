// services/storage_service.dart

// Dart imports:
import 'dart:io';

// Package imports:
import 'package:firebase_storage/firebase_storage.dart';

// Project imports:
import '../constants/error_messages.dart';
import '../services/firebase_service.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseService.storage;

  // Upload de arquivo
  Future<String> uploadFile(File file, String path) async {
    try {
      final ref = _storage.ref().child(path);
      final uploadTask = await ref.putFile(file);
      return await uploadTask.ref.getDownloadURL();
    } catch (e) {
      throw Exception(ErrorMessages.formatError(ErrorMessages.fileUploadError, e));
    }
  }

  // Upload de anexo de tarefa
  Future<String> uploadTaskAttachment(File file, String taskId) async {
    final fileName = file.path.split('/').last;
    final path = 'tasks/$taskId/attachments/$fileName';
    return await uploadFile(file, path);
  }

  // Download de arquivo
  Future<void> downloadFile(String url, String localPath) async {
    try {
      final ref = _storage.refFromURL(url);
      final file = File(localPath);
      await ref.writeToFile(file);
    } catch (e) {
      throw Exception(ErrorMessages.formatError(ErrorMessages.fileDownloadError, e));
    }
  }

  // Deletar arquivo
  Future<void> deleteFile(String url) async {
    try {
      final ref = _storage.refFromURL(url);
      await ref.delete();
    } catch (e) {
      throw Exception(ErrorMessages.formatError(ErrorMessages.fileDeleteError, e));
    }
  }
}

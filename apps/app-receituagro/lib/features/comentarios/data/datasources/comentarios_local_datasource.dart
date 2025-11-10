import 'dart:convert';
import 'package:core/core.dart' hide Column;
import 'package:flutter/foundation.dart';

import '../comentario_model.dart';

/// Local datasource for comentarios using Hive
/// Follows app-plantis local datasource pattern (Gold Standard 10/10)
abstract class ComentariosLocalDatasource {
  Future<List<ComentarioModel>> getComentarios();
  Future<ComentarioModel?> getComentarioById(String id);
  Future<void> addComentario(ComentarioModel comentario);
  Future<void> updateComentario(ComentarioModel comentario);
  Future<void> deleteComentario(String id);
  Future<List<ComentarioModel>> getComentariosByContext(String pkIdentificador);
  Future<List<ComentarioModel>> getComentariosByTool(String ferramenta);
  Future<List<ComentarioModel>> searchComentarios(String query);
  Future<void> clearCache();
}

@LazySingleton(as: ComentariosLocalDatasource)
class ComentariosLocalDatasourceImpl implements ComentariosLocalDatasource {
  static const String _boxName = 'receituagro_comentarios';
  final IHiveManager _hiveManager;
  Box<dynamic>? _box;
  List<ComentarioModel>? _cachedComentarios;
  DateTime? _cacheTimestamp;
  static const Duration _cacheValidity = Duration(minutes: 5);

  ComentariosLocalDatasourceImpl(this._hiveManager);

  Future<Box<dynamic>> get box async {
    if (_box != null) return _box!;
    final result = await _hiveManager.getBox<dynamic>(_boxName);
    if (result.isFailure) {
      throw Exception('Failed to open Hive box: ${result.error?.message}');
    }
    _box = result.data;
    return _box!;
  }

  @override
  Future<List<ComentarioModel>> getComentarios() async {
    try {
      // Check memory cache first
      if (_cachedComentarios != null && _cacheTimestamp != null) {
        final now = DateTime.now();
        if (now.difference(_cacheTimestamp!).compareTo(_cacheValidity) < 0) {
          return _cachedComentarios!;
        }
      }

      final hiveBox = await box;
      final comentarios = <ComentarioModel>[];

      for (final key in hiveBox.keys) {
        try {
          final comentarioData = hiveBox.get(key);
          if (comentarioData != null) {
            Map<String, dynamic> comentarioJson;

            // Support both String (new format) and Map (old format)
            if (comentarioData is String) {
              comentarioJson = jsonDecode(comentarioData) as Map<String, dynamic>;
            } else if (comentarioData is Map) {
              comentarioJson = Map<String, dynamic>.from(comentarioData);

              // Migrate old format to new format
              if (kDebugMode) {
                debugPrint(
                  '🔄 Migrating comentario $key from Map to JSON String format',
                );
              }
              final jsonString = jsonEncode(comentarioJson);
              await hiveBox.put(key, jsonString);
            } else {
              debugPrint(
                '⚠️ Unknown comentario data format for key $key: ${comentarioData.runtimeType}',
              );
              continue;
            }

            final comentario = ComentarioModel.fromJson(comentarioJson);
            if (comentario.status) {
              // Only include active comments
              comentarios.add(comentario);
            }
          }
        } catch (e) {
          debugPrint('Found corrupted comentario data for key $key: $e');
          try {
            await hiveBox.delete(key);
            debugPrint('Removed corrupted comentario data for key: $key');
          } catch (deleteError) {
            debugPrint(
              'Failed to remove corrupted data for key $key: $deleteError',
            );
          }
          continue;
        }
      }

      // Sort by createdAt descending
      comentarios.sort(
        (a, b) => b.createdAt.compareTo(a.createdAt),
      );

      _cachedComentarios = comentarios;
      _cacheTimestamp = DateTime.now();

      return comentarios;
    } catch (e) {
      throw Exception('Erro ao buscar comentários do cache local: ${e.toString()}');
    }
  }

  @override
  Future<ComentarioModel?> getComentarioById(String id) async {
    try {
      final hiveBox = await box;
      final comentarioData = hiveBox.get(id);

      if (comentarioData == null) {
        return null;
      }

      try {
        Map<String, dynamic> comentarioJson;

        // Support both String (new format) and Map (old format)
        if (comentarioData is String) {
          comentarioJson = jsonDecode(comentarioData) as Map<String, dynamic>;
        } else if (comentarioData is Map) {
          comentarioJson = Map<String, dynamic>.from(comentarioData);

          // Migrate old format to new format
          if (kDebugMode) {
            debugPrint('🔄 Migrating comentario $id from Map to JSON String format');
          }
          final jsonString = jsonEncode(comentarioJson);
          await hiveBox.put(id, jsonString);
        } else {
          debugPrint(
            '⚠️ Unknown comentario data format for ID $id: ${comentarioData.runtimeType}',
          );
          return null;
        }

        final comentario = ComentarioModel.fromJson(comentarioJson);

        return comentario.status ? comentario : null; // Only return active comments
      } catch (corruptionError) {
        debugPrint('Found corrupted comentario data for ID $id: $corruptionError');
        try {
          await hiveBox.delete(id);
          debugPrint('Removed corrupted comentario data for ID: $id');
        } catch (deleteError) {
          debugPrint(
            'Failed to remove corrupted data for ID $id: $deleteError',
          );
        }
        return null;
      }
    } catch (e) {
      throw Exception('Erro ao buscar comentário do cache local: ${e.toString()}');
    }
  }

  @override
  Future<void> addComentario(ComentarioModel comentario) async {
    try {
      if (kDebugMode) {
        debugPrint('💾 ComentariosLocalDatasourceImpl.addComentario() - Iniciando');
        debugPrint('💾 comentario.id: ${comentario.id}');
      }

      final hiveBox = await box;
      if (hiveBox.containsKey(comentario.id)) {
        if (kDebugMode) {
          debugPrint(
            '⚠️ ComentariosLocalDatasourceImpl.addComentario() - Comentário já existe com id: ${comentario.id}',
          );
        }
      }

      final comentarioJson = jsonEncode(comentario.toJson());

      if (kDebugMode) {
        debugPrint(
          '💾 ComentariosLocalDatasourceImpl.addComentario() - Gravando no Hive',
        );
      }

      await hiveBox.put(comentario.id, comentarioJson);

      if (kDebugMode) {
        debugPrint(
          '✅ ComentariosLocalDatasourceImpl.addComentario() - Gravado com sucesso',
        );
      }
      _invalidateCache();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ ComentariosLocalDatasourceImpl.addComentario() - Erro: $e');
      }
      throw Exception('Erro ao salvar comentário no cache local: ${e.toString()}');
    }
  }

  @override
  Future<void> updateComentario(ComentarioModel comentario) async {
    try {
      final hiveBox = await box;
      final comentarioJson = jsonEncode(comentario.toJson());
      await hiveBox.put(comentario.id, comentarioJson);
      _invalidateCache();
    } catch (e) {
      throw Exception(
        'Erro ao atualizar comentário no cache local: ${e.toString()}',
      );
    }
  }

  @override
  Future<void> deleteComentario(String id) async {
    try {
      final hiveBox = await box;
      final comentarioData = hiveBox.get(id);
      if (comentarioData != null) {
        Map<String, dynamic> comentarioJson;

        // Support both String (new format) and Map (old format)
        if (comentarioData is String) {
          comentarioJson = jsonDecode(comentarioData) as Map<String, dynamic>;
        } else if (comentarioData is Map) {
          comentarioJson = Map<String, dynamic>.from(comentarioData);
        } else {
          debugPrint(
            '⚠️ Unknown comentario data format for ID $id: ${comentarioData.runtimeType}',
          );
          return;
        }

        final comentario = ComentarioModel.fromJson(comentarioJson);
        final deletedComentario = comentario.copyWith(
          status: false,
          updatedAt: DateTime.now(),
        );

        final updatedJson = jsonEncode(deletedComentario.toJson());
        await hiveBox.put(id, updatedJson);
        _invalidateCache();
      }
    } catch (e) {
      throw Exception('Erro ao deletar comentário do cache local: ${e.toString()}');
    }
  }

  @override
  Future<List<ComentarioModel>> getComentariosByContext(
    String pkIdentificador,
  ) async {
    try {
      final allComentarios = await getComentarios();
      return allComentarios
          .where((comentario) => comentario.pkIdentificador == pkIdentificador)
          .toList();
    } catch (e) {
      throw Exception(
        'Erro ao buscar comentários por contexto no cache local: ${e.toString()}',
      );
    }
  }

  @override
  Future<List<ComentarioModel>> getComentariosByTool(String ferramenta) async {
    try {
      final allComentarios = await getComentarios();
      return allComentarios
          .where((comentario) => comentario.ferramenta == ferramenta)
          .toList();
    } catch (e) {
      throw Exception(
        'Erro ao buscar comentários por ferramenta no cache local: ${e.toString()}',
      );
    }
  }

  @override
  Future<List<ComentarioModel>> searchComentarios(String query) async {
    try {
      final allComentarios = await getComentarios();
      final searchQuery = query.toLowerCase().trim();

      if (searchQuery.isEmpty) {
        return allComentarios;
      }

      return allComentarios.where((comentario) {
        final titulo = comentario.titulo.toLowerCase();
        final conteudo = comentario.conteudo.toLowerCase();
        final ferramenta = comentario.ferramenta.toLowerCase();

        return titulo.contains(searchQuery) ||
            conteudo.contains(searchQuery) ||
            ferramenta.contains(searchQuery);
      }).toList();
    } catch (e) {
      throw Exception(
        'Erro ao buscar comentários no cache local: ${e.toString()}',
      );
    }
  }

  @override
  Future<void> clearCache() async {
    try {
      final hiveBox = await box;
      await hiveBox.clear();
      _invalidateCache();
    } catch (e) {
      throw Exception('Erro ao limpar cache local: ${e.toString()}');
    }
  }

  /// Invalidate memory cache
  void _invalidateCache() {
    _cachedComentarios = null;
    _cacheTimestamp = null;
  }

  /// Get cache statistics for monitoring
  Map<String, dynamic> getCacheStats() {
    return {
      'comentariosCache': {
        'cached': _cachedComentarios != null,
        'cacheSize': _cachedComentarios?.length ?? 0,
        'cacheAge': _cacheTimestamp != null
            ? DateTime.now().difference(_cacheTimestamp!).inMinutes
            : null,
      },
    };
  }
}

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../models/comentario_model.dart';
import '../constants/comentarios_design_tokens.dart';
import '../../../core/interfaces/i_premium_service.dart';

abstract class IComentariosRepository {
  Future<List<ComentarioModel>> getAllComentarios();
  Future<void> addComentario(ComentarioModel comentario);
  Future<void> updateComentario(ComentarioModel comentario);
  Future<void> deleteComentario(String id);
}

class ComentariosService extends ChangeNotifier {
  final IComentariosRepository? _repository;
  final IPremiumService? _premiumService;

  ComentariosService({
    IComentariosRepository? repository,
    IPremiumService? premiumService,
  }) : _repository = repository,
       _premiumService = premiumService;

  Future<List<ComentarioModel>> getAllComentarios({String? pkIdentificador}) async {
    try {
      final comentarios = await _repository?.getAllComentarios() ?? <ComentarioModel>[];
      
      // Sort by newest first
      comentarios.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      
      // Filter by identifier if provided
      if (pkIdentificador != null && pkIdentificador.isNotEmpty) {
        return comentarios
            .where((element) => element.pkIdentificador == pkIdentificador)
            .toList();
      }
      
      return comentarios;
    } catch (e) {
      debugPrint('Error getting comentarios: $e');
      return [];
    }
  }

  Future<void> addComentario(ComentarioModel comentario) async {
    try {
      await _repository?.addComentario(comentario);
    } catch (e) {
      debugPrint('Error adding comentario: $e');
      rethrow;
    }
  }

  Future<void> updateComentario(ComentarioModel comentario) async {
    try {
      await _repository?.updateComentario(comentario);
    } catch (e) {
      debugPrint('Error updating comentario: $e');
      rethrow;
    }
  }

  Future<void> deleteComentario(String id) async {
    try {
      await _repository?.deleteComentario(id);
    } catch (e) {
      debugPrint('Error deleting comentario: $e');
      rethrow;
    }
  }

  List<ComentarioModel> filterComentarios(
    List<ComentarioModel> comentarios,
    String searchText, {
    String? pkIdentificador,
    String? ferramenta,
  }) {
    if (comentarios.isEmpty) return comentarios;

    return comentarios.where((comentario) {
      // Search filter
      if (searchText.isNotEmpty) {
        final searchLower = _sanitizeSearchText(searchText);
        final contentMatch = comentario.conteudo.toLowerCase().contains(searchLower);
        final toolMatch = comentario.ferramenta.toLowerCase().contains(searchLower);

        if (!contentMatch && !toolMatch) return false;
      }

      // Context filters
      if (pkIdentificador != null && 
          pkIdentificador.isNotEmpty && 
          comentario.pkIdentificador != pkIdentificador) {
        return false;
      }

      if (ferramenta != null && 
          ferramenta.isNotEmpty && 
          comentario.ferramenta != ferramenta) {
        return false;
      }

      return true;
    }).toList();
  }

  String _sanitizeSearchText(String text) {
    // Limit length for performance
    if (text.length > ComentariosDesignTokens.maxSearchLength) {
      text = text.substring(0, ComentariosDesignTokens.maxSearchLength);
    }

    // Escape regex special characters for security
    return text.toLowerCase().replaceAll(RegExp(r'[\\\[\]{}()*+?.^$|]'), '');
  }

  int getMaxComentarios() {
    if (_premiumService?.isPremium == true) {
      return ComentariosDesignTokens.premiumMaxComments;
    } else {
      return ComentariosDesignTokens.freeTierMaxComments;
    }
  }

  bool canAddComentario(int currentCount) {
    final maxComentarios = getMaxComentarios();
    return currentCount < maxComentarios;
  }

  bool hasAdvancedFeatures() {
    return _premiumService?.isPremium == true;
  }

  String generateId() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }

  String generateIdReg() {
    // Simple ID generation - replace with actual database utility if available
    return 'REG_${DateTime.now().millisecondsSinceEpoch}';
  }

  bool isValidContent(String content) {
    return content.trim().length >= ComentariosDesignTokens.minCommentLength;
  }

  String getValidationErrorMessage() {
    return ComentariosDesignTokens.shortCommentError;
  }
}
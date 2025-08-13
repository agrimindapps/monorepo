// Flutter imports:
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:get/get.dart';

// Project imports:
import '../../../injections.dart';
import '../../../models/comentarios_models.dart';
import '../../../repository/comentarios_repository.dart';
import '../../../services/premium_service.dart';

class ComentariosService extends GetxService {
  final ComentariosRepository _repository = ComentariosRepository();
  @override
  void onInit() {
    super.onInit();
    _initializeDependencies();
  }

  void _initializeDependencies() {
    try {
      ReceituagroBindings().dependencies();
    } catch (e) {
      debugPrint('Erro ao inicializar dependências do Receituagro: $e');
    }
  }

  Future<List<Comentarios>> getAllComentarios({String? pkIdentificador}) async {
    final comentarios = await _repository.getAllComentarios();
    comentarios.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    
    if (pkIdentificador != null) {
      return comentarios.where((element) => element.pkIdentificador == pkIdentificador).toList();
    }
    
    return comentarios;
  }

  List<Comentarios> filterComentarios(List<Comentarios> comentarios, String searchText, {
    String? pkIdentificador,
    String? ferramenta,
  }) {
    if (comentarios.isEmpty) return comentarios;
    
    return comentarios.where((row) {
      // Aplica filtro de busca se fornecido
      if (searchText.isNotEmpty) {
        final searchLower = _sanitizeSearchText(searchText);
        final contentMatch = row.conteudo.toLowerCase().contains(searchLower);
        final toolMatch = row.ferramenta.toLowerCase().contains(searchLower);
        
        if (!contentMatch && !toolMatch) return false;
      }
      
      // Aplica filtro de pkIdentificador se fornecido
      if (pkIdentificador != null && row.pkIdentificador != pkIdentificador) {
        return false;
      }
      
      // Aplica filtro de ferramenta se fornecido
      if (ferramenta != null && row.ferramenta != ferramenta) {
        return false;
      }
      
      return true;
    }).toList();
  }
  
  String _sanitizeSearchText(String text) {
    // Remove caracteres especiais de regex e limita tamanho
    if (text.length > 100) {
      text = text.substring(0, 100);
    }
    
    // Escapa caracteres especiais de regex
    return text.toLowerCase().replaceAll(RegExp(r'[\\\[\]{}()*+?.^$|]'), '');
  }

  Future<void> addComentario(Comentarios comentario) async {
    await _repository.addComentario(comentario);
  }

  Future<void> updateComentario(Comentarios comentario) async {
    await _repository.updateComentario(comentario);
  }

  Future<void> deleteComentario(String id) async {
    await _repository.deleteComentario(id);
  }

  int getMaxComentarios() {
    // Comentários disponíveis apenas para usuários premium
    final premiumService = Get.find<PremiumService>();
    if (premiumService.isPremium) {
      return 9999999; // Ilimitado para premium
    } else {
      return 0; // Nenhum comentário para usuários não-premium
    }
  }

  bool canAddComentario(int currentCount) {
    final maxComentarios = getMaxComentarios();
    return currentCount < maxComentarios;
  }

  bool hasAdvancedFeatures() {
    // Funcionalidades avançadas disponíveis apenas para usuários premium
    final premiumService = Get.find<PremiumService>();
    return premiumService.isPremium;
  }
}

import 'package:flutter/foundation.dart';

import '../../../core/di/injection_container.dart';
import '../../../core/interfaces/i_premium_service.dart';
import '../../../core/repositories/favoritos_hive_repository.dart';
import '../domain/entities/favorito_entity.dart';
import 'universal_favorito_provider.dart';

/// Provider especializado para Pragas usando Universal Provider
class PragaFavoritoProvider extends UniversalFavoritoProvider {
  PragaFavoritoProvider() : super(
    repository: sl<FavoritosHiveRepository>(),
    tipo: TipoFavorito.praga,
  );

  @override
  Map<String, dynamic> prepareItemData() {
    final data = super.prepareItemData();
    return {
      ...data,
      'tipo': 'praga',
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    };
  }

  @override
  Future<void> onToggleSuccess(bool wasAdded) async {
    // Lógica específica para pragas após toggle
    if (wasAdded) {
      // Opcional: analytics, logging específico
      debugPrint('🐛 Praga adicionada aos favoritos: $itemId');
    }
  }
}

/// Provider especializado para Defensivos usando Universal Provider
class DefensivoFavoritoProvider extends UniversalFavoritoProvider {
  DefensivoFavoritoProvider() : super(
    repository: sl<FavoritosHiveRepository>(),
    tipo: TipoFavorito.defensivo,
  );

  @override
  Map<String, dynamic> prepareItemData() {
    final data = super.prepareItemData();
    return {
      ...data,
      'tipo': 'defensivo',
      'categoria': data['categoria'] ?? 'geral',
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    };
  }

  @override
  Future<void> onToggleSuccess(bool wasAdded) async {
    if (wasAdded) {
      debugPrint('🛡️ Defensivo adicionado aos favoritos: $itemId');
    }
  }
}

/// Provider especializado para Diagnósticos com validação Premium
class DiagnosticoFavoritoProvider extends UniversalFavoritoProvider {
  final IPremiumService _premiumService = sl<IPremiumService>();

  DiagnosticoFavoritoProvider() : super(
    repository: sl<FavoritosHiveRepository>(),
    tipo: TipoFavorito.diagnostico,
  );

  /// Propriedade para verificar se usuário é premium
  bool get isPremium => _premiumService.isPremium;

  @override
  Future<bool> validateBeforeToggle() async {
    // Diagnósticos requerem premium
    if (!isPremium) {
      setError('Favoritar diagnósticos requer assinatura premium');
      return false;
    }
    return true;
  }

  @override
  Map<String, dynamic> prepareItemData() {
    final data = super.prepareItemData();
    return {
      ...data,
      'tipo': 'diagnostico',
      'requiresPremium': true,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    };
  }

  @override
  String customizeErrorMessage(String originalError) {
    if (originalError.contains('premium')) {
      return 'Funcionalidade exclusiva para usuários Premium';
    }
    return originalError;
  }

  @override
  Future<void> onToggleSuccess(bool wasAdded) async {
    if (wasAdded) {
      debugPrint('🏥 Diagnóstico premium adicionado aos favoritos: $itemId');
    }
  }

  /// Método para verificar se pode favoritar
  bool canFavorite() => isPremium;

  /// Método auxiliar não mais necessário
  // setCustomError removido - usando setError protegido diretamente
}

/// Provider especializado para Culturas usando Universal Provider  
class CulturaFavoritoProvider extends UniversalFavoritoProvider {
  CulturaFavoritoProvider() : super(
    repository: sl<FavoritosHiveRepository>(),
    tipo: TipoFavorito.cultura,
  );

  @override
  Map<String, dynamic> prepareItemData() {
    final data = super.prepareItemData();
    return {
      ...data,
      'tipo': 'cultura',
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    };
  }

  @override
  Future<void> onToggleSuccess(bool wasAdded) async {
    if (wasAdded) {
      debugPrint('🌱 Cultura adicionada aos favoritos: $itemId');
    }
  }
}
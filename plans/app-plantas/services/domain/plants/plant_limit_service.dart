// Package imports:
import 'package:get/get.dart';

// Project imports:
import '../../../repository/planta_repository.dart';
import '../../application/auth_service.dart';
import '../../application/local_license_service.dart';

/// Serviço responsável por gerenciar limites de plantas para usuários
class PlantLimitService extends GetxService {
  static PlantLimitService get instance => Get.find<PlantLimitService>();

  final PlantaRepository _plantaRepository = PlantaRepository.instance;

  /// Limite de plantas para usuários não premium
  static const int freePlantLimit = 3;

  /// Verifica se o usuário pode adicionar uma nova planta
  Future<bool> canAddNewPlant() async {
    final user = AuthService.instance.currentUser;

    // Se não há usuário logado, não permite adicionar
    if (user == null) return false;

    // Se é usuário premium, permite ilimitado
    if (user.isPremium) return true;

    // Verifica licença local de teste (para incubador de projetos)
    final hasLocalLicense =
        await LocalLicenseService.instance.hasActiveLicense();
    if (hasLocalLicense) return true;

    // Para usuários não premium sem licença local, verifica o limite
    final currentPlantCount = await getCurrentPlantCount();
    return currentPlantCount < freePlantLimit;
  }

  /// Obtém a quantidade atual de plantas do usuário
  Future<int> getCurrentPlantCount() async {
    try {
      await _plantaRepository.initialize();
      final plantas = await _plantaRepository.findAll();
      return plantas.length;
    } catch (e) {
      // Em caso de erro, assume 0 plantas
      return 0;
    }
  }

  /// Verifica se o usuário atingiu o limite
  Future<bool> hasReachedLimit() async {
    final user = AuthService.instance.currentUser;

    // Usuários premium nunca atingem o limite
    if (user?.isPremium == true) return false;

    // Usuários com licença local nunca atingem o limite
    final hasLocalLicense =
        await LocalLicenseService.instance.hasActiveLicense();
    if (hasLocalLicense) return false;

    final currentCount = await getCurrentPlantCount();
    return currentCount >= freePlantLimit;
  }

  /// Obtém informações sobre o limite atual
  Future<PlantLimitInfo> getLimitInfo() async {
    final user = AuthService.instance.currentUser;
    final currentCount = await getCurrentPlantCount();
    final hasLocalLicense =
        await LocalLicenseService.instance.hasActiveLicense();

    // Considera premium se tem assinatura oficial ou licença local
    final isEffectivelyPremium = (user?.isPremium == true) || hasLocalLicense;

    return PlantLimitInfo(
      currentCount: currentCount,
      maxCount: isEffectivelyPremium ? null : freePlantLimit,
      isPremium: user?.isPremium ?? false,
      hasLocalLicense: hasLocalLicense,
      hasReachedLimit:
          isEffectivelyPremium ? false : currentCount >= freePlantLimit,
    );
  }
}

/// Informações sobre o limite de plantas
class PlantLimitInfo {
  final int currentCount;
  final int? maxCount; // null para usuários premium (ilimitado)
  final bool isPremium;
  final bool hasLocalLicense;
  final bool hasReachedLimit;

  PlantLimitInfo({
    required this.currentCount,
    required this.maxCount,
    required this.isPremium,
    required this.hasLocalLicense,
    required this.hasReachedLimit,
  });

  String get limitText {
    if (isPremium) {
      return '$currentCount plantas (Ilimitado - Premium)';
    }
    if (hasLocalLicense) {
      return '$currentCount plantas (Ilimitado - Licença Local)';
    }
    return '$currentCount de ${maxCount ?? 0} plantas';
  }

  bool get isEffectivelyPremium => isPremium || hasLocalLicense;
}

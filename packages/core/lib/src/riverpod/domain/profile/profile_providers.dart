import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../infrastructure/services/local_profile_image_service.dart';
import '../analytics/analytics_providers.dart';

/// Provider para o serviço de manipulação local de imagens de perfil
final localProfileImageServiceProvider = Provider<LocalProfileImageService>((ref) {
  final analytics = ref.watch(analyticsServiceProvider);
  return LocalProfileImageService(analytics);
});

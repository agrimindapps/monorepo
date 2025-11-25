import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../core/di/injection_container.dart' as di;
import '../../core/navigation/agricultural_navigation_extension.dart';
import '../../core/providers/core_providers.dart';
import '../../core/services/receituagro_navigation_service.dart';
import 'domain/navigation_page_service.dart';

part 'navigation_providers.g.dart';

@riverpod
NavigationPageService navigationPageService(Ref ref) {
  return NavigationPageService();
}

@riverpod
ReceitaAgroNavigationService receitaAgroNavigationService(Ref ref) {
  final coreService = ref.watch(coreNavigationServiceProvider);
  final agricExtension = ref.watch(agriculturalNavigationExtensionProvider);
  return ReceitaAgroNavigationService(
    coreService: coreService,
    agricExtension: agricExtension,
  );
}

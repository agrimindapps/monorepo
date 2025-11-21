import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../core/di/injection_container.dart' as di;
import 'domain/navigation_page_service.dart';

part 'navigation_providers.g.dart';

@riverpod
NavigationPageService navigationPageService(NavigationPageServiceRef ref) {
  return di.sl<NavigationPageService>();
}

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../presentation/managers/device_dialog_manager.dart';

part 'device_services_providers.g.dart';

// ============================================================================
// MANAGERS PROVIDERS
// ============================================================================

/// Fornece DeviceDialogManager
@riverpod
DeviceDialogManager deviceDialogManager(Ref ref) {
  return DeviceDialogManager();
}

// ============================================================================
// SERVICES PROVIDERS
// ============================================================================

// Nota: Os providers para DeviceActionService e DeviceInitializationService
// serão definidos após a resolução das dependências de use cases.
// Por enquanto, estas são classes que podem ser instanciadas diretamente
// com as dependências necessárias quando o notifier as demandar.

// DeviceMenuActionHandler, DeviceStatusBuilder, DeviceFeedbackBuilder
// e DeviceStatusManager são classes com métodos estáticos/simples
// que não requerem providers Riverpod.

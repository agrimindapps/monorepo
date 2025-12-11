/// Device Management Feature Export
///
/// Este arquivo centraliza todas as exportações da funcionalidade de
/// gerenciamento de dispositivos do app-plantis.
///
/// NOTA: A lógica base (entities, services, repositories) vem do core package.
/// Este módulo contém apenas:
/// - DeviceModel: Extensão específica do plantis da DeviceEntity do core
/// - Widgets de UI específicos do plantis
/// - Provider de estado do plantis
library;

// Re-export core device management
export 'package:core/core.dart'
    show
        DeviceEntity,
        DeviceStatistics,
        DeviceLimitConfig,
        DeviceManagementService,
        IDeviceRepository,
        deviceLimitConfigProvider,
        deviceRepositoryProvider,
        userDevicesFromRepositoryProvider,
        canAddMoreDevicesProvider,
        deviceStatisticsProvider,
        currentDeviceProvider,
        DeviceValidationResult;

// Models específicos do plantis
export 'data/models/device_model.dart';

// Presentation layer
export 'presentation/pages/device_management_page.dart';
// Provider do plantis para device management
export 'presentation/providers/device_management_provider.dart';
export 'presentation/providers/device_management_providers.dart'
    show
        plantisDeviceLimitConfigProvider,
        plantisDeviceManagementServiceProvider,
        plantisUserDevicesProvider,
        plantisCanAddMoreDevicesProvider,
        plantisDeviceStatisticsProvider;
export 'presentation/widgets/device_actions_widget.dart';
export 'presentation/widgets/device_list_widget.dart';
export 'presentation/widgets/device_statistics_widget.dart';
export 'presentation/widgets/device_tile_widget.dart';

/// Device Management Feature Export
///
/// Este arquivo centraliza todas as exportações da funcionalidade de
/// gerenciamento de dispositivos do app-plantis.
library;

export 'data/datasources/device_local_datasource.dart';
export 'data/datasources/device_remote_datasource.dart';
export 'data/models/device_model.dart';
export 'data/repositories/device_repository_impl.dart';
export 'domain/repositories/device_repository.dart';
export 'domain/usecases/get_device_statistics_usecase.dart';
export 'domain/usecases/get_user_devices_usecase.dart';
export 'domain/usecases/revoke_device_usecase.dart'
    hide RevokeDeviceUseCase, RevokeAllOtherDevicesUseCase;
export 'domain/usecases/validate_device_usecase.dart'
    hide ValidateDeviceUseCase, DeviceValidationResult;
export 'presentation/pages/device_management_page.dart';
export 'presentation/providers/device_management_provider.dart';
export 'presentation/providers/device_validation_interceptor.dart';
export 'presentation/widgets/device_actions_widget.dart';
export 'presentation/widgets/device_list_widget.dart';
export 'presentation/widgets/device_statistics_widget.dart';
export 'presentation/widgets/device_tile_widget.dart';

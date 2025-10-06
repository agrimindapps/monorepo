import 'dart:async';

import 'package:collection/collection.dart';
import 'package:core/core.dart' as core;
import 'package:flutter/foundation.dart';

import '../../../../core/usecases/usecase.dart';
import '../../domain/entities/premium_status.dart';
import '../../domain/repositories/premium_repository.dart';
import '../../domain/usecases/can_add_fuel_record.dart';
import '../../domain/usecases/can_add_maintenance_record.dart';
import '../../domain/usecases/can_add_vehicle.dart';
import '../../domain/usecases/can_use_feature.dart';
import '../../domain/usecases/check_premium_status.dart';
import '../../domain/usecases/get_available_products.dart';
import '../../domain/usecases/manage_local_license.dart';
import '../../domain/usecases/purchase_premium.dart';
import '../../domain/usecases/restore_purchases.dart';

/// State para Premium com loading separado para operações
@immutable
class PremiumNotifierState {
  const PremiumNotifierState({
    this.premiumStatus = PremiumStatus.free,
    this.availableProducts = const [],
    this.isLoadingProducts = false,
    this.isProcessingPurchase = false,
    this.errorMessage,
  });
  final PremiumStatus premiumStatus;
  final List<core.ProductInfo> availableProducts;
  final bool isLoadingProducts;
  final bool isProcessingPurchase;
  final String? errorMessage;

  PremiumNotifierState copyWith({
    PremiumStatus? premiumStatus,
    List<core.ProductInfo>? availableProducts,
    bool? isLoadingProducts,
    bool? isProcessingPurchase,
    String? errorMessage,
    bool clearError = false,
  }) {
    return PremiumNotifierState(
      premiumStatus: premiumStatus ?? this.premiumStatus,
      availableProducts: availableProducts ?? this.availableProducts,
      isLoadingProducts: isLoadingProducts ?? this.isLoadingProducts,
      isProcessingPurchase: isProcessingPurchase ?? this.isProcessingPurchase,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
  bool get isPremium => premiumStatus.isPremium;
  bool get canPurchasePremium => !isPremium;
  DateTime? get expirationDate => premiumStatus.expirationDate;

  String get subscriptionStatus {
    if (!isPremium) return 'Gratuito';
    if (premiumStatus.isExpired) return 'Expirado';
    return 'Premium';
  }

  String get premiumSource => premiumStatus.premiumSource;
  int get maxVehicles => premiumStatus.limits.maxVehicles;
  int get maxFuelRecords => premiumStatus.limits.maxFuelRecords;
  int get maxMaintenanceRecords => premiumStatus.limits.maxMaintenanceRecords;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PremiumNotifierState &&
          runtimeType == other.runtimeType &&
          premiumStatus == other.premiumStatus &&
          const ListEquality<core.ProductInfo>().equals(
            availableProducts,
            other.availableProducts,
          ) &&
          isLoadingProducts == other.isLoadingProducts &&
          isProcessingPurchase == other.isProcessingPurchase &&
          errorMessage == other.errorMessage;

  @override
  int get hashCode =>
      premiumStatus.hashCode ^
      const ListEquality<core.ProductInfo>().hash(availableProducts) ^
      isLoadingProducts.hashCode ^
      isProcessingPurchase.hashCode ^
      errorMessage.hashCode;

  @override
  String toString() =>
      'PremiumNotifierState('
      'premiumStatus: $premiumStatus, '
      'availableProducts: ${availableProducts.length}, '
      'isLoadingProducts: $isLoadingProducts, '
      'isProcessingPurchase: $isProcessingPurchase, '
      'errorMessage: $errorMessage)';
}

/// Premium Notifier usando AsyncNotifier com manual stream subscription
class PremiumNotifier extends core.AsyncNotifier<PremiumNotifierState> {
  CheckPremiumStatus? _checkPremiumStatus;
  CanUseFeature? _canUseFeature;
  CanAddVehicle? _canAddVehicle;
  CanAddFuelRecord? _canAddFuelRecord;
  CanAddMaintenanceRecord? _canAddMaintenanceRecord;
  PurchasePremium? _purchasePremium;
  GetAvailableProducts? _getAvailableProducts;
  RestorePurchases? _restorePurchases;
  GenerateLocalLicense? _generateLocalLicense;
  RevokeLocalLicense? _revokeLocalLicense;
  PremiumRepository? _premiumRepository;
  StreamSubscription<PremiumStatus>? _statusSubscription;

  @override
  Future<PremiumNotifierState> build() async {
    _checkPremiumStatus = ref.read(checkPremiumStatusProvider);
    _canUseFeature = ref.read(canUseFeatureProvider);
    _canAddVehicle = ref.read(canAddVehicleProvider);
    _canAddFuelRecord = ref.read(canAddFuelRecordProvider);
    _canAddMaintenanceRecord = ref.read(canAddMaintenanceRecordProvider);
    _purchasePremium = ref.read(purchasePremiumProvider);
    _getAvailableProducts = ref.read(getAvailableProductsProvider);
    _restorePurchases = ref.read(restorePurchasesProvider);
    _generateLocalLicense = ref.read(generateLocalLicenseProvider);
    _revokeLocalLicense = ref.read(revokeLocalLicenseProvider);
    _premiumRepository = ref.read(premiumRepositoryProvider);
    final result = await _checkPremiumStatus!(const NoParams());
    final premiumStatus = result.fold(
      (failure) => PremiumStatus.free,
      (status) => status,
    );
    _statusSubscription = _premiumRepository!.premiumStatus.listen((status) {
      state = core.AsyncValue.data(
        state.valueOrNull?.copyWith(premiumStatus: status) ??
            PremiumNotifierState(premiumStatus: status),
      );
    });
    ref.onDispose(() {
      _statusSubscription?.cancel();
      _statusSubscription = null;
    });

    return PremiumNotifierState(premiumStatus: premiumStatus);
  }

  /// Força uma verificação do status premium
  Future<void> refreshPremiumStatus() async {
    if (_premiumRepository == null) return;
    final result = await _premiumRepository!.forceSyncPremiumStatus();
    result.fold(
      (failure) {
        _updateError('Erro ao atualizar status: ${failure.message}');
      },
      (_) {
        clearError();
      },
    );
  }

  /// Força sincronização cross-device
  Future<void> syncAcrossDevices() async {
    if (_premiumRepository == null) return;
    try {
      final result = await _premiumRepository!.forceSyncPremiumStatus();
      result.fold(
        (failure) => _updateError('Erro na sincronização: ${failure.message}'),
        (_) => clearError(),
      );
    } catch (e) {
      _updateError('Erro inesperado na sincronização: $e');
    }
  }

  /// Obtém produtos disponíveis para compra
  Future<void> loadAvailableProducts() async {
    if (_getAvailableProducts == null) return;

    state = core.AsyncValue.data(
      state.valueOrNull?.copyWith(isLoadingProducts: true, clearError: true) ??
          const PremiumNotifierState(isLoadingProducts: true),
    );

    final result = await _getAvailableProducts!(const NoParams());

    result.fold(
      (failure) {
        state = core.AsyncValue.data(
          state.valueOrNull?.copyWith(
                isLoadingProducts: false,
                errorMessage: 'Erro ao carregar produtos: ${failure.message}',
                availableProducts: [],
              ) ??
              PremiumNotifierState(
                isLoadingProducts: false,
                errorMessage: 'Erro ao carregar produtos: ${failure.message}',
              ),
        );
      },
      (products) {
        state = core.AsyncValue.data(
          state.valueOrNull?.copyWith(
                availableProducts: products,
                isLoadingProducts: false,
                clearError: true,
              ) ??
              PremiumNotifierState(
                availableProducts: products,
                isLoadingProducts: false,
              ),
        );
      },
    );
  }

  /// Compra premium
  Future<bool> purchaseProduct(String productId) async {
    if (_purchasePremium == null) return false;

    state = core.AsyncValue.data(
      state.valueOrNull?.copyWith(
            isProcessingPurchase: true,
            clearError: true,
          ) ??
          const PremiumNotifierState(isProcessingPurchase: true),
    );

    try {
      final result = await _purchasePremium!(
        PurchasePremiumParams(productId: productId),
      );

      return result.fold(
        (failure) {
          state = core.AsyncValue.data(
            state.valueOrNull?.copyWith(
                  isProcessingPurchase: false,
                  errorMessage: 'Erro na compra: ${failure.message}',
                ) ??
                PremiumNotifierState(
                  isProcessingPurchase: false,
                  errorMessage: 'Erro na compra: ${failure.message}',
                ),
          );
          return false;
        },
        (subscription) {
          state = core.AsyncValue.data(
            state.valueOrNull?.copyWith(
                  isProcessingPurchase: false,
                  clearError: true,
                ) ??
                const PremiumNotifierState(isProcessingPurchase: false),
          );
          refreshPremiumStatus();
          return true;
        },
      );
    } catch (e) {
      state = core.AsyncValue.data(
        state.valueOrNull?.copyWith(
              isProcessingPurchase: false,
              errorMessage: 'Erro na compra: ${e.toString()}',
            ) ??
            PremiumNotifierState(
              isProcessingPurchase: false,
              errorMessage: 'Erro na compra: ${e.toString()}',
            ),
      );
      return false;
    }
  }

  /// Restaura compras anteriores
  Future<bool> restorePurchases() async {
    if (_restorePurchases == null) return false;

    state = core.AsyncValue.data(
      state.valueOrNull?.copyWith(
            isProcessingPurchase: true,
            clearError: true,
          ) ??
          const PremiumNotifierState(isProcessingPurchase: true),
    );

    try {
      final result = await _restorePurchases!(const NoParams());

      return result.fold(
        (failure) {
          state = core.AsyncValue.data(
            state.valueOrNull?.copyWith(
                  isProcessingPurchase: false,
                  errorMessage: 'Erro ao restaurar compras: ${failure.message}',
                ) ??
                PremiumNotifierState(
                  isProcessingPurchase: false,
                  errorMessage: 'Erro ao restaurar compras: ${failure.message}',
                ),
          );
          return false;
        },
        (success) {
          state = core.AsyncValue.data(
            state.valueOrNull?.copyWith(
                  isProcessingPurchase: false,
                  clearError: true,
                ) ??
                const PremiumNotifierState(isProcessingPurchase: false),
          );
          refreshPremiumStatus();
          return success;
        },
      );
    } catch (e) {
      state = core.AsyncValue.data(
        state.valueOrNull?.copyWith(
              isProcessingPurchase: false,
              errorMessage: 'Erro ao restaurar compras: ${e.toString()}',
            ) ??
            PremiumNotifierState(
              isProcessingPurchase: false,
              errorMessage: 'Erro ao restaurar compras: ${e.toString()}',
            ),
      );
      return false;
    }
  }

  /// Gera licença local para desenvolvimento
  Future<void> generateLocalLicense({int days = 30}) async {
    if (_generateLocalLicense == null) return;
    try {
      final result = await _generateLocalLicense!(
        GenerateLocalLicenseParams(days: days),
      );

      result.fold(
        (failure) {
          _updateError('Erro ao gerar licença: ${failure.message}');
        },
        (_) {
          clearError();
          debugPrint('Licença local gerada. Expira em $days dias.');
        },
      );
    } catch (e) {
      _updateError('Erro ao gerar licença: ${e.toString()}');
    }
  }

  /// Revoga licença local
  Future<void> revokeLocalLicense() async {
    if (_revokeLocalLicense == null) return;
    try {
      final result = await _revokeLocalLicense!(const NoParams());

      result.fold(
        (failure) {
          _updateError('Erro ao revogar licença: ${failure.message}');
        },
        (_) {
          clearError();
          debugPrint('Licença local revogada');
        },
      );
    } catch (e) {
      _updateError('Erro ao revogar licença: ${e.toString()}');
    }
  }

  /// Verifica se pode usar uma feature específica
  Future<bool> hasFeature(String featureId) async {
    return await _canUseFeatureById(featureId);
  }

  /// Verifica se pode adicionar veículo
  Future<bool> canAddVehicle(int currentCount) async {
    if (_canAddVehicle == null) return false;
    final result = await _canAddVehicle!(
      CanAddVehicleParams(currentCount: currentCount),
    );
    return result.fold((failure) => false, (canAdd) => canAdd);
  }

  /// Verifica se pode adicionar registro de combustível
  Future<bool> canAddFuelRecord(int currentCount) async {
    if (_canAddFuelRecord == null) return false;
    final result = await _canAddFuelRecord!(
      CanAddFuelRecordParams(currentCount: currentCount),
    );
    return result.fold((failure) => false, (canAdd) => canAdd);
  }

  /// Verifica se pode adicionar registro de manutenção
  Future<bool> canAddMaintenanceRecord(int currentCount) async {
    if (_canAddMaintenanceRecord == null) return false;
    final result = await _canAddMaintenanceRecord!(
      CanAddMaintenanceRecordParams(currentCount: currentCount),
    );
    return result.fold((failure) => false, (canAdd) => canAdd);
  }
  Future<bool> canAddUnlimitedVehicles() async =>
      state.valueOrNull?.isPremium ?? false;
  Future<bool> canAccessAdvancedReports() async =>
      await _canUseFeatureById('advanced_reports');
  Future<bool> canExportData() async => await _canUseFeatureById('export_data');
  Future<bool> canUseCustomCategories() async =>
      await _canUseFeatureById('custom_categories');
  Future<bool> canAccessPremiumThemes() async =>
      await _canUseFeatureById('premium_themes');
  Future<bool> canBackupToCloud() async =>
      await _canUseFeatureById('cloud_backup');
  Future<bool> canUseLocationHistory() async =>
      await _canUseFeatureById('location_history');
  Future<bool> canAccessAdvancedAnalytics() async =>
      await _canUseFeatureById('advanced_analytics');

  /// Método auxiliar para verificar features
  Future<bool> _canUseFeatureById(String featureId) async {
    if (_canUseFeature == null) return false;
    final result = await _canUseFeature!(
      CanUseFeatureParams(featureId: featureId),
    );
    return result.fold((failure) => false, (canUse) => canUse);
  }

  /// Stream de eventos de sincronização (para debug/monitoramento)
  Stream<String> get syncStatus {
    if (_premiumRepository == null) return Stream.value('Não disponível');
    return _premiumRepository!.syncEvents.map((event) {
      switch (event.runtimeType.toString()) {
        case '_SyncStarted':
          return 'Sincronização iniciada...';
        case '_SyncCompleted':
          return 'Sincronização concluída';
        case '_SyncFailed':
          return 'Erro na sincronização';
        case '_StatusUpdated':
          return 'Status atualizado';
        case '_WebhookReceived':
          return 'Atualização automática recebida';
        case '_RetryScheduled':
          return 'Tentativa agendada...';
        default:
          return 'Status atualizado';
      }
    });
  }

  /// Limpa mensagem de erro
  void clearError() {
    final currentState = state.valueOrNull;
    if (currentState != null && currentState.errorMessage != null) {
      state = core.AsyncValue.data(currentState.copyWith(clearError: true));
    }
  }

  /// Atualiza erro
  void _updateError(String message) {
    final currentState = state.valueOrNull;
    if (currentState != null) {
      state = core.AsyncValue.data(
        currentState.copyWith(errorMessage: message),
      );
    } else {
      state = core.AsyncValue.data(PremiumNotifierState(errorMessage: message));
    }
  }
}

/// Provider para PremiumNotifier
final premiumNotifierProvider =
    core.AsyncNotifierProvider<PremiumNotifier, PremiumNotifierState>(
      PremiumNotifier.new,
    );

/// Provider para status premium direto (renomeado para evitar conflito com core)
final gasometerIsPremiumProvider = core.Provider<bool>((ref) {
  final premiumAsync = ref.watch(premiumNotifierProvider);
  return premiumAsync.valueOrNull?.isPremium ?? false;
});

/// Provider para produtos disponíveis
final availableProductsProvider = core.Provider<List<core.ProductInfo>>((ref) {
  final premiumAsync = ref.watch(premiumNotifierProvider);
  return premiumAsync.valueOrNull?.availableProducts ?? [];
});

/// Provider para verificar se pode comprar premium
final canPurchasePremiumProvider = core.Provider<bool>((ref) {
  final premiumAsync = ref.watch(premiumNotifierProvider);
  return premiumAsync.valueOrNull?.canPurchasePremium ?? true;
});
final checkPremiumStatusProvider = core.Provider<CheckPremiumStatus>((ref) {
  return core.GetIt.instance<CheckPremiumStatus>();
});

final canUseFeatureProvider = core.Provider<CanUseFeature>((ref) {
  return core.GetIt.instance<CanUseFeature>();
});

final canAddVehicleProvider = core.Provider<CanAddVehicle>((ref) {
  return core.GetIt.instance<CanAddVehicle>();
});

final canAddFuelRecordProvider = core.Provider<CanAddFuelRecord>((ref) {
  return core.GetIt.instance<CanAddFuelRecord>();
});

final canAddMaintenanceRecordProvider = core.Provider<CanAddMaintenanceRecord>((
  ref,
) {
  return core.GetIt.instance<CanAddMaintenanceRecord>();
});

final purchasePremiumProvider = core.Provider<PurchasePremium>((ref) {
  return core.GetIt.instance<PurchasePremium>();
});

final getAvailableProductsProvider = core.Provider<GetAvailableProducts>((ref) {
  return core.GetIt.instance<GetAvailableProducts>();
});

final restorePurchasesProvider = core.Provider<RestorePurchases>((ref) {
  return core.GetIt.instance<RestorePurchases>();
});

final generateLocalLicenseProvider = core.Provider<GenerateLocalLicense>((ref) {
  return core.GetIt.instance<GenerateLocalLicense>();
});

final revokeLocalLicenseProvider = core.Provider<RevokeLocalLicense>((ref) {
  return core.GetIt.instance<RevokeLocalLicense>();
});

final premiumRepositoryProvider = core.Provider<PremiumRepository>((ref) {
  return core.GetIt.instance<PremiumRepository>();
});

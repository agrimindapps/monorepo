import 'dart:async';

import 'package:core/core.dart' as core;
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

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

@injectable
class PremiumProvider extends ChangeNotifier {

  PremiumProvider(
    this._checkPremiumStatus,
    this._canUseFeature,
    this._canAddVehicle,
    this._canAddFuelRecord,
    this._canAddMaintenanceRecord,
    this._purchasePremium,
    this._getAvailableProducts,
    this._restorePurchases,
    this._generateLocalLicense,
    this._revokeLocalLicense,
    this._premiumRepository,
  ) {
    _initialize();
  }
  final CheckPremiumStatus _checkPremiumStatus;
  final CanUseFeature _canUseFeature;
  final CanAddVehicle _canAddVehicle;
  final CanAddFuelRecord _canAddFuelRecord;
  final CanAddMaintenanceRecord _canAddMaintenanceRecord;
  final PurchasePremium _purchasePremium;
  final GetAvailableProducts _getAvailableProducts;
  final RestorePurchases _restorePurchases;
  final GenerateLocalLicense _generateLocalLicense;
  final RevokeLocalLicense _revokeLocalLicense;
  final PremiumRepository _premiumRepository;
  
  bool _isLoading = false;
  String? _errorMessage;
  PremiumStatus _premiumStatus = PremiumStatus.free;
  List<core.ProductInfo> _availableProducts = [];
  StreamSubscription<PremiumStatus>? _statusSubscription;
  
  // Getters
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isPremium => _premiumStatus.isPremium;
  PremiumStatus get premiumStatus => _premiumStatus;
  DateTime? get expirationDate => _premiumStatus.expirationDate;
  List<core.ProductInfo> get availableProducts => _availableProducts;
  bool get canPurchasePremium => !isPremium;
  
  String get subscriptionStatus {
    if (!isPremium) return 'Gratuito';
    if (_premiumStatus.isExpired) return 'Expirado';
    return 'Premium';
  }

  String get premiumSource => _premiumStatus.premiumSource;
  
  void _initialize() {
    // Escuta mudanças no status premium
    _statusSubscription = _premiumRepository.premiumStatus.listen((status) {
      _premiumStatus = status;
      notifyListeners();
    });
    
    // Verifica status inicial
    _checkInitialStatus();
  }
  
  Future<void> _checkInitialStatus() async {
    _isLoading = true;
    notifyListeners();

    final result = await _checkPremiumStatus(const NoParams());
    result.fold(
      (failure) {
        _errorMessage = failure.message;
        _premiumStatus = PremiumStatus.free;
      },
      (status) {
        _premiumStatus = status;
        _errorMessage = null;
      },
    );

    _isLoading = false;
    notifyListeners();
  }

  /// Força uma verificação do status premium
  Future<void> refreshPremiumStatus() async {
    _isLoading = true;
    notifyListeners();

    final result = await _premiumRepository.forceSyncPremiumStatus();
    result.fold(
      (failure) {
        _errorMessage = failure.message;
      },
      (_) {
        _errorMessage = null;
      },
    );

    _isLoading = false;
    notifyListeners();
  }

  /// Obtém produtos disponíveis para compra
  Future<void> loadAvailableProducts() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _getAvailableProducts(const NoParams());
    result.fold(
      (failure) {
        _errorMessage = 'Erro ao carregar produtos: ${failure.message}';
        _availableProducts = [];
      },
      (products) {
        _availableProducts = products;
        _errorMessage = null;
      },
    );

    _isLoading = false;
    notifyListeners();
  }

  /// Compra premium
  Future<bool> purchaseProduct(String productId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    try {
      final result = await _purchasePremium(PurchasePremiumParams(productId: productId));
      
      return result.fold(
        (failure) {
          _errorMessage = 'Erro na compra: ${failure.message}';
          _isLoading = false;
          notifyListeners();
          return false;
        },
        (subscription) {
          _errorMessage = null;
          _isLoading = false;
          notifyListeners();
          
          // Atualiza o status após a compra
          refreshPremiumStatus();
          return true;
        },
      );
    } catch (e) {
      _errorMessage = 'Erro na compra: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Restaura compras anteriores
  Future<bool> restorePurchases() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    try {
      final result = await _restorePurchases(const NoParams());
      
      return result.fold(
        (failure) {
          _errorMessage = 'Erro ao restaurar compras: ${failure.message}';
          _isLoading = false;
          notifyListeners();
          return false;
        },
        (success) {
          _errorMessage = null;
          _isLoading = false;
          notifyListeners();
          
          // Atualiza o status após restaurar
          refreshPremiumStatus();
          return success;
        },
      );
    } catch (e) {
      _errorMessage = 'Erro ao restaurar compras: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Gera licença local para desenvolvimento
  Future<void> generateLocalLicense({int days = 30}) async {
    try {
      final result = await _generateLocalLicense(GenerateLocalLicenseParams(days: days));
      
      result.fold(
        (failure) {
          _errorMessage = 'Erro ao gerar licença: ${failure.message}';
        },
        (_) {
          _errorMessage = null;
          debugPrint('Licença local gerada. Expira em $days dias.');
        },
      );
      
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Erro ao gerar licença: ${e.toString()}';
      notifyListeners();
    }
  }
  
  /// Revoga licença local
  Future<void> revokeLocalLicense() async {
    try {
      final result = await _revokeLocalLicense(const NoParams());
      
      result.fold(
        (failure) {
          _errorMessage = 'Erro ao revogar licença: ${failure.message}';
        },
        (_) {
          _errorMessage = null;
          debugPrint('Licença local revogada');
        },
      );
      
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Erro ao revogar licença: ${e.toString()}';
      notifyListeners();
    }
  }

  /// Limpa mensagem de erro
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Stream de eventos de sincronização (para debug/monitoramento)
  Stream<String> get syncStatus {
    return _premiumRepository.syncEvents.map((event) {
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

  /// Força sincronização cross-device
  Future<void> syncAcrossDevices() async {
    _isLoading = true;
    notifyListeners();

    try {
      final result = await _premiumRepository.forceSyncPremiumStatus();
      result.fold(
        (failure) => _errorMessage = 'Erro na sincronização: ${failure.message}',
        (_) => _errorMessage = null,
      );
    } catch (e) {
      _errorMessage = 'Erro inesperado na sincronização: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Métodos para verificar funcionalidades específicas do GasOMeter
  Future<bool> canAddUnlimitedVehicles() async {
    return isPremium;
  }

  Future<bool> canAccessAdvancedReports() async {
    return await _canUseFeatureById('advanced_reports');
  }

  Future<bool> canExportData() async {
    return await _canUseFeatureById('export_data');
  }

  Future<bool> canUseCustomCategories() async {
    return await _canUseFeatureById('custom_categories');
  }

  Future<bool> canAccessPremiumThemes() async {
    return await _canUseFeatureById('premium_themes');
  }

  Future<bool> canBackupToCloud() async {
    return await _canUseFeatureById('cloud_backup');
  }

  Future<bool> canUseLocationHistory() async {
    return await _canUseFeatureById('location_history');
  }

  Future<bool> canAccessAdvancedAnalytics() async {
    return await _canUseFeatureById('advanced_analytics');
  }

  /// Verifica se pode usar uma feature específica
  Future<bool> hasFeature(String featureId) async {
    return await _canUseFeatureById(featureId);
  }

  /// Verifica se pode adicionar veículo
  Future<bool> canAddVehicle(int currentCount) async {
    final result = await _canAddVehicle(CanAddVehicleParams(currentCount: currentCount));
    return result.fold((failure) => false, (canAdd) => canAdd);
  }

  /// Verifica se pode adicionar registro de combustível
  Future<bool> canAddFuelRecord(int currentCount) async {
    final result = await _canAddFuelRecord(CanAddFuelRecordParams(currentCount: currentCount));
    return result.fold((failure) => false, (canAdd) => canAdd);
  }

  /// Verifica se pode adicionar registro de manutenção
  Future<bool> canAddMaintenanceRecord(int currentCount) async {
    final result = await _canAddMaintenanceRecord(CanAddMaintenanceRecordParams(currentCount: currentCount));
    return result.fold((failure) => false, (canAdd) => canAdd);
  }
  
  // Limites para usuários gratuitos
  int get maxVehicles => _premiumStatus.limits.maxVehicles;
  int get maxFuelRecords => _premiumStatus.limits.maxFuelRecords;
  int get maxMaintenanceRecords => _premiumStatus.limits.maxMaintenanceRecords;

  /// Método auxiliar para verificar features
  Future<bool> _canUseFeatureById(String featureId) async {
    final result = await _canUseFeature(CanUseFeatureParams(featureId: featureId));
    return result.fold((failure) => false, (canUse) => canUse);
  }

  @override
  void dispose() {
    _statusSubscription?.cancel();
    super.dispose();
  }
}


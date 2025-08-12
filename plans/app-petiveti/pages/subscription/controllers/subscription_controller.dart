// Flutter imports:
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

// Package imports:
import 'package:purchases_flutter/purchases_flutter.dart';

// Project imports:
import '../models/benefit_model.dart';
import '../models/purchase_state_model.dart';
import '../models/subscription_model.dart';
import '../services/revenuecat_wrapper_service.dart';

// Helper function to safely convert dates
DateTime? _stringOrDateTimeToDateTime(dynamic date) {
  if (date == null) return null;
  if (date is DateTime) return date;
  if (date is String && date.isNotEmpty) {
    try {
      return DateTime.parse(date);
    } catch (e) {
      return null;
    }
  }
  return null;
}

class SubscriptionController extends ChangeNotifier {
  // Services
  late final RevenuecatWrapperService _revenuecatService;

  // State
  SubscriptionData _subscriptionData = SubscriptionData.empty();
  PurchaseStateData _purchaseState = PurchaseStateData.idle();
  List<Benefit> _benefits = [];
  bool _isInitialized = false;
  String? _errorMessage;

  // Getters
  SubscriptionData get subscriptionData => _subscriptionData;
  PurchaseStateData get purchaseState => _purchaseState;
  List<Benefit> get benefits => _benefits;
  bool get isInitialized => _isInitialized;
  bool get hasError => _errorMessage != null;
  String? get errorMessage => _errorMessage;

  // Subscription state
  bool get hasActiveSubscription => _subscriptionData.hasActiveSubscription;
  bool get hasOfferings => _subscriptionData.hasOfferings;
  bool get isEmpty => _subscriptionData.isEmpty;
  List<SubscriptionPackage> get packages => _subscriptionData.sortedPackages;
  SubscriptionPackage? get recommendedPackage => _subscriptionData.recommendedPackage;

  // Purchase state
  bool get isLoading => _purchaseState.isLoading;
  bool get isPurchasing => _purchaseState.isPurchasing;
  bool get isRestoring => _purchaseState.isRestoring;
  bool get isProcessing => _purchaseState.isProcessing;
  bool get shouldDisableUI => PurchaseStateRepository.shouldDisableUI(_purchaseState.state);

  // Benefits
  List<Benefit> get highlightBenefits => BenefitRepository.getHighlightBenefits(_benefits);
  List<Benefit> get professionalBenefits => BenefitRepository.filterByCategory(_benefits, BenefitCategory.professional);
  List<Benefit> get featureBenefits => BenefitRepository.filterByCategory(_benefits, BenefitCategory.feature);
  List<Benefit> get convenienceBenefits => BenefitRepository.filterByCategory(_benefits, BenefitCategory.convenience);
  List<Benefit> get supportBenefits => BenefitRepository.filterByCategory(_benefits, BenefitCategory.support);

  SubscriptionController() {
    _initializeServices();
  }

  void _initializeServices() {
    _revenuecatService = RevenuecatWrapperService();
  }

  Future<void> initialize() async {
    if (_isInitialized) return;

    _updatePurchaseState(PurchaseStateData.loading());

    try {
      // Initialize RevenueCat with dummy API key for now
      await _initializeRevenueCat();

      // Load subscription data
      await _loadSubscriptionData();

      // Load benefits
      await _loadBenefits();

      _isInitialized = true;
      _clearError();
    } catch (e) {
      _setError('Erro ao inicializar: $e');
      _updatePurchaseState(PurchaseStateData.error(e.toString()));
    }

    notifyListeners();
  }

  Future<void> _initializeRevenueCat() async {
    try {
      // Use a placeholder API key for now
      await _revenuecatService.initialize(
        store: Store.appStore,
        apiKey: 'dummy_api_key',
      );
    } catch (e) {
      throw Exception('Falha ao inicializar RevenueCat: $e');
    }
  }

  Future<void> _loadSubscriptionData() async {
    try {
      final offering = await _revenuecatService.getOfferings();
      final customerInfo = await _revenuecatService.getCustomerInfo();
      
      _subscriptionData = SubscriptionRepository.createSubscriptionData(
        offering: offering,
        hasActiveSubscription: customerInfo?.entitlements.active.isNotEmpty ?? false,
        subscriptionEndDate: _getSubscriptionEndDate(customerInfo),
      );

      _updatePurchaseState(PurchaseStateData.idle());
    } catch (e) {
      throw Exception('Falha ao carregar dados de assinatura: $e');
    }
  }

  Future<void> _loadBenefits() async {
    try {
      // Load default benefits for now
      _benefits = BenefitRepository.getDefaultBenefits();
    } catch (e) {
      _benefits = BenefitRepository.getDefaultBenefits();
    }
  }

  DateTime? _getSubscriptionEndDate(CustomerInfo? customerInfo) {
    if (customerInfo?.entitlements.active.isEmpty ?? true) return null;
    
    final entitlement = customerInfo!.entitlements.active.values.first;
    return _stringOrDateTimeToDateTime(entitlement.expirationDate);
  }

  Future<bool> purchasePackage(Package package) async {
    if (_purchaseState.isProcessing) return false;

    _updatePurchaseState(PurchaseStateData.purchasing(package));

    try {
      final result = await _revenuecatService.purchasePackage(package);
      
      if (result.success) {
        _updatePurchaseState(PurchaseStateData.success(package: package));
        await _refreshAfterPurchase();
        return true;
      } else {
        _updatePurchaseState(PurchaseStateData.error(result.error ?? 'Falha na compra'));
        return false;
      }
    } catch (e) {
      _updatePurchaseState(PurchaseStateData.error('Erro durante a compra: $e'));
      return false;
    }
  }

  Future<bool> restorePurchases() async {
    if (_purchaseState.isProcessing) return false;

    _updatePurchaseState(PurchaseStateData.restoring());

    try {
      final result = await _revenuecatService.restorePurchases();
      
      if (result.success) {
        if (result.hasRestoredProducts) {
          _updatePurchaseState(PurchaseStateData.success(isRestore: true));
          await _refreshAfterPurchase();
          return true;
        } else {
          _updatePurchaseState(PurchaseStateData.error('Nenhuma compra encontrada para restaurar', isRestore: true));
          return false;
        }
      } else {
        _updatePurchaseState(PurchaseStateData.error(result.error ?? 'Falha ao restaurar', isRestore: true));
        return false;
      }
    } catch (e) {
      _updatePurchaseState(PurchaseStateData.error('Erro ao restaurar: $e', isRestore: true));
      return false;
    }
  }

  Future<void> _refreshAfterPurchase() async {
    try {
      // Reload subscription data
      await _loadSubscriptionData();
    } catch (e) {
      debugPrint('Error refreshing after purchase: $e');
    }
  }

  Future<void> refresh() async {
    _clearError();
    _updatePurchaseState(PurchaseStateData.loading());

    try {
      await _loadSubscriptionData();
      await _loadBenefits();
      _updatePurchaseState(PurchaseStateData.idle());
    } catch (e) {
      _setError('Erro ao atualizar: $e');
      _updatePurchaseState(PurchaseStateData.error(e.toString()));
    }

    notifyListeners();
  }

  void _updatePurchaseState(PurchaseStateData newState) {
    _purchaseState = newState;
    notifyListeners();

    // Auto-reset certain states after delay
    if (PurchaseStateRepository.shouldAutoReset(newState.state)) {
      final duration = PurchaseStateRepository.getAutoResetDuration(newState.state);
      Future.delayed(duration, () {
        if (_purchaseState == newState) {
          _updatePurchaseState(PurchaseStateData.idle());
        }
      });
    }
  }

  void resetPurchaseState() {
    _updatePurchaseState(PurchaseStateData.idle());
  }

  void _setError(String error) {
    _errorMessage = error;
    debugPrint('SubscriptionController Error: $error');
  }

  void _clearError() {
    _errorMessage = null;
  }

  // Benefit filtering and sorting
  List<Benefit> getBenefitsByCategory(BenefitCategory category) {
    return BenefitRepository.filterByCategory(_benefits, category);
  }

  List<Benefit> getSortedBenefits() {
    return BenefitRepository.sortBenefits(_benefits);
  }

  Map<BenefitCategory, List<Benefit>> getGroupedBenefits() {
    return BenefitRepository.groupByCategory(_benefits);
  }

  // Package utilities
  SubscriptionPackage? getPackageById(String identifier) {
    try {
      return _subscriptionData.packages.firstWhere(
        (package) => package.identifier == identifier,
      );
    } catch (e) {
      return null;
    }
  }

  String getPackageDisplayPrice(Package package) {
    return package.storeProduct.priceString;
  }

  String getPackagePeriod(Package package) {
    return SubscriptionRepository.formatSubscriptionPeriod(package.packageType);
  }

  // Navigation helpers
  void openTermsOfUse() {
    // Placeholder - implement with URL launcher
    debugPrint('Opening Terms of Use');
  }

  void openPrivacyPolicy() {
    // Placeholder - implement with URL launcher
    debugPrint('Opening Privacy Policy');
  }

  // Statistics
  Map<String, dynamic> getSubscriptionStatistics() {
    return SubscriptionRepository.getSubscriptionStatistics(_subscriptionData);
  }

  Map<String, int> getBenefitStatistics() {
    return BenefitRepository.getBenefitStatistics(_benefits);
  }

  String getPurchaseStateDescription() {
    return PurchaseStateRepository.getStateDescription(_purchaseState);
  }

  // Validation
  bool canPurchase(Package package) {
    return !_purchaseState.isProcessing && 
           !hasActiveSubscription &&
           _subscriptionData.packages.any((p) => p.identifier == package.identifier);
  }

  bool canRestore() {
    return !_purchaseState.isProcessing;
  }

  @override
  void dispose() {
    // Clean up any resources if needed
    super.dispose();
  }
}

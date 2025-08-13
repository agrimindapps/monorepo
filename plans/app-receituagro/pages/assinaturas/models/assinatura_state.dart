// Package imports:
import 'package:purchases_flutter/purchases_flutter.dart';

/// Estado específico das assinaturas do app-receituagro
class AssinaturaState {
  final bool isPremium;
  final bool isLoading;
  final bool hasProducts;
  final String? errorMessage;
  final Map<String, dynamic> subscriptionInfo;
  final List<Package> availableProducts;
  final DateTime? lastUpdated;

  const AssinaturaState({
    required this.isPremium,
    required this.isLoading,
    required this.hasProducts,
    this.errorMessage,
    required this.subscriptionInfo,
    required this.availableProducts,
    this.lastUpdated,
  });

  /// Estado inicial
  factory AssinaturaState.initial() {
    return const AssinaturaState(
      isPremium: false,
      isLoading: true,
      hasProducts: false,
      errorMessage: null,
      subscriptionInfo: {},
      availableProducts: [],
      lastUpdated: null,
    );
  }

  /// Estado de carregamento
  factory AssinaturaState.loading() {
    return const AssinaturaState(
      isPremium: false,
      isLoading: true,
      hasProducts: false,
      errorMessage: null,
      subscriptionInfo: {},
      availableProducts: [],
      lastUpdated: null,
    );
  }

  /// Estado de erro
  factory AssinaturaState.error(String message) {
    return AssinaturaState(
      isPremium: false,
      isLoading: false,
      hasProducts: false,
      errorMessage: message,
      subscriptionInfo: {},
      availableProducts: [],
      lastUpdated: DateTime.now(),
    );
  }

  /// Estado de sucesso
  factory AssinaturaState.success({
    required bool isPremium,
    required Map<String, dynamic> subscriptionInfo,
    required List<Package> availableProducts,
  }) {
    return AssinaturaState(
      isPremium: isPremium,
      isLoading: false,
      hasProducts: availableProducts.isNotEmpty,
      errorMessage: null,
      subscriptionInfo: subscriptionInfo,
      availableProducts: availableProducts,
      lastUpdated: DateTime.now(),
    );
  }

  /// Cria uma cópia com novos valores
  AssinaturaState copyWith({
    bool? isPremium,
    bool? isLoading,
    bool? hasProducts,
    String? errorMessage,
    Map<String, dynamic>? subscriptionInfo,
    List<Package>? availableProducts,
    DateTime? lastUpdated,
  }) {
    return AssinaturaState(
      isPremium: isPremium ?? this.isPremium,
      isLoading: isLoading ?? this.isLoading,
      hasProducts: hasProducts ?? this.hasProducts,
      errorMessage: errorMessage ?? this.errorMessage,
      subscriptionInfo: subscriptionInfo ?? this.subscriptionInfo,
      availableProducts: availableProducts ?? this.availableProducts,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  /// Limpa erro
  AssinaturaState clearError() {
    return copyWith(errorMessage: null);
  }

  /// Verifica se há erro
  bool get hasError => errorMessage != null;

  /// Verifica se está carregando
  bool get isInitialLoading => isLoading && lastUpdated == null;

  /// Verifica se tem dados válidos
  bool get hasValidData => !isLoading && !hasError && lastUpdated != null;

  /// Retorna progresso da assinatura (0-100)
  double get subscriptionProgress {
    if (!isPremium) return 0.0;
    
    final percentComplete = subscriptionInfo['percentComplete'];
    if (percentComplete is num) {
      return percentComplete.toDouble();
    }
    return 0.0;
  }

  /// Retorna dias restantes
  int get daysRemaining {
    if (!isPremium) return 0;
    
    final days = subscriptionInfo['daysRemaining'];
    if (days is num) {
      return days.toInt();
    }
    return 0;
  }

  /// Retorna se a assinatura está ativa
  bool get isActive {
    return subscriptionInfo['active'] == true;
  }

  /// Retorna o período da assinatura (mensal, anual, etc.)
  String get subscriptionPeriod {
    if (!isPremium) return 'Não assinante';
    
    final period = subscriptionInfo['period'];
    if (period is String) {
      return period;
    }
    return 'Período indefinido';
  }

  /// Retorna a data de renovação
  DateTime? get renewalDate {
    if (!isPremium) return null;
    
    final renewalDateStr = subscriptionInfo['renewalDate'];
    if (renewalDateStr is String) {
      try {
        return DateTime.parse(renewalDateStr);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  /// Retorna se a assinatura está próxima do vencimento (menos de 7 dias)
  bool get isNearExpiration {
    if (!isPremium) return false;
    return daysRemaining <= 7 && daysRemaining > 0;
  }

  /// Retorna se a assinatura está vencida
  bool get isExpired {
    if (!isPremium) return false;
    return daysRemaining <= 0;
  }

  /// Retorna o preço do produto principal (se disponível)
  String? get mainProductPrice {
    if (availableProducts.isEmpty) return null;
    
    try {
      final mainProduct = availableProducts.first;
      return mainProduct.storeProduct.priceString;
    } catch (e) {
      return null;
    }
  }

  /// Retorna o produto principal
  Package? get mainProduct {
    if (availableProducts.isEmpty) return null;
    return availableProducts.first;
  }

  /// Retorna produtos ordenados por preço
  List<Package> get productsByPrice {
    final products = List<Package>.from(availableProducts);
    products.sort((a, b) => a.storeProduct.price.compareTo(b.storeProduct.price));
    return products;
  }

  @override
  String toString() {
    return 'AssinaturaState('
        'isPremium: $isPremium, '
        'isLoading: $isLoading, '
        'hasProducts: $hasProducts, '
        'errorMessage: $errorMessage, '
        'availableProducts: ${availableProducts.length}, '
        'lastUpdated: $lastUpdated'
        ')';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    
    return other is AssinaturaState &&
        other.isPremium == isPremium &&
        other.isLoading == isLoading &&
        other.hasProducts == hasProducts &&
        other.errorMessage == errorMessage &&
        other.subscriptionInfo == subscriptionInfo &&
        other.availableProducts == availableProducts &&
        other.lastUpdated == lastUpdated;
  }

  @override
  int get hashCode {
    return Object.hash(
      isPremium,
      isLoading,
      hasProducts,
      errorMessage,
      subscriptionInfo,
      availableProducts,
      lastUpdated,
    );
  }
}

/// Extensões úteis para o estado
extension AssinaturaStateExtensions on AssinaturaState {
  /// Retorna mensagem de status amigável
  String get statusMessage {
    if (isLoading) return 'Carregando...';
    if (hasError) return errorMessage ?? 'Erro desconhecido';
    if (!isPremium) return 'Conta gratuita';
    if (isExpired) return 'Assinatura expirada';
    if (isNearExpiration) return 'Assinatura próxima do vencimento';
    return 'Assinatura ativa';
  }

  /// Retorna cor baseada no status
  String get statusColor {
    if (isLoading) return '#FFA500'; // Orange
    if (hasError) return '#FF0000'; // Red
    if (!isPremium) return '#808080'; // Gray
    if (isExpired) return '#FF0000'; // Red
    if (isNearExpiration) return '#FFA500'; // Orange
    return '#00FF00'; // Green
  }

  /// Retorna ícone baseado no status
  String get statusIcon {
    if (isLoading) return 'hourglass';
    if (hasError) return 'error';
    if (!isPremium) return 'account_circle';
    if (isExpired) return 'expired';
    if (isNearExpiration) return 'warning';
    return 'verified';
  }
}

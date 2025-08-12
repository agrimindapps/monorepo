// Package imports:
import 'package:purchases_flutter/purchases_flutter.dart';

class SubscriptionData {
  final Offering? currentOffering;
  final List<SubscriptionPackage> packages;
  final bool hasActiveSubscription;
  final DateTime? subscriptionEndDate;

  const SubscriptionData({
    this.currentOffering,
    required this.packages,
    this.hasActiveSubscription = false,
    this.subscriptionEndDate,
  });

  bool get hasOfferings => currentOffering != null && packages.isNotEmpty;
  bool get isEmpty => packages.isEmpty;
  int get packageCount => packages.length;

  SubscriptionPackage? get recommendedPackage {
    return packages.where((p) => p.isRecommended).firstOrNull ??
           packages.where((p) => p.packageType == PackageType.monthly).firstOrNull;
  }

  List<SubscriptionPackage> get sortedPackages {
    final sorted = List<SubscriptionPackage>.from(packages);
    sorted.sort((a, b) {
      // Recommended packages first
      if (a.isRecommended && !b.isRecommended) return -1;
      if (!a.isRecommended && b.isRecommended) return 1;
      
      // Then by package type order
      final order = {
        PackageType.monthly: 1,
        PackageType.threeMonth: 2,
        PackageType.sixMonth: 3,
        PackageType.annual: 4,
        PackageType.weekly: 5,
      };
      
      return (order[a.packageType] ?? 99).compareTo(order[b.packageType] ?? 99);
    });
    return sorted;
  }

  static SubscriptionData empty() {
    return const SubscriptionData(packages: []);
  }

  SubscriptionData copyWith({
    Offering? currentOffering,
    List<SubscriptionPackage>? packages,
    bool? hasActiveSubscription,
    DateTime? subscriptionEndDate,
  }) {
    return SubscriptionData(
      currentOffering: currentOffering ?? this.currentOffering,
      packages: packages ?? this.packages,
      hasActiveSubscription: hasActiveSubscription ?? this.hasActiveSubscription,
      subscriptionEndDate: subscriptionEndDate ?? this.subscriptionEndDate,
    );
  }
}

class SubscriptionPackage {
  final Package package;
  final bool isRecommended;
  final String? badge;
  final double? discountPercentage;

  const SubscriptionPackage({
    required this.package,
    this.isRecommended = false,
    this.badge,
    this.discountPercentage,
  });

  String get identifier => package.identifier;
  String get title => package.storeProduct.title;
  String get description => package.storeProduct.description;
  String get priceString => package.storeProduct.priceString;
  double get price => package.storeProduct.price;
  String get currencyCode => package.storeProduct.currencyCode;
  PackageType get packageType => package.packageType;

  String get displayTitle {
    switch (packageType) {
      case PackageType.weekly:
        return 'Semanal';
      case PackageType.monthly:
        return 'Mensal';
      case PackageType.threeMonth:
        return 'Trimestral';
      case PackageType.sixMonth:
        return 'Semestral';
      case PackageType.annual:
        return 'Anual';
      case PackageType.lifetime:
        return 'Vitalício';
      default:
        return title;
    }
  }

  String get displayDescription {
    switch (packageType) {
      case PackageType.weekly:
        return 'Renovação semanal';
      case PackageType.monthly:
        return 'Renovação mensal';
      case PackageType.threeMonth:
        return 'Renovação a cada 3 meses';
      case PackageType.sixMonth:
        return 'Renovação a cada 6 meses';
      case PackageType.annual:
        return 'Renovação anual';
      case PackageType.lifetime:
        return 'Pagamento único';
      default:
        return description;
    }
  }

  String? get discountText {
    if (discountPercentage != null && discountPercentage! > 0) {
      return '${discountPercentage!.toInt()}% OFF';
    }
    return null;
  }

  bool get showDiscount => discountPercentage != null && discountPercentage! > 0;

  static SubscriptionPackage fromPackage(Package package) {
    bool isRecommended = false;
    double? discount;
    String? badge;

    // Determine if package is recommended and calculate discount
    switch (package.packageType) {
      case PackageType.monthly:
        isRecommended = true;
        badge = 'Mais Popular';
        break;
      case PackageType.annual:
        discount = 20.0; // Example discount
        badge = 'Melhor Valor';
        break;
      case PackageType.threeMonth:
        discount = 10.0;
        break;
      case PackageType.sixMonth:
        discount = 15.0;
        break;
      default:
        break;
    }

    return SubscriptionPackage(
      package: package,
      isRecommended: isRecommended,
      badge: badge,
      discountPercentage: discount,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'identifier': identifier,
      'title': title,
      'description': description,
      'priceString': priceString,
      'price': price,
      'currencyCode': currencyCode,
      'packageType': packageType.name,
      'isRecommended': isRecommended,
      'badge': badge,
      'discountPercentage': discountPercentage,
    };
  }
}

class SubscriptionRepository {
  static List<SubscriptionPackage> parsePackages(List<Package> packages) {
    return packages.map((package) => SubscriptionPackage.fromPackage(package)).toList();
  }

  static SubscriptionData createSubscriptionData({
    Offering? offering,
    bool hasActiveSubscription = false,
    DateTime? subscriptionEndDate,
  }) {
    if (offering == null || offering.availablePackages.isEmpty) {
      return SubscriptionData.empty();
    }

    final packages = parsePackages(offering.availablePackages);

    return SubscriptionData(
      currentOffering: offering,
      packages: packages,
      hasActiveSubscription: hasActiveSubscription,
      subscriptionEndDate: subscriptionEndDate,
    );
  }

  static Map<String, dynamic> getSubscriptionStatistics(SubscriptionData data) {
    return {
      'totalPackages': data.packageCount,
      'hasRecommended': data.recommendedPackage != null,
      'hasActiveSubscription': data.hasActiveSubscription,
      'hasOfferings': data.hasOfferings,
      'packageTypes': data.packages.map((p) => p.packageType.name).toSet().toList(),
    };
  }

  static String formatSubscriptionPeriod(PackageType type) {
    switch (type) {
      case PackageType.weekly:
        return 'por semana';
      case PackageType.monthly:
        return 'por mês';
      case PackageType.threeMonth:
        return 'por trimestre';
      case PackageType.sixMonth:
        return 'por semestre';
      case PackageType.annual:
        return 'por ano';
      case PackageType.lifetime:
        return 'pagamento único';
      default:
        return 'período';
    }
  }

  static int getPackagePriority(PackageType type) {
    switch (type) {
      case PackageType.monthly:
        return 1;
      case PackageType.annual:
        return 2;
      case PackageType.threeMonth:
        return 3;
      case PackageType.sixMonth:
        return 4;
      case PackageType.weekly:
        return 5;
      case PackageType.lifetime:
        return 6;
      default:
        return 99;
    }
  }
}

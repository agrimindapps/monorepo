import 'package:equatable/equatable.dart';

import 'market_entity.dart';

/// Market Filter Entity
/// 
/// Represents filtering criteria for market searches and listings
class MarketFilter extends Equatable {
  final List<MarketType>? types;
  final List<String>? exchanges;
  final PriceRange? priceRange;
  final VolumeRange? volumeRange;
  final PerformanceFilter? performance;
  final String? searchQuery;
  final SortOption sortBy;
  final SortOrder sortOrder;
  final bool onlyFavorites;

  const MarketFilter({
    types,
    exchanges,
    priceRange,
    volumeRange,
    performance,
    searchQuery,
    sortBy = SortOption.name,
    sortOrder = SortOrder.ascending,
    onlyFavorites = false,
  });

  /// Create a copy with updated values
  MarketFilter copyWith({
    List<MarketType>? types,
    List<String>? exchanges,
    PriceRange? priceRange,
    VolumeRange? volumeRange,
    PerformanceFilter? performance,
    String? searchQuery,
    SortOption? sortBy,
    SortOrder? sortOrder,
    bool? onlyFavorites,
  }) {
    return MarketFilter(
      types: types ?? types,
      exchanges: exchanges ?? exchanges,
      priceRange: priceRange ?? priceRange,
      volumeRange: volumeRange ?? volumeRange,
      performance: performance ?? performance,
      searchQuery: searchQuery ?? searchQuery,
      sortBy: sortBy ?? sortBy,
      sortOrder: sortOrder ?? sortOrder,
      onlyFavorites: onlyFavorites ?? onlyFavorites,
    );
  }

  /// Check if filter has any active criteria
  bool get hasActiveFilters {
    return types?.isNotEmpty == true ||
           exchanges?.isNotEmpty == true ||
           priceRange != null ||
           volumeRange != null ||
           performance != null ||
           searchQuery?.isNotEmpty == true ||
           onlyFavorites;
  }

  /// Get human-readable description of active filters
  List<String> get activeFiltersDescription {
    final descriptions = <String>[];
    
    if (types?.isNotEmpty == true) {
      descriptions.add('Tipos: ${types!.map((t) => t.displayName).join(", ")}');
    }
    
    if (exchanges?.isNotEmpty == true) {
      descriptions.add('Bolsas: ${exchanges!.join(", ")}');
    }
    
    if (priceRange != null) {
      descriptions.add(priceRange!.description);
    }
    
    if (volumeRange != null) {
      descriptions.add(volumeRange!.description);
    }
    
    if (performance != null) {
      descriptions.add(performance!.description);
    }
    
    if (searchQuery?.isNotEmpty == true) {
      descriptions.add('Busca: "$searchQuery"');
    }
    
    if (onlyFavorites) {
      descriptions.add('Apenas Favoritos');
    }
    
    return descriptions;
  }

  @override
  List<Object?> get props => [
        types,
        exchanges,
        priceRange,
        volumeRange,
        performance,
        searchQuery,
        sortBy,
        sortOrder,
        onlyFavorites,
      ];
}

/// Price Range Filter
class PriceRange extends Equatable {
  final double? minPrice;
  final double? maxPrice;
  final String currency;

  const PriceRange({
    minPrice,
    maxPrice,
    currency = 'BRL',
  });

  String get description {
    if (minPrice != null && maxPrice != null) {
      return 'Preço: ${minPrice!.toStringAsFixed(2)} - ${maxPrice!.toStringAsFixed(2)} $currency';
    } else if (minPrice != null) {
      return 'Preço: > ${minPrice!.toStringAsFixed(2)} $currency';
    } else if (maxPrice != null) {
      return 'Preço: < ${maxPrice!.toStringAsFixed(2)} $currency';
    }
    return 'Preço: Todos';
  }

  @override
  List<Object?> get props => [minPrice, maxPrice, currency];
}

/// Volume Range Filter
class VolumeRange extends Equatable {
  final double? minVolume;
  final double? maxVolume;

  const VolumeRange({
    minVolume,
    maxVolume,
  });

  String get description {
    if (minVolume != null && maxVolume != null) {
      return 'Volume: ${_formatVolume(minVolume!)} - ${_formatVolume(maxVolume!)}';
    } else if (minVolume != null) {
      return 'Volume: > ${_formatVolume(minVolume!)}';
    } else if (maxVolume != null) {
      return 'Volume: < ${_formatVolume(maxVolume!)}';
    }
    return 'Volume: Todos';
  }

  String _formatVolume(double volume) {
    if (volume >= 1000000) {
      return '${(volume / 1000000).toStringAsFixed(1)}M';
    } else if (volume >= 1000) {
      return '${(volume / 1000).toStringAsFixed(1)}K';
    }
    return volume.toStringAsFixed(0);
  }

  @override
  List<Object?> get props => [minVolume, maxVolume];
}

/// Performance Filter
class PerformanceFilter extends Equatable {
  final PerformanceType type;
  final double threshold;

  const PerformanceFilter({
    required type,
    required threshold,
  });

  String get description {
    switch (type) {
      case PerformanceType.gainers:
        return 'Alta: > +${threshold.toStringAsFixed(1)}%';
      case PerformanceType.losers:
        return 'Queda: < -${threshold.toStringAsFixed(1)}%';
      case PerformanceType.stable:
        return 'Estável: ±${threshold.toStringAsFixed(1)}%';
      case PerformanceType.volatile:
        return 'Volátil: > ±${threshold.toStringAsFixed(1)}%';
    }
  }

  @override
  List<Object?> get props => [type, threshold];
}

/// Performance Filter Types
enum PerformanceType {
  gainers('Em Alta'),
  losers('Em Queda'),
  stable('Estáveis'),
  volatile('Voláteis');

  const PerformanceType(displayName);
  final String displayName;
}

/// Sort Options
enum SortOption {
  name('Nome'),
  price('Preço'),
  change('Variação'),
  volume('Volume'),
  lastUpdated('Última Atualização');

  const SortOption(displayName);
  final String displayName;
}

/// Sort Orders
enum SortOrder {
  ascending('Crescente'),
  descending('Decrescente');

  const SortOrder(displayName);
  final String displayName;
}
import 'package:app_agrihurbi/core/error/failures.dart';

/// Market-specific failures
abstract class MarketFailure extends Failure {
  const MarketFailure({required super.message, super.code, super.details});
}

/// Network-related market failures
class MarketNetworkFailure extends MarketFailure {
  const MarketNetworkFailure({super.message = 'Erro de conexão ao carregar dados dos mercados'});
}

/// Cache-related market failures
class MarketCacheFailure extends MarketFailure {
  const MarketCacheFailure({super.message = 'Erro ao acessar cache de mercados'});
}

/// Server-related market failures
class MarketServerFailure extends MarketFailure {
  const MarketServerFailure({super.message = 'Erro no servidor de mercados'});
}

/// Data parsing failures
class MarketDataFailure extends MarketFailure {
  const MarketDataFailure({super.message = 'Erro ao processar dados dos mercados'});
}

/// Not found failures
class MarketNotFoundFailure extends MarketFailure {
  const MarketNotFoundFailure({super.message = 'Mercado não encontrado'});
}

/// Invalid filter failures
class InvalidMarketFilterFailure extends MarketFailure {
  const InvalidMarketFilterFailure({super.message = 'Filtro de mercado inválido'});
}

/// Market closed failures
class MarketClosedFailure extends MarketFailure {
  const MarketClosedFailure({super.message = 'Mercado está fechado'});
}

/// Insufficient data failures
class InsufficientMarketDataFailure extends MarketFailure {
  const InsufficientMarketDataFailure({super.message = 'Dados insuficientes para análise'});
}

/// API limit failures
class MarketAPILimitFailure extends MarketFailure {
  const MarketAPILimitFailure({super.message = 'Limite de requisições da API atingido'});
}

/// Favorites failures
class MarketFavoritesFailure extends MarketFailure {
  const MarketFavoritesFailure({super.message = 'Erro ao gerenciar mercados favoritos'});
}

/// Subscription required failures
class MarketSubscriptionRequiredFailure extends MarketFailure {
  const MarketSubscriptionRequiredFailure({super.message = 'Assinatura Premium necessária para acessar dados avançados'});
}

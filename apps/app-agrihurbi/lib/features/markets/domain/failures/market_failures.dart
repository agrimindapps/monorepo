import 'package:app_agrihurbi/core/error/failures.dart';

/// Market-specific failures
abstract class MarketFailure extends Failure {
  const MarketFailure({required super.message, super.code, super.details});
}

/// Network-related market failures
class MarketNetworkFailure extends MarketFailure {
  const MarketNetworkFailure({String message = 'Erro de conexão ao carregar dados dos mercados'}) : super(message: message);
}

/// Cache-related market failures
class MarketCacheFailure extends MarketFailure {
  const MarketCacheFailure({String message = 'Erro ao acessar cache de mercados'}) : super(message: message);
}

/// Server-related market failures
class MarketServerFailure extends MarketFailure {
  const MarketServerFailure({String message = 'Erro no servidor de mercados'}) : super(message: message);
}

/// Data parsing failures
class MarketDataFailure extends MarketFailure {
  const MarketDataFailure({String message = 'Erro ao processar dados dos mercados'}) : super(message: message);
}

/// Not found failures
class MarketNotFoundFailure extends MarketFailure {
  const MarketNotFoundFailure({String message = 'Mercado não encontrado'}) : super(message: message);
}

/// Invalid filter failures
class InvalidMarketFilterFailure extends MarketFailure {
  const InvalidMarketFilterFailure({String message = 'Filtro de mercado inválido'}) : super(message: message);
}

/// Market closed failures
class MarketClosedFailure extends MarketFailure {
  const MarketClosedFailure({String message = 'Mercado está fechado'}) : super(message: message);
}

/// Insufficient data failures
class InsufficientMarketDataFailure extends MarketFailure {
  const InsufficientMarketDataFailure({String message = 'Dados insuficientes para análise'}) : super(message: message);
}

/// API limit failures
class MarketAPILimitFailure extends MarketFailure {
  const MarketAPILimitFailure({String message = 'Limite de requisições da API atingido'}) : super(message: message);
}

/// Favorites failures
class MarketFavoritesFailure extends MarketFailure {
  const MarketFavoritesFailure({String message = 'Erro ao gerenciar mercados favoritos'}) : super(message: message);
}

/// Subscription required failures
class MarketSubscriptionRequiredFailure extends MarketFailure {
  const MarketSubscriptionRequiredFailure({String message = 'Assinatura Premium necessária para acessar dados avançados'}) : super(message: message);
}
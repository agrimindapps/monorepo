/// Application constants
class AppConstants {
  static const String appName = 'AgriHurbi';
  static const String appVersion = '1.0.0';
  static const String baseUrl = 'https://api.agrihurbi.com';
  static const String apiVersion = 'v1';
  static const String apiTimeout = '30000'; // 30 seconds
  static const String accessTokenKey = 'access_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userDataKey = 'user_data';
  static const String settingsKey = 'app_settings';
  static const String themeKey = 'theme_mode';
  static const String userBox = 'user_box';
  static const String livestockBox = 'livestock_box';
  static const String calculatorsBox = 'calculators_box';
  static const String weatherBox = 'weather_box';
  static const String settingsBox = 'settings_box';
  static const int defaultPageSize = 20;
  static const int maxRetryAttempts = 3;
  static const Duration cacheTimeout = Duration(hours: 24);
  static const String weatherApiKey = 'YOUR_WEATHER_API_KEY';
  static const List<String> calculatorTypes = [
    'nutrition',
    'breeding',
    'finance',
    'feed',
    'weight',
    'medication',
    'feed_conversion',
    'milk_production',
    'pregnancy',
    'vaccination_schedule',
    'pasture_management',
    'water_consumption',
    'growth_rate',
    'cost_benefit',
    'mortality_rate',
    'reproduction_efficiency',
    'forage_quality',
    'equipment_depreciation',
    'labor_cost',
    'profit_margin',
  ];
  static const List<String> livestockCategories = [
    'cattle',
    'horses',
    'sheep',
    'goats',
    'pigs',
    'poultry',
  ];
  static const List<String> equipmentCategories = [
    'tractors',
    'implements',
    'tools',
    'machinery',
    'irrigation',
    'storage',
  ];
}

/// Route names for navigation
class RouteNames {
  static const String splash = '/splash';
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
  static const String profile = '/profile';
  static const String settings = '/settings';
  static const String livestock = '/livestock';
  static const String livestockDetail = '/livestock/detail';
  static const String addLivestock = '/livestock/add';
  static const String editLivestock = '/livestock/edit';
  static const String calculators = '/calculators';
  static const String calculatorDetail = '/calculators/detail';
  static const String weather = '/weather';
  static const String weatherDetail = '/weather/detail';
  static const String news = '/news';
  static const String newsDetail = '/news/detail';
  static const String markets = '/markets';
  static const String marketDetail = '/markets/detail';
}

/// Error messages
class ErrorMessages {
  static const String networkError = 'Erro de conexão. Verifique sua internet.';
  static const String serverError = 'Erro no servidor. Tente novamente mais tarde.';
  static const String authError = 'Erro de autenticação. Faça login novamente.';
  static const String cacheError = 'Erro no cache local.';
  static const String generalError = 'Algo deu errado. Tente novamente.';
  static const String validationError = 'Dados inválidos. Verifique os campos.';
  static const String notFoundError = 'Recurso não encontrado.';
  static const String timeoutError = 'Tempo limite excedido.';
}

/// Success messages
class SuccessMessages {
  static const String loginSuccess = 'Login realizado com sucesso!';
  static const String registerSuccess = 'Cadastro realizado com sucesso!';
  static const String updateSuccess = 'Atualização realizada com sucesso!';
  static const String deleteSuccess = 'Exclusão realizada com sucesso!';
  static const String saveSuccess = 'Dados salvos com sucesso!';
}

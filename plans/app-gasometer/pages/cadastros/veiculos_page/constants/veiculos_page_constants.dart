/// Constantes centralizadas para VeiculosPage
///
/// Organizadas por categoria para facilitar manutenção e futuras alterações
class VeiculosPageConstants {
  // Private constructor to prevent instantiation
  const VeiculosPageConstants._();

  /// Tipos de combustível disponíveis (índices)
  static const int combustivelGasolina = 0;
  static const int combustivelEtanol = 1;
  static const int combustivelDiesel = 2;
  static const int combustivelGnv = 3;
  static const int combustivelEletrico = 4;
  static const int combustivelHibrido = 5;

  /// ========================================
  /// UI DIMENSIONS - Dimensões da Interface
  /// ========================================

  /// Breakpoints para responsividade
  static const double mobileBreakpoint = 600.0;
  static const double tabletBreakpoint = 1024.0;
  static const double desktopMinWidth = 1024.0;

  /// Grid cross axis count por largura de tela
  static const int gridMobileColumns = 1;
  static const int gridTabletColumns = 2;
  static const int gridSmallDesktopColumns = 3;
  static const int gridLargeDesktopColumns = 4;

  /// Larguras específicas para grid
  static const double gridTabletMinWidth = 600.0;
  static const double gridSmallDesktopMinWidth = 900.0;
  static const double gridLargeDesktopMinWidth = 1200.0;

  /// Espaçamentos padrão
  static const double standardSpacing = 16.0;
  static const double smallSpacing = 8.0;
  static const double largeSpacing = 24.0;

  /// ========================================
  /// DURATIONS - Durações de Animações
  /// ========================================

  /// Debounce para workers reativos
  static const Duration workerDebounceDelay = Duration(milliseconds: 100);

  /// Duração de snackbars por severidade
  static const Duration snackbarNormalDuration = Duration(seconds: 5);
  static const Duration snackbarCriticalDuration = Duration(seconds: 10);

  /// Duração de animações
  static const Duration fastAnimation = Duration(milliseconds: 150);
  static const Duration standardAnimation = Duration(milliseconds: 300);
  static const Duration slowAnimation = Duration(milliseconds: 500);

  /// ========================================
  /// COLORS & OPACITY - Cores e Transparências
  /// ========================================

  /// Valores de alpha para cores
  static const double lowOpacity = 0.3;
  static const double mediumOpacity = 0.6;
  static const double highOpacity = 0.8;
  static const double almostOpaque = 0.9;

  /// ========================================
  /// CSV EXPORT - Exportação CSV
  /// ========================================

  /// Cabeçalho do CSV
  static const String csvHeader =
      'Marca,Modelo,Ano,Placa,Odometro Inicial,Odometro Atual,Combustivel,Renavan,Chassi,Cor,Vendido,Valor Venda\n';

  /// Caracteres especiais para escape em CSV
  static const String csvComma = ',';
  static const String csvQuote = '"';
  static const String csvNewline = '\n';
  static const String csvEscapedQuote = '"""';

  /// ========================================
  /// FUEL TYPES - Tipos de Combustível
  /// ========================================

  /// Mapeamento de índices para nomes de combustível
  static const Map<int, String> combustivelNames = {
    combustivelGasolina: 'Gasolina',
    combustivelEtanol: 'Etanol',
    combustivelDiesel: 'Diesel',
    combustivelGnv: 'GNV',
    combustivelEletrico: 'Elétrico',
    combustivelHibrido: 'Híbrido',
  };

  /// Nome padrão para combustível desconhecido
  static const String combustivelDesconhecido = 'Desconhecido';

  /// ========================================
  /// UI TAGS - Tags para GetX Updates
  /// ========================================

  /// Tags para atualizações específicas da UI
  static const String vehicleListTag = 'vehicle_list';
  static const String headerTag = 'header';
  static const String gridTag = 'grid';
  static const String loadingTag = 'loading';

  /// ========================================
  /// VALIDATION - Validação
  /// ========================================

  /// Valores de validação
  static const String emptyString = '';
  static const String defaultSelectedId = '';

  /// Separadores e formatação
  static const String csvSeparator = ',';
  static const String csvRowSeparator = '\n';

  /// ========================================
  /// ERROR MESSAGES - Mensagens de Erro
  /// ========================================

  /// Contextos para error handler
  static const String contextDependencyInit = 'Inicialização de dependências';
  static const String contextVehicleLoad = 'Carregamento de veículos';
  static const String contextVehicleCreate = 'Criação de veículo';
  static const String contextVehicleUpdate = 'Atualização de veículo';
  static const String contextVehicleDelete = 'Remoção de veículo';
  static const String contextOdometerUpdate = 'Atualização de odômetro';
  static const String contextCsvExport = 'Exportação CSV';
  static const String contextCleanup = 'Cleanup de observables';
  static const String contextLaunchCheck = 'Verificação de lançamentos';

  /// ========================================
  /// DEPRECATED MESSAGES - Mensagens de Deprecação
  /// ========================================

  /// Mensagem para método _handleError depreciado
  static const String deprecatedHandleErrorMessage =
      'Use VeiculosErrorHandler.handleError() instead';

  /// ========================================
  /// HELPER METHODS - Métodos Auxiliares
  /// ========================================

  /// Obter nome do combustível por índice
  static String getCombustivelName(int index) {
    return combustivelNames[index] ?? combustivelDesconhecido;
  }

  /// Verificar se é uma largura de mobile
  static bool isMobileWidth(double width) {
    return width < mobileBreakpoint;
  }

  /// Verificar se é uma largura de tablet
  static bool isTabletWidth(double width) {
    return width >= mobileBreakpoint && width < tabletBreakpoint;
  }

  /// Verificar se é uma largura de desktop
  static bool isDesktopWidth(double width) {
    return width >= tabletBreakpoint;
  }

  /// Obter número de colunas do grid baseado na largura
  static int getGridColumns(double width) {
    if (width < gridTabletMinWidth) return gridMobileColumns;
    if (width < gridSmallDesktopMinWidth) return gridTabletColumns;
    if (width < gridLargeDesktopMinWidth) return gridSmallDesktopColumns;
    return gridLargeDesktopColumns;
  }

  /// Verificar se um valor está vazio
  static bool isEmpty(String? value) {
    return value == null || value == emptyString;
  }

  /// Verificar se string precisa de escape para CSV
  static bool needsCsvEscape(String field) {
    return field.contains(csvComma) ||
        field.contains(csvQuote) ||
        field.contains(csvNewline);
  }

  /// ========================================
  /// INTERNATIONALIZATION PREPARATION
  /// ========================================

  /// Chaves para futuras traduções
  /// (Para preparar migração para i18n)
  static const Map<String, String> i18nKeys = {
    // Fuel types
    'fuel_gasoline': 'Gasolina',
    'fuel_ethanol': 'Etanol',
    'fuel_diesel': 'Diesel',
    'fuel_gnv': 'GNV',
    'fuel_electric': 'Elétrico',
    'fuel_hybrid': 'Híbrido',
    'fuel_unknown': 'Desconhecido',

    // CSV headers
    'csv_brand': 'Marca',
    'csv_model': 'Modelo',
    'csv_year': 'Ano',
    'csv_plate': 'Placa',
    'csv_initial_odometer': 'Odometro Inicial',
    'csv_current_odometer': 'Odometro Atual',
    'csv_fuel': 'Combustivel',
    'csv_renavan': 'Renavan',
    'csv_chassis': 'Chassi',
    'csv_color': 'Cor',
    'csv_sold': 'Vendido',
    'csv_sale_value': 'Valor Venda',

    // Error contexts
    'error_dependency_init': 'Inicialização de dependências',
    'error_vehicle_load': 'Carregamento de veículos',
    'error_vehicle_create': 'Criação de veículo',
    'error_vehicle_update': 'Atualização de veículo',
    'error_vehicle_delete': 'Remoção de veículo',
    'error_odometer_update': 'Atualização de odômetro',
    'error_csv_export': 'Exportação CSV',
    'error_cleanup': 'Cleanup de observables',
    'error_launch_check': 'Verificação de lançamentos',
  };
}

/// Constantes organizadas para o módulo de combustível
class FuelConstants {
  
  FuelConstants._();
  static const double minLiters = 0.001;
  static const double maxLiters = 999.999;
  static const double minPricePerLiter = 0.1;
  static const double maxPricePerLiter = 9.999;
  static const double maxTotalPrice = 9999.99;
  static const double maxOdometer = 9999999.0;
  static const String decimalSeparator = ',';
  static const String dotSeparator = '.';
  static const int litersDecimals = 3;
  static const int priceDecimals = 3;
  static const int totalDecimals = 2;
  static const int odometerDecimals = 1;
  static const int maxYearsBack = 5;
  static const int maxGasStationNameLength = 100;
  static const int minGasStationNameLength = 2;
  static const int maxNotesLength = 500;
  static const int maxCacheSize = 100;
  static const int litersDebounceMs = 300;
  static const int priceDebounceMs = 300;
  static const int odometerDebounceMs = 200;
  static const double maxTankOverfill = 1.1; // 10% acima da capacidade
  static const double maxPriceVariation = 2.0; // Variação máxima de preço esperada
  static const double maxOdometerDifference = 2000.0; // Diferença máxima entre registros
  static const double maxCalculationDifference = 0.01; // Diferença de arredondamento
  static const String litersPattern = r'^\d{0,4}[,.]?\d{0,3}$';
  static const String pricePattern = r'^\d{0,1}[,.]?\d{0,3}$';
  static const String odometerPattern = r'^\d{0,6}[,.]?\d{0,1}$';
  static const String gasStationNamePattern = r'^[a-zA-ZÀ-ÿ0-9\s\-\.&]+$';
  static const String requiredFieldError = 'Campo obrigatório';
  static const String invalidValueError = 'Valor inválido';
  static const String tooHighValueError = 'Valor muito alto';
  static const String tooLowValueError = 'Valor muito baixo';
  static const String futureDateError = 'Data não pode ser futura';
  static const String tooOldDateError = 'Data muito antiga';
  static const String fuelTypeLabel = 'Tipo de Combustível';
  static const String dateLabel = 'Data';
  static const String fullTankLabel = 'Tanque Cheio';
  static const String fullTankSubtitle = 'Marque se encheu completamente o tanque';
  static const String litersLabel = 'Litros';
  static const String pricePerLiterLabel = 'Preço/Litro';
  static const String totalPriceLabel = 'Valor Total';
  static const String odometerLabel = 'Odômetro';
  static const String gasStationLabel = 'Nome do Posto (opcional)';
  static const String gasStationHint = 'Ex: Shell, Petrobras, Ipiranga...';
  static const String gasStationBrandLabel = 'Bandeira/Rede (opcional)';
  static const String gasStationBrandHint = 'Ex: BR, Shell Select...';
  static const String notesLabel = 'Observações (opcional)';
  static const String notesHint = 'Adicione comentários sobre este abastecimento...';
  static const String noVehicleSelected = 'Nenhum veículo selecionado';
  static const String selectVehicleMessage = 'Selecione um veículo primeiro para registrar o abastecimento.';
  static const String loadingFormMessage = 'Carregando formulário...';
  static const String fuelInfoSection = 'Informações do Combustível';
  static const String valuesSection = 'Valores';
  static const String locationSection = 'Local do Abastecimento';
  static const String notesSection = 'Observações';
  static const String litersPlaceholder = '0,000';
  static const String pricePlaceholder = '0,000';
  static const String odometerPlaceholder = '0,0';
  static const String litersUnit = 'L';
  static const String kilometerUnit = 'km';
  static const String currencySymbol = 'R\$';
  static const String consumptionUnit = 'km/l';
  static const Map<String, Map<String, dynamic>> fuelTypeProperties = {
    'gasoline': {
      'displayName': 'Gasolina',
      'color': 0xFF4CAF50,
      'density': 0.74, // kg/L
      'energyContent': 32.0, // MJ/L
    },
    'ethanol': {
      'displayName': 'Etanol',
      'color': 0xFF2196F3,
      'density': 0.79, // kg/L
      'energyContent': 21.2, // MJ/L
    },
    'diesel': {
      'displayName': 'Diesel',
      'color': 0xFF795548,
      'density': 0.83, // kg/L
      'energyContent': 35.8, // MJ/L
    },
    'gas': {
      'displayName': 'Gás Natural',
      'color': 0xFF9C27B0,
      'density': 0.65, // kg/L equivalent
      'energyContent': 25.5, // MJ/L equivalent
    },
    'hybrid': {
      'displayName': 'Híbrido',
      'color': 0xFF607D8B,
      'density': 0.74, // Average
      'energyContent': 32.0, // Average
    },
    'electric': {
      'displayName': 'Elétrico',
      'color': 0xFF03DAC6,
      'density': 0.0, // Not applicable
      'energyContent': 3.6, // MJ/kWh equivalent
    },
  };
  static const String formStatusIdle = 'idle';
  static const String formStatusLoading = 'loading';
  static const String formStatusError = 'error';
  static const String formStatusSuccess = 'success';
  static const double formMaxHeight = 600.0;
  static const double sectionSpacing = 16.0;
  static const double fieldSpacing = 12.0;
  static const double buttonHeight = 48.0;
  static const int animationDurationMs = 250;
  static const int loadingMinDurationMs = 500; // Previne instanciação
}
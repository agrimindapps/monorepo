/// Constants for the medications page UI elements, dimensions, and timings
class MedicationsConstants {
  // Private constructor to prevent instantiation
  MedicationsConstants._();

  // Tab configuration
  static const int tabCount = 4;
  
  // Icon dimensions
  static const double tabIconSize = 16.0;
  static const double errorIconSize = 64.0;
  
  // Spacing and padding
  static const double pageContentPadding = 16.0;
  static const double searchFiltersSpacing = 8.0;
  static const double errorContentSpacing = 16.0;
  static const double dialogContentSpacing = 16.0;
  
  // List item dimensions
  static const double medicationCardHeight = 120.0;
  static const double cardBottomSpacing = 8.0;
  
  // Text sizes
  static const double errorTextSize = 16.0;
  
  // Timeouts
  static const Duration loadingTimeout = Duration(seconds: 10);
  
  // TextField properties
  static const int reasonTextFieldMaxLines = 3;
  
  // Strings
  static const String allMedicationsTitle = 'Medicamentos';
  static const String petMedicationsTitle = 'Medicamentos do Pet';
  static const String searchHintText = 'Buscar medicamentos...';
  static const String addMedicationTooltip = 'Adicionar Medicamento';
  static const String refreshTooltip = 'Atualizar';
  
  // Tab titles
  static const String allTabTitle = 'Todos';
  static const String activeTabTitle = 'Ativos';
  static const String expiringTabTitle = 'Vencendo';
  static const String statisticsTabTitle = 'Estatísticas';
  
  // Empty state messages
  static const String noActiveMedications = 'Nenhum medicamento ativo no momento';
  static const String noExpiringMedications = 'Nenhum medicamento próximo ao vencimento';
  static const String noMedicationsFound = 'Nenhum medicamento encontrado';
  
  // Error and action messages
  static const String retryButtonText = 'Tentar Novamente';
  static const String cancelButtonText = 'Cancelar';
  static const String deleteButtonText = 'Excluir';
  static const String discontinueButtonText = 'Descontinuar';
  
  // Dialog titles
  static const String deleteMedicationTitle = 'Excluir Medicamento';
  static const String discontinueMedicationTitle = 'Descontinuar Medicamento';
  
  // Success messages
  static const String medicationDeletedMessage = 'Medicamento excluído com sucesso';
  static const String medicationDiscontinuedMessage = 'Medicamento descontinuado';
  
  // Input labels
  static const String discontinuationReasonLabel = 'Motivo da descontinuação';
  
  // Routes
  static const String addMedicationRoute = '/medications/add';
  static const String detailsRoute = '/medications/details';
  static const String editRoute = '/medications/edit';
}
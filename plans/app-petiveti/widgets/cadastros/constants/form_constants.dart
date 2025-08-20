/// Constantes gerais para todos os formulários de cadastro
class FormConstants {
  // Durações de animação
  static const Duration shortAnimation = Duration(milliseconds: 150);
  static const Duration mediumAnimation = Duration(milliseconds: 300);
  static const Duration longAnimation = Duration(milliseconds: 500);

  // Timeouts
  static const Duration saveTimeout = Duration(seconds: 30);
  static const Duration loadTimeout = Duration(seconds: 10);
  static const Duration autoSaveDelay = Duration(seconds: 2);

  // Limites de caracteres
  static const int shortTextLimit = 50;
  static const int mediumTextLimit = 100;
  static const int longTextLimit = 500;
  static const int observationsLimit = 1000;

  // Valores monetários
  static const double minCurrencyValue = 0.0;
  static const double maxCurrencyValue = 99999.99;

  // Validação
  static const int minNameLength = 2;
  static const int maxNameLength = 100;
  static const int minDescriptionLength = 3;

  // Mensagens padrão
  static const String requiredFieldMessage = 'Este campo é obrigatório';
  static const String invalidValueMessage = 'Valor inválido';
  static const String saveSuccessMessage = 'Salvo com sucesso!';
  static const String saveErrorMessage = 'Erro ao salvar. Tente novamente.';
  static const String deleteConfirmMessage = 'Tem certeza que deseja excluir?';
  static const String unsavedChangesMessage = 'Há alterações não salvas. Deseja continuar?';
  static const String loadingMessage = 'Carregando...';
  static const String savingMessage = 'Salvando...';
  static const String deletingMessage = 'Excluindo...';

  // Labels padrão
  static const String saveLabel = 'Salvar';
  static const String cancelLabel = 'Cancelar';
  static const String deleteLabel = 'Excluir';
  static const String duplicateLabel = 'Duplicar';
  static const String editLabel = 'Editar';
  static const String confirmLabel = 'Confirmar';
  static const String retryLabel = 'Tentar Novamente';
  static const String closeLabel = 'Fechar';

  // Placeholders
  static const String selectAnimalPlaceholder = 'Selecione um animal';
  static const String selectDatePlaceholder = 'Selecione uma data';
  static const String enterValuePlaceholder = 'Digite o valor';
  static const String enterDescriptionPlaceholder = 'Digite uma descrição';
  static const String enterObservationPlaceholder = 'Digite suas observações';

  // Formatos
  static const String dateFormat = 'dd/MM/yyyy';
  static const String dateTimeFormat = 'dd/MM/yyyy HH:mm';
  static const String currencyFormat = 'R\$ #,##0.00';

  // Responsividade
  static const double mobileBreakpoint = 600;
  static const double tabletBreakpoint = 900;
  static const double desktopBreakpoint = 1200;

  // Opacidade
  static const double disabledOpacity = 0.5;
  static const double overlayOpacity = 0.6;
  static const double shimmerOpacity = 0.3;

  // Ícones padrão
  static const String defaultAnimalIcon = '🐾';
  static const String successIcon = '✅';
  static const String errorIcon = '❌';
  static const String warningIcon = '⚠️';
  static const String infoIcon = 'ℹ️';

  // Configurações de debounce
  static const Duration searchDebounce = Duration(milliseconds: 500);
  static const Duration validationDebounce = Duration(milliseconds: 300);

  // Limites de lista
  static const int maxRecentItems = 10;
  static const int maxSearchResults = 50;
  static const int itemsPerPage = 20;

  // Configurações de cache
  static const Duration cacheExpiration = Duration(hours: 24);
  static const int maxCacheSize = 100;
}
/// Application constants
/// Static values used throughout the app
class AppConstants {
  AppConstants._();

  // Routes
  static const String homeRoute = '/';
  static const String loginRoute = '/login';
  static const String signUpRoute = '/signup';
  static const String forgotPasswordRoute = '/forgot-password';
  static const String settingsRoute = '/settings';
  static const String settingsPageRoute = '/settings-page';
  static const String profileRoute = '/profile';
  static const String notificationsRoute = '/notifications-settings';
  static const String promoRoute = '/promo';
  static const String premiumRoute = '/premium';
  static const String listDetailRoute = '/list/:id';
  static const String privacyPolicyRoute = '/privacy-policy';
  static const String termsOfServiceRoute = '/terms-of-service';
  static const String accountDeletionPolicyRoute = '/account-deletion-policy';

  // Asset Paths
  static const String imagesPath = 'assets/images/';
  static const String iconsPath = 'assets/icons/';
  static const String logoPath = '${imagesPath}logo.png';

  // Error Messages
  static const String genericError = 'Ocorreu um erro. Tente novamente.';
  static const String networkError = 'Erro de conexão. Verifique sua internet.';
  static const String notFoundError = 'Item não encontrado.';
  static const String validationError = 'Dados inválidos. Verifique os campos.';
  static const String unauthorizedError = 'Acesso não autorizado.';

  // Success Messages
  static const String saveSuccess = 'Salvo com sucesso!';
  static const String updateSuccess = 'Atualizado com sucesso!';
  static const String deleteSuccess = 'Removido com sucesso!';

  // Confirmation Messages
  static const String deleteConfirmation = 'Tem certeza que deseja remover?';
  static const String discardChangesConfirmation = 'Descartar alterações?';

  // Button Labels
  static const String save = 'Salvar';
  static const String cancel = 'Cancelar';
  static const String delete = 'Excluir';
  static const String edit = 'Editar';
  static const String add = 'Adicionar';
  static const String confirm = 'Confirmar';
  static const String retry = 'Tentar Novamente';

  // Loading Messages
  static const String loading = 'Carregando...';
  static const String saving = 'Salvando...';
  static const String deleting = 'Removendo...';
  static const String syncing = 'Sincronizando...';

  // Validation Messages
  static const String requiredField = 'Campo obrigatório';
  static const String invalidEmail = 'Email inválido';
  static const String passwordTooShort = 'Senha muito curta';
  static const String nameTooShort = 'Nome muito curto (mínimo 2 caracteres)';

  // Date Formats
  static const String dateFormat = 'dd/MM/yyyy';
  static const String dateTimeFormat = 'dd/MM/yyyy HH:mm';
  static const String timeFormat = 'HH:mm';

  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;
}

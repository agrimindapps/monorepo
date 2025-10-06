/// **Centralized String Constants for Comments Feature**
/// 
/// This class provides all user-facing strings for the comments feature,
/// prepared for future internationalization (i18n) implementation.
/// 
/// ## I18N Preparation:
/// 
/// - All strings are centralized for easy extraction
/// - Organized by functional areas (UI, validation, business logic)
/// - Context provided for translators
/// - Parameterized strings support dynamic content
/// - Consistent naming convention for i18n keys
/// 
/// ## Usage:
/// ```dart
/// // Instead of: Text('Novo Comentário')
/// Text(ComentariosStrings.dialogTitle)
/// 
/// // For parameterized strings:
/// Text(ComentariosStrings.validationMinLength(3))
/// ```
/// 
/// ## Future I18N Implementation:
/// 
/// This class can be easily converted to use Flutter's `Localizations`:
/// ```dart
/// // Future implementation example:
/// String get dialogTitle => Localizations.of(context).comentarioDialogTitle;
/// ```
class ComentariosStrings {
  ComentariosStrings._(); // Private constructor to prevent instantiation
  
  /// Dialog title for creating new comments
  /// Context: Title of the modal dialog
  static const String dialogTitle = 'Novo Comentário';
  
  /// Page title for comments listing
  /// Context: AppBar title or page header
  static const String pageTitle = 'Comentários';
  
  /// Section header for comments list
  /// Context: Section divider or group header
  static const String commentsSection = 'Seus Comentários';
  
  /// Subtitle explaining what comments are for
  /// Context: Helper text below main title
  static const String pageSubtitle = 'Suas anotações e observações sobre o conteúdo';
  
  /// Label for comment content input field
  /// Context: TextField label
  static const String fieldLabelContent = 'Comentário';
  
  /// Label for comment title input field  
  /// Context: TextField label
  static const String fieldLabelTitle = 'Título';
  
  /// Placeholder text for content input
  /// Context: TextField hint text
  static const String fieldHintContent = 'Digite aqui sua anotação...';
  
  /// Placeholder text for title input
  /// Context: TextField hint text  
  static const String fieldHintTitle = 'Digite um título para seu comentário';
  
  /// Instructional text above content field
  /// Context: Helper text above input field
  static const String fieldInstructionContent = 'Digite seu comentário ou anotação:';
  
  /// Save button text
  /// Context: Primary action button
  static const String buttonSave = 'Salvar';
  
  /// Cancel button text
  /// Context: Secondary action button
  static const String buttonCancel = 'Cancelar';
  
  /// Edit button text
  /// Context: Edit action in menu or button
  static const String buttonEdit = 'Editar';
  
  /// Delete button text
  /// Context: Delete action in menu or button  
  static const String buttonDelete = 'Excluir';
  
  /// Add comment button text
  /// Context: Floating action button or primary CTA
  static const String buttonAddComment = 'Adicionar Comentário';
  
  /// Search button text
  /// Context: Search action button
  static const String buttonSearch = 'Buscar';
  
  /// Clear search button text
  /// Context: Clear search input button
  static const String buttonClearSearch = 'Limpar busca';
  
  /// Loading text when saving comment
  /// Context: Button text during save operation
  static const String statusSaving = 'Salvando...';
  
  /// Loading text when deleting comment
  /// Context: Button text during delete operation
  static const String statusDeleting = 'Excluindo...';
  
  /// Loading text when loading comments
  /// Context: Loading indicator text
  static const String statusLoading = 'Carregando comentários...';
  
  /// Success message after saving
  /// Context: Snackbar or toast message
  static const String statusSaveSuccess = 'Comentário salvo com sucesso!';
  
  /// Success message after deleting
  /// Context: Snackbar or toast message
  static const String statusDeleteSuccess = 'Comentário excluído com sucesso!';
  
  /// Error when content is too short
  /// Context: Form validation error
  static String validationMinLength(int minLength) => 
      'Conteúdo deve ter pelo menos $minLength caracteres';
  
  /// Error when content is too long
  /// Context: Form validation error  
  static String validationMaxLength(int maxLength) => 
      'Conteúdo não pode exceder $maxLength caracteres';
  
  /// Error when title is empty
  /// Context: Form validation error
  static const String validationTitleRequired = 'Título é obrigatório';
  
  /// Error when title is too short
  /// Context: Form validation error
  static String validationTitleMinLength(int minLength) => 
      'Título deve ter pelo menos $minLength caracteres';
  
  /// Error when title is too long
  /// Context: Form validation error
  static String validationTitleMaxLength(int maxLength) => 
      'Título não pode exceder $maxLength caracteres';
  
  /// Error for inappropriate content
  /// Context: Content moderation message
  static const String validationInappropriatContent = 
      'Conteúdo contém linguagem inapropriada';
  
  /// Error for low quality content
  /// Context: Content quality validation
  static const String validationLowQuality = 
      'Conteúdo deve ser mais descritivo e útil';
  
  /// Information about minimum length requirement
  /// Context: Helper text below input field
  static String requirementMinLength(int minLength) => 
      'Mínimo de $minLength caracteres';
  
  /// Error when user reaches comment limit
  /// Context: Business rule violation message
  static String errorCommentLimit(int limit) => 
      'Limite de comentários ativos atingido ($limit). '
      'Considere deletar comentários antigos ou fazer upgrade.';
  
  /// Error when daily limit is reached
  /// Context: Rate limiting message
  static String errorDailyLimit(int limit) => 
      'Limite diário de comentários atingido ($limit). '
      'Tente novamente amanhã.';
  
  /// Error when creating comments too quickly
  /// Context: Anti-spam message
  static const String errorRateLimit = 
      'Muitos comentários criados recentemente. '
      'Aguarde alguns minutos antes de criar outro.';
  
  /// Error when duplicate content is detected
  /// Context: Duplicate prevention message
  static const String errorDuplicateContent = 
      'Já existe um comentário similar neste contexto';
  
  /// Generic error message for save failures
  /// Context: Fallback error message
  static const String errorSaveFailed = 'Erro ao salvar comentário';
  
  /// Generic error message for delete failures  
  /// Context: Fallback error message
  static const String errorDeleteFailed = 'Erro ao excluir comentário';
  
  /// Generic error message for load failures
  /// Context: Fallback error message
  static const String errorLoadFailed = 'Erro ao carregar comentários';
  
  /// Message when no comments exist
  /// Context: Empty state in comments list
  static const String emptyStateTitle = 'Nenhum comentário encontrado';
  
  /// Subtitle for empty state
  /// Context: Helper text in empty state
  static const String emptyStateSubtitle = 
      'Comece adicionando suas primeiras anotações sobre o conteúdo';
  
  /// Message when search returns no results
  /// Context: Empty search results
  static const String emptySearchTitle = 'Nenhum resultado encontrado';
  
  /// Subtitle for empty search results
  /// Context: Helper text for search results
  static const String emptySearchSubtitle = 
      'Tente termos diferentes ou verifique a ortografia';
  
  /// Action button text in empty state
  /// Context: Primary action in empty state
  static const String emptyStateAction = 'Adicionar Primeiro Comentário';
  
  /// Search field placeholder
  /// Context: Search input hint text
  static const String searchPlaceholder = 'Buscar em seus comentários...';
  
  /// Search field label
  /// Context: Search input label
  static const String searchLabel = 'Buscar comentários';
  
  /// Filter by tool label
  /// Context: Filter dropdown or chip
  static const String filterByTool = 'Filtrar por ferramenta';
  
  /// Filter by date label
  /// Context: Filter dropdown or chip
  static const String filterByDate = 'Filtrar por data';
  
  /// Show all filter option
  /// Context: Filter option to show all items
  static const String filterShowAll = 'Mostrar todos';
  
  /// Results count text
  /// Context: Search/filter results summary
  static String searchResults(int count) => 
      count == 1 ? '1 resultado encontrado' : '$count resultados encontrados';
  
  /// Relative time: now
  /// Context: Time stamp showing immediate time
  static const String timeNow = 'Agora';
  
  /// Relative time: minutes ago (singular)
  /// Context: Time stamp for recent activity
  static const String timeMinuteAgo = '1 minuto atrás';
  
  /// Relative time: minutes ago (plural)
  /// Context: Time stamp for recent activity
  static String timeMinutesAgo(int minutes) => '$minutes minutos atrás';
  
  /// Relative time: hour ago (singular)
  /// Context: Time stamp for recent activity
  static const String timeHourAgo = '1 hora atrás';
  
  /// Relative time: hours ago (plural)
  /// Context: Time stamp for recent activity
  static String timeHoursAgo(int hours) => '$hours horas atrás';
  
  /// Relative time: day ago (singular)
  /// Context: Time stamp for older activity
  static const String timeDayAgo = '1 dia atrás';
  
  /// Relative time: days ago (plural)
  /// Context: Time stamp for older activity
  static String timeDaysAgo(int days) => '$days dias atrás';
  
  /// Screen reader label for comment card
  /// Context: Semantic label for accessibility
  static String a11yCommentCard(String tool, String timeAgo) => 
      'Comentário de $tool, criado $timeAgo';
  
  /// Screen reader hint for comment card
  /// Context: Semantic hint for accessibility
  static const String a11yCommentCardHint = 
      'Toque para ver opções de edição e exclusão';
  
  /// Screen reader label for tool badge
  /// Context: Semantic label for accessibility
  static String a11yToolBadge(String tool) => 'Ferramenta: $tool';
  
  /// Screen reader label for creation date
  /// Context: Semantic label for accessibility
  static String a11yCreationDate(String timeAgo) => 'Data de criação: $timeAgo';
  
  /// Screen reader label for content
  /// Context: Semantic label for accessibility
  static const String a11yContent = 'Conteúdo do comentário';
  
  /// Screen reader label for edit field
  /// Context: Semantic label for accessibility
  static const String a11yEditField = 'Campo de edição do comentário';
  
  /// Screen reader hint for edit field
  /// Context: Semantic hint for accessibility
  static const String a11yEditFieldHint = 'Digite o novo conteúdo do comentário';
  
  /// Screen reader label for actions menu
  /// Context: Semantic label for accessibility
  static const String a11yActionsMenu = 'Menu de ações do comentário';
  
  /// Screen reader hint for actions menu
  /// Context: Semantic hint for accessibility
  static const String a11yActionsMenuHint = 'Toque para ver opções de editar ou excluir';
  
  /// Screen reader label for edit action
  /// Context: Semantic label for accessibility
  static const String a11yEditAction = 'Editar comentário';
  
  /// Screen reader hint for edit action
  /// Context: Semantic hint for accessibility
  static const String a11yEditActionHint = 'Permite modificar o conteúdo deste comentário';
  
  /// Screen reader label for delete action
  /// Context: Semantic label for accessibility
  static const String a11yDeleteAction = 'Excluir comentário';
  
  /// Screen reader hint for delete action
  /// Context: Semantic hint for accessibility  
  static const String a11yDeleteActionHint = 'Remove permanentemente este comentário';
  
  /// Screen reader label for save button
  /// Context: Semantic label for accessibility
  static const String a11ySaveButton = 'Salvar alterações';
  
  /// Screen reader hint for save button
  /// Context: Semantic hint for accessibility
  static const String a11ySaveButtonHint = 'Confirma e salva as alterações no comentário';
  
  /// Screen reader label for cancel button
  /// Context: Semantic label for accessibility
  static const String a11yCancelButton = 'Cancelar edição';
  
  /// Screen reader hint for cancel button
  /// Context: Semantic hint for accessibility
  static const String a11yCancelButtonHint = 'Cancela a edição e mantém o texto original';
  
  /// Screen reader label for dialog
  /// Context: Semantic label for accessibility
  static const String a11yDialog = 'Diálogo para criar novo comentário';
  
  /// Screen reader label for text field
  /// Context: Semantic label for accessibility
  static const String a11yTextField = 'Campo de texto para o comentário';
  
  /// Screen reader hint for text field
  /// Context: Semantic hint for accessibility
  static const String a11yTextFieldHint = 'Digite o conteúdo do seu comentário aqui';
  
  /// Screen reader label for requirement text
  /// Context: Semantic label for accessibility
  static const String a11yRequirement = 'Requisito mínimo';
  
  /// Screen reader label for save dialog button
  /// Context: Semantic label for accessibility
  static const String a11ySaveDialogButton = 'Salvar comentário';
  
  /// Screen reader hint for save dialog button
  /// Context: Semantic hint for accessibility
  static const String a11ySaveDialogButtonHint = 'Confirma e salva o novo comentário';
  
  /// Screen reader label for cancel dialog button
  /// Context: Semantic label for accessibility
  static const String a11yCancelDialogButton = 'Cancelar criação do comentário';
  
  /// Screen reader hint for cancel dialog button
  /// Context: Semantic hint for accessibility
  static const String a11yCancelDialogButtonHint = 'Fecha o diálogo sem salvar';
  
  /// Title for premium upgrade prompt
  /// Context: Premium feature promotion
  static const String premiumTitle = 'Recurso Premium';
  
  /// Message explaining premium requirement
  /// Context: Feature limitation explanation
  static const String premiumMessage = 
      'Para adicionar mais comentários, faça upgrade para a versão premium.';
  
  /// Upgrade button text
  /// Context: Premium upgrade call-to-action
  static const String premiumUpgrade = 'Fazer Upgrade';
  
  /// Premium benefits description
  /// Context: Value proposition for premium
  static const String premiumBenefits = 
      'Comentários ilimitados, backup na nuvem e muito mais!';
  
  /// Delete confirmation title
  /// Context: Confirmation dialog title
  static const String confirmDeleteTitle = 'Confirmar Exclusão';
  
  /// Delete confirmation message
  /// Context: Confirmation dialog content
  static const String confirmDeleteMessage = 
      'Tem certeza que deseja excluir este comentário? '
      'Esta ação não pode ser desfeita.';
  
  /// Confirm button in dialogs
  /// Context: Confirmation action button
  static const String confirmYes = 'Sim, excluir';
  
  /// Cancel button in dialogs
  /// Context: Cancel action button
  static const String confirmNo = 'Cancelar';
  
  /// Tool name for pests feature
  /// Context: Agricultural tool identifier
  static const String toolPests = 'Pragas';
  
  /// Tool name for diseases feature
  /// Context: Agricultural tool identifier  
  static const String toolDiseases = 'Doenças';
  
  /// Tool name for defensives feature
  /// Context: Agricultural tool identifier
  static const String toolDefensives = 'Defensivos';
  
  /// Tool name for diagnostics feature
  /// Context: Agricultural tool identifier
  static const String toolDiagnostics = 'Diagnósticos';
  
  /// Generic tool name for unknown tools
  /// Context: Fallback for unrecognized tools
  static const String toolGeneric = 'Ferramenta';
  
  /// Context description for pest comments
  /// Context: Helper text explaining comment context
  static const String contextPests = 'Suas observações sobre esta praga';
  
  /// Context description for disease comments
  /// Context: Helper text explaining comment context
  static const String contextDiseases = 'Suas anotações sobre esta doença';
  
  /// Context description for defensive comments
  /// Context: Helper text explaining comment context
  static const String contextDefensives = 'Sua experiência com este defensivo';
  
  /// Context description for diagnostic comments
  /// Context: Helper text explaining comment context
  static const String contextDiagnostics = 'Suas observações sobre este diagnóstico';
}

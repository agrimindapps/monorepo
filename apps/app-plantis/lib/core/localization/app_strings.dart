/// Central localization constants for the app
/// This file contains all hardcoded strings that should be localized
class AppStrings {
  AppStrings._();

  // Plant Details Page Strings
  static const String plantDetailsTitle = 'Detalhes da Planta';
  static const String error = 'Erro';
  static const String loadingPlant = 'Carregando planta...';
  static const String loadingPlantAriaLabel =
      'Carregando informações da planta';
  static const String oopsError = 'Ops! Algo deu errado';
  static const String plantLoadError =
      'Não foi possível carregar as informações da planta.';
  static const String errorDetails = 'Detalhes do erro';
  static const String tryAgain = 'Tentar novamente';
  static const String goBack = 'Voltar';
  static const String help = 'Ajuda';
  static const String troubleshootingTips = 'Dicas para solucionar';
  static const String checkConnection = 'Verifique sua conexão com a internet';
  static const String restartApp =
      'Tente fechar e abrir o aplicativo novamente';
  static const String checkUpdates = 'Verifique se há atualizações disponíveis';
  static const String needHelp = 'Precisa de ajuda?';
  static const String helpMessage =
      'Se o problema persistir, você pode:\n\n'
      '• Reiniciar o aplicativo\n'
      '• Verificar sua conexão com a internet\n'
      '• Entrar em contato com o suporte';
  static const String understood = 'Entendi';

  // Plant Details Actions
  static const String quickActions = 'Ações rápidas';
  static const String quickActionsFor = 'Ações rápidas para';
  static const String editPlantFor = 'Editar informações de';
  static const String removeFavorite = 'Remover dos favoritos';
  static const String addFavorite = 'Adicionar aos favoritos';
  static const String moreOptions = 'Mais opções para';
  static const String backToPlantList = 'Voltar para a lista de plantas';
  static const String water = 'Regar';
  static const String fertilize = 'Adubar';
  static const String photo = 'Foto';
  static const String note = 'Nota';
  static const String unfavorite = 'Desfavoritar';
  static const String favorite = 'Favoritar';
  static const String share = 'Compartilhar';
  static const String deletePlant = 'Excluir planta';
  static const String plantRemovedFromFavorites =
      'Planta removida dos favoritos';
  static const String plantAddedToFavorites = 'Planta adicionada aos favoritos';
  static const String quickWaterRecorded = 'Rega rápida registrada!';
  static const String quickFertilizeRecorded = 'Adubação rápida registrada!';
  static const String photoCaptureInDevelopment =
      'Captura de foto em desenvolvimento';
  static const String noteAdditionInDevelopment =
      'Adição de nota em desenvolvimento';
  static const String sharingInDevelopment =
      'Compartilhamento em desenvolvimento';

  // Tab Names
  static const String overview = 'Visão Geral';
  static const String tasks = 'Tarefas';
  static const String care = 'Cuidados';
  static const String notes = 'Comentários';

  // More Options Sheet
  static const String options = 'Opções';
  static const String shareInfo = 'Compartilhar informações da planta';
  static const String duplicate = 'Duplicar';
  static const String createCopy = 'Criar uma cópia desta planta';
  static const String deleteAction = 'Excluir';
  static const String permanentlyRemove = 'Remover permanentemente esta planta';

  // Delete Confirmation
  static const String confirmDelete = 'Excluir planta';
  static const String deleteConfirmMessage = 'Tem certeza que deseja excluir';
  static const String cannotBeUndone = 'Esta ação não pode ser desfeita.';
  static const String cancel = 'Cancelar';
  static const String delete = 'Excluir';

  // Invalid Data State
  static const String incompleteData = 'Dados Incompletos';
  static const String incompleteDataAriaLabel = 'Dados da planta incompletos';
  static const String incompleteDataMessage =
      'Esta planta possui dados incompletos ou inválidos e precisa ser editada.';
  static const String editPlantData =
      'Editar dados da planta para corrigir problemas';
  static const String editPlant = 'Editar Planta';

  // Task Creation
  static const String newTask = 'Nova Tarefa';
  static const String taskType = 'Tipo de tarefa';
  static const String taskTitle = 'Título da tarefa';
  static const String descriptionOptional = 'Descrição (opcional)';
  static const String scheduledDate = 'Data programada';
  static const String create = 'Criar';
  static const String taskCreatedSuccessfully = 'Tarefa criada com sucesso!';
  static const String addNewTask = 'Adicionar Nova Tarefa';

  // Task Types
  static const String watering = 'Rega';
  static const String fertilizing = 'Adubação';
  static const String pruning = 'Poda';
  static const String sunlightCheck = 'Luz solar';
  static const String pestInspection = 'Pragas';
  static const String replanting = 'Replantio';

  // Default Task Titles
  static const String waterPlant = 'Regar planta';
  static const String applyFertilizer = 'Aplicar fertilizante';
  static const String pruneBranches = 'Podar galhos';
  static const String checkSunExposure = 'Verificar exposição solar';
  static const String inspectPests = 'Inspecionar pragas';
  static const String replantInLargerPot = 'Replantar em vaso maior';

  // Status Messages
  static const String plantDeletedSuccessfully = 'Planta excluída com sucesso';
  static const String errorDeletingPlant = 'Erro ao excluir planta';
  static const String sharingFeatureInDevelopment =
      'Funcionalidade de compartilhamento em desenvolvimento';
  static const String duplicateFeatureInDevelopment =
      'Funcionalidade de duplicação em desenvolvimento';

  // Tasks System Strings
  // TasksProvider Messages
  static const String loadingTasks = 'Carregando tarefas...';
  static const String synchronizing = 'Sincronizando...';
  static const String addingTask = 'Adicionando tarefa...';
  static const String completingTask = 'Concluindo tarefa...';
  static const String refreshing = 'Atualizando...';
  static const String errorSyncingTasks = 'Erro ao sincronizar tarefas';
  static const String errorSyncingNewTask = 'Erro ao sincronizar nova tarefa';
  static const String errorSyncingTaskCompletion =
      'Erro ao sincronizar conclusão da tarefa';
  static const String unexpectedErrorLoadingTasks =
      'Erro inesperado ao carregar tarefas';
  static const String unexpectedErrorAddingTask =
      'Erro inesperado ao adicionar tarefa';
  static const String unexpectedErrorCompletingTask =
      'Erro inesperado ao completar tarefa';
  static const String mustBeAuthenticatedToCreateTasks =
      'Você deve estar autenticado para criar tarefas';

  // Task Creation Dialog
  static const String newTaskTitle = 'Nova Tarefa';
  static const String taskTypeLabel = 'Tipo de Tarefa';
  static const String plantLabel = 'Planta';
  static const String taskTitleLabel = 'Título da Tarefa';
  static const String taskDescriptionLabel = 'Descrição (opcional)';
  static const String dueDateLabel = 'Data de Vencimento';
  static const String priorityLabel = 'Prioridade';
  static const String selectPlantHint = 'Selecione uma planta';
  static const String taskTitleHint = 'Ex: Regar plantas da sala';
  static const String taskDescriptionHint =
      'Detalhes adicionais sobre a tarefa...';
  static const String titleRequired = 'Título é obrigatório';
  static const String pleaseSelectPlant = 'Por favor, selecione uma planta';
  static const String noPlantFoundAddFirst =
      'Nenhuma planta encontrada. Adicione uma planta primeiro.';
  static const String today = 'Hoje';
  static const String tomorrow = 'Amanhã';
  static const String createTaskButton = 'Criar Tarefa';
  static const String dueDatePickerHelp = 'Data de Vencimento';
  static const String confirmButton = 'CONFIRMAR';
  static const String cancelButton = 'CANCELAR';

  // Tasks Dashboard
  static const String totalLabel = 'Total';
  static const String pendingLabel = 'Pendentes';
  static const String todayLabel = 'Hoje';
  static const String overdueLabel = 'Atrasadas';
  static const String overallProgress = 'Progresso Geral';
  static const String tasksProgressFormat = 'de %d tarefas (%d%%)';

  // Empty Tasks Widget
  static const String noTasksFound = 'Nenhuma tarefa encontrada';
  static const String noTasksFoundDescription =
      'Você ainda não possui tarefas cadastradas.\nComece adicionando uma nova tarefa para suas plantas!';
  static const String noTasksToday = 'Nenhuma tarefa para hoje';
  static const String noTasksTodayDescription =
      'Que ótimo! Você não tem tarefas agendadas para hoje.\nSuas plantas estão sendo bem cuidadas!';
  static const String noOverdueTasks = 'Nenhuma tarefa atrasada';
  static const String noOverdueTasksDescription =
      'Parabéns! Você está em dia com todos os cuidados.\nSuas plantas agradecem!';
  static const String noUpcomingTasks = 'Nenhuma tarefa próxima';
  static const String noUpcomingTasksDescription =
      'Não há tarefas agendadas para os próximos dias.\nTalvez seja hora de planejar novos cuidados?';
  static const String noCompletedTasks = 'Nenhuma tarefa concluída';
  static const String noCompletedTasksDescription =
      'Você ainda não concluiu nenhuma tarefa.\nComece completando algumas tarefas pendentes!';
  static const String noTasksForThisPlant = 'Nenhuma tarefa para esta planta';
  static const String noTasksForThisPlantDescription =
      'Esta planta não possui tarefas cadastradas.\nQue tal adicionar alguns cuidados?';
  static const String addNewTaskButton = 'Adicionar Nova Tarefa';

  // Task Notification Service
  static const String timeToWater = 'Hora de regar! 💧';
  static const String timeToFertilize = 'Hora de adubar! 🌿';
  static const String timeToPrune = 'Hora da poda! ✂️';
  static const String timeToRepot = 'Hora do transplante! 🪴';
  static const String timeToClean = 'Hora da limpeza! 🧹';
  static const String timeToSpray = 'Hora da pulverização! 💨';
  static const String timeForSunlight = 'Hora do sol! ☀️';
  static const String timeForShade = 'Hora da sombra! 🌤️';
  static const String timeForInspection = 'Hora da inspeção! 🔍';
  static const String careReminder = 'Lembrete de cuidado! 🌱';
  static const String taskOverdue = 'Tarefa em Atraso! 🚨';
  static const String goodMorning = 'Bom dia! 🌱';
  static const String completeAction = 'Concluir';
  static const String remindLaterAction = 'Lembrar mais tarde';
  static const String viewDetailsAction = 'Ver detalhes';
  static const String completeNowAction = 'Concluir agora';
  static const String rescheduleAction = 'Reagendar';
  static const String reminderRescheduled = 'Lembrete Reagendado 🔔';
  static const String notificationSystem = 'Sistema de Notificações';
  static const String checkingOverdueTasks = 'Verificando tarefas em atraso...';

  // Task Notification Priority Emojis
  static const String urgentPriorityEmoji = ' ⚡';
  static const String highPriorityEmoji = ' 🔴';
  static const String mediumPriorityEmoji = ' 🟡';
  static const String lowPriorityEmoji = ' 🟢';

  // Daily Summary Messages
  static const String oneTaskToday = 'Você tem 1 tarefa para hoje: ';
  static const String multipleTasksWithUrgent =
      'Você tem %TOTAL% tarefas hoje, %URGENT% urgentes!';
  static const String multipleTasksScheduled =
      'Você tem %TOTAL% tarefas agendadas para hoje';

  // Tasks AppBar Strings
  static const String tasksTitle = 'Tarefas';
  static const String searchTasksHint = 'Buscar tarefas...';
  static const String filtersTitle = 'Filtros';
  static const String clearAllFilters = 'Limpar todos';
  static const String clearFilters = 'Limpar';
  static const String applyFilters = 'Aplicar Filtros';
  static const String taskStatusSection = 'Status da Tarefa';
  static const String taskTypeSection = 'Tipo de Tarefa';
  static const String prioritySection = 'Prioridade';
  static const String filterByPlantSection = 'Filtrar por Planta';
  static const String plantNameHint = 'Nome da planta';
  static const String totalTasksFormat = '%d tarefas';
  static const String todayQuickFilter = 'Para hoje';
  static const String upcomingQuickFilterFormat = 'Próximas %d';
  static const String plantFilterFormat = 'Planta: %s';

  // Task Type Display Names (centralized)
  static const String taskTypeWatering = 'Rega';
  static const String taskTypeFertilizing = 'Adubo';
  static const String taskTypePruning = 'Poda';
  static const String taskTypePestInspection = 'Inspeção';
  static const String taskTypeRepotting = 'Replantio';
  static const String taskTypeCleaning = 'Limpeza';
  static const String taskTypeSpraying = 'Pulverização';
  static const String taskTypeSunlight = 'Luz solar';
  static const String taskTypeShade = 'Sombra';
  static const String taskTypeCustom = 'Personalizada';

  // Priority Display Names (centralized)
  static const String priorityUrgent = 'Urgente';
  static const String priorityHigh = 'Alta';
  static const String priorityMedium = 'Média';
  static const String priorityLow = 'Baixa';
}

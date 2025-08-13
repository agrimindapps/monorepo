// Flutter imports:
import 'package:flutter/foundation.dart';

/// Service para gerenciar internacionalização e strings localizadas
/// Fornece interface centralizada para todas as strings da aplicação
class I18nService {
  static const I18nService _instance = I18nService._internal();
  factory I18nService() => _instance;
  const I18nService._internal();

  // Locale atual (pode ser configurado dinamicamente)
  static String _currentLocale = 'pt_BR';

  /// Define o locale atual
  static void setLocale(String locale) {
    if (_supportedLocales.containsKey(locale)) {
      _currentLocale = locale;
      debugPrint('🌐 Locale alterado para: $locale');
    } else {
      debugPrint('⚠️ Locale não suportado: $locale. Mantendo: $_currentLocale');
    }
  }

  /// Obtém o locale atual
  static String get currentLocale => _currentLocale;

  /// Mapa de locales suportados
  static const Map<String, String> _supportedLocales = {
    'pt_BR': 'Português (Brasil)',
    'en_US': 'English (United States)',
    'es_ES': 'Español (España)',
  };

  /// Verifica se um locale é suportado
  static bool isLocaleSupported(String locale) {
    return _supportedLocales.containsKey(locale);
  }

  /// Obtém lista de locales suportados
  static Map<String, String> get supportedLocales => _supportedLocales;

  // ========== STRINGS DA APLICAÇÃO ==========

  // Strings gerais
  static String get loading => _getString('loading');
  static String get error => _getString('error');
  static String get success => _getString('success');
  static String get cancel => _getString('cancel');
  static String get confirm => _getString('confirm');
  static String get save => _getString('save');
  static String get delete => _getString('delete');
  static String get edit => _getString('edit');
  static String get back => _getString('back');
  static String get close => _getString('close');
  static String get tryAgain => _getString('tryAgain');

  // Strings específicas do módulo planta_detalhes
  static String get plantDetails => _getString('plantDetails');
  static String get plantInfo => _getString('plantInfo');
  static String get careHistory => _getString('careHistory');
  static String get upcomingTasks => _getString('upcomingTasks');
  static String get comments => _getString('comments');
  static String get addComment => _getString('addComment');
  static String get commentAdded => _getString('commentAdded');
  static String get commentRemoved => _getString('commentRemoved');
  static String get removeComment => _getString('removeComment');
  static String get editPlant => _getString('editPlant');
  static String get removePlant => _getString('removePlant');
  static String get plantRemoved => _getString('plantRemoved');
  static String get confirmRemovePlant => _getString('confirmRemovePlant');

  // Strings de tarefas
  static String get taskCompleted => _getString('taskCompleted');
  static String get markAsCompleted => _getString('markAsCompleted');
  static String get taskDueDate => _getString('taskDueDate');
  static String get nextDueDate => _getString('nextDueDate');
  static String get interval => _getString('interval');
  static String get completionDate => _getString('completionDate');
  static String get selectCompletionDate => _getString('selectCompletionDate');

  // Strings de carregamento e erro
  static String get loadingPlantData => _getString('loadingPlantData');
  static String get errorLoadingData => _getString('errorLoadingData');
  static String get errorAddingComment => _getString('errorAddingComment');
  static String get errorRemovingComment => _getString('errorRemovingComment');
  static String get errorMarkingTask => _getString('errorMarkingTask');
  static String get errorRemovingPlant => _getString('errorRemovingPlant');
  static String get timeoutError => _getString('timeoutError');
  static String get databaseError => _getString('databaseError');
  static String get connectionError => _getString('connectionError');
  static String get unexpectedError => _getString('unexpectedError');

  // Strings de informações da planta
  static String get plantName => _getString('plantName');
  static String get plantSpecies => _getString('plantSpecies');
  static String get plantSpace => _getString('plantSpace');
  static String get noPlantName => _getString('noPlantName');
  static String get noPlantSpecies => _getString('noPlantSpecies');
  static String get noSpaceDefined => _getString('noSpaceDefined');
  static String get noCommentsYet => _getString('noCommentsYet');
  static String get noTasksYet => _getString('noTasksYet');

  // Strings específicas do módulo minhas_plantas
  static String get myPlants => _getString('myPlants');
  static String get searchPlaceholder => _getString('searchPlaceholder');
  static String get noPlantsFound => _getString('noPlantsFound');
  static String get addNewPlant => _getString('addNewPlant');
  static String get editPlantAction => _getString('editPlantAction');
  static String get removePlantAction => _getString('removePlantAction');
  static String get confirmRemoval => _getString('confirmRemoval');
  static String get removalMessage => _getString('removalMessage');
  static String get plantRemovedSuccess => _getString('plantRemovedSuccess');
  static String get removedSuccessfully => _getString('removedSuccessfully');
  static String get inDevelopment => _getString('inDevelopment');
  static String get featureInDevelopment => _getString('featureInDevelopment');
  static String get plant => _getString('plant');
  static String get plants => _getString('plants');

  // Status de cuidados
  static String get allCareUpToDate => _getString('allCareUpToDate');
  static String get pendingCare => _getString('pendingCare');

  // Pluralization para plantas e cuidados
  static String plantsCount(int count) => _getPlural('plantsCount', count);
  static String pendingCareCount(int count) =>
      _getPlural('pendingCareCount', count);

  // Strings de data e tempo
  static String get today => _getString('today');
  static String get tomorrow => _getString('tomorrow');
  static String get yesterday => _getString('yesterday');
  static String get daysAgo => _getString('daysAgo');
  static String get weeksAgo => _getString('weeksAgo');
  static String get inDays => _getString('inDays');
  static String get inWeeks => _getString('inWeeks');
  static String get dateNotProvided => _getString('dateNotProvided');
  static String get invalidDate => _getString('invalidDate');

  // Pluralization helpers
  static String days(int count) => _getPlural('days', count);
  static String weeks(int count) => _getPlural('weeks', count);

  /// Obtém string localizada pela chave
  static String _getString(String key) {
    final strings = _getStringsForLocale(_currentLocale);
    final result = strings[key];

    if (result == null) {
      debugPrint(
          '⚠️ String não encontrada para chave: $key (locale: $_currentLocale)');
      // Fallback para português se não encontrar
      if (_currentLocale != 'pt_BR') {
        final fallback = _getStringsForLocale('pt_BR')[key];
        if (fallback != null) return fallback;
      }
      return '[$key]'; // Mostra a chave se não encontrar tradução
    }

    return result;
  }

  /// Obtém string plural localizada
  static String _getPlural(String key, int count) {
    final pluralKey = count == 1 ? '${key}_singular' : '${key}_plural';
    return _getString(pluralKey).replaceAll('{count}', count.toString());
  }

  /// Obtém mapa de strings para um locale específico
  static Map<String, String> _getStringsForLocale(String locale) {
    switch (locale) {
      case 'pt_BR':
        return _ptBRStrings;
      case 'en_US':
        return _enUSStrings;
      case 'es_ES':
        return _esESStrings;
      default:
        return _ptBRStrings;
    }
  }

  // ========== DEFINIÇÕES DE STRINGS POR LOCALE ==========

  static const Map<String, String> _ptBRStrings = {
    // Gerais
    'loading': 'Carregando...',
    'error': 'Erro',
    'success': 'Sucesso',
    'cancel': 'Cancelar',
    'confirm': 'Confirmar',
    'save': 'Salvar',
    'delete': 'Excluir',
    'edit': 'Editar',
    'back': 'Voltar',
    'close': 'Fechar',
    'tryAgain': 'Tentar novamente',

    // Módulo específico
    'plantDetails': 'Detalhes da Planta',
    'plantInfo': 'Informações da Planta',
    'careHistory': 'Histórico de Cuidados',
    'upcomingTasks': 'Próximas Tarefas',
    'comments': 'Comentários',
    'addComment': 'Adicionar Comentário',
    'commentAdded': 'Comentário adicionado!',
    'commentRemoved': 'Comentário removido!',
    'removeComment': 'Remover Comentário',
    'editPlant': 'Editar Planta',
    'removePlant': 'Remover Planta',
    'plantRemoved': 'Planta removida com sucesso!',
    'confirmRemovePlant': 'Tem certeza que deseja remover esta planta?',

    // Tarefas
    'taskCompleted': 'Tarefa concluída!',
    'markAsCompleted': 'Marcar como Concluída',
    'taskDueDate': 'Data de vencimento',
    'nextDueDate': 'Próximo vencimento',
    'interval': 'Intervalo',
    'completionDate': 'Data de conclusão',
    'selectCompletionDate': 'Selecionar data de conclusão',

    // Erros e carregamento
    'loadingPlantData': 'Carregando informações da planta...',
    'errorLoadingData': 'Erro ao carregar dados',
    'errorAddingComment': 'Erro ao adicionar comentário',
    'errorRemovingComment': 'Erro ao remover comentário',
    'errorMarkingTask': 'Erro ao marcar tarefa como concluída',
    'errorRemovingPlant': 'Erro ao remover planta',
    'timeoutError': 'Tempo limite excedido ao carregar dados',
    'databaseError': 'Erro no banco de dados',
    'connectionError': 'Erro de conexão',
    'unexpectedError': 'Ocorreu um erro inesperado',

    // Informações da planta
    'plantName': 'Nome da Planta',
    'plantSpecies': 'Espécie',
    'plantSpace': 'Espaço',
    'noPlantName': 'Nome não informado',
    'noPlantSpecies': 'Espécie não informada',
    'noSpaceDefined': 'Espaço não definido',
    'noCommentsYet': 'Nenhum comentário ainda',
    'noTasksYet': 'Nenhuma tarefa ainda',

    // Módulo minhas_plantas
    'myPlants': 'Minhas plantas',
    'searchPlaceholder': 'Buscar por nome ou espécie...',
    'noPlantsFound': 'Nenhuma planta encontrada',
    'addNewPlant': 'Adicionar nova planta',
    'editPlantAction': 'Editar',
    'removePlantAction': 'Remover',
    'confirmRemoval': 'Remover planta',
    'removalMessage':
        'Tem certeza que deseja remover esta planta?\n\nEsta ação não pode ser desfeita.',
    'plantRemovedSuccess': 'Planta removida',
    'removedSuccessfully': 'foi removida com sucesso',
    'inDevelopment': 'Em desenvolvimento',
    'featureInDevelopment': 'Função de edição será implementada em breve',
    'plant': 'planta',
    'plants': 'plantas',

    // Status de cuidados
    'allCareUpToDate': 'Todos os cuidados em dia',
    'pendingCare': 'cuidado pendente',

    // Data e tempo
    'today': 'Hoje',
    'tomorrow': 'Amanhã',
    'yesterday': 'Ontem',
    'daysAgo': 'Há {count} dia(s)',
    'weeksAgo': 'Há {count} semana(s)',
    'inDays': 'Em {count} dia(s)',
    'inWeeks': 'Em {count} semana(s)',
    'dateNotProvided': 'Data não informada',
    'invalidDate': 'Data inválida',

    // Plurais
    'days_singular': '{count} dia',
    'days_plural': '{count} dias',
    'weeks_singular': '{count} semana',
    'weeks_plural': '{count} semanas',
    'plantsCount_singular': '{count} planta',
    'plantsCount_plural': '{count} plantas',
    'pendingCareCount_singular': '{count} cuidado pendente',
    'pendingCareCount_plural': '{count} cuidados pendentes',
  };

  static const Map<String, String> _enUSStrings = {
    // Gerais
    'loading': 'Loading...',
    'error': 'Error',
    'success': 'Success',
    'cancel': 'Cancel',
    'confirm': 'Confirm',
    'save': 'Save',
    'delete': 'Delete',
    'edit': 'Edit',
    'back': 'Back',
    'close': 'Close',
    'tryAgain': 'Try Again',

    // Módulo específico
    'plantDetails': 'Plant Details',
    'plantInfo': 'Plant Information',
    'careHistory': 'Care History',
    'upcomingTasks': 'Upcoming Tasks',
    'comments': 'Comments',
    'addComment': 'Add Comment',
    'commentAdded': 'Comment added!',
    'commentRemoved': 'Comment removed!',
    'removeComment': 'Remove Comment',
    'editPlant': 'Edit Plant',
    'removePlant': 'Remove Plant',
    'plantRemoved': 'Plant successfully removed!',
    'confirmRemovePlant': 'Are you sure you want to remove this plant?',

    // Tarefas
    'taskCompleted': 'Task completed!',
    'markAsCompleted': 'Mark as Completed',
    'taskDueDate': 'Due date',
    'nextDueDate': 'Next due date',
    'interval': 'Interval',
    'completionDate': 'Completion date',
    'selectCompletionDate': 'Select completion date',

    // Erros e carregamento
    'loadingPlantData': 'Loading plant information...',
    'errorLoadingData': 'Error loading data',
    'errorAddingComment': 'Error adding comment',
    'errorRemovingComment': 'Error removing comment',
    'errorMarkingTask': 'Error marking task as completed',
    'errorRemovingPlant': 'Error removing plant',
    'timeoutError': 'Timeout exceeded while loading data',
    'databaseError': 'Database error',
    'connectionError': 'Connection error',
    'unexpectedError': 'An unexpected error occurred',

    // Informações da planta
    'plantName': 'Plant Name',
    'plantSpecies': 'Species',
    'plantSpace': 'Space',
    'noPlantName': 'Name not provided',
    'noPlantSpecies': 'Species not provided',
    'noSpaceDefined': 'Space not defined',
    'noCommentsYet': 'No comments yet',
    'noTasksYet': 'No tasks yet',

    // Módulo minhas_plantas
    'myPlants': 'My plants',
    'searchPlaceholder': 'Search by name or species...',
    'noPlantsFound': 'No plants found',
    'addNewPlant': 'Add new plant',
    'editPlantAction': 'Edit',
    'removePlantAction': 'Remove',
    'confirmRemoval': 'Remove plant',
    'removalMessage':
        'Are you sure you want to remove this plant?\n\nThis action cannot be undone.',
    'plantRemovedSuccess': 'Plant removed',
    'removedSuccessfully': 'was removed successfully',
    'inDevelopment': 'In development',
    'featureInDevelopment': 'Edit function will be implemented soon',
    'plant': 'plant',
    'plants': 'plants',

    // Status de cuidados
    'allCareUpToDate': 'All care up to date',
    'pendingCare': 'pending care',

    // Data e tempo
    'today': 'Today',
    'tomorrow': 'Tomorrow',
    'yesterday': 'Yesterday',
    'daysAgo': '{count} day(s) ago',
    'weeksAgo': '{count} week(s) ago',
    'inDays': 'In {count} day(s)',
    'inWeeks': 'In {count} week(s)',
    'dateNotProvided': 'Date not provided',
    'invalidDate': 'Invalid date',

    // Plurais
    'days_singular': '{count} day',
    'days_plural': '{count} days',
    'weeks_singular': '{count} week',
    'weeks_plural': '{count} weeks',
    'plantsCount_singular': '{count} plant',
    'plantsCount_plural': '{count} plants',
  };

  static const Map<String, String> _esESStrings = {
    // Gerais
    'loading': 'Cargando...',
    'error': 'Error',
    'success': 'Éxito',
    'cancel': 'Cancelar',
    'confirm': 'Confirmar',
    'save': 'Guardar',
    'delete': 'Eliminar',
    'edit': 'Editar',
    'back': 'Volver',
    'close': 'Cerrar',
    'tryAgain': 'Intentar de nuevo',

    // Módulo específico
    'plantDetails': 'Detalles de la Planta',
    'plantInfo': 'Información de la Planta',
    'careHistory': 'Historial de Cuidados',
    'upcomingTasks': 'Próximas Tareas',
    'comments': 'Comentarios',
    'addComment': 'Añadir Comentario',
    'commentAdded': '¡Comentario añadido!',
    'commentRemoved': '¡Comentario eliminado!',
    'removeComment': 'Eliminar Comentario',
    'editPlant': 'Editar Planta',
    'removePlant': 'Eliminar Planta',
    'plantRemoved': '¡Planta eliminada con éxito!',
    'confirmRemovePlant': '¿Estás seguro de que quieres eliminar esta planta?',

    // Tarefas
    'taskCompleted': '¡Tarea completada!',
    'markAsCompleted': 'Marcar como Completada',
    'taskDueDate': 'Fecha de vencimiento',
    'nextDueDate': 'Próximo vencimiento',
    'interval': 'Intervalo',
    'completionDate': 'Fecha de finalización',
    'selectCompletionDate': 'Seleccionar fecha de finalización',

    // Erros e carregamento
    'loadingPlantData': 'Cargando información de la planta...',
    'errorLoadingData': 'Error al cargar datos',
    'errorAddingComment': 'Error al añadir comentario',
    'errorRemovingComment': 'Error al eliminar comentario',
    'errorMarkingTask': 'Error al marcar tarea como completada',
    'errorRemovingPlant': 'Error al eliminar planta',
    'timeoutError': 'Tiempo límite excedido al cargar datos',
    'databaseError': 'Error de base de datos',
    'connectionError': 'Error de conexión',
    'unexpectedError': 'Ocurrió un error inesperado',

    // Informações da planta
    'plantName': 'Nombre de la Planta',
    'plantSpecies': 'Especie',
    'plantSpace': 'Espacio',
    'noPlantName': 'Nombre no proporcionado',
    'noPlantSpecies': 'Especie no proporcionada',
    'noSpaceDefined': 'Espacio no definido',
    'noCommentsYet': 'Aún no hay comentarios',
    'noTasksYet': 'Aún no hay tareas',

    // Módulo minhas_plantas
    'myPlants': 'Mis plantas',
    'searchPlaceholder': 'Buscar por nombre o especie...',
    'noPlantsFound': 'No se encontraron plantas',
    'addNewPlant': 'Añadir nueva planta',
    'editPlantAction': 'Editar',
    'removePlantAction': 'Eliminar',
    'confirmRemoval': 'Eliminar planta',
    'removalMessage':
        '¿Estás seguro de que quieres eliminar esta planta?\n\nEsta acción no se puede deshacer.',
    'plantRemovedSuccess': 'Planta eliminada',
    'removedSuccessfully': 'fue eliminada con éxito',
    'inDevelopment': 'En desarrollo',
    'featureInDevelopment': 'La función de edición se implementará pronto',
    'plant': 'planta',
    'plants': 'plantas',

    // Data e tempo
    'today': 'Hoy',
    'tomorrow': 'Mañana',
    'yesterday': 'Ayer',
    'daysAgo': 'Hace {count} día(s)',
    'weeksAgo': 'Hace {count} semana(s)',
    'inDays': 'En {count} día(s)',
    'inWeeks': 'En {count} semana(s)',
    'dateNotProvided': 'Fecha no proporcionada',
    'invalidDate': 'Fecha inválida',

    // Plurais
    'days_singular': '{count} día',
    'days_plural': '{count} días',
    'weeks_singular': '{count} semana',
    'weeks_plural': '{count} semanas',
    'plantsCount_singular': '{count} planta',
    'plantsCount_plural': '{count} plantas',
  };

  /// Formata string com parâmetros
  static String format(String template, Map<String, dynamic> params) {
    String result = template;
    params.forEach((key, value) {
      result = result.replaceAll('{$key}', value.toString());
    });
    return result;
  }

  /// Obtém string formatada diretamente
  static String getFormatted(String key, Map<String, dynamic> params) {
    return format(_getString(key), params);
  }
}

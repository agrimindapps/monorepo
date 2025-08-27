import 'package:flutter/material.dart';

/// Enhanced constants for the reminders page for better maintainability
class RemindersConstants {
  // Private constructor to prevent instantiation
  RemindersConstants._();

  // Tab configuration
  static const int tabCount = 3;

  // Layout dimensions and spacing
  static const EdgeInsets cardMargin = EdgeInsets.only(bottom: 12);
  static const EdgeInsets listPadding = EdgeInsets.all(16);
  static const double emptyIconSize = 64.0;
  static const double itemExtent = 120.0; // Fixed height for better performance
  static const double cacheExtent = 1000.0; // Cache more items for smoother scrolling

  // Icon and text dimensions
  static const double scheduleIconSize = 14.0;
  static const double repeatIconSize = 14.0;
  static const double iconSpacing = 4.0;
  static const double subtitleSpacing = 4.0;

  // Snooze durations
  static const Duration snooze1Hour = Duration(hours: 1);
  static const Duration snooze4Hours = Duration(hours: 4);
  static const Duration snooze1Day = Duration(days: 1);

  // Date formatting constants
  static const int todayDifference = 0;
  static const int tomorrowDifference = 1;
  static const int yesterdayDifference = -1;
  static const String timePadChar = '0';
  static const int timePadWidth = 2;

  // App text content
  static const String pageTitle = 'Lembretes';
  static const String refreshLabel = 'Atualizar lembretes';
  static const String refreshHint = 'Toque para recarregar a lista de lembretes';
  static const String addReminderLabel = 'Adicionar novo lembrete';
  static const String addReminderHint = 'Toque para criar um novo lembrete';
  static const String loadingLabel = 'Carregando lembretes';

  // Tab labels and empty messages
  static const String todayTabText = 'Hoje';
  static const String overdueTabText = 'Atrasados';
  static const String allTabText = 'Todos';
  
  static const String emptyTodayMessage = 'Nenhum lembrete para hoje';
  static const String emptyOverdueMessage = 'Nenhum lembrete atrasado';
  static const String emptyAllMessage = 'Nenhum lembrete cadastrado';
  
  static const String todayListLabel = 'Lembretes de hoje';
  static const String overdueListLabel = 'Lembretes atrasados';
  static const String allListLabel = 'Todos os lembretes';

  // Status text
  static const String completedStatus = 'concluído';
  static const String overdueStatus = 'atrasado';
  static const String todayStatus = 'para hoje';
  static const String scheduledStatus = 'agendado';

  // Menu actions
  static const String completeAction = 'complete';
  static const String snoozeAction = 'snooze';
  static const String editAction = 'edit';
  static const String deleteAction = 'delete';

  // Menu labels
  static const String completeMenuLabel = 'Marcar como Concluído';
  static const String snoozeMenuLabel = 'Adiar';
  static const String editMenuLabel = 'Editar';
  static const String deleteMenuLabel = 'Excluir';

  // Dialog titles and content
  static const String snoozeDialogTitle = 'Adiar Lembrete';
  static const String snoozeDialogContent = 'Por quanto tempo deseja adiar este lembrete?';
  static const String deleteDialogTitle = 'Confirmar Exclusão';
  
  // Button labels
  static const String snooze1HourLabel = '1 hora';
  static const String snooze4HoursLabel = '4 horas';
  static const String snooze1DayLabel = '1 dia';
  static const String cancelButtonLabel = 'Cancelar';
  static const String deleteButtonLabel = 'Excluir';
  static const String retryButtonLabel = 'Tentar Novamente';

  // Time formatting labels
  static const String todayLabel = 'Hoje às';
  static const String tomorrowLabel = 'Amanhã às';
  static const String yesterdayLabel = 'Ontem às';
  static const String recurringLabel = 'Repete a cada';
  static const String daysLabel = 'dias';

  // Error and success messages
  static const String errorPrefix = 'Erro: ';
  static const String successSuffix = ' com sucesso';
  static const String errorActionPrefix = 'Erro ao ';

  // Development messages
  static const String addFeatureDevelopment = 'Funcionalidade de adicionar lembrete em desenvolvimento';
  static const String editFeatureDevelopment = 'Funcionalidade de editar lembrete em desenvolvimento';
}

/// Color constants for different reminder types and states
class RemindersColors {
  // Private constructor to prevent instantiation
  RemindersColors._();

  // Type colors
  static const Color vaccineColor = Colors.green;
  static const Color medicationColor = Colors.blue;
  static const Color appointmentColor = Colors.purple;
  static const Color weightColor = Colors.teal;
  static const Color generalColor = Colors.grey;

  // Status colors
  static const Color completedIconColor = Colors.white;
}

/// Icon constants for reminder types and actions
class RemindersIcons {
  // Private constructor to prevent instantiation
  RemindersIcons._();

  // App bar icons
  static const IconData refreshIcon = Icons.refresh;
  static const IconData addIcon = Icons.add;

  // Tab icons
  static const IconData todayIcon = Icons.today;
  static const IconData warningIcon = Icons.warning;
  static const IconData listIcon = Icons.list;

  // Empty state icon
  static const IconData emptyScheduleIcon = Icons.schedule;

  // Type icons
  static const IconData vaccineIcon = Icons.vaccines;
  static const IconData medicationIcon = Icons.medication;
  static const IconData appointmentIcon = Icons.event;
  static const IconData weightIcon = Icons.scale;
  static const IconData generalIcon = Icons.notifications;

  // Status and action icons
  static const IconData scheduleIcon = Icons.schedule;
  static const IconData repeatIcon = Icons.repeat;
  static const IconData checkIcon = Icons.check;
  static const IconData snoozeIcon = Icons.snooze;
  static const IconData editIcon = Icons.edit;
  static const IconData deleteIcon = Icons.delete;
}

/// Semantic labels for accessibility
class RemindersSemantics {
  // Private constructor to prevent instantiation
  RemindersSemantics._();

  static const String reminderOptionsLabel = 'Opções do lembrete';
  static const String reminderOptionsHint = 'Toque para ver ações disponíveis';
  static const String cardHint = 'Toque para ver opções do lembrete';

  static String reminderCardLabel(String title, String status, String date) =>
      '$title, $status, $date';

  static String reminderTypeLabel(String typeName) =>
      'Lembrete tipo $typeName';

  static String tabLabel(String tabName, int count) =>
      'Lembretes de $tabName, $count itens';

  static String deleteConfirmationContent(String title) =>
      'Deseja realmente excluir o lembrete "$title"?';
}

/// Animation and performance constants
class RemindersPerformance {
  // Private constructor to prevent instantiation
  RemindersPerformance._();

  // List performance optimizations
  static const double listCacheExtent = 1000.0;
  static const double listItemExtent = 120.0;
  
  // Animation durations (if needed for future enhancements)
  static const Duration defaultAnimationDuration = Duration(milliseconds: 300);
  static const Duration fastAnimationDuration = Duration(milliseconds: 150);
}
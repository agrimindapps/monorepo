import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

enum TaskFilter {
  all,
  today,
  overdue,
  starred,
  week;

  String get displayName {
    switch (this) {
      case TaskFilter.all:
        return 'Todas as tarefas';
      case TaskFilter.today:
        return 'Hoje';
      case TaskFilter.overdue:
        return 'Vencidas';
      case TaskFilter.starred:
        return 'Favoritas';
      case TaskFilter.week:
        return 'Esta semana';
    }
  }

  IconData get icon {
    switch (this) {
      case TaskFilter.all:
        return Icons.list_alt;
      case TaskFilter.today:
        return Icons.today;
      case TaskFilter.overdue:
        return Icons.schedule;
      case TaskFilter.starred:
        return Icons.star;
      case TaskFilter.week:
        return Icons.date_range;
    }
  }

  Color get color {
    switch (this) {
      case TaskFilter.all:
        return AppColors.textSecondary;
      case TaskFilter.today:
        return AppColors.success;
      case TaskFilter.overdue:
        return AppColors.error;
      case TaskFilter.starred:
        return AppColors.warning;
      case TaskFilter.week:
        return AppColors.info;
    }
  }

  String get description {
    switch (this) {
      case TaskFilter.all:
        return 'Visualizar todas as tarefas';
      case TaskFilter.today:
        return 'Tarefas com vencimento hoje';
      case TaskFilter.overdue:
        return 'Tarefas em atraso';
      case TaskFilter.starred:
        return 'Tarefas marcadas como favoritas';
      case TaskFilter.week:
        return 'Tarefas com vencimento nesta semana';
    }
  }
}

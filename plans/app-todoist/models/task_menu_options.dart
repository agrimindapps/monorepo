// Flutter imports:
import 'package:flutter/material.dart';

enum TaskMenuOption {
  reorder,
  grouping,
  customize,
  settings,
  // Futuras funcionalidades podem ser adicionadas aqui
  // sort,
  // filter,
  // export,
}

extension TaskMenuOptionExtension on TaskMenuOption {
  String get title {
    switch (this) {
      case TaskMenuOption.reorder:
        return 'Reordenar';
      case TaskMenuOption.grouping:
        return 'Agrupar';
      case TaskMenuOption.customize:
        return 'Personalizar';
      case TaskMenuOption.settings:
        return 'Configurações';
    }
  }

  String get subtitle {
    switch (this) {
      case TaskMenuOption.reorder:
        return 'Arrastar tarefas para reorganizar';
      case TaskMenuOption.grouping:
        return 'Organizar por critérios';
      case TaskMenuOption.customize:
        return 'Alterar cores do fundo';
      case TaskMenuOption.settings:
        return 'Preferências do aplicativo';
    }
  }

  IconData get icon {
    switch (this) {
      case TaskMenuOption.reorder:
        return Icons.reorder;
      case TaskMenuOption.grouping:
        return Icons.group_work;
      case TaskMenuOption.customize:
        return Icons.palette_outlined;
      case TaskMenuOption.settings:
        return Icons.settings_outlined;
    }
  }

  bool isToggleable(bool isReorderMode) {
    switch (this) {
      case TaskMenuOption.reorder:
        return true;
      case TaskMenuOption.grouping:
        return false;
      case TaskMenuOption.customize:
        return false;
      case TaskMenuOption.settings:
        return false;
    }
  }

  bool isActive(bool isReorderMode) {
    switch (this) {
      case TaskMenuOption.reorder:
        return isReorderMode;
      case TaskMenuOption.grouping:
        return false; // Não tem estado ativo/inativo
      case TaskMenuOption.customize:
        return false; // Não tem estado ativo/inativo
      case TaskMenuOption.settings:
        return false; // Não tem estado ativo/inativo
    }
  }
}

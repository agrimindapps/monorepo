import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

/// Widget para atalhos de teclado desktop
class DesktopKeyboardShortcuts extends StatefulWidget {
  final Widget child;
  final Map<SingleActivator, VoidCallback>? customShortcuts;

  const DesktopKeyboardShortcuts({
    super.key,
    required this.child,
    this.customShortcuts,
  });

  @override
  State<DesktopKeyboardShortcuts> createState() => _DesktopKeyboardShortcutsState();
}

class _DesktopKeyboardShortcutsState extends State<DesktopKeyboardShortcuts> {
  bool _shouldAutofocus = false;

  @override
  void initState() {
    super.initState();
    // Defer autofocus until after the first frame to avoid layout issues
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {
          _shouldAutofocus = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Só aplicar shortcuts em desktop/web
    if (!kIsWeb && !PlatformHelper.isMacOS && !PlatformHelper.isWindows && !PlatformHelper.isLinux) {
      return widget.child;
    }

    final shortcuts = <LogicalKeySet, Intent>{
      // Navegação básica
      LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.digit1): 
          const NavigateToIntent('/tasks'),
      LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.digit2): 
          const NavigateToIntent('/plants'),
      LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.digit3): 
          const NavigateToIntent('/settings'),
      
      // Ações comuns
      LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyN): 
          const CreateNewPlantIntent(),
      LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyS): 
          const SaveIntent(),
      LogicalKeySet(LogicalKeyboardKey.escape): 
          const EscapeIntent(),
      LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyQ): 
          const GoBackIntent(),
      
      // Busca
      LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyF): 
          const SearchIntent(),
      
      // Refresh
      LogicalKeySet(LogicalKeyboardKey.f5): 
          const RefreshIntent(),
      LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyR): 
          const RefreshIntent(),
    };

    // Adicionar shortcuts customizados
    if (widget.customShortcuts != null) {
      for (final entry in widget.customShortcuts!.entries) {
        shortcuts[LogicalKeySet.fromSet({entry.key.trigger})] = 
            CustomIntent(entry.value);
      }
    }

    final actions = <Type, Action<Intent>>{
      NavigateToIntent: NavigateToAction(),
      CreateNewPlantIntent: CreateNewPlantAction(),
      SaveIntent: SaveAction(),
      EscapeIntent: EscapeAction(),
      GoBackIntent: GoBackAction(),
      SearchIntent: SearchAction(),
      RefreshIntent: RefreshAction(),
      CustomIntent: CustomAction(),
    };

    return Shortcuts(
      shortcuts: shortcuts,
      child: Actions(
        actions: actions,
        child: Focus(
          autofocus: _shouldAutofocus,
          child: widget.child,
        ),
      ),
    );
  }
}

// Intents (intenções)
class NavigateToIntent extends Intent {
  final String route;
  const NavigateToIntent(this.route);
}

class CreateNewPlantIntent extends Intent {
  const CreateNewPlantIntent();
}

class SaveIntent extends Intent {
  const SaveIntent();
}

class EscapeIntent extends Intent {
  const EscapeIntent();
}

class GoBackIntent extends Intent {
  const GoBackIntent();
}

class SearchIntent extends Intent {
  const SearchIntent();
}

class RefreshIntent extends Intent {
  const RefreshIntent();
}

class CustomIntent extends Intent {
  final VoidCallback callback;
  const CustomIntent(this.callback);
}

// Actions (ações)
class NavigateToAction extends Action<NavigateToIntent> {
  @override
  Object? invoke(NavigateToIntent intent) {
    final context = primaryFocus?.context;
    if (context != null && context.mounted) {
      context.go(intent.route);
    }
    return null;
  }
}

class CreateNewPlantAction extends Action<CreateNewPlantIntent> {
  @override
  Object? invoke(CreateNewPlantIntent intent) {
    final context = primaryFocus?.context;
    if (context != null && context.mounted) {
      context.go('/plants/add');
    }
    return null;
  }
}

class SaveAction extends Action<SaveIntent> {
  @override
  Object? invoke(SaveIntent intent) {
    // Disparar evento de save global
    final context = primaryFocus?.context;
    if (context != null && context.mounted) {
      // Procurar por um SaveNotifier no contexto
      final saveNotifier = SaveNotifier.maybeOf(context);
      if (saveNotifier != null) {
        saveNotifier.save();
      }
    }
    return null;
  }
}

class EscapeAction extends Action<EscapeIntent> {
  @override
  Object? invoke(EscapeIntent intent) {
    final context = primaryFocus?.context;
    if (context != null && context.mounted) {
      // Fechar dialogs, drawers, etc.
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
    }
    return null;
  }
}

class GoBackAction extends Action<GoBackIntent> {
  @override
  Object? invoke(GoBackIntent intent) {
    final context = primaryFocus?.context;
    if (context != null && context.mounted) {
      if (context.canPop()) {
        context.pop();
      }
    }
    return null;
  }
}

class SearchAction extends Action<SearchIntent> {
  @override
  Object? invoke(SearchIntent intent) {
    final context = primaryFocus?.context;
    if (context != null && context.mounted) {
      // Disparar evento de busca global
      final searchNotifier = SearchNotifier.maybeOf(context);
      if (searchNotifier != null) {
        searchNotifier.toggleSearch();
      }
    }
    return null;
  }
}

class RefreshAction extends Action<RefreshIntent> {
  @override
  Object? invoke(RefreshIntent intent) {
    final context = primaryFocus?.context;
    if (context != null && context.mounted) {
      // Disparar evento de refresh global
      final refreshNotifier = RefreshNotifier.maybeOf(context);
      if (refreshNotifier != null) {
        refreshNotifier.refresh();
      }
    }
    return null;
  }
}

class CustomAction extends Action<CustomIntent> {
  @override
  Object? invoke(CustomIntent intent) {
    intent.callback();
    return null;
  }
}

// Notifiers para comunicação global
class SaveNotifier extends InheritedNotifier<ValueNotifier<void>> {
  const SaveNotifier({
    super.key,
    required super.child,
    required ValueNotifier<void> saveNotifier,
  }) : super(notifier: saveNotifier);

  static SaveNotifier? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<SaveNotifier>();
  }

  void save() => (notifier as ValueNotifier<void>).value;
}

class SearchNotifier extends InheritedWidget {
  final VoidCallback toggleSearch;

  const SearchNotifier({
    super.key,
    required super.child,
    required this.toggleSearch,
  });

  static SearchNotifier? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<SearchNotifier>();
  }

  @override
  bool updateShouldNotify(SearchNotifier oldWidget) {
    return toggleSearch != oldWidget.toggleSearch;
  }
}

class RefreshNotifier extends InheritedWidget {
  final VoidCallback refresh;

  const RefreshNotifier({
    super.key,
    required super.child,
    required this.refresh,
  });

  static RefreshNotifier? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<RefreshNotifier>();
  }

  @override
  bool updateShouldNotify(RefreshNotifier oldWidget) {
    return refresh != oldWidget.refresh;
  }
}

// Widget helper para exibir shortcuts disponíveis
class KeyboardShortcutsHelp extends StatelessWidget {
  const KeyboardShortcutsHelp({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Atalhos de Teclado'),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildShortcutItem('Ctrl + 1', 'Ir para Tarefas'),
            _buildShortcutItem('Ctrl + 2', 'Ir para Plantas'),
            _buildShortcutItem('Ctrl + 3', 'Ir para Configurações'),
            const Divider(),
            _buildShortcutItem('Ctrl + N', 'Nova Planta'),
            _buildShortcutItem('Ctrl + S', 'Salvar'),
            _buildShortcutItem('Ctrl + F', 'Buscar'),
            _buildShortcutItem('F5 / Ctrl + R', 'Atualizar'),
            const Divider(),
            _buildShortcutItem('Esc', 'Cancelar/Fechar'),
            _buildShortcutItem('Ctrl + Q', 'Voltar'),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Fechar'),
        ),
      ],
    );
  }

  Widget _buildShortcutItem(String shortcut, String description) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              shortcut,
              style: const TextStyle(
                fontFamily: 'monospace',
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(child: Text(description)),
        ],
      ),
    );
  }
}

// Extension para facilitar uso
extension DesktopKeyboardShortcutsExtension on Widget {
  /// Aplica atalhos de teclado desktop
  Widget withKeyboardShortcuts({
    Map<SingleActivator, VoidCallback>? customShortcuts,
  }) {
    return DesktopKeyboardShortcuts(
      customShortcuts: customShortcuts,
      child: this,
    );
  }
}

// Helper para detectar plataforma
abstract class PlatformHelper {
  static bool get isMacOS => defaultTargetPlatform == TargetPlatform.macOS;
  static bool get isWindows => defaultTargetPlatform == TargetPlatform.windows;
  static bool get isLinux => defaultTargetPlatform == TargetPlatform.linux;
}
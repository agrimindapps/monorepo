import 'package:core/core.dart' hide Column;
import 'package:flutter/material.dart';

import '../../../../core/providers/spaces_providers.dart';

class SpaceSelectorWidget extends ConsumerStatefulWidget {
  final String? selectedSpaceId;
  final ValueChanged<String?> onSpaceChanged;
  final String? errorText;
  final bool isRequired;

  const SpaceSelectorWidget({
    super.key,
    this.selectedSpaceId,
    required this.onSpaceChanged,
    this.errorText,
    this.isRequired = true,
  });

  @override
  ConsumerState<SpaceSelectorWidget> createState() =>
      _SpaceSelectorWidgetState();
}

class _SpaceSelectorWidgetState extends ConsumerState<SpaceSelectorWidget> {
  String? _selectedSpaceId;

  @override
  void initState() {
    super.initState();
    _selectedSpaceId = widget.selectedSpaceId;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final spacesAsync = ref.read(spacesNotifierProvider);
      final isEmpty = spacesAsync.maybeWhen(
        data: (state) => state.allSpaces.isEmpty,
        orElse: () => true,
      );

      if (isEmpty) {
        ref.read(spacesNotifierProvider.notifier).loadSpaces();
      }
    });
  }

  @override
  void didUpdateWidget(covariant SpaceSelectorWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedSpaceId != oldWidget.selectedSpaceId) {
      setState(() {
        _selectedSpaceId = widget.selectedSpaceId;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final spacesAsync = ref.watch(spacesNotifierProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Espaço${widget.isRequired ? ' *' : ''}',
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        spacesAsync.when(
          data: (spacesState) {
            if (spacesState.hasSpaces || !spacesState.hasSpaces) {
              return _buildSpaceDropdown(context, spacesState, theme);
            }
            if (spacesState.error != null) {
              return Container(
                height: 56,
                decoration: BoxDecoration(
                  border: Border.all(color: theme.colorScheme.error),
                  borderRadius: BorderRadius.circular(12),
                  color: theme.brightness == Brightness.dark
                      ? const Color(0xFF2C2C2E)
                      : const Color(0xFFFFFFFF),
                ),
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error,
                        color: theme.colorScheme.error,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Erro ao carregar espaços',
                        style: TextStyle(color: theme.colorScheme.error),
                      ),
                    ],
                  ),
                ),
              );
            }

            return _buildSpaceDropdown(context, spacesState, theme);
          },
          loading: () => Container(
            height: 56,
            decoration: BoxDecoration(
              border: Border.all(
                color: theme.colorScheme.outline.withValues(alpha: 0.5),
              ),
              borderRadius: BorderRadius.circular(12),
              color: theme.brightness == Brightness.dark
                  ? const Color(0xFF2C2C2E)
                  : const Color(0xFFFFFFFF),
            ),
            child: const Center(
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          ),
          error: (error, _) => Container(
            height: 56,
            decoration: BoxDecoration(
              border: Border.all(color: theme.colorScheme.error),
              borderRadius: BorderRadius.circular(12),
              color: theme.brightness == Brightness.dark
                  ? const Color(0xFF2C2C2E)
                  : const Color(0xFFFFFFFF),
            ),
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error, color: theme.colorScheme.error, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Erro ao carregar espaços',
                    style: TextStyle(color: theme.colorScheme.error),
                  ),
                ],
              ),
            ),
          ),
        ),
        if (widget.errorText != null) ...[
          const SizedBox(height: 8),
          Text(
            widget.errorText!,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.error,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildSpaceDropdown(
    BuildContext context,
    SpacesState spacesState,
    ThemeData theme,
  ) {
    final spaces = spacesState.allSpaces;

    final List<DropdownMenuItem<String?>> items = [
      DropdownMenuItem<String?>(
        value: null,
        child: Text(
          'Sem espaço',
          style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
        ),
      ),
      if (spaces.isNotEmpty)
        const DropdownMenuItem<String?>(
          value: 'divider1',
          enabled: false,
          child: Divider(height: 1),
        ),
      ...spaces.map(
        (space) => DropdownMenuItem<String?>(
          value: space.id,
          child: Text(space.displayName),
        ),
      ),
      if (spaces.isNotEmpty)
        const DropdownMenuItem<String?>(
          value: 'divider2',
          enabled: false,
          child: Divider(height: 1),
        ),
      DropdownMenuItem<String?>(
        value: 'CREATE_NEW',
        child: Row(
          children: [
            Icon(Icons.add, size: 16, color: theme.colorScheme.primary),
            const SizedBox(width: 8),
            Text(
              'Cadastrar novo espaço',
              style: TextStyle(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    ];

    return DropdownButtonFormField<String?>(
      initialValue: _selectedSpaceId,
      onChanged: (value) {
        if (value == 'CREATE_NEW') {
          _showAddSpaceDialog(context);
        } else {
          setState(() {
            _selectedSpaceId = value;
          });
          widget.onSpaceChanged(value);
        }
      },
      decoration: InputDecoration(
        hintText: 'Selecione um espaço',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: theme.colorScheme.outline.withValues(alpha: 0.5),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: theme.colorScheme.outline.withValues(alpha: 0.5),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: theme.colorScheme.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: theme.colorScheme.error, width: 2),
        ),
        filled: true,
        fillColor: theme.brightness == Brightness.dark
            ? const Color(0xFF2C2C2E)
            : const Color(0xFFFFFFFF), // Branco puro para modo claro
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 12,
        ),
      ),
      items: items,
      isExpanded: true,
    );
  }

  Future<void> _showAddSpaceDialog(BuildContext context) async {
    final controller = TextEditingController();

    final name = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Novo Espaço'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Nome do espaço'),
            const SizedBox(height: 8),
            TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: 'Ex: Jardim da frente',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              autofocus: true,
              textCapitalization: TextCapitalization.sentences,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                Navigator.of(context).pop(controller.text.trim());
              }
            },
            child: const Text('Adicionar'),
          ),
        ],
      ),
    );

    controller.dispose();

    if (name != null && name.isNotEmpty) {
      widget.onSpaceChanged('CREATE_NEW:$name');
    }
  }
}

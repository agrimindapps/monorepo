import 'package:flutter/material.dart';
import '../../domain/task_list_group_entity.dart';
import '../../../../shared/widgets/emoji_picker_widget.dart';

class CreateEditGroupDialog extends StatefulWidget {
  final TaskListGroupEntity? group; // null = create, not null = edit
  final String userId;

  const CreateEditGroupDialog({super.key, this.group, required this.userId});

  @override
  State<CreateEditGroupDialog> createState() => _CreateEditGroupDialogState();

  static Future<TaskListGroupEntity?> show(
    BuildContext context, {
    TaskListGroupEntity? group,
    required String userId,
  }) async {
    return showDialog<TaskListGroupEntity>(
      context: context,
      builder: (context) => CreateEditGroupDialog(group: group, userId: userId),
    );
  }
}

class _CreateEditGroupDialogState extends State<CreateEditGroupDialog> {
  late TextEditingController _nameController;
  String? _selectedIcon;
  String _selectedColor = '#2196F3';

  final List<String> _availableColors = [
    '#2196F3', // Blue
    '#4CAF50', // Green
    '#FF5722', // Orange
    '#9C27B0', // Purple
    '#F44336', // Red
    '#00BCD4', // Cyan
    '#FFC107', // Amber
    '#607D8B', // Grey
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.group?.name);
    _selectedIcon = widget.group?.icon;
    _selectedColor = widget.group?.color ?? '#2196F3';
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.group != null;

    return AlertDialog(
      title: Text(isEdit ? 'Editar Grupo' : 'Novo Grupo'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Name field
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Nome do Grupo',
                hintText: 'Ex: Trabalho, Pessoal...',
                border: OutlineInputBorder(),
              ),
              autofocus: true,
              textCapitalization: TextCapitalization.sentences,
            ),

            const SizedBox(height: 24),

            // Icon selection
            Text('Ícone', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: () {
                EmojiPickerBottomSheet.show(
                  context,
                  currentEmoji: _selectedIcon,
                  onEmojiSelected: (emoji) {
                    setState(
                      () => _selectedIcon = emoji.isNotEmpty ? emoji : null,
                    );
                  },
                );
              },
              icon: _selectedIcon != null
                  ? Text(_selectedIcon!, style: const TextStyle(fontSize: 24))
                  : const Icon(Icons.add_reaction_outlined),
              label: Text(
                _selectedIcon != null ? 'Alterar Emoji' : 'Escolher Emoji',
              ),
            ),

            const SizedBox(height: 24),

            // Color selection
            Text('Cor', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: _availableColors.map((colorHex) {
                final color = _parseColor(colorHex);
                final isSelected = _selectedColor == colorHex;
                return InkWell(
                  onTap: () => setState(() => _selectedColor = colorHex),
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected ? Colors.white : Colors.transparent,
                        width: 3,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: color.withValues(alpha: 0.5),
                                blurRadius: 8,
                                spreadRadius: 2,
                              ),
                            ]
                          : null,
                    ),
                    child: isSelected
                        ? const Icon(Icons.check, color: Colors.white)
                        : null,
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: _handleSave,
          child: Text(isEdit ? 'Salvar' : 'Criar'),
        ),
      ],
    );
  }

  void _handleSave() {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Digite um nome para o grupo')),
      );
      return;
    }

    final now = DateTime.now();
    final group = TaskListGroupEntity(
      id: widget.group?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      userId: widget.userId,
      icon: _selectedIcon,
      color: _selectedColor,
      position: widget.group?.position ?? 0,
      createdAt: widget.group?.createdAt ?? now,
      updatedAt: now,
      isCollapsed: widget.group?.isCollapsed ?? false,
    );

    Navigator.pop(context, group);
  }

  Color _parseColor(String colorHex) {
    try {
      return Color(int.parse(colorHex.replaceAll('#', '0xFF')));
    } catch (e) {
      return Colors.blue;
    }
  }
}

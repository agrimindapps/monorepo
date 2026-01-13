import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../shared/constants/task_list_colors.dart';
import '../../../shared/widgets/color_picker.dart';
import '../../tasks/domain/task_list_entity.dart';
import '../providers/task_list_providers.dart';

class CreateEditTaskListPage extends ConsumerStatefulWidget {
  final TaskListEntity? taskList;

  const CreateEditTaskListPage({
    super.key,
    this.taskList,
  });

  @override
  ConsumerState<CreateEditTaskListPage> createState() =>
      _CreateEditTaskListPageState();
}

class _CreateEditTaskListPageState
    extends ConsumerState<CreateEditTaskListPage> {
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late String _selectedColor;
  String? _selectedBackground;

  bool get isEditing => widget.taskList != null;

  final List<String> _backgroundOptions = [
    'none',
    'mountain',
    'beach',
    'city',
    'forest',
    'abstract',
  ];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.taskList?.title);
    _descriptionController =
        TextEditingController(text: widget.taskList?.description);
    _selectedColor =
        widget.taskList?.color ?? TaskListColors.defaultColor;
    _selectedBackground = widget.taskList?.backgroundImage;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Digite um título para a lista'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final taskList = TaskListEntity(
      id: widget.taskList?.id ?? const Uuid().v4(),
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim(),
      color: _selectedColor,
      ownerId: widget.taskList?.ownerId ?? '', // Will be set in datasource
      memberIds: widget.taskList?.memberIds ?? [],
      createdAt: widget.taskList?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
      isShared: widget.taskList?.isShared ?? false,
      isArchived: widget.taskList?.isArchived ?? false,
      position: widget.taskList?.position ?? 0,
      backgroundImage: _selectedBackground == 'none' ? null : _selectedBackground,
    );

    if (isEditing) {
      final success = await ref
          .read(updateTaskListProvider.notifier)
          .call(taskList);

      if (!mounted) return;

      if (success) {
        Navigator.of(context).pop(true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Lista atualizada com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erro ao atualizar lista'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } else {
      final id = await ref
          .read(createTaskListProvider.notifier)
          .call(taskList);

      if (!mounted) return;

      if (id != null) {
        Navigator.of(context).pop(true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Lista criada com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erro ao criar lista'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final createState = ref.watch(createTaskListProvider);
    final updateState = ref.watch(updateTaskListProvider);
    final isLoading =
        createState.isLoading || updateState.isLoading;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Editar Lista' : 'Nova Lista'),
        actions: [
          if (isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            )
          else
            IconButton(
              icon: const Icon(Icons.check),
              onPressed: _save,
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Título
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Título da lista *',
                hintText: 'Ex: Compras, Trabalho, Projetos...',
                border: OutlineInputBorder(),
              ),
              textCapitalization: TextCapitalization.sentences,
              maxLength: 50,
            ),
            const SizedBox(height: 16),

            // Descrição
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Descrição (opcional)',
                hintText: 'Adicione detalhes sobre a lista',
                border: OutlineInputBorder(),
              ),
              textCapitalization: TextCapitalization.sentences,
              maxLines: 3,
              maxLength: 200,
            ),
            const SizedBox(height: 24),

            // Seletor de Cor
            Text(
              'Cor da lista',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            ColorPicker(
              selectedColor: _selectedColor,
              onColorSelected: (color) {
                setState(() {
                  _selectedColor = color;
                });
              },
            ),
            const SizedBox(height: 24),

            // Seletor de Fundo
            Text(
              'Imagem de Fundo',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 80,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _backgroundOptions.length,
                separatorBuilder: (context, index) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  final bg = _backgroundOptions[index];
                  final isSelected = 
                      (bg == 'none' && _selectedBackground == null) || 
                      bg == _selectedBackground;
                  
                  return InkWell(
                    onTap: () {
                      setState(() {
                        _selectedBackground = bg == 'none' ? null : bg;
                      });
                    },
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: bg == 'none' ? Colors.grey[200] : Colors.grey[300],
                        borderRadius: BorderRadius.circular(8),
                        border: isSelected
                            ? Border.all(
                                color: Theme.of(context).primaryColor,
                                width: 3,
                              )
                            : null,
                        image: bg != 'none' 
                            ? null // TODO: Add actual assets
                            : null,
                      ),
                      child: Center(
                        child: bg == 'none'
                            ? const Icon(Icons.block, color: Colors.grey)
                            : Text(
                                bg[0].toUpperCase() + bg.substring(1),
                                style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                              ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),

            // Preview
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: TaskListColors.fromHex(_selectedColor).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: TaskListColors.fromHex(_selectedColor),
                  width: 2,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.list,
                    color: TaskListColors.fromHex(_selectedColor),
                    size: 32,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _titleController.text.isEmpty
                              ? 'Preview da lista'
                              : _titleController.text,
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color:
                                    TaskListColors.fromHex(_selectedColor),
                              ),
                        ),
                        if (_descriptionController.text.isNotEmpty)
                          Text(
                            _descriptionController.text,
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(
                                  color: Colors.grey[600],
                                ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

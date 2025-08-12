// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../models/72_task_list.dart';

class CreateListDialog extends StatefulWidget {
  final String userId;
  final TaskList? editingList;

  const CreateListDialog({
    super.key,
    required this.userId,
    this.editingList,
  });

  @override
  State<CreateListDialog> createState() => _CreateListDialogState();
}

class _CreateListDialogState extends State<CreateListDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  String _selectedColor = 'FF2196F3'; // Azul padrão
  bool _isShared = false;

  final List<String> _availableColors = [
    'FF2196F3', // Azul
    'FF4CAF50', // Verde
    'FFFF9800', // Laranja
    'FFF44336', // Vermelho
    'FF9C27B0', // Roxo
    'FF607D8B', // Azul acinzentado
    'FF795548', // Marrom
    'FF009688', // Teal
    'FFFF5722', // Laranja escuro
    'FF3F51B5', // Índigo
  ];

  @override
  void initState() {
    super.initState();
    if (widget.editingList != null) {
      _populateFormWithList(widget.editingList!);
    }
  }

  void _populateFormWithList(TaskList list) {
    _titleController.text = list.title;
    _descriptionController.text = list.description ?? '';
    _selectedColor = list.color;
    _isShared = list.isShared;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        padding: const EdgeInsets.all(20),
        constraints: const BoxConstraints(maxWidth: 400, maxHeight: 600),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.editingList != null ? 'Editar Lista' : 'Nova Lista',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 20),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTitleField(),
                      const SizedBox(height: 16),
                      _buildDescriptionField(),
                      const SizedBox(height: 16),
                      _buildColorPicker(),
                      const SizedBox(height: 16),
                      _buildSharedToggle(),
                      const SizedBox(height: 16),
                      _buildPreview(),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              _buildActionButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTitleField() {
    return TextFormField(
      controller: _titleController,
      decoration: const InputDecoration(
        labelText: 'Nome da Lista',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.title),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Por favor, insira um nome para a lista';
        }
        return null;
      },
      textCapitalization: TextCapitalization.words,
    );
  }

  Widget _buildDescriptionField() {
    return TextFormField(
      controller: _descriptionController,
      maxLines: 2,
      decoration: const InputDecoration(
        labelText: 'Descrição (opcional)',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.description),
      ),
      textCapitalization: TextCapitalization.sentences,
    );
  }

  Widget _buildColorPicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Cor da Lista:', style: TextStyle(fontSize: 16)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _availableColors.map((color) {
            final isSelected = _selectedColor == color;
            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedColor = color;
                });
              },
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Color(int.parse('0x$color')),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected ? Colors.black : Colors.transparent,
                    width: 2,
                  ),
                ),
                child: isSelected
                    ? const Icon(Icons.check, color: Colors.white)
                    : null,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildSharedToggle() {
    return Row(
      children: [
        const Icon(Icons.share, color: Colors.blue),
        const SizedBox(width: 8),
        const Text('Lista compartilhada'),
        const Spacer(),
        Switch(
          value: _isShared,
          onChanged: (value) {
            setState(() {
              _isShared = value;
            });
          },
        ),
      ],
    );
  }

  Widget _buildPreview() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.withValues(alpha: 0.3)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Preview:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Row(
            children: [
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: Color(int.parse('0x$_selectedColor')),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _titleController.text.isEmpty
                          ? 'Nome da Lista'
                          : _titleController.text,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    if (_descriptionController.text.isNotEmpty)
                      Text(
                        _descriptionController.text,
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                  ],
                ),
              ),
              if (_isShared)
                const Icon(Icons.share, size: 16, color: Colors.blue),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        const SizedBox(width: 8),
        ElevatedButton(
          onPressed: _saveList,
          child: Text(widget.editingList != null ? 'Atualizar' : 'Criar'),
        ),
      ],
    );
  }

  void _saveList() {
    if (_formKey.currentState!.validate()) {
      final now = DateTime.now();
      final nowMs = now.millisecondsSinceEpoch;
      final list = TaskList(
        id: widget.editingList?.id ?? 'list_$nowMs',
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        color: _selectedColor,
        ownerId: widget.userId,
        createdAt: widget.editingList?.createdAt ?? nowMs,
        updatedAt: nowMs,
        isShared: _isShared,
      );

      Navigator.of(context).pop(list);
    }
  }
}

import 'package:flutter/material.dart';

class NotesExpansionDialog extends StatefulWidget {
  final String? initialNotes;
  final void Function(String?) onSave;

  const NotesExpansionDialog({
    super.key,
    this.initialNotes,
    required this.onSave,
  });

  @override
  State<NotesExpansionDialog> createState() => _NotesExpansionDialogState();
}

class _NotesExpansionDialogState extends State<NotesExpansionDialog> {
  late TextEditingController _notesController;

  @override
  void initState() {
    super.initState();
    _notesController = TextEditingController(text: widget.initialNotes ?? '');
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  void _saveNotes() {
    final notes = _notesController.text.trim();
    widget.onSave(notes.isEmpty ? null : notes);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(16),
      child: Container(
        width: double.infinity,
        height: MediaQuery.of(context).size.height * 0.7,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Anotações da Tarefa',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: TextField(
                controller: _notesController,
                maxLines: null,
                expands: true,
                textAlignVertical: TextAlignVertical.top,
                decoration: const InputDecoration(
                  hintText: 'Digite suas anotações aqui...\n\nVocê pode usar este espaço para:\n• Detalhes importantes\n• Lembretes pessoais\n• Links e referências\n• Qualquer informação adicional',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.all(16),
                ),
                autofocus: true,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancelar'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _saveNotes,
                  child: const Text('Salvar'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
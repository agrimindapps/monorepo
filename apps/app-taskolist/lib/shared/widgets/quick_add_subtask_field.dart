import 'package:core/core.dart' hide FormState;
import 'package:flutter/material.dart';

import '../../features/tasks/domain/task_entity.dart';
import '../../features/tasks/presentation/providers/task_notifier.dart';
import '../providers/auth_providers.dart';

/// Widget para adicionar subtarefa rapidamente (inline)
class QuickAddSubtaskField extends ConsumerStatefulWidget {
  final String parentTaskId;

  const QuickAddSubtaskField({
    super.key,
    required this.parentTaskId,
  });

  @override
  ConsumerState<QuickAddSubtaskField> createState() =>
      _QuickAddSubtaskFieldState();
}

class _QuickAddSubtaskFieldState extends ConsumerState<QuickAddSubtaskField> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _isLoading = false;
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      setState(() {
        _hasText = _controller.text.trim().isNotEmpty;
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _createSubtask() async {
    final title = _controller.text.trim();
    if (title.isEmpty) return;

    final currentUser = ref.read(authProvider).value;
    if (currentUser == null) {
      _showError('Usuário não autenticado');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final newSubtask = TaskEntity(
        id: FirebaseFirestore.instance.collection('_').doc().id,
        title: title,
        listId: 'default',
        createdById: currentUser.id,
        parentTaskId: widget.parentTaskId,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await ref.read(taskProvider.notifier).createSubtask(newSubtask);

      // Limpar campo e remover foco
      _controller.clear();
      _focusNode.unfocus();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Subtarefa adicionada!'),
            duration: Duration(seconds: 1),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        _showError('Erro ao criar subtarefa: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(top: 8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          children: [
            Icon(
              Icons.add_circle_outline,
              color: Colors.grey[600],
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: _controller,
                focusNode: _focusNode,
                enabled: !_isLoading,
                decoration: InputDecoration(
                  hintText: 'Adicionar subtarefa...',
                  hintStyle: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[500],
                  ),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(vertical: 8),
                ),
                style: const TextStyle(fontSize: 14),
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _createSubtask(),
              ),
            ),
            if (_isLoading)
              const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            else if (_hasText)
              IconButton(
                icon: const Icon(Icons.send, size: 18),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onPressed: _createSubtask,
                color: Theme.of(context).primaryColor,
              ),
          ],
        ),
      ),
    );
  }
}

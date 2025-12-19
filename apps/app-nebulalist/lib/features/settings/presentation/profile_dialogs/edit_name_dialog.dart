import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/presentation/providers/auth_provider.dart';

/// Dialog para editar o nome de exibição do usuário
class EditNameDialog extends ConsumerStatefulWidget {
  final String? currentName;

  const EditNameDialog({
    super.key,
    this.currentName,
  });

  @override
  ConsumerState<EditNameDialog> createState() => _EditNameDialogState();
}

class _EditNameDialogState extends ConsumerState<EditNameDialog> {
  late final TextEditingController _controller;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.currentName);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.edit, size: 24),
          SizedBox(width: 12),
          Text('Editar Nome'),
        ],
      ),
      content: TextField(
        controller: _controller,
        autofocus: true,
        enabled: !_isLoading,
        decoration: const InputDecoration(
          labelText: 'Nome de exibição',
          hintText: 'Digite seu nome',
          border: OutlineInputBorder(),
        ),
        textCapitalization: TextCapitalization.words,
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _handleSave,
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Text('Salvar'),
        ),
      ],
    );
  }

  Future<void> _handleSave() async {
    final newName = _controller.text.trim();

    if (newName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Nome não pode estar vazio'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    final success = await ref.read(authProvider.notifier).updateProfile(
          displayName: newName,
        );

    if (!mounted) return;

    setState(() => _isLoading = false);

    Navigator.of(context).pop();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success ? '✅ Nome atualizado para: $newName' : '❌ Erro ao atualizar nome',
        ),
        backgroundColor: success ? Colors.green : Colors.red,
      ),
    );
  }

  /// Mostra o dialog e aguarda resultado
  static Future<void> show(
    BuildContext context,
    WidgetRef ref,
    String? currentName,
  ) async {
    await showDialog<void>(
      context: context,
      builder: (_) => EditNameDialog(currentName: currentName),
    );
  }
}

import 'package:flutter/material.dart';

class DeletionPasswordDialog extends StatefulWidget {
  const DeletionPasswordDialog({super.key, required this.controller});

  final TextEditingController controller;

  @override
  State<DeletionPasswordDialog> createState() => _DeletionPasswordDialogState();
}

class _DeletionPasswordDialogState extends State<DeletionPasswordDialog> {
  bool _isPasswordVisible = false;
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_updateButtonState);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_updateButtonState);
    super.dispose();
  }

  void _updateButtonState() {
    setState(() {
      _hasText = widget.controller.text.trim().isNotEmpty;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.security, color: Colors.blue),
          SizedBox(width: 12),
          Text('Confirmação de Identidade'),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Por questões de segurança, confirme sua senha atual para prosseguir com a exclusão da conta.',
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 24),
          TextField(
            controller: widget.controller,
            obscureText: !_isPasswordVisible,
            autofocus: true,
            decoration: InputDecoration(
              labelText: 'Senha atual',
              hintText: 'Digite sua senha atual',
              prefixIcon: const Icon(Icons.lock),
              suffixIcon: IconButton(
                icon: Icon(
                  _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                ),
                onPressed: () =>
                    setState(() => _isPasswordVisible = !_isPasswordVisible),
              ),
              border: const OutlineInputBorder(),
            ),
            onSubmitted: _hasText
                ? (_) =>
                    Navigator.of(context).pop(widget.controller.text.trim())
                : null,
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                Icon(Icons.info, color: Colors.blue.shade600, size: 20),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Esta validação é obrigatória para proteger sua conta de exclusões não autorizadas.',
                    style: TextStyle(fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(null),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _hasText
              ? () => Navigator.of(context).pop(widget.controller.text.trim())
              : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
          ),
          child: const Text('Confirmar'),
        ),
      ],
    );
  }
}

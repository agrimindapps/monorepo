import 'package:core/core.dart';
import 'package:flutter/material.dart';

import '../../features/auth/presentation/notifiers/auth_notifier.dart';
import '../../features/auth/presentation/providers/auth_providers.dart';
import '../services/avatar_service.dart';

/// Dialog for avatar selection with camera, gallery and remove options
class AvatarSelectionDialog extends ConsumerStatefulWidget {
  const AvatarSelectionDialog({super.key});

  @override
  ConsumerState<AvatarSelectionDialog> createState() => _AvatarSelectionDialogState();
}

class _AvatarSelectionDialogState extends ConsumerState<AvatarSelectionDialog> {
  final AvatarService _avatarService = AvatarService();
  bool _isProcessing = false;
  AvatarResult? _previewResult;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Alterar Avatar',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            // Preview section
            if (_previewResult != null && _previewResult!.success)
              _buildPreviewSection(),
            
            // Loading indicator
            if (_isProcessing)
              const Padding(
                padding: EdgeInsets.all(24),
                child: Column(
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Processando imagem...'),
                  ],
                ),
              ),
            
            // Action buttons
            if (!_isProcessing) ...[
              const SizedBox(height: 16),
              _buildActionButtons(context),
            ],
            
            const SizedBox(height: 16),
            
            // Cancel/Close buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancelar'),
                ),
                if (_previewResult != null && _previewResult!.success) ...[
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _saveAvatar,
                    child: const Text('Salvar'),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreviewSection() {
    final bytes = _avatarService.decodeAvatarBytes(_previewResult!.base64Data);
    if (bytes == null) return const SizedBox.shrink();

    return Column(
      children: [
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: Theme.of(context).primaryColor,
              width: 2,
            ),
          ),
          child: ClipOval(
            child: Image.memory(
              bytes,
              fit: BoxFit.cover,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Tamanho: ${_previewResult!.sizeKB!.toStringAsFixed(1)} KB',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Prévia do seu novo avatar',
          style: TextStyle(fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Column(
      children: [
        // Camera button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _selectFromCamera,
            icon: const Icon(Icons.camera_alt),
            label: const Text('Câmera'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
        const SizedBox(height: 12),
        
        // Gallery button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _selectFromGallery,
            icon: const Icon(Icons.photo_library),
            label: const Text('Galeria'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
        
        // Remove button (only if user has avatar)
        Consumer(
          builder: (context, ref, _) {
            final currentUser = ref.watch(currentUserProvider);
            final hasAvatar = currentUser?.hasLocalAvatar == true ||
                currentUser?.hasProfilePhoto == true;
            
            if (!hasAvatar) return const SizedBox.shrink();
            
            return Column(
              children: [
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: TextButton.icon(
                    onPressed: _removeAvatar,
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    label: const Text(
                      'Remover Avatar',
                      style: TextStyle(color: Colors.red),
                    ),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      side: const BorderSide(color: Colors.red),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  Future<void> _selectFromCamera() async {
    await _processAvatarSelection(() => _avatarService.selectFromCamera());
  }

  Future<void> _selectFromGallery() async {
    await _processAvatarSelection(() => _avatarService.selectFromGallery());
  }

  Future<void> _processAvatarSelection(Future<AvatarResult> Function() selectionFn) async {
    setState(() {
      _isProcessing = true;
      _previewResult = null;
    });

    try {
      final result = await selectionFn();
      
      setState(() {
        _isProcessing = false;
      });

      if (result.success && result.base64Data != null) {
        setState(() {
          _previewResult = result;
        });
      } else if (!result.cancelled && result.errorMessage != null) {
        _showErrorSnackBar(result.errorMessage!);
      }
    } catch (e) {
      setState(() {
        _isProcessing = false;
      });
      _showErrorSnackBar('Erro inesperado: ${e.toString()}');
    }
  }

  Future<void> _saveAvatar() async {
    if (_previewResult?.base64Data == null) return;

    try {
      final authNotifier = ref.read(authProvider.notifier);
      final success = await authNotifier.updateAvatar(_previewResult!.base64Data!);

      if (success) {
        if (mounted) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Avatar atualizado com sucesso!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        _showErrorSnackBar('Erro ao salvar avatar');
      }
    } catch (e) {
      _showErrorSnackBar('Erro ao salvar: ${e.toString()}');
    }
  }

  Future<void> _removeAvatar() async {
    try {
      final authNotifier = ref.read(authProvider.notifier);
      final success = await authNotifier.removeAvatar();

      if (success) {
        if (mounted) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Avatar removido com sucesso!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        _showErrorSnackBar('Erro ao remover avatar');
      }
    } catch (e) {
      _showErrorSnackBar('Erro ao remover: ${e.toString()}');
    }
  }

  void _showErrorSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

/// Show avatar selection dialog
Future<void> showAvatarSelectionDialog(BuildContext context) {
  return showDialog(
    context: context,
    builder: (context) => const AvatarSelectionDialog(),
  );
}
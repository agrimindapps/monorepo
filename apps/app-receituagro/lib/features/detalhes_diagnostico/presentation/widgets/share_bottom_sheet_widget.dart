import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';

class ShareBottomSheetWidget extends StatelessWidget {
  final String shareText;
  final VoidCallback? onSuccess;
  final void Function(String)? onError;

  const ShareBottomSheetWidget({
    super.key,
    required this.shareText,
    this.onSuccess,
    this.onError,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      margin: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            margin: const EdgeInsets.symmetric(vertical: 12),
            height: 4,
            width: 40,
            decoration: BoxDecoration(
              color: theme.dividerColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Icon(
                  Icons.share,
                  size: 48,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(height: 12),
                Text(
                  'Compartilhar Diagnóstico',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Escolha como deseja compartilhar as informações',
                  style: TextStyle(
                    fontSize: 14,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                _buildShareOption(
                  context,
                  icon: Icons.share,
                  title: 'Compartilhar via Apps',
                  subtitle: 'WhatsApp, Telegram, Email, etc.',
                  onTap: () => _shareViaApps(context),
                ),
                _buildShareOption(
                  context,
                  icon: Icons.copy,
                  title: 'Copiar Texto',
                  subtitle: 'Copiar informações para área de transferência',
                  onTap: () => _copyToClipboard(context),
                ),
                _buildShareOption(
                  context,
                  icon: Icons.text_fields,
                  title: 'Compartilhar Personalizado',
                  subtitle: 'Editar texto antes de compartilhar',
                  onTap: () => _shareCustomText(context),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildShareOption(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          Navigator.pop(context);
          onTap();
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            border: Border.all(
              color: theme.dividerColor,
              width: 1,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  color: theme.colorScheme.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _shareViaApps(BuildContext context) async {
    try {
      await Share.share(shareText);
      onSuccess?.call();
    } catch (e) {
      onError?.call('Erro ao compartilhar via apps');
    }
  }

  void _copyToClipboard(BuildContext context) async {
    try {
      await Clipboard.setData(ClipboardData(text: shareText));
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Diagnóstico copiado para área de transferência'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      onSuccess?.call();
    } catch (e) {
      onError?.call('Erro ao copiar texto');
    }
  }

  void _shareCustomText(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (context) => _buildCustomShareDialog(context),
    );
  }

  Widget _buildCustomShareDialog(BuildContext context) {
    final theme = Theme.of(context);
    final textController = TextEditingController(text: shareText);
    
    return AlertDialog(
      backgroundColor: theme.dialogTheme.backgroundColor ?? theme.cardColor,
      title: Text(
        'Personalizar Compartilhamento',
        style: TextStyle(color: theme.colorScheme.onSurface),
      ),
      content: SizedBox(
        width: double.maxFinite,
        height: 400,
        child: Column(
          children: [
            Text(
              'Edite o texto antes de compartilhar:',
              style: TextStyle(
                fontSize: 14,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: TextField(
                controller: textController,
                maxLines: null,
                expands: true,
                textAlignVertical: TextAlignVertical.top,
                style: TextStyle(
                  fontSize: 12,
                  color: theme.colorScheme.onSurface,
                ),
                decoration: InputDecoration(
                  hintText: 'Personalize seu texto aqui...',
                  hintStyle: TextStyle(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(
            'Cancelar',
            style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
          ),
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                try {
                  await Clipboard.setData(ClipboardData(text: textController.text));
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Texto copiado para área de transferência'),
                        backgroundColor: Colors.green,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                  onSuccess?.call();
                } catch (e) {
                  onError?.call('Erro ao copiar texto');
                }
              },
              child: Text(
                'Copiar',
                style: TextStyle(color: theme.colorScheme.primary),
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();
                try {
                  await Share.share(textController.text);
                  onSuccess?.call();
                } catch (e) {
                  onError?.call('Erro ao compartilhar texto');
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: theme.colorScheme.onPrimary,
              ),
              child: const Text('Compartilhar'),
            ),
          ],
        ),
      ],
    );
  }
}
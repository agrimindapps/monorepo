// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:share_plus/share_plus.dart';

// Project imports:
import '../controller/condicao_corporal_controller.dart';

class ShareService {
  static Future<void> shareResult({
    required BuildContext context,
    required CondicaoCorporalController controller,
    ShareFormat format = ShareFormat.text,
  }) async {
    if (controller.resultado == null) return;

    try {
      switch (format) {
        case ShareFormat.text:
          await _shareAsText(controller);
          break;
        case ShareFormat.whatsapp:
          await _shareToWhatsApp(controller);
          break;
        case ShareFormat.telegram:
          await _shareToTelegram(controller);
          break;
        case ShareFormat.email:
          await _shareToEmail(controller);
          break;
      }
    } catch (e) {
      debugPrint('Erro ao compartilhar: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erro ao compartilhar resultado. Tente novamente.'),
          ),
        );
      }
    }
  }

  static Future<void> _shareAsText(CondicaoCorporalController controller) async {
    final shareText = _generateShareText(controller);
    await Share.share(shareText);
  }

  static Future<void> _shareToWhatsApp(CondicaoCorporalController controller) async {
    final shareText = _generateShareText(controller, platform: 'WhatsApp');
    await Share.share(shareText);
  }

  static Future<void> _shareToTelegram(CondicaoCorporalController controller) async {
    final shareText = _generateShareText(controller, platform: 'Telegram');
    await Share.share(shareText);
  }

  static Future<void> _shareToEmail(CondicaoCorporalController controller) async {
    const subject = 'Resultado da Avaliação de Condição Corporal';
    final body = _generateShareText(controller, isEmail: true);
    
    await Share.share(body, subject: subject);
  }

  static String _generateShareText(
    CondicaoCorporalController controller, {
    String? platform,
    bool isEmail = false,
  }) {
    final emoji = _getEmojiForResult(controller);
    final header = platform != null ? '📱 Compartilhado via $platform\n\n' : '';
    
    return '''
$header🐾 AVALIAÇÃO DE CONDIÇÃO CORPORAL $emoji

📋 Dados da Avaliação:
• Espécie: ${controller.especieSelecionada}
• Escore ECC: ${controller.indiceSelecionado}/9

${controller.resultado}

${isEmail ? '\n' : ''}📱 Esta avaliação foi gerada pelo app fNutriTuti
⚠️ Sempre consulte um veterinário para orientações específicas

#fNutriTuti #CondicaoCorporal #Pet #Veterinario
    '''.trim();
  }

  static String _getEmojiForResult(CondicaoCorporalController controller) {
    if (controller.indiceSelecionado == null) return '📊';
    
    if (controller.indiceSelecionado! <= 3) return '📉';
    if (controller.indiceSelecionado! <= 5) return '✅';
    return '📈';
  }

  static void showShareOptionsDialog(
    BuildContext context,
    CondicaoCorporalController controller,
  ) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => _ShareOptionsWidget(controller: controller),
    );
  }

  static void showSharePreview(
    BuildContext context,
    CondicaoCorporalController controller,
  ) {
    final previewText = _generateShareText(controller);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Preview do Compartilhamento'),
        content: SingleChildScrollView(
          child: Text(previewText),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              shareResult(
                context: context,
                controller: controller,
                format: ShareFormat.text,
              );
            },
            child: const Text('Compartilhar'),
          ),
        ],
      ),
    );
  }
}

enum ShareFormat {
  text,
  whatsapp,
  telegram,
  email,
}

class _ShareOptionsWidget extends StatelessWidget {
  final CondicaoCorporalController controller;

  const _ShareOptionsWidget({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Compartilhar Resultado',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Escolha como você gostaria de compartilhar o resultado da avaliação:',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 20),
          
          // Preview Button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                Navigator.pop(context);
                ShareService.showSharePreview(context, controller);
              },
              icon: const Icon(Icons.preview),
              label: const Text('Ver Preview'),
            ),
          ),
          
          const SizedBox(height: 16),
          
          GridView.count(
            shrinkWrap: true,
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 2.5,
            children: [
              _buildShareOption(
                context,
                icon: Icons.text_fields,
                label: 'Texto Simples',
                onTap: () {
                  Navigator.pop(context);
                  ShareService.shareResult(
                    context: context,
                    controller: controller,
                    format: ShareFormat.text,
                  );
                },
              ),
              _buildShareOption(
                context,
                icon: Icons.chat_bubble,
                label: 'WhatsApp',
                color: Colors.green,
                onTap: () {
                  Navigator.pop(context);
                  ShareService.shareResult(
                    context: context,
                    controller: controller,
                    format: ShareFormat.whatsapp,
                  );
                },
              ),
              _buildShareOption(
                context,
                icon: Icons.send,
                label: 'Telegram',
                color: Colors.blue,
                onTap: () {
                  Navigator.pop(context);
                  ShareService.shareResult(
                    context: context,
                    controller: controller,
                    format: ShareFormat.telegram,
                  );
                },
              ),
              _buildShareOption(
                context,
                icon: Icons.email,
                label: 'Email',
                color: Colors.orange,
                onTap: () {
                  Navigator.pop(context);
                  ShareService.shareResult(
                    context: context,
                    controller: controller,
                    format: ShareFormat.email,
                  );
                },
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          Center(
            child: TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShareOption(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color? color,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 20,
              color: color ?? Colors.grey.shade700,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey.shade700,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

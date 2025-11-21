import 'package:flutter/material.dart';
import '../../constants/settings_design_tokens.dart';

/// Diálogo de confirmação para remoção de dados pessoais
/// Mostra as consequências e o impacto em outros dispositivos
class ClearDataDialog extends StatefulWidget {
  const ClearDataDialog({super.key});

  @override
  State<ClearDataDialog> createState() => _ClearDataDialogState();

  static Future<bool?> show(BuildContext context) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => const ClearDataDialog(),
    );
  }
}

class _ClearDataDialogState extends State<ClearDataDialog> {
  final TextEditingController _confirmationController = TextEditingController();
  bool _isConfirmationValid = false;

  @override
  void dispose() {
    _confirmationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 460),
        child: Padding(
          padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(32),
              ),
              child: const Icon(
                Icons.delete_sweep,
                size: 32,
                color: Colors.red,
              ),
            ),

            const SizedBox(height: 20),
            Text(
              'Remover Dados Pessoais',
              style: SettingsDesignTokens.getSectionTitleStyle(
                context,
              ).copyWith(fontSize: 20),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest.withValues(
                  alpha: 0.3,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Ao remover seus dados pessoais:',
                    style: SettingsDesignTokens.getListTitleStyle(context),
                  ),

                  const SizedBox(height: 12),
                  _buildInfoItem(
                    context,
                    icon: Icons.storage,
                    text:
                        'Seus favoritos e comentários serão removidos deste dispositivo',
                    iconColor: Colors.red,
                  ),

                  const SizedBox(height: 8),
                  _buildInfoItem(
                    context,
                    icon: Icons.sync,
                    text: 'A remoção será sincronizada com todos seus outros dispositivos',
                    iconColor: Colors.red,
                  ),

                  const SizedBox(height: 8),
                  _buildInfoItem(
                    context,
                    icon: Icons.cloud,
                    text:
                        'Esta ação é permanente e não poderá ser desfeita',
                    iconColor: Colors.red,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),
            const Text(
              'Para confirmar, digite CONCORDO abaixo:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _confirmationController,
              onChanged: (value) {
                setState(() {
                  _isConfirmationValid = value.trim().toUpperCase() == 'CONCORDO';
                });
              },
              decoration: InputDecoration(
                hintText: 'Digite CONCORDO para confirmar',
                hintStyle: TextStyle(
                  color: Colors.grey.shade500,
                  fontSize: 14,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.red.shade400, width: 2),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
              ),
              textCapitalization: TextCapitalization.characters,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),

            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          SettingsDesignTokens.iconContainerRadius,
                        ),
                      ),
                      side: BorderSide(color: theme.colorScheme.outline),
                    ),
                    child: Text(
                      'Cancelar',
                      style: TextStyle(
                        color: theme.colorScheme.onSurface,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isConfirmationValid
                        ? () => Navigator.of(context).pop(true)
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isConfirmationValid
                          ? Colors.red
                          : Colors.grey.shade300,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          SettingsDesignTokens.iconContainerRadius,
                        ),
                      ),
                    ),
                    child: const Text(
                      'Limpar Dados',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],
            ),
          ],
          ),
        ),
      ),
    );
  }

  /// Item de informação com ícone e texto
  Widget _buildInfoItem(
    BuildContext context, {
    required IconData icon,
    required String text,
    required Color iconColor,
    Color? textColor,
  }) {
    final theme = Theme.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: iconColor),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: SettingsDesignTokens.getListSubtitleStyle(context).copyWith(
              color: textColor ?? theme.colorScheme.onSurfaceVariant,
              height: 1.3,
            ),
          ),
        ),
      ],
    );
  }
}

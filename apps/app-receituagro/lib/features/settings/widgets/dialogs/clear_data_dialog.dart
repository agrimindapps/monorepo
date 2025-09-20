import 'package:flutter/material.dart';
import '../../constants/settings_design_tokens.dart';

/// Diálogo de confirmação para limpeza de dados
/// Mostra as consequências de limpar os dados locais
class ClearDataDialog extends StatelessWidget {
  const ClearDataDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Ícone
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: SettingsDesignTokens.warningColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(32),
              ),
              child: const Icon(
                Icons.delete_sweep,
                size: 32,
                color: SettingsDesignTokens.warningColor,
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Título
            Text(
              'Limpar Dados Locais',
              style: SettingsDesignTokens.getSectionTitleStyle(context).copyWith(
                fontSize: 20,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 16),
            
            // Informações sobre as consequências
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Ao limpar os dados locais:',
                    style: SettingsDesignTokens.getListTitleStyle(context),
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // Item 1
                  _buildInfoItem(
                    context,
                    icon: Icons.storage,
                    text: 'Todas as receitas, diagnósticos e dados salvos localmente serão removidos',
                    iconColor: SettingsDesignTokens.warningColor,
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // Item 2
                  _buildInfoItem(
                    context,
                    icon: Icons.settings_backup_restore,
                    text: 'Suas configurações e preferências serão resetadas',
                    iconColor: SettingsDesignTokens.warningColor,
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // Item 3 - Informação positiva
                  _buildInfoItem(
                    context,
                    icon: Icons.cloud,
                    text: 'Seus dados na nuvem permanecerão seguros e poderão ser baixados novamente',
                    iconColor: SettingsDesignTokens.successColor,
                    textColor: SettingsDesignTokens.successColor,
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // Item 4 - Informação positiva
                  _buildInfoItem(
                    context,
                    icon: Icons.refresh,
                    text: 'Você pode sincronizar seus dados novamente após a limpeza',
                    iconColor: SettingsDesignTokens.primaryColor,
                    textColor: SettingsDesignTokens.primaryColor,
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Botões
            Row(
              children: [
                // Botão Cancelar
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(SettingsDesignTokens.iconContainerRadius),
                      ),
                      side: BorderSide(
                        color: theme.colorScheme.outline,
                      ),
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
                
                // Botão Limpar
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: SettingsDesignTokens.warningColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(SettingsDesignTokens.iconContainerRadius),
                      ),
                    ),
                    child: const Text(
                      'Limpar Dados',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
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
        Icon(
          icon,
          size: 18,
          color: iconColor,
        ),
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

  /// Método estático para mostrar o diálogo
  static Future<bool?> show(BuildContext context) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => const ClearDataDialog(),
    );
  }
}
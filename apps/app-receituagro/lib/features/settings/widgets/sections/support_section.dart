import 'package:core/core.dart' hide Column;
import 'package:flutter/material.dart';

import '../../../../core/providers/core_providers.dart';
import '../../../../core/providers/core_providers.dart';
import '../../constants/settings_design_tokens.dart';
import '../dialogs/feedback_dialog.dart';
import '../shared/section_header.dart';
import '../shared/settings_card.dart';
import '../shared/settings_list_tile.dart';

/// Support and feedback section
/// Handles app rating and user feedback
class SupportSection extends ConsumerWidget {
  const SupportSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(
          title: 'Suporte',
          icon: Icons.support,
          showIcon: false,
        ),
        SettingsCard(
          child: Column(
            children: [
              SettingsListTile(
                leadingIcon: Icons.star_outline,
                title: 'Avaliar o App',
                subtitle: 'Avalie nossa experiência na loja',
                onTap: () => _showRateApp(context, ref),
              ),
              Divider(
                height: 1,
                thickness: 0.5,
                color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
              ),
              SettingsListTile(
                leadingIcon: Icons.feedback_outlined,
                title: 'Enviar Feedback',
                subtitle: 'Nos ajude a melhorar o app',
                onTap: () => _showFeedback(context, ref),
              ),
              Divider(
                height: 1,
                thickness: 0.5,
                color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
              ),
              SettingsListTile(
                leadingIcon: Icons.info_outline,
                title: 'Sobre o Aplicativo',
                subtitle: 'Versão, suporte e informações',
                onTap: () => _showAboutApp(context, ref),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _showRateApp(BuildContext context, WidgetRef ref) async {
    try {
      // ✅ FIXED: Usar AppRatingService do core package ao invés de placeholder
      final appRatingService = ref.read(appRatingRepositoryProvider);

      // Verificar se pode mostrar o diálogo
      final canShow = await appRatingService.canShowRatingDialog();

      if (canShow) {
        // Mostrar diálogo de avaliação nativo
        if (!context.mounted) return;
        final success = await appRatingService.showRatingDialog(context: context);

        if (context.mounted && !success) {
          // Se não mostrou o diálogo, abrir a loja diretamente
          final storeOpened = await appRatingService.openAppStore();

          if (!storeOpened && context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SettingsDesignTokens.getErrorSnackbar(
                'Não foi possível abrir a loja de aplicativos',
              ),
            );
          }
        }
      } else {
        // Já avaliou ou não atingiu os critérios, abrir loja diretamente
        final storeOpened = await appRatingService.openAppStore();

        if (!storeOpened && context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SettingsDesignTokens.getErrorSnackbar(
              'Não foi possível abrir a loja de aplicativos',
            ),
          );
        } else if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Obrigado por avaliar nosso app!'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SettingsDesignTokens.getErrorSnackbar(
            'Erro ao abrir avaliação do app: $e',
          ),
        );
      }
    }
  }

  Future<void> _showFeedback(BuildContext context, WidgetRef ref) async {
    if (!context.mounted) return;
    await showDialog<void>(
      context: context,
      builder: (context) => const FeedbackDialog(),
    );
  }

  void _showAboutApp(BuildContext context, WidgetRef ref) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sobre o app - Em desenvolvimento'),
          backgroundColor: Colors.blue,
        ),
      );
    }
  }
}

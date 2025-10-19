import 'package:core/core.dart';
import 'package:flutter/material.dart';

import '../../../defensivos/presentation/pages/detalhe_defensivo_page.dart';
import '../../../diagnosticos/presentation/pages/detalhe_diagnostico_page.dart';
import '../providers/diagnosticos_praga_notifier.dart';

/// Widget responsável pelo modal de detalhes do diagnóstico
///
/// Responsabilidade única: exibir detalhes completos de um diagnóstico em modal
/// - Layout responsivo com constraints adequados
/// - Informações detalhadas do diagnóstico
/// - Ações para navegar para defensivo ou diagnóstico detalhado
/// - Premium badges para features pagas
class DiagnosticoDialogWidget extends ConsumerWidget {
  final DiagnosticoModel diagnostico;
  final String pragaName;

  const DiagnosticoDialogWidget({
    super.key,
    required this.diagnostico,
    required this.pragaName,
  });

  /// Mostra o modal de detalhes
  static Future<void> show(
    BuildContext context,
    DiagnosticoModel diagnostico,
    String pragaName,
  ) {
    return showDialog<void>(
      context: context,
      builder:
          (context) => DiagnosticoDialogWidget(
            diagnostico: diagnostico,
            pragaName: pragaName,
          ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Dialog(
      backgroundColor: theme.dialogTheme.backgroundColor ?? theme.cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxHeight: double.infinity,
          maxWidth: 400.0, // Largura máxima de 400px
          minWidth: 360.0, // Largura mínima de 360px
        ),
        child: IntrinsicHeight(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildHeader(context),
              Flexible(child: _buildContent(context)),
              _buildActions(context, ref),
            ],
          ),
        ),
      ),
    );
  }

  /// Cabeçalho do modal com título e botão de fechar
  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  diagnostico.nome,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ),
              IconButton(
                icon: Icon(
                  Icons.close,
                  size: 24,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                onPressed: () => Navigator.of(context).pop(),
                splashRadius: 20,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Ingrediente Ativo: ${diagnostico.ingredienteAtivo}',
            style: TextStyle(
              fontSize: 14,
              fontStyle: FontStyle.italic,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  /// Conteúdo principal do modal
  Widget _buildContent(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          const SizedBox(height: 16),
          _DiagnosticoInfoRow(
            label: 'Dosagem',
            value: diagnostico.dosagem,
            icon: Icons.medical_services,
            isPremium: false, // Removido bloqueio premium
          ),
          const _DiagnosticoInfoRow(
            label: 'Aplicação Terrestre',
            value: 'Não disponível',
            icon: Icons.agriculture,
            isPremium: false, // Removido bloqueio premium
          ),
          const _DiagnosticoInfoRow(
            label: 'Aplicação Aérea',
            value: 'Não disponível',
            icon: Icons.flight,
            isPremium: false, // Removido bloqueio premium
          ),
          const _DiagnosticoInfoRow(
            label: 'Intervalo de Aplicação',
            value: 'Não disponível',
            icon: Icons.schedule,
            isPremium: false, // Removido bloqueio premium
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  /// Ações do modal (botões defensivo e diagnóstico)
  Widget _buildActions(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          Expanded(child: _DefensivoButton(diagnostico: diagnostico, ref: ref)),
          const SizedBox(width: 16),
          Expanded(
            child: _DiagnosticoButton(
              diagnostico: diagnostico,
              pragaName: pragaName,
            ),
          ),
        ],
      ),
    );
  }
}

/// Widget para linha de informação no modal
class _DiagnosticoInfoRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final bool isPremium;

  const _DiagnosticoInfoRow({
    required this.label,
    required this.value,
    required this.icon,
    required this.isPremium,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: theme.colorScheme.onSurfaceVariant,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          if (isPremium) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.amber.shade100,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.amber.shade300),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.diamond, size: 12, color: Colors.amber.shade700),
                  const SizedBox(width: 4),
                  Text(
                    'Premium',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: Colors.amber.shade700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Botão para navegar ao defensivo
class _DefensivoButton extends ConsumerWidget {
  final DiagnosticoModel diagnostico;
  final WidgetRef ref;

  const _DefensivoButton({required this.diagnostico, required this.ref});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return OutlinedButton(
      onPressed: () {
        const fabricante = 'Fabricante Desconhecido';

        if (context.mounted) Navigator.of(context).pop();
        if (context.mounted) {
          Navigator.push(
            context,
            MaterialPageRoute<void>(
              builder:
                  (context) => DetalheDefensivoPage(
                    defensivoName: diagnostico.nome,
                    fabricante: fabricante,
                  ),
            ),
          );
        }
      },
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        side: BorderSide(color: theme.colorScheme.outline),
      ),
      child: Text(
        'Defensivo',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: theme.colorScheme.onSurface,
        ),
      ),
    );
  }
}

/// Botão para navegar ao diagnóstico detalhado
class _DiagnosticoButton extends ConsumerWidget {
  final DiagnosticoModel diagnostico;
  final String pragaName;

  const _DiagnosticoButton({
    required this.diagnostico,
    required this.pragaName,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return ElevatedButton(
      onPressed: () {
        if (context.mounted) Navigator.of(context).pop();
        if (context.mounted) {
          Navigator.push(
            context,
            MaterialPageRoute<void>(
              builder:
                  (context) => DetalheDiagnosticoPage(
                    diagnosticoId: diagnostico.id,
                    nomeDefensivo: diagnostico.nome,
                    nomePraga: pragaName,
                    cultura: diagnostico.cultura,
                  ),
            ),
          );
        }
      },
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 0,
      ),
      child: const Text(
        'Diagnóstico',
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    );
  }
}

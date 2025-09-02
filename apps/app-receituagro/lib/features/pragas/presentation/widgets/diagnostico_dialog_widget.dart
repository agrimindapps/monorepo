import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../DetalheDefensivos/detalhe_defensivo_page.dart';
import '../../../DetalheDiagnostico/detalhe_diagnostico_page.dart';
import '../providers/diagnosticos_praga_provider.dart';

/// Widget responsável pelo modal de detalhes do diagnóstico
/// 
/// Responsabilidade única: exibir detalhes completos de um diagnóstico em modal
/// - Layout responsivo com constraints adequados
/// - Informações detalhadas do diagnóstico
/// - Ações para navegar para defensivo ou diagnóstico detalhado
/// - Premium badges para features pagas
class DiagnosticoDialogWidget extends StatelessWidget {
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
      builder: (context) => DiagnosticoDialogWidget(
        diagnostico: diagnostico,
        pragaName: pragaName,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Dialog(
      backgroundColor: theme.dialogTheme.backgroundColor ?? theme.cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.7,
          maxWidth: MediaQuery.of(context).size.width - 32,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(context),
            Flexible(
              child: _buildContent(context),
            ),
            _buildActions(context),
          ],
        ),
      ),
    );
  }

  /// Cabeçalho do modal com título e botão de fechar
  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);
    
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 16, 0),
      child: Row(
        children: [
          Expanded(
            child: Text(
              diagnostico.nome,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.close,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  /// Conteúdo principal do modal
  Widget _buildContent(BuildContext context) {
    final theme = Theme.of(context);
    
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Ingrediente Ativo
          Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: Text(
              'Ingrediente Ativo: ${diagnostico.ingredienteAtivo}',
              style: TextStyle(
                fontSize: 14,
                fontStyle: FontStyle.italic,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          // Information Cards
          Container(
            padding: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                _DiagnosticoInfoRow(
                  label: 'Dosagem',
                  value: diagnostico.dosagem,
                  icon: Icons.medication,
                  isPremium: true,
                ),
                const SizedBox(height: 16),
                const _DiagnosticoInfoRow(
                  label: 'Aplicação Terrestre',
                  value: '••• L/ha',
                  icon: Icons.agriculture,
                  isPremium: false,
                ),
                const SizedBox(height: 16),
                const _DiagnosticoInfoRow(
                  label: 'Aplicação Aérea',
                  value: '••• L/ha',
                  icon: Icons.flight,
                  isPremium: false,
                ),
                const SizedBox(height: 16),
                const _DiagnosticoInfoRow(
                  label: 'Intervalo de Aplicação',
                  value: '••• dias',
                  icon: Icons.schedule,
                  isPremium: false,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  /// Ações do modal (botões defensivo e diagnóstico)
  Widget _buildActions(BuildContext context) {
    final provider = Provider.of<DiagnosticosPragaProvider>(context, listen: false);
    
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: _DefensivoButton(
              diagnostico: diagnostico,
              provider: provider,
            ),
          ),
          const SizedBox(width: 12),
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

    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: theme.colorScheme.onSurfaceVariant,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: isPremium ? FontWeight.w600 : FontWeight.w300,
                  color: isPremium
                      ? theme.colorScheme.onSurface
                      : theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
        ),
        if (!isPremium) ...[
          const SizedBox(width: 8),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.diamond,
                size: 12,
                color: Colors.amber.shade600,
              ),
              const SizedBox(width: 4),
              Text(
                'Premium',
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.amber.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

/// Botão para navegar ao defensivo
class _DefensivoButton extends StatelessWidget {
  final DiagnosticoModel diagnostico;
  final DiagnosticosPragaProvider provider;

  const _DefensivoButton({
    required this.diagnostico,
    required this.provider,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: () {
        final defensivoData = provider.getDefensivoData(diagnostico.nome);
        Navigator.of(context).pop();
        Navigator.push(
          context,
          MaterialPageRoute<void>(
            builder: (context) => DetalheDefensivoPage(
              defensivoName: diagnostico.nome,
              fabricante: defensivoData?['fabricante'] as String? ?? 'Fabricante Desconhecido',
            ),
          ),
        );
      },
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: const Text('Defensivo'),
    );
  }
}

/// Botão para navegar ao diagnóstico detalhado
class _DiagnosticoButton extends StatelessWidget {
  final DiagnosticoModel diagnostico;
  final String pragaName;

  const _DiagnosticoButton({
    required this.diagnostico,
    required this.pragaName,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return ElevatedButton(
      onPressed: () {
        Navigator.of(context).pop();
        Navigator.push(
          context,
          MaterialPageRoute<void>(
            builder: (context) => DetalheDiagnosticoPage(
              diagnosticoId: diagnostico.id,
              nomeDefensivo: diagnostico.nome,
              nomePraga: pragaName,
              cultura: diagnostico.cultura,
            ),
          ),
        );
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: const Text('Diagnóstico'),
    );
  }
}
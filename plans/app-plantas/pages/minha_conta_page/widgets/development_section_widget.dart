// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'menu_item_widget.dart';

class DevelopmentSectionWidget extends StatelessWidget {
  final VoidCallback onGerarDadosTeste;
  final VoidCallback onLimparRegistros;
  final VoidCallback onPaginaPromocional;
  final VoidCallback? onGerarLicenca;
  final VoidCallback? onRevogarLicenca;

  const DevelopmentSectionWidget({
    super.key,
    required this.onGerarDadosTeste,
    required this.onLimparRegistros,
    required this.onPaginaPromocional,
    this.onGerarLicenca,
    this.onRevogarLicenca,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        MenuItemWidget(
          icon: Icons.bug_report_outlined,
          title: 'Gerar dados de teste',
          onTap: onGerarDadosTeste,
        ),
        MenuItemWidget(
          icon: Icons.delete_sweep_outlined,
          title: 'Limpar todos os registros',
          onTap: onLimparRegistros,
        ),
        MenuItemWidget(
          icon: Icons.campaign_outlined,
          title: 'Página promocional',
          onTap: onPaginaPromocional,
        ),

        // Seção de licenças (sempre visível - projeto incubador)
        if (onGerarLicenca != null)
          MenuItemWidget(
            icon: Icons.verified_user_outlined,
            title: 'Gerar Licença Local',
            subtitle: 'Ativa premium por 30 dias',
            onTap: onGerarLicenca!,
          ),
        if (onRevogarLicenca != null)
          MenuItemWidget(
            icon: Icons.remove_circle_outline,
            title: 'Revogar Licença Local',
            subtitle: 'Remove licença de teste',
            onTap: onRevogarLicenca!,
          ),
      ],
    );
  }
}

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:get/get.dart';

// Project imports:
import '../../controller/detalhes_defensivos_controller.dart';
import '../../widgets/application_info_section.dart';

class AplicacaoTab extends StatefulWidget {
  final DetalhesDefensivosController controller;

  const AplicacaoTab({
    super.key,
    required this.controller,
  });

  @override
  State<AplicacaoTab> createState() => _AplicacaoTabState();
}

class _AplicacaoTabState extends State<AplicacaoTab>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;
  
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    // Delay para evitar conflitos de build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    
    if (!_isInitialized) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
    
    return GetBuilder<DetalhesDefensivosController>(
      builder: (controller) {
        if (controller.defensivo.value.informacoes.isEmpty) {
          return const Center(
            key: ValueKey('no_application_info'),
            child: Text('Não há informações de aplicação disponíveis.'),
          );
        }

        final aplicacoes = controller.defensivo.value.informacoes;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            key: const ValueKey('application_content'),
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
            ApplicationInfoSection(
              key: const ValueKey('tech_section'),
              title: 'Tecnologia',
              content: aplicacoes['tecnologia'] ?? '',
              icon: Icons.precision_manufacturing_outlined,
              controller: widget.controller,
            ),
            const SizedBox(height: 24),
            ApplicationInfoSection(
              key: const ValueKey('packaging_section'),
              title: 'Embalagens',
              content: aplicacoes['embalagens'] ?? '',
              icon: Icons.inventory_2_outlined,
              controller: widget.controller,
            ),
            const SizedBox(height: 24),
            ApplicationInfoSection(
              key: const ValueKey('integrated_management_section'),
              title: 'Manejo Integrado',
              content: aplicacoes['manejoIntegrado'] ?? '',
              icon: Icons.integration_instructions_outlined,
              controller: widget.controller,
            ),
            const SizedBox(height: 24),
            ApplicationInfoSection(
              key: const ValueKey('resistance_management_section'),
              title: 'Manejo de Resistência',
              content: aplicacoes['manejoResistencia'] ?? '',
              icon: Icons.shield_outlined,
              controller: widget.controller,
            ),
            const SizedBox(height: 24),
            ApplicationInfoSection(
              key: const ValueKey('human_precautions_section'),
              title: 'Precauções Humanas',
              content: aplicacoes['pHumanas'] ?? '',
              icon: Icons.person_outlined,
              controller: widget.controller,
            ),
            const SizedBox(height: 24),
            ApplicationInfoSection(
              key: const ValueKey('environmental_precautions_section'),
              title: 'Precauções Ambientais',
              content: aplicacoes['pAmbientais'] ?? '',
              icon: Icons.nature_outlined,
              controller: widget.controller,
            ),
            const SizedBox(height: 24),
            ApplicationInfoSection(
              key: const ValueKey('compatibility_section'),
              title: 'Compatibilidade',
              content: aplicacoes['compatibilidade'] ?? '',
              icon: Icons.compare_arrows_outlined,
              controller: widget.controller,
            ),
            ],
          ),
        );
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/widgets/modern_header_widget.dart';
import '../../../navigation/bottom_nav_wrapper.dart';
import '../widgets/custom_tab_bar_widget.dart';

/// Página de detalhes do defensivo refatorada com Clean Architecture
/// 
/// TEMPORARIAMENTE SIMPLIFICADA para resolver build blockers
/// TODO: Implementar funcionalidade completa após resolver erros críticos
class DetalheDefensivoCleanPage extends ConsumerStatefulWidget {
  final String defensivoName;
  final String fabricante;

  const DetalheDefensivoCleanPage({
    super.key,
    required this.defensivoName,
    required this.fabricante,
  });

  @override
  ConsumerState<DetalheDefensivoCleanPage> createState() => 
      _DetalheDefensivoCleanPageState();
}

class _DetalheDefensivoCleanPageState 
    extends ConsumerState<DetalheDefensivoCleanPage> 
    with TickerProviderStateMixin {
  
  late TabController _tabController;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavWrapper(
      selectedIndex: 0,
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1120),
              child: Column(
                children: [
                  _buildHeader(),
                  Expanded(
                    child: _buildBody(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ModernHeaderWidget(
      title: widget.defensivoName,
      subtitle: widget.fabricante,
      leftIcon: Icons.shield_outlined,
      rightIcon: Icons.favorite_border,
      isDark: isDark,
      showBackButton: true,
      showActions: true,
      onBackPressed: () => Navigator.of(context).pop(),
      onRightIconPressed: () {},
    );
  }

  Widget _buildBody() {
    return Column(
      children: [
        CustomTabBarWidget(tabController: _tabController),
        Expanded(
          child: Container(
            margin: const EdgeInsets.only(left: 8, right: 8, top: 4, bottom: 8),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildInformacoesTab(),
                _buildDiagnosticosTab(),
                _buildTecnologiaTab(),
                _buildComentariosTab(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInformacoesTab() {
    return const Center(
      child: Text('Informações - Em desenvolvimento'),
    );
  }

  Widget _buildDiagnosticosTab() {
    return const Center(
      child: Text('Diagnósticos - Em desenvolvimento'),
    );
  }

  Widget _buildTecnologiaTab() {
    return const Center(
      child: Text('Tecnologia - Em desenvolvimento'),
    );
  }

  Widget _buildComentariosTab() {
    return const Center(
      child: Text('Comentários - Em desenvolvimento'),
    );
  }
}
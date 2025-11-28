import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/presentation/providers/recent_access_provider.dart';
import '../../../../core/widgets/internal_page_layout.dart';
import '../providers/defensivo_cadastro_provider.dart';
import '../providers/defensivos_providers.dart';
import '../widgets/defensivo_cadastro_tab1_informacoes.dart';
import '../widgets/defensivo_cadastro_tab2_diagnostico.dart';
import '../widgets/defensivo_cadastro_tab3_aplicacao.dart';

/// Defensivo Cadastro Page
/// 3-tab registration form for defensivos (agricultural defensives)
/// Replicates functionality from old Vue.js project
class DefensivoCadastroPage extends ConsumerStatefulWidget {
  final String? defensivoId; // null for new, ID for edit

  const DefensivoCadastroPage({
    super.key,
    this.defensivoId,
  });

  @override
  ConsumerState<DefensivoCadastroPage> createState() =>
      _DefensivoCadastroPageState();
}

class _DefensivoCadastroPageState extends ConsumerState<DefensivoCadastroPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _accessRegistered = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    // Load existing data if editing
    if (widget.defensivoId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref
            .read(defensivoCadastroProvider.notifier)
            .loadDefensivo(widget.defensivoId!);
        // Register access after loading
        _registerAccessFromList();
      });
    }

    // Listen to tab changes
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        ref
            .read(defensivoCadastroProvider.notifier)
            .setCurrentTab(_tabController.index);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  /// Register access by finding the defensivo from the list
  void _registerAccessFromList() {
    if (_accessRegistered || widget.defensivoId == null) return;

    final defensivosAsync = ref.read(defensivosProvider);
    defensivosAsync.whenData((defensivos) {
      final defensivo = defensivos
          .where((d) => d.id == widget.defensivoId)
          .firstOrNull;
      if (defensivo != null) {
        _accessRegistered = true;
        ref.read(recentAccessProvider.notifier).addDefensivoAccess(defensivo);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(defensivoCadastroProvider);
    final isEdit = widget.defensivoId != null;

    // Try to register access if not done yet
    if (isEdit && !_accessRegistered) {
      _registerAccessFromList();
    }

    return InternalPageLayout(
      title: isEdit ? 'Editar Defensivo' : 'Novo Defensivo',
      actions: [
        // Save button for current tab
        Padding(
          padding: const EdgeInsets.only(right: 16.0),
          child: ElevatedButton.icon(
            onPressed: state.isLoading ? null : () => _saveCurrentTab(),
            icon: state.isLoading
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.save),
            label: const Text('Salvar'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
          ),
        ),
      ],
      body: Column(
        children: [
          // Error message banner
          if (state.errorMessage != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16.0),
              color: Colors.red.shade100,
              child: Row(
                children: [
                  const Icon(Icons.error_outline, color: Colors.red),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      state.errorMessage!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      // Clear error message
                      // TODO: Add method to clear error in provider
                    },
                  ),
                ],
              ),
            ),

          // Success message banner
          if (state.isSaved && state.errorMessage == null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16.0),
              color: Colors.green.shade100,
              child: const Row(
                children: [
                  Icon(Icons.check_circle_outline, color: Colors.green),
                  SizedBox(width: 8),
                  Text(
                    'Dados salvos com sucesso!',
                    style: TextStyle(color: Colors.green),
                  ),
                ],
              ),
            ),

          // Tab bar
          Container(
            color: Colors.grey.shade200,
            child: TabBar(
              controller: _tabController,
              labelColor: Colors.green,
              unselectedLabelColor: Colors.grey,
              indicatorColor: Colors.green,
              tabs: const [
                Tab(
                  icon: Icon(Icons.info_outline),
                  text: 'Informações',
                ),
                Tab(
                  icon: Icon(Icons.assessment),
                  text: 'Diagnóstico',
                ),
                Tab(
                  icon: Icon(Icons.description),
                  text: 'Aplicação',
                ),
              ],
            ),
          ),

          // Tab content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: const [
                DefensivoCadastroTab1Informacoes(),
                DefensivoCadastroTab2Diagnostico(),
                DefensivoCadastroTab3Aplicacao(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Save current tab data
  Future<void> _saveCurrentTab() async {
    final notifier = ref.read(defensivoCadastroProvider.notifier);
    final currentTab = _tabController.index;

    bool success = false;

    switch (currentTab) {
      case 0:
        success = await notifier.saveTab1();
        break;
      case 1:
        success = await notifier.saveTab2();
        break;
      case 2:
        success = await notifier.saveTab3();
        break;
    }

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Dados salvos com sucesso!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }
}

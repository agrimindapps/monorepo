import 'package:core/core.dart' hide Column;
import 'package:flutter/material.dart';

import '../../../../core/services/receituagro_navigation_service.dart';
import '../../../../core/utils/receita_agro_data_inspector_initializer.dart';
import '../../../../core/widgets/modern_header_widget.dart';
import '../../../../core/widgets/standard_tab_bar_widget.dart';
import 'data_inspector/index.dart';

/// Data Inspector Page - Refatorada com visual moderno
///
/// Responsabilidade única: Orquestração da inspeção visual de Hive e SharedPreferences
///
/// Refatoração:
/// - 964 linhas → ~140 linhas (-85%)
/// - 4 módulos especializados:
///   - data_inspector_helpers.dart (formatação e helpers)
///   - hive_box_loader_service.dart (loading seguro de boxes)
///   - hive_tab_widget.dart (tab de HiveBoxes)
///   - shared_prefs_tab_widget.dart (tab de SharedPreferences)
class DataInspectorPage extends StatefulWidget {
  const DataInspectorPage({super.key});

  @override
  State<DataInspectorPage> createState() => _DataInspectorPageState();
}

class _DataInspectorPageState extends State<DataInspectorPage>
    with TickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;
  String _searchQuery = '';
  String _selectedModule = 'Todos';

  final DatabaseInspectorService _inspector = DatabaseInspectorService.instance;
  List<String> _availableModules = ['Todos'];
  List<SharedPreferencesRecord> _sharedPrefsData = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _initializeInspector();
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _initializeInspector() {
    ReceitaAgroDataInspectorInitializer.initialize();

    final modules =
        _inspector.customBoxes
            .map((box) => box.module ?? 'Outros')
            .toSet()
            .toList();
    modules.sort();
    _availableModules = ['Todos', ...modules];
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      _sharedPrefsData = await _inspector.loadSharedPreferencesData();
      setState(() => _isLoading = false);
    } catch (e) {
      setState(() => _isLoading = false);
      _showSnackBar('Erro ao carregar dados: $e', isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1120),
              child: Column(
                children: [_buildHeader(isDark), Expanded(child: _buildBody())],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(bool isDark) {
    return ModernHeaderWidget(
      title: 'Data Inspector',
      subtitle: 'Inspeção de Hive e SharedPreferences',
      leftIcon: Icons.storage_outlined,
      rightIcon: Icons.refresh,
      isDark: isDark,
      showBackButton: true,
      showActions: true,
      onBackPressed:
          () => GetIt.instance<ReceitaAgroNavigationService>().goBack<void>(),
      onRightIconPressed: _loadData,
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      children: [
        StandardTabBarWidget(
          tabController: _tabController,
          tabs: const [
            StandardTabData(icon: Icons.folder_open, text: 'HiveBoxes'),
            StandardTabData(icon: Icons.settings, text: 'SharedPrefs'),
          ],
        ),
        Expanded(
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: TabBarView(
              controller: _tabController,
              children: [_buildHiveBoxesTab(), _buildSharedPrefsTab()],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHiveBoxesTab() {
    return HiveTabWidget(
      inspector: _inspector,
      availableModules: _availableModules,
      selectedModule: _selectedModule,
      searchQuery: _searchQuery,
      onModuleChanged: (value) => setState(() => _selectedModule = value),
      onSearchChanged: (value) => setState(() => _searchQuery = value),
      onShowSuccessMessage: (msg) => _showSnackBar(msg, isError: false),
      onShowErrorMessage: (msg) => _showSnackBar(msg, isError: true),
    );
  }

  Widget _buildSharedPrefsTab() {
    return SharedPrefsTabWidget(
      sharedPrefsData: _sharedPrefsData,
      searchQuery: _searchQuery,
      onSearchChanged: (value) => setState(() => _searchQuery = value),
      onRemoveSharedPref: (key) async {
        final success = await _inspector.removeSharedPreferencesKey(key);
        if (success) {
          await _loadData();
        }
        return success;
      },
      onShowSuccessSnackBar: () => _showSnackBar('Copiado!', isError: false),
      onShowErrorSnackBar: (msg) => _showSnackBar(msg, isError: true),
    );
  }

  void _showSnackBar(String message, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}

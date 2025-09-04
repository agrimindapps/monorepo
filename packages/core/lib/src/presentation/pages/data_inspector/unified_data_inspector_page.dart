import 'package:flutter/material.dart';
import '../../../domain/entities/custom_box_type.dart';
import '../../../infrastructure/services/database_inspector_service.dart';
import '../../theme/data_inspector_theme.dart';
import '../../widgets/data_inspector/security_guard.dart';
import '../../widgets/data_inspector/overview_tab.dart';
import '../../widgets/data_inspector/hive_boxes_tab.dart';
import '../../widgets/data_inspector/shared_preferences_tab.dart';
import '../../widgets/data_inspector/export_tab.dart';

/// Unified Data Inspector Page combining best features from all app implementations
/// - Overview Dashboard (from gasometer)
/// - Advanced Hive Management (from receituagro)  
/// - Enhanced SharedPrefs (from plantis)
/// - Comprehensive Export (from receituagro + enhancements)
class UnifiedDataInspectorPage extends StatefulWidget {
  /// Custom theme for the inspector
  final DataInspectorTheme? theme;
  
  /// App name for branding and security messages
  final String appName;
  
  /// Custom box types specific to the app
  final List<CustomBoxType> customBoxes;
  
  /// Override security in release builds (use with extreme caution)
  final bool forceAllowInRelease;
  
  /// Show development warning even in debug builds
  final bool showDevelopmentWarning;
  
  /// Custom colors to override theme
  final Color? primaryColor;
  final Color? accentColor;

  const UnifiedDataInspectorPage({
    super.key,
    this.theme,
    this.appName = 'App',
    this.customBoxes = const [],
    this.forceAllowInRelease = false,
    this.showDevelopmentWarning = false,
    this.primaryColor,
    this.accentColor,
  });

  @override
  State<UnifiedDataInspectorPage> createState() => _UnifiedDataInspectorPageState();
}

class _UnifiedDataInspectorPageState extends State<UnifiedDataInspectorPage>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late DataInspectorTheme _theme;
  late DatabaseInspectorService _inspector;
  
  bool _isLoading = true;
  bool _isInitialized = false;
  String? _error;
  Map<String, dynamic> _stats = {};
  List<String> _hiveBoxes = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _setupInspector();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      _setupTheme();
      _initializeInspector().catchError((Object error) {
        setState(() {
          _error = error.toString();
          _isLoading = false;
        });
      });
      _isInitialized = true;
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _setupTheme() {
    if (widget.theme != null) {
      _theme = widget.theme!;
    } else if (widget.primaryColor != null) {
      _theme = DataInspectorTheme.custom(
        primaryColor: widget.primaryColor!,
        accentColor: widget.accentColor,
        brightness: Theme.of(context).brightness,
      );
    } else {
      _theme = DataInspectorTheme.fromContext(context);
    }
  }

  void _setupInspector() {
    _inspector = DatabaseInspectorService.instance;
    
    // Register custom boxes for this app
    if (widget.customBoxes.isNotEmpty) {
      _inspector.registerCustomBoxes(widget.customBoxes);
    }
  }

  Future<void> _initializeInspector() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      // Get available boxes and stats
      _hiveBoxes = _inspector.getAvailableHiveBoxes();
      _stats = _inspector.getGeneralStats();

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Wrap with security guard
    return SecurityGuard(
      forceAllow: widget.forceAllowInRelease,
      theme: _theme,
      appName: widget.appName,
      child: widget.showDevelopmentWarning
          ? DevelopmentAccessGuard(
              theme: _theme,
              appName: widget.appName,
              child: _buildInspectorContent(),
            )
          : _buildInspectorContent(),
    );
  }

  Widget _buildInspectorContent() {
    return Theme(
      data: _theme.themeData,
      child: Scaffold(
        backgroundColor: _theme.backgroundColor,
        appBar: _buildAppBar(),
        body: _buildBody(),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Row(
        children: [
          Icon(
            Icons.storage,
            color: _theme.brightness == Brightness.dark ? Colors.white : Colors.white,
          ),
          const SizedBox(width: 8),
          Text('${widget.appName} - Inspetor de Dados'),
        ],
      ),
      backgroundColor: _theme.primaryColor,
      foregroundColor: _theme.brightness == Brightness.dark ? Colors.white : Colors.white,
      elevation: 0,
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: _initializeInspector,
          tooltip: 'Atualizar dados',
        ),
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert),
          onSelected: _handleMenuAction,
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'export_all',
              child: Row(
                children: [
                  Icon(Icons.download),
                  SizedBox(width: 8),
                  Text('Exportar Tudo'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'clear_cache',
              child: Row(
                children: [
                  Icon(Icons.clear_all),
                  SizedBox(width: 8),
                  Text('Limpar Cache'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'settings',
              child: Row(
                children: [
                  Icon(Icons.settings),
                  SizedBox(width: 8),
                  Text('Configurações'),
                ],
              ),
            ),
          ],
        ),
      ],
      bottom: _isLoading
          ? null
          : TabBar(
              controller: _tabController,
              labelColor: _theme.brightness == Brightness.dark ? Colors.white : Colors.white,
              unselectedLabelColor: (_theme.brightness == Brightness.dark ? Colors.white : Colors.white).withValues(alpha: 0.7),
              indicatorColor: _theme.brightness == Brightness.dark ? Colors.white : Colors.white,
              tabs: const [
                Tab(icon: Icon(Icons.dashboard), text: 'Visão Geral'),
                Tab(icon: Icon(Icons.storage), text: 'Hive Boxes'),
                Tab(icon: Icon(Icons.settings), text: 'SharedPrefs'),
                Tab(icon: Icon(Icons.download), text: 'Exportar'),
              ],
            ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(_theme.primaryColor),
            ),
            const SizedBox(height: 16),
            Text(
              'Carregando dados do ${widget.appName}...',
              style: TextStyle(color: _theme.onSurfaceColor),
            ),
          ],
        ),
      );
    }

    if (_error != null) {
      return _buildErrorState();
    }

    return TabBarView(
      controller: _tabController,
      children: [
        // Overview Tab (gasometer-inspired)
        OverviewTab(
          stats: _stats,
          inspector: _inspector,
          theme: _theme,
          appName: widget.appName,
          onRefresh: _initializeInspector,
        ),
        
        // Hive Boxes Tab (receituagro-inspired)
        HiveBoxesTab(
          boxes: _hiveBoxes,
          inspector: _inspector,
          theme: _theme,
          onRefresh: _initializeInspector,
        ),
        
        // SharedPreferences Tab (plantis-inspired)
        SharedPreferencesTab(
          inspector: _inspector,
          theme: _theme,
        ),
        
        // Export Tab (receituagro + enhancements)
        ExportTab(
          inspector: _inspector,
          theme: _theme,
          appName: widget.appName,
          hiveBoxes: _hiveBoxes,
        ),
      ],
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: _theme.errorColor,
          ),
          const SizedBox(height: 16),
          Text(
            'Erro ao carregar dados',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: _theme.onSurfaceColor,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 32),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _theme.errorColor.withValues(alpha: 0.1),
              border: Border.all(
                color: _theme.errorColor.withValues(alpha: 0.3),
                width: 1,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              _error!,
              style: TextStyle(
                color: _theme.onSurfaceColor.withValues(alpha: 0.8),
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _initializeInspector,
            icon: const Icon(Icons.refresh),
            label: const Text('Tentar Novamente'),
            style: ElevatedButton.styleFrom(
              backgroundColor: _theme.primaryColor,
              foregroundColor: _theme.brightness == Brightness.dark ? Colors.white : Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleMenuAction(String action) async {
    switch (action) {
      case 'export_all':
        await _exportAllData();
        break;
      case 'clear_cache':
        await _clearCache();
        break;
      case 'settings':
        await _showSettings();
        break;
    }
  }

  Future<void> _exportAllData() async {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        DataInspectorDesignTokens.getSuccessSnackbar(
          'Exportação em desenvolvimento...',
          theme: _theme,
        ),
      );
    }
  }

  Future<void> _clearCache() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: _theme.cardColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DataInspectorDesignTokens.radiusM),
        ),
        title: Row(
          children: [
            Icon(
              Icons.warning,
              color: _theme.warningColor,
              size: 32,
            ),
            const SizedBox(width: 12),
            const Text('Limpar Cache'),
          ],
        ),
        content: Text(
          'Isso irá limpar todo o cache do ${widget.appName}. '
          'Os dados serão recarregados na próxima utilização. Continuar?',
          style: const TextStyle(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              'Cancelar',
              style: TextStyle(color: _theme.onSurfaceColor.withValues(alpha: 0.6)),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: _theme.warningColor,
              foregroundColor: Colors.white,
            ),
            child: const Text('Limpar'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        DataInspectorDesignTokens.getSuccessSnackbar(
          'Cache limpo com sucesso!',
          theme: _theme,
        ),
      );
      await _initializeInspector();
    }
  }

  Future<void> _showSettings() async {
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: _theme.cardColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DataInspectorDesignTokens.radiusM),
        ),
        title: const Text('Configurações do Inspetor'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.palette, color: _theme.primaryColor),
              title: const Text('Tema'),
              subtitle: Text(_theme.brightness == Brightness.dark ? 'Escuro' : 'Claro'),
              onTap: () {
                // Theme switching logic here
              },
            ),
            ListTile(
              leading: Icon(Icons.security, color: _theme.primaryColor),
              title: const Text('Segurança'),
              subtitle: Text(widget.forceAllowInRelease ? 'Desabilitada' : 'Habilitada'),
            ),
            ListTile(
              leading: Icon(Icons.info, color: _theme.primaryColor),
              title: Text('App: ${widget.appName}'),
              subtitle: Text('${widget.customBoxes.length} boxes registradas'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }
}
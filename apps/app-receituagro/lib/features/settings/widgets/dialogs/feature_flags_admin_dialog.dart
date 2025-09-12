import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/providers/feature_flags_provider.dart';

/// Feature Flags Admin Panel Dialog (Debug/Development Mode Only)
/// 
/// Features:
/// - Complete feature flags overview
/// - Remote Config values inspection
/// - Feature discovery onboarding simulation
/// - A/B test variant switching (local override)
/// - Debug information and diagnostics
class FeatureFlagsAdminDialog extends StatefulWidget {
  final FeatureFlagsProvider provider;

  const FeatureFlagsAdminDialog({
    super.key,
    required this.provider,
  });

  @override
  State<FeatureFlagsAdminDialog> createState() => _FeatureFlagsAdminDialogState();
}

class _FeatureFlagsAdminDialogState extends State<FeatureFlagsAdminDialog>
    with TickerProviderStateMixin {
  late TabController _tabController;
  Map<String, dynamic> _debugInfo = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadDebugInfo();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _loadDebugInfo() {
    _debugInfo = widget.provider.getDebugInfo();
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        constraints: const BoxConstraints(
          maxWidth: 700,
          maxHeight: 600,
        ),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.admin_panel_settings,
                    color: theme.colorScheme.primary,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Feature Flags Admin Panel',
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Ambiente de desenvolvimento',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),
            
            // Tab Bar
            TabBar(
              controller: _tabController,
              labelColor: theme.colorScheme.primary,
              unselectedLabelColor: theme.colorScheme.onSurfaceVariant,
              indicatorColor: theme.colorScheme.primary,
              tabs: const [
                Tab(text: 'Flags', icon: Icon(Icons.flag, size: 16)),
                Tab(text: 'A/B Tests', icon: Icon(Icons.science, size: 16)),
                Tab(text: 'Remote Config', icon: Icon(Icons.cloud_sync, size: 16)),
                Tab(text: 'Debug', icon: Icon(Icons.bug_report, size: 16)),
              ],
            ),
            
            // Tab Content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildFeatureFlagsTab(),
                  _buildABTestingTab(),
                  _buildRemoteConfigTab(),
                  _buildDebugTab(),
                ],
              ),
            ),
            
            // Actions
            Container(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: _refreshAll,
                    child: const Text('Atualizar Tudo'),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Fechar'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Feature Flags Tab
  Widget _buildFeatureFlagsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Core Features
          _buildFeatureGroup(
            'Core Features',
            [
              _FeatureFlagDebugItem('Premium Features', widget.provider.isPremiumFeaturesEnabled),
              _FeatureFlagDebugItem('Advanced Diagnostics', widget.provider.isAdvancedDiagnosticsEnabled),
              _FeatureFlagDebugItem('Offline Mode', widget.provider.isOfflineModeEnabled),
              _FeatureFlagDebugItem('Push Notifications', widget.provider.isPushNotificationsEnabled),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Performance Features
          _buildFeatureGroup(
            'Performance Features',
            [
              _FeatureFlagDebugItem('Image Optimization', widget.provider.isImageOptimizationEnabled),
              _FeatureFlagDebugItem('Data Caching', widget.provider.isDataCachingEnabled),
              _FeatureFlagDebugItem('Preload Content', widget.provider.isPreloadContentEnabled),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Business Logic Features
          _buildFeatureGroup(
            'Business Logic Features',
            [
              _FeatureFlagDebugItem('Subscription Validation', widget.provider.isSubscriptionValidationEnabled),
              _FeatureFlagDebugItem('Device Management', widget.provider.isDeviceManagementEnabled),
              _FeatureFlagDebugItem('Content Synchronization', widget.provider.isContentSynchronizationEnabled),
            ],
          ),
        ],
      ),
    );
  }

  /// A/B Testing Tab
  Widget _buildABTestingTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Active A/B Tests',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          // UI/UX A/B Tests
          _buildABTestGroup(
            'UI/UX Tests',
            [
              _ABTestDebugItem('New UI Design', widget.provider.isNewUiDesignEnabled, 'Variant B'),
              _ABTestDebugItem('Improved Onboarding', widget.provider.isImprovedOnboardingEnabled, 'Test Group'),
              _ABTestDebugItem('Gamification', widget.provider.isGamificationEnabled, 'Experimental'),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Feature Discovery
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.lightbulb_outline, color: Colors.blue),
                    const SizedBox(width: 8),
                    Text(
                      'Feature Discovery Simulation',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Colors.blue.shade700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'Simule o processo de descoberta de novas funcionalidades para usuários.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: _simulateFeatureDiscovery,
                    icon: const Icon(Icons.play_arrow, size: 16),
                    label: const Text('Simular Discovery'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.blue,
                      side: BorderSide(color: Colors.blue.withValues(alpha: 0.5)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Remote Config Tab
  Widget _buildRemoteConfigTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Remote Config Values',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: _refreshRemoteConfig,
                icon: const Icon(Icons.refresh),
                tooltip: 'Refresh Remote Config',
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Remote Config Status
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: widget.provider.isInitialized
                  ? Colors.green.withValues(alpha: 0.1)
                  : Colors.orange.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: widget.provider.isInitialized
                    ? Colors.green.withValues(alpha: 0.3)
                    : Colors.orange.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  widget.provider.isInitialized ? Icons.check_circle : Icons.sync,
                  color: widget.provider.isInitialized ? Colors.green : Colors.orange,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Text(
                  widget.provider.isInitialized 
                      ? 'Remote Config Inicializado'
                      : 'Aguardando Inicialização',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Config Values (Mock data - in real implementation, this would come from RemoteConfig)
          ..._buildRemoteConfigValues().map((item) => _buildConfigValueItem(item)),
        ],
      ),
    );
  }

  /// Debug Tab
  Widget _buildDebugTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Debug Information',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: _copyDebugInfo,
                icon: const Icon(Icons.copy),
                tooltip: 'Copy Debug Info',
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Debug Info Display
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Provider Status:',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                ..._debugInfo.entries.map((entry) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 120,
                          child: Text(
                            '${entry.key}:',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            entry.value.toString(),
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              fontFamily: 'monospace',
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Build Feature Group
  Widget _buildFeatureGroup(String title, List<_FeatureFlagDebugItem> features) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        ...features.map((feature) => _buildFeatureFlagItem(feature)),
      ],
    );
  }

  /// Build Feature Flag Item
  Widget _buildFeatureFlagItem(_FeatureFlagDebugItem feature) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: feature.isEnabled 
            ? Colors.green.withValues(alpha: 0.1)
            : Colors.grey.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: feature.isEnabled 
              ? Colors.green.withValues(alpha: 0.3)
              : Colors.grey.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            feature.isEnabled ? Icons.check_circle : Icons.cancel,
            color: feature.isEnabled ? Colors.green : Colors.grey,
            size: 16,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              feature.name,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
          Text(
            feature.isEnabled ? 'ENABLED' : 'DISABLED',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: feature.isEnabled ? Colors.green : Colors.grey,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  /// Build A/B Test Group
  Widget _buildABTestGroup(String title, List<_ABTestDebugItem> tests) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        ...tests.map((test) => _buildABTestItem(test)),
      ],
    );
  }

  /// Build A/B Test Item
  Widget _buildABTestItem(_ABTestDebugItem test) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: test.isActive 
            ? Colors.blue.withValues(alpha: 0.1)
            : Colors.grey.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: test.isActive 
              ? Colors.blue.withValues(alpha: 0.3)
              : Colors.grey.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            test.isActive ? Icons.science : Icons.science_outlined,
            color: test.isActive ? Colors.blue : Colors.grey,
            size: 16,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              test.name,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
          if (test.isActive)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                test.variant,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: Colors.blue,
                  fontSize: 8,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// Build Config Value Item
  Widget _buildConfigValueItem(_RemoteConfigItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                item.key,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Text(
                item.source,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            item.value.toString(),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontFamily: 'monospace',
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }

  /// Get Remote Config Values (Mock)
  List<_RemoteConfigItem> _buildRemoteConfigValues() {
    return [
      _RemoteConfigItem('enable_premium_features', true, 'Remote'),
      _RemoteConfigItem('enable_advanced_diagnostics', false, 'Default'),
      _RemoteConfigItem('enable_offline_mode', true, 'Remote'),
      _RemoteConfigItem('enable_new_ui_design', false, 'Default'),
      _RemoteConfigItem('min_app_version', '1.0.0', 'Remote'),
      _RemoteConfigItem('feature_discovery_delay_ms', 2000, 'Remote'),
    ];
  }

  /// Refresh All
  Future<void> _refreshAll() async {
    try {
      await widget.provider.refresh();
      _loadDebugInfo();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Feature Flags atualizados com sucesso'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao atualizar: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Refresh Remote Config
  Future<void> _refreshRemoteConfig() async {
    await _refreshAll();
  }

  /// Copy Debug Info
  void _copyDebugInfo() {
    final debugText = _debugInfo.entries
        .map((e) => '${e.key}: ${e.value}')
        .join('\n');
    
    Clipboard.setData(ClipboardData(text: debugText));
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Debug info copiado para a área de transferência'),
      ),
    );
  }

  /// Simulate Feature Discovery
  void _simulateFeatureDiscovery() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Feature Discovery'),
        content: const Text(
          'Esta seria uma demonstração de como os usuários descobrem novos recursos '
          'baseado em feature flags e A/B testing.\n\n'
          'Em produção, isso incluiria tooltips, highlights, onboarding flows, etc.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}

/// Debug Data Models
class _FeatureFlagDebugItem {
  final String name;
  final bool isEnabled;

  const _FeatureFlagDebugItem(this.name, this.isEnabled);
}

class _ABTestDebugItem {
  final String name;
  final bool isActive;
  final String variant;

  const _ABTestDebugItem(this.name, this.isActive, this.variant);
}

class _RemoteConfigItem {
  final String key;
  final dynamic value;
  final String source;

  const _RemoteConfigItem(this.key, this.value, this.source);
}
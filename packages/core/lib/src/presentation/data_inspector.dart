// Data Inspector - Unified implementation for all apps in the monorepo
// Combines the best features from app-receituagro, app-plantis, and app-gasometer

// Main page
export 'pages/data_inspector/unified_data_inspector_page.dart';

// Theme system
export 'theme/data_inspector_theme.dart';

// Security components
export 'widgets/data_inspector/security_guard.dart';

// Tab widgets
export 'widgets/data_inspector/overview_tab.dart';
export 'widgets/data_inspector/hive_boxes_tab.dart';
export 'widgets/data_inspector/shared_preferences_tab.dart';
export 'widgets/data_inspector/export_tab.dart';

// Core service (re-export for convenience)
export '../infrastructure/services/database_inspector_service.dart';
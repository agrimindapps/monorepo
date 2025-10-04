// Central providers export file for app-gasometer Riverpod migration
// This file provides a clean, organized way to access all app providers

// Core providers
export 'app_state_providers.dart';
export 'dependency_providers.dart';

// Note: Legacy providers migrated to Riverpod notifiers
// - auth_provider.dart -> features/auth/presentation/notifiers/auth_notifier.dart
// - vehicles_provider.dart -> features/vehicles/presentation/providers/vehicles_notifier.dart
// - fuel_provider.dart -> features/fuel/presentation/providers/fuel_riverpod_notifier.dart
// - settings_provider.dart -> core/providers/settings_notifier.dart

// This file serves as the main entry point for all Riverpod providers
// in the gasometer app, following Clean Architecture patterns
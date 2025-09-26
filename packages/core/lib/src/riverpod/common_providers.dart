// ========== COMMON RIVERPOD PROVIDERS ==========
// Providers compartilhados entre apps que usam Riverpod
// Consolida padrões comuns de state management

import 'package:riverpod/riverpod.dart';

// ========== CONNECTIVITY PROVIDERS ==========
/// Provider para conectividade compartilhado
/// Usado por múltiplos apps para verificar conexão
final connectivityProvider = StateProvider<bool>((ref) => true);

// ========== LOADING STATE PROVIDERS ==========
/// Provider genérico para estados de loading
/// Pode ser usado por qualquer feature que precisa de loading state
final globalLoadingProvider = StateProvider<bool>((ref) => false);

/// Provider para múltiplos loading states (por key)
final loadingStatesProvider = StateProvider<Map<String, bool>>((ref) => {});

// ========== ERROR HANDLING PROVIDERS ==========
/// Provider para gerenciamento global de erros
final globalErrorProvider = StateProvider<String?>((ref) => null);

/// Provider para múltiplas mensagens de erro (por contexto)
final errorMessagesProvider = StateProvider<Map<String, String>>((ref) => {});

// ========== THEME PROVIDERS ==========
/// Provider para modo escuro/claro compartilhado
final isDarkModeProvider = StateProvider<bool>((ref) => false);

/// Provider para configurações de tema
final themeConfigProvider = StateProvider<Map<String, dynamic>>((ref) => {
  'primaryColor': '#2196F3',
  'accentColor': '#FF5722',
  'useMaterial3': true,
});

// ========== USER SESSION PROVIDERS ==========
/// Provider para dados básicos do usuário logado
final currentUserIdProvider = StateProvider<String?>((ref) => null);

/// Provider para status de autenticação
final isAuthenticatedProvider = StateProvider<bool>((ref) => false);

// ========== UTILITY PROVIDERS ==========
/// Provider para configurações globais da aplicação
final appConfigProvider = StateProvider<Map<String, dynamic>>((ref) => {});

/// Provider para feature flags compartilhados
final featureFlagsProvider = StateProvider<Map<String, bool>>((ref) => {});
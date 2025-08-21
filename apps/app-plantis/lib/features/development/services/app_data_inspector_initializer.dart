import 'package:core/core.dart';
import 'package:flutter/foundation.dart';

/// Inicializador do DatabaseInspectorService específico para o app-plantis
class AppDataInspectorInitializer {
  static void initialize() {
    if (!kDebugMode) return; // Apenas em modo debug

    final inspector = DatabaseInspectorService.instance;

    // Registrar todas as boxes customizadas do app-plantis
    inspector.registerCustomBoxes([
      // Módulo de Plantas
      CustomBoxType(
        key: 'plants',
        displayName: 'Plantas',
        module: 'plants',
        description:
            'Dados completos das plantas cadastradas, incluindo informações básicas, cuidados e imagens',
      ),

      // Módulo de Espaços/Ambientes
      CustomBoxType(
        key: 'spaces',
        displayName: 'Espaços',
        module: 'spaces',
        description:
            'Ambientes onde as plantas estão localizadas (sala, cozinha, varanda, etc)',
      ),

      // Módulo de Tarefas
      CustomBoxType(
        key: 'tasks',
        displayName: 'Tarefas de Cuidados',
        module: 'tasks',
        description:
            'Lembretes e tarefas de cuidados das plantas (regar, adubar, podar)',
      ),

      // Módulo de Notificações
      CustomBoxType(
        key: 'notifications_settings',
        displayName: 'Configurações de Notificações',
        module: 'notifications',
        description: 'Preferências de notificações e lembretes do usuário',
      ),

      CustomBoxType(
        key: 'notifications_history',
        displayName: 'Histórico de Notificações',
        module: 'notifications',
        description: 'Registro de notificações enviadas ao usuário',
      ),

      // Módulo de Configurações
      CustomBoxType(
        key: 'user_preferences',
        displayName: 'Preferências do Usuário',
        module: 'settings',
        description:
            'Configurações gerais do aplicativo e preferências do usuário',
      ),

      CustomBoxType(
        key: 'app_settings',
        displayName: 'Configurações do App',
        module: 'settings',
        description: 'Configurações técnicas e de sistema do aplicativo',
      ),

      // Módulo Premium/Licenças
      CustomBoxType(
        key: 'premium_license',
        displayName: 'Licença Premium',
        module: 'premium',
        description: 'Informações de licença e assinatura premium',
      ),

      // Módulo de Cache
      CustomBoxType(
        key: 'image_cache',
        displayName: 'Cache de Imagens',
        module: 'cache',
        description: 'Cache de imagens das plantas para melhor performance',
      ),

      // Módulo de Sincronização
      CustomBoxType(
        key: 'sync_queue',
        displayName: 'Fila de Sincronização',
        module: 'sync',
        description: 'Dados pendentes de sincronização com o servidor',
      ),

      CustomBoxType(
        key: 'sync_metadata',
        displayName: 'Metadados de Sincronização',
        module: 'sync',
        description: 'Informações sobre última sincronização e status',
      ),

      // Módulo de Analytics
      CustomBoxType(
        key: 'analytics_events',
        displayName: 'Eventos de Analytics',
        module: 'analytics',
        description: 'Eventos de uso do app para análise',
      ),

      // Módulo de Backup
      CustomBoxType(
        key: 'backup_metadata',
        displayName: 'Metadados de Backup',
        module: 'backup',
        description: 'Informações sobre backups locais e na nuvem',
      ),
    ]);

    if (kDebugMode) {
      print('🔍 DatabaseInspectorService inicializado para app-plantis');
      print('📦 ${inspector.customBoxes.length} boxes registradas');
    }
  }

  /// Adiciona uma box customizada em runtime
  static void addCustomBox({
    required String key,
    required String displayName,
    required String module,
    String? description,
  }) {
    final inspector = DatabaseInspectorService.instance;
    inspector.addCustomBox(
      CustomBoxType(
        key: key,
        displayName: displayName,
        module: module,
        description: description,
      ),
    );
  }

  /// Remove uma box customizada
  static void removeCustomBox(String key) {
    final inspector = DatabaseInspectorService.instance;
    inspector.removeCustomBox(key);
  }
}

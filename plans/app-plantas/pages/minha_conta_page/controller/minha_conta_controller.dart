// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:get/get.dart';

// Project imports:
import '../../../core/extensions/theme_extensions.dart';
import '../../../services/application/local_license_service.dart';
import '../services/data_cleanup_service.dart';
import '../services/navigation_service.dart';
import '../services/test_data_service.dart';
import '../services/theme_service.dart';

/// Controller refatorado seguindo princípios SOLID
/// Mantém apenas orquestração de chamadas aos services e gerenciamento de estado de UI
/// Toda lógica de negócio foi extraída para services especializados
class MinhaContaController extends GetxController {
  // ========== DEPENDENCIES ==========

  final _testDataService = TestDataService.instance;
  final _cleanupService = DataCleanupService.instance;
  final _navigationService = NavigationService.instance;
  final _themeService = ThemeService.instance;

  // ========== REACTIVE STATE ==========

  /// Estado de loading para operações assíncronas
  final RxBool isLoading = false.obs;

  /// Estado de loading específico para geração de dados
  final RxBool isGeneratingData = false.obs;

  /// Estado de loading específico para limpeza
  final RxBool isCleaningData = false.obs;

  // ========== NAVIGATION METHODS ==========

  /// Navega para Termos de Uso
  Future<void> navigateToTermos() async {
    final result = await _navigationService.navigateToTermos();
    if (!result.success) {
      _showError('Erro', result.message);
    }
  }

  /// Navega para Política de Privacidade
  Future<void> navigateToPoliticas() async {
    final result = await _navigationService.navigateToPoliticas();
    if (!result.success) {
      _showError('Erro', result.message);
    }
  }

  /// Navega para página Premium
  void navigateToPromo() {
    final result = _navigationService.navigateToPromo();
    if (!result.success) {
      _showError('Erro', result.message);
    }
  }

  /// Navega para notificações (placeholder)
  void navigateToNotifications() {
    _navigationService.navigateToNotifications();
  }

  /// Navega para App Store (placeholder)
  void navigateToAppStore() {
    _navigationService.navigateToAppStore();
  }

  /// Mostra diálogo "Sobre o App"
  void navigateToAbout() {
    final result = _navigationService.showAboutDialog();
    if (!result.success) {
      _showError('Erro', result.message);
    }
  }

  /// Compartilha o app (placeholder)
  void shareApp() {
    _navigationService.shareApp();
  }

  /// Mostra formulário de feedback
  void sendFeedback() {
    final result = _navigationService.showFeedback();
    if (!result.success) {
      _showError('Erro', result.message);
    }
  }

  // ========== THEME METHODS ==========

  /// Alterna tema usando service unificado
  void toggleTheme() {
    final result = _themeService.toggleTheme();
    if (result.success) {
      debugPrint(
          '🎨 MinhaContaController: ${result.message} via ${result.method}');
    } else {
      _showError('Erro', result.message ?? 'Erro desconhecido');
    }
  }

  /// Obtém informações de debug do tema
  void logThemeDebug() {
    _themeService.logThemeInfo();
  }

  // ========== DEVELOPMENT METHODS ==========

  /// Gera dados de teste usando service especializado
  Future<void> gerarDadosDeTeste() async {
    try {
      isLoading.value = true;
      isGeneratingData.value = true;

      debugPrint(
          '🧪 MinhaContaController: Iniciando geração de dados de teste');

      final result = await _testDataService.gerarDadosCompletos();

      if (result.success) {
        _showSuccess('Sucesso', result.message);
        debugPrint(
            '✅ MinhaContaController: Dados de teste gerados com sucesso');
      } else {
        _showError('Erro', result.message);
        debugPrint(
            '❌ MinhaContaController: Erro na geração de dados: ${result.error}');
      }
    } catch (e) {
      debugPrint(
          '❌ MinhaContaController: Erro inesperado na geração de dados: $e');
      _showError('Erro', 'Erro inesperado ao gerar dados de teste: $e');
    } finally {
      isLoading.value = false;
      isGeneratingData.value = false;
    }
  }

  /// Limpa todos os registros usando service especializado
  Future<void> limparTodosRegistros() async {
    try {
      isLoading.value = true;
      isCleaningData.value = true;

      debugPrint('🧹 MinhaContaController: Iniciando limpeza de registros');

      final result = await _cleanupService.limparTodosRegistrosComConfirmacao();

      if (result.success && !result.cancelled) {
        _showSuccess('Sucesso', result.message);
        debugPrint(
            '✅ MinhaContaController: Limpeza concluída: ${result.totalItensRemovidos} itens removidos');
      } else if (result.cancelled) {
        debugPrint('🚫 MinhaContaController: Limpeza cancelada pelo usuário');
      } else {
        _showError('Erro', result.message);
        debugPrint('❌ MinhaContaController: Erro na limpeza: ${result.error}');
      }
    } catch (e) {
      debugPrint('❌ MinhaContaController: Erro inesperado na limpeza: $e');
      _showError('Erro', 'Erro inesperado ao limpar registros: $e');
    } finally {
      isLoading.value = false;
      isCleaningData.value = false;
    }
  }

  /// Limpa apenas dados de teste
  Future<void> limparDadosDeTeste() async {
    try {
      isLoading.value = true;
      isCleaningData.value = true;

      debugPrint('🧪 MinhaContaController: Limpando dados de teste');

      final result = await _cleanupService.limparApenasDataosDeTeste();

      if (result.success) {
        _showSuccess('Sucesso', result.message);
        debugPrint('✅ MinhaContaController: Dados de teste limpos');
      } else {
        _showError('Erro', result.message);
        debugPrint(
            '❌ MinhaContaController: Erro ao limpar dados de teste: ${result.error}');
      }
    } catch (e) {
      debugPrint(
          '❌ MinhaContaController: Erro inesperado na limpeza de teste: $e');
      _showError('Erro', 'Erro inesperado ao limpar dados de teste: $e');
    } finally {
      isLoading.value = false;
      isCleaningData.value = false;
    }
  }

  // ========== COMPUTED PROPERTIES ==========

  /// Verifica se tema atual é claro
  bool get isLightTheme => !_themeService.isDarkTheme;

  /// Verifica se tema atual é escuro
  bool get isDarkTheme => _themeService.isDarkTheme;

  /// Obtém nome do tema atual
  String get currentThemeName => _themeService.currentThemeName;

  /// Verifica se há operação em andamento
  bool get hasOperationInProgress =>
      isLoading.value || isGeneratingData.value || isCleaningData.value;

  // ========== UTILITY METHODS ==========

  /// Exibe mensagem de sucesso padronizada
  void _showSuccess(String title, String message) {
    final context = Get.context;
    if (context != null) {
      PlantasGetSnackbar.success(context, title, message);
    }
  }

  /// Exibe mensagem de erro padronizada
  void _showError(String title, String message) {
    final context = Get.context;
    if (context != null) {
      PlantasGetSnackbar.error(context, title, message);
    }
  }

  // ========== LICENSE MANAGEMENT ==========

  /// Gera uma licença local para testes
  Future<void> gerarLicencaLocal() async {
    try {
      isLoading.value = true;

      debugPrint('🔐 MinhaContaController: Gerando licença local');

      await LocalLicenseService.instance.generateTestLicense();

      _showSuccess(
        'Licença Gerada',
        'Licença local ativa por 30 dias. Status premium habilitado!',
      );

      debugPrint('✅ MinhaContaController: Licença local gerada com sucesso');
    } catch (e) {
      debugPrint('❌ MinhaContaController: Erro ao gerar licença: $e');
      _showError('Erro', 'Falha ao gerar licença local: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Revoga a licença local de testes
  Future<void> revogarLicencaLocal() async {
    try {
      isLoading.value = true;

      debugPrint('🔐 MinhaContaController: Revogando licença local');

      await LocalLicenseService.instance.removeTestLicense();

      _showSuccess(
        'Licença Revogada',
        'Licença local removida. Status premium desabilitado.',
      );

      debugPrint('✅ MinhaContaController: Licença local revogada com sucesso');
    } catch (e) {
      debugPrint('❌ MinhaContaController: Erro ao revogar licença: $e');
      _showError('Erro', 'Falha ao revogar licença local: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // ========== DEBUGGING AND DIAGNOSTICS ==========

  /// Obtém estatísticas dos dados atuais
  Future<void> logDataStatistics() async {
    try {
      final stats = await _cleanupService.obterEstatisticasAtuais();
      debugPrint('📊 MinhaContaController: Estatísticas dos dados:');
      debugPrint('   • Plantas: ${stats.totalPlantas}');
      debugPrint('   • Espaços: ${stats.totalEspacos}');
      debugPrint('   • Configurações: ${stats.totalConfigs}');
      debugPrint('   • Tarefas pendentes: ${stats.totalTarefasPendentes}');
      debugPrint('   • Tarefas concluídas: ${stats.totalTarefasConcluidas}');
      debugPrint('   • Total de itens: ${stats.totalItens}');
    } catch (e) {
      debugPrint('❌ MinhaContaController: Erro ao obter estatísticas: $e');
    }
  }

  /// Log de informações do controller
  void logControllerInfo() {
    debugPrint('📋 MinhaContaController: Estado atual do controller:');
    debugPrint('   • isLoading: ${isLoading.value}');
    debugPrint('   • isGeneratingData: ${isGeneratingData.value}');
    debugPrint('   • isCleaningData: ${isCleaningData.value}');
    debugPrint('   • hasOperationInProgress: $hasOperationInProgress');
    debugPrint('   • currentThemeName: $currentThemeName');
    debugPrint('   • Tema claro: $isLightTheme');
  }
}

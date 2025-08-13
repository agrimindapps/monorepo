/// Interface unificada para serviços de navegação do módulo app-receituagro
/// Centraliza todas as operações de navegação em uma única interface consistente
abstract class INavigationService {
  // =========================================================================
  // Navegação para Detalhes
  // =========================================================================
  
  /// Navega para detalhes de defensivo
  void navigateToDefensivoDetails(String defensivoId);
  
  /// Navega para detalhes de praga
  void navigateToPragaDetails(String pragaId);
  
  /// Navega para detalhes de diagnóstico
  void navigateToDiagnosticoDetails(String diagnosticoId);
  
  // =========================================================================
  // Navegação Genérica
  // =========================================================================
  
  /// Navega para uma rota específica com argumentos opcionais
  void navigateToRoute(String route, {dynamic arguments});
  
  /// Volta para a página anterior
  void goBack({dynamic result});
  
  /// Substitui a página atual por uma nova rota
  void replaceWithRoute(String route, {dynamic arguments});
  
  /// Navega para rota e remove todas as páginas anteriores do stack
  void navigateAndClearStack(String route, {dynamic arguments});
  
  // =========================================================================
  // Navegação com Dados
  // =========================================================================
  
  /// Navega para detalhes de praga usando dados do mapa
  void navigateToPragaFromData(Map<dynamic, dynamic> data);
  
  /// Navega para diagnóstico usando dados do mapa
  void navigateToDiagnosticoFromData(Map<dynamic, dynamic> data);
  
  // =========================================================================
  // Utilitários de Navegação
  // =========================================================================
  
  /// Verifica se um ID é válido para navegação
  bool isValidId(String? id);
  
  /// Verifica se é possível voltar na navegação
  bool canGoBack();
  
  /// Obtém a rota atual
  String get currentRoute;
  
  /// Obtém os argumentos da rota atual
  dynamic get currentArguments;
}
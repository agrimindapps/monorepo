/// Interface base para serviços de navegação
abstract class INavigationService {
  /// Navegar para uma rota específica
  void navigateTo(String routeName, {dynamic arguments});

  /// Voltar para a rota anterior
  void goBack({dynamic result});

  /// Substituir rota atual
  void replaceWith(String routeName, {dynamic arguments});

  /// Limpar pilha de navegação e ir para uma rota
  void offAllTo(String routeName, {dynamic arguments});

  /// Verificar se pode voltar na pilha de navegação
  bool canGoBack();
}
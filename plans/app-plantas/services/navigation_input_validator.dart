class NavigationInputValidator {
  static final Set<String> _validRoutes = {
    '/home',
    '/plantas',
    '/espacos',
    '/tarefas',
    '/perfil',
    '/ajustes',
  };

  /// Registrar uma nova rota válida
  void registerValidRoute(String routeName) {
    _validRoutes.add(routeName);
  }

  /// Validar se a rota é válida
  bool isValidRoute(String routeName) {
    return _validRoutes.contains(routeName);
  }

  /// Remover uma rota
  void removeRoute(String routeName) {
    _validRoutes.remove(routeName);
  }

  /// Listar todas as rotas registradas
  Set<String> get registeredRoutes => Set.unmodifiable(_validRoutes);
}
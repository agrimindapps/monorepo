enum NavigationType {
  push('push', 'Empilhar'),
  pushReplacement('push_replacement', 'Substituir'),
  pushAndRemoveUntil('push_and_remove_until', 'Empilhar e Remover'),
  pop('pop', 'Voltar'),
  popAndPush('pop_and_push', 'Voltar e Empilhar');

  const NavigationType(this.id, this.displayName);
  final String id;
  final String displayName;
}

class NavigationAction {
  final String id;
  final String title;
  final String route;
  final NavigationType type;
  final Map<String, dynamic>? arguments;
  final bool Function()? condition;
  final String? description;

  const NavigationAction({
    required this.id,
    required this.title,
    required this.route,
    this.type = NavigationType.push,
    this.arguments,
    this.condition,
    this.description,
  });

  NavigationAction copyWith({
    String? id,
    String? title,
    String? route,
    NavigationType? type,
    Map<String, dynamic>? arguments,
    bool Function()? condition,
    String? description,
  }) {
    return NavigationAction(
      id: id ?? this.id,
      title: title ?? this.title,
      route: route ?? this.route,
      type: type ?? this.type,
      arguments: arguments ?? this.arguments,
      condition: condition ?? this.condition,
      description: description ?? this.description,
    );
  }

  bool get isEnabled => condition?.call() ?? true;
  bool get hasArguments => arguments != null && arguments!.isNotEmpty;
  String get typeDisplayName => type.displayName;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'route': route,
      'type': type.id,
      'arguments': arguments,
      'description': description,
    };
  }

  static NavigationAction fromJson(Map<String, dynamic> json) {
    return NavigationAction(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      route: json['route'] ?? '',
      type: _getNavigationTypeById(json['type'] ?? 'push'),
      arguments: json['arguments'],
      description: json['description'],
    );
  }

  static NavigationType _getNavigationTypeById(String id) {
    return NavigationType.values.firstWhere(
      (type) => type.id == id,
      orElse: () => NavigationType.push,
    );
  }

  @override
  String toString() {
    return 'NavigationAction(id: $id, title: $title, route: $route, type: ${type.id})';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is NavigationAction &&
        other.id == id &&
        other.title == title &&
        other.route == route &&
        other.type == type;
  }

  @override
  int get hashCode {
    return Object.hash(id, title, route, type);
  }
}

class NavigationHistory {
  final String actionId;
  final String route;
  final DateTime timestamp;
  final Map<String, dynamic>? arguments;
  final NavigationType type;

  const NavigationHistory({
    required this.actionId,
    required this.route,
    required this.timestamp,
    this.arguments,
    required this.type,
  });

  NavigationHistory copyWith({
    String? actionId,
    String? route,
    DateTime? timestamp,
    Map<String, dynamic>? arguments,
    NavigationType? type,
  }) {
    return NavigationHistory(
      actionId: actionId ?? this.actionId,
      route: route ?? this.route,
      timestamp: timestamp ?? this.timestamp,
      arguments: arguments ?? this.arguments,
      type: type ?? this.type,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'actionId': actionId,
      'route': route,
      'timestamp': timestamp.toIso8601String(),
      'arguments': arguments,
      'type': type.id,
    };
  }

  static NavigationHistory fromJson(Map<String, dynamic> json) {
    return NavigationHistory(
      actionId: json['actionId'] ?? '',
      route: json['route'] ?? '',
      timestamp: DateTime.parse(json['timestamp'] ?? DateTime.now().toIso8601String()),
      arguments: json['arguments'],
      type: NavigationAction._getNavigationTypeById(json['type'] ?? 'push'),
    );
  }

  @override
  String toString() {
    return 'NavigationHistory(actionId: $actionId, route: $route, timestamp: $timestamp)';
  }
}

class NavigationRepository {
  static List<NavigationAction> getDefaultNavigationActions() {
    return [
      const NavigationAction(
        id: 'promo_page',
        title: 'Página Promocional',
        route: '/promo',
        description: 'Navegar para página promocional do PetiVeti',
      ),
      const NavigationAction(
        id: 'about_page',
        title: 'Sobre',
        route: '/sobre',
        description: 'Navegar para página sobre o aplicativo',
      ),
      const NavigationAction(
        id: 'subscription_page',
        title: 'Versão Premium',
        route: '/subscription',
        description: 'Navegar para página de assinatura premium',
      ),
      const NavigationAction(
        id: 'updates_page',
        title: 'Atualizações',
        route: '/atualizacoes',
        description: 'Navegar para página de atualizações do app',
      ),
    ];
  }

  static NavigationAction? getActionById(String id) {
    try {
      return getDefaultNavigationActions().firstWhere((action) => action.id == id);
    } catch (e) {
      return null;
    }
  }

  static List<NavigationAction> getActionsByType(NavigationType type) {
    return getDefaultNavigationActions()
        .where((action) => action.type == type)
        .toList();
  }

  static List<NavigationAction> getEnabledActions() {
    return getDefaultNavigationActions()
        .where((action) => action.isEnabled)
        .toList();
  }

  static List<NavigationType> getAvailableTypes() {
    return NavigationType.values;
  }

  static String getTypeDisplayName(NavigationType type) {
    return type.displayName;
  }

  static Map<NavigationType, List<NavigationAction>> groupByType() {
    final grouped = <NavigationType, List<NavigationAction>>{};
    
    for (final action in getDefaultNavigationActions()) {
      grouped.putIfAbsent(action.type, () => []).add(action);
    }
    
    return grouped;
  }

  static int getActionCount() {
    return getDefaultNavigationActions().length;
  }

  static int getEnabledActionCount() {
    return getEnabledActions().length;
  }

  static Map<String, dynamic> getNavigationStatistics() {
    final actions = getDefaultNavigationActions();
    final types = <String, int>{};
    
    for (final action in actions) {
      types[action.type.id] = (types[action.type.id] ?? 0) + 1;
    }
    
    return {
      'totalActions': actions.length,
      'enabledActions': actions.where((action) => action.isEnabled).length,
      'typeCounts': types,
      'availableTypes': NavigationType.values.map((type) => type.id).toList(),
    };
  }

  static NavigationAction createCustomAction({
    required String id,
    required String title,
    required String route,
    NavigationType type = NavigationType.push,
    Map<String, dynamic>? arguments,
    bool Function()? condition,
    String? description,
  }) {
    return NavigationAction(
      id: id,
      title: title,
      route: route,
      type: type,
      arguments: arguments,
      condition: condition,
      description: description,
    );
  }

  static bool isValidRoute(String route) {
    return route.isNotEmpty && route.startsWith('/');
  }

  static bool canNavigate(NavigationAction action) {
    return action.isEnabled && isValidRoute(action.route);
  }

  static List<String> getAllRoutes() {
    return getDefaultNavigationActions()
        .map((action) => action.route)
        .toSet()
        .toList();
  }

  static NavigationAction? findActionByRoute(String route) {
    try {
      return getDefaultNavigationActions()
          .firstWhere((action) => action.route == route);
    } catch (e) {
      return null;
    }
  }

  static Map<String, String> validateAction(NavigationAction action) {
    final errors = <String, String>{};
    
    if (action.id.isEmpty) {
      errors['id'] = 'ID é obrigatório';
    }
    
    if (action.title.isEmpty) {
      errors['title'] = 'Título é obrigatório';
    }
    
    if (!isValidRoute(action.route)) {
      errors['route'] = 'Rota deve começar com /';
    }
    
    return errors;
  }

  static bool hasValidationErrors(NavigationAction action) {
    return validateAction(action).isNotEmpty;
  }
}
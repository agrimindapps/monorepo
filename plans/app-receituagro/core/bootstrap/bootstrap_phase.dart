/// Enum representing different phases of application bootstrap
enum BootstrapPhase {
  /// Não iniciado
  notStarted('Não iniciado'),

  /// Configuração inicial
  configuration('Configuração'),

  /// Dependências core
  coreDependencies('Dependências Core'),

  /// Repositórios
  repositories('Repositórios'),

  /// Controllers
  controllers('Controllers'),

  /// Serviços de UI
  uiServices('Serviços de UI'),

  /// Rotas
  routes('Rotas'),

  /// Concluído
  completed('Concluído'),

  /// Rollback
  rollback('Rollback');

  /// Nome para exibição
  final String displayName;

  /// Construtor
  const BootstrapPhase(this.displayName);

  /// Retorna o nome da fase
  String get name => displayName;
}
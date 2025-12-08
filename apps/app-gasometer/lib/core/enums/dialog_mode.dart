/// Modo de operação do dialog/form para operações CRUD
enum DialogMode {
  /// Criação de novo registro - campos vazios e editáveis
  create,

  /// Visualização de registro existente - campos preenchidos e readonly
  view,

  /// Edição de registro existente - campos preenchidos e editáveis
  edit,
}

/// Extension com helpers para DialogMode
extension DialogModeX on DialogMode {
  /// Retorna true se está no modo de criação
  bool get isCreate => this == DialogMode.create;

  /// Retorna true se está no modo de visualização
  bool get isView => this == DialogMode.view;

  /// Retorna true se está no modo de edição
  bool get isEdit => this == DialogMode.edit;

  /// Retorna true se os campos devem ser editáveis (create ou edit)
  bool get isEditable => this != DialogMode.view;

  /// Retorna true se é um registro existente (view ou edit)
  bool get hasRecord => this != DialogMode.create;

  /// Retorna o título base para o modo
  String get title => switch (this) {
        DialogMode.create => 'Adicionar',
        DialogMode.view => 'Detalhes',
        DialogMode.edit => 'Editar',
      };

  /// Retorna o título completo com o nome da entidade
  String titleFor(String entityName) => switch (this) {
        DialogMode.create => 'Adicionar $entityName',
        DialogMode.view => 'Detalhes',
        DialogMode.edit => 'Editar $entityName',
      };

  /// Retorna o ícone adequado para o modo
  String get iconName => switch (this) {
        DialogMode.create => 'add',
        DialogMode.view => 'visibility',
        DialogMode.edit => 'edit',
      };
}



/// Serviço para gerenciar mensagens de erro dos favoritos
///
/// **Responsabilidade:** Single Responsibility Principle (SOLID)
/// - Centraliza todas as mensagens de erro relacionadas a favoritos
/// - Facilita internacionalização futura
/// - Mantém consistência nas mensagens exibidas ao usuário
///
/// **Uso:**
/// ```dart
/// final errorService = di.sl<FavoritosErrorMessageService>();
/// final message = errorService.getAddErrorMessage('defensivo');
/// ```

class FavoritosErrorMessageService {
  /// Mensagem para erro ao alterar favorito (toggle)
  String getToggleErrorMessage(String tipo) {
    return 'Erro ao alterar favorito de $tipo';
  }

  /// Mensagem para erro ao adicionar favorito
  String getAddErrorMessage(String tipo) {
    return 'Erro ao adicionar $tipo aos favoritos';
  }

  /// Mensagem para erro ao remover favorito
  String getRemoveErrorMessage(String tipo) {
    return 'Erro ao remover $tipo dos favoritos';
  }

  /// Mensagem para erro ao limpar favoritos de um tipo
  String getClearErrorMessage(String tipo) {
    return 'Erro ao limpar favoritos de $tipo';
  }

  /// Mensagem para erro ao limpar todos os favoritos
  String getClearAllErrorMessage() {
    return 'Erro ao limpar todos os favoritos';
  }

  /// Mensagem para erro ao carregar favoritos
  String getLoadErrorMessage([String? tipo]) {
    if (tipo != null && tipo.isNotEmpty) {
      return 'Erro ao carregar $tipo favoritos';
    }
    return 'Erro ao carregar favoritos';
  }

  /// Mensagem para erro ao sincronizar favoritos
  String getSyncErrorMessage() {
    return 'Erro ao sincronizar favoritos';
  }

  /// Mensagem para erro ao pesquisar favoritos
  String getSearchErrorMessage() {
    return 'Erro ao pesquisar favoritos';
  }

  /// Mensagem para erro genérico com detalhes
  String getErrorWithDetails(String operation, String details) {
    return 'Erro ao $operation: $details';
  }

  /// Mensagem de erro para operação não permitida
  String getOperationNotAllowedMessage(String reason) {
    return 'Operação não permitida: $reason';
  }

  /// Mensagem de erro para tipo inválido
  String getInvalidTypeMessage(String tipo) {
    return 'Tipo de favorito inválido: $tipo';
  }

  /// Mensagem de erro para favorito não encontrado
  String getNotFoundMessage(String tipo, String id) {
    return '$tipo com ID $id não encontrado nos favoritos';
  }

  /// Mensagem de erro para limite de favoritos atingido
  String getLimitReachedMessage(String tipo, int limit) {
    return 'Limite de $limit $tipo favoritos atingido';
  }

  /// Mensagem de erro para favorito duplicado
  String getDuplicateMessage(String tipo, String id) {
    return '$tipo com ID $id já está nos favoritos';
  }
}

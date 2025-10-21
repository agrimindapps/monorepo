/// Interface para manipulação de mensagens da UI
///
/// Define o contrato para exibição de mensagens, permitindo
/// desacoplamento entre controller e widgets específicos
abstract class MessageHandler {
  void showMessage(String message, {bool isError = true});
  void showSuccess(String message);
  void showError(String message);
}

/// Serviço responsável por gerenciar mensagens da UI
///
/// Este serviço centraliza a lógica de exibição de mensagens,
/// permitindo diferentes implementações (SnackBar, Dialog, etc.)
class VolumeSanguineoMessageService {
  final MessageHandler? _messageHandler;

  VolumeSanguineoMessageService([this._messageHandler]);

  /// Exibe mensagem de sucesso
  void showSuccess(String message) {
    _messageHandler?.showSuccess(message);
  }

  /// Exibe mensagem de erro
  void showError(String message) {
    _messageHandler?.showError(message);
  }

  /// Exibe mensagem genérica
  void showMessage(String message, {bool isError = true}) {
    _messageHandler?.showMessage(message, isError: isError);
  }

  /// Verifica se o serviço tem um handler configurado
  bool get hasHandler => _messageHandler != null;
}

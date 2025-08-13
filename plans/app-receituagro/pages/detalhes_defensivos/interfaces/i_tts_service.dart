/// Interface para serviços de Text-to-Speech
abstract class ITtsService {
  /// Fala o texto fornecido
  Future<void> speak(String text);
  
  /// Para a reprodução de áudio
  Future<void> stop();
  
  /// Verifica se está falando atualmente
  bool get isSpeaking;
  
  /// Dispõe dos recursos
  void dispose();
}
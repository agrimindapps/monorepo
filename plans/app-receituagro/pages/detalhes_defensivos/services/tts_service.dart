// Project imports:
import '../../../../core/services/tts_service.dart' as core_tts;
import '../interfaces/i_tts_service.dart';

/// Serviço para gerenciamento de Text-to-Speech
/// Wrapper around the core TTS service with additional functionality
class TtsService implements ITtsService {
  final core_tts.TtsService _coreTtsService;
  bool _isSpeaking = false;

  TtsService() : _coreTtsService = core_tts.TtsService();

  @override
  Future<void> speak(String text) async {
    if (text.trim().isEmpty) return;
    
    try {
      _isSpeaking = true;
      final formattedText = _formatTextForSpeech(text);
      await _coreTtsService.speak(formattedText);
    } catch (e) {
      _isSpeaking = false;
      rethrow;
    }
  }

  @override
  Future<void> stop() async {
    try {
      await _coreTtsService.stop();
    } finally {
      _isSpeaking = false;
    }
  }

  @override
  bool get isSpeaking => _isSpeaking;

  @override
  void dispose() {
    stop();
  }

  /// Formata o texto removendo tags HTML e caracteres especiais
  String _formatTextForSpeech(String text) {
    return text
        .replaceAll(RegExp(r'<br\s*\/?>', caseSensitive: false), '. ')
        .replaceAll(RegExp(r'<[^>]*>'), '') // Remove outras tags HTML
        .replaceAll(RegExp(r'\s+'), ' ') // Normaliza espaços
        .trim();
  }

  /// Para uso em testes ou quando precisar notificar mudança de estado
  void setSpeakingState(bool speaking) {
    _isSpeaking = speaking;
  }
}

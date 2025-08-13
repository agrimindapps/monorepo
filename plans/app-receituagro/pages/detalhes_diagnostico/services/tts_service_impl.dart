// Project imports:
import '../../../../core/services/tts_service.dart';
import '../interfaces/i_tts_service.dart';

/// Implementação do serviço TTS
class TtsServiceImpl implements ITtsService {
  final TtsService _ttsService;

  TtsServiceImpl(this._ttsService);

  @override
  Future<void> speak(String text) async {
    return _ttsService.speak(text);
  }

  @override
  Future<void> stop() async {
    return _ttsService.stop();
  }

  @override
  bool get isSpeaking => false; // Estado gerenciado pelo controller

  @override
  Future<void> dispose() async {
    await _ttsService.dispose();
  }
}

enum TTSSpeechState { idle, speaking, paused, stopped }

abstract class ITTSService {
  /// Initialize the TTS engine
  Future<void> initialize();

  /// Speak the given text
  Future<void> speak(String text);

  /// Stop current speech
  Future<void> stop();

  /// Pause current speech
  Future<void> pause();

  /// Resume paused speech
  Future<void> resume();

  /// Check if TTS is available on this device
  Future<bool> isAvailable();

  /// Set language (e.g., 'pt-BR')
  Future<void> setLanguage(String languageCode);

  /// Set speech rate (0.5 - 2.0, default: 0.8)
  Future<void> setRate(double rate);

  /// Set pitch (0.5 - 2.0, default: 1.0)
  Future<void> setPitch(double pitch);

  /// Set volume (0.0 - 1.0, default: 0.8)
  Future<void> setVolume(double volume);

  /// Stream of speech state changes
  Stream<TTSSpeechState> get speechStateStream;

  /// Current speech state
  TTSSpeechState get currentState;

  /// Dispose resources
  void dispose();
}

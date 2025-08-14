/// Abstract interface for Text-to-Speech functionality
/// Following Interface Segregation Principle (SOLID)
abstract class ITtsService {
  /// Check if TTS is available on the current platform
  Future<bool> isAvailable();
  
  /// Speak the given text
  Future<void> speak(String text);
  
  /// Stop current speech
  Future<void> stop();
  
  /// Pause current speech
  Future<void> pause();
  
  /// Resume paused speech
  Future<void> resume();
  
  /// Check if currently speaking
  bool get isSpeaking;
  
  /// Check if speech is paused
  bool get isPaused;
  
  /// Set speech rate (0.0 to 1.0)
  Future<void> setSpeechRate(double rate);
  
  /// Set speech volume (0.0 to 1.0)
  Future<void> setVolume(double volume);
  
  /// Set speech pitch (0.5 to 2.0)
  Future<void> setPitch(double pitch);
  
  /// Get available languages
  Future<List<String>> getLanguages();
  
  /// Set speech language
  Future<void> setLanguage(String language);
}
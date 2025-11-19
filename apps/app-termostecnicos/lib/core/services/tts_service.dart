
import 'package:flutter/foundation.dart' show kIsWeb, defaultTargetPlatform, TargetPlatform;
import 'package:flutter_tts/flutter_tts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TtsService {
  static final TtsService _instance = TtsService._internal();
  final FlutterTts _flutterTts = FlutterTts();

  factory TtsService() {
    return _instance;
  }

  TtsService._internal() {
    _initialize();
  }

  void _initialize() async {
    final prefs = await SharedPreferences.getInstance();
    final language = prefs.getString('tts_language') ?? 'pt-BR';
    final speechRate = prefs.getDouble('tts_speech_rate') ?? 0.5;
    final volume = prefs.getDouble('tts_volume') ?? 1.0;
    final pitch = prefs.getDouble('tts_pitch') ?? 1.0;

    await _flutterTts.setLanguage(language);
    await _flutterTts.setSpeechRate(speechRate);
    await _flutterTts.setVolume(volume);
    await _flutterTts.setPitch(pitch);

    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.iOS) {
      await _flutterTts.setSharedInstance(true);

      await _flutterTts.setIosAudioCategory(
          IosTextToSpeechAudioCategory.ambient,
          [
            IosTextToSpeechAudioCategoryOptions.allowBluetooth,
            IosTextToSpeechAudioCategoryOptions.allowBluetoothA2DP,
            IosTextToSpeechAudioCategoryOptions.mixWithOthers
          ],
          IosTextToSpeechAudioMode.voicePrompt);

      await _flutterTts.setSharedInstance(true);
      await _flutterTts.awaitSynthCompletion(true);
    }

    // if (Platform.isAndroid) {
    //   await _getDefaultVoice();
    //   await _getDefaultEngine();
    // }
  }

  Future<void> speak(String text) async {
    await _flutterTts.speak(text);
  }

  Future<void> stop() async {
    await _flutterTts.stop();
  }

  Future<void> pause() async {
    await _flutterTts.pause();
  }

  Future<void> setLanguage(String language) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('tts_language', language);
    await _flutterTts.setLanguage(language);
  }

  Future<void> setSpeechRate(double rate) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('tts_speech_rate', rate);
    await _flutterTts.setSpeechRate(rate);
  }

  Future<void> setVolume(double volume) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('tts_volume', volume);
    await _flutterTts.setVolume(volume);
  }

  Future<void> setPitch(double pitch) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('tts_pitch', pitch);
    await _flutterTts.setPitch(pitch);
  }

  Future<void> saveSettings(
      String language, double speechRate, double volume, double pitch) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('tts_language', language);
    await prefs.setDouble('tts_speech_rate', speechRate);
    await prefs.setDouble('tts_volume', volume);
    await prefs.setDouble('tts_pitch', pitch);
    await _flutterTts.setLanguage(language);
    await _flutterTts.setSpeechRate(speechRate);
    await _flutterTts.setVolume(volume);
    await _flutterTts.setPitch(pitch);
  }

  // Future<void> _getDefaultEngine() async {
  //   var engine = await _flutterTts.getDefaultEngine;
  //   if (engine != null) {
  //     print(engine);
  //   }
  // }

  // Future<void> _getDefaultVoice() async {
  //   var voice = await _flutterTts.getDefaultVoice;
  //   if (voice != null) {
  //     print(voice);
  //   }
  // }
}

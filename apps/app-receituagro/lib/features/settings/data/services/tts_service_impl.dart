import 'dart:async';

import 'package:flutter_tts/flutter_tts.dart';

import '../../domain/services/i_tts_service.dart';

class TTSServiceImpl implements ITTSService {
  final FlutterTts _flutterTts = FlutterTts();
  final StreamController<TTSSpeechState> _stateController =
      StreamController<TTSSpeechState>.broadcast();

  TTSSpeechState _currentState = TTSSpeechState.idle;

  TTSServiceImpl() {
    _setupCallbacks();
  }

  void _setupCallbacks() {
    _flutterTts.setStartHandler(() {
      _updateState(TTSSpeechState.speaking);
    });

    _flutterTts.setCompletionHandler(() {
      _updateState(TTSSpeechState.idle);
    });

    _flutterTts.setPauseHandler(() {
      _updateState(TTSSpeechState.paused);
    });

    _flutterTts.setContinueHandler(() {
      _updateState(TTSSpeechState.speaking);
    });

    _flutterTts.setCancelHandler(() {
      _updateState(TTSSpeechState.stopped);
    });

    _flutterTts.setErrorHandler((msg) {
      _updateState(TTSSpeechState.idle);
    });
  }

  void _updateState(TTSSpeechState newState) {
    _currentState = newState;
    if (!_stateController.isClosed) {
      _stateController.add(newState);
    }
  }

  @override
  Future<void> initialize() async {
    try {
      // Set default language
      await _flutterTts.setLanguage('pt-BR');

      // Set default iOS/Android settings
      await _flutterTts.setIosAudioCategory(
        IosTextToSpeechAudioCategory.playback,
        [
          IosTextToSpeechAudioCategoryOptions.allowBluetooth,
          IosTextToSpeechAudioCategoryOptions.allowBluetoothA2DP,
          IosTextToSpeechAudioCategoryOptions.mixWithOthers,
        ],
        IosTextToSpeechAudioMode.defaultMode,
      );

      // Check if pt-BR is available, fallback to pt if not
      final languages = await _flutterTts.getLanguages;
      if (languages is List && !languages.contains('pt-BR')) {
        if (languages.contains('pt')) {
          await _flutterTts.setLanguage('pt');
        }
      }
    } catch (e) {
      // Initialization failed, but don't throw - service will just not work
    }
  }

  @override
  Future<void> speak(String text) async {
    try {
      if (text.trim().isEmpty) return;

      // Stop any ongoing speech first
      if (_currentState == TTSSpeechState.speaking ||
          _currentState == TTSSpeechState.paused) {
        await stop();
        // Small delay to ensure clean state transition
        await Future<void>.delayed(const Duration(milliseconds: 100));
      }

      await _flutterTts.speak(text);
    } catch (e) {
      _updateState(TTSSpeechState.idle);
    }
  }

  @override
  Future<void> stop() async {
    try {
      await _flutterTts.stop();
      _updateState(TTSSpeechState.stopped);
    } catch (e) {
      _updateState(TTSSpeechState.idle);
    }
  }

  @override
  Future<void> pause() async {
    try {
      if (_currentState == TTSSpeechState.speaking) {
        await _flutterTts.pause();
        _updateState(TTSSpeechState.paused);
      }
    } catch (e) {
      // Pause not supported on all platforms
    }
  }

  @override
  Future<void> resume() async {
    try {
      if (_currentState == TTSSpeechState.paused) {
        // Flutter TTS doesn't have a direct resume, so we continue
        await _flutterTts.speak('');
        _updateState(TTSSpeechState.speaking);
      }
    } catch (e) {
      // Resume not supported on all platforms
    }
  }

  @override
  Future<bool> isAvailable() async {
    try {
      final languages = await _flutterTts.getLanguages;
      return languages != null && (languages as List).isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<void> setLanguage(String languageCode) async {
    try {
      await _flutterTts.setLanguage(languageCode);
    } catch (e) {
      // Language not available
    }
  }

  @override
  Future<void> setRate(double rate) async {
    try {
      // Clamp rate between 0.5 and 2.0
      final clampedRate = rate.clamp(0.5, 2.0);
      await _flutterTts.setSpeechRate(clampedRate);
    } catch (e) {
      // Rate setting failed
    }
  }

  @override
  Future<void> setPitch(double pitch) async {
    try {
      // Clamp pitch between 0.5 and 2.0
      final clampedPitch = pitch.clamp(0.5, 2.0);
      await _flutterTts.setPitch(clampedPitch);
    } catch (e) {
      // Pitch setting failed
    }
  }

  @override
  Future<void> setVolume(double volume) async {
    try {
      // Clamp volume between 0.0 and 1.0
      final clampedVolume = volume.clamp(0.0, 1.0);
      await _flutterTts.setVolume(clampedVolume);
    } catch (e) {
      // Volume setting failed
    }
  }

  @override
  Stream<TTSSpeechState> get speechStateStream => _stateController.stream;

  @override
  TTSSpeechState get currentState => _currentState;

  @override
  void dispose() {
    _flutterTts.stop();
    _stateController.close();
  }
}

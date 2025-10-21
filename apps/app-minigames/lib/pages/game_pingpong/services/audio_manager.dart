/// Gerenciador de áudio e efeitos sonoros para o jogo Ping Pong
/// 
/// Controla todos os efeitos sonoros do jogo, música de fundo,
/// configurações de volume e feedback auditivo.
library;

// Dart imports:
import 'dart:async';
import 'dart:math';

// Flutter imports:
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

// Project imports:
import 'package:app_minigames/constants/game_constants.dart';

/// Gerenciador central de áudio para o jogo
class AudioManager extends ChangeNotifier {
  /// Configurações de volume
  double _masterVolume = 0.8;
  double _soundEffectsVolume = 0.7;
  double _musicVolume = 0.3;
  bool _isMuted = false;
  
  /// Estados de áudio
  bool _isInitialized = false;
  bool _musicEnabled = true;
  bool _soundEffectsEnabled = true;
  
  /// Cache de sons
  final Map<SoundEffect, SoundData> _soundCache = {};
  
  /// Timer para música de fundo
  Timer? _musicTimer;
  
  /// Configurações de qualidade
  AudioQuality _audioQuality = AudioQuality.medium;
  
  /// Sistema de áudio 3D simulado
  bool _enable3DAudio = false;
  double _listenerX = 0.0;
  double _listenerY = 0.0;
  
  /// Mixer de áudio para múltiplos sons simultâneos
  final List<ActiveSound> _activeSounds = [];
  
  /// Getters para configurações
  double get masterVolume => _masterVolume;
  double get soundEffectsVolume => _soundEffectsVolume;
  double get musicVolume => _musicVolume;
  bool get isMuted => _isMuted;
  bool get isInitialized => _isInitialized;
  bool get musicEnabled => _musicEnabled;
  bool get soundEffectsEnabled => _soundEffectsEnabled;
  AudioQuality get audioQuality => _audioQuality;
  bool get enable3DAudio => _enable3DAudio;
  
  /// Inicializa o sistema de áudio
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      // Carrega todos os efeitos sonoros
      await _loadAllSounds();
      
      // Inicia música de fundo se habilitada
      if (_musicEnabled) {
        _startBackgroundMusic();
      }
      
      _isInitialized = true;
      debugPrint('AudioManager inicializado com sucesso');
      
    } catch (e) {
      debugPrint('Erro ao inicializar AudioManager: $e');
      // Modo silencioso em caso de falha
      _isMuted = true;
    }
    
    notifyListeners();
  }
  
  /// Carrega todos os sons no cache
  Future<void> _loadAllSounds() async {
    for (final effect in SoundEffect.values) {
      await _loadSound(effect);
    }
  }
  
  /// Carrega um som específico
  Future<void> _loadSound(SoundEffect effect) async {
    try {
      // Em uma implementação real, carregaria o arquivo de áudio
      // Por enquanto, simula carregamento com configurações
      _soundCache[effect] = SoundData(
        effect: effect,
        duration: _getSoundDuration(effect),
        volume: _getDefaultVolume(effect),
        pitch: 1.0,
        isLoaded: true,
      );
    } catch (e) {
      debugPrint('Erro ao carregar som ${effect.name}: $e');
      // Som de fallback silencioso
      _soundCache[effect] = SoundData(
        effect: effect,
        duration: const Duration(milliseconds: 100),
        volume: 0.0,
        pitch: 1.0,
        isLoaded: false,
      );
    }
  }
  
  /// Reproduz um efeito sonoro
  void playSound(SoundEffect effect, {
    double? volume,
    double? pitch,
    double? pan,
    bool loop = false,
    double? x,
    double? y,
  }) {
    if (!_isInitialized || _isMuted || !_soundEffectsEnabled) return;
    
    final soundData = _soundCache[effect];
    if (soundData == null || !soundData.isLoaded) return;
    
    // Calcula volume final
    final finalVolume = _calculateFinalVolume(
      volume ?? soundData.volume,
      effect,
      x,
      y,
    );
    
    if (finalVolume <= 0.0) return;
    
    // Calcula pitch final
    final finalPitch = _calculateFinalPitch(pitch ?? soundData.pitch, effect);
    
    // Calcula pan (esquerda/direita) para áudio 3D
    final finalPan = _calculate3DPan(x, y, pan);
    
    // Cria som ativo
    final activeSound = ActiveSound(
      effect: effect,
      volume: finalVolume,
      pitch: finalPitch,
      pan: finalPan,
      startTime: DateTime.now(),
      duration: soundData.duration,
      loop: loop,
      x: x,
      y: y,
    );
    
    // Adiciona à lista de sons ativos
    _activeSounds.add(activeSound);
    
    // Remove sons que já terminaram
    _cleanupActiveSounds();
    
    // Simula reprodução (em implementação real, usaria plugin de áudio)
    _simulateAudioPlayback(activeSound);
    
    // Feedback háptico baseado no som
    _provideHapticFeedback(effect, finalVolume);
  }
  
  /// Para um efeito sonoro específico
  void stopSound(SoundEffect effect) {
    _activeSounds.removeWhere((sound) => sound.effect == effect);
  }
  
  /// Para todos os sons
  void stopAllSounds() {
    _activeSounds.clear();
  }
  
  /// Reproduz som com efeito 3D baseado na posição da bola
  void playBallSound(SoundEffect effect, double ballX, double ballY, double ballSpeed) {
    if (!_soundEffectsEnabled) return;
    
    // Volume baseado na velocidade da bola
    final speedVolume = (ballSpeed / 10.0).clamp(0.3, 1.0);
    
    // Pitch baseado na velocidade
    final speedPitch = 0.8 + (ballSpeed / 20.0).clamp(0.0, 0.4);
    
    playSound(
      effect,
      volume: speedVolume,
      pitch: speedPitch,
      x: ballX,
      y: ballY,
    );
  }
  
  /// Reproduz som de colisão com raquete
  void playPaddleHitSound(double impact, double velocity, bool isPlayer) {
    final effect = isPlayer ? SoundEffect.paddleHit : SoundEffect.paddleHit;
    
    // Volume baseado na força do impacto
    final impactVolume = (impact.abs() / 5.0).clamp(0.4, 1.0);
    
    // Pitch baseado na velocidade da raquete
    final velocityPitch = 0.9 + (velocity.abs() / 10.0).clamp(0.0, 0.3);
    
    playSound(
      effect,
      volume: impactVolume,
      pitch: velocityPitch,
    );
  }
  
  /// Reproduz som de pontuação
  void playScoreSound(bool playerScored, int currentScore) {
    const effect = SoundEffect.score;
    
    // Pitch mais alto para pontuação do jogador
    final scorePitch = playerScored ? 1.2 : 0.8;
    
    // Volume aumenta conforme a pontuação
    final scoreVolume = 0.6 + (currentScore / 20.0).clamp(0.0, 0.4);
    
    playSound(
      effect,
      volume: scoreVolume,
      pitch: scorePitch,
    );
    
    // Som adicional para vitória
    if (currentScore >= 10) {
      Timer(const Duration(milliseconds: 300), () {
        playSound(
          playerScored ? SoundEffect.gameEnd : SoundEffect.gameEnd,
          volume: 0.8,
          pitch: playerScored ? 1.1 : 0.9,
        );
      });
    }
  }
  
  /// Inicia música de fundo
  void _startBackgroundMusic() {
    if (!_musicEnabled || _isMuted) return;
    
    // Simula música de fundo com timer
    _musicTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      if (_musicEnabled && !_isMuted) {
        // Em implementação real, controlaria música de fundo
        _playAmbientSound();
      }
    });
  }
  
  /// Para música de fundo
  void stopBackgroundMusic() {
    _musicTimer?.cancel();
    _musicTimer = null;
  }
  
  /// Reproduz som ambiente sutil
  void _playAmbientSound() {
    // Som ambiente muito sutil para não interferir no jogo
    playSound(
      SoundEffect.buttonClick,
      volume: _musicVolume * 0.1,
      pitch: 0.5,
    );
  }
  
  /// Calcula volume final considerando 3D e configurações
  double _calculateFinalVolume(
    double baseVolume, 
    SoundEffect effect, 
    double? x, 
    double? y
  ) {
    double finalVolume = baseVolume * _soundEffectsVolume * _masterVolume;
    
    // Aplica atenuação 3D se habilitada
    if (_enable3DAudio && x != null && y != null) {
      final distance = sqrt(pow(x - _listenerX, 2) + pow(y - _listenerY, 2));
      const maxDistance = 400.0; // Distância máxima audível
      final attenuation = 1.0 - (distance / maxDistance).clamp(0.0, 1.0);
      finalVolume *= attenuation;
    }
    
    return finalVolume.clamp(0.0, 1.0);
  }
  
  /// Calcula pitch final com variações aleatórias
  double _calculateFinalPitch(double basePitch, SoundEffect effect) {
    double finalPitch = basePitch;
    
    // Adiciona variação aleatória sutil para realismo
    final variation = (Random().nextDouble() - 0.5) * 0.1;
    finalPitch += variation;
    
    // Diferentes efeitos têm diferentes ranges de pitch
    switch (effect) {
      case SoundEffect.paddleHit:
        finalPitch = finalPitch.clamp(0.7, 1.5);
        break;
      case SoundEffect.wallHit:
        finalPitch = finalPitch.clamp(0.8, 1.3);
        break;
      case SoundEffect.score:
        finalPitch = finalPitch.clamp(0.5, 1.8);
        break;
      default:
        finalPitch = finalPitch.clamp(0.5, 2.0);
    }
    
    return finalPitch;
  }
  
  /// Calcula pan 3D (esquerda/direita)
  double _calculate3DPan(double? x, double? y, double? basePan) {
    if (!_enable3DAudio || x == null) {
      return basePan ?? 0.0;
    }
    
    // Calcula pan baseado na posição X
    const screenWidth = 800.0; // Largura típica da tela
    final normalizedX = (x / screenWidth * 2.0) - 1.0; // -1.0 a 1.0
    
    return normalizedX.clamp(-1.0, 1.0);
  }
  
  /// Simula reprodução de áudio (placeholder para implementação real)
  void _simulateAudioPlayback(ActiveSound sound) {
    // Em uma implementação real, usaria AudioPlayers ou similar
    debugPrint('🔊 Reproduzindo ${sound.effect.name} - Volume: ${sound.volume.toStringAsFixed(2)}, Pitch: ${sound.pitch.toStringAsFixed(2)}');
  }
  
  /// Fornece feedback háptico baseado no som
  void _provideHapticFeedback(SoundEffect effect, double volume) {
    if (volume < 0.3) return; // Só feedback para sons audíveis
    
    switch (effect) {
      case SoundEffect.paddleHit:
        HapticFeedback.mediumImpact();
        break;
      case SoundEffect.wallHit:
        HapticFeedback.lightImpact();
        break;
      case SoundEffect.score:
        HapticFeedback.heavyImpact();
        break;
      case SoundEffect.gameStart:
      case SoundEffect.gameEnd:
        HapticFeedback.heavyImpact();
        break;
      case SoundEffect.buttonClick:
        HapticFeedback.selectionClick();
        break;
    }
  }
  
  /// Remove sons que já terminaram
  void _cleanupActiveSounds() {
    final now = DateTime.now();
    _activeSounds.removeWhere((sound) {
      final elapsed = now.difference(sound.startTime);
      return !sound.loop && elapsed >= sound.duration;
    });
  }
  
  /// Obtém duração padrão do som
  Duration _getSoundDuration(SoundEffect effect) {
    switch (effect) {
      case SoundEffect.paddleHit:
        return const Duration(milliseconds: 150);
      case SoundEffect.wallHit:
        return const Duration(milliseconds: 100);
      case SoundEffect.score:
        return const Duration(milliseconds: 500);
      case SoundEffect.gameStart:
        return const Duration(milliseconds: 800);
      case SoundEffect.gameEnd:
        return const Duration(milliseconds: 1200);
      case SoundEffect.buttonClick:
        return const Duration(milliseconds: 50);
    }
  }
  
  /// Obtém volume padrão do som
  double _getDefaultVolume(SoundEffect effect) {
    switch (effect) {
      case SoundEffect.paddleHit:
        return 0.8;
      case SoundEffect.wallHit:
        return 0.6;
      case SoundEffect.score:
        return 1.0;
      case SoundEffect.gameStart:
      case SoundEffect.gameEnd:
        return 0.9;
      case SoundEffect.buttonClick:
        return 0.4;
    }
  }
  
  /// Configurações de volume
  void setMasterVolume(double volume) {
    _masterVolume = volume.clamp(0.0, 1.0);
    notifyListeners();
  }
  
  void setSoundEffectsVolume(double volume) {
    _soundEffectsVolume = volume.clamp(0.0, 1.0);
    notifyListeners();
  }
  
  void setMusicVolume(double volume) {
    _musicVolume = volume.clamp(0.0, 1.0);
    notifyListeners();
  }
  
  void setMuted(bool muted) {
    _isMuted = muted;
    if (muted) {
      stopAllSounds();
      stopBackgroundMusic();
    } else if (_musicEnabled) {
      _startBackgroundMusic();
    }
    notifyListeners();
  }
  
  void setMusicEnabled(bool enabled) {
    _musicEnabled = enabled;
    if (!enabled) {
      stopBackgroundMusic();
    } else if (!_isMuted) {
      _startBackgroundMusic();
    }
    notifyListeners();
  }
  
  void setSoundEffectsEnabled(bool enabled) {
    _soundEffectsEnabled = enabled;
    if (!enabled) {
      stopAllSounds();
    }
    notifyListeners();
  }
  
  /// Configurações avançadas
  void setAudioQuality(AudioQuality quality) {
    _audioQuality = quality;
    notifyListeners();
  }
  
  void set3DAudioEnabled(bool enabled) {
    _enable3DAudio = enabled;
    notifyListeners();
  }
  
  void updateListenerPosition(double x, double y) {
    _listenerX = x;
    _listenerY = y;
  }
  
  /// Obtém estatísticas de áudio
  Map<String, dynamic> getAudioStatistics() {
    return {
      'isInitialized': _isInitialized,
      'activeSounds': _activeSounds.length,
      'soundsInCache': _soundCache.length,
      'masterVolume': _masterVolume,
      'isMuted': _isMuted,
      'musicEnabled': _musicEnabled,
      'soundEffectsEnabled': _soundEffectsEnabled,
      'enable3DAudio': _enable3DAudio,
      'audioQuality': _audioQuality.toString(),
    };
  }
  
  /// Salva configurações
  Map<String, dynamic> saveSettings() {
    return {
      'masterVolume': _masterVolume,
      'soundEffectsVolume': _soundEffectsVolume,
      'musicVolume': _musicVolume,
      'isMuted': _isMuted,
      'musicEnabled': _musicEnabled,
      'soundEffectsEnabled': _soundEffectsEnabled,
      'audioQuality': _audioQuality.index,
      'enable3DAudio': _enable3DAudio,
    };
  }
  
  /// Carrega configurações
  void loadSettings(Map<String, dynamic> settings) {
    _masterVolume = settings['masterVolume']?.toDouble() ?? 0.8;
    _soundEffectsVolume = settings['soundEffectsVolume']?.toDouble() ?? 0.7;
    _musicVolume = settings['musicVolume']?.toDouble() ?? 0.3;
    _isMuted = settings['isMuted'] ?? false;
    _musicEnabled = settings['musicEnabled'] ?? true;
    _soundEffectsEnabled = settings['soundEffectsEnabled'] ?? true;
    _enable3DAudio = settings['enable3DAudio'] ?? false;
    
    final qualityIndex = settings['audioQuality'] ?? AudioQuality.medium.index;
    _audioQuality = AudioQuality.values[qualityIndex.clamp(0, AudioQuality.values.length - 1)];
    
    notifyListeners();
  }
  
  @override
  void dispose() {
    stopAllSounds();
    stopBackgroundMusic();
    _soundCache.clear();
    _activeSounds.clear();
    super.dispose();
  }
}

/// Dados de um som carregado
class SoundData {
  final SoundEffect effect;
  final Duration duration;
  final double volume;
  final double pitch;
  final bool isLoaded;
  
  SoundData({
    required this.effect,
    required this.duration,
    required this.volume,
    required this.pitch,
    required this.isLoaded,
  });
}

/// Som ativo sendo reproduzido
class ActiveSound {
  final SoundEffect effect;
  final double volume;
  final double pitch;
  final double pan;
  final DateTime startTime;
  final Duration duration;
  final bool loop;
  final double? x;
  final double? y;
  
  ActiveSound({
    required this.effect,
    required this.volume,
    required this.pitch,
    required this.pan,
    required this.startTime,
    required this.duration,
    required this.loop,
    this.x,
    this.y,
  });
}

/// Qualidade de áudio
enum AudioQuality {
  low,
  medium,
  high,
  ultra
}

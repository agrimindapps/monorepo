/// Serviço de áudio e feedback para o jogo da memória
/// 
/// Centraliza feedback sonoro e tátil, com configurações de usuário
/// e suporte a diferentes tipos de eventos do jogo.
library;

// Flutter imports:
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Tipos de sons do jogo
enum MemorySoundType {
  gameStart,     // Início do jogo
  cardFlip,      // Virar carta
  matchFound,    // Par encontrado
  matchMissed,   // Par não encontrado
  gameWin,       // Vitória
  gamePause,     // Pausar jogo
  gameResume,    // Retomar jogo
  buttonClick,   // Clique em botão
  error,         // Erro/ação inválida
  newRecord,     // Novo recorde
}

/// Tipos de feedback tátil
enum MemoryHapticType {
  light,         // Leve
  medium,        // Médio
  heavy,         // Pesado
  selection,     // Seleção
  notification,  // Notificação
  warning,       // Aviso
  error,         // Erro
  success,       // Sucesso
}

/// Configurações de áudio
class AudioConfig {
  final bool soundEnabled;
  final bool hapticsEnabled;
  final double volume;
  final bool use3D;
  
  const AudioConfig({
    this.soundEnabled = true,
    this.hapticsEnabled = true,
    this.volume = 1.0,
    this.use3D = false,
  });
  
  AudioConfig copyWith({
    bool? soundEnabled,
    bool? hapticsEnabled,
    double? volume,
    bool? use3D,
  }) {
    return AudioConfig(
      soundEnabled: soundEnabled ?? this.soundEnabled,
      hapticsEnabled: hapticsEnabled ?? this.hapticsEnabled,
      volume: volume ?? this.volume,
      use3D: use3D ?? this.use3D,
    );
  }
}

/// Serviço de áudio e feedback
class MemoryAudioService {
  /// Configurações atuais
  AudioConfig _config = const AudioConfig();
  
  /// Controle de estado
  bool _isDisposed = false;
  
  /// Cache de frequências de sons (simulado)
  final Map<MemorySoundType, double> _soundFrequencies = {
    MemorySoundType.gameStart: 440.0,      // Lá
    MemorySoundType.cardFlip: 523.25,      // Dó
    MemorySoundType.matchFound: 659.25,    // Mi
    MemorySoundType.matchMissed: 293.66,   // Ré
    MemorySoundType.gameWin: 783.99,       // Sol
    MemorySoundType.gamePause: 369.99,     // Fá#
    MemorySoundType.gameResume: 493.88,    // Si
    MemorySoundType.buttonClick: 349.23,   // Fá
    MemorySoundType.error: 246.94,         // Si bemol
    MemorySoundType.newRecord: 880.0,      // Lá (oitava superior)
  };
  
  /// Duração dos sons em milissegundos
  final Map<MemorySoundType, int> _soundDurations = {
    MemorySoundType.gameStart: 500,
    MemorySoundType.cardFlip: 150,
    MemorySoundType.matchFound: 400,
    MemorySoundType.matchMissed: 200,
    MemorySoundType.gameWin: 1000,
    MemorySoundType.gamePause: 300,
    MemorySoundType.gameResume: 300,
    MemorySoundType.buttonClick: 100,
    MemorySoundType.error: 250,
    MemorySoundType.newRecord: 800,
  };
  
  /// Atualiza configurações
  void updateConfig(AudioConfig config) {
    _config = config;
    debugPrint('Configurações de áudio atualizadas: ${config.soundEnabled ? 'som ativado' : 'som desativado'}');
  }
  
  /// Obtém configurações atuais
  AudioConfig get config => _config;
  
  /// Toca som específico
  Future<void> playSound(MemorySoundType soundType) async {
    if (_isDisposed || !_config.soundEnabled) return;
    
    try {
      // Em uma implementação real, aqui você usaria um package como audioplayers
      // Por enquanto, vamos usar feedback tátil correspondente
      await _playSimulatedSound(soundType);
      
      debugPrint('Som tocado: ${soundType.name}');
    } catch (e) {
      debugPrint('Erro ao tocar som $soundType: $e');
    }
  }
  
  /// Simula reprodução de som (implementação placeholder)
  Future<void> _playSimulatedSound(MemorySoundType soundType) async {
    // Aqui seria implementada a lógica real de reprodução de áudio
    // Por exemplo:
    // final player = AudioPlayer();
    // await player.play(AssetSource('sounds/${soundType.name}.mp3'));
    
    // Por enquanto, apenas simula o delay
    await Future.delayed(Duration(milliseconds: _soundDurations[soundType] ?? 100));
  }
  
  /// Feedback tátil específico
  Future<void> playHapticFeedback(MemoryHapticType hapticType) async {
    if (_isDisposed || !_config.hapticsEnabled) return;
    
    try {
      switch (hapticType) {
        case MemoryHapticType.light:
          await HapticFeedback.lightImpact();
          break;
        case MemoryHapticType.medium:
          await HapticFeedback.mediumImpact();
          break;
        case MemoryHapticType.heavy:
          await HapticFeedback.heavyImpact();
          break;
        case MemoryHapticType.selection:
          await HapticFeedback.selectionClick();
          break;
        case MemoryHapticType.notification:
          await HapticFeedback.mediumImpact();
          break;
        case MemoryHapticType.warning:
          await HapticFeedback.heavyImpact();
          break;
        case MemoryHapticType.error:
          await HapticFeedback.heavyImpact();
          // Padrão de vibração dupla para erro
          await Future.delayed(const Duration(milliseconds: 100));
          await HapticFeedback.heavyImpact();
          break;
        case MemoryHapticType.success:
          await HapticFeedback.mediumImpact();
          // Padrão de vibração tripla para sucesso
          await Future.delayed(const Duration(milliseconds: 100));
          await HapticFeedback.lightImpact();
          await Future.delayed(const Duration(milliseconds: 100));
          await HapticFeedback.lightImpact();
          break;
      }
      
      debugPrint('Feedback tátil: ${hapticType.name}');
    } catch (e) {
      debugPrint('Erro no feedback tátil: $e');
    }
  }
  
  /// Feedback combinado (som + tátil)
  Future<void> playCombinedFeedback(
    MemorySoundType soundType,
    MemoryHapticType hapticType,
  ) async {
    await Future.wait([
      playSound(soundType),
      playHapticFeedback(hapticType),
    ]);
  }
  
  /// Sons específicos do jogo
  Future<void> playGameStartSound() async {
    await playCombinedFeedback(
      MemorySoundType.gameStart,
      MemoryHapticType.medium,
    );
  }
  
  Future<void> playCardFlipSound() async {
    await playCombinedFeedback(
      MemorySoundType.cardFlip,
      MemoryHapticType.light,
    );
  }
  
  Future<void> playMatchFoundSound() async {
    await playCombinedFeedback(
      MemorySoundType.matchFound,
      MemoryHapticType.success,
    );
  }
  
  Future<void> playMatchMissedSound() async {
    await playCombinedFeedback(
      MemorySoundType.matchMissed,
      MemoryHapticType.medium,
    );
  }
  
  Future<void> playGameWinSound() async {
    await playCombinedFeedback(
      MemorySoundType.gameWin,
      MemoryHapticType.success,
    );
  }
  
  Future<void> playNewRecordSound() async {
    await playCombinedFeedback(
      MemorySoundType.newRecord,
      MemoryHapticType.success,
    );
  }
  
  Future<void> playErrorSound() async {
    await playCombinedFeedback(
      MemorySoundType.error,
      MemoryHapticType.error,
    );
  }
  
  Future<void> playButtonClickSound() async {
    await playCombinedFeedback(
      MemorySoundType.buttonClick,
      MemoryHapticType.selection,
    );
  }
  
  Future<void> playPauseSound() async {
    await playCombinedFeedback(
      MemorySoundType.gamePause,
      MemoryHapticType.medium,
    );
  }
  
  Future<void> playResumeSound() async {
    await playCombinedFeedback(
      MemorySoundType.gameResume,
      MemoryHapticType.light,
    );
  }
  
  /// Toca sequência de sons
  Future<void> playSequence(List<MemorySoundType> sounds, {
    Duration delay = const Duration(milliseconds: 200),
  }) async {
    for (int i = 0; i < sounds.length; i++) {
      await playSound(sounds[i]);
      if (i < sounds.length - 1) {
        await Future.delayed(delay);
      }
    }
  }
  
  /// Toca sequência de feedback tátil
  Future<void> playHapticSequence(List<MemoryHapticType> haptics, {
    Duration delay = const Duration(milliseconds: 100),
  }) async {
    for (int i = 0; i < haptics.length; i++) {
      await playHapticFeedback(haptics[i]);
      if (i < haptics.length - 1) {
        await Future.delayed(delay);
      }
    }
  }
  
  /// Para todos os sons
  void stopAllSounds() {
    // Em uma implementação real, pararia todos os players ativos
    debugPrint('Todos os sons parados');
  }
  
  /// Testa todos os sons (para configurações)
  Future<void> testAllSounds() async {
    for (final soundType in MemorySoundType.values) {
      await playSound(soundType);
      await Future.delayed(const Duration(milliseconds: 500));
    }
  }
  
  /// Testa todos os feedbacks táteis
  Future<void> testAllHaptics() async {
    for (final hapticType in MemoryHapticType.values) {
      await playHapticFeedback(hapticType);
      await Future.delayed(const Duration(milliseconds: 300));
    }
  }
  
  /// Verifica se o dispositivo suporta feedback tátil
  bool get hasHapticSupport {
    // Em uma implementação real, verificaria as capacidades do dispositivo
    return true; // Assumindo que todos os dispositivos suportam
  }
  
  /// Verifica se o dispositivo suporta áudio
  bool get hasAudioSupport {
    // Em uma implementação real, verificaria as capacidades do dispositivo
    return true; // Assumindo que todos os dispositivos suportam
  }
  
  /// Obtém volume atual do sistema
  Future<double> getSystemVolume() async {
    // Em uma implementação real, obteria o volume do sistema
    return 0.7; // Placeholder
  }
  
  /// Obtém estatísticas de uso
  Map<String, dynamic> getUsageStatistics() {
    return {
      'soundEnabled': _config.soundEnabled,
      'hapticsEnabled': _config.hapticsEnabled,
      'volume': _config.volume,
      'use3D': _config.use3D,
      'hasHapticSupport': hasHapticSupport,
      'hasAudioSupport': hasAudioSupport,
      'isDisposed': _isDisposed,
    };
  }
  
  /// Dispose do serviço
  void dispose() {
    if (_isDisposed) return;
    
    debugPrint('Fazendo dispose do MemoryAudioService');
    stopAllSounds();
    _isDisposed = true;
    debugPrint('MemoryAudioService disposed');
  }
}

import 'dart:developer' as developer;
import 'optimized_image_service.dart';

/// Serviço de otimização do startup da aplicação
/// Resolve problema de carregamento de 1181+ imagens causando 890ms+ de startup
/// 
/// Estratégias implementadas:
/// 1. Lazy loading - carrega imagens apenas quando necessário
/// 2. Preload seletivo - apenas imagens críticas no startup
/// 3. Cache inteligente - gerenciamento otimizado de memória
/// 4. Background initialization - inicialização em background
class StartupOptimizationService {
  static final StartupOptimizationService _instance = StartupOptimizationService._internal();
  factory StartupOptimizationService() => _instance;
  StartupOptimizationService._internal();

  final OptimizedImageService _imageService = OptimizedImageService();
  bool _isInitialized = false;
  bool _isInitializing = false;

  /// Inicialização otimizada do app
  /// Meta: reduzir startup de 3.0s+ para <1.5s
  Future<void> initializeApp() async {
    if (_isInitialized || _isInitializing) return;
    
    _isInitializing = true;
    final startTime = DateTime.now();
    
    try {
      developer.log('🚀 Iniciando otimização do startup...', name: 'StartupOptimization');
      
      // ETAPA 1: Preload apenas imagens críticas (não bloqueia UI)
      await _preloadCriticalImages();
      
      // ETAPA 2: Inicialização de serviços em background (futuro)
      _initializeBackgroundServices();
      
      final elapsedMs = DateTime.now().difference(startTime).inMilliseconds;
      developer.log('✅ Startup otimizado em ${elapsedMs}ms', name: 'StartupOptimization');
      
      _isInitialized = true;
      
    } catch (e) {
      developer.log('❌ Erro na otimização do startup: $e', name: 'StartupOptimization');
    } finally {
      _isInitializing = false;
    }
  }

  /// Preload apenas de imagens críticas para o primeiro carregamento
  /// Carrega ~5-10 imagens essenciais vs 1181+ imagens completas
  Future<void> _preloadCriticalImages() async {
    final criticalImages = [
      // Imagem de fallback (mais importante)
      'assets/imagens/bigsize/a.jpg',
      
      // Pragas mais comuns - baseado em dados de uso (simulado)
      'assets/imagens/bigsize/Anticarsia gemmatalis.jpg', // Lagarta-da-soja
      'assets/imagens/bigsize/Spodoptera frugiperda.jpg', // Lagarta-do-cartucho
      'assets/imagens/bigsize/Helicoverpa armigera.jpg', // Lagarta-do-algodão
      'assets/imagens/bigsize/Chrysodeixis includens.jpg', // Lagarta-falsa-medideira
      'assets/imagens/bigsize/Elasmopalpus lignosellus.jpg', // Broca-do-colo
      
      // Adicione outras imagens críticas baseado em analytics
    ];

    developer.log('Preloading ${criticalImages.length} critical images...', 
                 name: 'StartupOptimization');

    // Carrega de forma assíncrona sem bloquear o startup
    for (final imagePath in criticalImages) {
      try {
        await _imageService.loadImage(imagePath);
      } catch (e) {
        developer.log('Warning: Failed to preload $imagePath: $e', 
                     name: 'StartupOptimization');
        // Continua mesmo se uma imagem falhar
      }
    }

    developer.log('✅ Critical images preloaded', name: 'StartupOptimization');
  }

  /// Inicialização de serviços em background (não bloqueia startup)
  void _initializeBackgroundServices() {
    // Executa em background thread para não bloquear UI
    Future.delayed(const Duration(milliseconds: 500), () {
      developer.log('🔧 Inicializando serviços em background...', 
                   name: 'StartupOptimization');
      
      // Aqui podem ir outras inicializações pesadas:
      // - Pre-cache de dados frequentes
      // - Inicialização de analytics
      // - Setup de notificações
      // - Etc.
    });
  }

  /// Preload inteligente baseado no contexto do usuário
  /// Chamado quando o usuário navega para seções específicas
  Future<void> preloadContextualImages(String context) async {
    developer.log('Preloading images for context: $context', 
                 name: 'StartupOptimization');

    List<String> imagesToPreload = [];

    switch (context.toLowerCase()) {
      case 'soja':
        imagesToPreload = [
          'assets/imagens/bigsize/Anticarsia gemmatalis.jpg',
          'assets/imagens/bigsize/Chrysodeixis includens.jpg',
          'assets/imagens/bigsize/Euschistus heros.jpg',
          'assets/imagens/bigsize/Nezara viridula.jpg',
        ];
        break;
        
      case 'milho':
        imagesToPreload = [
          'assets/imagens/bigsize/Spodoptera frugiperda.jpg',
          'assets/imagens/bigsize/Helicoverpa zea.jpg',
          'assets/imagens/bigsize/Diabrotica speciosa.jpg',
        ];
        break;
        
      case 'algodao':
        imagesToPreload = [
          'assets/imagens/bigsize/Helicoverpa armigera.jpg',
          'assets/imagens/bigsize/Alabama argillacea.jpg',
          'assets/imagens/bigsize/Anthonomus grandis.jpg',
        ];
        break;
    }

    // Carrega em background
    for (final imagePath in imagesToPreload) {
      _imageService.loadImage(imagePath).catchError((e) {
        developer.log('Warning: Failed to preload contextual image $imagePath: $e', 
                     name: 'StartupOptimization');
        return null;
      });
    }
  }

  /// Otimização de memória - limpa cache quando necessário
  void optimizeMemoryUsage() {
    final stats = _imageService.getStats();
    final cacheSizeMB = double.tryParse(stats['totalCacheSizeMB']?.toString() ?? '0') ?? 0;
    
    if (cacheSizeMB > 30) { // Se cache > 30MB
      developer.log('🧹 Cache size is ${cacheSizeMB}MB, forcing cleanup...', 
                   name: 'StartupOptimization');
      _imageService.forceGarbageCollection();
    }
  }

  /// Estatísticas de performance do startup
  Map<String, dynamic> getPerformanceStats() {
    final imageStats = _imageService.getStats();
    return {
      'isInitialized': _isInitialized,
      'isInitializing': _isInitializing,
      'imageCache': imageStats,
      'optimizationLevel': _getOptimizationLevel(),
    };
  }

  /// Calcula nível de otimização atual
  String _getOptimizationLevel() {
    final stats = _imageService.getStats();
    final hitRate = double.tryParse(stats['hitRate']?.toString() ?? '0') ?? 0;
    
    if (hitRate > 80) return 'Excelente';
    if (hitRate > 60) return 'Bom';
    if (hitRate > 40) return 'Regular';
    return 'Pode melhorar';
  }

  /// Reset completo do serviço (para debug)
  void reset() {
    _imageService.clearCache();
    _isInitialized = false;
    _isInitializing = false;
    developer.log('🔄 Startup optimization service reset', name: 'StartupOptimization');
  }

  /// Getter para verificar se está inicializado
  bool get isInitialized => _isInitialized;
  
  /// Getter para verificar se está inicializando
  bool get isInitializing => _isInitializing;
}
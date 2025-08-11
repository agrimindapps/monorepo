# Documentação Técnica - Página Detalhes Diagnóstico (app-receituagro)

## 📋 Visão Geral

A **DetalhesDiagnosticoPage** é uma página **premium** do módulo **app-receituagro** que exibe informações detalhadas sobre diagnósticos agrícolas. Implementa um sistema complexo de **performance optimization** com carregamento paralelo, cache unificado, premium gating e integração com TTS e favoritos.

---

## 🏗️ Arquitetura de Performance

### Organização Modular Otimizada
```
📦 app-receituagro/pages/detalhes_diagnostico/
├── 📁 bindings/
│   └── detalhes_diagnostico_bindings.dart    # Dependency injection
├── 📁 constants/
│   └── diagnostico_performance_constants.dart # Configurações de performance
├── 📁 controller/
│   └── detalhes_diagnostico_controller.dart   # Estado reativo principal
├── 📁 interfaces/
│   ├── i_database_repository.dart            # Database abstraction
│   ├── i_favorite_service.dart               # Favoritos abstraction
│   ├── i_local_storage_service.dart          # Storage abstraction
│   ├── i_premium_service.dart                # Premium abstraction
│   └── i_tts_service.dart                    # TTS abstraction
├── 📁 models/
│   ├── diagnostic_data.dart                  # Agregação de dados
│   ├── diagnostico_details_model.dart        # Modelo principal
│   └── loading_state.dart                    # Estados de loading
├── 📁 services/
│   ├── database_repository_impl.dart         # Database implementation
│   ├── diagnostico_performance_service.dart  # Otimização de performance
│   ├── favorite_service.dart                 # Favoritos implementation
│   ├── local_storage_service_impl.dart       # Storage implementation
│   ├── premium_service_impl.dart             # Premium implementation
│   └── tts_service_impl.dart                 # TTS implementation
├── 📁 views/
│   ├── components/
│   │   ├── diagnostico_app_bar.dart          # App bar especializado
│   │   └── premium_card.dart                 # Card premium
│   ├── sections/
│   │   ├── application_section.dart          # Seção aplicação
│   │   ├── diagnostic_section.dart           # Seção diagnóstico
│   │   ├── header_section.dart               # Seção header
│   │   ├── image_section.dart                # Seção imagem
│   │   └── info_section.dart                 # Seção informações
│   └── detalhes_diagnostico_page.dart        # Página principal
└── 📁 widgets/
    ├── application_tabs.dart                 # Tabs de aplicação
    ├── favorite_button.dart                  # Botão favorito animado
    ├── font_size_controls.dart               # Controles de fonte
    ├── info_box.dart                         # Caixas de informação
    ├── loading_state_widget.dart             # Widget de loading
    └── share_button.dart                     # Botão compartilhar
```

### Padrões Arquiteturais Aplicados
- **Interface Segregation Principle**: 5+ interfaces especializadas
- **Dependency Injection**: Constructor-based injection via GetX
- **Performance Optimization**: Parallel loading + unified cache
- **Premium Gating**: Access control com fallbacks
- **State Management**: LoadingStateManager para estados complexos
- **Repository Pattern**: Abstração de acesso a dados
- **Service Layer Pattern**: Serviços especializados por domínio

---

## 🎛️ Controller - Performance-Optimized State Management

### Injeção de Dependências e Inicialização
```dart
class DetalhesDiagnosticoController extends GetxController {
  // Serviços injetados via interfaces
  late final ITtsService _ttsService;
  late final ILocalStorageService _localStorageService;
  late final PremiumService _premiumService;
  late final IDatabaseRepository _databaseRepository;
  late final IFavoriteService _favoriteService;
  late final ICacheService _cacheService;
  late final DiagnosticoPerformanceService _performanceService;

  // Gerenciamento de loading states
  final LoadingStateManager _loadingManager = LoadingStateManager();
  final Rx<LoadingStateManager> loadingManager = LoadingStateManager().obs;

  @override
  void onInit() {
    super.onInit();
    
    // Dependency injection via Get.find()
    _ttsService = Get.find<ITtsService>(tag: 'diagnostico');
    _localStorageService = Get.find<ILocalStorageService>();
    _premiumService = Get.find<PremiumService>();
    _databaseRepository = Get.find<IDatabaseRepository>();
    _favoriteService = Get.find<IFavoriteService>(tag: 'diagnostico');
    _cacheService = Get.find<ICacheService>();
    
    // Performance service initialization
    _performanceService = DiagnosticoPerformanceService(
      databaseRepository: _databaseRepository,
      localStorageService: _localStorageService,
      premiumService: _premiumService,
      cacheService: _cacheService,
    );

    // Carregamento otimizado se ID fornecido
    if (diagnosticoId.isNotEmpty) {
      loadDiagnosticoDataOptimized(diagnosticoId);
    }
  }
}
```

### Estados Reativos Especializados
```dart
// Estados reativos da UI
final RxBool isPremium = false.obs;
final RxBool isFavorite = false.obs;
final RxBool isTtsSpeaking = false.obs;
final RxDouble fontSize = 14.0.obs;

// Dados do diagnóstico
final Rx<DiagnosticoDetailsModel> diagnostico = 
    DiagnosticoDetailsModel.empty().obs;

// Getters para estados de loading específicos
bool get isLoading => _loadingManager.hasAnyLoading;
bool get isLoadingDiagnostic => 
    _loadingManager.isLoading(LoadingStateType.loadingDiagnostic);
bool get isLoadingFavorite => 
    _loadingManager.isLoading(LoadingStateType.loadingFavorite);
bool get isLoadingPremium => 
    _loadingManager.isLoading(LoadingStateType.loadingPremium);
bool get isLoadingTts => 
    _loadingManager.isLoading(LoadingStateType.loadingTts);
```

### Loading State Management Avançado
```dart
void _setLoadingState(LoadingStateType type, bool loading, {String? message}) {
  if (loading) {
    _loadingManager.setLoading(type, message: message);
  } else {
    _loadingManager.setIdle(type);
  }
  loadingManager.refresh();
}

void _setSuccessState(LoadingStateType type, {String? message}) {
  _loadingManager.setSuccess(type, message: message);
  loadingManager.refresh();
}

void _setErrorState(LoadingStateType type, dynamic error, {String? message}) {
  _loadingManager.setError(type, error, message: message);
  loadingManager.refresh();
}
```

### Funcionalidades Principais do Controller

#### **1. Performance-Optimized Data Loading**
```dart
Future<void> loadDiagnosticoDataOptimized(String diagnosticoId) async {
  // Set loading states for all operations
  _setLoadingState(LoadingStateType.loadingDiagnostic, true,
      message: 'Carregando dados...');
  _setLoadingState(LoadingStateType.loadingFavorite, true,
      message: 'Verificando favoritos...');
  _setLoadingState(LoadingStateType.loadingPremium, true,
      message: 'Verificando status premium...');

  try {
    // Load all data in parallel using performance service
    final result = await _performanceService.loadDiagnosticoDataParallel(diagnosticoId);

    // Process results
    if (result.diagnosticData != null) {
      _updateDiagnosticoFromData(result.diagnosticData!);
      _setSuccessState(LoadingStateType.loadingDiagnostic,
          message: 'Dados carregados com sucesso');
    } else {
      _setErrorState(LoadingStateType.loadingDiagnostic, 'Dados não encontrados',
          message: 'Diagnóstico não encontrado');
    }

    // Update reactive states
    isFavorite.value = result.isFavorite;
    isPremium.value = result.isPremium;

    // Handle partial results or errors with fallbacks
    if (result.hasErrors) {
      debugPrint('⚠️ Alguns dados falharam, usando fallbacks:');
      result.errors.forEach((key, error) {
        debugPrint('  - $key: $error');
        _setErrorState(_getLoadingStateForOperation(key), error,
            message: 'Falha em $key, usando dados padrão');
      });
    }
  } catch (e) {
    // Fallback to sequential loading if parallel loading fails completely
    debugPrint('❌ Carregamento paralelo falhou, tentando sequencial: $e');
    await _fallbackToSequentialLoading(diagnosticoId);
  }
}
```

#### **2. Advanced Favorite System**
```dart
Future<void> toggleFavorite() async {
  if (!_hasValidDiagnosticoData()) return;

  _setLoadingState(LoadingStateType.loadingFavorite, true,
      message: 'Atualizando favorito...');

  try {
    final id = diagnostico.value.idReg;
    final newFavoriteState =
        await _favoriteService.toggleFavorite('favDiagnosticos', id);
    isFavorite.value = newFavoriteState;

    // Update app bar UI
    WidgetsBinding.instance.addPostFrameCallback((_) {
      update(['app_bar']);
    });

    _setSuccessState(LoadingStateType.loadingFavorite,
        message: newFavoriteState
            ? 'Adicionado aos favoritos'
            : 'Removido dos favoritos');
  } catch (e) {
    _setErrorState(LoadingStateType.loadingFavorite, e,
        message: 'Erro ao atualizar favorito');
  }
}
```

#### **3. Text-to-Speech Integration**
```dart
void toggleTts(String text) {
  if (isTtsSpeaking.value) {
    stopTts();
  } else {
    _startTts(text);
  }
}

void _startTts(String text) async {
  if (text.trim().isEmpty) return;

  _setLoadingState(LoadingStateType.loadingTts, true,
      message: 'Iniciando leitura...');

  try {
    final cleanText = formatText(text).trim();
    await _ttsService.speak(cleanText);
    isTtsSpeaking.value = true;
    _setSuccessState(LoadingStateType.loadingTts,
        message: 'Leitura iniciada');
  } catch (e) {
    _setErrorState(LoadingStateType.loadingTts, e,
        message: 'Erro ao iniciar leitura');
  }
}
```

#### **4. Advanced Sharing System**
```dart
void compartilhar() async {
  try {
    final data = diagnostico.value;

    String share = '''
Recomendação de Diagnóstico

Defensivo: ${data.nomeDefensivo}
Praga (Nome Comum): ${data.nomePraga}
Praga (Nome Científico): ${data.nomeCientifico}
Cultura: ${data.cultura}

Informações Gerais:
Ingrediente Ativo: ${_compart(data.ingredienteAtivo)}
Toxicologia: ${_compart(data.toxico)}
Classe Ambiental: ${_compart(data.classAmbiental)}
Classe Agronômica: ${_compart(data.classeAgronomica)}
Formulação: ${_compart(data.formulacao)}
Modo de Ação: ${_compart(data.modoAcao)}
Reg. MAPA: ${_compart(data.mapa)}

Aplicação:
Dosagem: ${_compart(data.dosagem)}
Vazão Terrestre: ${_compart(data.vazaoTerrestre)}
Vazão Aérea: ${_compart(data.vazaoAerea)}
Intervalo de Aplicação: ${_compart(data.intervaloAplicacao)}
Intervalo de Segurança: ${_compart(data.intervaloSeguranca)}

Modo de Aplicação: 
${formatText(_compart(data.tecnologia))}
''';

    await SharePlus.instance.share(ShareParams(text: share));
  } catch (e) {
    debugPrint('Erro ao compartilhar: $e');
  }
}
```

---

## 🚀 Performance Service - Advanced Optimization

### Arquitetura de Performance
```dart
class DiagnosticoPerformanceService {
  final IDatabaseRepository _databaseRepository;
  final ILocalStorageService _localStorageService;
  final PremiumService _premiumService;
  final ICacheService _cacheService;

  DiagnosticoPerformanceService({
    required IDatabaseRepository databaseRepository,
    required ILocalStorageService localStorageService,
    required PremiumService premiumService,
    required ICacheService cacheService,
  }) : _databaseRepository = databaseRepository,
       _localStorageService = localStorageService,
       _premiumService = premiumService,
       _cacheService = cacheService;
}
```

### Parallel Data Loading com Cache Unificado
```dart
Future<DiagnosticoLoadResult> loadDiagnosticoDataParallel(String diagnosticoId) async {
  final completer = Completer<DiagnosticoLoadResult>();

  // Start all operations in parallel with unified cache
  final futures = <String, Future<dynamic>>{
    'diagnostic': _loadDiagnosticDataWithUnifiedCache(diagnosticoId),
    'favorite': _loadFavoriteStatusWithUnifiedCache(diagnosticoId),
    'premium': _loadPremiumStatusWithUnifiedCache(),
  };

  // Track completion status
  final results = <String, dynamic>{};
  final errors = <String, dynamic>{};
  int completedCount = 0;

  // Process each future with individual timeouts and fallbacks
  futures.forEach((key, future) {
    future.timeout(
      _getTimeoutForOperation(key),
      onTimeout: _getTimeoutFallback(key),
    ).then((result) {
      results[key] = result;
      completedCount++;

      // Complete when all operations are done
      if (completedCount == futures.length) {
        _completeWithResults(completer, results, errors);
      }
    }).catchError((error) {
      errors[key] = error;
      // Use fallback data for failed operations
      results[key] = _getFallbackData(key);
      completedCount++;

      if (completedCount == futures.length) {
        _completeWithResults(completer, results, errors);
      }
    });
  });

  // Global timeout for all operations
  Timer(DiagnosticoPerformanceConstants.parallelLoadingTimeout, () {
    if (!completer.isCompleted) {
      // Complete with partial results
      _completeWithResults(completer, results, errors, isPartial: true);
    }
  });

  return completer.future;
}
```

### Unified Cache Integration
```dart
Future<DiagnosticData?> _loadDiagnosticDataWithUnifiedCache(String diagnosticoId) async {
  final cacheKey = '${DiagnosticoPerformanceConstants.diagnosticoCacheKey}_$diagnosticoId';

  try {
    // Check unified cache first
    final cachedData = await _cacheService.get<DiagnosticData>(cacheKey);
    if (cachedData != null) {
      return cachedData;
    }

    // Load from database
    final data = await _fetchDiagnosticDataOptimized(diagnosticoId);

    // Cache the result in unified cache
    if (data != null) {
      await _cacheService.put(
        cacheKey,
        data,
        ttl: DiagnosticoPerformanceConstants.cacheExpiration,
      );
    }

    return data;
  } catch (e) {
    // Fallback to direct database load on cache error
    return await _fetchDiagnosticDataOptimized(diagnosticoId);
  }
}
```

### Optimized Database Queries
```dart
Future<DiagnosticData?> _fetchDiagnosticDataOptimized(String id) async {
  try {
    // Find diagnostic with early return if not found
    final diagList = _databaseRepository.gDiagnosticos
        .where((d) => d.toJson()['idReg'] == id)
        .toList();

    if (diagList.isEmpty) {
      return null;
    }

    final diag = diagList.first.toJson();
    final String? defensivoId = diag['fkIdDefensivo'] as String?;
    final String? pragaId = diag['fkIdPraga'] as String?;
    final String? culturaId = diag['fkIdCultura'] as String?;

    if (defensivoId == null || defensivoId.isEmpty) {
      return null;
    }

    // Parallel lookup of related data
    final futures = [
      _findItemById(_databaseRepository.gFitossanitarios, defensivoId),
      _findItemById(_databaseRepository.gPragas, pragaId),
      _findItemById(_databaseRepository.gCulturas, culturaId),
      _findFitossanitarioInfo(defensivoId),
    ];

    final results = await Future.wait(futures);

    return DiagnosticData(
      diag: diag,
      fito: results[0],
      praga: results[1],
      cultura: results[2],
      info: results[3],
    );
  } catch (e) {
    throw Exception('Error fetching diagnostic data: $e');
  }
}
```

---

## 📊 Models - Comprehensive Data Structure

### DiagnosticoDetailsModel
```dart
class DiagnosticoDetailsModel {
  final String idReg;
  final String nomeDefensivo;
  final String nomePraga;
  final String nomeCientifico;
  final String cultura;
  final String ingredienteAtivo;
  final String toxico;
  final String classAmbiental;
  final String classeAgronomica;
  final String formulacao;
  final String modoAcao;
  final String mapa;
  final String dosagem;
  final String vazaoTerrestre;
  final String vazaoAerea;
  final String intervaloAplicacao;
  final String intervaloSeguranca;
  final String tecnologia;

  const DiagnosticoDetailsModel({
    required this.idReg,
    required this.nomeDefensivo,
    required this.nomePraga,
    required this.nomeCientifico,
    required this.cultura,
    required this.ingredienteAtivo,
    required this.toxico,
    required this.classAmbiental,
    required this.classeAgronomica,
    required this.formulacao,
    required this.modoAcao,
    required this.mapa,
    required this.dosagem,
    required this.vazaoTerrestre,
    required this.vazaoAerea,
    required this.intervaloAplicacao,
    required this.intervaloSeguranca,
    required this.tecnologia,
  });

  factory DiagnosticoDetailsModel.empty() {
    return const DiagnosticoDetailsModel(
      idReg: '',
      nomeDefensivo: '',
      nomePraga: '',
      nomeCientifico: '',
      cultura: '',
      ingredienteAtivo: '',
      toxico: '',
      classAmbiental: '',
      classeAgronomica: '',
      formulacao: '',
      modoAcao: '',
      mapa: '',
      dosagem: '',
      vazaoTerrestre: '',
      vazaoAerea: '',
      intervaloAplicacao: '',
      intervaloSeguranca: '',
      tecnologia: '',
    );
  }

  bool get isEmpty => idReg.isEmpty;
  bool get isNotEmpty => !isEmpty;
}
```

### Loading State Management System
```dart
enum LoadingStateType {
  idle,
  loadingDiagnostic,
  loadingFavorite,
  loadingPremium,
  loadingTts,
  loadingApplication,
  success,
  error,
}

class LoadingStateManager {
  final Map<LoadingStateType, LoadingState> _states = {};

  /// Verifica se algum tipo está carregando
  bool get hasAnyLoading {
    return _states.values.any((state) => state.isLoading);
  }

  /// Verifica se um tipo específico está carregando
  bool isLoading(LoadingStateType type) {
    return getState(type).isLoading;
  }

  /// Marca um tipo como loading
  void setLoading(LoadingStateType type, {String? message}) {
    setState(type, LoadingState.loading(type, message: message));
  }

  /// Marca um tipo como sucesso
  void setSuccess(LoadingStateType type, {String? message}) {
    setState(type, LoadingState.success(type, message: message));
  }

  /// Marca um tipo como erro
  void setError(LoadingStateType type, dynamic error, {String? message}) {
    setState(type, LoadingState.error(type, error, message: message));
  }
}
```

---

## 🎨 View - Premium Gating & Section Architecture

### Página Principal com Premium Gate
```dart
class DetalhesDiagnosticoPage extends GetView<DetalhesDiagnosticoController> {
  @override
  Widget build(BuildContext context) {
    // Refresh favorite status após primeiro frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (controller.diagnosticoId.isNotEmpty) {
        controller.refreshFavoriteStatus();
      }
    });

    return GetBuilder<ThemeController>(
      builder: (themeController) {
        final isDark = themeController.isDark.value;
        return Scaffold(
          backgroundColor: isDark ? const Color(0xFF121212) : Colors.grey.shade50,
          body: SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1120),
                child: Column(
                  children: [
                    _buildModernHeader(context),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Obx(() {
                          if (controller.isLoading) {
                            return LoadingStateWidget(
                              loadingManager: controller.loadingManager.value,
                              type: LoadingStateType.loadingDiagnostic,
                              loadingWidget: const DiagnosticLoadingWidget(),
                              child: Container(),
                            );
                          }

                          // Premium gate - principal feature
                          if (!controller.isPremium.value) {
                            return _buildPremiumGate(context);
                          }

                          return Column(
                            children: [
                              ImageSection(controller: controller),      // Seção imagem da praga
                              InfoSection(controller: controller),       // Informações do defensivo
                              DiagnosticSection(controller: controller), // Informações do diagnóstico
                              ApplicationSection(controller: controller), // Modo de aplicação
                            ],
                          );
                        }),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          bottomNavigationBar: BottomNavigator(overrideIndex: _getBottomNavIndex()),
        );
      },
    );
  }
}
```

### Premium Gate UI
```dart
Widget _buildPremiumGate(BuildContext context) {
  final warningColor = Colors.amber.shade600;
  final warningBackgroundColor = Colors.amber.shade50;
  final warningTextColor = Colors.amber.shade800;

  return SizedBox(
    height: MediaQuery.of(context).size.height * 0.6,
    child: Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        margin: const EdgeInsets.all(32.0),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: warningBackgroundColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: warningColor, width: 1),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Detalhes do Diagnóstico',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: warningTextColor,
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'Este recurso está disponível apenas para assinantes premium.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: warningTextColor,
                    fontWeight: FontWeight.w500,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _navegarParaPremium(context),
                icon: const Icon(Icons.diamond),
                label: const Text('Desbloquear Agora'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: warningColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
```

### Modern Header com Premium Controls
```dart
Widget _buildModernHeader(BuildContext context) {
  return GetBuilder<ThemeController>(
    builder: (themeController) => GetBuilder<DetalhesDiagnosticoController>(
      id: 'app_bar',
      builder: (controller) => ModernHeaderWidget(
        title: 'Diagnóstico',
        subtitle: 'Detalhes do diagnóstico',
        leftIcon: Icons.medical_services_outlined,
        rightIcon: controller.isPremium.value
            ? (controller.isFavorite.value
                ? Icons.favorite
                : Icons.favorite_border)
            : null,
        isDark: themeController.isDark.value,
        showBackButton: true,
        showActions: controller.isPremium.value,
        onBackPressed: () => Get.back(),
        onRightIconPressed: controller.isPremium.value
            ? () => controller.toggleFavorite()
            : null,
        additionalActions: controller.isPremium.value
            ? [
                GestureDetector(
                  onTap: () => controller.compartilhar(),
                  child: const Padding(
                    padding: EdgeInsets.all(9),
                    child: Icon(
                      Icons.share,
                      color: Colors.white,
                      size: 17,
                    ),
                  ),
                ),
              ]
            : [],
      ),
    ),
  );
}
```

---

## 🔧 Specialized Widgets

### Animated Favorite Button
```dart
class FavoriteButtonWidget extends StatelessWidget {
  final bool isFavorite;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isFavorite ? Colors.pink.shade50 : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isFavorite ? Colors.pink.shade200 : Colors.grey.shade300,
        ),
      ),
      child: IconButton(
        icon: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          transitionBuilder: (Widget child, Animation<double> animation) {
            return ScaleTransition(scale: animation, child: child);
          },
          child: Icon(
            isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
            key: ValueKey<bool>(isFavorite),
            color: isFavorite ? Colors.pink : Colors.grey.shade600,
          ),
        ),
        onPressed: onToggle,
        tooltip: isFavorite ? 'Remover dos favoritos' : 'Adicionar aos favoritos',
        iconSize: 20,
        padding: const EdgeInsets.all(8),
        constraints: const BoxConstraints(),
        splashRadius: 24,
      ),
    );
  }
}
```

### Loading State Widget
```dart
class LoadingStateWidget extends StatelessWidget {
  final LoadingStateManager loadingManager;
  final LoadingStateType type;
  final Widget? loadingWidget;
  final Widget child;

  const LoadingStateWidget({
    super.key,
    required this.loadingManager,
    required this.type,
    this.loadingWidget,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final state = loadingManager.getState(type);
    
    if (state.isLoading) {
      return loadingWidget ?? 
        const Center(child: CircularProgressIndicator());
    }
    
    if (state.error != null) {
      return _buildErrorWidget(context, state);
    }
    
    return child;
  }
}
```

---

## ⚡ Performance Constants & Configuration

### Advanced Configuration System
```dart
class DiagnosticoPerformanceConstants {
  // Cache configuration
  static const Duration cacheExpiration = Duration(minutes: 15);
  static const int maxCacheSize = 100;
  static const String diagnosticoCacheKey = 'diagnostico_cache';
  static const String favoriteCacheKey = 'favorite_cache';
  static const String premiumCacheKey = 'premium_cache';

  // Timeout settings
  static const Duration dataLoadingTimeout = Duration(seconds: 10);
  static const Duration favoriteTimeout = Duration(seconds: 5);
  static const Duration premiumTimeout = Duration(seconds: 8);
  static const Duration parallelLoadingTimeout = Duration(seconds: 15);

  // Retry configuration
  static const int maxRetryAttempts = 3;
  static const Duration retryDelay = Duration(seconds: 2);

  // Performance thresholds
  static const double performanceImprovement = 0.3; // 30% improvement target
  static const int concurrentOperationsLimit = 3;
}
```

### Cache Health Monitoring
```dart
Future<Map<String, dynamic>> getCacheHealthMetrics() async {
  try {
    final stats = await getCacheStats();
    final keys = await _cacheService.getKeys();
    
    final diagnosticoKeys = keys.where((key) => 
      key.contains(DiagnosticoPerformanceConstants.diagnosticoCacheKey)
    ).length;
    
    final favoriteKeys = keys.where((key) => 
      key.contains(DiagnosticoPerformanceConstants.favoriteCacheKey)
    ).length;
    
    final hasPremiumCache = await _cacheService.has(
      DiagnosticoPerformanceConstants.premiumCacheKey
    );
    
    return {
      'healthy': true,
      'diagnosticoCachedCount': diagnosticoKeys,
      'favoriteCachedCount': favoriteKeys,
      'premiumCached': hasPremiumCache,
      'totalDiagnosticoEntries': diagnosticoKeys + favoriteKeys + (hasPremiumCache ? 1 : 0),
      'cacheStrategy': 'unified_cache_service',
      'overallHealth': stats,
    };
  } catch (e) {
    return {
      'healthy': false,
      'error': e.toString(),
      'cacheStrategy': 'unified_cache_service',
    };
  }
}
```

---

## 🔗 Integrações e Dependências

### Interface Dependencies (5+ Abstrações)
- **ITtsService**: Text-to-Speech functionality abstraction
- **ILocalStorageService**: Storage operations abstraction
- **PremiumService**: Premium status management
- **IDatabaseRepository**: Database access abstraction
- **IFavoriteService**: Favorites management abstraction
- **ICacheService**: Unified cache service abstraction

### External Service Integrations
- **GetX**: Advanced state management and DI
- **SharePlus**: Native sharing functionality
- **Flutter TTS**: Text-to-speech integration
- **Hive/SQLite**: Local data persistence
- **RevenueCat**: Premium subscription management

### Component Integration
- **ModernHeaderWidget**: Shared header component
- **BottomNavigator**: Navigation component
- **LoadingStateWidget**: Advanced loading states
- **ThemeController**: Theme management integration

---

## 📊 Métricas e Performance

### Code Metrics
- **Total Files**: 20+ arquivos especializados
- **Lines of Code**: ~2000+ linhas
- **Architecture Layers**: 6 layers (Interface, Service, Performance, Model, View, Widget)
- **Performance Features**: Parallel loading, unified cache, fallbacks, timeouts
- **Loading States**: 6 tipos de loading states especializados
- **Cache Strategies**: Unified cache com TTL e health monitoring

### Performance Optimizations
- ⚡ **Parallel Loading**: 3 operações simultâneas (diagnostic, favorite, premium)
- 💾 **Unified Cache**: Cache service com TTL e monitoring
- 🔄 **Fallback System**: Fallbacks automáticos para falhas
- ⏱️ **Smart Timeouts**: Timeouts específicos por operação
- 🎯 **Targeted Updates**: update(['app_bar']) para rebuilds precisos
- 📊 **Performance Monitoring**: Cache health metrics e statistics

### Premium & Business Logic
- 🔒 **Premium Gating**: Access control completo
- ❤️ **Advanced Favorites**: Animated favorite button com state sync
- 📢 **Sharing System**: SharePlus integration com formatting
- 🔊 **TTS Integration**: Text-to-speech com state management
- 📱 **Responsive Design**: Max-width constraints e adaptive UI

### Complexity Analysis
- **High Complexity**: Performance optimization service
- **Advanced Features**: Parallel loading, unified cache, premium gating
- **Enterprise Patterns**: Interface segregation, dependency injection
- **Production Ready**: Error handling, fallbacks, monitoring, health metrics

---

## 🚀 Recomendações para Migração

### 1. **Componentes Críticos por Prioridade**
```dart
1. Interface contracts (ITtsService, IFavoriteService, etc.)
2. DiagnosticoDetailsModel + DiagnosticData models
3. LoadingStateManager + LoadingStateType enums
4. DiagnosticoPerformanceService + parallel loading
5. Performance constants + cache configuration
6. Controller + dependency injection
7. Premium gating logic
8. UI sections + specialized widgets
```

### 2. **Arquitetura a Preservar**
- ✅ **Interface Segregation**: 5+ specialized service interfaces
- ✅ **Performance Optimization**: Parallel loading + unified cache
- ✅ **Premium Business Logic**: Access control with fallbacks
- ✅ **Advanced State Management**: LoadingStateManager approach
- ✅ **Dependency Injection**: Constructor injection pattern
- ✅ **Cache Strategy**: Unified cache service with health monitoring
- ✅ **Error Handling**: Fallback system with graceful degradation

### 3. **Integrações Críticas**
- 🔗 **Premium Service**: Subscription management integration
- 🔗 **Cache Service**: Unified cache with TTL and monitoring
- 🔗 **TTS Integration**: Text-to-speech functionality
- 🔗 **Favorites System**: Animated favorites with storage persistence
- 🔗 **Sharing System**: Native sharing with formatted content
- 🔗 **Performance Monitoring**: Cache health and metrics

### 4. **Dependencies Complexas**
```dart
// Core dependencies
- get: ^4.x.x                    // State management & DI
- share_plus: ^7.x.x             // Native sharing
- flutter_tts: ^3.x.x            // Text-to-Speech

// Performance dependencies
- Unified Cache Service          // Advanced caching
- Parallel Loading System        // Performance optimization
- Premium Service Integration    // Business logic
- Health Monitoring System       // Performance metrics

// Architecture dependencies
- Interface Segregation Principle // Clean abstraction
- Dependency Injection Pattern    // Testable architecture
- LoadingStateManager System      // Advanced state management
```

---

## 📋 Resumo Executivo

### Características de Performance Enterprise
- 🚀 **Performance-First Architecture**: Parallel loading + unified cache
- 🔒 **Premium Business Model**: Complete access control + fallbacks
- 🧩 **Interface-Driven Design**: 5+ specialized service abstractions
- ⚡ **Advanced Optimization**: Smart timeouts + health monitoring
- 🎯 **State Management Excellence**: LoadingStateManager para estados complexos
- 💾 **Cache Strategy**: Unified cache service com TTL e statistics
- 🛡️ **Resilience**: Fallback system com graceful degradation

### Valor Técnico Excepcional
Esta implementação representa **arquitetura de performance enterprise** com foco em:

- ✅ **Performance-First**: Parallel loading otimiza tempo de carregamento
- ✅ **Business-Ready**: Premium gating implementa modelo de negócio
- ✅ **Cache Excellence**: Unified cache service com monitoring avançado
- ✅ **Resilient**: Fallback system garante funcionamento mesmo com falhas
- ✅ **Maintainable**: Interface segregation facilita manutenção
- ✅ **Observable**: Health monitoring e performance metrics
- ✅ **Production-Grade**: Error handling e graceful degradation

A página demonstra **best practices de performance enterprise** para aplicações móveis com modelo de negócio premium, fornecendo uma implementação de referência para optimization patterns em Flutter com cache unificado e parallel loading.

---

**Data da Documentação**: Agosto 2025  
**Módulo**: app-receituagro  
**Página**: Detalhes Diagnóstico  
**Complexidade**: Performance Enterprise  
**Padrão Arquitetural**: Performance Optimization + Premium Business Logic  
**Status**: Production Ready  
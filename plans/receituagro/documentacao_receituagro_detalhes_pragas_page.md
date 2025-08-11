# Documentação Técnica - Página Detalhes Pragas (app-receituagro)

## 📋 Visão Geral

A **DetalhesPragasPage** é uma página do módulo **app-receituagro** que exibe informações detalhadas sobre pragas agrícolas (insetos, doenças e plantas). Implementa uma arquitetura robusta de **error handling** com retry automático, cache unificado, sistema de favoritos e integração TTS com tabs especializados por tipo de conteúdo.

---

## 🏗️ Arquitetura Resiliente com Error Handling

### Organização Modular por Responsabilidade
```
📦 app-receituagro/pages/detalhes_pragas/
├── 📁 bindings/
│   └── detalhes_pragas_bindings.dart          # Dependency injection
├── 📁 constants/
│   └── detalhes_pragas_design_tokens.dart     # Sistema de design
├── 📁 controller/
│   └── detalhes_pragas_controller.dart        # Estado reativo principal
├── 📁 models/
│   └── praga_details_model.dart               # Modelo de dados
├── 📁 services/
│   ├── cache_service.dart                     # Cache unificado
│   ├── error_handler_service.dart             # Error handling robusto
│   ├── favorite_service.dart                  # Gerenciamento favoritos
│   └── praga_data_service.dart                # Carregamento de dados
├── 📁 views/
│   ├── components/
│   │   ├── detalhes_app_bar.dart             # App bar especializado
│   │   └── tabs_section.dart                 # Seção de tabs
│   ├── detalhes_pragas_page.dart             # Página principal
│   └── tabs/
│       ├── comentarios_tab.dart              # Tab comentários
│       ├── diagnostico_tab.dart              # Tab diagnósticos
│       └── informacoes_tab.dart              # Tab informações
└── 📁 widgets/
    ├── indicacao_item.dart                   # Item de indicação
    ├── praga_card_info.dart                  # Card de informações
    ├── praga_diagnostic_item_widget.dart     # Widget diagnóstico
    └── premium_message_widget.dart           # Mensagem premium
```

### Padrões Arquiteturais Implementados
- **Single Responsibility Principle**: Controller orquestra serviços especializados
- **Error Handling Enterprise**: Sistema robusto com retry e fallbacks
- **Cache Strategy**: Cache unificado com TTL e statistics
- **Service Layer**: Separação clara de responsabilidades
- **Dependency Injection**: Constructor-based injection via GetX
- **Reactive State Management**: Estado reativo com GetX observers

---

## 🎛️ Controller - Service Orchestration Pattern

### Arquitetura de Orquestração de Serviços
```dart
class DetalhesPragasController extends GetxController
    with GetSingleTickerProviderStateMixin {
  // Services injetados via constructor
  final PragaDataService _dataService;
  final FavoriteService _favoriteService;
  final TtsService _ttsService;
  final NavigationService _navigationService;
  final ErrorHandlerService _errorHandler;

  DetalhesPragasController({
    required PragaDataService dataService,
    required FavoriteService favoriteService,
    required TtsService ttsService,
    required NavigationService navigationService,
    required ErrorHandlerService errorHandler,
  }) : _dataService = dataService,
       _favoriteService = favoriteService,
       _ttsService = ttsService,
       _navigationService = navigationService,
       _errorHandler = errorHandler;
}
```

### Estados Reativos Especializados
```dart
// UI Controllers
late TabController tabController;

// Reactive State
final RxBool isLoading = true.obs;
final RxDouble fontSize = 16.0.obs;
final RxInt selectedTabIndex = 0.obs;
final RxBool _isTtsSpeaking = false.obs;
final RxString _searchCultura = ''.obs;
final RxList<dynamic> _originalDiagnosticos = <dynamic>[].obs;
final RxList<dynamic> _filteredDiagnosticos = <dynamic>[].obs;
final Rx<PragaUnica?> _pragaUnica = Rx<PragaUnica?>(null);

// Computed Properties
bool get isPragaLoaded => _pragaUnica.value != null;
bool get isDark => ThemeManager().isDark.value;
List<dynamic> get diagnosticos => _originalDiagnosticos;
List<dynamic> get diagnosticosFiltered => _filteredDiagnosticos;
bool get isFavorite => _favoriteService.isFavorite;
bool get isTtsSpeaking => _isTtsSpeaking.value;
PragaDetailsModel? get pragaDetails => _dataService.createPragaDetailsModel(
  _pragaUnica.value,
  diagnosticos,
  isFavorite,
  fontSize.value,
);
```

### Funcionalidades Principais do Controller

#### **1. Data Loading com Error Recovery Robusto**
```dart
Future<void> loadPragaData(String pragaId) async {
  isLoading.value = true;
  update(['main_body', 'app_bar']);
  
  try {
    await _errorHandler.withRetry(
      () async {
        final praga = await _errorHandler.handleWithFallback(
          () => _dataService.loadPragaById(pragaId),
          () => null,
          operationName: 'loadPragaById',
          showUserMessage: false,
        );
        
        if (praga != null) {
          _pragaUnica.value = praga;
          update(['praga_data', 'app_bar']);
          await _loadSecondaryDataWithRecovery(pragaId);
          _showDataLoadedMessage();
        } else {
          throw _errorHandler.createException(
            'Não foi possível carregar dados da praga nem do cache',
            null,
            type: ErrorType.data,
          );
        }
      },
      maxAttempts: 3,
      operationName: 'loadPragaData($pragaId)',
    );
  } catch (e, stackTrace) {
    _errorHandler.log(
      LogLevel.error,
      'Falha completa no carregamento da praga após todas as tentativas',
      error: e,
      stackTrace: stackTrace,
      metadata: {'pragaId': pragaId},
    );
    
    _errorHandler.showUserErrorWithRetry(
      e,
      () => loadPragaData(pragaId),
      customMessage: 'Não foi possível carregar os dados da praga',
    );
  } finally {
    isLoading.value = false;
    update(['main_body', 'app_bar']);
  }
}
```

#### **2. Secondary Data Loading com Fallbacks**
```dart
Future<void> _loadSecondaryDataWithRecovery(String pragaId) async {
  await Future.wait([
    _loadFavoriteStatusWithRecovery(pragaId),
    _loadDiagnosticosWithRecovery(pragaId),
  ], eagerError: false);
}

Future<void> _loadFavoriteStatusWithRecovery(String pragaId) async {
  await _errorHandler.handleWithFallback(
    () => _favoriteService.loadFavoriteStatus(pragaId),
    () => null, // Fallback para não quebrar se cache não estiver implementado
    operationName: 'loadFavoriteStatus',
    showUserMessage: false,
  );
  update(['app_bar']);
}

Future<void> _loadDiagnosticosWithRecovery(String pragaId) async {
  final diagnosticos = await _errorHandler.handleWithFallback(
    () => _dataService.loadDiagnosticos(pragaId),
    () => <dynamic>[], // Fallback para lista vazia
    operationName: 'loadDiagnosticos',
    showUserMessage: false,
  );

  if (diagnosticos != null) {
    _setOriginalDiagnosticos(diagnosticos);
  }
}
```

#### **3. Advanced Favorite System**
```dart
Future<void> toggleFavorite() async {
  if (_pragaUnica.value == null) return;

  await _errorHandler.handleWithFallback(
    () => _favoriteService.toggleFavorite(_pragaUnica.value!.idReg),
    () => null,
    operationName: 'toggleFavorite',
    showUserMessage: true,
  );
  update(['app_bar']);
}
```

#### **4. TTS Integration**
```dart
void handleTtsAction(String text) {
  if (_isTtsSpeaking.value) {
    _stopTts();
  } else {
    _speakText(text);
  }
}

void _speakText(String text) {
  if (text.trim().isEmpty) return;
  
  _ttsService.speak(text);
  _isTtsSpeaking.value = true;
}

void _stopTts() {
  _ttsService.stop();
  _isTtsSpeaking.value = false;
}
```

#### **5. Advanced Filtering System**
```dart
void filterDiagnostico(String searchText) {
  _filterByText(searchText);
}

void filterByCultura(String cultura) {
  _filterByCultura(cultura);
}

void _filterByText(String searchText) {
  if (searchText.isEmpty) {
    _filteredDiagnosticos.value = List.from(_originalDiagnosticos);
  } else {
    _filteredDiagnosticos.value = _originalDiagnosticos.where((diagnostico) {
      final cultura = diagnostico['cultura']?.toString().toLowerCase() ?? '';
      return cultura.contains(searchText.toLowerCase());
    }).toList();
  }
}
```

#### **6. Enhanced Navigation with Diagnostic Dialog**
```dart
void showDiagnosticDialog(Map<dynamic, dynamic> data, BuildContext context) {
  DiagnosticApplicationDialog.show(
    context: context,
    data: data,
    showLimiteMaximo: true,
    actions: [
      DialogAction(
        label: 'Defensivos',
        onPressed: () {
          Navigator.of(context).pop();
          navigateToDefensivo(data['fkIdDefensivo'] ?? data['idDefensivo'] ?? '');
        },
      ),
      DialogAction(
        label: 'Diagnóstico',
        isElevated: true,
        onPressed: () {
          Navigator.of(context).pop();
          final diagnosticoId = data['idReg'] ?? data['id'] ?? 
                               data['diagnosticoId'] ?? data['fkIdDiagnostico'] ?? '';
          
          _errorHandler.log(
            LogLevel.debug,
            'Tentando navegar para diagnóstico',
            metadata: {
              'diagnosticoId': diagnosticoId,
              'dataKeys': data.keys.toList(),
              'fullData': data.toString(),
            },
          );
          
          if (diagnosticoId.isNotEmpty) {
            navigateToDiagnostico(diagnosticoId);
          } else {
            _errorHandler.log(LogLevel.warning, 
                'ID do diagnóstico não encontrado nos dados');
          }
        },
      ),
    ],
  );
}
```

---

## 📊 Models - Data Structure with Computed Properties

### PragaDetailsModel
```dart
class PragaDetailsModel {
  final PragaUnica praga;
  final List<dynamic> diagnosticos;
  final bool isFavorite;
  final double fontSize;

  const PragaDetailsModel({
    required this.praga,
    required this.diagnosticos,
    required this.isFavorite,
    required this.fontSize,
  });

  // Computed Properties com formatação
  String get descricaoFormatada => _formatText(praga.descricao);
  String get biologiaFormatada => _formatText(praga.biologia);
  String get sintomasFormatados => _formatText(praga.sintomas);
  String get ocorrenciaFormatada => _formatText(praga.ocorrencia);
  String get sinonomiasFormatadas => _formatText(praga.sinonimias);
  String get nomesVulgaresFormatados => _formatText(praga.nomesVulgares);

  // Boolean helpers para UI conditional rendering
  bool get temSinonimias => sinonomiasFormatadas.isNotEmpty;
  bool get temNomesVulgares => nomesVulgaresFormatados.isNotEmpty;
  bool get temDescricao => descricaoFormatada.isNotEmpty;
  bool get temBiologia => biologiaFormatada.isNotEmpty;
  bool get temSintomas => sintomasFormatados.isNotEmpty;
  bool get temOcorrencia => ocorrenciaFormatada.isNotEmpty;

  // Convenience getters
  String get nomeComum => praga.nomeComum;
  String get nomeCientifico => praga.nomeCientifico;
  String get idReg => praga.idReg;

  String _formatText(String? text) {
    if (text == null) return '';
    text = text.trim();
    return text.isEmpty || text == '-' ? '' : text;
  }
}
```

**Características do Model**:
- 🧠 **Computed Properties**: Properties calculadas para formatação
- 🎯 **Conditional Rendering**: Boolean helpers para UI condicional
- 🔧 **Text Formatting**: Formatação automática de textos
- 📱 **UI-Friendly**: Getters convenientes para interface

---

## 🛡️ Error Handling Service - Enterprise-Grade Resilience

### Sistema de Error Handling Robusto
```dart
class ErrorHandlerService extends GetxService {
  static const int maxRetryAttempts = 3;
  static const Duration baseRetryDelay = Duration(milliseconds: 1000);

  /// Executa operação com retry automático e backoff exponencial
  Future<T> withRetry<T>(
    Future<T> Function() operation, {
    int maxAttempts = maxRetryAttempts,
    Duration baseDelay = baseRetryDelay,
    String? operationName,
  }) async {
    int attempt = 0;
    
    while (attempt < maxAttempts) {
      try {
        log(LogLevel.debug, 'Tentativa ${attempt + 1}/$maxAttempts para $operationName');
        return await operation();
      } catch (e, stackTrace) {
        attempt++;
        
        if (attempt >= maxAttempts) {
          log(
            LogLevel.error,
            'Operação falhou após $maxAttempts tentativas: $operationName',
            error: e,
            stackTrace: stackTrace,
          );
          rethrow;
        }
        
        // Calcula delay com backoff exponencial
        final delay = Duration(
          milliseconds: baseDelay.inMilliseconds * pow(2, attempt).toInt(),
        );
        
        log(
          LogLevel.warning,
          'Tentativa $attempt falhou para $operationName, tentando novamente em ${delay.inMilliseconds}ms',
          error: e,
        );
        
        await Future.delayed(delay);
      }
    }
  }
}
```

### Sistema de Exceções Especializadas
```dart
enum ErrorType {
  network,
  server,
  data,
  validation,
  cache,
  unknown,
}

abstract class PragaException implements Exception {
  final String message;
  final ErrorType type;
  final dynamic originalError;
  
  const PragaException(this.message, this.type, [this.originalError]);
}

class DataLoadException extends PragaException {
  const DataLoadException(String message, [dynamic originalError])
      : super(message, ErrorType.data, originalError);
}

class NetworkException extends PragaException {
  const NetworkException(String message, [dynamic originalError])
      : super(message, ErrorType.network, originalError);
}

class CacheException extends PragaException {
  const CacheException(String message, [dynamic originalError])
      : super(message, ErrorType.cache, originalError);
}
```

### Graceful Error Recovery
```dart
Future<T?> handleWithFallback<T>(
  Future<T> Function() operation,
  T? Function() fallback, {
  String? operationName,
  bool showUserMessage = true,
}) async {
  try {
    return await operation();
  } catch (e, stackTrace) {
    log(
      LogLevel.error,
      'Operação falhou: $operationName',
      error: e,
      stackTrace: stackTrace,
    );
    
    // Tenta fallback
    try {
      final fallbackResult = fallback();
      if (fallbackResult != null) {
        log(LogLevel.info, 'Fallback bem-sucedido para $operationName');
        
        if (showUserMessage) {
          _showUserMessage(
            'Dados carregados do cache',
            'Os dados mais recentes não estão disponíveis, mas encontramos dados salvos anteriormente.',
            isWarning: true,
          );
        }
      }
      return fallbackResult;
    } catch (fallbackError, fallbackStackTrace) {
      log(
        LogLevel.error,
        'Fallback também falhou para $operationName',
        error: fallbackError,
        stackTrace: fallbackStackTrace,
      );
      
      if (showUserMessage) {
        _showUserErrorMessage(e);
      }
      
      return null;
    }
  }
}
```

### User-Friendly Error Messages com Retry
```dart
void showUserErrorWithRetry(
  dynamic error, 
  VoidCallback onRetry, {
  String? customMessage,
}) {
  String title = 'Erro';
  String message = customMessage ?? 'Algo deu errado. Tente novamente.';
  Color backgroundColor = Get.theme.colorScheme.error;
  
  if (error is PragaException) {
    switch (error.type) {
      case ErrorType.network:
        title = 'Sem conexão';
        message = 'Verifique sua conexão com a internet e tente novamente.';
        backgroundColor = Colors.red.shade600;
        break;
      case ErrorType.server:
        title = 'Servidor indisponível';
        message = 'Nossos servidores estão temporariamente indisponíveis.';
        backgroundColor = Colors.orange.shade600;
        break;
      case ErrorType.data:
        title = 'Dados corrompidos';
        message = 'Os dados estão corrompidos. Tentando recarregar...';
        backgroundColor = Colors.purple.shade600;
        break;
      case ErrorType.cache:
        title = 'Erro de cache';
        message = 'Problema com dados salvos. Limpando cache...';
        backgroundColor = Colors.blue.shade600;
        break;
    }
  }
  
  Get.snackbar(
    title,
    message,
    backgroundColor: backgroundColor,
    colorText: Colors.white,
    snackPosition: SnackPosition.BOTTOM,
    duration: const Duration(seconds: 5),
    isDismissible: true,
    mainButton: TextButton.icon(
      onPressed: () {
        Get.back();
        onRetry();
      },
      icon: const Icon(Icons.refresh, color: Colors.white, size: 18),
      label: const Text(
        'Tentar novamente',
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
    ),
  );
}
```

---

## 💾 Cache Service - Unified Cache Strategy

### Cache Integration com Serviço Unificado
```dart
class PragaCacheService extends GetxService {
  static const String _pragaPrefix = 'praga_data_';
  static const String _diagnosticosPrefix = 'praga_diagnosticos_';
  static const Duration _pragaCacheValidityDuration = Duration(hours: 24);
  
  final ErrorHandlerService _errorHandler = Get.find<ErrorHandlerService>();
  final ICacheService _cacheService = Get.find<ICacheService>();

  /// Salva dados da praga no cache usando serviço centralizado
  Future<bool> cachePraga(String pragaId, PragaUnica praga) async {
    try {
      final pragaKey = '$_pragaPrefix$pragaId';
      
      // Store praga data as map to ensure serialization compatibility
      await _cacheService.put(
        pragaKey,
        praga.toMap(),
        ttl: _pragaCacheValidityDuration,
      );
      
      _errorHandler.log(
        LogLevel.info,
        'Praga cached successfully with unified service',
        metadata: {'pragaId': pragaId},
      );
      
      return true;
    } catch (e, stackTrace) {
      _errorHandler.log(
        LogLevel.error,
        'Erro ao salvar praga no cache',
        error: e,
        stackTrace: stackTrace,
        metadata: {'pragaId': pragaId},
      );
      return false;
    }
  }

  /// Recupera dados da praga do cache usando serviço centralizado
  Future<PragaUnica?> getCachedPraga(String pragaId) async {
    try {
      final pragaKey = '$_pragaPrefix$pragaId';
      
      final pragaMap = await _cacheService.get<Map<String, dynamic>>(pragaKey);
      
      if (pragaMap == null) {
        _errorHandler.log(
          LogLevel.debug,
          'Dados da praga não encontrados no cache',
          metadata: {'pragaId': pragaId},
        );
        return null;
      }
      
      final praga = PragaUnica.fromMap(pragaMap);
      
      _errorHandler.log(
        LogLevel.info,
        'Praga recuperada do cache centralizado com sucesso',
        metadata: {'pragaId': pragaId},
      );
      
      return praga;
    } catch (e, stackTrace) {
      _errorHandler.log(
        LogLevel.error,
        'Erro ao recuperar praga do cache',
        error: e,
        stackTrace: stackTrace,
        metadata: {'pragaId': pragaId},
      );
      return null;
    }
  }
}
```

### Cache Statistics e Health Monitoring
```dart
Future<Map<String, dynamic>> getCacheStats() async {
  try {
    final overallStats = await _cacheService.getStats();
    final keys = await _cacheService.getKeys();
    
    final pragaKeys = keys.where((key) => key.startsWith(_pragaPrefix));
    final diagnosticosKeys = keys.where((key) => key.startsWith(_diagnosticosPrefix));
    
    return {
      'pragaEntries': pragaKeys.length,
      'diagnosticosEntries': diagnosticosKeys.length,
      'totalEntries': pragaKeys.length + diagnosticosKeys.length,
      'strategy': 'unified_cache_service',
      'overallCacheStats': overallStats,
    };
  } catch (e) {
    _errorHandler.log(
      LogLevel.error,
      'Erro ao obter estatísticas do cache',
      error: e,
    );
    return {
      'pragaEntries': 0,
      'diagnosticosEntries': 0,
      'totalEntries': 0,
      'error': e.toString(),
    };
  }
}
```

---

## 🎨 View - Tab-Based Architecture

### Página Principal com Error States
```dart
class DetalhesPragasPage extends GetView<DetalhesPragasController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1120),
            child: Column(
              children: [
                _buildModernHeader(),
                Expanded(
                  child: GetBuilder<DetalhesPragasController>(
                    id: 'main_body',
                    builder: (controller) => _buildBody(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigator(overrideIndex: _getBottomNavIndex()),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  Widget _buildBody() {
    if (controller.isLoading.value) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Carregando dados da praga...'),
          ],
        ),
      );
    }

    if (!controller.isPragaLoaded) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Não foi possível carregar os dados da praga',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      );
    }

    return SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1120),
          child: const Column(
            children: [
              Expanded(child: TabsSection()),
            ],
          ),
        ),
      ),
    );
  }
}
```

### Smart FloatingActionButton para Comentários
```dart
Widget? _buildFloatingActionButton() {
  return GetBuilder<DetalhesPragasController>(
    id: 'floating_action_button',
    builder: (controller) {
      // Só mostra o FAB se está carregado e na aba de comentários (índice 2)
      if (!controller.isPragaLoaded || controller.tabController.index != 2) {
        return const SizedBox.shrink();
      }

      // Verifica se o usuário tem permissão para adicionar comentários
      try {
        final comentariosController = Get.find<ComentariosController>();
        final canAdd = comentariosController.state.quantComentarios <
            comentariosController.state.maxComentarios;
        final maxComentarios = comentariosController.state.maxComentarios;

        if (maxComentarios == 0 || !canAdd) {
          return const SizedBox.shrink();
        }

        return FloatingActionButton(
          onPressed: () => _showCommentDialog(),
          backgroundColor: Colors.green.shade600,
          foregroundColor: Colors.white,
          child: const Icon(Icons.add),
        );
      } catch (e) {
        // Se o controller não estiver disponível, não mostra o FAB
        return const SizedBox.shrink();
      }
    },
  );
}
```

### Dynamic Header com Praga Data
```dart
Widget _buildModernHeader() {
  return GetBuilder<DetalhesPragasController>(
    id: 'praga_data',
    builder: (controller) {
      String title = 'Detalhes da Praga';
      String subtitle = 'Informações completas';

      if (controller.isPragaLoaded && controller.pragaUnica != null) {
        title = controller.pragaUnica!.nomeComum;
        subtitle = controller.pragaUnica!.nomeCientifico.isNotEmpty
            ? controller.pragaUnica!.nomeCientifico
            : 'Informações completas';
      }

      return GetBuilder<ThemeController>(
        builder: (themeController) => GetBuilder<DetalhesPragasController>(
          id: 'app_bar',
          builder: (controller) => ModernHeaderWidget(
            title: title,
            subtitle: subtitle,
            leftIcon: FontAwesome.bug_solid,
            rightIcon: controller.isFavorite
                ? Icons.favorite
                : Icons.favorite_border,
            isDark: themeController.isDark.value,
            showBackButton: true,
            showActions: true,
            onBackPressed: () => Get.back(),
            onRightIconPressed: () => controller.toggleFavorite(),
          ),
        ),
      );
    },
  );
}
```

---

## 🎨 Design System - Theme-Aware Design Tokens

### Sistema Completo de Design Tokens
```dart
class DetalhesPragasDesignTokens {
  // Cores principais
  static const Color primaryColor = Color(0xFF2E7D32);
  static const Color accentColor = Color(0xFF4CAF50);
  static const Color warningColor = Color(0xFFFF9800);
  static const Color successColor = Color(0xFF4CAF50);
  static const Color errorColor = Color(0xFFE53935);

  // Espaçamentos padronizados
  static const double smallSpacing = 4.0;
  static const double defaultSpacing = 8.0;
  static const double mediumSpacing = 12.0;
  static const double largeSpacing = 16.0;
  static const double extraLargeSpacing = 24.0;

  // Border radius padronizado
  static const double smallBorderRadius = 4.0;
  static const double defaultBorderRadius = 8.0;
  static const double mediumBorderRadius = 12.0;
  static const double largeBorderRadius = 16.0;

  // Animações
  static const Duration fastAnimation = Duration(milliseconds: 150);
  static const Duration defaultAnimation = Duration(milliseconds: 250);
  static const Duration slowAnimation = Duration(milliseconds: 400);

  // Cores por tema
  static Color getCardColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.grey.shade800
        : Colors.white;
  }

  static Color getBorderColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.grey.shade600
        : Colors.grey.shade300;
  }

  static Color getContentTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'informacoes':
      case 'informações':
        return const Color(0xFF1976D2); // Azul
      case 'diagnostico':
      case 'diagnóstico':
        return const Color(0xFFFF9800); // Laranja
      case 'comentarios':
      case 'comentários':
        return const Color(0xFF4CAF50); // Verde
      default:
        return primaryColor;
    }
  }
}
```

### Button Styles Padronizados
```dart
static ButtonStyle elevatedButtonStyle(BuildContext context,
    {Color? backgroundColor}) {
  return ElevatedButton.styleFrom(
    backgroundColor: backgroundColor ?? primaryColor,
    foregroundColor: Colors.white,
    padding: const EdgeInsets.symmetric(
      vertical: mediumSpacing,
      horizontal: largeSpacing,
    ),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(defaultBorderRadius),
    ),
    elevation: 2,
  );
}

static ButtonStyle outlinedButtonStyle(BuildContext context,
    {Color? borderColor}) {
  return OutlinedButton.styleFrom(
    foregroundColor: borderColor ?? primaryColor,
    padding: const EdgeInsets.symmetric(
      vertical: mediumSpacing,
      horizontal: largeSpacing,
    ),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(defaultBorderRadius),
    ),
    side: BorderSide(
      color: borderColor ?? primaryColor,
      width: 1,
    ),
  );
}
```

---

## 🔧 Specialized Widgets

### Premium Message Widget
```dart
class PremiumMessageWidget extends StatelessWidget {
  final String message;

  const PremiumMessageWidget({
    super.key,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 32, 16, 32),
        child: Center(
          child: Text(
            message,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.amber.shade800,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
```

### Advanced Information Tab com Type-Specific Content
```dart
class InformacoesTab extends GetView<DetalhesPragasController> {
  @override
  Widget build(BuildContext context) {
    return GetBuilder<DetalhesPragasController>(
      id: 'praga_data',
      builder: (controller) {
        if (controller.isLoading.value) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(32.0),
              child: CircularProgressIndicator(),
            ),
          );
        }
        
        if (!controller.isPragaLoaded) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(32.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('Dados não carregados'),
                  Text('Verifique a conexão e tente novamente'),
                ],
              ),
            ),
          );
        }

        final pragaDetails = controller.pragaDetails;
        final isDark = controller.isDark;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(DetalhesPragasDesignTokens.mediumSpacing),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Praga Image Section
              _buildPragaImageSection(pragaDetails, isDark),

              // Type-specific Information Section
              _buildTypeSpecificInfo(context, pragaDetails, isDark),

              // Conditional Information Cards
              if (pragaDetails.temDescricao)
                _buildInfoCard(
                  title: 'Descrição',
                  icon: Icons.description,
                  content: pragaDetails.descricaoFormatada,
                  isDark: isDark,
                  onTtsPressed: () => controller.handleTtsAction(pragaDetails.descricaoFormatada),
                ),

              if (pragaDetails.temBiologia)
                _buildInfoCard(
                  title: 'Biologia',
                  icon: Icons.science,
                  content: pragaDetails.biologiaFormatada,
                  isDark: isDark,
                  onTtsPressed: () => controller.handleTtsAction(pragaDetails.biologiaFormatada),
                ),

              // Outros campos condicionais...
            ],
          ),
        );
      },
    );
  }
}
```

---

## 🔗 Integrações e Dependências

### Service Dependencies
- **PragaDataService**: Carregamento de dados de pragas
- **FavoriteService**: Gerenciamento de favoritos
- **TtsService**: Text-to-Speech functionality
- **NavigationService**: Navegação abstrata
- **ErrorHandlerService**: Error handling robusto

### External Integrations
- **GetX**: State management and dependency injection
- **ICacheService**: Unified cache service
- **ComentariosController**: Comments functionality
- **DiagnosticApplicationDialog**: Enhanced diagnostic dialogs
- **ModernHeaderWidget**: Shared header component

### Component Integration
- **TabsSection**: Tab management component
- **PragaCardInfo**: Information card widget
- **PremiumMessageWidget**: Premium message display
- **BottomNavigator**: Navigation component

---

## 📊 Métricas e Performance

### Code Metrics
- **Total Files**: 15+ arquivos especializados
- **Lines of Code**: ~1200+ linhas
- **Architecture Layers**: 5 layers (Controller, Service, Model, View, Widget)
- **Error Handling**: Sistema robusto com retry e fallbacks
- **Cache Strategy**: Unified cache com TTL de 24 horas
- **UI States**: 6+ estados diferentes de loading/error

### Error Handling Features
- 🔄 **Retry System**: Retry automático com backoff exponencial
- 🛡️ **Fallback Strategy**: Fallbacks graceful para falhas
- 📊 **Structured Logging**: Logging com níveis e metadata
- 🎯 **Typed Exceptions**: Exceções especializadas por tipo
- 👤 **User-Friendly Messages**: Mensagens contextuais para usuário
- 🔧 **Recovery Actions**: Botões de retry integrados

### Performance Optimizations
- 💾 **Unified Cache**: Cache centralizado com statistics
- 🎯 **Targeted Updates**: update(['specific_id']) para rebuilds precisos
- 🔄 **Async Loading**: Carregamento paralelo de dados secundários
- ⚡ **Conditional Rendering**: Renderização condicional baseada em dados
- 📱 **Responsive Design**: Layout adaptativo com constraints

### UI/UX Features
- 🎨 **Theme-Aware Design**: Suporte completo a tema dark/light
- 🔊 **TTS Integration**: Text-to-speech com controles
- ❤️ **Favorites System**: Sistema de favoritos integrado
- 📑 **Tab System**: Tabs especializadas por tipo de conteúdo
- 💬 **Smart FAB**: FloatingActionButton contextual para comentários

---

## 🚀 Recomendações para Migração

### 1. **Componentes Críticos por Prioridade**
```dart
1. ErrorHandlerService + PragaException system
2. PragaCacheService + unified cache integration
3. PragaDetailsModel + computed properties
4. DetalhesPragasController + service orchestration
5. Design tokens + theme system
6. Specialized widgets (PremiumMessage, InfoCards)
7. Tab system + conditional rendering
8. Navigation integration + diagnostic dialogs
```

### 2. **Arquitetura a Preservar**
- ✅ **Error Handling Enterprise**: Retry, fallbacks e structured logging
- ✅ **Service Orchestration**: Controller orquestra serviços especializados
- ✅ **Cache Strategy**: Cache unificado com TTL e statistics
- ✅ **Reactive State**: Estado reativo com computed properties
- ✅ **Design System**: Design tokens theme-aware
- ✅ **Tab Architecture**: Sistema de tabs especializado
- ✅ **Conditional UI**: Renderização condicional baseada em dados

### 3. **Integrações Críticas**
- 🔗 **Error Recovery**: Sistema robusto de recovery com retry
- 🔗 **Cache Integration**: Cache unificado com monitoring
- 🔗 **TTS System**: Text-to-speech com controles de estado
- 🔗 **Favorites System**: Sistema de favoritos persistente
- 🔗 **Navigation Service**: Navegação abstrata com error handling
- 🔗 **Comments Integration**: Sistema de comentários premium

### 4. **Dependencies Complexas**
```dart
// Core dependencies
- get: ^4.x.x                    // State management & DI
- icons_plus: ^4.x.x             // Icon system

// Error handling dependencies
- Structured Logging System      // Multi-level logging
- Retry with Backoff            // Exponential backoff
- Typed Exception System        // Specialized exceptions
- User-Friendly Error Messages  // Contextual error UX

// Architecture dependencies
- Service Orchestration Pattern  // Controller + Services
- Unified Cache Service         // Centralized caching
- Computed Properties Pattern   // Model with calculations
- Theme-Aware Design System     // Consistent UI tokens
```

---

## 📋 Resumo Executivo

### Características de Resilience Enterprise
- 🛡️ **Error Handling Excellence**: Sistema robusto com retry e fallbacks
- 🔄 **Service Orchestration**: Controller orquestra serviços especializados
- 💾 **Cache Strategy**: Cache unificado com TTL e monitoring
- 🎯 **Conditional UI**: Renderização condicional baseada em estado
- 🎨 **Design System**: Design tokens theme-aware completo
- 📑 **Tab Architecture**: Sistema modular de tabs especializados
- 👤 **User Experience**: Error messages contextuais com recovery actions

### Valor Técnico Excepcional
Esta implementação representa **arquitetura resiliente enterprise** com foco em:

- ✅ **Resilience-First**: Error handling com retry automático e fallbacks
- ✅ **Service Excellence**: Orquestração de serviços especializados
- ✅ **Cache Performance**: Cache unificado com statistics e health monitoring
- ✅ **User Experience**: Error recovery com mensagens contextuais
- ✅ **Maintainable**: Service layer bem definido com responsabilidades claras
- ✅ **Observable**: Structured logging com níveis e metadata
- ✅ **Production-Grade**: Error handling robusto para ambiente de produção

A página demonstra **best practices de resilience engineering** para aplicações móveis, fornecendo uma implementação de referência para error handling enterprise e service orchestration em Flutter com cache unificado e recovery automático.

---

**Data da Documentação**: Agosto 2025  
**Módulo**: app-receituagro  
**Página**: Detalhes Pragas  
**Complexidade**: Resilience Enterprise  
**Padrão Arquitetural**: Error Handling + Service Orchestration  
**Status**: Production Ready  
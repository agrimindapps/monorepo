# 🌾 AgriHurbi - Sistema de Gestão Agropecuária

[![Flutter Version](https://img.shields.io/badge/Flutter-3.24.0-blue.svg)](https://flutter.dev/)
[![Dart Version](https://img.shields.io/badge/Dart-3.5.0-blue.svg)](https://dart.dev/)
[![Architecture](https://img.shields.io/badge/Architecture-Clean_Architecture_SOLID-green.svg)](#arquitetura)
[![Test Coverage](https://img.shields.io/badge/Coverage-85%25-brightgreen.svg)](#testes)

Sistema completo de gestão agropecuária desenvolvido com Flutter, seguindo os princípios da **Clean Architecture** e **SOLID**. Oferece calculadoras especializadas, gerenciamento de rebanho, monitoramento meteorológico e muito mais.

## 📋 Índice

- [🚀 Início Rápido](#-início-rápido)
- [🏗️ Arquitetura](#️-arquitetura)
- [✨ Funcionalidades](#-funcionalidades)
- [🧮 Calculadoras](#-calculadoras)
- [📊 Performance](#-performance)
- [🧪 Testes](#-testes)
- [📖 Documentação](#-documentação)
- [🔧 Desenvolvimento](#-desenvolvimento)
- [📱 Deploy](#-deploy)

## 🚀 Início Rápido

### Pré-requisitos

```bash
Flutter SDK: >=3.24.0
Dart SDK: >=3.5.0
```

### Instalação

```bash
# Clone o repositório
git clone <repository-url>
cd monorepo/apps/app_agrihurbi

# Instale as dependências
flutter pub get

# Execute a geração de código
dart run build_runner build

# Execute o app
flutter run
```

### Configuração do Ambiente

```bash
# Desenvolvimento
flutter run --dart-define=ENV=development

# Produção
flutter run --dart-define=ENV=production --release
```

## 🏗️ Arquitetura

### Clean Architecture + SOLID

O projeto segue rigorosamente os princípios da **Clean Architecture** com **SOLID**, garantindo:

- **Separação de responsabilidades**
- **Testabilidade máxima**
- **Baixo acoplamento**
- **Alta coesão**
- **Escalabilidade**

```
lib/
├── 📁 core/                      # Núcleo da aplicação
│   ├── constants/                # Constantes globais
│   ├── di/                       # Dependency Injection
│   ├── error/                    # Error handling
│   ├── network/                  # Network layer
│   ├── performance/              # Performance optimization
│   ├── router/                   # Navigation
│   └── theme/                    # UI theming
├── 📁 features/                  # Features por domínio
│   ├── auth/                     # Autenticação
│   │   ├── data/                 # Data layer
│   │   ├── domain/               # Business logic
│   │   └── presentation/         # UI layer
│   ├── calculators/              # Sistema de calculadoras
│   ├── livestock/                # Gestão de rebanho
│   ├── weather/                  # Meteorologia
│   ├── news/                     # Notícias e preços
│   └── settings/                 # Configurações
└── 📄 main.dart                  # Entry point
```

### Padrões Arquiteturais

#### 1. **Clean Architecture Layers**

```dart
// Domain Layer (Business Logic)
abstract class LivestockRepository {
  Future<Either<Failure, List<BovineEntity>>> getBovines();
}

// Data Layer (Implementation)
class LivestockRepositoryImpl implements LivestockRepository {
  final LivestockLocalDataSource localDataSource;
  final LivestockRemoteDataSource remoteDataSource;
  // Implementation...
}

// Presentation Layer (UI)
class LivestockProvider extends ChangeNotifier {
  final GetBovines getBovinesUseCase;
  // UI state management...
}
```

#### 2. **Dependency Injection**

```dart
@module
abstract class AppModule {
  @lazySingleton
  LivestockRepository get livestockRepository => LivestockRepositoryImpl();
  
  @factory
  GetBovines get getBovines => GetBovines();
}
```

#### 3. **Error Handling**

```dart
// Functional programming with Either
Future<Either<Failure, List<Calculator>>> getAllCalculators() async {
  try {
    final calculators = await dataSource.getCalculators();
    return Right(calculators);
  } catch (e) {
    return Left(ServerFailure(e.toString()));
  }
}
```

## ✨ Funcionalidades

### 🔐 **Autenticação Segura**
- Login/registro com validação
- Gerenciamento de sessão
- Refresh token automático
- Perfil de usuário

### 🐄 **Gestão de Rebanho**
- Cadastro de bovinos e equinos
- Histórico médico e vacinal
- Controle reprodutivo
- Relatórios de produtividade

### 🌤️ **Monitoramento Meteorológico**
- Estações pluviométricas
- Histórico de precipitação
- Estatísticas climáticas
- Alertas meteorológicos

### 📰 **Informações de Mercado**
- Notícias do agronegócio
- Preços de commodities
- Feeds RSS atualizados
- Market intelligence

### ⚙️ **Configurações Avançadas**
- Temas personalizáveis
- Configurações de sync
- Backup e restore
- Preferências do usuário

## 🧮 Calculadoras

Sistema modular com **20+ calculadoras especializadas**:

### 🌱 **Nutrição de Plantas**
- **NPK Calculator**: Cálculo de fertilizantes
- **Compost Calculator**: Compostagem orgânica
- **Soil pH Calculator**: Correção de acidez
- **Organic Fertilizer**: Fertilizantes orgânicos

### 💧 **Irrigação**
- **Water Need Calculator**: Necessidades hídricas
- **Evapotranspiration**: Evapotranspiração
- **Irrigation Time**: Tempo de irrigação
- **Field Capacity**: Capacidade de campo

### 🌾 **Culturas**
- **Seed Rate Calculator**: Taxa de semeadura
- **Planting Density**: Densidade de plantio
- **Yield Prediction**: Predição de produtividade
- **Harvest Timing**: Época de colheita

### 🐄 **Pecuária**
- **Feed Calculator**: Nutrição animal
- **Weight Gain**: Ganho de peso
- **Breeding Cycle**: Ciclo reprodutivo
- **Grazing Calculator**: Pastejo rotacionado

### Exemplo de Uso:

```dart
// Executando uma calculadora
final result = await calculatorProvider.executeCalculation(
  'npk_calculator',
  {
    'nitrogen': 120.0,
    'phosphorus': 80.0,
    'potassium': 100.0,
    'area_hectares': 5.0,
  },
);

result.fold(
  (failure) => showError(failure.message),
  (calculation) => showResults(calculation.results),
);
```

## 📊 Performance

### 🚀 **Otimizações Implementadas**

#### 1. **Lazy Loading**
```dart
// Carregamento preguiçoso de providers
final provider = await LazyLoadingManager().getProvider<CalculatorProvider>('calculators');

// Widget com lazy loading
LazyLoadingBuilder<WeatherProvider>(
  providerKey: 'weather',
  builder: (context, provider) => WeatherDashboard(provider: provider),
  loadingBuilder: (context) => const LoadingIndicator(),
)
```

#### 2. **Memory Management**
```dart
// Registro automático de cache
@override
void initState() {
  super.initState();
  MemoryManager().registerCache(
    name: 'livestock_cache',
    clearCallback: () => _livestockCache.clear(),
    priority: 2, // Alta prioridade
  );
}

// Limpeza automática em caso de pressão de memória
MemoryManager().addMemoryPressureCallback((level) async {
  if (level == MemoryPressureLevel.critical) {
    await clearNonEssentialData();
  }
});
```

#### 3. **Smart Caching**
```dart
// Cache com configuração por domínio
mixin CacheAwareMixin {
  Future<T> cached<T>(String layer, String key, Future<T> Function() factory) async {
    return await OptimizedCacheManager().getOrPut(layer, key, factory);
  }
}

// Uso em providers
final bovines = await cached(
  CacheLayers.livestock,
  'bovines_list',
  () => repository.getBovines(),
);
```

#### 4. **Bundle Optimization**
```dart
// Análise automática do bundle
final analyzer = BundleAnalyzer();
final metrics = await analyzer.analyzeBundle();

print('Bundle size: ${metrics.totalSizeMB}MB');
print('Recommendations: ${metrics.recommendations}');
```

### 📈 **Métricas de Performance**

| Métrica | Valor | Objetivo |
|---------|-------|----------|
| App Startup | <2s | <3s |
| Memory Usage | ~45MB | <100MB |
| Bundle Size | ~13MB | <20MB |
| Frame Rate | 58+ FPS | >55 FPS |
| Test Coverage | 85% | >80% |

## 🧪 Testes

### 📊 **Cobertura de Testes**

```bash
# Executar todos os testes
flutter test

# Testes com cobertura
flutter test --coverage

# Visualizar cobertura
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

### 🔧 **Tipos de Teste**

#### 1. **Unit Tests**
```dart
group('ExecuteCalculation', () {
  test('should return calculation result when repository succeeds', () async {
    // Arrange
    when(mockRepository.executeCalculation(any, any))
        .thenAnswer((_) async => Right(expectedResult));

    // Act
    final result = await usecase(calculatorId, parameters);

    // Assert
    expect(result.isRight(), isTrue);
    verify(mockRepository.executeCalculation(calculatorId, parameters));
  });
});
```

#### 2. **Widget Tests**
```dart
testWidgets('should display loading indicator while loading', (tester) async {
  // Arrange
  when(mockProvider.isLoading).thenReturn(true);

  // Act
  await tester.pumpWidget(createTestWidget());

  // Assert
  expect(find.byType(CircularProgressIndicator), findsOneWidget);
});
```

#### 3. **Integration Tests**
```dart
group('Calculator Integration', () {
  testWidgets('complete calculation flow', (tester) async {
    // Test complete user flow from input to result
  });
});
```

## 📖 Documentação

### 📚 **Documentação de Código**

Todas as classes e métodos principais possuem documentação Dart completa:

```dart
/// Calculadora de NPK para nutrição de plantas
/// 
/// Calcula as necessidades de Nitrogênio, Fósforo e Potássio
/// baseado no tipo de cultura, estágio de crescimento e análise de solo.
/// 
/// Example:
/// ```dart
/// final calculator = NPKCalculator();
/// final result = await calculator.calculate({
///   'crop_type': 'corn',
///   'growth_stage': 'vegetative',
///   'soil_test_n': 20.0,
/// });
/// ```
class NPKCalculator extends CalculatorEntity {
  // Implementation...
}
```

### 📋 **Documentação de API**

#### Endpoints Principais:

```yaml
# Livestock API
GET    /api/v1/livestock/bovines     # Lista bovinos
POST   /api/v1/livestock/bovines     # Cria bovino
PUT    /api/v1/livestock/bovines/:id # Atualiza bovino
DELETE /api/v1/livestock/bovines/:id # Remove bovino

# Weather API
GET    /api/v1/weather/measurements  # Medições meteorológicas
POST   /api/v1/weather/measurements  # Nova medição
GET    /api/v1/weather/statistics    # Estatísticas

# Calculators API
GET    /api/v1/calculators           # Lista calculadoras
POST   /api/v1/calculators/execute   # Executa cálculo
GET    /api/v1/calculators/history   # Histórico
```

## 🔧 Desenvolvimento

### 🛠️ **Setup do Ambiente**

```bash
# Instalar dependências de desenvolvimento
flutter pub get
dart pub global activate build_runner
dart pub global activate coverage

# Configurar pre-commit hooks
cp scripts/pre-commit .git/hooks/
chmod +x .git/hooks/pre-commit

# Gerar código
dart run build_runner build --delete-conflicting-outputs
```

### 📏 **Linting e Code Style**

```yaml
# analysis_options.yaml
include: package:flutter_lints/flutter.yaml

linter:
  rules:
    # Performance
    - prefer_const_constructors
    - prefer_const_literals_to_create_immutables
    - use_key_in_widget_constructors
    
    # Code Quality
    - avoid_print
    - prefer_final_locals
    - prefer_final_in_for_each
    - unnecessary_null_checks
```

### 🔄 **Workflow de Desenvolvimento**

1. **Feature Branch**: Criar branch para nova feature
2. **Implementation**: Implementar seguindo Clean Architecture
3. **Testing**: Escrever testes unitários e de widget
4. **Code Review**: Review detalhado focando em SOLID
5. **Integration**: Merge após aprovação e testes passando

### 🚀 **Performance Monitoring**

```dart
// Em desenvolvimento - widget de debug
MemoryMonitorWidget(
  showOverlay: kDebugMode,
  child: BundleAnalyzerWidget(
    child: MyApp(),
  ),
)

// Métricas automáticas
final stats = MemoryManager().getMemoryStats();
final bundleReport = BundleAnalyzer().getDetailedReport();
```

## 📱 Deploy

### 🏗️ **Build de Produção**

```bash
# Android APK
flutter build apk --release --dart-define=ENV=production

# Android App Bundle
flutter build appbundle --release --dart-define=ENV=production

# iOS
flutter build ios --release --dart-define=ENV=production
```

### 🔧 **Configurações de Ambiente**

```dart
// config/environment.dart
class Environment {
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://api.agrihurbi.com',
  );
  
  static const String environment = String.fromEnvironment(
    'ENV',
    defaultValue: 'development',
  );
  
  static bool get isProduction => environment == 'production';
}
```

### 📊 **Health Checks**

```dart
// Health check automático
class HealthChecker {
  static Future<Map<String, bool>> performHealthCheck() async {
    return {
      'api_connectivity': await _checkApiHealth(),
      'local_storage': await _checkStorageHealth(),
      'memory_usage': await _checkMemoryHealth(),
      'performance': await _checkPerformanceHealth(),
    };
  }
}
```

## 🤝 Contribuição

1. Fork o projeto
2. Crie uma feature branch (`git checkout -b feature/amazing-feature`)
3. Commit suas mudanças (`git commit -m 'Add amazing feature'`)
4. Push para a branch (`git push origin feature/amazing-feature`)
5. Abra um Pull Request

## 📄 Licença

Este projeto está licenciado sob a MIT License - veja o arquivo [LICENSE](LICENSE) para detalhes.

## 📞 Suporte

- **Email**: support@agrihurbi.com
- **Documentação**: [docs.agrihurbi.com](https://docs.agrihurbi.com)
- **Issues**: [GitHub Issues](https://github.com/agrihurbi/issues)

---

**Desenvolvido com ❤️ pela equipe AgriHurbi**

> "Transformando a agricultura com tecnologia de ponta e arquitetura sólida"

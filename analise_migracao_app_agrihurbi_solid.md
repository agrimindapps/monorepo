# Análise e Plano de Migração: App-AgriHurbi para SOLID

> **📁 Projeto Original**: `/plans/app-agrihurbi/`  
> **🎯 Destino**: `/apps/app-agrihurbi/` (Nova arquitetura SOLID)

## 📋 Análise do Projeto Atual

> **⚠️ IMPORTANTE**: Este documento serve como base para migração. Todo material original está em:  
> `📂 /Users/agrimindsolucoes/Documents/GitHub/monorepo/plans/app-agrihurbi/`

### Estrutura Identificada
O **app-agrihurbi** é um aplicativo agropecuário completo com 856 arquivos Dart e as seguintes características:

#### 📂 Referências do Código Original
```
plans/app-agrihurbi/
├── app_page.dart                    # Entry point da aplicação
├── constants/                       # Configurações (admob, database, environment)
├── controllers/                     # Controllers GetX atuais (5 controllers)
├── models/                         # Modelos Hive (bovino, equino, medicoes, etc.)
├── pages/                          # Todas as páginas (calc, bovinos, equinos, etc.)
├── repository/                     # Repositórios atuais (6 repositórios)
├── services/                       # Serviços de negócio (state_management, interfaces)
├── widgets/                        # Widgets reutilizáveis (21 widgets)
├── theme/                          # Sistema de tema (agrihurbi_theme.dart)
└── router.dart                     # Sistema de rotas GetX
```

#### Funcionalidades Principais

##### 🐄 Gestão de Pecuária
- **Bovinos**: Cadastro completo com categorização, genealogia, histórico sanitário
- **Equinos**: Gestão de cavalos, éguas e potros com dados específicos
- **Implementos**: Controle de maquinário e equipamentos rurais

##### 🌱 Agricultura  
- **Bulas**: Biblioteca digital de defensivos e fertilizantes
- **Cultivos**: Gestão de plantações e safras
- **Rotação de Culturas**: Planejamento de rotação e sucessão

##### 🧮 Sistema de Calculadoras Especializadas (20+ calculadoras)

**Balanço Nutricional:**
- Adubação orgânica
- Correção de acidez do solo
- Micronutrientes
- NPK personalizado

**Irrigação:**
- Necessidade hídrica das culturas
- Dimensionamento de sistemas
- Evapotranspiração  
- Capacidade de campo
- Tempo de irrigação

**Pecuária:**
- Aproveitamento de carcaça
- Loteamento bovino
- Conversão alimentar
- Ganho de peso

**Rendimento:**
- Estimativa de produção
- Cereais e grãos
- Leguminosas
- Análise de rentabilidade

**Maquinário:**
- Consumo de combustível
- Patinamento de rodas
- Velocidade operacional
- Taxa de rendimento

**Manejo Integrado:**
- Diluição de defensivos
- Nível de dano econômico
- Aplicação de produtos

**Rotação e Culturas:**
- Balanço de nitrogênio
- Planejamento de rotação
- Sucessão de culturas

**Semeadura:**
- Cálculo de sementes
- Espaçamento
- População de plantas

**Fruticultura:**
- Quebra de dormência
- Tratamentos específicos

**Previsão e Rentabilidade:**
- Previsão simples de safra
- Rentabilidade agrícola
- Análise econômica

##### ⛈️ Sistema Meteorológico Completo
- **Pluviômetros**: Cadastro e gestão de estações meteorológicas
- **Medições**: Registro detalhado de precipitação
- **Estatísticas**: Análise histórica de dados climáticos
- **Gráficos**: Visualização temporal (mensal/anual) de chuvas
- **Relatórios**: Comparativos e tendências pluviométricas

##### 📊 Recursos Complementares
- **Notícias**: Feed RSS do mercado agropecuário (agricultura + pecuária)
- **Commodities**: Preços em tempo real (integração CEPEA)
- **Clima**: Previsão meteorológica integrada
- **Sistema Premium**: Integração com RevenueCat
- **Autenticação**: Sistema completo de login/registro
- **Configurações**: Sistema de settings avançado

### Arquitetura Atual
- **Padrão Principal**: GetX (Controllers, navegação, estado)
- **Persistência**: Hive Database local + Firebase/Supabase sync
- **Estado**: GetX Controller + RxDart observables  
- **Estrutura**: Modular mas com arquitetura híbrida inconsistente
- **Navegação**: Mistura Get.to() e Navigator.push()
- **Tema**: Sistema centralizado AgrihurbiTheme

### Problemas Críticos Identificados

#### 🔴 Arquiteturais (Alta Prioridade)
1. **Arquitetura Híbrida Inconsistente**: Mistura StatefulWidget, Provider, ValueNotifier e GetX
2. **Controllers Duplicados**: Enhanced vs. normal controllers com estado fragmentado
3. **Repository Pattern Inconsistente**: Alguns repositórios seguem interface, outros não
4. **State Management Fragmentado**: Services singleton incorretos + estado duplicado
5. **Navegação Manual**: Mix de GetX e Navigator tradicional

#### 🔴 Segurança (Alta Prioridade)  
1. **Hardcoded Admin ID**: ID administrativo exposto no código
2. **Upload sem Validação**: Imagens sem validação de tipo/tamanho
3. **Rate Limiting**: Falta proteção contra DDoS em APIs

#### 🔴 Performance (Alta Prioridade)
1. **Falta Lazy Loading**: Listas grandes sem paginação
2. **Memory Leaks**: Controllers sem dispose adequado
3. **Queries não Otimizadas**: Pluviômetro carrega dados desnecessários

## 🔄 Transformação de Padrões: Atual vs. SOLID

### GetX Híbrido → Clean Architecture + Provider

#### ❌ ANTES (GetX Híbrido Pattern)
```dart
// plans/app-agrihurbi/controllers/enhanced_bovinos_controller.dart
// Violação: Mistura UI state, business logic e data access
class EnhancedBovinosController extends GetxController {
  late final UnifiedDataService _dataService;
  final RxBool isPageLoading = false.obs;
  final Rx<BovinoClass?> selectedBovino = Rx<BovinoClass?>(null);
  
  List<BovinoClass> get bovinos => _dataService.bovinos;
  
  Future<void> loadBovinos() async {
    isPageLoading.value = true;
    // Business logic + Data access + UI state mixed
    final result = await _repository.getAllBovinos();
    _dataService.updateBovinos(result);
    isPageLoading.value = false;
  }
}
```

#### ✅ DEPOIS (Clean Architecture Pattern)
```dart
// Presentation Layer
class BovinosProvider extends ChangeNotifier {
  final GetBovinosUseCase _getBovinosUseCase;
  
  List<BovinoEntity> _bovinos = [];
  bool _isLoading = false;
  
  Future<void> loadBovinos() async {
    _isLoading = true;
    notifyListeners();
    
    final result = await _getBovinosUseCase();
    result.fold(
      (failure) => _handleFailure(failure),
      (bovinos) => _bovinos = bovinos,
    );
    
    _isLoading = false;
    notifyListeners();
  }
}

// Domain Layer  
class GetBovinosUseCase {
  final BovinoRepository repository;
  
  Future<Either<Failure, List<BovinoEntity>>> call() {
    return repository.getBovinos();
  }
}

// Data Layer
class BovinoRepositoryImpl implements BovinoRepository {
  final BovinoLocalDataSource localDataSource;
  final BovinoRemoteDataSource remoteDataSource;
  
  @override
  Future<Either<Failure, List<BovinoEntity>>> getBovinos() async {
    try {
      final localBovinos = await localDataSource.getAllBovinos();
      return Right(localBovinos.map((model) => model.toEntity()).toList());
    } catch (e) {
      return Left(CacheFailure());
    }
  }
}
```

### Calculadoras Dispersas → Calculator Domain Unificado

#### ❌ ANTES (Calculadoras Dispersas)
```dart
// Cada calculadora como controller separado sem padrão
class NecessidadeHidricaController extends GetxController {
  final _model = NecessidadeHidricaModel();
  final evapotranspiracaoController = TextEditingController();
  final RxBool _calculado = false.obs;
  
  void calcular() {
    // Lógica de cálculo diretamente no controller
    final necessidade = _model.evapotranspiracao * _model.coeficienteCultura;
    // ...
  }
}

class AdubacaoOrganicaController extends GetxController {
  // Código duplicado similar...
}
```

#### ✅ DEPOIS (Calculator Domain Unificado)
```dart
// Domain Layer - Calculator Entity
abstract class CalculatorEntity {
  String get id;
  String get name;
  String get category;
  Map<String, dynamic> get parameters;
  CalculatorResult calculate();
}

// Use Case Genérico
class ExecuteCalculationUseCase {
  final CalculatorRepository repository;
  
  Future<Either<Failure, CalculatorResult>> call(
    String calculatorId,
    Map<String, dynamic> inputs,
  ) {
    return repository.executeCalculation(calculatorId, inputs);
  }
}

// Implementações específicas
class NecessidadeHidricaCalculator extends CalculatorEntity {
  @override
  CalculatorResult calculate() {
    return NecessidadeHidricaResult(
      necessidadeDiaria: evapotranspiracao * coeficienteCultura,
      volumeTotal: necessidadeDiaria * areaPlantada,
    );
  }
}
```

### Pluviometria Monolítica → Weather Domain Modular

#### ❌ ANTES (Sistema Monolítico)
```dart
// Controller gigante com todas responsabilidades
class MedicoesPageController extends GetxController {
  final RxList<Medicoes> medicoes = <Medicoes>[].obs;
  final RxBool isLoading = false.obs;
  final MedicoesRepository _repository = MedicoesRepository();
  
  // UI state + business logic + data management
  void loadMedicoes() async {
    isLoading.value = true;
    final result = await _repository.getAllMedicoes();
    medicoes.assignAll(result);
    calculateStatistics(); // Business logic
    isLoading.value = false;
  }
  
  void calculateStatistics() {
    // Lógica complexa misturada
  }
}
```

#### ✅ DEPOIS (Weather Domain Modular)
```dart
// Domain Layer
class WeatherMeasurement {
  final String id;
  final double rainfall;
  final DateTime timestamp;
  final String stationId;
}

class GetWeatherMeasurementsUseCase {
  final WeatherRepository repository;
  
  Future<Either<Failure, List<WeatherMeasurement>>> call(String stationId) {
    return repository.getMeasurements(stationId);
  }
}

class CalculateWeatherStatisticsUseCase {
  Future<Either<Failure, WeatherStatistics>> call(
    List<WeatherMeasurement> measurements,
  ) {
    // Lógica pura de cálculo
    return Right(WeatherStatistics.fromMeasurements(measurements));
  }
}

// Presentation Layer
class WeatherProvider extends ChangeNotifier {
  final GetWeatherMeasurementsUseCase _getMeasurements;
  final CalculateWeatherStatisticsUseCase _calculateStats;
  
  // Separated concerns
}
```

## 📐 Arquitetura SOLID Proposta

### Estrutura de Diretórios Clean Architecture
```
apps/app-agrihurbi/
├── lib/
│   ├── core/                           # Core utilities e abstrações
│   │   ├── di/
│   │   │   └── injection_container.dart # Dependency Injection
│   │   ├── error/
│   │   │   ├── failures.dart           # Failure types
│   │   │   └── exceptions.dart         # Exception types  
│   │   ├── router/
│   │   │   └── app_router.dart         # GoRouter configuration
│   │   ├── theme/
│   │   │   └── app_theme.dart          # Tema unificado
│   │   └── usecases/
│   │       └── usecase.dart            # Base UseCase
│   ├── features/
│   │   ├── livestock/                  # 🐄 Gestão de Animais
│   │   │   ├── domain/
│   │   │   │   ├── entities/
│   │   │   │   │   ├── bovine_entity.dart
│   │   │   │   │   └── equine_entity.dart
│   │   │   │   ├── repositories/
│   │   │   │   │   └── livestock_repository.dart
│   │   │   │   └── usecases/
│   │   │   │       ├── get_bovines.dart
│   │   │   │       ├── create_bovine.dart
│   │   │   │       └── update_bovine.dart
│   │   │   ├── data/
│   │   │   │   ├── datasources/
│   │   │   │   │   ├── livestock_local_datasource.dart
│   │   │   │   │   └── livestock_remote_datasource.dart
│   │   │   │   ├── models/
│   │   │   │   │   ├── bovine_model.dart
│   │   │   │   │   └── equine_model.dart
│   │   │   │   └── repositories/
│   │   │   │       └── livestock_repository_impl.dart
│   │   │   └── presentation/
│   │   │       ├── providers/
│   │   │       │   ├── bovines_provider.dart
│   │   │       │   └── equines_provider.dart
│   │   │       ├── pages/
│   │   │       │   ├── bovines_list_page.dart
│   │   │       │   ├── bovine_details_page.dart
│   │   │       │   └── bovine_form_page.dart
│   │   │       └── widgets/
│   │   │           ├── bovine_card_widget.dart
│   │   │           └── livestock_form_widget.dart
│   │   ├── agriculture/                # 🌱 Agricultura
│   │   │   ├── domain/
│   │   │   │   ├── entities/
│   │   │   │   │   ├── crop_entity.dart
│   │   │   │   │   ├── implement_entity.dart
│   │   │   │   │   └── pesticide_guide_entity.dart
│   │   │   │   ├── repositories/
│   │   │   │   │   └── agriculture_repository.dart
│   │   │   │   └── usecases/
│   │   │   │       ├── get_crops.dart
│   │   │   │       ├── get_implements.dart
│   │   │   │       └── get_pesticide_guides.dart
│   │   │   ├── data/
│   │   │   └── presentation/
│   │   ├── calculators/                # 🧮 Sistema de Calculadoras
│   │   │   ├── domain/
│   │   │   │   ├── entities/
│   │   │   │   │   ├── calculator_entity.dart
│   │   │   │   │   ├── calculation_result.dart
│   │   │   │   │   └── calculator_category.dart
│   │   │   │   ├── repositories/
│   │   │   │   │   └── calculator_repository.dart
│   │   │   │   └── usecases/
│   │   │   │       ├── get_calculators.dart
│   │   │   │       ├── execute_calculation.dart
│   │   │   │       └── save_calculation_history.dart
│   │   │   ├── data/
│   │   │   │   ├── models/
│   │   │   │   │   ├── irrigation_calculator_model.dart
│   │   │   │   │   ├── nutrition_calculator_model.dart
│   │   │   │   │   └── livestock_calculator_model.dart
│   │   │   │   └── repositories/
│   │   │   │       └── calculator_repository_impl.dart
│   │   │   └── presentation/
│   │   │       ├── providers/
│   │   │       │   ├── calculators_provider.dart
│   │   │       │   └── calculation_history_provider.dart
│   │   │       ├── pages/
│   │   │       │   ├── calculators_overview_page.dart
│   │   │       │   ├── irrigation_calculator_page.dart
│   │   │       │   ├── nutrition_calculator_page.dart
│   │   │       │   └── livestock_calculator_page.dart
│   │   │       └── widgets/
│   │   │           ├── calculator_card_widget.dart
│   │   │           ├── calculation_form_widget.dart
│   │   │           └── result_display_widget.dart
│   │   ├── weather/                    # ⛈️ Sistema Meteorológico
│   │   │   ├── domain/
│   │   │   │   ├── entities/
│   │   │   │   │   ├── rain_gauge_entity.dart
│   │   │   │   │   ├── weather_measurement_entity.dart
│   │   │   │   │   └── weather_statistics_entity.dart
│   │   │   │   ├── repositories/
│   │   │   │   │   └── weather_repository.dart
│   │   │   │   └── usecases/
│   │   │   │       ├── get_rain_gauges.dart
│   │   │   │       ├── create_measurement.dart
│   │   │   │       ├── get_measurements.dart
│   │   │   │       └── calculate_statistics.dart
│   │   │   ├── data/
│   │   │   └── presentation/
│   │   ├── news_and_markets/           # 📰 Notícias e Mercados
│   │   │   ├── domain/
│   │   │   │   ├── entities/
│   │   │   │   │   ├── news_article_entity.dart
│   │   │   │   │   └── commodity_price_entity.dart
│   │   │   │   ├── repositories/
│   │   │   │   │   ├── news_repository.dart
│   │   │   │   │   └── commodity_repository.dart
│   │   │   │   └── usecases/
│   │   │   │       ├── get_agriculture_news.dart
│   │   │   │       ├── get_livestock_news.dart
│   │   │   │       └── get_commodity_prices.dart
│   │   │   ├── data/
│   │   │   └── presentation/
│   │   ├── auth/                       # 🔐 Autenticação
│   │   │   ├── domain/
│   │   │   │   ├── entities/
│   │   │   │   │   └── user_entity.dart
│   │   │   │   ├── repositories/
│   │   │   │   │   └── auth_repository.dart
│   │   │   │   └── usecases/
│   │   │   │       ├── login_user.dart
│   │   │   │       ├── register_user.dart
│   │   │   │       └── logout_user.dart
│   │   │   ├── data/
│   │   │   └── presentation/
│   │   ├── premium/                    # 💎 Sistema Premium
│   │   │   ├── domain/
│   │   │   ├── data/
│   │   │   └── presentation/
│   │   └── settings/                   # ⚙️ Configurações
│   │       ├── domain/
│   │       ├── data/
│   │       └── presentation/
│   └── main.dart
```

### Mapeamento de Dependências por Feature

#### Core Package Integration
```yaml
# pubspec.yaml
dependencies:
  # Core package do monorepo
  core:
    path: ../../packages/core
    
  # State management
  provider: ^6.1.1
  riverpod: ^2.4.9
  
  # Navigation  
  go_router: ^12.1.3
  
  # Dependency Injection
  get_it: ^7.6.4
  injectable: ^2.3.2
```

#### Uso dos Core Services
```dart
// Usar services do core package
import 'package:core/services/hive_storage_service.dart';
import 'package:core/services/firebase_auth_service.dart';
import 'package:core/services/revenue_cat_service.dart';
import 'package:core/services/firebase_analytics_service.dart';
```

## 🗂️ Mapeamento de Migração por Domínio

### 1. 🐄 Livestock (Bovinos + Equinos)

#### Migração de Entidades
```dart
// ANTES: plans/app-agrihurbi/models/bovino_class.dart
class BovinoClass extends BaseModel {
  String nomeComum;
  String paisOrigem;
  List<String>? imagens;
  String raca;
  String aptidao;
  // Herda de BaseModel com id, createdAt, updatedAt
}

// DEPOIS: apps/app-agrihurbi/lib/features/livestock/domain/entities/bovine_entity.dart
class BovineEntity extends Equatable {
  final String id;
  final String commonName;
  final String countryOfOrigin;
  final List<String> images;
  final String breed;
  final String aptitude;
  final List<String> tags;
  final String breedingSystem;
  final String purpose;
  final DateTime createdAt;
  final DateTime updatedAt;
  
  const BovineEntity({
    required this.id,
    required this.commonName,
    required this.countryOfOrigin,
    this.images = const [],
    required this.breed,
    required this.aptitude,
    this.tags = const [],
    required this.breedingSystem,
    required this.purpose,
    required this.createdAt,
    required this.updatedAt,
  });
  
  @override
  List<Object?> get props => [
    id, commonName, countryOfOrigin, images, breed, 
    aptitude, tags, breedingSystem, purpose, createdAt, updatedAt
  ];
}
```

#### Migração de Repository
```dart
// ANTES: plans/app-agrihurbi/repository/bovinos_repository.dart
class BovinosRepository {
  final Box<BovinoClass> _bovinosBox;
  
  Future<List<BovinoClass>> getAllBovinos() async {
    return _bovinosBox.values.toList();
  }
}

// DEPOIS: Clean Architecture Repository Pattern
// Domain Interface
abstract class LivestockRepository {
  Future<Either<Failure, List<BovineEntity>>> getBovines();
  Future<Either<Failure, Unit>> createBovine(BovineEntity bovine);
  Future<Either<Failure, Unit>> updateBovine(BovineEntity bovine);
  Future<Either<Failure, Unit>> deleteBovine(String id);
}

// Data Implementation
class LivestockRepositoryImpl implements LivestockRepository {
  final LivestockLocalDataSource localDataSource;
  final LivestockRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;
  
  @override
  Future<Either<Failure, List<BovineEntity>>> getBovines() async {
    try {
      final localBovines = await localDataSource.getAllBovines();
      return Right(localBovines.map((model) => model.toEntity()).toList());
    } catch (e) {
      return Left(CacheFailure());
    }
  }
}
```

### 2. 🧮 Calculators (Sistema Unificado)

#### Entidade Base para Calculadoras
```dart
// Nova arquitetura unificada
abstract class CalculatorEntity extends Equatable {
  final String id;
  final String name;
  final String description;
  final CalculatorCategory category;
  final List<CalculatorParameter> parameters;
  
  const CalculatorEntity({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.parameters,
  });
  
  CalculatorResult calculate(Map<String, dynamic> inputs);
}

enum CalculatorCategory {
  irrigation,
  nutrition,
  livestock,
  machinery,
  crops,
  economics,
}

class CalculatorParameter extends Equatable {
  final String key;
  final String name;
  final String unit;
  final ParameterType type;
  final bool required;
  final dynamic defaultValue;
  final List<String>? options; // For dropdown parameters
  
  const CalculatorParameter({
    required this.key,
    required this.name,
    required this.unit,
    required this.type,
    this.required = true,
    this.defaultValue,
    this.options,
  });
  
  @override
  List<Object?> get props => [key, name, unit, type, required, defaultValue, options];
}

enum ParameterType { number, text, dropdown, boolean, date }
```

#### Implementação Específica - Irrigação
```dart
// ANTES: Múltiplos controllers separados
class NecessidadeHidricaController extends GetxController { ... }
class CapacidadeCampoController extends GetxController { ... }

// DEPOIS: Implementação unificada
class IrrigationCalculator extends CalculatorEntity {
  const IrrigationCalculator() : super(
    id: 'irrigation_water_need',
    name: 'Necessidade Hídrica',
    description: 'Calcula a necessidade de água das culturas',
    category: CalculatorCategory.irrigation,
    parameters: [
      CalculatorParameter(
        key: 'evapotranspiration',
        name: 'Evapotranspiração (mm/dia)',
        unit: 'mm/dia',
        type: ParameterType.number,
      ),
      CalculatorParameter(
        key: 'crop_coefficient',
        name: 'Coeficiente da Cultura',
        unit: '',
        type: ParameterType.number,
      ),
      CalculatorParameter(
        key: 'planted_area',
        name: 'Área Plantada',
        unit: 'ha',
        type: ParameterType.number,
      ),
    ],
  );
  
  @override
  CalculatorResult calculate(Map<String, dynamic> inputs) {
    final evapotranspiration = inputs['evapotranspiration'] as double;
    final cropCoefficient = inputs['crop_coefficient'] as double;
    final plantedArea = inputs['planted_area'] as double;
    
    final dailyNeed = evapotranspiration * cropCoefficient;
    final totalVolume = dailyNeed * plantedArea;
    
    return IrrigationCalculatorResult(
      dailyWaterNeed: dailyNeed,
      totalVolume: totalVolume,
      irrigationTime: totalVolume / 10, // Exemplo
    );
  }
}
```

### 3. ⛈️ Weather (Sistema Meteorológico)

#### Migração de Entidades
```dart
// ANTES: plans/app-agrihurbi/models/pluviometros_models.dart
@HiveType(typeId: 31)
class Pluviometro extends HiveObject {
  @HiveField(0)
  String? id;
  @HiveField(1)
  String? nome;
  @HiveField(2)
  String? descricao;
  // ...
}

// DEPOIS: Clean Entity
class RainGaugeEntity extends Equatable {
  final String id;
  final String name;
  final String description;
  final GeoLocation location;
  final DateTime installationDate;
  final RainGaugeStatus status;
  final String? notes;
  
  const RainGaugeEntity({
    required this.id,
    required this.name,
    required this.description,
    required this.location,
    required this.installationDate,
    required this.status,
    this.notes,
  });
  
  @override
  List<Object?> get props => [
    id, name, description, location, installationDate, status, notes
  ];
}

class GeoLocation extends Equatable {
  final double latitude;
  final double longitude;
  final double? altitude;
  
  const GeoLocation({
    required this.latitude,
    required this.longitude,
    this.altitude,
  });
  
  @override
  List<Object?> get props => [latitude, longitude, altitude];
}

enum RainGaugeStatus { active, inactive, maintenance }
```

#### Use Cases do Weather Domain
```dart
class GetRainGaugesUseCase {
  final WeatherRepository repository;
  
  const GetRainGaugesUseCase(this.repository);
  
  Future<Either<Failure, List<RainGaugeEntity>>> call() async {
    return await repository.getRainGauges();
  }
}

class CreateWeatherMeasurementUseCase {
  final WeatherRepository repository;
  
  const CreateWeatherMeasurementUseCase(this.repository);
  
  Future<Either<Failure, Unit>> call(CreateMeasurementParams params) async {
    return await repository.createMeasurement(params.toEntity());
  }
}

class CalculateWeatherStatisticsUseCase {
  Future<Either<Failure, WeatherStatistics>> call(
    List<WeatherMeasurementEntity> measurements,
  ) async {
    try {
      final stats = WeatherStatistics.calculate(measurements);
      return Right(stats);
    } catch (e) {
      return Left(CalculationFailure());
    }
  }
}
```

### 4. 📰 News and Markets

#### Integração RSS + Commodities
```dart
// ANTES: plans/app-agrihurbi/services/rss_service.dart
class RSSService {
  final RxList<RssItem> itemsAgricultura = <RssItem>[].obs;
  
  void carregaAgroRSS() async {
    // Lógica RSS direta no service
  }
}

// DEPOIS: Clean Architecture
class GetAgricultureNewsUseCase {
  final NewsRepository repository;
  
  const GetAgricultureNewsUseCase(this.repository);
  
  Future<Either<Failure, List<NewsArticleEntity>>> call() async {
    return await repository.getAgricultureNews();
  }
}

class GetCommodityPricesUseCase {
  final CommodityRepository repository;
  
  const GetCommodityPricesUseCase(this.repository);
  
  Future<Either<Failure, List<CommodityPriceEntity>>> call() async {
    return await repository.getCurrentPrices();
  }
}

// Data Source Implementation
class NewsRemoteDataSourceImpl implements NewsRemoteDataSource {
  final http.Client client;
  final RSSParser rssParser;
  
  @override
  Future<List<NewsArticleModel>> getAgricultureNews() async {
    final response = await client.get(Uri.parse(RSS_AGRICULTURE_URL));
    if (response.statusCode == 200) {
      final feed = rssParser.parse(response.body);
      return feed.items.map((item) => NewsArticleModel.fromRSSItem(item)).toList();
    } else {
      throw ServerException();
    }
  }
}
```

## 🔧 Estratégia de Migração por Fases

### Fase 1: Setup Base e Core Integration (Semana 1-2)
```yaml
Prioridade: CRÍTICA
Duração: 10-14 dias
```

**Objetivos:**
- Criar estrutura Clean Architecture
- Configurar Dependency Injection
- Integrar com packages/core
- Setup da navegação GoRouter
- Configurar tema unificado

**Tasks:**
1. **Criar estrutura de diretórios** conforme arquitetura SOLID
2. **Configurar DI container** com get_it + injectable
3. **Setup core package integration** (Hive, Firebase, RevenueCat)
4. **Implementar GoRouter** substituindo navegação GetX
5. **Migrar tema** de AgrihurbiTheme para sistema unificado
6. **Configurar error handling** com failure types
7. **Setup testing infrastructure** com mocks e fixtures

**Dependências Críticas:**
```yaml
dependencies:
  core:
    path: ../../packages/core
  provider: ^6.1.1
  go_router: ^12.1.3
  get_it: ^7.6.4
  injectable: ^2.3.2
  dartz: ^0.10.1
  equatable: ^2.0.5
```

**Validação:**
- [ ] App inicializa sem GetX
- [ ] Navigation funciona com GoRouter
- [ ] Core services integrados
- [ ] DI container funcionando
- [ ] Tema aplicado consistentemente

### Fase 2: Migração do Livestock Domain (Semana 3-4)
```yaml
Prioridade: ALTA
Duração: 10-14 dias
```

**Objetivos:**
- Migrar bovinos e equinos para Clean Architecture
- Implementar CRUD completo
- Setup Provider state management
- Integrar com core storage

**Tasks:**
1. **Criar entities** (BovineEntity, EquineEntity)
2. **Implementar repositories** (interface + implementation)
3. **Criar use cases** (CRUD operations)
4. **Migrar data sources** (local Hive + remote)
5. **Implementar providers** substituindo GetX controllers
6. **Migrar páginas** para usar providers
7. **Migrar widgets** com keys adequadas
8. **Implementar form validation** centralizada

**Estrutura:**
```
features/livestock/
├── domain/
│   ├── entities/ (bovine_entity.dart, equine_entity.dart)
│   ├── repositories/ (livestock_repository.dart)
│   └── usecases/ (get_bovines.dart, create_bovine.dart, etc.)
├── data/
│   ├── datasources/ (local/remote)
│   ├── models/ (bovine_model.dart)
│   └── repositories/ (livestock_repository_impl.dart)
└── presentation/
    ├── providers/ (bovines_provider.dart)
    ├── pages/ (bovines_list_page.dart, etc.)
    └── widgets/ (bovine_card_widget.dart)
```

**Validação:**
- [ ] CRUD bovinos funcional
- [ ] CRUD equinos funcional
- [ ] Sync local/remote
- [ ] Form validation ativa
- [ ] Provider state management

### Fase 3: Migração do Calculator Domain (Semana 5-7)
```yaml
Prioridade: ALTA
Duração: 18-21 dias
```

**Objetivos:**
- Unificar 20+ calculadoras em sistema único
- Implementar calculator engine flexível
- Migrar todas as calculadoras existentes
- Setup calculation history

**Tasks:**
1. **Criar base calculator entity** abstrata
2. **Implementar calculator engine** genérico
3. **Migrar calculadoras de irrigação** (5 calculadoras)
4. **Migrar calculadoras de nutrição** (4 calculadoras)
5. **Migrar calculadoras de pecuária** (2 calculadoras)
6. **Migrar calculadoras de rendimento** (4 calculadoras)
7. **Migrar calculadoras de maquinário** (3 calculadoras)
8. **Implementar calculation history** e persistence
9. **Criar UI genérica** para calculadoras
10. **Setup category navigation**

**Calculadoras por Categoria:**
- **Irrigação**: Necessidade Hídrica, Dimensionamento, Evapotranspiração, Capacidade Campo, Tempo Irrigação
- **Nutrição**: Adubação Orgânica, Correção Acidez, Micronutrientes, NPK
- **Pecuária**: Aproveitamento Carcaça, Loteamento Bovino
- **Rendimento**: Cereais, Grãos, Leguminosas, Previsão
- **Maquinário**: Consumo, Patinamento, Velocidade
- **Culturas**: Rotação, Semeadura, Fruticultura
- **Manejo**: Diluição Defensivos, Nível Dano Econômico

**Validação:**
- [ ] Todas 20+ calculadoras migradas
- [ ] Calculator engine funcional
- [ ] History persistence ativa
- [ ] Category navigation
- [ ] Results display consistent

### Fase 4: Migração do Weather Domain (Semana 8-9)
```yaml
Prioridade: ALTA
Duração: 12-14 dias
```

**Objetivos:**
- Migrar sistema completo de pluviometria
- Implementar statistics calculation
- Setup chart visualization
- Migrar measurement recording

**Tasks:**
1. **Criar weather entities** (RainGauge, Measurement, Statistics)
2. **Implementar weather repository** com cache strategy
3. **Migrar pluviometer management** (CRUD)
4. **Migrar measurement recording** com validation
5. **Implementar statistics calculation** (mensal/anual)
6. **Setup chart visualization** com fl_chart
7. **Migrar results page** com statistics
8. **Implement export functionality**

**Validação:**
- [ ] Pluviometer CRUD funcional
- [ ] Measurement recording ativo
- [ ] Statistics calculation correta
- [ ] Charts renderizando
- [ ] Export funcionando

### Fase 5: News, Markets e Remaining Features (Semana 10-11)
```yaml
Prioridade: MÉDIA
Duração: 10-14 dias
```

**Objetivos:**
- Migrar RSS news system
- Integrar commodity prices
- Migrar auth system
- Setup premium features
- Migrar settings

**Tasks:**
1. **Migrar RSS news** para clean architecture
2. **Integrar commodity prices** (CEPEA)
3. **Migrar auth system** usando core services
4. **Setup premium features** com RevenueCat core
5. **Migrar settings page** com preferences
6. **Implement agriculture/livestock** specific pages
7. **Setup weather integration**

**Validação:**
- [ ] RSS news funcionando
- [ ] Commodity prices atualizados
- [ ] Auth integrado com core
- [ ] Premium features ativas
- [ ] Settings persistentes

### Fase 6: Otimização e Polimento (Semana 12)
```yaml
Prioridade: MÉDIA
Duração: 5-7 dias
```

**Objetivos:**
- Performance optimization
- UI/UX polishing
- Testing coverage
- Documentation

**Tasks:**
1. **Performance audit** e otimizações
2. **UI polish** e responsive design
3. **Test coverage** increase (>80%)
4. **Documentation** update
5. **Code review** e cleanup
6. **Analytics setup** com Firebase

**Validação:**
- [ ] Performance targets atingidos
- [ ] UI responsiva completa
- [ ] Test coverage >80%
- [ ] Documentation atualizada

## 📊 Mapeamento de Dependências Críticas

### Package Dependencies
```yaml
# pubspec.yaml - App AgriHurbi
name: app_agrihurbi
version: 1.0.0+1

dependencies:
  flutter:
    sdk: flutter
    
  # Core monorepo package
  core:
    path: ../../packages/core
    
  # State Management
  provider: ^6.1.1
  riverpod: ^2.4.9          # Para features específicas se necessário
  
  # Architecture
  dartz: ^0.10.1            # Either/Option functional programming
  equatable: ^2.0.5         # Entity equality
  
  # Dependency Injection  
  get_it: ^7.6.4           # Service locator
  injectable: ^2.3.2        # Code generation para DI
  
  # Navigation
  go_router: ^12.1.3        # Substitui GetX navigation
  
  # Data & Storage
  hive: ^2.2.3             # Via core package
  hive_flutter: ^1.1.0     # Via core package
  
  # Network
  dio: ^5.3.3              # HTTP client
  connectivity_plus: ^5.0.2
  
  # UI & Charts
  fl_chart: ^0.65.0        # Charts para weather statistics
  cached_network_image: ^3.3.0
  image_picker: ^1.0.4     # Image handling
  
  # Utils
  intl: ^0.18.1            # Date formatting
  url_launcher: ^6.2.1     # External links
  share_plus: ^7.2.1       # Share functionality
  
  # RSS & External Data
  webfeed: ^0.7.0          # RSS parsing
  xml: ^6.4.2              # XML parsing
  
dev_dependencies:
  flutter_test:
    sdk: flutter
    
  # Code Generation
  injectable_generator: ^2.4.1
  hive_generator: ^2.0.1
  build_runner: ^2.4.7
  
  # Testing
  mockito: ^5.4.2
  bloc_test: ^9.1.5
  
  # Linting
  flutter_lints: ^3.0.1
```

### Core Services Integration
```dart
// lib/core/di/injection_container.dart
import 'package:core/services/hive_storage_service.dart';
import 'package:core/services/firebase_auth_service.dart';
import 'package:core/services/revenue_cat_service.dart';
import 'package:core/services/firebase_analytics_service.dart';

@InjectableInit()
void configureDependencies() => getIt.init();

@module
abstract class CoreServicesModule {
  @singleton
  HiveStorageService get hiveService => HiveStorageService();
  
  @singleton  
  FirebaseAuthService get authService => FirebaseAuthService();
  
  @singleton
  RevenueCatService get premiumService => RevenueCatService();
  
  @singleton
  FirebaseAnalyticsService get analyticsService => FirebaseAnalyticsService();
}
```

### Repository Dependencies Map
```dart
// Livestock Repository Dependencies
class LivestockRepositoryImpl implements LivestockRepository {
  final HiveStorageService _hiveService;      // Via core package
  final FirebaseFirestore _firestore;        // Via core package  
  final NetworkInfo _networkInfo;            // Local implementation
  final ImageUploadService _imageService;    // Local implementation
}

// Calculator Repository Dependencies  
class CalculatorRepositoryImpl implements CalculatorRepository {
  final HiveStorageService _hiveService;      // Via core package
  final CalculatorEngine _calculatorEngine;  // Local implementation
  final CalculationCache _cache;             // Local implementation
}

// Weather Repository Dependencies
class WeatherRepositoryImpl implements WeatherRepository {
  final HiveStorageService _hiveService;      // Via core package
  final WeatherApiService _apiService;       // Local implementation
  final StatisticsCalculator _calculator;    // Local implementation
}

// News Repository Dependencies
class NewsRepositoryImpl implements NewsRepository {
  final http.Client _httpClient;             // Standard package
  final RSSParser _rssParser;               // Local implementation
  final NewsCache _cache;                   // Local implementation
}
```

## 🔒 Configuração de Segurança e Compliance

### Authentication Integration
```dart
// Usar core FirebaseAuthService
class AuthRepositoryImpl implements AuthRepository {
  final FirebaseAuthService _coreAuthService;
  final HiveStorageService _storage;
  
  @override
  Future<Either<Failure, UserEntity>> loginWithEmailPassword(
    String email, 
    String password,
  ) async {
    try {
      final authResult = await _coreAuthService.signInWithEmailAndPassword(
        email: email, 
        password: password,
      );
      
      final user = UserEntity.fromFirebaseUser(authResult.user!);
      await _storage.saveUserData(user.toModel());
      
      return Right(user);
    } catch (e) {
      return Left(AuthFailure(e.toString()));
    }
  }
}
```

### Premium Features Integration  
```dart
// Usar core RevenueCatService
class PremiumRepositoryImpl implements PremiumRepository {
  final RevenueCatService _revenueCatService;
  
  @override
  Future<Either<Failure, bool>> checkPremiumStatus() async {
    try {
      final isPremium = await _revenueCatService.isPremiumUser();
      return Right(isPremium);
    } catch (e) {
      return Left(PremiumCheckFailure());
    }
  }
  
  @override
  Future<Either<Failure, Unit>> purchasePremium() async {
    try {
      await _revenueCatService.purchasePremium();
      return const Right(unit);
    } catch (e) {
      return Left(PurchaseFailure());
    }
  }
}
```

### Data Security Best Practices
```dart
// Encryption para dados sensíveis
class SecureDataManager {
  final HiveStorageService _hiveService;
  final EncryptionService _encryption;
  
  Future<void> saveSensitiveData(String key, dynamic data) async {
    final encryptedData = await _encryption.encrypt(jsonEncode(data));
    await _hiveService.saveData(key, encryptedData);
  }
  
  Future<T?> getSensitiveData<T>(String key, T Function(Map<String, dynamic>) fromJson) async {
    final encryptedData = await _hiveService.getData(key);
    if (encryptedData != null) {
      final decryptedData = await _encryption.decrypt(encryptedData);
      final json = jsonDecode(decryptedData) as Map<String, dynamic>;
      return fromJson(json);
    }
    return null;
  }
}
```

## 📈 Estratégia de Testing

### Unit Testing Structure
```dart
// test/features/livestock/domain/usecases/get_bovines_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:dartz/dartz.dart';

class MockLivestockRepository extends Mock implements LivestockRepository {}

void main() {
  late GetBovinesUseCase useCase;
  late MockLivestockRepository mockRepository;
  
  setUp(() {
    mockRepository = MockLivestockRepository();
    useCase = GetBovinesUseCase(mockRepository);
  });
  
  group('GetBovinesUseCase', () {
    final tBovines = [
      const BovineEntity(
        id: '1',
        commonName: 'Nelore',
        breed: 'Nelore',
        // ... outros campos
      ),
    ];
    
    test('should get bovines from repository', () async {
      // arrange
      when(mockRepository.getBovines())
          .thenAnswer((_) async => Right(tBovines));
      
      // act
      final result = await useCase();
      
      // assert
      expect(result, Right(tBovines));
      verify(mockRepository.getBovines());
      verifyNoMoreInteractions(mockRepository);
    });
  });
}
```

### Widget Testing Examples
```dart
// test/features/livestock/presentation/widgets/bovine_card_widget_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

void main() {
  group('BovineCardWidget', () {
    late BovineEntity testBovine;
    
    setUp(() {
      testBovine = const BovineEntity(
        id: '1',
        commonName: 'Test Bovine',
        breed: 'Test Breed',
        // ... campos obrigatórios
      );
    });
    
    testWidgets('should display bovine information', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: BovineCardWidget(bovine: testBovine),
        ),
      );
      
      expect(find.text('Test Bovine'), findsOneWidget);
      expect(find.text('Test Breed'), findsOneWidget);
    });
  });
}
```

### Integration Testing
```dart
// integration_test/livestock_flow_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  
  group('Livestock Management Flow', () {
    testWidgets('should create, edit and delete bovine', (tester) async {
      // Test complete CRUD flow
      // 1. Navigate to bovines list
      // 2. Create new bovine
      // 3. Edit bovine
      // 4. Delete bovine
      // 5. Verify persistence
    });
  });
}
```

## 🚀 Performance e Otimização

### Lazy Loading Implementation
```dart
// Paginação para listas grandes
class BovinesProvider extends ChangeNotifier {
  List<BovineEntity> _bovines = [];
  bool _isLoading = false;
  bool _hasMore = true;
  int _currentPage = 0;
  static const int _pageSize = 20;
  
  Future<void> loadMoreBovines() async {
    if (_isLoading || !_hasMore) return;
    
    _isLoading = true;
    notifyListeners();
    
    final result = await _getBovinesUseCase(
      PaginationParams(page: _currentPage, pageSize: _pageSize),
    );
    
    result.fold(
      (failure) => _handleFailure(failure),
      (newBovines) {
        if (newBovines.length < _pageSize) {
          _hasMore = false;
        }
        _bovines.addAll(newBovines);
        _currentPage++;
      },
    );
    
    _isLoading = false;
    notifyListeners();
  }
}
```

### Image Optimization
```dart
class ImageOptimizationService {
  Future<File> optimizeImage(File imageFile) async {
    final bytes = await imageFile.readAsBytes();
    final image = img.decodeImage(bytes);
    
    // Resize para máximo 1024x1024
    final resized = img.copyResize(
      image!,
      width: math.min(image.width, 1024),
      height: math.min(image.height, 1024),
    );
    
    // Comprimir com qualidade 85%
    final compressed = img.encodeJpg(resized, quality: 85);
    
    final optimizedFile = File('${imageFile.path}_optimized.jpg');
    await optimizedFile.writeAsBytes(compressed);
    
    return optimizedFile;
  }
}
```

### Memory Management
```dart
class MemoryOptimizedProvider extends ChangeNotifier {
  StreamSubscription? _dataSubscription;
  Timer? _cacheCleanupTimer;
  
  @override
  void dispose() {
    _dataSubscription?.cancel();
    _cacheCleanupTimer?.cancel();
    super.dispose();
  }
  
  void _setupCacheCleanup() {
    _cacheCleanupTimer = Timer.periodic(
      const Duration(minutes: 30),
      (_) => _cleanupCache(),
    );
  }
  
  void _cleanupCache() {
    // Remove dados antigos do cache
    final cutoff = DateTime.now().subtract(const Duration(hours: 2));
    _cache.removeWhere((key, value) => value.timestamp.isBefore(cutoff));
  }
}
```

## 📱 UI/UX e Responsividade

### Responsive Layout System
```dart
class ResponsiveLayoutBuilder extends StatelessWidget {
  final Widget mobile;
  final Widget tablet;
  final Widget desktop;
  
  const ResponsiveLayoutBuilder({
    super.key,
    required this.mobile,
    required this.tablet,
    required this.desktop,
  });
  
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 768) {
          return mobile;
        } else if (constraints.maxWidth < 1200) {
          return tablet;
        } else {
          return desktop;
        }
      },
    );
  }
}

// Uso nas páginas
class BovinesListPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ResponsiveLayoutBuilder(
      mobile: const BovinesListMobileView(),
      tablet: const BovinesListTabletView(),
      desktop: const BovinesListDesktopView(),
    );
  }
}
```

### Consistent Theme System
```dart
// lib/core/theme/app_theme.dart
class AppTheme {
  static const Color primaryGreen = Color(0xFF2E7D32);
  static const Color secondaryGreen = Color(0xFF4CAF50);
  static const Color accentGreen = Color(0xFF81C784);
  
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryGreen,
      brightness: Brightness.light,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: primaryGreen,
      foregroundColor: Colors.white,
      elevation: 2,
    ),
    cardTheme: CardTheme(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 12,
      ),
    ),
  );
}
```

### Animation System
```dart
class AgriHurbiAnimations {
  static const Duration fastDuration = Duration(milliseconds: 200);
  static const Duration normalDuration = Duration(milliseconds: 300);
  static const Duration slowDuration = Duration(milliseconds: 500);
  
  static Animation<double> createFadeIn(AnimationController controller) {
    return Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: controller, curve: Curves.easeIn),
    );
  }
  
  static Animation<Offset> createSlideIn(AnimationController controller) {
    return Tween<Offset>(
      begin: const Offset(1.0, 0.0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: controller, curve: Curves.easeInOut),
    );
  }
}
```

## 🔧 Ferramentas de Desenvolvimento

### Build Scripts
```bash
#!/bin/bash
# scripts/build_agrihurbi.sh

echo "🌾 Building App AgriHurbi..."

# Clean
flutter clean

# Get dependencies
flutter pub get

# Generate code
flutter packages pub run build_runner build --delete-conflicting-outputs

# Build APK
flutter build apk --release --target-platform android-arm64

# Build iOS (if on macOS)
if [[ "$OSTYPE" == "darwin"* ]]; then
    flutter build ios --release --no-codesign
fi

echo "✅ Build completed!"
```

### Code Generation Commands
```bash
# Generate dependency injection
flutter packages pub run build_runner build --delete-conflicting-outputs

# Generate Hive adapters  
flutter packages pub run build_runner build --target hive_generator

# Generate mocks for testing
flutter packages pub run build_runner build --target mockito
```

## 📚 Documentação e Guias

### Developer Onboarding
```markdown
# AgriHurbi Development Guide

## Getting Started
1. Clone monorepo
2. Run `cd apps/app-agrihurbi`
3. Run `flutter pub get`
4. Run `flutter packages pub run build_runner build`
5. Setup Firebase config
6. Run `flutter run`

## Architecture Overview
- Clean Architecture com Provider
- Feature-based organization
- Core package integration
- SOLID principles

## Adding New Features
1. Create feature folder in `lib/features/`
2. Implement domain layer (entities, repositories, use cases)
3. Implement data layer (models, data sources, repository impl)
4. Implement presentation layer (providers, pages, widgets)
5. Add tests
6. Update documentation
```

### API Documentation
```dart
/// AgriHurbi Calculator API
/// 
/// Provides unified interface for agricultural calculations
/// 
/// Example:
/// ```dart
/// final calculator = IrrigationCalculator();
/// final result = calculator.calculate({
///   'evapotranspiration': 5.0,
///   'crop_coefficient': 1.2,
///   'planted_area': 10.0,
/// });
/// ```
class CalculatorAPI {
  /// Execute calculation with given parameters
  Future<CalculatorResult> calculate(
    String calculatorId,
    Map<String, dynamic> parameters,
  );
  
  /// Get available calculators by category
  List<CalculatorEntity> getCalculatorsByCategory(CalculatorCategory category);
  
  /// Get calculation history for user
  Future<List<CalculationHistoryEntity>> getCalculationHistory();
}
```

## ⚡ Comandos Rápidos de Migração

### Scaffold New Feature
```bash
# Criar estrutura para nova feature
./scripts/create_feature.sh livestock

# Gerar boilerplate code
./scripts/generate_boilerplate.sh livestock BovineEntity

# Run tests
flutter test test/features/livestock/

# Generate coverage
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
```

### Migration Checklist
```markdown
## Pre-Migration Checklist
- [ ] Backup current plans/app-agrihurbi
- [ ] Setup Clean Architecture structure
- [ ] Configure core package integration
- [ ] Setup DI container
- [ ] Configure GoRouter

## Per-Feature Migration Checklist  
- [ ] Create domain entities
- [ ] Implement repository interfaces
- [ ] Create use cases
- [ ] Implement data sources
- [ ] Create repository implementations
- [ ] Implement providers
- [ ] Migrate pages and widgets
- [ ] Add tests
- [ ] Update navigation
- [ ] Verify functionality

## Post-Migration Checklist
- [ ] Performance audit
- [ ] Security review
- [ ] Test coverage >80%
- [ ] Documentation update
- [ ] Code review
- [ ] Deploy validation
```

---

## 🎯 Cronograma Resumido

| Fase | Duração | Foco Principal | Entregáveis |
|------|---------|----------------|-------------|
| **Fase 1** | 2 semanas | Setup & Core | Estrutura SOLID + DI + Core Integration |
| **Fase 2** | 2 semanas | Livestock | Domain Bovinos/Equinos completo |
| **Fase 3** | 3 semanas | Calculators | 20+ calculadoras unificadas |
| **Fase 4** | 2 semanas | Weather | Sistema meteorológico completo |
| **Fase 5** | 2 semanas | News & Others | RSS, Auth, Premium, Settings |
| **Fase 6** | 1 semana | Polish | Otimização, testes, documentação |

**Total: 12 semanas (3 meses)**

## 🚨 Riscos e Mitigação

### Riscos Técnicos
1. **Complexidade das Calculadoras**: 20+ calculadoras com lógicas diferentes
   - **Mitigação**: Implementar base unificada primeiro, migrar gradualmente
   
2. **Data Migration**: Dados Hive existentes podem ser incompatíveis
   - **Mitigação**: Criar migration scripts, manter backward compatibility
   
3. **Performance**: Sistema grande pode ter performance issues
   - **Mitigação**: Lazy loading, pagination, cache strategy

### Riscos de Escopo
1. **Feature Creep**: Tentação de adicionar features durante migração
   - **Mitigação**: Foco estrito em migração, features novas pós-migração
   
2. **Timeline**: 12 semanas é agressivo para projeto dessa magnitude
   - **Mitigação**: Priorização clara, MVP primeiro, polish depois

## 💡 Recomendações Finais

1. **Priorize MVP**: Migre funcionalidades core primeiro, polish depois
2. **Mantenha Funcionalidade**: Usuários não devem notar diferença inicial
3. **Teste Continuamente**: Cada fase deve ser testada antes da próxima
4. **Documente Decisões**: Registre escolhas arquiteturais para futuro
5. **Performance First**: Monitor performance desde fase 1
6. **User Feedback**: Colete feedback assim que possível

**AgriHurbi** representa um dos maiores desafios de migração do monorepo devido ao seu tamanho (856 arquivos Dart) e complexidade (20+ calculadoras especializadas). A abordagem por fases garante que o risco seja gerenciado e a funcionalidade mantida durante todo o processo.

A arquitetura Clean + Provider proporcionará melhor testabilidade, manutenibilidade e escalabilidade para futuras features agropecuárias.
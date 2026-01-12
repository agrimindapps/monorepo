# 🦟 Controle de Pragas e Doenças (Pest & Disease Control)

**ID**: AGR-012  
**Prioridade**: 🔴 Alta  
**Estimativa**: 3-4 semanas  
**Status**: 📝 Planejamento  
**Criado**: 2026-01-12  
**Atualizado**: 2026-01-12  

---

## 📖 Visão Geral

### O que é?
O **Controle de Pragas e Doenças** é uma ferramenta para monitorar e gerenciar problemas fitossanitários na propriedade. Permite registrar ocorrências, avaliar severidade, acompanhar tratamentos e analisar a eficácia das medidas de controle.

### Por que implementar?
1. **Redução de Perdas** - Pragas/doenças podem causar perdas de 20-80% da produção
2. **MIP (Manejo Integrado)** - Reduzir uso de agrotóxicos com estratégias integradas
3. **Rastreabilidade** - Registrar defensivos aplicados (exigência legal)
4. **Tomada de Decisão** - Dados históricos para escolher melhores estratégias
5. **Compliance** - Atender receituário agronômico e rastreabilidade
6. **Economia** - Aplicar apenas quando necessário (nível de dano econômico)

### Benchmark
- **Strider** - App brasileiro focado em MIP (líder no segmento)
- **Cropwise** - Syngenta (monitoramento + IA para identificação)
- **Taranis** - Imagens aéreas + IA para detecção
- **Agrivi** - Gestão agrícola com módulo de pragas

### Conceitos Fundamentais

#### Manejo Integrado de Pragas (MIP)
- Combinação de métodos (cultural, biológico, químico)
- Preservação de inimigos naturais
- Monitoramento constante
- Intervenção apenas quando necessário

#### Nível de Dano Econômico (NDE)
- População de pragas que causa dano = custo de controle
- Varia por cultura, estágio fenológico e valor da produção
- Base para decisão de aplicação

#### Nível de Controle (NC)
- População abaixo do NDE
- Momento ideal para intervir
- Geralmente 70-80% do NDE

---

## 🎯 Objetivos

### Objetivos de Negócio
- [ ] Reduzir perdas por pragas/doenças em 30%
- [ ] Reduzir custos com defensivos em 20% (aplicações mais assertivas)
- [ ] Melhorar rastreabilidade (compliance)
- [ ] Gerar relatórios para certificações
- [ ] Diferencial competitivo no mercado

### Objetivos Técnicos
- [ ] Seguir padrão Clean Architecture (igual Pluviometer)
- [ ] 100% Riverpod code generation
- [ ] Drift para persistência local
- [ ] Firebase ready para sincronização
- [ ] Offline-first (essencial no campo)
- [ ] Banco de imagens local (identificação)

---

## 🏗️ Arquitetura Proposta

### Estrutura de Pastas
```
lib/features/pest_disease_control/
├── data/
│   ├── datasources/
│   │   ├── pest_disease_local_datasource.dart
│   │   └── pest_disease_catalog_datasource.dart
│   ├── models/
│   │   ├── pest_occurrence_model.dart
│   │   ├── control_action_model.dart
│   │   ├── pest_catalog_model.dart
│   │   └── monitoring_schedule_model.dart
│   └── repositories/
│       └── pest_disease_repository_impl.dart
├── domain/
│   ├── entities/
│   │   ├── pest_occurrence_entity.dart
│   │   ├── control_action_entity.dart
│   │   ├── pest_catalog_entity.dart
│   │   ├── monitoring_schedule_entity.dart
│   │   └── enums/
│   │       ├── pest_type.dart
│   │       ├── severity_level.dart
│   │       ├── control_method.dart
│   │       ├── crop_stage.dart
│   │       └── efficacy_rating.dart
│   ├── repositories/
│   │   └── pest_disease_repository.dart
│   └── usecases/
│       ├── occurrences/
│       │   ├── register_occurrence.dart
│       │   ├── update_occurrence.dart
│       │   ├── delete_occurrence.dart
│       │   ├── get_occurrences.dart
│       │   └── get_occurrence_by_id.dart
│       ├── control/
│       │   ├── register_control_action.dart
│       │   ├── evaluate_efficacy.dart
│       │   ├── get_control_history.dart
│       │   └── suggest_control_method.dart
│       ├── monitoring/
│       │   ├── create_monitoring_schedule.dart
│       │   ├── get_monitoring_alerts.dart
│       │   └── complete_monitoring.dart
│       ├── catalog/
│       │   ├── search_pest_catalog.dart
│       │   ├── get_pest_by_id.dart
│       │   └── get_control_recommendations.dart
│       ├── analytics/
│       │   ├── get_pest_statistics.dart
│       │   ├── analyze_efficacy.dart
│       │   ├── predict_outbreaks.dart
│       │   └── calculate_economic_impact.dart
│       └── reports/
│           ├── export_spray_log.dart
│           ├── export_traceability_report.dart
│           └── export_efficacy_report.dart
└── presentation/
    ├── providers/
    │   ├── pest_disease_provider.dart
    │   └── pest_disease_provider.g.dart
    ├── pages/
    │   ├── pest_control_home_page.dart
    │   ├── occurrences_list_page.dart
    │   ├── occurrence_detail_page.dart
    │   ├── occurrence_form_page.dart
    │   ├── control_action_form_page.dart
    │   ├── pest_catalog_page.dart
    │   ├── pest_detail_page.dart
    │   ├── monitoring_calendar_page.dart
    │   ├── efficacy_analysis_page.dart
    │   └── spray_log_page.dart
    └── widgets/
        ├── occurrence_card.dart
        ├── severity_indicator.dart
        ├── pest_identifier_widget.dart
        ├── control_method_selector.dart
        ├── efficacy_gauge.dart
        ├── monitoring_alert_card.dart
        ├── pest_timeline.dart
        └── economic_impact_chart.dart
```

---

## 📊 Modelo de Dados

### 1. PestOccurrenceEntity (Ocorrência de Praga/Doença)
```dart
/// Representa uma ocorrência de praga ou doença detectada
class PestOccurrenceEntity extends Equatable {
  final String id;                    // UUID
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final bool isActive;                // Soft delete
  
  // Relacionamentos
  final String? fieldId;              // FK → Field (Caderno de Campo)
  final String? cropId;               // FK → Crop
  
  // Identificação do problema
  final PestType pestType;            // Tipo (inseto, fungo, vírus, etc)
  final String? pestCatalogId;        // FK → PestCatalog (se identificado)
  final String commonName;            // Nome comum
  final String? scientificName;       // Nome científico
  
  // Detecção
  final DateTime detectionDate;       // Data de detecção
  final String? detectedBy;           // Quem detectou
  final CropStage cropStage;          // Estágio fenológico da cultura
  
  // Severidade
  final SeverityLevel severity;       // Baixa, média, alta, crítica
  final double? affectedAreaHa;       // Área afetada (ha)
  final double? affectedPercent;      // % da área total afetada
  final double? populationDensity;    // Densidade populacional (ex: lagartas/m²)
  final String? damageDescription;    // Descrição do dano observado
  
  // Localização
  final String? latitude;
  final String? longitude;
  final String? locationDescription;  // "Bordadura leste", "Reboleira central"
  
  // Condições favoráveis
  final String? weatherConditions;    // Clima no momento
  final double? temperature;          // Temperatura (°C)
  final double? humidity;             // Umidade (%)
  final bool hadRecentRain;           // Choveu recentemente?
  
  // Status
  final OccurrenceStatus status;      // Ativo, controlado, resolvido
  final DateTime? resolvedDate;       // Data de resolução
  
  // Observações
  final String? observations;
  
  // Mídia
  final List<String>? photoUrls;      // Fotos da ocorrência
  final List<String>? videoUrls;      // Vídeos (opcional)
  
  // Alertas
  final bool isAboveThreshold;        // Acima do NC?
  final bool requiresImmediate Action; // Requer ação imediata?
  
  // Sync
  final String? objectId;
  
  // Computed
  int get daysSinceDetection;
  bool get isControlled;
  double get economicImpact;          // Calculado
}

enum PestType {
  insect,         // Inseto (lagartas, percevejos, etc)
  mite,           // Ácaro
  fungus,         // Fungo
  bacteria,       // Bactéria
  virus,          // Vírus
  nematode,       // Nematoide
  weed,           // Planta daninha
  rodent,         // Roedor
  bird,           // Ave
  other           // Outro
}

enum SeverityLevel {
  low,            // Baixa - Abaixo do NC
  medium,         // Média - Próximo ao NC
  high,           // Alta - Acima do NC
  critical        // Crítica - Muito acima do NC
}

enum CropStage {
  germination,    // Germinação
  vegetative,     // Vegetativo
  flowering,      // Floração
  fruiting,       // Frutificação
  maturation,     // Maturação
  harvest         // Colheita
}

enum OccurrenceStatus {
  active,         // Ativo (requer monitoramento)
  underControl,   // Sob controle (ação em andamento)
  controlled,     // Controlado (população baixou)
  resolved        // Resolvido (eliminado)
}
```

### 2. ControlActionEntity (Ação de Controle)
```dart
/// Representa uma ação de controle realizada contra praga/doença
class ControlActionEntity extends Equatable {
  final String id;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final bool isActive;
  
  // Relacionamentos
  final String occurrenceId;          // FK → PestOccurrence
  final String? fieldId;              // Denormalizado
  final String? cropId;               // Denormalizado
  
  // Tipo de controle
  final ControlMethod method;         // Químico, biológico, cultural, etc
  final String? methodDescription;
  
  // Execução
  final DateTime applicationDate;     // Data da aplicação
  final DateTime? endDate;            // Data fim (para controles longos)
  final String? executedBy;           // Quem executou
  final String? operatorName;
  final String? machineryUsed;        // Equipamento utilizado
  
  // Produtos utilizados (se químico ou biológico)
  final List<ProductUsage>? products; // Lista de produtos
  
  // Área tratada
  final double? treatedAreaHa;        // Área tratada
  final String? applicationMethod;    // Pulverização, isca, etc
  final double? applicationRate;      // Taxa de aplicação
  
  // Condições de aplicação
  final String? weatherConditions;
  final double? temperature;
  final double? windSpeed;
  final double? humidity;
  
  // Custos
  final double? productsCost;         // Custo produtos
  final double? laborCost;            // Custo mão-de-obra
  final double? machineryCost;        // Custo máquinas
  final double? totalCost;            // Custo total
  
  // Receituário agronômico (se químico)
  final String? agronomistName;
  final String? agronomistCrea;
  final String? prescriptionNumber;
  final DateTime? prescriptionDate;
  
  // Carência
  final int? gracePeroidDays;         // Período de carência (dias)
  final DateTime? safeHarvestDate;    // Data segura para colheita
  
  // Avaliação de eficácia
  final EfficacyRating? efficacy;     // Avaliação pós-aplicação
  final DateTime? efficacyEvalDate;   // Data da avaliação
  final String? efficacyObservations;
  final double? mortalityPercent;     // % de mortalidade da praga
  final double? reductionPercent;     // % de redução populacional
  
  // Observações
  final String? observations;
  
  // Mídia
  final List<String>? photoUrls;
  
  // Sync
  final String? objectId;
  
  // Computed
  int get daysSinceApplication;
  bool get isWithinGracePeriod;
}

enum ControlMethod {
  chemical,       // Químico (defensivos)
  biological,     // Biológico (predadores, parasitoides)
  cultural,       // Cultural (rotação, destruição restos)
  mechanical,     // Mecânico (catação, armadilhas)
  genetic,        // Genético (variedades resistentes)
  behavioral,     // Comportamental (feromônios, atrativos)
  physical,       // Físico (temperatura, radiação)
  integrated      // Integrado (combinação)
}

enum EfficacyRating {
  excellent,      // Excelente (>90% controle)
  good,           // Bom (70-90%)
  regular,        // Regular (50-70%)
  poor,           // Ruim (30-50%)
  ineffective     // Ineficaz (<30%)
}

/// Produto utilizado no controle
class ProductUsage {
  final String productName;           // Nome comercial
  final String? activeIngredient;     // Princípio ativo
  final String? manufacturer;         // Fabricante
  final String category;              // Inseticida, fungicida, etc
  
  final double quantity;              // Quantidade utilizada
  final String unit;                  // Unidade (L, kg, etc)
  final double? dosePerHa;            // Dose por hectare
  
  final double? unitPrice;            // Preço unitário
  final double? totalCost;            // Custo total
  
  final String? batchNumber;          // Lote
  final DateTime? expirationDate;     // Validade
  final String? invoiceNumber;        // NF
}
```

### 3. PestCatalogEntity (Catálogo de Pragas/Doenças)
```dart
/// Catálogo de pragas e doenças com informações técnicas
class PestCatalogEntity extends Equatable {
  final String id;
  final bool isActive;
  
  // Identificação
  final String commonName;            // Nome popular
  final String scientificName;        // Nome científico
  final List<String>? aliases;        // Outros nomes
  final PestType type;                // Tipo
  
  // Classificação
  final String? family;               // Família taxonômica
  final String? order;                // Ordem
  final String? class_;              // Classe
  
  // Hospedeiros
  final List<String> hostCrops;       // Culturas hospedeiras
  final String? preferredHost;        // Hospedeiro preferencial
  
  // Descrição
  final String? description;          // Descrição geral
  final String? lifecycle;            // Ciclo de vida
  final String? symptoms;             // Sintomas do ataque
  final String? identificationTips;   // Dicas de identificação
  
  // Danos
  final String? damageType;           // Tipo de dano
  final SeverityPotential severity;   // Potencial de severidade
  final double? yieldLossPercent;     // Perda potencial (%)
  
  // Condições favoráveis
  final String? favorableConditions;  // Condições que favorecem
  final double? optimalTempMin;       // Temperatura ótima mín
  final double? optimalTempMax;       // Temperatura ótima máx
  final double? optimalHumidity;      // Umidade ótima
  final SeasonOccurrence season;      // Época de ocorrência
  
  // Nível de controle
  final double? economicThreshold;    // NDE (indivíduos/m² ou %)
  final double? actionThreshold;      // NC (indivíduos/m² ou %)
  final String? samplingMethod;       // Método de amostragem
  
  // Controle recomendado
  final List<String> recommendedMethods; // Métodos recomendados
  final String? culturalControl;      // Controle cultural
  final String? biologicalControl;    // Controle biológico
  final List<String>? chemicalOptions;// Opções químicas
  final String? resistanceNotes;      // Notas sobre resistência
  
  // Inimigos naturais
  final List<String>? naturalEnemies; // Predadores/parasitoides
  
  // Mídia
  final List<String>? photoUrls;      // Fotos de identificação
  final String? illustrationUrl;      // Ilustração/desenho
  final String? videoUrl;             // Vídeo educativo
  
  // Referências
  final List<String>? references;     // Referências bibliográficas
  final String? source;               // Fonte da informação
}

enum SeverityPotential {
  low,            // Baixo potencial de dano
  moderate,       // Moderado
  high,           // Alto
  veryHigh        // Muito alto
}

enum SeasonOccurrence {
  yearRound,      // O ano todo
  rainy,          // Estação chuvosa
  dry,            // Estação seca
  spring,         // Primavera
  summer,         // Verão
  autumn,         // Outono
  winter          // Inverno
}
```

### 4. MonitoringScheduleEntity (Agenda de Monitoramento)
```dart
/// Agenda de monitoramento preventivo de pragas
class MonitoringScheduleEntity extends Equatable {
  final String id;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final bool isActive;
  
  // Relacionamentos
  final String? fieldId;
  final String? cropId;
  
  // Planejamento
  final String title;                 // "Monitoramento semanal - Soja"
  final String? description;
  
  // Periodicidade
  final MonitoringFrequency frequency; // Diária, semanal, etc
  final int intervalDays;             // Intervalo em dias
  final DateTime startDate;           // Data início
  final DateTime? endDate;            // Data fim (opcional)
  
  // Alvos de monitoramento
  final List<String> targetPests;     // Pragas-alvo
  final List<String> pointsToInspect; // Pontos de inspeção
  
  // Responsável
  final String? responsiblePerson;
  
  // Alertas
  final bool sendReminders;           // Enviar lembretes?
  final int? reminderDaysBefore;      // Dias antes
  
  // Status
  final bool isCompleted;
  final DateTime? lastMonitoringDate;
  final DateTime? nextMonitoringDate;
  
  // Observações
  final String? observations;
  
  // Sync
  final String? objectId;
}

enum MonitoringFrequency {
  daily,          // Diária
  twiceWeekly,    // 2x por semana
  weekly,         // Semanal
  biweekly,       // Quinzenal
  monthly,        // Mensal
  custom          // Personalizada
}
```

---

## 🗄️ Tabelas Drift (SQLite)

```dart
// lib/database/tables/pest_disease_tables.dart

/// Tabela de Ocorrências de Pragas/Doenças
class PestOccurrences extends Table {
  TextColumn get id => text()();
  DateTimeColumn get createdAt => dateTime().nullable()();
  DateTimeColumn get updatedAt => dateTime().nullable()();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  
  // Relacionamentos
  TextColumn get fieldId => text().nullable()();
  TextColumn get cropId => text().nullable()();
  
  // Identificação
  TextColumn get pestType => text()();
  TextColumn get pestCatalogId => text().nullable()();
  TextColumn get commonName => text()();
  TextColumn get scientificName => text().nullable()();
  
  // Detecção
  DateTimeColumn get detectionDate => dateTime()();
  TextColumn get detectedBy => text().nullable()();
  TextColumn get cropStage => text()();
  
  // Severidade
  TextColumn get severity => text()();
  RealColumn get affectedAreaHa => real().nullable()();
  RealColumn get affectedPercent => real().nullable()();
  RealColumn get populationDensity => real().nullable()();
  TextColumn get damageDescription => text().nullable()();
  
  // Localização
  TextColumn get latitude => text().nullable()();
  TextColumn get longitude => text().nullable()();
  TextColumn get locationDescription => text().nullable()();
  
  // Condições
  TextColumn get weatherConditions => text().nullable()();
  RealColumn get temperature => real().nullable()();
  RealColumn get humidity => real().nullable()();
  BoolColumn get hadRecentRain => boolean().withDefault(const Constant(false))();
  
  // Status
  TextColumn get status => text().withDefault(const Constant('active'))();
  DateTimeColumn get resolvedDate => dateTime().nullable()();
  
  TextColumn get observations => text().nullable()();
  TextColumn get photoUrls => text().nullable()(); // JSON array
  TextColumn get videoUrls => text().nullable()(); // JSON array
  
  BoolColumn get isAboveThreshold => boolean().withDefault(const Constant(false))();
  BoolColumn get requiresImmediateAction => boolean().withDefault(const Constant(false))();
  
  TextColumn get objectId => text().nullable()();
  
  @override
  Set<Column> get primaryKey => {id};
}

/// Tabela de Ações de Controle
class ControlActions extends Table {
  TextColumn get id => text()();
  DateTimeColumn get createdAt => dateTime().nullable()();
  DateTimeColumn get updatedAt => dateTime().nullable()();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  
  // Relacionamentos
  TextColumn get occurrenceId => text().references(PestOccurrences, #id)();
  TextColumn get fieldId => text().nullable()();
  TextColumn get cropId => text().nullable()();
  
  // Tipo
  TextColumn get method => text()();
  TextColumn get methodDescription => text().nullable()();
  
  // Execução
  DateTimeColumn get applicationDate => dateTime()();
  DateTimeColumn get endDate => dateTime().nullable()();
  TextColumn get executedBy => text().nullable()();
  TextColumn get operatorName => text().nullable()();
  TextColumn get machineryUsed => text().nullable()();
  
  // Produtos (JSON)
  TextColumn get products => text().nullable()(); // JSON array of ProductUsage
  
  // Área
  RealColumn get treatedAreaHa => real().nullable()();
  TextColumn get applicationMethod => text().nullable()();
  RealColumn get applicationRate => real().nullable()();
  
  // Condições
  TextColumn get weatherConditions => text().nullable()();
  RealColumn get temperature => real().nullable()();
  RealColumn get windSpeed => real().nullable()();
  RealColumn get humidity => real().nullable()();
  
  // Custos
  RealColumn get productsCost => real().nullable()();
  RealColumn get laborCost => real().nullable()();
  RealColumn get machineryCost => real().nullable()();
  RealColumn get totalCost => real().nullable()();
  
  // Receituário
  TextColumn get agronomistName => text().nullable()();
  TextColumn get agronomistCrea => text().nullable()();
  TextColumn get prescriptionNumber => text().nullable()();
  DateTimeColumn get prescriptionDate => dateTime().nullable()();
  
  // Carência
  IntColumn get gracePeriodDays => integer().nullable()();
  DateTimeColumn get safeHarvestDate => dateTime().nullable()();
  
  // Eficácia
  TextColumn get efficacy => text().nullable()();
  DateTimeColumn get efficacyEvalDate => dateTime().nullable()();
  TextColumn get efficacyObservations => text().nullable()();
  RealColumn get mortalityPercent => real().nullable()();
  RealColumn get reductionPercent => real().nullable()();
  
  TextColumn get observations => text().nullable()();
  TextColumn get photoUrls => text().nullable()(); // JSON array
  
  TextColumn get objectId => text().nullable()();
  
  @override
  Set<Column> get primaryKey => {id};
}

/// Tabela do Catálogo de Pragas
class PestCatalog extends Table {
  TextColumn get id => text()();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  
  // Identificação
  TextColumn get commonName => text()();
  TextColumn get scientificName => text()();
  TextColumn get aliases => text().nullable()(); // JSON array
  TextColumn get type => text()();
  
  // Classificação
  TextColumn get family => text().nullable()();
  TextColumn get order => text().nullable()();
  TextColumn get class_ => text().nullable()();
  
  // Hospedeiros
  TextColumn get hostCrops => text()(); // JSON array
  TextColumn get preferredHost => text().nullable()();
  
  // Descrição
  TextColumn get description => text().nullable()();
  TextColumn get lifecycle => text().nullable()();
  TextColumn get symptoms => text().nullable()();
  TextColumn get identificationTips => text().nullable()();
  
  // Danos
  TextColumn get damageType => text().nullable()();
  TextColumn get severity => text()();
  RealColumn get yieldLossPercent => real().nullable()();
  
  // Condições
  TextColumn get favorableConditions => text().nullable()();
  RealColumn get optimalTempMin => real().nullable()();
  RealColumn get optimalTempMax => real().nullable()();
  RealColumn get optimalHumidity => real().nullable()();
  TextColumn get season => text().nullable()();
  
  // Níveis
  RealColumn get economicThreshold => real().nullable()();
  RealColumn get actionThreshold => real().nullable()();
  TextColumn get samplingMethod => text().nullable()();
  
  // Controle
  TextColumn get recommendedMethods => text().nullable()(); // JSON array
  TextColumn get culturalControl => text().nullable()();
  TextColumn get biologicalControl => text().nullable()();
  TextColumn get chemicalOptions => text().nullable()(); // JSON array
  TextColumn get resistanceNotes => text().nullable()();
  
  TextColumn get naturalEnemies => text().nullable()(); // JSON array
  
  // Mídia
  TextColumn get photoUrls => text().nullable()(); // JSON array
  TextColumn get illustrationUrl => text().nullable()();
  TextColumn get videoUrl => text().nullable()();
  
  TextColumn get references => text().nullable()(); // JSON array
  TextColumn get source => text().nullable()();
  
  @override
  Set<Column> get primaryKey => {id};
}

/// Tabela de Agenda de Monitoramento
class MonitoringSchedules extends Table {
  TextColumn get id => text()();
  DateTimeColumn get createdAt => dateTime().nullable()();
  DateTimeColumn get updatedAt => dateTime().nullable()();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  
  // Relacionamentos
  TextColumn get fieldId => text().nullable()();
  TextColumn get cropId => text().nullable()();
  
  // Planejamento
  TextColumn get title => text()();
  TextColumn get description => text().nullable()();
  
  // Periodicidade
  TextColumn get frequency => text()();
  IntColumn get intervalDays => integer()();
  DateTimeColumn get startDate => dateTime()();
  DateTimeColumn get endDate => dateTime().nullable()();
  
  // Alvos
  TextColumn get targetPests => text().nullable()(); // JSON array
  TextColumn get pointsToInspect => text().nullable()(); // JSON array
  
  TextColumn get responsiblePerson => text().nullable()();
  
  // Alertas
  BoolColumn get sendReminders => boolean().withDefault(const Constant(false))();
  IntColumn get reminderDaysBefore => integer().nullable()();
  
  // Status
  BoolColumn get isCompleted => boolean().withDefault(const Constant(false))();
  DateTimeColumn get lastMonitoringDate => dateTime().nullable()();
  DateTimeColumn get nextMonitoringDate => dateTime().nullable()();
  
  TextColumn get observations => text().nullable()();
  TextColumn get objectId => text().nullable()();
  
  @override
  Set<Column> get primaryKey => {id};
}
```

Continua no próximo arquivo...

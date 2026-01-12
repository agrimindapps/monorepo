# 🌾 Gestão de Pastagens (Pasture Management)

**ID**: AGR-013  
**Prioridade**: 🔴 Alta  
**Estimativa**: 3-4 semanas  
**Status**: 📝 Planejamento  
**Criado**: 2026-01-12  
**Atualizado**: 2026-01-12  

---

## 📖 Visão Geral

### O que é?
A **Gestão de Pastagens** é uma ferramenta para pecuaristas gerenciarem de forma eficiente a rotação de pastagens, monitorar a condição dos piquetes e otimizar a lotação animal. Permite maximizar a produção forrageira enquanto mantém a sustentabilidade do sistema.

### Por que implementar?
1. **Intensificação Sustentável** - Aumentar lotação sem degradar pastagem
2. **Redução de Custos** - Menos suplementação com pasto bem manejado
3. **Recuperação de Áreas** - Identificar piquetes degradados
4. **Planejamento Forrageiro** - Prever déficit/excesso de forragem
5. **Integração com Livestock** - Complementa gestão de bovinos existente
6. **Diferencial Competitivo** - Poucos apps fazem isso bem

### Benchmark
- **Pastoreio Racional Voisin (PRV)** - Metodologia clássica de rotação
- **Pastejo Rotacionado** - Método tradicional brasileiro
- **MiG (Manejo Intensivo de Gado)** - Metodologia americana
- **Apps**: FarmLogs, Pasture.io, MaiaGrazing

### Conceitos Fundamentais

#### Unidade Animal (UA)
- 1 UA = 450 kg de peso vivo
- Permite comparar diferentes categorias
- Base para cálculo de lotação

#### Taxa de Lotação
- UA/ha = Quantas unidades animais por hectare
- Lotação instantânea vs lotação média anual
- Varia conforme época do ano e condição da pastagem

#### Período de Ocupação e Descanso
- **Ocupação**: Dias que os animais ficam no piquete
- **Descanso**: Dias sem animais para rebrota
- Varia conforme forrageira e época do ano

---

## 🎯 Objetivos

### Objetivos de Negócio
- [ ] Aumentar engajamento de usuários pecuaristas
- [ ] Integrar com feature Livestock existente
- [ ] Gerar dados para analytics de produtividade
- [ ] Base para consultoria técnica

### Objetivos Técnicos
- [ ] Seguir padrão Clean Architecture (igual Pluviometer)
- [ ] 100% Riverpod code generation
- [ ] Drift para persistência local
- [ ] Firebase ready para sincronização
- [ ] Offline-first (essencial para áreas rurais)

---

## 🏗️ Arquitetura Proposta

### Estrutura de Pastas
```
lib/features/pasture_management/
├── data/
│   ├── datasources/
│   │   └── pasture_local_datasource.dart
│   ├── models/
│   │   ├── paddock_model.dart
│   │   ├── grazing_cycle_model.dart
│   │   ├── pasture_condition_model.dart
│   │   └── forage_species_model.dart
│   └── repositories/
│       └── pasture_repository_impl.dart
├── domain/
│   ├── entities/
│   │   ├── paddock_entity.dart
│   │   ├── grazing_cycle_entity.dart
│   │   ├── pasture_condition_entity.dart
│   │   ├── forage_species_entity.dart
│   │   └── enums/
│   │       ├── paddock_status.dart
│   │       ├── forage_type.dart
│   │       └── season_type.dart
│   ├── repositories/
│   │   └── pasture_repository.dart
│   └── usecases/
│       ├── paddocks/
│       │   ├── create_paddock.dart
│       │   ├── update_paddock.dart
│       │   ├── delete_paddock.dart
│       │   ├── get_paddocks.dart
│       │   └── get_paddock_by_id.dart
│       ├── grazing/
│       │   ├── start_grazing.dart
│       │   ├── end_grazing.dart
│       │   ├── get_grazing_history.dart
│       │   ├── get_current_grazing.dart
│       │   └── calculate_rest_days.dart
│       ├── conditions/
│       │   ├── register_condition.dart
│       │   ├── get_condition_history.dart
│       │   └── get_paddocks_needing_attention.dart
│       ├── calculations/
│       │   ├── calculate_stocking_rate.dart
│       │   ├── calculate_carrying_capacity.dart
│       │   ├── calculate_forage_availability.dart
│       │   └── suggest_rotation_schedule.dart
│       └── reports/
│           ├── get_pasture_statistics.dart
│           ├── get_rotation_summary.dart
│           └── export_pasture_report.dart
└── presentation/
    ├── providers/
    │   ├── pasture_provider.dart
    │   └── pasture_provider.g.dart
    ├── pages/
    │   ├── pasture_home_page.dart
    │   ├── paddocks_list_page.dart
    │   ├── paddock_detail_page.dart
    │   ├── paddock_form_page.dart
    │   ├── grazing_form_page.dart
    │   ├── condition_form_page.dart
    │   ├── rotation_calendar_page.dart
    │   ├── pasture_map_page.dart
    │   └── pasture_statistics_page.dart
    └── widgets/
        ├── paddock_card.dart
        ├── paddock_status_badge.dart
        ├── grazing_timeline.dart
        ├── condition_indicator.dart
        ├── forage_height_slider.dart
        ├── stocking_rate_gauge.dart
        ├── rotation_calendar_widget.dart
        └── pasture_summary_card.dart
```

---

## 📊 Modelo de Dados

### 1. PaddockEntity (Piquete/Módulo)
```dart
/// Representa um piquete ou divisão de pastagem
class PaddockEntity extends Equatable {
  final String id;                    // UUID
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final bool isActive;                // Soft delete
  
  // Identificação
  final String name;                  // "Piquete 1", "Módulo A"
  final String? code;                 // Código interno
  final String? description;
  
  // Área
  final double area;                  // Em hectares
  final AreaUnit areaUnit;            // ha, alqueire
  
  // Localização
  final String? latitude;
  final String? longitude;
  final String? polygonGeoJson;       // Polígono do piquete
  
  // Forrageira
  final ForageType forageType;        // Tipo de forrageira
  final String? forageSpecies;        // Espécie específica
  final String? forageVariety;        // Cultivar/variedade
  final int? implantationYear;        // Ano de implantação
  
  // Capacidade
  final double? capacityUA;           // Capacidade em UA
  final double? idealRestDays;        // Dias de descanso ideais
  final double? maxOccupationDays;    // Dias máx de ocupação
  
  // Status atual
  final PaddockStatus status;         // Ocupado, em descanso, reforma
  final DateTime? statusChangedAt;    // Quando mudou o status
  final String? currentHerdId;        // Lote atual (se ocupado)
  
  // Infraestrutura
  final bool hasWaterSource;          // Tem aguada?
  final bool hasShadow;               // Tem sombra?
  final bool hasSaltTrough;           // Tem cocho de sal?
  final String? infrastructureNotes;
  
  // Observações
  final String? observations;
  
  // Sync
  final String? objectId;             // Firebase
  
  // Computed
  double get stockingRate;            // UA/ha atual
  int get daysSinceStatusChange;      // Dias no status atual
  bool get needsAttention;            // Precisa de atenção?
}

enum PaddockStatus {
  available,      // Disponível para uso
  occupied,       // Com animais
  resting,        // Em descanso (recuperação)
  deferred,       // Diferido (vedado para acúmulo)
  reform,         // Em reforma/recuperação
  inactive        // Inativo
}

enum ForageType {
  // Gramíneas Tropicais
  brachiaria,     // Braquiária (várias espécies)
  panicum,        // Panicum (Mombaça, Tanzânia, etc)
  cynodon,        // Cynodon (Tifton, Coast-cross)
  andropogon,     // Andropogon
  
  // Gramíneas de Clima Temperado
  ryegrass,       // Azevém
  oat,            // Aveia
  
  // Leguminosas
  stylosanthes,   // Estilosantes
  leucaena,       // Leucena
  
  // Integração
  ilpf,           // Integração Lavoura-Pecuária-Floresta
  
  // Outros
  native,         // Pastagem nativa
  mixed,          // Consorciada/mista
  other
}

enum AreaUnit { hectare, alqueire, acre }
```

### 2. GrazingCycleEntity (Ciclo de Pastejo)
```dart
/// Representa um período de ocupação de um piquete por um lote
class GrazingCycleEntity extends Equatable {
  final String id;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final bool isActive;
  
  // Relacionamentos
  final String paddockId;             // FK → Paddock
  final String? herdId;               // FK → Herd (Livestock)
  
  // Período
  final DateTime entryDate;           // Data de entrada
  final DateTime? exitDate;           // Data de saída (null = atual)
  final int? plannedDays;             // Dias planejados
  
  // Altura da forragem
  final double? entryHeight;          // Altura entrada (cm)
  final double? exitHeight;           // Altura saída (cm)
  final double? idealEntryHeight;     // Altura ideal entrada
  final double? idealExitHeight;      // Altura ideal saída (resíduo)
  
  // Animais
  final int? animalCount;             // Número de animais
  final double? totalUA;              // Total em UA
  final String? animalCategory;       // Categoria (vacas, novilhas, etc)
  final double? averageWeight;        // Peso médio (kg)
  
  // Lotação
  final double? stockingRate;         // UA/ha instantânea
  final double? animalDaysPerHa;      // Dias-animal/ha
  
  // Suplementação durante o período
  final bool hadSupplementation;
  final String? supplementationType;  // Mineral, proteinado, energético
  final double? supplementationKgDay; // kg/animal/dia
  
  // Observações
  final String? entryObservations;
  final String? exitObservations;
  final String? weatherConditions;    // Condições climáticas
  
  // Sync
  final String? objectId;
  
  // Computed
  int get occupationDays;             // Dias de ocupação
  bool get isCurrentlyGrazing;        // Pastejo em andamento?
  double get heightReduction;         // Redução de altura (%)
}
```

### 3. PastureConditionEntity (Condição da Pastagem)
```dart
/// Registro de avaliação da condição de um piquete
class PastureConditionEntity extends Equatable {
  final String id;
  final DateTime? createdAt;
  final bool isActive;
  
  // Relacionamentos
  final String paddockId;             // FK → Paddock
  
  // Data da avaliação
  final DateTime evaluationDate;
  final String? evaluatedBy;          // Quem avaliou
  
  // Altura da forragem
  final double forageHeight;          // Altura média (cm)
  final double? forageHeightMin;      // Altura mínima
  final double? forageHeightMax;      // Altura máxima
  
  // Cobertura e qualidade
  final double coveragePercent;       // Cobertura vegetal (%)
  final double? greenPercent;         // Material verde (%)
  final double? deadMaterialPercent;  // Material morto (%)
  final ForageQuality quality;        // Qualidade geral
  
  // Problemas identificados
  final double? weedPercent;          // Invasoras (%)
  final List<String>? weedTypes;      // Tipos de invasoras
  final bool hasPests;                // Tem pragas?
  final String? pestDescription;      // Descrição das pragas
  final bool hasDiseases;             // Tem doenças?
  final String? diseaseDescription;   // Descrição das doenças
  
  // Solo
  final bool hasErosion;              // Sinais de erosão?
  final bool hasCompaction;           // Solo compactado?
  final SoilMoisture soilMoisture;    // Umidade do solo
  
  // Disponibilidade de forragem
  final double? forageMassKgHa;       // Massa de forragem (kg MS/ha)
  final double? leafPercentage;       // % de folhas
  
  // Recomendações
  final PastureAction recommendedAction;  // Ação recomendada
  final int? recommendedRestDays;     // Dias de descanso sugeridos
  final String? observations;
  
  // Fotos
  final List<String>? photoUrls;
  
  // GPS da avaliação
  final String? latitude;
  final String? longitude;
  
  // Sync
  final String? objectId;
}

enum ForageQuality {
  excellent,    // Excelente - alta proporção de folhas verdes
  good,         // Boa - adequada para pastejo
  regular,      // Regular - precisa de atenção
  poor,         // Ruim - degradada
  critical      // Crítica - reforma necessária
}

enum SoilMoisture {
  saturated,    // Encharcado
  wet,          // Úmido
  adequate,     // Adequado
  dry,          // Seco
  veryDry       // Muito seco
}

enum PastureAction {
  readyToGraze,     // Pronto para pastejo
  continueResting,  // Continuar descansando
  needsDefer,       // Precisa diferir
  needsFertilization, // Precisa adubar
  needsWeedControl, // Controle de invasoras
  needsPestControl, // Controle de pragas
  needsReform,      // Precisa de reforma
  needsIrrigation   // Precisa de irrigação
}
```

### 4. ForageSpeciesEntity (Espécie Forrageira - Catálogo)
```dart
/// Catálogo de espécies forrageiras com parâmetros técnicos
class ForageSpeciesEntity extends Equatable {
  final String id;
  final bool isActive;
  
  // Identificação
  final String commonName;            // Nome comum
  final String scientificName;        // Nome científico
  final ForageType type;              // Tipo
  final String? cultivar;             // Cultivar específica
  
  // Características
  final ClimateAdaptation climate;    // Adaptação climática
  final SoilFertilityRequirement fertility; // Exigência de fertilidade
  final DroughtTolerance droughtTolerance;  // Tolerância à seca
  final GrowthHabit growthHabit;      // Hábito de crescimento
  
  // Manejo recomendado
  final double idealEntryHeight;      // Altura ideal entrada (cm)
  final double idealExitHeight;       // Altura ideal saída (cm)
  final int minRestDaysWet;           // Descanso mínimo águas (dias)
  final int maxRestDaysWet;           // Descanso máximo águas
  final int minRestDaysDry;           // Descanso mínimo seca
  final int maxRestDaysDry;           // Descanso máximo seca
  final int maxOccupationDays;        // Ocupação máxima
  
  // Produtividade
  final double? yieldKgHaYear;        // Produção (kg MS/ha/ano)
  final double? proteinPercent;       // Proteína bruta (%)
  final double? tndPercent;           // NDT (%)
  final double? stockingRateUA;       // Lotação suportada (UA/ha)
  
  // Observações
  final String? managementTips;       // Dicas de manejo
  final String? observations;
  
  // Imagem
  final String? imageUrl;
}

enum ClimateAdaptation { tropical, subtropical, temperate, universal }
enum SoilFertilityRequirement { low, medium, high }
enum DroughtTolerance { low, medium, high }
enum GrowthHabit { erect, decumbent, stoloniferous }
```

---

## 🗄️ Tabelas Drift (SQLite)

```dart
// lib/database/tables/pasture_tables.dart

/// Tabela de Piquetes
class Paddocks extends Table {
  TextColumn get id => text()();
  DateTimeColumn get createdAt => dateTime().nullable()();
  DateTimeColumn get updatedAt => dateTime().nullable()();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  
  // Identificação
  TextColumn get name => text()();
  TextColumn get code => text().nullable()();
  TextColumn get description => text().nullable()();
  
  // Área
  RealColumn get area => real()();
  TextColumn get areaUnit => text().withDefault(const Constant('hectare'))();
  
  // Localização
  TextColumn get latitude => text().nullable()();
  TextColumn get longitude => text().nullable()();
  TextColumn get polygonGeoJson => text().nullable()();
  
  // Forrageira
  TextColumn get forageType => text()();
  TextColumn get forageSpecies => text().nullable()();
  TextColumn get forageVariety => text().nullable()();
  IntColumn get implantationYear => integer().nullable()();
  
  // Capacidade
  RealColumn get capacityUA => real().nullable()();
  RealColumn get idealRestDays => real().nullable()();
  RealColumn get maxOccupationDays => real().nullable()();
  
  // Status
  TextColumn get status => text().withDefault(const Constant('available'))();
  DateTimeColumn get statusChangedAt => dateTime().nullable()();
  TextColumn get currentHerdId => text().nullable()();
  
  // Infraestrutura
  BoolColumn get hasWaterSource => boolean().withDefault(const Constant(false))();
  BoolColumn get hasShadow => boolean().withDefault(const Constant(false))();
  BoolColumn get hasSaltTrough => boolean().withDefault(const Constant(false))();
  TextColumn get infrastructureNotes => text().nullable()();
  
  TextColumn get observations => text().nullable()();
  TextColumn get objectId => text().nullable()();
  
  @override
  Set<Column> get primaryKey => {id};
}

/// Tabela de Ciclos de Pastejo
class GrazingCycles extends Table {
  TextColumn get id => text()();
  DateTimeColumn get createdAt => dateTime().nullable()();
  DateTimeColumn get updatedAt => dateTime().nullable()();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  
  // Relacionamentos
  TextColumn get paddockId => text().references(Paddocks, #id)();
  TextColumn get herdId => text().nullable()();
  
  // Período
  DateTimeColumn get entryDate => dateTime()();
  DateTimeColumn get exitDate => dateTime().nullable()();
  IntColumn get plannedDays => integer().nullable()();
  
  // Altura da forragem
  RealColumn get entryHeight => real().nullable()();
  RealColumn get exitHeight => real().nullable()();
  RealColumn get idealEntryHeight => real().nullable()();
  RealColumn get idealExitHeight => real().nullable()();
  
  // Animais
  IntColumn get animalCount => integer().nullable()();
  RealColumn get totalUA => real().nullable()();
  TextColumn get animalCategory => text().nullable()();
  RealColumn get averageWeight => real().nullable()();
  
  // Lotação
  RealColumn get stockingRate => real().nullable()();
  RealColumn get animalDaysPerHa => real().nullable()();
  
  // Suplementação
  BoolColumn get hadSupplementation => boolean().withDefault(const Constant(false))();
  TextColumn get supplementationType => text().nullable()();
  RealColumn get supplementationKgDay => real().nullable()();
  
  // Observações
  TextColumn get entryObservations => text().nullable()();
  TextColumn get exitObservations => text().nullable()();
  TextColumn get weatherConditions => text().nullable()();
  
  TextColumn get objectId => text().nullable()();
  
  @override
  Set<Column> get primaryKey => {id};
}

/// Tabela de Avaliações de Condição
class PastureConditions extends Table {
  TextColumn get id => text()();
  DateTimeColumn get createdAt => dateTime().nullable()();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  
  // Relacionamentos
  TextColumn get paddockId => text().references(Paddocks, #id)();
  
  // Avaliação
  DateTimeColumn get evaluationDate => dateTime()();
  TextColumn get evaluatedBy => text().nullable()();
  
  // Altura
  RealColumn get forageHeight => real()();
  RealColumn get forageHeightMin => real().nullable()();
  RealColumn get forageHeightMax => real().nullable()();
  
  // Cobertura e qualidade
  RealColumn get coveragePercent => real()();
  RealColumn get greenPercent => real().nullable()();
  RealColumn get deadMaterialPercent => real().nullable()();
  TextColumn get quality => text()();
  
  // Problemas
  RealColumn get weedPercent => real().nullable()();
  TextColumn get weedTypes => text().nullable()(); // JSON array
  BoolColumn get hasPests => boolean().withDefault(const Constant(false))();
  TextColumn get pestDescription => text().nullable()();
  BoolColumn get hasDiseases => boolean().withDefault(const Constant(false))();
  TextColumn get diseaseDescription => text().nullable()();
  
  // Solo
  BoolColumn get hasErosion => boolean().withDefault(const Constant(false))();
  BoolColumn get hasCompaction => boolean().withDefault(const Constant(false))();
  TextColumn get soilMoisture => text().nullable()();
  
  // Forragem
  RealColumn get forageMassKgHa => real().nullable()();
  RealColumn get leafPercentage => real().nullable()();
  
  // Recomendações
  TextColumn get recommendedAction => text()();
  IntColumn get recommendedRestDays => integer().nullable()();
  TextColumn get observations => text().nullable()();
  
  // Mídia
  TextColumn get photoUrls => text().nullable()(); // JSON array
  TextColumn get latitude => text().nullable()();
  TextColumn get longitude => text().nullable()();
  
  TextColumn get objectId => text().nullable()();
  
  @override
  Set<Column> get primaryKey => {id};
}

/// Tabela de Espécies Forrageiras (Catálogo)
class ForageSpecies extends Table {
  TextColumn get id => text()();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  
  // Identificação
  TextColumn get commonName => text()();
  TextColumn get scientificName => text()();
  TextColumn get type => text()();
  TextColumn get cultivar => text().nullable()();
  
  // Características
  TextColumn get climate => text()();
  TextColumn get fertility => text()();
  TextColumn get droughtTolerance => text()();
  TextColumn get growthHabit => text()();
  
  // Manejo
  RealColumn get idealEntryHeight => real()();
  RealColumn get idealExitHeight => real()();
  IntColumn get minRestDaysWet => integer()();
  IntColumn get maxRestDaysWet => integer()();
  IntColumn get minRestDaysDry => integer()();
  IntColumn get maxRestDaysDry => integer()();
  IntColumn get maxOccupationDays => integer()();
  
  // Produtividade
  RealColumn get yieldKgHaYear => real().nullable()();
  RealColumn get proteinPercent => real().nullable()();
  RealColumn get tndPercent => real().nullable()();
  RealColumn get stockingRateUA => real().nullable()();
  
  TextColumn get managementTips => text().nullable()();
  TextColumn get observations => text().nullable()();
  TextColumn get imageUrl => text().nullable()();
  
  @override
  Set<Column> get primaryKey => {id};
}
```

---

## 🎨 Telas e Fluxos

### Navegação Principal
```
pasture_home_page
├── [Tab] Meus Piquetes
│   └── paddocks_list_page
│       ├── paddock_form_page (criar/editar)
│       └── paddock_detail_page
│           ├── grazing_form_page (iniciar/finalizar pastejo)
│           ├── condition_form_page (avaliar condição)
│           └── grazing_timeline (histórico)
├── [Tab] Rotação
│   └── rotation_calendar_page
│       └── Visão de calendário com piquetes
├── [Tab] Mapa
│   └── pasture_map_page
│       └── Visualização espacial dos piquetes
└── [Tab] Estatísticas
    └── pasture_statistics_page
        └── Análises e relatórios
```

### Wireframes (Descrição)

#### 1. Home Page - Dashboard
```
┌─────────────────────────────────────┐
│ 🌾 Gestão de Pastagens              │
├─────────────────────────────────────┤
│ ┌─────────────────────────────────┐ │
│ │ Resumo do Sistema               │ │
│ │ • 12 piquetes | 180 ha          │ │
│ │ • 3 ocupados | 8 descansando    │ │
│ │ • Lotação média: 2.3 UA/ha      │ │
│ └─────────────────────────────────┘ │
│                                     │
│ ⚠️ Atenção Necessária               │
│ ┌─────────────────────────────────┐ │
│ │ 🔴 Piquete 5 - Descanso: 45 dias│ │
│ │    Recomendação: Iniciar pastejo│ │
│ │ 🟡 Piquete 8 - Invasoras: 15%   │ │
│ │    Recomendação: Controle       │ │
│ └─────────────────────────────────┘ │
│                                     │
│ 📊 Status dos Piquetes              │
│ ┌───┬───┬───┬───┬───┬───┐         │
│ │ 1 │ 2 │ 3 │ 4 │ 5 │ 6 │         │
│ │🟢│🟢│🔵│🔵│🟡│🔵│         │
│ ├───┼───┼───┼───┼───┼───┤         │
│ │ 7 │ 8 │ 9 │10 │11 │12 │         │
│ │🔵│🟡│🟢│🔵│🔵│🔴│         │
│ └───┴───┴───┴───┴───┴───┘         │
│ 🟢 Ocupado 🔵 Descansando           │
│ 🟡 Atenção 🔴 Disponível            │
│                                     │
├─────────────────────────────────────┤
│ [Piquetes] [Rotação] [Mapa] [Stats] │
└─────────────────────────────────────┘
```

#### 2. Lista de Piquetes
```
┌─────────────────────────────────────┐
│ ← Meus Piquetes             [+ Add] │
├─────────────────────────────────────┤
│ [🔍 Buscar...] [Filtrar ▼]          │
│                                     │
│ ┌─────────────────────────────────┐ │
│ │ 📍 Piquete 1              🟢    │ │
│ │ Brachiaria brizantha | 15 ha    │ │
│ │ ━━━━━━━━━━━━━━━━━━━━            │ │
│ │ Status: Ocupado (5 dias)        │ │
│ │ Lote: Vacas em lactação         │ │
│ │ Lotação: 3.2 UA/ha              │ │
│ │ Altura: 35 cm → 18 cm           │ │
│ │ [Ver detalhes →]                │ │
│ └─────────────────────────────────┘ │
│                                     │
│ ┌─────────────────────────────────┐ │
│ │ 📍 Piquete 2              🔵    │ │
│ │ Panicum maximum | 12 ha         │ │
│ │ ━━━━━━━━━━━━━━━                 │ │
│ │ Status: Descansando (22 dias)   │ │
│ │ Última avaliação: 10/01         │ │
│ │ Altura atual: 65 cm ✓           │ │
│ │ Previsão: Pronto em 6 dias      │ │
│ │ [Ver detalhes →]                │ │
│ └─────────────────────────────────┘ │
│                                     │
│ Resumo: 12 piquetes | 180 ha total  │
└─────────────────────────────────────┘
```

#### 3. Detalhe do Piquete
```
┌─────────────────────────────────────┐
│ ← Piquete 1                  [Edit] │
├─────────────────────────────────────┤
│ ┌─────────────────────────────────┐ │
│ │ 🗺️ [Mapa/Foto do piquete]      │ │
│ │                                 │ │
│ └─────────────────────────────────┘ │
│                                     │
│ 📋 Informações                      │
│ • Área: 15 hectares                 │
│ • Forrageira: Brachiaria brizantha  │
│ • Cultivar: Marandu                 │
│ • Implantação: 2020                 │
│ • Capacidade: 45 UA                 │
│                                     │
│ 🏗️ Infraestrutura                   │
│ ✓ Aguada  ✓ Sombra  ✓ Cocho sal    │
│                                     │
│ ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━  │
│                                     │
│ 📊 Status Atual: OCUPADO            │
│ ┌─────────────────────────────────┐ │
│ │ Lote: Vacas em lactação (45 cb) │ │
│ │ Entrada: 08/01/2026             │ │
│ │ Dias ocupado: 5                 │ │
│ │ Altura entrada: 35 cm           │ │
│ │ Altura atual: ~22 cm            │ │
│ │ Lotação: 3.2 UA/ha              │ │
│ │                                 │ │
│ │ [Registrar Saída]               │ │
│ └─────────────────────────────────┘ │
│                                     │
│ ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━  │
│                                     │
│ 📈 Histórico de Pastejo             │
│ ┌─────────────────────────────────┐ │
│ │ ──●── 08/01 Entrada (35cm)      │ │
│ │   │                             │ │
│ │ ──●── 03/01 Saída (15cm)        │ │
│ │   │   7 dias | 2.8 UA/ha        │ │
│ │ ──●── 27/12 Entrada (38cm)      │ │
│ │   │                             │ │
│ │ ──●── 20/12 Saída (12cm)        │ │
│ │       6 dias | 3.0 UA/ha        │ │
│ └─────────────────────────────────┘ │
│ [Ver histórico completo]            │
│                                     │
│ ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━  │
│                                     │
│ [📷 Avaliar Condição] [📊 Estatís.] │
└─────────────────────────────────────┘
```

#### 4. Formulário de Entrada/Saída
```
┌─────────────────────────────────────┐
│ ← Registrar Entrada         [Salvar]│
├─────────────────────────────────────┤
│                                     │
│ Piquete                             │
│ [Piquete 5 - 12 ha              ▼]  │
│                                     │
│ Lote de Animais                     │
│ [Vacas em lactação              ▼]  │
│                                     │
│ Data de Entrada *                   │
│ [📅 12/01/2026                   ]  │
│                                     │
│ ─── Animais ───                     │
│ Quantidade:     [45        ] cab    │
│ Peso médio:     [480       ] kg     │
│ Total UA:       [48.0      ] auto   │
│                                     │
│ ─── Condição da Pastagem ───        │
│ Altura da forragem *                │
│ [━━━━━━━━●━━━━━] 35 cm              │
│ Ideal: 30-40 cm ✓                   │
│                                     │
│ Cobertura vegetal                   │
│ [━━━━━━━━━━━●━━] 85%                │
│                                     │
│ Qualidade visual                    │
│ [▼ Boa                           ]  │
│                                     │
│ ─── Planejamento ───                │
│ Dias planejados: [5         ] dias  │
│ Altura saída ideal: 15 cm           │
│                                     │
│ Observações                         │
│ [________________________]          │
│                                     │
│ ─── Lotação Calculada ───           │
│ ┌─────────────────────────────────┐ │
│ │ 📊 4.0 UA/ha                    │ │
│ │ ⚠️ Acima do recomendado (3.5)   │ │
│ │ Sugestão: Reduzir para 42 cab   │ │
│ └─────────────────────────────────┘ │
│                                     │
└─────────────────────────────────────┘
```

#### 5. Calendário de Rotação
```
┌─────────────────────────────────────┐
│ ← Calendário de Rotação     [Config]│
├─────────────────────────────────────┤
│         Janeiro 2026                │
│ ┌───┬───┬───┬───┬───┬───┬───┐     │
│ │Dom│Seg│Ter│Qua│Qui│Sex│Sab│     │
│ ├───┼───┼───┼───┼───┼───┼───┤     │
│ │   │   │   │ 1 │ 2 │ 3 │ 4 │     │
│ │   │   │   │P1 │P1 │P1 │P1 │     │
│ ├───┼───┼───┼───┼───┼───┼───┤     │
│ │ 5 │ 6 │ 7 │ 8 │ 9 │10 │11 │     │
│ │P1 │P1 │P2 │P2 │P2 │P2 │P2 │     │
│ ├───┼───┼───┼───┼───┼───┼───┤     │
│ │12 │13 │14 │15 │16 │17 │18 │     │
│ │P2▶│P3 │P3 │P3 │P3 │P3 │P4 │     │
│ └───┴───┴───┴───┴───┴───┴───┘     │
│                                     │
│ 🎨 Legenda                          │
│ P1 = Piquete 1 (ocupado)            │
│ P2▶ = Piquete 2 (hoje)              │
│ P3, P4 = Próximos planejados        │
│                                     │
│ ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━  │
│                                     │
│ 📋 Próximas Movimentações           │
│ ┌─────────────────────────────────┐ │
│ │ 12/01 - Sair do Piquete 2       │ │
│ │         Entrar no Piquete 3     │ │
│ ├─────────────────────────────────┤ │
│ │ 17/01 - Sair do Piquete 3       │ │
│ │         Entrar no Piquete 4     │ │
│ └─────────────────────────────────┘ │
│                                     │
│ [Sugerir Rotação Automática]        │
└─────────────────────────────────────┘
```

---

## 📊 Cálculos e Algoritmos

### 1. Taxa de Lotação
```dart
/// Calcula taxa de lotação instantânea
double calculateStockingRate({
  required int animalCount,
  required double averageWeight,
  required double areaHa,
}) {
  final totalUA = (animalCount * averageWeight) / 450;
  return totalUA / areaHa; // UA/ha
}
```

### 2. Capacidade de Suporte
```dart
/// Estima capacidade de suporte baseado na forragem
double calculateCarryingCapacity({
  required double forageMassKgHa,    // kg MS/ha
  required double utilizationRate,    // % (geralmente 50-70%)
  required double dailyIntakePercent, // % do peso vivo (2-3%)
  required double grazingDays,        // Dias de pastejo
  required double averageWeight,      // Peso médio (kg)
}) {
  final availableForage = forageMassKgHa * utilizationRate;
  final dailyIntakeKg = averageWeight * dailyIntakePercent;
  final totalIntakeNeeded = dailyIntakeKg * grazingDays;
  
  final animalsSupported = availableForage / totalIntakeNeeded;
  final uaSupported = (animalsSupported * averageWeight) / 450;
  
  return uaSupported; // UA/ha
}
```

### 3. Dias de Descanso Recomendados
```dart
/// Calcula dias de descanso baseado na forrageira e estação
int calculateRestDays({
  required ForageSpeciesEntity forage,
  required SeasonType season,
  required double exitHeight,
}) {
  // Base da forrageira
  int baseDays = season == SeasonType.wet
      ? forage.minRestDaysWet
      : forage.minRestDaysDry;
  
  // Ajuste por altura de saída (se saiu muito baixo, precisa mais descanso)
  if (exitHeight < forage.idealExitHeight * 0.8) {
    baseDays = (baseDays * 1.3).round(); // +30% se raspou muito
  }
  
  // Limites
  final maxDays = season == SeasonType.wet
      ? forage.maxRestDaysWet
      : forage.maxRestDaysDry;
  
  return baseDays.clamp(forage.minRestDaysWet, maxDays);
}
```

### 4. Sugestão de Rotação
```dart
/// Sugere próximo piquete para pastejo
PaddockEntity? suggestNextPaddock({
  required List<PaddockEntity> paddocks,
  required ForageSpeciesEntity forage,
}) {
  final available = paddocks.where((p) => 
    p.status == PaddockStatus.available ||
    (p.status == PaddockStatus.resting && 
     p.daysSinceStatusChange >= forage.minRestDaysWet)
  );
  
  // Ordenar por dias de descanso (mais tempo primeiro)
  final sorted = available.toList()
    ..sort((a, b) => b.daysSinceStatusChange.compareTo(a.daysSinceStatusChange));
  
  // Filtrar por altura adequada (se tiver avaliação recente)
  final ready = sorted.where((p) {
    final lastCondition = getLastCondition(p.id);
    if (lastCondition == null) return true;
    return lastCondition.forageHeight >= forage.idealEntryHeight;
  });
  
  return ready.firstOrNull ?? sorted.firstOrNull;
}
```

### 5. Estimativa de Massa de Forragem
```dart
/// Estima massa de forragem pela altura (método simplificado)
double estimateForageMass({
  required double heightCm,
  required ForageType forageType,
}) {
  // Coeficientes aproximados (kg MS/ha por cm de altura)
  final coefficients = {
    ForageType.brachiaria: 120.0,   // ~120 kg MS/ha/cm
    ForageType.panicum: 150.0,      // ~150 kg MS/ha/cm
    ForageType.cynodon: 100.0,      // ~100 kg MS/ha/cm
  };
  
  final coef = coefficients[forageType] ?? 100.0;
  return heightCm * coef; // kg MS/ha
}
```

---

## 🔗 Integração com Livestock

### Compartilhamento de Dados
```dart
// Integração com feature Livestock existente

/// Provider que conecta Pasture com Livestock
@riverpod
class PastureLivestockIntegration extends _$PastureLivestockIntegration {
  
  /// Obtém lotes disponíveis do Livestock
  Future<List<HerdEntity>> getAvailableHerds() async {
    // Usar provider do Livestock
    return ref.read(herdsProvider).value ?? [];
  }
  
  /// Ao iniciar pastejo, atualiza localização do lote
  Future<void> updateHerdLocation({
    required String herdId,
    required String paddockId,
  }) async {
    await ref.read(updateHerdUseCaseProvider).call(
      UpdateHerdParams(
        id: herdId,
        currentPaddockId: paddockId,
      ),
    );
  }
  
  /// Calcula UA do lote
  double calculateHerdUA(HerdEntity herd) {
    return (herd.animalCount * herd.averageWeight) / 450;
  }
}
```

### Dados Compartilhados
- **Herds** (Lotes) → Usados no GrazingCycle
- **Animals** → Para cálculo preciso de UA
- **Categories** → Para filtrar lotes por categoria

---

## ✅ Critérios de Aceite

### MVP (Versão 1.0)

#### Piquetes
- [ ] CRUD completo de piquetes
- [ ] Campos obrigatórios: nome, área, forrageira
- [ ] Status visual (ocupado, descansando, etc)
- [ ] Localização GPS opcional
- [ ] Listagem com filtros

#### Ciclos de Pastejo
- [ ] Registrar entrada de animais
- [ ] Registrar saída de animais
- [ ] Altura de entrada e saída
- [ ] Cálculo automático de lotação (UA/ha)
- [ ] Histórico de pastejo

#### Avaliação de Condição
- [ ] Formulário de avaliação
- [ ] Altura da forragem (slider)
- [ ] Cobertura vegetal (%)
- [ ] Qualidade visual
- [ ] Recomendação de ação

#### Dashboard
- [ ] Resumo do sistema
- [ ] Piquetes que precisam de atenção
- [ ] Status visual de todos piquetes

### Versão 1.1 (Melhorias)
- [ ] Calendário de rotação
- [ ] Sugestão automática de próximo piquete
- [ ] Fotos nas avaliações
- [ ] Catálogo de forrageiras
- [ ] Alertas de descanso

### Versão 1.2 (Avançado)
- [ ] Mapa com piquetes (polígonos)
- [ ] Integração completa com Livestock
- [ ] Cálculo de capacidade de suporte
- [ ] Relatórios exportáveis
- [ ] Planejamento de diferimento
- [ ] Previsão de forragem

---

## 🔧 Implementação Técnica

### Use Cases

#### Paddocks
| Use Case | Params | Return |
|----------|--------|--------|
| CreatePaddock | PaddockEntity | Either<Failure, PaddockEntity> |
| UpdatePaddock | PaddockEntity | Either<Failure, PaddockEntity> |
| DeletePaddock | String id | Either<Failure, Unit> |
| GetPaddocks | NoParams | Either<Failure, List<PaddockEntity>> |
| GetPaddockById | String id | Either<Failure, PaddockEntity> |
| GetPaddocksByStatus | PaddockStatus | Either<Failure, List<PaddockEntity>> |

#### Grazing
| Use Case | Params | Return |
|----------|--------|--------|
| StartGrazing | GrazingCycleEntity | Either<Failure, GrazingCycleEntity> |
| EndGrazing | String id, exitData | Either<Failure, GrazingCycleEntity> |
| GetCurrentGrazing | String paddockId | Either<Failure, GrazingCycleEntity?> |
| GetGrazingHistory | String paddockId | Either<Failure, List<GrazingCycleEntity>> |
| CalculateRestDays | params | Either<Failure, int> |

#### Conditions
| Use Case | Params | Return |
|----------|--------|--------|
| RegisterCondition | PastureConditionEntity | Either<Failure, PastureConditionEntity> |
| GetConditionHistory | String paddockId | Either<Failure, List<PastureConditionEntity>> |
| GetPaddocksNeedingAttention | NoParams | Either<Failure, List<PaddockEntity>> |

#### Calculations
| Use Case | Params | Return |
|----------|--------|--------|
| CalculateStockingRate | params | Either<Failure, double> |
| CalculateCarryingCapacity | params | Either<Failure, double> |
| SuggestNextPaddock | params | Either<Failure, PaddockEntity?> |
| SuggestRotationSchedule | params | Either<Failure, List<RotationSuggestion>> |

### Providers (Riverpod)

```dart
// Repository
@riverpod
PastureRepository pastureRepository(Ref ref);

// Use Cases
@riverpod
CreatePaddockUseCase createPaddockUseCase(Ref ref);
@riverpod
StartGrazingUseCase startGrazingUseCase(Ref ref);
// ... outros

// State Notifiers
@riverpod
class PaddocksNotifier extends _$PaddocksNotifier { }

@riverpod
class GrazingNotifier extends _$GrazingNotifier { }

@riverpod
class ConditionsNotifier extends _$ConditionsNotifier { }

@riverpod
class RotationPlannerNotifier extends _$RotationPlannerNotifier { }

// Computed Providers
@riverpod
List<PaddockEntity> paddocksNeedingAttention(Ref ref);

@riverpod
PastureStatistics pastureStatistics(Ref ref);
```

---

## 📅 Cronograma Estimado

### Semana 1: Foundation
- [ ] Criar estrutura de pastas
- [ ] Implementar entities e enums
- [ ] Criar tabelas Drift
- [ ] Popular catálogo de forrageiras
- [ ] Implementar repositories Drift

### Semana 2: Domain + Data
- [ ] Implementar repository interface
- [ ] Implementar repository impl
- [ ] Criar use cases de CRUD
- [ ] Criar use cases de cálculos
- [ ] Implementar providers Riverpod

### Semana 3: Presentation (Core)
- [ ] Home page com dashboard
- [ ] CRUD de piquetes
- [ ] Formulário de entrada/saída
- [ ] Formulário de avaliação
- [ ] Timeline de histórico

### Semana 4: Presentation (Polish)
- [ ] Calendário de rotação
- [ ] Integração com Livestock
- [ ] Sugestões automáticas
- [ ] Ajustes finais
- [ ] Testes

---

## 🧪 Testes

### Unit Tests
- [ ] Cálculo de UA
- [ ] Cálculo de capacidade de suporte
- [ ] Cálculo de dias de descanso
- [ ] Sugestão de próximo piquete
- [ ] Validações de entrada

### Integration Tests
- [ ] Fluxo: criar piquete → iniciar pastejo → finalizar
- [ ] Atualização de status automática
- [ ] Integração com Livestock

### Widget Tests
- [ ] PaddockCard renderização
- [ ] ForageHeightSlider valores
- [ ] StockingRateGauge alertas

---

## 📚 Referências Técnicas

### Metodologias de Manejo
- **PRV** (Pastoreio Racional Voisin) - André Voisin
- **MiG** (Manejo Intensivo de Gado) - Allan Savory
- **Embrapa** - Recomendações técnicas brasileiras

### Parâmetros de Forrageiras (Embrapa)

| Forrageira | Entrada (cm) | Saída (cm) | Descanso Águas | Descanso Seca |
|------------|--------------|------------|----------------|---------------|
| B. brizantha cv. Marandu | 25-30 | 10-15 | 25-30 dias | 45-60 dias |
| B. brizantha cv. Xaraés | 30-35 | 15-20 | 20-25 dias | 40-50 dias |
| Panicum maximum cv. Mombaça | 80-90 | 30-40 | 25-30 dias | 50-70 dias |
| Panicum maximum cv. Tanzânia | 60-70 | 25-30 | 25-30 dias | 45-60 dias |
| Cynodon (Tifton 85) | 20-25 | 5-10 | 18-21 dias | 28-35 dias |

### Links Úteis
- [Embrapa Gado de Corte](https://www.embrapa.br/gado-de-corte)
- [Manual de Pastagens (Embrapa)](https://www.embrapa.br/)
- [Drift Documentation](https://drift.simonbinder.eu/)

---

## 📝 Notas de Implementação

### Decisões Técnicas
1. **Status automático** - Atualizar status do piquete ao iniciar/finalizar pastejo
2. **Catálogo pré-populado** - ForageSpecies vem com dados padrão
3. **Cálculos on-demand** - Lotação calculada, não armazenada
4. **Alertas computados** - Provider que observa condições

### Pontos de Atenção
1. **Offline** - Crítico para uso no campo
2. **Sincronização** - Resolver conflitos de edição simultânea
3. **Performance** - Indexar paddockId em todas tabelas relacionadas
4. **UX no campo** - Botões grandes, formulários simples

### Seed Data - Forrageiras
```dart
// Incluir no primeiro run
final defaultForages = [
  ForageSpeciesEntity(
    id: 'brachiaria-marandu',
    commonName: 'Braquiarão',
    scientificName: 'Brachiaria brizantha',
    cultivar: 'Marandu',
    type: ForageType.brachiaria,
    idealEntryHeight: 28,
    idealExitHeight: 12,
    minRestDaysWet: 25,
    maxRestDaysWet: 30,
    minRestDaysDry: 45,
    maxRestDaysDry: 60,
    maxOccupationDays: 7,
    // ...
  ),
  // ... outras forrageiras
];
```

---

## 🔗 Dependências com Outras Features

### Dependências
- **Livestock** - Lotes de animais para vincular ao pastejo
- **Weather** - Determinar estação (águas/seca)
- **Settings** - Configurações de unidades

### Integrações Futuras
- **Caderno de Campo** - Registrar atividades de reforma/adubação
- **Calculators** - Calculadora de adubação de pastagem
- **Maps** - Visualização espacial avançada

---

**Autor**: Claude (AI Assistant)  
**Revisão**: Pendente  
**Aprovação**: Pendente

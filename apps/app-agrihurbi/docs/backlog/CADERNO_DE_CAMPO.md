# 📋 Caderno de Campo Digital (Field Notebook)

**ID**: AGR-010  
**Prioridade**: 🔴 Alta  
**Estimativa**: 3-4 semanas  
**Status**: 📝 Planejamento  
**Criado**: 2026-01-12  
**Atualizado**: 2026-01-12  

---

## 📖 Visão Geral

### O que é?
O **Caderno de Campo Digital** é uma ferramenta essencial para o produtor rural registrar todas as atividades realizadas na propriedade. Substitui o caderno físico tradicional, oferecendo rastreabilidade completa, análise de custos e conformidade regulatória.

### Por que implementar?
1. **Rastreabilidade** - Exigência de mercados e certificações
2. **Gestão de Custos** - Saber quanto custa produzir cada cultura
3. **Tomada de Decisão** - Dados históricos para planejar melhor
4. **Compliance** - Atender normas de rastreabilidade (ex: SISBOV, GlobalGAP)
5. **Eficiência** - Eliminar papel e centralizar informações

### Benchmark
- **Aegro** - Caderno de campo + gestão financeira
- **Cropwise** - Monitoramento de lavouras (Syngenta)
- **Strider** - MIP e controle de pragas
- **Agrosmart** - IoT + dados climáticos

---

## 🎯 Objetivos

### Objetivos de Negócio
- [ ] Aumentar retenção de usuários em 30%
- [ ] Gerar dados para features de analytics
- [ ] Base para integração com certificadoras
- [ ] Diferenciar do concorrente

### Objetivos Técnicos
- [ ] Seguir padrão Clean Architecture (igual Pluviometer)
- [ ] 100% Riverpod code generation
- [ ] Drift para persistência local
- [ ] Firebase ready para sincronização
- [ ] Offline-first

---

## 🏗️ Arquitetura Proposta

### Estrutura de Pastas
```
lib/features/field_notebook/
├── data/
│   ├── datasources/
│   │   └── field_notebook_local_datasource.dart
│   ├── models/
│   │   ├── field_model.dart
│   │   ├── crop_model.dart
│   │   ├── activity_model.dart
│   │   └── input_usage_model.dart
│   └── repositories/
│       └── field_notebook_repository_impl.dart
├── domain/
│   ├── entities/
│   │   ├── field_entity.dart
│   │   ├── crop_entity.dart
│   │   ├── activity_entity.dart
│   │   ├── input_usage_entity.dart
│   │   └── activity_type.dart
│   ├── repositories/
│   │   └── field_notebook_repository.dart
│   └── usecases/
│       ├── fields/
│       │   ├── create_field.dart
│       │   ├── update_field.dart
│       │   ├── delete_field.dart
│       │   ├── get_fields.dart
│       │   └── get_field_by_id.dart
│       ├── crops/
│       │   ├── create_crop.dart
│       │   ├── get_crops_by_field.dart
│       │   └── close_crop.dart
│       ├── activities/
│       │   ├── create_activity.dart
│       │   ├── update_activity.dart
│       │   ├── delete_activity.dart
│       │   ├── get_activities.dart
│       │   └── get_activities_by_crop.dart
│       └── reports/
│           ├── get_field_statistics.dart
│           ├── get_cost_analysis.dart
│           └── export_report.dart
└── presentation/
    ├── providers/
    │   ├── field_notebook_provider.dart
    │   └── field_notebook_provider.g.dart
    ├── pages/
    │   ├── field_notebook_home_page.dart
    │   ├── fields_list_page.dart
    │   ├── field_detail_page.dart
    │   ├── field_form_page.dart
    │   ├── crop_form_page.dart
    │   ├── activity_form_page.dart
    │   ├── activities_list_page.dart
    │   ├── activity_detail_page.dart
    │   ├── cost_analysis_page.dart
    │   └── export_report_page.dart
    └── widgets/
        ├── field_card.dart
        ├── crop_card.dart
        ├── activity_card.dart
        ├── activity_type_selector.dart
        ├── input_usage_form.dart
        └── cost_summary_card.dart
```

---

## 📊 Modelo de Dados

### 1. FieldEntity (Talhão/Área)
```dart
class FieldEntity extends Equatable {
  final String id;                    // UUID
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final bool isActive;                // Soft delete
  
  // Identificação
  final String name;                  // "Talhão A", "Pivô 1"
  final String? code;                 // Código interno opcional
  final String? description;
  
  // Área
  final double area;                  // Em hectares
  final AreaUnit areaUnit;            // ha, alqueire, acre
  
  // Localização
  final String? latitude;
  final String? longitude;
  final String? polygonGeoJson;       // Polígono do talhão (futuro)
  
  // Classificação
  final SoilType? soilType;           // Argiloso, arenoso, etc
  final String? observations;
  
  // Sync
  final String? objectId;             // Firebase
}

enum AreaUnit { hectare, alqueire, acre }
enum SoilType { clayey, sandy, loamy, silty, mixed }
```

### 2. CropEntity (Cultura/Safra no Talhão)
```dart
class CropEntity extends Equatable {
  final String id;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final bool isActive;
  
  // Relacionamentos
  final String fieldId;               // FK → Field
  
  // Cultura
  final CropType cropType;            // Soja, milho, trigo, etc
  final String? variety;              // Variedade/cultivar
  final String season;                // "2024/25", "Safrinha 2025"
  
  // Datas
  final DateTime plantingDate;        // Data de plantio
  final DateTime? expectedHarvestDate;
  final DateTime? actualHarvestDate;
  final CropStatus status;            // Planejado, plantado, colhido
  
  // Produção
  final double? plantedArea;          // Área efetivamente plantada
  final double? expectedYield;        // Produtividade esperada (sc/ha)
  final double? actualYield;          // Produtividade real
  final double? harvestedQuantity;    // Quantidade colhida (sc ou ton)
  
  // Custos
  final double? totalCost;            // Calculado das atividades
  final double? revenuePerUnit;       // Preço de venda por unidade
  
  // Sync
  final String? objectId;
}

enum CropType {
  soybean,      // Soja
  corn,         // Milho
  wheat,        // Trigo
  cotton,       // Algodão
  coffee,       // Café
  sugarcane,    // Cana-de-açúcar
  rice,         // Arroz
  beans,        // Feijão
  sorghum,      // Sorgo
  sunflower,    // Girassol
  pasture,      // Pastagem
  other
}

enum CropStatus { planned, planted, growing, harvesting, harvested, closed }
```

### 3. ActivityEntity (Atividade/Operação)
```dart
class ActivityEntity extends Equatable {
  final String id;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final bool isActive;
  
  // Relacionamentos
  final String cropId;                // FK → Crop
  final String fieldId;               // FK → Field (denormalizado para queries)
  
  // Atividade
  final ActivityType activityType;    // Tipo de atividade
  final DateTime activityDate;        // Data de execução
  final DateTime? endDate;            // Data fim (se operação longa)
  
  // Detalhes
  final String? description;
  final String? observations;
  final String? weatherCondition;     // Condição climática
  final double? temperature;          // Temperatura no momento
  
  // Área e Execução
  final double? workedArea;           // Área trabalhada (ha)
  final double? workHours;            // Horas de trabalho
  final String? operatorName;         // Quem executou
  final String? machineryUsed;        // Máquina utilizada
  
  // Custos
  final double? laborCost;            // Custo mão-de-obra
  final double? machineryCost;        // Custo máquinas
  final double? inputsCost;           // Custo insumos (calculado)
  final double? otherCosts;           // Outros custos
  final double? totalCost;            // Total calculado
  
  // Geolocalização
  final String? latitude;
  final String? longitude;
  
  // Mídia
  final List<String>? photoUrls;      // URLs das fotos
  
  // Sync
  final String? objectId;
}

enum ActivityType {
  // Preparo de Solo
  soilPreparation,      // Preparo de solo
  liming,               // Calagem
  gypsum,               // Gessagem
  plowing,              // Aração
  harrowing,            // Gradagem
  subsoiling,           // Subsolagem
  
  // Plantio
  planting,             // Plantio/Semeadura
  replanting,           // Replantio
  
  // Tratos Culturais
  fertilization,        // Adubação
  topdressing,          // Adubação de cobertura
  foliarApplication,    // Aplicação foliar
  
  // Controle Fitossanitário
  herbicideApplication, // Aplicação de herbicida
  insecticideApplication, // Aplicação de inseticida
  fungicideApplication, // Aplicação de fungicida
  biologicalControl,    // Controle biológico
  
  // Irrigação
  irrigation,           // Irrigação
  fertirrigation,       // Fertirrigação
  
  // Colheita
  harvest,              // Colheita
  
  // Outros
  monitoring,           // Monitoramento/Visita
  soilSampling,         // Coleta de solo
  maintenance,          // Manutenção geral
  other                 // Outro
}
```

### 4. InputUsageEntity (Uso de Insumo na Atividade)
```dart
class InputUsageEntity extends Equatable {
  final String id;
  final DateTime? createdAt;
  final bool isActive;
  
  // Relacionamentos
  final String activityId;            // FK → Activity
  
  // Insumo
  final InputCategory category;       // Categoria
  final String productName;           // Nome comercial
  final String? activeIngredient;     // Princípio ativo
  final String? manufacturer;         // Fabricante
  
  // Quantidade
  final double quantity;              // Quantidade utilizada
  final InputUnit unit;               // Unidade
  final double? dosePerHectare;       // Dose por hectare
  
  // Custo
  final double? unitPrice;            // Preço unitário
  final double? totalCost;            // Custo total
  
  // Rastreabilidade
  final String? batchNumber;          // Número do lote
  final DateTime? expirationDate;     // Validade
  final String? invoiceNumber;        // Nota fiscal
  
  // Receituário (para defensivos)
  final String? agronomistName;       // Responsável técnico
  final String? agronomistCrea;       // CREA do agrônomo
  final String? prescriptionNumber;   // Número do receituário
  
  // Sync
  final String? objectId;
}

enum InputCategory {
  seed,           // Semente
  fertilizer,     // Fertilizante
  herbicide,      // Herbicida
  insecticide,    // Inseticida
  fungicide,      // Fungicida
  adjuvant,       // Adjuvante
  inoculant,      // Inoculante
  biological,     // Biológico
  soilAmendment,  // Corretivo de solo
  fuel,           // Combustível
  other
}

enum InputUnit {
  kg,             // Quilograma
  g,              // Grama
  l,              // Litro
  ml,             // Mililitro
  ton,            // Tonelada
  sc,             // Saca (60kg)
  bag,            // Bag/Big bag
  unit,           // Unidade
  dose            // Dose
}
```

---

## 🗄️ Tabelas Drift (SQLite)

```dart
// lib/database/tables/field_notebook_tables.dart

/// Tabela de Talhões
class Fields extends Table {
  TextColumn get id => text()();
  DateTimeColumn get createdAt => dateTime().nullable()();
  DateTimeColumn get updatedAt => dateTime().nullable()();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  
  TextColumn get name => text()();
  TextColumn get code => text().nullable()();
  TextColumn get description => text().nullable()();
  
  RealColumn get area => real()();
  TextColumn get areaUnit => text().withDefault(const Constant('hectare'))();
  
  TextColumn get latitude => text().nullable()();
  TextColumn get longitude => text().nullable()();
  TextColumn get polygonGeoJson => text().nullable()();
  
  TextColumn get soilType => text().nullable()();
  TextColumn get observations => text().nullable()();
  
  TextColumn get objectId => text().nullable()();
  
  @override
  Set<Column> get primaryKey => {id};
}

/// Tabela de Culturas
class Crops extends Table {
  TextColumn get id => text()();
  DateTimeColumn get createdAt => dateTime().nullable()();
  DateTimeColumn get updatedAt => dateTime().nullable()();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  
  TextColumn get fieldId => text().references(Fields, #id)();
  
  TextColumn get cropType => text()();
  TextColumn get variety => text().nullable()();
  TextColumn get season => text()();
  
  DateTimeColumn get plantingDate => dateTime()();
  DateTimeColumn get expectedHarvestDate => dateTime().nullable()();
  DateTimeColumn get actualHarvestDate => dateTime().nullable()();
  TextColumn get status => text().withDefault(const Constant('planned'))();
  
  RealColumn get plantedArea => real().nullable()();
  RealColumn get expectedYield => real().nullable()();
  RealColumn get actualYield => real().nullable()();
  RealColumn get harvestedQuantity => real().nullable()();
  
  RealColumn get totalCost => real().nullable()();
  RealColumn get revenuePerUnit => real().nullable()();
  
  TextColumn get objectId => text().nullable()();
  
  @override
  Set<Column> get primaryKey => {id};
}

/// Tabela de Atividades
class Activities extends Table {
  TextColumn get id => text()();
  DateTimeColumn get createdAt => dateTime().nullable()();
  DateTimeColumn get updatedAt => dateTime().nullable()();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  
  TextColumn get cropId => text().references(Crops, #id)();
  TextColumn get fieldId => text().references(Fields, #id)();
  
  TextColumn get activityType => text()();
  DateTimeColumn get activityDate => dateTime()();
  DateTimeColumn get endDate => dateTime().nullable()();
  
  TextColumn get description => text().nullable()();
  TextColumn get observations => text().nullable()();
  TextColumn get weatherCondition => text().nullable()();
  RealColumn get temperature => real().nullable()();
  
  RealColumn get workedArea => real().nullable()();
  RealColumn get workHours => real().nullable()();
  TextColumn get operatorName => text().nullable()();
  TextColumn get machineryUsed => text().nullable()();
  
  RealColumn get laborCost => real().nullable()();
  RealColumn get machineryCost => real().nullable()();
  RealColumn get inputsCost => real().nullable()();
  RealColumn get otherCosts => real().nullable()();
  RealColumn get totalCost => real().nullable()();
  
  TextColumn get latitude => text().nullable()();
  TextColumn get longitude => text().nullable()();
  TextColumn get photoUrls => text().nullable()(); // JSON array
  
  TextColumn get objectId => text().nullable()();
  
  @override
  Set<Column> get primaryKey => {id};
}

/// Tabela de Uso de Insumos
class InputUsages extends Table {
  TextColumn get id => text()();
  DateTimeColumn get createdAt => dateTime().nullable()();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  
  TextColumn get activityId => text().references(Activities, #id)();
  
  TextColumn get category => text()();
  TextColumn get productName => text()();
  TextColumn get activeIngredient => text().nullable()();
  TextColumn get manufacturer => text().nullable()();
  
  RealColumn get quantity => real()();
  TextColumn get unit => text()();
  RealColumn get dosePerHectare => real().nullable()();
  
  RealColumn get unitPrice => real().nullable()();
  RealColumn get totalCost => real().nullable()();
  
  TextColumn get batchNumber => text().nullable()();
  DateTimeColumn get expirationDate => dateTime().nullable()();
  TextColumn get invoiceNumber => text().nullable()();
  
  TextColumn get agronomistName => text().nullable()();
  TextColumn get agronomistCrea => text().nullable()();
  TextColumn get prescriptionNumber => text().nullable()();
  
  TextColumn get objectId => text().nullable()();
  
  @override
  Set<Column> get primaryKey => {id};
}
```

---

## 🎨 Telas e Fluxos

### Navegação Principal
```
field_notebook_home_page
├── [Tab] Meus Talhões
│   └── fields_list_page
│       ├── field_form_page (criar/editar)
│       └── field_detail_page
│           ├── crop_form_page (nova cultura)
│           └── activities_list_page
│               └── activity_form_page
├── [Tab] Atividades Recentes
│   └── activities_list_page (todas)
│       └── activity_detail_page
├── [Tab] Análise de Custos
│   └── cost_analysis_page
└── [Tab] Relatórios
    └── export_report_page
```

### Wireframes (Descrição)

#### 1. Home Page
```
┌─────────────────────────────────────┐
│ 🌱 Caderno de Campo                 │
├─────────────────────────────────────┤
│ ┌─────────────────────────────────┐ │
│ │ Resumo da Safra 2024/25         │ │
│ │ • 5 talhões ativos              │ │
│ │ • 12 atividades este mês        │ │
│ │ • R$ 45.230,00 em custos        │ │
│ └─────────────────────────────────┘ │
│                                     │
│ ⚡ Ações Rápidas                    │
│ [+ Nova Atividade] [+ Novo Talhão]  │
│                                     │
│ 📋 Últimas Atividades               │
│ ┌─────────────────────────────────┐ │
│ │ 🌿 Aplicação Fungicida          │ │
│ │ Talhão A - Soja | Ontem         │ │
│ │ 50 ha | R$ 3.500,00             │ │
│ └─────────────────────────────────┘ │
│ ┌─────────────────────────────────┐ │
│ │ 💧 Irrigação                    │ │
│ │ Pivô 1 - Milho | 10/01          │ │
│ │ 80 ha | R$ 1.200,00             │ │
│ └─────────────────────────────────┘ │
├─────────────────────────────────────┤
│ [Talhões] [Atividades] [Custos]     │
└─────────────────────────────────────┘
```

#### 2. Lista de Talhões
```
┌─────────────────────────────────────┐
│ ← Meus Talhões              [+ Add] │
├─────────────────────────────────────┤
│ [🔍 Buscar talhão...]               │
│                                     │
│ ┌─────────────────────────────────┐ │
│ │ 📍 Talhão A                     │ │
│ │ 50 ha | Soja 2024/25            │ │
│ │ Status: Em desenvolvimento      │ │
│ │ Última atividade: há 2 dias     │ │
│ │ [Ver detalhes →]                │ │
│ └─────────────────────────────────┘ │
│                                     │
│ ┌─────────────────────────────────┐ │
│ │ 📍 Pivô 1                       │ │
│ │ 80 ha | Milho Safrinha          │ │
│ │ Status: Colhido                 │ │
│ │ Produtividade: 120 sc/ha        │ │
│ │ [Ver detalhes →]                │ │
│ └─────────────────────────────────┘ │
│                                     │
│ Total: 5 talhões | 320 ha          │
└─────────────────────────────────────┘
```

#### 3. Formulário de Atividade
```
┌─────────────────────────────────────┐
│ ← Nova Atividade           [Salvar] │
├─────────────────────────────────────┤
│                                     │
│ Tipo de Atividade *                 │
│ [▼ Aplicação de Fungicida        ]  │
│                                     │
│ Data *                              │
│ [📅 12/01/2026                   ]  │
│                                     │
│ Talhão *                            │
│ [▼ Talhão A - Soja              ]   │
│                                     │
│ Área Trabalhada                     │
│ [50        ] ha                     │
│                                     │
│ ─── Insumos Utilizados ───          │
│ ┌─────────────────────────────────┐ │
│ │ Opera Ultra                     │ │
│ │ 0.5 L/ha | Total: 25 L          │ │
│ │ R$ 180,00/L | R$ 4.500,00       │ │
│ │ [Editar] [Remover]              │ │
│ └─────────────────────────────────┘ │
│ [+ Adicionar Insumo]                │
│                                     │
│ ─── Custos ───                      │
│ Mão-de-obra:    [R$ 500,00    ]     │
│ Máquinas:       [R$ 800,00    ]     │
│ Outros:         [R$ 0,00      ]     │
│                                     │
│ 💰 Total: R$ 5.800,00               │
│                                     │
│ Observações                         │
│ [________________________]          │
│ [________________________]          │
│                                     │
│ 📷 Fotos                            │
│ [+ Adicionar foto]                  │
│                                     │
└─────────────────────────────────────┘
```

---

## 📊 Estatísticas e Relatórios

### Métricas Calculadas

#### Por Talhão
- Área total e área plantada
- Custo total e custo/ha
- Número de atividades
- Histórico de culturas

#### Por Cultura
- Produtividade (sc/ha ou ton/ha)
- Custo de produção total
- Custo/ha e custo/sc
- Margem bruta
- ROI

#### Por Tipo de Atividade
- Frequência de uso
- Custo médio
- Área total trabalhada

#### Por Período
- Totais mensais/anuais
- Comparação entre safras
- Tendências

### Relatórios Exportáveis

1. **Relatório de Atividades** (PDF/CSV)
   - Por período
   - Por talhão
   - Por tipo de atividade

2. **Relatório de Custos** (PDF/CSV)
   - Detalhamento por categoria
   - Comparativo entre talhões
   - Evolução mensal

3. **Ficha do Talhão** (PDF)
   - Dados cadastrais
   - Histórico de culturas
   - Todas as atividades
   - Rastreabilidade completa

4. **Receituário Agronômico** (PDF)
   - Defensivos utilizados
   - Doses e datas
   - Responsável técnico

---

## ✅ Critérios de Aceite

### MVP (Versão 1.0)

#### Talhões
- [ ] CRUD completo de talhões
- [ ] Campos obrigatórios: nome, área
- [ ] Localização GPS opcional
- [ ] Listagem com busca e filtros
- [ ] Visualização em cards

#### Culturas
- [ ] Criar cultura vinculada ao talhão
- [ ] Definir safra e datas
- [ ] Atualizar status da cultura
- [ ] Registrar produtividade na colheita

#### Atividades
- [ ] CRUD completo de atividades
- [ ] Seleção de tipo (enum completo)
- [ ] Vincular a cultura/talhão
- [ ] Registrar custos básicos
- [ ] Listar atividades recentes

#### Insumos
- [ ] Adicionar insumos na atividade
- [ ] Calcular custo total
- [ ] Campos de rastreabilidade

#### Relatórios
- [ ] Resumo na home
- [ ] Custo total por talhão
- [ ] Export CSV básico

### Versão 1.1 (Melhorias)
- [ ] Fotos nas atividades
- [ ] Compartilhamento de relatório
- [ ] Filtros avançados
- [ ] Gráficos de custo
- [ ] Comparação entre safras

### Versão 1.2 (Avançado)
- [ ] Mapa com talhões
- [ ] Polígono do talhão (GeoJSON)
- [ ] Integração com estoque de insumos
- [ ] Alertas de prazo (carência)
- [ ] Dashboard analytics

---

## 🔧 Implementação Técnica

### Use Cases

#### Fields
| Use Case | Params | Return |
|----------|--------|--------|
| CreateField | FieldEntity | Either<Failure, FieldEntity> |
| UpdateField | FieldEntity | Either<Failure, FieldEntity> |
| DeleteField | String id | Either<Failure, Unit> |
| GetFields | NoParams | Either<Failure, List<FieldEntity>> |
| GetFieldById | String id | Either<Failure, FieldEntity> |

#### Crops
| Use Case | Params | Return |
|----------|--------|--------|
| CreateCrop | CropEntity | Either<Failure, CropEntity> |
| UpdateCrop | CropEntity | Either<Failure, CropEntity> |
| CloseCrop | String id, yield, quantity | Either<Failure, CropEntity> |
| GetCropsByField | String fieldId | Either<Failure, List<CropEntity>> |
| GetActiveCrops | NoParams | Either<Failure, List<CropEntity>> |

#### Activities
| Use Case | Params | Return |
|----------|--------|--------|
| CreateActivity | ActivityEntity | Either<Failure, ActivityEntity> |
| UpdateActivity | ActivityEntity | Either<Failure, ActivityEntity> |
| DeleteActivity | String id | Either<Failure, Unit> |
| GetActivities | filters | Either<Failure, List<ActivityEntity>> |
| GetActivitiesByCrop | String cropId | Either<Failure, List<ActivityEntity>> |
| GetRecentActivities | int limit | Either<Failure, List<ActivityEntity>> |

#### Reports
| Use Case | Params | Return |
|----------|--------|--------|
| GetFieldStatistics | String fieldId | Either<Failure, FieldStatistics> |
| GetCostAnalysis | filters | Either<Failure, CostAnalysis> |
| ExportActivitiesReport | filters, format | Either<Failure, String> |

### Providers (Riverpod)

```dart
// Repository
@riverpod
FieldNotebookRepository fieldNotebookRepository(Ref ref);

// Use Cases
@riverpod
CreateFieldUseCase createFieldUseCase(Ref ref);
// ... outros

// State Notifiers
@riverpod
class FieldsNotifier extends _$FieldsNotifier { }

@riverpod
class CropsNotifier extends _$CropsNotifier { }

@riverpod
class ActivitiesNotifier extends _$ActivitiesNotifier { }

@riverpod
class CostAnalysisNotifier extends _$CostAnalysisNotifier { }
```

---

## 📅 Cronograma Estimado

### Semana 1: Foundation
- [ ] Criar estrutura de pastas
- [ ] Implementar entities
- [ ] Criar tabelas Drift
- [ ] Implementar repositories Drift
- [ ] Criar models (toEntity, fromDrift, toJson)

### Semana 2: Domain + Data
- [ ] Implementar repository interface
- [ ] Implementar repository impl
- [ ] Criar todos os use cases
- [ ] Implementar providers Riverpod
- [ ] Testar persistência

### Semana 3: Presentation (Core)
- [ ] Home page com resumo
- [ ] CRUD de talhões
- [ ] CRUD de culturas
- [ ] CRUD de atividades básico
- [ ] Formulário de insumos

### Semana 4: Presentation (Polish)
- [ ] Análise de custos
- [ ] Export CSV
- [ ] Widgets refinados
- [ ] Testes de UI
- [ ] Ajustes finais

---

## 🧪 Testes

### Unit Tests (Use Cases)
- [ ] CreateField - validações e sucesso
- [ ] CreateActivity - cálculo de custos
- [ ] GetFieldStatistics - agregações

### Integration Tests
- [ ] Fluxo completo: criar talhão → cultura → atividade
- [ ] Persistência offline
- [ ] Cálculo de custos cascata

### Widget Tests
- [ ] FieldCard renderização
- [ ] ActivityForm validações
- [ ] InputUsageForm cálculos

---

## 📚 Referências

### Padrão de Implementação
- `lib/features/pluviometer/` - Estrutura de referência
- `lib/features/livestock/` - Gestão de entidades complexas

### Documentação
- [Drift Documentation](https://drift.simonbinder.eu/)
- [Riverpod Documentation](https://riverpod.dev/)
- [Either Pattern (dartz)](https://pub.dev/packages/dartz)

---

## 📝 Notas de Implementação

### Decisões Técnicas
1. **Denormalização fieldId em Activity** - Evita JOIN para queries frequentes
2. **PhotoUrls como JSON string** - Flexibilidade sem tabela adicional
3. **Enums como String no Drift** - Compatibilidade e legibilidade
4. **Soft delete padrão** - Auditoria e recuperação

### Pontos de Atenção
1. **Performance** - Indexar campos de filtro frequente
2. **Validação** - Não permitir atividade sem cultura ativa
3. **Cálculo de custos** - Recalcular ao editar insumos
4. **Sincronização** - ObjectId preparado para Firebase

---

## 🔗 Dependências com Outras Features

### Integrações Futuras
- **Weather** - Condição climática automática na atividade
- **Calculators** - Sugerir doses de insumos
- **Livestock** - Vincular pastagens com bovinos
- **Markets** - Preços para cálculo de receita

---

**Autor**: Claude (AI Assistant)  
**Revisão**: Pendente  
**Aprovação**: Pendente

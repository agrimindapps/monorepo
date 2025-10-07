# Sistema de Diagnóstico Agronômico - ReceitaAgro

**Documento Técnico de Arquitetura e Análise Profunda**

---

## 📋 Sumário Executivo

Este documento detalha a implementação completa do **Sistema de Diagnóstico Agronômico** do ReceitaAgro, responsável por conectar informações de **defensivos agrícolas**, **pragas** e **culturas** para fornecer recomendações técnicas precisas aos usuários.

### Métricas do Sistema

| Métrica | Valor Atual | Status |
|---------|-------------|--------|
| **Hive Boxes** | 6 boxes principais | ✅ Implementado |
| **Entidades de Domínio** | 8 entidades principais | ✅ Implementado |
| **Repositórios** | 12+ repositórios especializados | ✅ Implementado |
| **Use Cases** | 15+ casos de uso | ✅ Implementado |
| **Páginas de Detalhes** | 3 páginas (Diagnóstico, Defensivo, Praga) | ✅ Implementado |
| **Providers Riverpod** | 6+ notifiers | ✅ Implementado |
| **Completude Estimada** | ~85% | ⚠️ Gaps identificados |
| **Qualidade Arquitetural** | Clean Architecture rigorosa | ✅ Alta qualidade |

---

## 📊 Visão Geral do Sistema

### 1.1. Objetivo Principal

O sistema fornece **diagnósticos agronômicos** que relacionam:
- **Defensivos agrícolas** (fitossanitários)
- **Pragas** (insetos, doenças, plantas daninhas)
- **Culturas agrícolas** (soja, milho, café, etc.)

Permitindo que agrônomos e agricultores:
1. **Consultem** recomendações de aplicação de defensivos
2. **Visualizem** dosagens, intervalos e épocas de aplicação
3. **Acessem** informações técnicas sobre ingredientes ativos, toxicidade e formulações
4. **Explorem** defensivos por praga ou pragas por defensivo

### 1.2. Stack Tecnológico

```dart
// State Management
Provider: Riverpod (code generation)
Pattern: AsyncNotifier com estados imutáveis

// Storage Local
Database: Hive (NoSQL key-value)
Type: Static data (sem sincronização Firebase)
Size: ~15-30MB de dados estáticos
Access Pattern: Open -> Query -> Close (sem cache)

// Arquitetura
Pattern: Clean Architecture (Data/Domain/Presentation)
Dependency Injection: GetIt + Injectable
Error Handling: Either<Failure, T> (dartz)
```

### 1.3. 🔴 Princípio Fundamental: Sem Sistema de Cache

**IMPORTANTE:** Este sistema foi projetado para **NÃO** utilizar cache de dados. Todas as consultas às Hiveboxes seguem o padrão:

```dart
// ✅ PADRÃO CORRETO
Box<T>? box;
try {
  box = await Hive.openBox<T>('boxName');
  // Consultar dados
  final data = box.values.where(...).toList();
  return data;
} finally {
  await box?.close();  // SEMPRE fechar
}
```

**Motivações:**
- ✅ Dados sempre atualizados e consistentes
- ✅ Sem complexidade de invalidação de cache
- ✅ Gerenciamento explícito de recursos
- ✅ Hive já otimiza acesso in-memory

**Regras:**
1. Abrir box → Consultar → Fechar (em try-finally)
2. Para múltiplas consultas: abrir boxes uma vez, fechar ao final
3. Nunca confiar em campos cached (ex: `nomeDefensivo`)
4. Sempre resolver através de FKs e consultas diretas

---

## 🗄️ Arquitetura de Dados

### 2.1. Modelo de Dados Hive

#### **DiagnosticoHive (TypeId: 101)** - Tabela de Relacionamento Central

```dart
@HiveType(typeId: 101)
class DiagnosticoHive extends HiveObject {
  // Identificadores
  @HiveField(0) String objectId;
  @HiveField(3) String idReg;  // ID único do diagnóstico

  // Foreign Keys (Relacionamentos)
  @HiveField(4) String fkIdDefensivo;     // → FitossanitarioHive
  @HiveField(6) String fkIdCultura;       // → CulturaHive
  @HiveField(8) String fkIdPraga;         // → PragasHive

  // Campos Cached (⚠️ PODEM ESTAR DESATUALIZADOS)
  @HiveField(5) String? nomeDefensivo;    // ❌ Não usar diretamente
  @HiveField(7) String? nomeCultura;      // ❌ Não usar diretamente
  @HiveField(9) String? nomePraga;        // ❌ Não usar diretamente

  // Dosagem
  @HiveField(10) String? dsMin;           // Dosagem mínima
  @HiveField(11) String dsMax;            // Dosagem máxima (required)
  @HiveField(12) String um;               // Unidade de medida (kg/ha, L/ha, etc)

  // Aplicação Terrestre
  @HiveField(13) String? minAplicacaoT;   // Vazão mínima terrestre
  @HiveField(14) String? maxAplicacaoT;   // Vazão máxima terrestre
  @HiveField(15) String? umT;             // Unidade medida terrestre (L/ha)

  // Aplicação Aérea
  @HiveField(16) String? minAplicacaoA;   // Vazão mínima aérea
  @HiveField(17) String? maxAplicacaoA;   // Vazão máxima aérea
  @HiveField(18) String? umA;             // Unidade medida aérea (L/ha)

  // Intervalos e Época
  @HiveField(19) String? intervalo;       // Intervalo entre aplicações (dias)
  @HiveField(20) String? intervalo2;      // Intervalo alternativo (dias)
  @HiveField(21) String? epocaAplicacao;  // Época recomendada

  // Timestamps
  @HiveField(1) int createdAt;
  @HiveField(2) int updatedAt;
}
```

**Exemplo JSON:**
```json
{
  "objectId": "abc123",
  "idReg": "DG-00001",
  "fkIdDefensivo": "DF-54321",
  "fkIdCultura": "CU-98765",
  "fkIdPraga": "PR-13579",
  "nomeDefensivo": "Glifosato 480 g/L",
  "nomeCultura": "Soja",
  "nomePraga": "Lagarta da Soja",
  "dsMin": "1.0",
  "dsMax": "2.5",
  "um": "L/ha",
  "minAplicacaoT": "100",
  "maxAplicacaoT": "200",
  "umT": "L/ha",
  "intervalo": "15",
  "epocaAplicacao": "Pré-emergência"
}
```

#### **FitossanitarioHive (TypeId: 102)** - Defensivos Agrícolas

```dart
@HiveType(typeId: 102)
class FitossanitarioHive extends HiveObject {
  @HiveField(3) String idReg;              // ID único (PK)
  @HiveField(4) bool status;               // Ativo/Inativo
  @HiveField(5) String nomeComum;          // Nome comercial
  @HiveField(6) String nomeTecnico;        // Nome técnico

  // Classificações
  @HiveField(7) String? classeAgronomica;  // Herbicida, Inseticida, etc
  @HiveField(8) String? fabricante;        // Empresa fabricante
  @HiveField(9) String? classAmbiental;    // Classe I, II, III, IV

  // Características
  @HiveField(10) int comercializado;       // 0=não, 1=sim
  @HiveField(11) String? corrosivo;        // Sim/Não
  @HiveField(12) String? inflamavel;       // Sim/Não
  @HiveField(13) String? formulacao;       // EC, SC, WG, etc
  @HiveField(14) String? modoAcao;         // Sistêmico, Contato, etc
  @HiveField(15) String? mapa;             // Registro MAPA
  @HiveField(16) String? toxico;           // Classe toxicológica
  @HiveField(17) String? ingredienteAtivo; // Princípio ativo
  @HiveField(18) String? quantProduto;     // Quantidade produto
  @HiveField(19) bool elegivel;            // Elegível para uso
}
```

#### **FitossanitarioInfoHive (TypeId: 103)** - Informações Complementares

```dart
@HiveType(typeId: 103)
class FitossanitarioInfoHive extends HiveObject {
  @HiveField(11) String fkIdDefensivo;        // → FitossanitarioHive
  @HiveField(4) String? embalagens;           // Tipos de embalagens
  @HiveField(5) String? tecnologia;           // Tecnologia de aplicação
  @HiveField(6) String? pHumanas;             // Precauções humanas
  @HiveField(7) String? pAmbiental;           // Precauções ambientais
  @HiveField(8) String? manejoResistencia;    // Manejo de resistência
  @HiveField(9) String? compatibilidade;      // Compatibilidade de mistura
  @HiveField(10) String? manejoIntegrado;     // MIP/MID
}
```

#### **PragasHive (TypeId: 105)** - Pragas e Patógenos

```dart
@HiveType(typeId: 105)
class PragasHive extends HiveObject {
  @HiveField(3) String idReg;                 // ID único (PK)
  @HiveField(4) String nomeComum;             // Nome popular
  @HiveField(5) String nomeCientifico;        // Nome científico
  @HiveField(28) String tipoPraga;            // Inseto, Doença, Daninha

  // Classificação Taxonômica Completa (28 campos!)
  @HiveField(6) String? dominio;
  @HiveField(7) String? reino;
  @HiveField(8) String? subReino;
  @HiveField(9) String? clado01;
  @HiveField(10) String? clado02;
  @HiveField(11) String? clado03;
  @HiveField(12) String? superDivisao;
  @HiveField(13) String? divisao;
  @HiveField(14) String? subDivisao;
  @HiveField(15) String? classe;
  @HiveField(16) String? subClasse;
  @HiveField(17) String? superOrdem;
  @HiveField(18) String? ordem;
  @HiveField(19) String? subOrdem;
  @HiveField(20) String? infraOrdem;
  @HiveField(21) String? superFamilia;
  @HiveField(22) String? familia;
  @HiveField(23) String? subFamilia;
  @HiveField(24) String? tribo;
  @HiveField(25) String? subTribo;
  @HiveField(26) String? genero;
  @HiveField(27) String? especie;
}
```

#### **PragasInfHive (TypeId: 106)** - Informações Complementares de Pragas

```dart
@HiveType(typeId: 106)
class PragasInfHive extends HiveObject {
  @HiveField(8) String fkIdPraga;          // → PragasHive
  @HiveField(4) String? descrisao;         // Descrição geral
  @HiveField(5) String? sintomas;          // Sintomas de infestação
  @HiveField(6) String? bioecologia;       // Biologia e ecologia
  @HiveField(7) String? controle;          // Métodos de controle
}
```

#### **CulturaHive (TypeId: 100)** - Culturas Agrícolas

```dart
@HiveType(typeId: 100)
class CulturaHive extends HiveObject {
  @HiveField(3) String idReg;              // ID único (PK)
  @HiveField(4) String cultura;            // Nome da cultura

  // Getters de conveniência
  String get nome => cultura;
  String get nomeComum => cultura;
  String get nomeCientifico => cultura;
}
```

### 2.2. Diagrama de Relacionamentos

```
┌─────────────────────┐
│   CulturaHive       │
│  (TypeId: 100)      │
│                     │
│ PK: idReg           │
│ • cultura           │
└──────────┬──────────┘
           │
           │ 1
           │
           │ N
┌──────────▼──────────────────────┐
│    DiagnosticoHive              │
│    (TypeId: 101)                │◄───────────────┐
│                                 │                │
│ PK: idReg                       │                │
│ FK: fkIdDefensivo   ────────────┼────────┐       │
│ FK: fkIdCultura                 │        │       │
│ FK: fkIdPraga       ────────────┼─────┐  │       │
│                                 │     │  │       │
│ • dsMin, dsMax, um              │     │  │       │
│ • minAplicacaoT, maxAplicacaoT  │     │  │       │
│ • minAplicacaoA, maxAplicacaoA  │     │  │       │
│ • intervalo, epocaAplicacao     │     │  │       │
└─────────────────────────────────┘     │  │       │
                                        │  │       │
                              ┌─────────┘  │       │
                              │            │       │
                              │ N          │ N     │
                              │            │       │
                              │ 1          │ 1     │
                    ┌─────────▼───────┐ ┌──▼───────▼─────────┐
                    │  PragasHive     │ │ FitossanitarioHive │
                    │ (TypeId: 105)   │ │  (TypeId: 102)     │
                    │                 │ │                    │
                    │ PK: idReg       │ │ PK: idReg          │
                    │ • nomeComum     │ │ • nomeComum        │
                    │ • nomeCientifico│ │ • nomeTecnico      │
                    │ • tipoPraga     │ │ • ingredienteAtivo │
                    │ • taxonomia...  │ │ • toxico           │
                    └────┬────────────┘ │ • classeAgronomica │
                         │              │ • modoAcao         │
                         │ 1            └──┬─────────────────┘
                         │                 │
                         │ 1               │ 1
                         │                 │
                         │ 1               │ 1
              ┌──────────▼──────────┐ ┌────▼──────────────────┐
              │ PragasInfHive       │ │ FitossanitarioInfoHive│
              │ (TypeId: 106)       │ │  (TypeId: 103)        │
              │                     │ │                       │
              │ FK: fkIdPraga       │ │ FK: fkIdDefensivo     │
              │ • descrisao         │ │ • tecnologia          │
              │ • sintomas          │ │ • pHumanas            │
              │ • bioecologia       │ │ • pAmbiental          │
              │ • controle          │ │ • manejoResistencia   │
              └─────────────────────┘ └───────────────────────┘
```

**Legenda:**
- **PK** = Primary Key (chave primária)
- **FK** = Foreign Key (chave estrangeira)
- **1** = Um (cardinalidade)
- **N** = Muitos (cardinalidade)

### 2.3. Cardinalidades

| Relação | Cardinalidade | Descrição |
|---------|---------------|-----------|
| Cultura → Diagnóstico | 1:N | Uma cultura pode ter múltiplos diagnósticos |
| Praga → Diagnóstico | 1:N | Uma praga pode ser combatida por múltiplos defensivos |
| Defensivo → Diagnóstico | 1:N | Um defensivo pode ser usado para múltiplas pragas/culturas |
| Diagnóstico ↔ Cultura+Praga+Defensivo | N:3 | Diagnóstico liga as 3 entidades (tabela de junção) |
| Praga → PragasInf | 1:1 | Cada praga tem informações complementares opcionais |
| Defensivo → DefensivoInfo | 1:1 | Cada defensivo tem informações complementares opcionais |

---

## 🏗️ Arquitetura Clean Architecture

### 3.1. Estrutura de Camadas

```
lib/
├── core/
│   ├── data/
│   │   ├── models/                    # Modelos Hive
│   │   │   ├── diagnostico_hive.dart
│   │   │   ├── fitossanitario_hive.dart
│   │   │   ├── fitossanitario_info_hive.dart
│   │   │   ├── pragas_hive.dart
│   │   │   ├── pragas_inf_hive.dart
│   │   │   └── cultura_hive.dart
│   │   └── repositories/              # Repositórios de infraestrutura
│   │       ├── diagnostico_hive_repository.dart
│   │       ├── fitossanitario_hive_repository.dart
│   │       ├── pragas_hive_repository.dart
│   │       └── cultura_hive_repository.dart
│   ├── extensions/
│   │   ├── diagnostico_hive_extension.dart    # 🔑 CRUCIAL
│   │   ├── fitossanitario_hive_extension.dart
│   │   └── pragas_hive_extension.dart
│   ├── services/
│   │   ├── diagnostico_entity_resolver.dart   # 🔑 CRUCIAL
│   │   ├── diagnostico_integration_service.dart
│   │   ├── diagnostico_compatibility_service.dart
│   │   ├── diagnostico_grouping_service.dart
│   │   ├── diagnosticos_data_loader.dart
│   │   ├── fitossanitarios_data_loader.dart
│   │   └── pragas_data_loader.dart
│   └── di/
│       └── injection_container.dart
│
└── features/
    ├── diagnosticos/                   # Feature de diagnósticos
    │   ├── data/
    │   │   ├── mappers/
    │   │   │   └── diagnostico_mapper.dart
    │   │   └── repositories/
    │   │       └── diagnosticos_repository_impl.dart
    │   ├── domain/
    │   │   ├── entities/
    │   │   │   └── diagnostico_entity.dart
    │   │   ├── repositories/
    │   │   │   └── i_diagnosticos_repository.dart
    │   │   └── usecases/
    │   │       ├── get_diagnosticos_usecase.dart
    │   │       ├── get_diagnosticos_by_defensivo_usecase.dart
    │   │       ├── get_diagnosticos_by_cultura_usecase.dart
    │   │       ├── get_diagnosticos_by_praga_usecase.dart
    │   │       └── search_diagnosticos_with_filters_usecase.dart
    │   └── presentation/
    │       ├── providers/
    │       │   └── diagnosticos_notifier.dart
    │       └── pages/
    │           └── diagnosticos_page.dart
    │
    ├── detalhes_diagnostico/           # Feature de detalhes
    │   ├── presentation/
    │   │   ├── providers/
    │   │   │   └── detalhe_diagnostico_notifier.dart
    │   │   ├── pages/
    │   │   │   └── detalhe_diagnostico_page.dart
    │   │   └── widgets/
    │   │       ├── diagnostico_info_widget.dart
    │   │       ├── diagnostico_detalhes_widget.dart
    │   │       └── aplicacao_instrucoes_widget.dart
    │
    ├── DetalheDefensivos/              # Feature de detalhes de defensivo
    │   ├── data/
    │   │   ├── models/
    │   │   │   └── defensivo_model.dart
    │   │   └── repositories/
    │   │       └── defensivo_repository_impl.dart
    │   ├── domain/
    │   │   ├── entities/
    │   │   │   ├── defensivo_entity.dart
    │   │   │   └── defensivo_details_entity.dart
    │   │   ├── repositories/
    │   │   │   └── i_defensivo_details_repository.dart
    │   │   └── usecases/
    │   │       ├── get_defensivo_details_usecase.dart
    │   │       └── get_diagnosticos_by_defensivo_usecase.dart
    │   ├── presentation/
    │   │   ├── providers/
    │   │   │   └── detalhe_defensivo_notifier.dart
    │   │   ├── widgets/
    │   │   │   ├── defensivo_info_cards_widget.dart
    │   │   │   ├── diagnosticos_tab_widget.dart
    │   │   │   └── tecnologia_tab_widget.dart
    │   │   └── detalhe_defensivo_page.dart
    │
    └── pragas/                         # Feature de pragas
        ├── presentation/
        │   ├── providers/
        │   │   ├── detalhe_praga_notifier.dart
        │   │   └── diagnosticos_praga_notifier.dart
        │   ├── pages/
        │   │   └── detalhe_praga_page.dart
        │   └── widgets/
        │       ├── praga_info_widget.dart
        │       └── diagnosticos_praga_mockup_widget.dart
```

### 3.2. Fluxo de Dados (Data Flow)

```
┌──────────────────────────────────────────────────────────────┐
│                    PRESENTATION LAYER                         │
│                                                               │
│  ┌────────────────────────────────────────────────────────┐  │
│  │  DetalheDiagnosticoPage                                │  │
│  │  • Recebe: diagnosticoId, nomeDefensivo, nomePraga     │  │
│  │  • Exibe: Widgets especializados                       │  │
│  └───────────────────┬────────────────────────────────────┘  │
│                      │                                        │
│                      │ usa                                    │
│                      │                                        │
│  ┌───────────────────▼────────────────────────────────────┐  │
│  │  DetalheDiagnosticoNotifier (Riverpod)                 │  │
│  │  • State: DetalheDiagnosticoState                      │  │
│  │  • Métodos:                                            │  │
│  │    - loadDiagnosticoData(diagnosticoId)               │  │
│  │    - toggleFavorito()                                  │  │
│  │    - buildShareText()                                  │  │
│  └───────────────────┬────────────────────────────────────┘  │
└────────────────────────┼───────────────────────────────────────┘
                         │
                         │ chama
                         │
┌────────────────────────▼───────────────────────────────────────┐
│                      DOMAIN LAYER                              │
│                                                                │
│  ┌──────────────────────────────────────────────────────────┐ │
│  │  IDiagnosticosRepository (Interface)                     │ │
│  │  • getById(id): Either<Failure, DiagnosticoEntity?>      │ │
│  │  • getByDefensivo(id): Either<Failure, List<...>>       │ │
│  │  • getByPraga(id): Either<Failure, List<...>>           │ │
│  │  • getByCultura(id): Either<Failure, List<...>>         │ │
│  └───────────────────┬──────────────────────────────────────┘ │
└────────────────────────┼───────────────────────────────────────┘
                         │
                         │ implementado por
                         │
┌────────────────────────▼───────────────────────────────────────┐
│                       DATA LAYER                               │
│                                                                │
│  ┌──────────────────────────────────────────────────────────┐ │
│  │  DiagnosticosRepositoryImpl                              │ │
│  │  • Injeta: DiagnosticoHiveRepository                     │ │
│  │  • Converte: DiagnosticoHive → DiagnosticoEntity         │ │
│  │  • Usa: DiagnosticoMapper.fromHive()                     │ │
│  └───────────────────┬──────────────────────────────────────┘ │
│                      │                                         │
│                      │ usa                                     │
│                      │                                         │
│  ┌───────────────────▼──────────────────────────────────────┐ │
│  │  DiagnosticoHiveRepository (Infraestrutura)              │ │
│  │  • Acessa: Box<DiagnosticoHive>                          │ │
│  │  • Métodos:                                              │ │
│  │    - getAll(): RepositoryResult<List<DiagnosticoHive>>  │ │
│  │    - getByIdOrObjectId(id): DiagnosticoHive?            │ │
│  │    - findByDefensivo(id): List<DiagnosticoHive>         │ │
│  │    - findByPraga(id): List<DiagnosticoHive>             │ │
│  │    - findByCultura(id): List<DiagnosticoHive>           │ │
│  │    - findByMultipleCriteria(...): List<...>             │ │
│  └───────────────────┬──────────────────────────────────────┘ │
└────────────────────────┼───────────────────────────────────────┘
                         │
                         │ consulta
                         │
┌────────────────────────▼───────────────────────────────────────┐
│                    HIVE DATABASE                               │
│                                                                │
│  ┌──────────────────────────────────────────────────────────┐ │
│  │  Box<DiagnosticoHive>                                    │ │
│  │  • ~2000-5000 registros                                  │ │
│  │  • Indexed by: idReg, objectId                           │ │
│  └──────────────────────────────────────────────────────────┘ │
│                                                                │
│  ┌──────────────────────────────────────────────────────────┐ │
│  │  Box<FitossanitarioHive>                                 │ │
│  │  • ~500-1000 defensivos                                  │ │
│  └──────────────────────────────────────────────────────────┘ │
│                                                                │
│  ┌──────────────────────────────────────────────────────────┐ │
│  │  Box<PragasHive>                                         │ │
│  │  • ~300-800 pragas                                       │ │
│  └──────────────────────────────────────────────────────────┘ │
│                                                                │
│  ┌──────────────────────────────────────────────────────────┐ │
│  │  Box<CulturaHive>                                        │ │
│  │  • ~100-200 culturas                                     │ │
│  └──────────────────────────────────────────────────────────┘ │
└────────────────────────────────────────────────────────────────┘
```

---

## 🔄 Formação de Informações de Diagnóstico

### 4.1. Método Crucial: `toDataMap()`

Este método é **FUNDAMENTAL** para compreender como as informações são preparadas para exibição na UI.

**Localização:** `lib/core/extensions/diagnostico_hive_extension.dart`

```dart
extension DiagnosticoHiveExtension on DiagnosticoHive {
  /// Converte DiagnosticoHive para Map<String, String>
  /// resolvendo informações técnicas dinamicamente
  Future<Map<String, String>> toDataMap() async {
    // 1️⃣ Inicializa valores padrão
    String ingredienteAtivo = 'Consulte a bula do produto';
    String toxico = 'Consulte a bula do produto';
    String formulacao = 'Consulte a bula do produto';
    String modoAcao = 'Consulte a bula do produto';
    String nomeCientifico = 'N/A';

    try {
      // 2️⃣ Busca informações do DEFENSIVO via FK
      final fitossanitarioRepo = di.sl<FitossanitarioHiveRepository>();
      final defensivo = await fitossanitarioRepo.getById(fkIdDefensivo);

      if (defensivo != null) {
        if (defensivo.ingredienteAtivo?.isNotEmpty == true) {
          ingredienteAtivo = defensivo.ingredienteAtivo!;
        }
        if (defensivo.toxico?.isNotEmpty == true) {
          toxico = defensivo.toxico!;
        }
        if (defensivo.formulacao?.isNotEmpty == true) {
          formulacao = defensivo.formulacao!;
        }
        if (defensivo.modoAcao?.isNotEmpty == true) {
          modoAcao = defensivo.modoAcao!;
        }
      }
    } catch (e) {
      // ⚠️ Silently fails - mantém valores padrão
    }

    try {
      // 3️⃣ Busca informações da PRAGA via FK
      final pragaRepo = di.sl<PragasHiveRepository>();
      final praga = await pragaRepo.getById(fkIdPraga);

      if (praga != null && praga.nomeCientifico.isNotEmpty) {
        nomeCientifico = praga.nomeCientifico;
      }
    } catch (e) {
      // ⚠️ Silently fails - mantém valor padrão
    }

    // 4️⃣ Retorna mapa completo com todos os dados formatados
    return {
      // Nomes (resolvidos dinamicamente)
      'nomeDefensivo': await getDisplayNomeDefensivo(),
      'nomeCultura': await getDisplayNomeCultura(),
      'nomePraga': await getDisplayNomePraga(),
      'nomeCientifico': nomeCientifico,

      // Dosagens e aplicações (formatados com extensões)
      'dosagem': displayDosagem,
      'vazaoTerrestre': displayVazaoTerrestre,
      'vazaoAerea': displayVazaoAerea,
      'intervaloAplicacao': displayIntervaloAplicacao,
      'epocaAplicacao': displayEpocaAplicacao,

      // Informações técnicas (do defensivo)
      'ingredienteAtivo': ingredienteAtivo,
      'toxico': toxico,
      'formulacao': formulacao,
      'modoAcao': modoAcao,

      // Valores fixos/placeholder
      'intervaloSeguranca': 'Consulte a bula do produto',
      'classAmbiental': 'Consulte a bula do produto',
      'classeAgronomica': 'Consulte a bula do produto',
      'mapa': 'Consulte o registro MAPA',
      'tecnologia': 'Aplicar conforme recomendações técnicas. Consulte um engenheiro agrônomo.',
    };
  }
}
```

### 4.2. Métodos Auxiliares de Formatação

#### **getDisplayNomeDefensivo()** - Resolve nome do defensivo

```dart
Future<String> getDisplayNomeDefensivo() async {
  Box<FitossanitarioHive>? box;
  
  try {
    // 1. Abrir box de fitossanitários
    box = await Hive.openBox<FitossanitarioHive>('fitossanitarios');

    // 2. Consultar defensivo
    final defensivo = box.values.firstWhere(
      (f) => f.idReg == fkIdDefensivo,
      orElse: () => null,
    );

    // 3. Retornar nome se encontrado
    if (defensivo != null && defensivo.nomeComum.isNotEmpty) {
      return defensivo.nomeComum;
    }
  } catch (e) {
    debugPrint('❌ Erro ao resolver nome do defensivo: $e');
  } finally {
    // 4. SEMPRE fechar box
    await box?.close();
  }

  return 'Defensivo não identificado';
}
```

**⚠️ IMPORTANTE:** 
- Este método **SEMPRE** abre a box, consulta e fecha imediatamente
- **NUNCA** usa o campo `nomeDefensivo` armazenado no DiagnosticoHive, pois pode estar desatualizado
- O padrão try-finally garante que a box seja fechada mesmo em caso de erro

#### **displayDosagem** - Formata dosagem

```dart
String get displayDosagem {
  if (dsMin?.isNotEmpty == true && dsMax.isNotEmpty) {
    return '$dsMin - $dsMax $um';  // Ex: "1.0 - 2.5 L/ha"
  } else if (dsMax.isNotEmpty) {
    return '$dsMax $um';            // Ex: "2.5 L/ha"
  }
  return 'Dosagem não especificada';
}
```

#### **displayVazaoTerrestre** - Formata vazão terrestre

```dart
String get displayVazaoTerrestre {
  if (minAplicacaoT?.isNotEmpty == true &&
      maxAplicacaoT?.isNotEmpty == true) {
    return '$minAplicacaoT - $maxAplicacaoT ${umT ?? "L/ha"}';
  } else if (maxAplicacaoT?.isNotEmpty == true) {
    return '$maxAplicacaoT ${umT ?? "L/ha"}';
  }
  return 'Não especificada';
}
```

### 4.3. Padrão de Acesso Direto às Hiveboxes

**Responsabilidade:** Consultar dados diretamente das Hiveboxes sem cache intermediário.

**Localização:** Repositories em `lib/features/*/data/repositories/`

**⚠️ IMPORTANTE:** Não utilizamos sistema de cache. Todas as consultas devem seguir o padrão:
1. **Abrir** a Hivebox
2. **Consultar** os dados necessários
3. **Fechar** a Hivebox imediatamente

```dart
/// Exemplo de consulta direta seguindo o padrão correto
Future<String> resolveCulturaNome({
  required String idCultura,
  String defaultValue = 'Cultura não especificada',
}) async {
  Box<CulturaHive>? box;
  
  try {
    // 1. Abrir box
    box = await Hive.openBox<CulturaHive>('culturas');

    // 2. Consultar dados
    if (idCultura.isNotEmpty) {
      final culturaData = box.values.firstWhere(
        (c) => c.idReg == idCultura,
        orElse: () => null,
      );

      if (culturaData != null && culturaData.cultura.isNotEmpty) {
        return culturaData.cultura;
      }
    }

    // 3. Retorna default se não encontrar
    return defaultValue;
  } catch (e) {
    debugPrint('❌ Erro ao resolver cultura: $e');
    return defaultValue;
  } finally {
    // 4. Fechar box (CRÍTICO!)
    await box?.close();
  }
}

/// Exemplo de consulta de múltiplos registros
Future<List<DiagnosticoHive>> findDiagnosticosByDefensivo(
  String idDefensivo,
) async {
  Box<DiagnosticoHive>? box;
  
  try {
    // 1. Abrir box
    box = await Hive.openBox<DiagnosticoHive>('diagnosticos');

    // 2. Consultar e retornar dados
    return box.values
        .where((d) => d.fkIdDefensivo == idDefensivo)
        .toList();
  } catch (e) {
    debugPrint('❌ Erro ao buscar diagnósticos: $e');
    return [];
  } finally {
    // 3. Fechar box (CRÍTICO!)
    await box?.close();
  }
}
```

**Características:**
- ✅ Consulta sempre dados atualizados
- ✅ Sem risco de dados desatualizados por cache
- ✅ Gerenciamento explícito de recursos (open/close)
- ✅ Padrão try-finally garante fechamento da box
- ⚠️ Importante sempre fechar boxes no bloco finally

---

## 📄 Páginas de Detalhes e Consulta

### 5.1. DetalheDiagnosticoPage

**Responsabilidade:** Exibir informações completas de um diagnóstico específico.

**Localização:** `lib/features/detalhes_diagnostico/presentation/pages/detalhe_diagnostico_page.dart`

**Parâmetros de Entrada:**
```dart
final String diagnosticoId;        // ID único do diagnóstico
final String nomeDefensivo;        // Nome do defensivo (display)
final String nomePraga;            // Nome da praga (display)
final String cultura;              // Nome da cultura (display)
```

**Fluxo de Inicialização:**
```dart
@override
void initState() {
  super.initState();
  WidgetsBinding.instance.addPostFrameCallback((_) async {
    final notifier = ref.read(detalheDiagnosticoNotifierProvider.notifier);

    // 1. Carrega dados do diagnóstico
    await notifier.loadDiagnosticoData(widget.diagnosticoId);

    // 2. Carrega estado de favorito
    await notifier.loadFavoritoState(widget.diagnosticoId);

    // 3. Carrega status premium
    await notifier.loadPremiumStatus();
  });
}
```

**Widgets Especializados:**

1. **DiagnosticoInfoWidget** - Informações gerais
   - Nome do defensivo, praga e cultura
   - Ingrediente ativo
   - Nome científico da praga

2. **DiagnosticoDetalhesWidget** - Detalhes técnicos
   - Classificações (toxicológica, ambiental, agronômica)
   - Formulação e modo de ação
   - Registro MAPA

3. **AplicacaoInstrucoesWidget** - Instruções de aplicação
   - Dosagem recomendada
   - Vazão terrestre e aérea
   - Intervalo entre aplicações
   - Intervalo de segurança
   - Época de aplicação

### 5.2. DetalheDefensivoPage

**Responsabilidade:** Exibir informações completas de um defensivo e seus diagnósticos.

**Localização:** `lib/features/DetalheDefensivos/detalhe_defensivo_page.dart`

**Parâmetros de Entrada:**
```dart
final String defensivoName;        // Nome comercial
final String fabricante;           // Fabricante
```

**Estrutura de Tabs:**
```dart
TabController(length: 4)
├── Tab 1: Informações (DefensivoInfoCardsWidget)
│   ├── Informações Básicas
│   │   • Nome comercial e técnico
│   │   • Fabricante
│   │   • Ingrediente ativo
│   │   • Classe agronômica
│   ├── Classificações
│   │   • Classe toxicológica
│   │   • Classe ambiental
│   │   • Formulação
│   ├── Segurança
│   │   • Toxico
│   │   • Inflamável
│   │   • Corrosivo
│   └── Tecnologia
│       • Modo de ação
│       • Registro MAPA
│
├── Tab 2: Diagnósticos (DiagnosticosTabWidget)
│   ├── Lista de diagnósticos deste defensivo
│   ├── Filtros por cultura e praga
│   └── Cards clicáveis para detalhe
│
├── Tab 3: Tecnologia (TecnologiaTabWidget)
│   ├── Tecnologia de aplicação
│   ├── Precauções humanas
│   ├── Precauções ambientais
│   ├── Manejo de resistência
│   ├── Compatibilidade de mistura
│   └── Manejo integrado (MIP/MID)
│
└── Tab 4: Comentários (ComentariosTabWidget)
    └── Sistema de comentários/avaliações
```

**Fluxo de Carregamento:**
```dart
Future<void> _loadData() async {
  try {
    // 1. Inicializa dados do defensivo
    await ref
        .read(detalheDefensivoNotifierProvider.notifier)
        .initializeData(widget.defensivoName, widget.fabricante);

    final state = ref.read(detalheDefensivoNotifierProvider);

    state.whenData((data) async {
      if (data.defensivoData != null) {
        final defensivoIdReg = data.defensivoData!.idReg;

        // 2. Busca diagnósticos relacionados por ID do defensivo
        await ref
            .read(diagnosticosNotifierProvider.notifier)
            .getDiagnosticosByDefensivo(
              defensivoIdReg,
              nomeDefensivo: data.defensivoData!.nomeComum,
            );

        // 3. Registra acesso para histórico
        await _recordDefensivoAccess(data.defensivoData!);
      }
    });
  } catch (e) {
    debugPrint('❌ ERRO ao carregar dados: $e');
  }
}
```

**Problema de Diagnósticos Vazios:**

O código contém debug extensivo para investigar por que alguns defensivos não retornam diagnósticos:

```dart
Future<void> _debugDiagnosticosStatus() async {
  debugPrint('🔧 [FORCE DEBUG] Verificando status dos diagnósticos...');

  final repository = sl<DiagnosticoHiveRepository>();
  final result = await repository.getAll();
  final allDiagnosticos = result.isSuccess ? result.data! : [];

  debugPrint('📊 [FORCE DEBUG] Repository direto: ${allDiagnosticos.length} diagnósticos');

  // Busca correspondências exatas por ID
  final exactMatches = allDiagnosticos
      .where((d) => d.fkIdDefensivo == defensivoId)
      .toList();

  debugPrint('Correspondências exatas por ID: ${exactMatches.length}');

  // Busca correspondências por nome (fallback)
  final nameMatches = allDiagnosticos
      .where((d) =>
          d.nomeDefensivo != null &&
          d.nomeDefensivo.toLowerCase().contains(defensivoNome.toLowerCase())
      )
      .toList();

  debugPrint('Correspondências por nome: ${nameMatches.length}');
}
```

### 5.3. DetalhePragaPage

**Responsabilidade:** Exibir informações completas de uma praga e defensivos recomendados.

**Localização:** `lib/features/pragas/presentation/pages/detalhe_praga_page.dart`

**Parâmetros de Entrada:**
```dart
final String pragaName;            // Nome comum
final String? pragaId;             // ID opcional
final String pragaScientificName;  // Nome científico
```

**Estrutura de Tabs:**
```dart
TabController(length: 3)
├── Tab 1: Informações (PragaInfoWidget)
│   ├── Informações Básicas
│   │   • Nome comum e científico
│   │   • Tipo de praga (Inseto/Doença/Daninha)
│   │   • Classificação taxonômica
│   ├── Descrição
│   ├── Sintomas de infestação
│   ├── Bioecologia
│   └── Métodos de controle
│
├── Tab 2: Diagnósticos (DiagnosticosPragaMockupWidget)
│   ├── Lista de defensivos recomendados
│   ├── Filtros por cultura
│   └── Cards clicáveis para detalhe
│
└── Tab 3: Comentários (ComentariosPragaWidget)
    └── Sistema de comentários/avaliações
```

**Fluxo de Carregamento:**
```dart
Future<void> _loadInitialData() async {
  try {
    final pragaNotifier = ref.read(detalhePragaNotifierProvider.notifier);
    final diagnosticosNotifier = ref.read(diagnosticosPragaNotifierProvider.notifier);

    // 1. Carrega dados da praga
    if (widget.pragaId != null && widget.pragaId!.isNotEmpty) {
      await pragaNotifier.initializeById(widget.pragaId!);
    } else {
      await pragaNotifier.initializeAsync(
        widget.pragaName,
        widget.pragaScientificName,
      );
    }

    final pragaState = await ref.read(detalhePragaNotifierProvider.future);

    // 2. Carrega diagnósticos (defensivos recomendados)
    if (pragaState.pragaData != null && pragaState.pragaData!.idReg.isNotEmpty) {
      await diagnosticosNotifier.loadDiagnosticos(
        pragaState.pragaData!.idReg,
        pragaName: widget.pragaName,
      );
    }
  } catch (e) {
    debugPrint('❌ Erro ao carregar dados iniciais: $e');
  }
}
```

---

## 🔍 Consulta de Hive Boxes e Ligação de Informações

### 6.1. DiagnosticoHiveRepository

**Localização:** `lib/core/data/repositories/diagnostico_hive_repository.dart`

**Métodos Principais:**

```dart
class DiagnosticoHiveRepository {
  late Box<DiagnosticoHive> _box;

  /// Busca todos os diagnósticos
  Future<RepositoryResult<List<DiagnosticoHive>>> getAll() async {
    try {
      final diagnosticos = _box.values.toList();
      return RepositoryResult.success(diagnosticos);
    } catch (e) {
      return RepositoryResult.error(
        RepositoryError(
          message: 'Erro ao buscar diagnósticos: ${e.toString()}',
          code: 'GET_ALL_ERROR',
        ),
      );
    }
  }

  /// Busca por ID único ou ObjectId
  Future<DiagnosticoHive?> getByIdOrObjectId(String id) async {
    try {
      // Tenta buscar por idReg primeiro
      final byIdReg = _box.values
          .firstWhereOrNull((d) => d.idReg == id);
      if (byIdReg != null) return byIdReg;

      // Fallback: busca por objectId
      return _box.values
          .firstWhereOrNull((d) => d.objectId == id);
    } catch (e) {
      return null;
    }
  }

  /// 🔑 CRUCIAL: Busca diagnósticos por ID do defensivo
  Future<List<DiagnosticoHive>> findByDefensivo(String idDefensivo) async {
    try {
      return _box.values
          .where((d) => d.fkIdDefensivo == idDefensivo)
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// 🔑 CRUCIAL: Busca diagnósticos por ID da praga
  Future<List<DiagnosticoHive>> findByPraga(String idPraga) async {
    try {
      return _box.values
          .where((d) => d.fkIdPraga == idPraga)
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// 🔑 CRUCIAL: Busca diagnósticos por ID da cultura
  Future<List<DiagnosticoHive>> findByCultura(String idCultura) async {
    try {
      return _box.values
          .where((d) => d.fkIdCultura == idCultura)
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// 🔑 CRUCIAL: Busca por múltiplos critérios (defensivo + cultura + praga)
  Future<List<DiagnosticoHive>> findByMultipleCriteria({
    String? defensivoId,
    String? culturaId,
    String? pragaId,
  }) async {
    try {
      var results = _box.values;

      if (defensivoId != null) {
        results = results.where((d) => d.fkIdDefensivo == defensivoId);
      }

      if (culturaId != null) {
        results = results.where((d) => d.fkIdCultura == culturaId);
      }

      if (pragaId != null) {
        results = results.where((d) => d.fkIdPraga == pragaId);
      }

      return results.toList();
    } catch (e) {
      return [];
    }
  }
}
```

### 6.2. Consultas Típicas

#### **Caso 1: Buscar Diagnóstico por ID**

```dart
// Usuário clica em card de diagnóstico
final diagnosticoId = "DG-00123";

// 1. Notifier solicita ao repository
final result = await _diagnosticosRepository.getById(diagnosticoId);

// 2. Repository busca no Hive
result.fold(
  (failure) => handleError(failure),
  (diagnostico) {
    // 3. DiagnosticoEntity retornado
    // 4. Extensão toDataMap() busca informações complementares
    final dataMap = await diagnosticoHive.toDataMap();

    // 5. UI exibe informações
    displayDiagnostico(dataMap);
  },
);
```

**Sequência de consultas no `toDataMap()`:**

```
┌──────────────────────────────────────────────┐
│ 1. DiagnosticoHive                           │
│    • fkIdDefensivo = "DF-54321"              │
│    • fkIdCultura = "CU-98765"                │
│    • fkIdPraga = "PR-13579"                  │
└───────────────┬──────────────────────────────┘
                │
                ├──> 2. Consulta FitossanitarioHive
                │    await fitossanitarioRepo.getById("DF-54321")
                │    ✅ Retorna: ingredienteAtivo, toxico, formulacao, modoAcao
                │
                ├──> 3. Consulta PragasHive
                │    await pragaRepo.getById("PR-13579")
                │    ✅ Retorna: nomeCientifico
                │
                └──> 4. Monta Map<String, String>
                     ✅ Retorna: 15 campos formatados para UI
```

#### **Caso 2: Buscar Diagnósticos por Defensivo**

```dart
// Usuário entra na página de detalhes do defensivo "Glifosato 480"
final defensivoIdReg = "DF-54321";

// 1. Notifier solicita diagnósticos
await ref
    .read(diagnosticosNotifierProvider.notifier)
    .getDiagnosticosByDefensivo(defensivoIdReg);

// 2. Repository executa consulta
final diagnosticosHive = await _hiveRepository.findByDefensivo(defensivoIdReg);
// WHERE fkIdDefensivo == "DF-54321"

// 3. Mapeia para entidades
final entities = diagnosticosHive
    .map((hive) => DiagnosticoMapper.fromHive(hive))
    .toList();

// 4. UI exibe lista de diagnósticos
// Exemplo:
// - Glifosato 480 → Soja → Buva
// - Glifosato 480 → Soja → Picão-preto
// - Glifosato 480 → Milho → Capim-colchão
```

#### **Caso 3: Buscar Defensivos por Praga**

```dart
// Usuário entra na página de detalhes da praga "Lagarta da Soja"
final pragaIdReg = "PR-13579";

// 1. Notifier solicita diagnósticos
await diagnosticosNotifier.loadDiagnosticos(
  pragaIdReg,
  pragaName: "Lagarta da Soja",
);

// 2. Repository executa consulta
final diagnosticosHive = await _hiveRepository.findByPraga(pragaIdReg);
// WHERE fkIdPraga == "PR-13579"

// 3. Para cada diagnóstico, resolve nomes
for (final diag in diagnosticosHive) {
  final nomeDefensivo = await diag.getDisplayNomeDefensivo();
  // Busca defensivo por diag.fkIdDefensivo

  final nomeCultura = await diag.getDisplayNomeCultura();
  // Busca cultura por diag.fkIdCultura
}

// 4. UI exibe lista de defensivos recomendados
// Exemplo:
// - Deltametrina 25 EC → Soja
// - Clorpirifós 480 EC → Soja
// - Lambda-cialotrina 50 EC → Milho
```

#### **Caso 4: Buscar Recomendações para Cultura + Praga**

```dart
// Usuário seleciona: Cultura="Soja" + Praga="Lagarta da Soja"
final idCultura = "CU-98765";
final idPraga = "PR-13579";

// 1. Notifier solicita recomendações
await ref
    .read(diagnosticosNotifierProvider.notifier)
    .getRecomendacoesPara(
      idCultura: idCultura,
      idPraga: idPraga,
      nomeCultura: "Soja",
      nomePraga: "Lagarta da Soja",
    );

// 2. Repository executa consulta múltipla
final diagnosticosHive = await _hiveRepository.findByMultipleCriteria(
  culturaId: idCultura,
  pragaId: idPraga,
);
// WHERE fkIdCultura == "CU-98765" AND fkIdPraga == "PR-13579"

// 3. UI exibe defensivos compatíveis
// Exemplo:
// - Deltametrina 25 EC (1.0-1.5 L/ha)
// - Clorpirifós 480 EC (0.8-1.2 L/ha)
// - Lambda-cialotrina 50 EC (0.3-0.5 L/ha)
```

---

## 🧩 Estrutura de Objetos para UI

### 7.1. DiagnosticoEntity (Domain Layer)

**Localização:** `lib/features/diagnosticos/domain/entities/diagnostico_entity.dart`

```dart
class DiagnosticoEntity {
  final String id;                           // idReg
  final String objectId;

  // Relacionamentos
  final String idDefensivo;                  // fkIdDefensivo
  final String idCultura;                    // fkIdCultura
  final String idPraga;                      // fkIdPraga

  // Nomes (display - não confiáveis)
  final String? nomeDefensivo;
  final String? nomeCultura;
  final String? nomePraga;

  // Value Objects
  final DosagemInfo dosagem;                 // dsMin, dsMax, um
  final AplicacaoInfo aplicacao;             // vazões, intervalos
  final String? epocaAplicacao;

  // Metadados
  final DiagnosticoCompletude completude;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const DiagnosticoEntity({
    required this.id,
    required this.objectId,
    required this.idDefensivo,
    required this.idCultura,
    required this.idPraga,
    this.nomeDefensivo,
    this.nomeCultura,
    this.nomePraga,
    required this.dosagem,
    required this.aplicacao,
    this.epocaAplicacao,
    required this.completude,
    this.createdAt,
    this.updatedAt,
  });
}
```

#### **Value Objects**

```dart
/// Informações de dosagem
class DosagemInfo {
  final double? dosageMin;
  final double dosageMax;
  final String unit;

  /// Média da dosagem
  double get dosageAverage =>
      dosageMin != null
          ? (dosageMin! + dosageMax) / 2
          : dosageMax;

  /// Dosagem formatada
  String get displayText =>
      dosageMin != null
          ? '$dosageMin - $dosageMax $unit'
          : '$dosageMax $unit';

  const DosagemInfo({
    this.dosageMin,
    required this.dosageMax,
    required this.unit,
  });
}

/// Informações de aplicação
class AplicacaoInfo {
  // Aplicação terrestre
  final double? minAplicacaoTerrestre;
  final double? maxAplicacaoTerrestre;
  final String? unidadeTerrestre;

  // Aplicação aérea
  final double? minAplicacaoAerea;
  final double? maxAplicacaoAerea;
  final String? unidadeAerea;

  // Intervalos
  final String? intervaloAplicacao;
  final String? intervaloSeguranca;

  /// Tipos de aplicação disponíveis
  List<TipoAplicacao> get tiposDisponiveis {
    final tipos = <TipoAplicacao>[];

    if (maxAplicacaoTerrestre != null) {
      tipos.add(TipoAplicacao.terrestre);
    }

    if (maxAplicacaoAerea != null) {
      tipos.add(TipoAplicacao.aerea);
    }

    return tipos;
  }

  const AplicacaoInfo({
    this.minAplicacaoTerrestre,
    this.maxAplicacaoTerrestre,
    this.unidadeTerrestre,
    this.minAplicacaoAerea,
    this.maxAplicacaoAerea,
    this.unidadeAerea,
    this.intervaloAplicacao,
    this.intervaloSeguranca,
  });
}

/// Enum para tipo de aplicação
enum TipoAplicacao {
  terrestre,
  aerea,
  ambos,
}

/// Enum para completude do diagnóstico
enum DiagnosticoCompletude {
  completo,       // Todos os campos preenchidos
  parcial,        // Alguns campos faltando
  minimo,         // Apenas campos essenciais
}
```

### 7.2. DefensivoEntity (Domain Layer)

**Localização:** `lib/features/DetalheDefensivos/domain/entities/defensivo_entity.dart`

```dart
class DefensivoEntity {
  final String idReg;
  final String nomeComum;
  final String nomeTecnico;
  final String fabricante;
  final String ingredienteAtivo;
  final String toxico;
  final String inflamavel;
  final String corrosivo;
  final String modoAcao;
  final String classeAgronomica;
  final String classAmbiental;
  final String formulacao;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const DefensivoEntity({
    required this.idReg,
    required this.nomeComum,
    required this.nomeTecnico,
    required this.fabricante,
    required this.ingredienteAtivo,
    required this.toxico,
    required this.inflamavel,
    required this.corrosivo,
    required this.modoAcao,
    required this.classeAgronomica,
    required this.classAmbiental,
    required this.formulacao,
    this.createdAt,
    this.updatedAt,
  });
}

/// Entidade estendida com informações complementares
class DefensivoDetailsEntity extends DefensivoEntity {
  final String? embalagens;
  final String? tecnologia;
  final String? precaucoesHumanas;
  final String? precaucoesAmbientais;
  final String? manejoResistencia;
  final String? compatibilidade;
  final String? manejoIntegrado;
  final String? mapa;
  final String? quantProduto;
  final bool comercializado;
  final bool elegivel;

  const DefensivoDetailsEntity({
    required super.idReg,
    required super.nomeComum,
    required super.nomeTecnico,
    required super.fabricante,
    required super.ingredienteAtivo,
    required super.toxico,
    required super.inflamavel,
    required super.corrosivo,
    required super.modoAcao,
    required super.classeAgronomica,
    required super.classAmbiental,
    required super.formulacao,
    super.createdAt,
    super.updatedAt,
    this.embalagens,
    this.tecnologia,
    this.precaucoesHumanas,
    this.precaucoesAmbientais,
    this.manejoResistencia,
    this.compatibilidade,
    this.manejoIntegrado,
    this.mapa,
    this.quantProduto,
    required this.comercializado,
    required this.elegivel,
  });

  /// Factory para criar a partir de FitossanitarioHive + FitossanitarioInfoHive
  factory DefensivoDetailsEntity.fromHive(FitossanitarioHive hive) {
    // Busca informações complementares se disponíveis
    // ...
  }
}
```

### 7.3. Map<String, String> - Objeto Final para UI

Retornado por `toDataMap()` e usado pelos widgets de apresentação:

```dart
{
  // ===== IDENTIFICAÇÃO =====
  'nomeDefensivo': 'Glifosato 480 g/L',       // ✅ Resolvido dinamicamente
  'nomeCultura': 'Soja',                       // ✅ Resolvido dinamicamente
  'nomePraga': 'Buva',                         // ✅ Resolvido dinamicamente
  'nomeCientifico': 'Conyza bonariensis',      // ✅ Resolvido dinamicamente

  // ===== DOSAGEM E APLICAÇÃO =====
  'dosagem': '2.0 - 3.0 L/ha',                 // ✅ Formatado
  'vazaoTerrestre': '100 - 200 L/ha',          // ✅ Formatado
  'vazaoAerea': '30 - 50 L/ha',                // ✅ Formatado
  'intervaloAplicacao': '15 dias',             // ✅ Formatado
  'epocaAplicacao': 'Pré-emergência',          // ✅ Direto do Hive

  // ===== INFORMAÇÕES TÉCNICAS =====
  'ingredienteAtivo': 'Glifosato',             // ✅ Do defensivo
  'toxico': 'Classe III (Moderadamente Tóxico)', // ✅ Do defensivo
  'formulacao': 'SL (Concentrado Solúvel)',    // ✅ Do defensivo
  'modoAcao': 'Sistêmico',                     // ✅ Do defensivo

  // ===== PLACEHOLDERS =====
  'intervaloSeguranca': 'Consulte a bula do produto',
  'classAmbiental': 'Consulte a bula do produto',
  'classeAgronomica': 'Consulte a bula do produto',
  'mapa': 'Consulte o registro MAPA',
  'tecnologia': 'Aplicar conforme recomendações técnicas. Consulte um engenheiro agrônomo.',
}
```

**Uso nos Widgets:**

```dart
// DiagnosticoInfoWidget
Text(diagnosticoData['nomeDefensivo'] ?? 'N/A')
Text(diagnosticoData['nomeCultura'] ?? 'N/A')
Text(diagnosticoData['nomePraga'] ?? 'N/A')

// DiagnosticoDetalhesWidget
Text(diagnosticoData['ingredienteAtivo'] ?? 'N/A')
Text(diagnosticoData['toxico'] ?? 'N/A')
Text(diagnosticoData['formulacao'] ?? 'N/A')
Text(diagnosticoData['modoAcao'] ?? 'N/A')

// AplicacaoInstrucoesWidget
Text(diagnosticoData['dosagem'] ?? 'N/A')
Text(diagnosticoData['vazaoTerrestre'] ?? 'N/A')
Text(diagnosticoData['vazaoAerea'] ?? 'N/A')
Text(diagnosticoData['intervaloAplicacao'] ?? 'N/A')
Text(diagnosticoData['intervaloSeguranca'] ?? 'N/A')
```

### 7.4. Estados Riverpod

#### **DetalheDiagnosticoState**

```dart
class DetalheDiagnosticoState {
  final DiagnosticoEntity? diagnostico;           // Entidade de domínio
  final DiagnosticoHive? diagnosticoHive;         // Modelo Hive (backup)
  final Map<String, String> diagnosticoData;      // 🔑 Dados para UI
  final bool isFavorited;
  final bool isPremium;
  final bool isLoading;
  final bool isSharingContent;
  final String? errorMessage;

  const DetalheDiagnosticoState({
    this.diagnostico,
    this.diagnosticoHive,
    required this.diagnosticoData,
    required this.isFavorited,
    required this.isPremium,
    required this.isLoading,
    required this.isSharingContent,
    this.errorMessage,
  });

  bool get hasError => errorMessage != null;
  bool get hasDiagnostico => diagnostico != null;
}
```

#### **DiagnosticosState** (Lista de diagnósticos)

```dart
class DiagnosticosState {
  final List<DiagnosticoEntity> diagnosticos;     // Lista principal
  final DiagnosticosStats? stats;                 // Estatísticas globais
  final DiagnosticoFiltersData? filtersData;      // Dados para filtros
  final DiagnosticoSearchFilters currentFilters;  // Filtros ativos

  // Contexto de busca atual
  final String? contextoCultura;
  final String? contextoPraga;
  final String? contextoDefensivo;

  final bool isLoading;
  final bool isLoadingMore;                       // Paginação
  final String? errorMessage;

  /// Summary da busca atual
  String get searchSummary {
    if (hasContext) {
      final parts = <String>[];
      if (contextoDefensivo != null) parts.add('Defensivo: $contextoDefensivo');
      if (contextoCultura != null) parts.add('Cultura: $contextoCultura');
      if (contextoPraga != null) parts.add('Praga: $contextoPraga');

      return '${diagnosticos.length} recomendações para ${parts.join(' + ')}';
    }

    return 'Mostrando ${diagnosticos.length} diagnósticos';
  }

  bool get hasData => diagnosticos.isNotEmpty;
  bool get hasContext =>
      contextoCultura != null ||
      contextoPraga != null ||
      contextoDefensivo != null;
}
```

---

## ⚠️ Problemas Identificados no Código Fonte

### 8.1. Abordagem: Campos Cached como Fallback

**Severidade:** ℹ️ INFORMACIONAL

**Localização:** `DiagnosticoHive.nomeDefensivo`, `nomeCultura`, `nomePraga`

**Descrição:**
O modelo `DiagnosticoHive` armazena nomes das entidades relacionadas, mas **esses campos não devem ser a fonte primária de dados**. Sempre consulte as boxes relacionadas:

**Modelo de Dados:**
```dart
@HiveType(typeId: 101)
class DiagnosticoHive extends HiveObject {
  @HiveField(4) String fkIdDefensivo;         // ✅ Source of truth - usar sempre
  @HiveField(5) String? nomeDefensivo;        // ⚠️ Fallback apenas

  @HiveField(6) String fkIdCultura;           // ✅ Source of truth - usar sempre
  @HiveField(7) String? nomeCultura;          // ⚠️ Fallback apenas

  @HiveField(8) String fkIdPraga;             // ✅ Source of truth - usar sempre
  @HiveField(9) String? nomePraga;            // ⚠️ Fallback apenas
}
```

**Solução Implementada:**
```dart
// ✅ SEMPRE consulta a box relacionada
Future<String> getDisplayNomeDefensivo() async {
  Box<FitossanitarioHive>? box;
  
  try {
    // 1. Abrir box
    box = await Hive.openBox<FitossanitarioHive>('fitossanitarios');
    
    // 2. Consultar defensivo
    final defensivo = box.values.firstWhere(
      (f) => f.idReg == fkIdDefensivo,
      orElse: () => null,
    );

    // 3. Retornar nome atualizado
    if (defensivo != null && defensivo.nomeComum.isNotEmpty) {
      return defensivo.nomeComum;  // ✅ Sempre atualizado
    }
  } catch (e) {
    debugPrint('❌ Erro: $e');
  } finally {
    // 4. Fechar box
    await box?.close();
  }

  // Fallback para campo cached apenas se consulta falhar
  return nomeDefensivo ?? 'Defensivo não identificado';
}

// ❌ NUNCA usar diretamente
// String nomeIncorreto = diagnostico.nomeDefensivo;  // ERRADO!
```

**Regras de Uso:**
- ✅ Sempre usar métodos `getDisplayNome*()` que consultam boxes
- ✅ Campos cached (`nomeDefensivo`, etc.) são apenas fallback de erro
- ✅ Sempre fechar boxes após consulta (try-finally)
- ❌ Nunca acessar campos de nome diretamente na UI

### 8.2. Otimização: Consulta Eficiente com Boxes Abertas

**Severidade:** ℹ️ INFORMACIONAL

**Localização:** `toDataMap()`, list rendering

**Descrição:**
Para renderizar listas de diagnósticos, o padrão recomendado é abrir as boxes uma vez e fechar ao final:

```dart
// ✅ Padrão otimizado: abrir boxes uma vez
Future<List<Map<String, String>>> loadDiagnosticosParaLista(
  List<DiagnosticoHive> diagnosticos,
) async {
  Box<FitossanitarioHive>? defBox;
  Box<PragasHive>? pragaBox;
  Box<CulturaHive>? cultBox;
  
  try {
    // 1. Abrir todas as boxes necessárias UMA VEZ
    defBox = await Hive.openBox<FitossanitarioHive>('fitossanitarios');
    pragaBox = await Hive.openBox<PragasHive>('pragas');
    cultBox = await Hive.openBox<CulturaHive>('culturas');

    // 2. Processar todos os diagnósticos
    final results = <Map<String, String>>[];
    
    for (final diag in diagnosticos) {
      // Consultar defensivo
      final defensivo = defBox.values.firstWhere(
        (f) => f.idReg == diag.fkIdDefensivo,
        orElse: () => null,
      );
      
      // Consultar praga
      final praga = pragaBox.values.firstWhere(
        (p) => p.idReg == diag.fkIdPraga,
        orElse: () => null,
      );
      
      // Consultar cultura
      final cultura = cultBox.values.firstWhere(
        (c) => c.idReg == diag.fkIdCultura,
        orElse: () => null,
      );

      results.add({
        'nomeDefensivo': defensivo?.nomeComum ?? 'N/A',
        'nomePraga': praga?.nomeComum ?? 'N/A',
        'nomeCultura': cultura?.cultura ?? 'N/A',
        'dosagem': diag.displayDosagem,
        // ... outros campos
      });
    }
    
    return results;
  } catch (e) {
    debugPrint('❌ Erro: $e');
    return [];
  } finally {
    // 3. Fechar TODAS as boxes
    await defBox?.close();
    await pragaBox?.close();
    await cultBox?.close();
  }
}
```

**Vantagens:**
- ✅ Boxes abertas uma única vez para múltiplas consultas
- ✅ Consultas in-memory são extremamente rápidas
- ✅ Gerenciamento explícito de recursos
- ✅ Sem overhead de múltiplas aberturas/fechamentos

**Recomendações:**
- ✅ Abrir boxes uma vez para processar lotes
- ✅ Usar try-finally para garantir fechamento
- ✅ Para consultas únicas, abrir e fechar imediatamente
- ⚠️ Evitar manter boxes abertas por muito tempo

**Código Otimizado Sugerido:**
```dart
/// Helper para processar em lote
Future<Map<String, DiagnosticoDisplayData>> batchLoadDiagnosticos(
  List<DiagnosticoHive> diagnosticos,
) async {
  final defensivoIds = diagnosticos.map((d) => d.fkIdDefensivo).toSet();
  final pragaIds = diagnosticos.map((d) => d.fkIdPraga).toSet();
  final culturaIds = diagnosticos.map((d) => d.fkIdCultura).toSet();

  // 2. Busca em batch (3 consultas ao invés de 300)
  final defensivos = await _fetchDefensivosInBatch(defensivoIds);
  final pragas = await _fetchPragasInBatch(pragaIds);
  final culturas = await _fetchCulturasInBatch(culturaIds);

  // 3. Monta mapa de resultado
  return {
    for (final diag in diagnosticos)
      diag.idReg: DiagnosticoDisplayData(
        nomeDefensivo: defensivos[diag.fkIdDefensivo]?.nomeComum ?? 'N/A',
        nomePraga: pragas[diag.fkIdPraga]?.nomeComum ?? 'N/A',
        nomeCultura: culturas[diag.fkIdCultura]?.cultura ?? 'N/A',
      )
  };
}
```

### 8.3. Problema: Silent Failures em toDataMap()

**Severidade:** 🟡 MÉDIA

**Localização:** `diagnostico_hive_extension.dart:100-154`

**Descrição:**
Erros de busca são silenciosamente ignorados, retornando valores placeholder sem notificar o usuário:

```dart
try {
  final defensivo = await fitossanitarioRepo.getById(fkIdDefensivo);
  if (defensivo != null) {
    ingredienteAtivo = defensivo.ingredienteAtivo!;
  }
} catch (e) {
  // ❌ Ignora completamente o erro
  // ingredienteAtivo mantém: 'Consulte a bula do produto'
}
```

**Impacto:**
- ⚠️ Usuário não sabe que há dados faltando
- ⚠️ Impossível debugar problemas de relacionamento quebrado
- ⚠️ Dados podem parecer corretos mas estarem incompletos

**Recomendação Final:**
- ✅ Logar erros para analytics/crash reporting
- ✅ Adicionar campo `warnings` no state
- ✅ Exibir badge de "informações incompletas" na UI
- ✅ Permitir retry manual

**Código Melhorado Sugerido:**
```dart
Future<(Map<String, String>, List<String>)> toDataMapWithWarnings() async {
  final warnings = <String>[];
  String ingredienteAtivo = 'Consulte a bula do produto';

  try {
    final defensivo = await fitossanitarioRepo.getById(fkIdDefensivo);
    if (defensivo != null) {
      ingredienteAtivo = defensivo.ingredienteAtivo!;
    } else {
      warnings.add('Defensivo $fkIdDefensivo não encontrado');
    }
  } catch (e) {
    warnings.add('Erro ao buscar defensivo: $e');
    // Logar para analytics
    FirebaseCrashlytics.instance.recordError(e, stack);
  }

  return (dataMap, warnings);
}
```

### 8.4. Problema: Falta de Validação de Foreign Keys

**Severidade:** 🟡 MÉDIA

**Localização:** Repositórios, Data loaders

**Descrição:**
Não há validação se as FKs existem antes de salvar diagnósticos:

```dart
// ❌ Pode salvar com FK inválida
DiagnosticoHive(
  fkIdDefensivo: 'INVALID-ID',  // Não existe!
  fkIdCultura: 'CU-123',
  fkIdPraga: 'PR-456',
  // ...
)
```

**Impacto:**
- ⚠️ Diagnósticos órfãos (sem relacionamento válido)
- ⚠️ Busca retorna resultados mas não consegue resolver nomes
- ⚠️ Dados inconsistentes no banco

**Recomendação Final:**
- ✅ Implementar validação no data loader
- ✅ Adicionar método `validateEntity()` no resolver
- ✅ Executar validação periódica em background
- ✅ Criar relatório de integridade referencial

**Código Sugerido:**
```dart
Future<void> validateDiagnosticosIntegrity() async {
  final diagnosticos = await _diagnosticoRepo.getAll();
  final issues = <String>[];

  for (final diag in diagnosticos) {
    // Valida defensivo
    final defensivo = await _defensivoRepo.getById(diag.fkIdDefensivo);
    if (defensivo == null) {
      issues.add('Diagnóstico ${diag.idReg}: defensivo ${diag.fkIdDefensivo} não existe');
    }

    // Valida praga
    final praga = await _pragaRepo.getById(diag.fkIdPraga);
    if (praga == null) {
      issues.add('Diagnóstico ${diag.idReg}: praga ${diag.fkIdPraga} não existe');
    }

    // Valida cultura
    final cultura = await _culturaRepo.getById(diag.fkIdCultura);
    if (cultura == null) {
      issues.add('Diagnóstico ${diag.idReg}: cultura ${diag.fkIdCultura} não existe');
    }
  }

  if (issues.isNotEmpty) {
    // Reportar para analytics
    FirebaseAnalytics.instance.logEvent(
      name: 'data_integrity_issues',
      parameters: {'count': issues.length},
    );
  }
}
```

### 8.5. Solução: Consulta Direta sem Cache

**Status:** ✅ RESOLVIDO

**Abordagem:** Consultas diretas às Hiveboxes

**Descrição:**
Sistema foi projetado para **NÃO** utilizar cache. Todas as consultas seguem o padrão:
1. Abrir Hivebox
2. Consultar dados
3. Fechar Hivebox

```dart
// ✅ Padrão correto sem cache
Future<String> getNomeDefensivo(String id) async {
  Box<FitossanitarioHive>? box;
  
  try {
    box = await Hive.openBox<FitossanitarioHive>('fitossanitarios');
    
    final defensivo = box.values.firstWhere(
      (f) => f.idReg == id,
      orElse: () => null,
    );
    
    return defensivo?.nomeComum ?? 'Não identificado';
  } finally {
    await box?.close();
  }
}
```

**Vantagens:**
- ✅ Dados sempre atualizados
- ✅ Sem inconsistências entre usuários
- ✅ Gerenciamento explícito de recursos
- ✅ Sem complexidade de invalidação de cache

**Pontos de Atenção:**
- ⚠️ Boxes devem ser sempre fechadas (usar try-finally)
- ⚠️ Para múltiplas consultas, abrir boxes uma única vez e fechar ao final
- ⚠️ Monitorar vazamento de boxes abertas

### 8.6. Problema: Debug Excessivo em Produção

**Severidade:** 🟢 BAIXA

**Localização:** `detalhe_defensivo_page.dart:112-246`

**Descrição:**
Código de debug extremamente verboso permanece ativo em produção:

```dart
Future<void> _debugDiagnosticosStatus() async {
  debugPrint('🔧 [FORCE DEBUG] Verificando status...');
  debugPrint('📊 [FORCE DEBUG] Repository direto: ${count}');
  debugPrint('⚠️ [FORCE DEBUG] Nenhum diagnóstico...');
  debugPrint('🔄 [FORCE DEBUG] Chamando DataLoader...');
  debugPrint('✅ [FORCE DEBUG] Carregamento bem-sucedido!');
  // ... 134 linhas de debug
}
```

**Impacto:**
- ⚠️ Poluição de logs
- ⚠️ Pequeno overhead de performance
- ⚠️ Exposição de lógica interna

**Recomendação Final:**
- ✅ Remover ou condicionar com `kDebugMode`
- ✅ Usar logger estruturado (como `logger` package)
- ✅ Criar build flavors (debug/release)

### 8.7. Problema: Falta de Tratamento de Dados Vazios

**Severidade:** 🟡 MÉDIA

**Localização:** Diversos widgets

**Descrição:**
Alguns campos podem estar vazios mas não têm fallback adequado:

```dart
// ❌ Pode retornar string vazia
Text(diagnosticoData['intervaloSeguranca'])

// ✅ Deveria ser
Text(diagnosticoData['intervaloSeguranca']?.isNotEmpty == true
    ? diagnosticoData['intervaloSeguranca']!
    : 'Não especificado')
```

**Impacto:**
- ⚠️ UI com espaços vazios
- ⚠️ UX ruim (usuário não sabe se é erro ou ausência de dado)

**Recomendação Final:**
- ✅ Sempre usar `?? 'Valor padrão'`
- ✅ Criar widget `InfoField` com tratamento padrão
- ✅ Validar completude no mapper

### 8.8. Problema: Falta de Indexação no Hive

**Severidade:** 🟠 ALTA

**Localização:** Inicialização Hive

**Descrição:**
Consultas em Hive não estão indexadas, forçando full table scan:

```dart
// ❌ Percorre todos os 5000 registros toda vez
_box.values.where((d) => d.fkIdDefensivo == idDefensivo).toList();
```

**Impacto:**
- 🐢 Consultas lentas em boxes grandes
- 🐢 Performance degrada com crescimento dos dados

**Recomendação Final:**
- ✅ Usar `HiveObject.key` como índice primário
- ✅ Criar índices secundários manualmente
- ✅ Considerar migrar para SQLite/Drift para queries complexas

**Código Sugerido:**
```dart
// Manter índices manuais em memória
final Map<String, List<String>> _defensivoIndex = {};

void _buildIndex() {
  _defensivoIndex.clear();
  for (final diag in _box.values) {
    _defensivoIndex
        .putIfAbsent(diag.fkIdDefensivo, () => [])
        .add(diag.key.toString());
  }
}

List<DiagnosticoHive> findByDefensivo(String id) {
  final keys = _defensivoIndex[id] ?? [];
  return keys.map((k) => _box.get(k)!).toList();
}
```

---

## 📊 Completude do Sistema

### 9.1. Features Implementadas

| Feature | Status | Qualidade | Observações |
|---------|--------|-----------|-------------|
| **Modelos Hive** | ✅ 100% | ⭐⭐⭐⭐⭐ | Estrutura completa e bem definida |
| **Repositórios** | ✅ 100% | ⭐⭐⭐⭐ | Implementados, mas sem índices |
| **Extensões de Formatação** | ✅ 100% | ⭐⭐⭐⭐ | Funcionais, mas com silent failures |
| **DiagnosticoEntityResolver** | ✅ 100% | ⭐⭐⭐ | Cache funcional, TTL pode ser melhorado |
| **Clean Architecture** | ✅ 100% | ⭐⭐⭐⭐⭐ | Separação de camadas rigorosa |
| **Páginas de Detalhes** | ✅ 100% | ⭐⭐⭐⭐ | UI completa, UX pode melhorar |
| **Busca por Defensivo** | ✅ 100% | ⭐⭐⭐⭐ | Funcional |
| **Busca por Praga** | ✅ 100% | ⭐⭐⭐⭐ | Funcional |
| **Busca por Cultura** | ✅ 100% | ⭐⭐⭐⭐ | Funcional |
| **Busca por Combinação** | ✅ 100% | ⭐⭐⭐⭐ | Funcional |
| **Favoritos** | ✅ 100% | ⭐⭐⭐⭐ | Integrado |
| **Compartilhamento** | ✅ 90% | ⭐⭐⭐ | Implementado mas básico |
| **Data Loaders** | ✅ 100% | ⭐⭐⭐⭐ | Inicialização funcional |
| **Riverpod Providers** | ✅ 100% | ⭐⭐⭐⭐⭐ | Migração completa |

### 9.2. Features Faltando/Incompletas

| Feature | Status | Prioridade | Esforço |
|---------|--------|------------|---------|
| **Validação de Integridade Referencial** | ❌ 0% | 🔴 Alta | 8h |
| **Índices Otimizados Hive** | ❌ 0% | 🔴 Alta | 12h |
| **Batch Loading Otimizado** | ❌ 0% | 🔴 Alta | 16h |
| **Tratamento de Erros Visível** | 🟡 30% | 🟠 Média | 6h |
| **Invalidação Inteligente de Cache** | 🟡 50% | 🟠 Média | 4h |
| **Testes Unitários** | 🟡 20% | 🟠 Média | 24h |
| **Testes de Integração** | ❌ 0% | 🟠 Média | 16h |
| **Analytics de Uso** | 🟡 40% | 🟢 Baixa | 4h |
| **Busca Avançada com Filtros** | ✅ 80% | 🟢 Baixa | 4h |
| **Exportação de Diagnósticos** | ❌ 0% | 🟢 Baixa | 8h |
| **Sincronização com Backend** | ❌ 0% | 🔵 Futura | 40h+ |

### 9.3. Estimativa de Completude Global

```
┌─────────────────────────────────────────────────────┐
│  COMPLETUDE GERAL DO SISTEMA: 85%                  │
├─────────────────────────────────────────────────────┤
│                                                     │
│  ████████████████████████████████████████░░░░░░░   │
│  0%  10%  20%  30%  40%  50%  60%  70%  80%  90%  100%│
│                                                     │
├─────────────────────────────────────────────────────┤
│  ✅ Funcionalidades Core: 95%                       │
│  ⚠️ Performance: 70%                                │
│  ⚠️ Robustez: 75%                                   │
│  ✅ Arquitetura: 95%                                │
│  ⚠️ Testes: 20%                                     │
│  ✅ UX: 85%                                          │
└─────────────────────────────────────────────────────┘
```

---

## 🎯 Recomendações Prioritárias

### 10.1. Ações Imediatas (Sprint 1-2 semanas)

#### **1. Implementar Gerenciamento Adequado de Boxes**
**Impacto:** 🔴 CRÍTICO
**Esforço:** 16h

```dart
// Objetivo: Garantir abertura e fechamento adequado de boxes
// Pattern: Open -> Query -> Close

/// Exemplo de consulta simples
Future<FitossanitarioHive?> getDefensivoById(String id) async {
  Box<FitossanitarioHive>? box;
  
  try {
    // 1. Abrir box
    box = await Hive.openBox<FitossanitarioHive>('fitossanitarios');
    
    // 2. Consultar
    final result = box.values.firstWhere(
      (f) => f.idReg == id,
      orElse: () => null,
    );
    
    return result;
  } catch (e) {
    debugPrint('❌ Erro: $e');
    return null;
  } finally {
    // 3. Fechar (SEMPRE!)
    await box?.close();
  }
}

/// Exemplo de consulta com múltiplos relacionamentos
Future<List<DiagnosticoDisplayData>> loadDiagnosticosWithRelations(
  List<String> diagnosticoIds,
) async {
  Box<DiagnosticoHive>? diagBox;
  Box<FitossanitarioHive>? defBox;
  Box<PragasHive>? pragaBox;
  Box<CulturaHive>? cultBox;
  
  try {
    // 1. Abrir todas as boxes necessárias
    diagBox = await Hive.openBox<DiagnosticoHive>('diagnosticos');
    defBox = await Hive.openBox<FitossanitarioHive>('fitossanitarios');
    pragaBox = await Hive.openBox<PragasHive>('pragas');
    cultBox = await Hive.openBox<CulturaHive>('culturas');

    // 2. Consultar dados
    final diagnosticos = diagBox.values
        .where((d) => diagnosticoIds.contains(d.idReg))
        .toList();

    // 3. Montar objetos display
    final results = <DiagnosticoDisplayData>[];
    
    for (final diag in diagnosticos) {
      final defensivo = defBox.values.firstWhere(
        (f) => f.idReg == diag.fkIdDefensivo,
        orElse: () => null,
      );
      
      final praga = pragaBox.values.firstWhere(
        (p) => p.idReg == diag.fkIdPraga,
        orElse: () => null,
      );
      
      final cultura = cultBox.values.firstWhere(
        (c) => c.idReg == diag.fkIdCultura,
        orElse: () => null,
      );

      results.add(DiagnosticoDisplayData(
        diagnostico: diag,
        defensivo: defensivo,
        praga: praga,
        cultura: cultura,
      ));
    }
    
    return results;
  } catch (e) {
    debugPrint('❌ Erro: $e');
    return [];
  } finally {
    // 4. Fechar TODAS as boxes
    await diagBox?.close();
    await defBox?.close();
    await pragaBox?.close();
    await cultBox?.close();
  }
}
```

#### **2. Adicionar Validação de Integridade**
**Impacto:** 🔴 CRÍTICO
**Esforço:** 8h

```dart
// Executar na inicialização ou periodicamente
Future<IntegrityReport> validateDataIntegrity() async {
  final issues = <IntegrityIssue>[];
  final diagnosticos = await _diagnosticoRepo.getAll();

  for (final diag in diagnosticos) {
    // Valida FKs
    if (!await _defensivoRepo.exists(diag.fkIdDefensivo)) {
      issues.add(IntegrityIssue.brokenForeignKey(
        'diagnostico',
        diag.idReg,
        'defensivo',
        diag.fkIdDefensivo,
      ));
    }
    // ... validar praga e cultura
  }

  return IntegrityReport(
    totalDiagnosticos: diagnosticos.length,
    issues: issues,
    timestamp: DateTime.now(),
  );
}
```

#### **3. Melhorar Tratamento de Erros**
**Impacto:** 🟠 ALTA
**Esforço:** 6h

```dart
// State com warnings visíveis
class DetalheDiagnosticoState {
  // ... campos existentes
  final List<String> warnings;  // Novo!

  bool get hasWarnings => warnings.isNotEmpty;
}

// toDataMapWithWarnings() retorna warnings
final (dataMap, warnings) = await diagnosticoHive.toDataMapWithWarnings();

state = state.copyWith(
  diagnosticoData: dataMap,
  warnings: warnings,
);

// UI exibe warnings
if (state.hasWarnings) {
  WarningBanner(
    message: 'Algumas informações podem estar incompletas',
    warnings: state.warnings,
  );
}
```

### 10.2. Melhorias de Médio Prazo (Sprint 3-4)

#### **4. Implementar Helper de Gerenciamento de Boxes**
**Impacto:** 🟠 MÉDIA
**Esforço:** 6h

```dart
/// Classe auxiliar para gerenciar abertura e fechamento de boxes
class HiveBoxManager {
  /// Executa operação com box garantindo fechamento
  static Future<T> withBox<T, B>(
    String boxName,
    Future<T> Function(Box<B> box) operation,
  ) async {
    Box<B>? box;
    
    try {
      box = await Hive.openBox<B>(boxName);
      return await operation(box);
    } finally {
      await box?.close();
    }
  }
  
  /// Executa operação com múltiplas boxes
  static Future<T> withMultipleBoxes<T>(
    Map<String, Type> boxes,
    Future<T> Function(Map<String, Box>) operation,
  ) async {
    final openedBoxes = <String, Box>{};
    
    try {
      // Abrir todas as boxes
      for (final entry in boxes.entries) {
        openedBoxes[entry.key] = await Hive.openBox(entry.key);
      }
      
      return await operation(openedBoxes);
    } finally {
      // Fechar todas as boxes
      for (final box in openedBoxes.values) {
        await box.close();
      }
    }
  }
}

// Uso:
final defensivo = await HiveBoxManager.withBox<FitossanitarioHive?, FitossanitarioHive>(
  'fitossanitarios',
  (box) async {
    return box.values.firstWhere(
      (f) => f.idReg == id,
      orElse: () => null,
    );
  },
);
```

#### **5. Adicionar Testes**
**Impacto:** 🟠 MÉDIA
**Esforço:** 24h (unitários) + 16h (integração)

- ✅ Testes unitários para repositórios
- ✅ Testes de integração para fluxos completos
- ✅ Testes de performance para batch loading
- ✅ Testes de regressão para resolução de nomes

#### **6. Criar Índices Manuais**
**Impacto:** 🟠 MÉDIA
**Esforço:** 12h

```dart
class IndexedDiagnosticoRepository {
  final Map<String, List<String>> _defensivoIndex = {};
  final Map<String, List<String>> _pragaIndex = {};
  final Map<String, List<String>> _culturaIndex = {};

  Future<void> rebuildIndexes() async {
    _defensivoIndex.clear();
    _pragaIndex.clear();
    _culturaIndex.clear();

    for (final diag in _box.values) {
      _defensivoIndex
          .putIfAbsent(diag.fkIdDefensivo, () => [])
          .add(diag.key.toString());
      // ... outros índices
    }
  }

  List<DiagnosticoHive> findByDefensivo(String id) {
    final keys = _defensivoIndex[id] ?? [];
    return keys.map((k) => _box.get(k)!).toList();
  }
}
```

### 10.3. Melhorias de Longo Prazo

#### **7. Migrar para Drift (SQLite)**
**Impacto:** 🔵 FUTURA
**Esforço:** 40h+

Se o volume de dados crescer muito (>10k diagnósticos), considerar migração para SQLite com Drift para:
- Queries SQL otimizadas
- Índices nativos do banco
- Joins eficientes
- Transações ACID

#### **8. Implementar Sincronização com Backend**
**Impacto:** 🔵 FUTURA
**Esforço:** 60h+

Para dados dinâmicos:
- Delta sync (apenas mudanças)
- Conflict resolution
- Offline-first com queue de sincronização

---

## 📝 Checklist de Verificação

### Para Desenvolvedores

#### **Regras de Acesso a Dados**
- [ ] **Sempre** usar `getDisplayNome*()` ao invés de campos cached
- [ ] **Nunca** confiar em `nomeDefensivo`, `nomeCultura`, `nomePraga` do DiagnosticoHive
- [ ] **Sempre** abrir boxes no início da operação e fechar no bloco finally
- [ ] **Nunca** deixar boxes abertas sem fechamento explícito
- [ ] Para listas, abrir boxes uma vez e fechar após processar todos os itens
- [ ] Para consultas únicas, usar padrão: abrir -> consultar -> fechar

#### **Gerenciamento de Boxes**
- [ ] Usar try-finally para garantir fechamento de boxes
- [ ] Considerar usar HiveBoxManager helper para operações complexas
- [ ] Monitorar boxes abertas em modo debug
- [ ] Evitar abrir a mesma box múltiplas vezes em sequência
- [ ] Fechar boxes o mais rápido possível após consulta

#### **Qualidade e Performance**
- [ ] Validar FKs antes de salvar novos diagnósticos
- [ ] Logar erros de resolução para analytics
- [ ] Testar com dados grandes (>1000 diagnósticos)
- [ ] Verificar performance de scroll em listas
- [ ] Adicionar testes para novos use cases
- [ ] Documentar breaking changes
- [ ] Atualizar este documento ao modificar estrutura

### Para QA/Testers

- [ ] Verificar se nomes estão sempre atualizados
- [ ] Testar navegação Defensivo → Diagnósticos
- [ ] Testar navegação Praga → Defensivos
- [ ] Verificar busca por cultura + praga
- [ ] Testar compartilhamento de diagnósticos
- [ ] Validar favoritos funcionando
- [ ] Verificar performance com muitos dados
- [ ] Testar offline (dados estáticos devem funcionar)
- [ ] Verificar se placeholders aparecem corretamente
- [ ] Validar todos os campos de dosagem e aplicação

---

## 🔄 Atualizações e Tarefas

### Histórico de Atualizações

| Data | Versão | Alterações |
|------|--------|------------|
| 2025-01-07 | 1.0.0 | Documento inicial criado com análise completa |
| 2025-10-07 | 2.0.0 | **Revisão Arquitetural**: Abolição do sistema de cache. Todas consultas agora seguem padrão direto: abrir box → consultar → fechar. Atualização de exemplos, recomendações e checklist. |

### Próximas Tarefas (Backlog)

#### **Críticas (P0)**
- [ ] **TASK-RAG-001**: Implementar padrão de abertura/fechamento de boxes em todos os repositórios (16h)
- [ ] **TASK-RAG-002**: Criar HiveBoxManager helper para gerenciamento centralizado (6h)
- [ ] **TASK-RAG-003**: Adicionar validação de integridade referencial (8h)
- [ ] **TASK-RAG-004**: Melhorar tratamento de erros visíveis (6h)

#### **Altas (P1)**
- [ ] **TASK-RAG-005**: Implementar monitoramento de boxes abertas (leak detection) (8h)
- [ ] **TASK-RAG-006**: Adicionar logs de abertura/fechamento de boxes para debugging (4h)
- [ ] **TASK-RAG-007**: Remover/condicionar debug logs excessivos (2h)

#### **Médias (P2)**
- [ ] **TASK-RAG-007**: Adicionar testes unitários (24h)
- [ ] **TASK-RAG-008**: Adicionar testes de integração (16h)
- [ ] **TASK-RAG-009**: Melhorar UX de campos vazios/incompletos (4h)
- [ ] **TASK-RAG-010**: Implementar analytics de uso (4h)

#### **Baixas (P3)**
- [ ] **TASK-RAG-011**: Adicionar exportação de diagnósticos PDF/CSV (8h)
- [ ] **TASK-RAG-012**: Melhorar busca avançada com filtros (4h)
- [ ] **TASK-RAG-013**: Criar documentação de API interna (8h)

#### **Futuras**
- [ ] **TASK-RAG-014**: Avaliar migração para Drift (SQLite) (40h+)
- [ ] **TASK-RAG-015**: Implementar sincronização com backend (60h+)

---

## 📚 Referências

### Documentação Relacionada
- [Clean Architecture Guide](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)
- [Riverpod Documentation](https://riverpod.dev/)
- [Hive Documentation](https://docs.hivedb.dev/)
- [Dartz (Either) Documentation](https://pub.dev/packages/dartz)

### Arquivos-Chave do Projeto
- `lib/core/data/models/diagnostico_hive.dart` - Modelo central
- `lib/core/extensions/diagnostico_hive_extension.dart` - Formatação crucial
- `lib/core/services/diagnostico_entity_resolver.dart` - Resolução de nomes
- `lib/features/diagnosticos/presentation/providers/diagnosticos_notifier.dart` - State management
- `lib/features/detalhes_diagnostico/presentation/pages/detalhe_diagnostico_page.dart` - UI principal

---

**Documento mantido por:** Equipe de Desenvolvimento ReceitaAgro
**Última atualização:** 2025-10-07
**Versão:** 2.0.0
**Status:** 📄 Completo e atualizado - Arquitetura sem cache

---

## 🎓 Glossário

| Termo | Definição |
|-------|-----------|
| **Diagnóstico** | Recomendação técnica que relaciona defensivo + cultura + praga com dosagens e instruções |
| **Defensivo** | Produto fitossanitário (agrotóxico) usado no controle de pragas |
| **Fitossanitário** | Sinônimo de defensivo agrícola |
| **Praga** | Organismo prejudicial às culturas (inseto, doença, planta daninha) |
| **Cultura** | Planta cultivada (soja, milho, café, etc.) |
| **FK** | Foreign Key - chave estrangeira que referencia outra entidade |
| **Hive Box** | Container de dados do Hive (similar a uma tabela) |
| **TypeId** | Identificador único do tipo Hive para serialização |
| **Clean Architecture** | Padrão arquitetural com separação de camadas |
| **Either<L,R>** | Tipo funcional que representa sucesso (R) ou falha (L) |
| **Entity** | Objeto de domínio com identidade única |
| **Value Object** | Objeto imutável definido por seus atributos |
| **Repository** | Abstração para acesso a dados |
| **Use Case** | Regra de negócio encapsulada em uma ação específica |
| **Provider/Notifier** | Gerenciador de estado no Riverpod |
| **Cached Field** | Campo armazenado que pode estar desatualizado |
| **N+1 Problem** | Problema de performance onde N consultas adicionais são feitas |
| **Box Leakage** | Vazamento de boxes Hive abertas e não fechadas |
| **Try-Finally** | Padrão de código que garante execução de cleanup mesmo com erros |
| **Open-Query-Close** | Padrão de acesso: abrir box → consultar → fechar |

---

**🚀 ReceitaAgro - Sistema de Diagnóstico Agronômico Profissional**

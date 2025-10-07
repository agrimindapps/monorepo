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

// Arquitetura
Pattern: Clean Architecture (Data/Domain/Presentation)
Dependency Injection: GetIt + Injectable
Error Handling: Either<Failure, T> (dartz)
```

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
  try {
    final repository = di.sl<FitossanitarioHiveRepository>();
    final defensivo = await repository.getById(fkIdDefensivo);

    if (defensivo != null && defensivo.nomeComum.isNotEmpty) {
      return defensivo.nomeComum;
    }
  } catch (e) {
    // Ignora erro
  }

  return 'Defensivo não identificado';
}
```

**⚠️ IMPORTANTE:** Este método **SEMPRE** busca no repositório usando `fkIdDefensivo`. **NUNCA** usa o campo `nomeDefensivo` armazenado no DiagnosticoHive, pois pode estar desatualizado.

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

### 4.3. Serviço DiagnosticoEntityResolver

**Responsabilidade:** Resolver IDs para nomes legíveis com cache inteligente.

**Localização:** `lib/core/services/diagnostico_entity_resolver.dart`

```dart
class DiagnosticoEntityResolver {
  // Singleton instance
  static DiagnosticoEntityResolver get instance =>
      _instance ??= DiagnosticoEntityResolver._internal();

  // Repositórios injetados
  late final CulturaHiveRepository _culturaRepository;
  late final FitossanitarioHiveRepository _defensivoRepository;
  late final PragasHiveRepository _pragasRepository;

  // Cache com TTL de 30 minutos
  final Map<String, String> _culturaCache = {};
  final Map<String, String> _defensivoCache = {};
  final Map<String, String> _pragaCache = {};

  DateTime? _lastCacheUpdate;
  static const Duration _cacheTTL = Duration(minutes: 30);

  /// Resolve nome de cultura APENAS usando ID
  /// ✅ SEMPRE resolve via repository.getById()
  /// ❌ NUNCA usa campos nomeCultura cached
  Future<String> resolveCulturaNome({
    required String idCultura,
    String defaultValue = 'Cultura não especificada',
  }) async {
    try {
      // 1. Verifica cache
      if (_isCacheValid && _culturaCache.containsKey(idCultura)) {
        return _culturaCache[idCultura]!;
      }

      // 2. Busca no repositório
      if (idCultura.isNotEmpty) {
        final culturaData = await _culturaRepository.getById(idCultura);

        if (culturaData != null && culturaData.cultura.isNotEmpty) {
          final resolvedName = culturaData.cultura;

          // 3. Atualiza cache
          _culturaCache[idCultura] = resolvedName;
          _updateCacheTimestamp();

          return resolvedName;
        }
      }

      // 4. Retorna default se não encontrar
      _culturaCache[idCultura] = defaultValue;
      _updateCacheTimestamp();

      return defaultValue;
    } catch (e) {
      debugPrint('❌ Erro ao resolver cultura: $e');
      return defaultValue;
    }
  }

  // Métodos similares para:
  // - resolveDefensivoNome()
  // - resolvePragaNome()
  // - resolveBatchCulturas()
  // - resolveBatchDefensivos()
  // - resolveBatchPragas()
}
```

**Características:**
- ✅ Cache de 30 minutos para evitar consultas repetidas
- ✅ Singleton pattern para cache global
- ✅ Batch resolution para otimizar múltiplas consultas
- ✅ Fallback para valores padrão
- ⚠️ Cache pode retornar dados obsoletos até expiração

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

### 8.1. Problema Crítico: Campos Cached Desatualizados

**Severidade:** 🔴 CRÍTICA

**Localização:** `DiagnosticoHive.nomeDefensivo`, `nomeCultura`, `nomePraga`

**Descrição:**
O modelo `DiagnosticoHive` armazena nomes das entidades relacionadas como cache, mas esses valores **podem estar desatualizados** se:
- Um defensivo mudar de nome comercial
- Uma praga tiver seu nome comum corrigido
- Dados forem atualizados em produção

**Código Problemático:**
```dart
@HiveType(typeId: 101)
class DiagnosticoHive extends HiveObject {
  @HiveField(4) String fkIdDefensivo;         // ✅ Source of truth
  @HiveField(5) String? nomeDefensivo;        // ❌ Pode estar desatualizado

  @HiveField(6) String fkIdCultura;           // ✅ Source of truth
  @HiveField(7) String? nomeCultura;          // ❌ Pode estar desatualizado

  @HiveField(8) String fkIdPraga;             // ✅ Source of truth
  @HiveField(9) String? nomePraga;            // ❌ Pode estar desatualizado
}
```

**Impacto:**
- ⚠️ UI pode exibir nomes incorretos/antigos
- ⚠️ Buscas por nome podem retornar resultados inconsistentes
- ⚠️ Dados de compartilhamento podem ter informações desatualizadas

**Solução Atual (Mitigação):**
```dart
// ✅ SEMPRE usa resolução dinâmica
Future<String> getDisplayNomeDefensivo() async {
  final repository = di.sl<FitossanitarioHiveRepository>();
  final defensivo = await repository.getById(fkIdDefensivo);

  if (defensivo != null && defensivo.nomeComum.isNotEmpty) {
    return defensivo.nomeComum;  // ✅ Sempre atualizado
  }

  return 'Defensivo não identificado';
}

// ❌ NUNCA usar diretamente
// String nomeIncorreto = diagnostico.nomeDefensivo;  // ERRADO!
```

**Recomendação Final:**
- ✅ Manter extensões `getDisplayNome*()` como única fonte
- ⚠️ Remover campos cached ou marcar como `@deprecated`
- ✅ Adicionar testes de integração para validar resolução

### 8.2. Problema de Performance: N+1 Queries

**Severidade:** 🟠 ALTA

**Localização:** `toDataMap()`, list rendering

**Descrição:**
Ao carregar uma lista de diagnósticos, cada item executa múltiplas consultas assíncronas:

```dart
// Para cada diagnóstico na lista...
for (final diagnostico in diagnosticos) {
  // Consulta 1: Buscar defensivo
  final defensivo = await fitossanitarioRepo.getById(diagnostico.fkIdDefensivo);

  // Consulta 2: Buscar praga
  final praga = await pragaRepo.getById(diagnostico.fkIdPraga);

  // Consulta 3: Buscar cultura
  final cultura = await culturaRepo.getById(diagnostico.fkIdCultura);
}

// Para 100 diagnósticos = 300+ consultas! 😱
```

**Impacto:**
- 🐢 Lentidão na renderização de listas
- 🐢 Scroll lag quando lazy loading
- 🐢 Timeout em listas grandes (>200 itens)

**Mitigação Atual:**
```dart
// DiagnosticoEntityResolver usa cache de 30 minutos
bool get _isCacheValid {
  return _lastCacheUpdate != null &&
         DateTime.now().difference(_lastCacheUpdate!) < _cacheTTL;
}
```

**Recomendação Final:**
- ✅ Implementar batch loading no resolver
- ✅ Pre-fetch comum entities no startup
- ✅ Usar `Future.wait()` para paralelizar consultas
- ✅ Lazy load apenas campos essenciais na lista

**Código Otimizado Sugerido:**
```dart
/// Batch resolution otimizado
Future<Map<String, DiagnosticoDisplayData>> batchResolve(
  List<DiagnosticoHive> diagnosticos,
) async {
  // 1. Coleta todos os IDs únicos
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

### 8.5. Problema: Cache Pode Retornar Dados Obsoletos

**Severidade:** 🟡 MÉDIA

**Localização:** `DiagnosticoEntityResolver`

**Descrição:**
Cache de 30 minutos pode manter dados desatualizados por muito tempo:

```dart
static const Duration _cacheTTL = Duration(minutes: 30);  // ⚠️ Muito longo?
```

**Cenário Problemático:**
```
09:00 - Usuário A acessa: Cache carrega "Glifosato 480"
09:15 - Admin atualiza produto para "Glifosato 480 g/L SL"
09:20 - Usuário A retorna: Ainda vê "Glifosato 480" (cache válido)
09:30 - Cache expira, próxima busca verá novo nome
```

**Impacto:**
- ⚠️ Dados podem estar 30 minutos desatualizados
- ⚠️ Inconsistência entre usuários (uns veem versão antiga, outros nova)

**Recomendação Final:**
- ✅ Reduzir TTL para 5-10 minutos
- ✅ Implementar invalidação manual após data loads
- ✅ Adicionar versioning de cache
- ✅ Force refresh ao pull-to-refresh

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

#### **1. Implementar Batch Loading**
**Impacto:** 🔴 CRÍTICO
**Esforço:** 16h

```dart
// Objetivo: Reduzir de 300 queries para 3 queries
Future<List<DiagnosticoDisplayData>> loadDiagnosticosOptimized(
  List<String> diagnosticoIds,
) async {
  // 1. Carregar diagnósticos em batch
  final diagnosticos = await _diagnosticoRepo.getByIds(diagnosticoIds);

  // 2. Extrair IDs únicos
  final defensivoIds = diagnosticos.map((d) => d.fkIdDefensivo).toSet();
  final pragaIds = diagnosticos.map((d) => d.fkIdPraga).toSet();
  final culturaIds = diagnosticos.map((d) => d.fkIdCultura).toSet();

  // 3. Carregar todas entidades relacionadas (3 queries)
  final defensivos = await Future.wait([
    _defensivoRepo.getByIds(defensivoIds),
    _pragaRepo.getByIds(pragaIds),
    _culturaRepo.getByIds(culturaIds),
  ]);

  // 4. Montar objetos display
  return diagnosticos.map((diag) {
    return DiagnosticoDisplayData(
      diagnostico: diag,
      defensivo: defensivosMap[diag.fkIdDefensivo],
      praga: pragasMap[diag.fkIdPraga],
      cultura: culturasMap[diag.fkIdCultura],
    );
  }).toList();
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

#### **4. Otimizar Cache**
**Impacto:** 🟠 MÉDIA
**Esforço:** 4h

- Reduzir TTL para 10 minutos
- Implementar invalidação manual após data loads
- Adicionar cache warming no startup

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

- [ ] **Sempre** usar `getDisplayNome*()` ao invés de campos cached
- [ ] **Nunca** confiar em `nomeDefensivo`, `nomeCultura`, `nomePraga` do DiagnosticoHive
- [ ] Usar batch loading quando carregar listas
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

### Próximas Tarefas (Backlog)

#### **Críticas (P0)**
- [ ] **TASK-RAG-001**: Implementar batch loading otimizado (16h)
- [ ] **TASK-RAG-002**: Adicionar validação de integridade referencial (8h)
- [ ] **TASK-RAG-003**: Melhorar tratamento de erros visíveis (6h)

#### **Altas (P1)**
- [ ] **TASK-RAG-004**: Otimizar cache do EntityResolver (4h)
- [ ] **TASK-RAG-005**: Criar índices manuais para consultas (12h)
- [ ] **TASK-RAG-006**: Remover/condicionar debug logs excessivos (2h)

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
**Última atualização:** 2025-01-07
**Versão:** 1.0.0
**Status:** 📄 Completo e atualizado

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
| **Batch Loading** | Carregamento em lote para otimizar múltiplas consultas |
| **TTL** | Time To Live - tempo de vida do cache |

---

**🚀 ReceitaAgro - Sistema de Diagnóstico Agronômico Profissional**

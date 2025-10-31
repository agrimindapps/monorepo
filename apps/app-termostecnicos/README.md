# 📚 Termos Técnicos - Technical Dictionary & Glossary

<div align="center">

![Flutter](https://img.shields.io/badge/Flutter-3.35+-02569B?style=for-the-badge&logo=flutter)
![Dart](https://img.shields.io/badge/Dart-3.9.0+-0175C2?style=for-the-badge&logo=dart)
![Riverpod](https://img.shields.io/badge/State-Riverpod-blueviolet?style=for-the-badge)

**Dicionário completo com +10.000 termos técnicos de 12 áreas do conhecimento**

[Características](#-características) •
[Áreas](#-áreas-do-conhecimento) •
[Funcionalidades](#-funcionalidades) •
[Como Usar](#-como-usar)

</div>

---

## 📖 Visão Geral

**Termos Técnicos** é um aplicativo educacional completo que reúne mais de 10.000 definições técnicas e acadêmicas de 12 áreas do conhecimento, com recursos de busca avançada, favoritos, notas e síntese de voz.

### 🎯 Público-Alvo

- **Estudantes**: Universitários e pré-vestibulandos
- **Profissionais**: Referência técnica no trabalho
- **Professores**: Material de apoio didático
- **Pesquisadores**: Consulta rápida de terminologias

---

## 📚 Áreas do Conhecimento

### 🔬 **Ciências Exatas**
1. **Matemática** - Álgebra, Geometria, Cálculo, Estatística
2. **Física** - Mecânica, Termodinâmica, Eletromagnetismo, Quântica
3. **Química** - Orgânica, Inorgânica, Físico-Química, Bioquímica
4. **Informática** - Programação, Redes, IA, Banco de Dados

### 🌱 **Ciências Biológicas**
5. **Biologia** - Genética, Ecologia, Fisiologia, Microbiologia
6. **Medicina** - Anatomia, Patologia, Farmacologia, Clínica

### 🌍 **Ciências Humanas**
7. **Geografia** - Física, Humana, Cartografia, Geopolítica
8. **Direito** - Civil, Penal, Constitucional, Trabalhista
9. **Economia** - Macro, Micro, Finanças, Mercado
10. **Administração** - Gestão, Marketing, Logística, RH

### 🏗️ **Engenharias e Tecnologia**
11. **Arquitetura** - Urbanismo, Estruturas, Design, História
12. **Agricultura** - Agronomia, Zootecnia, Solo, Cultivos

---

## ✨ Características

### 🔍 **Busca Avançada**

- **Busca Global**: Pesquisa em todas as áreas
- **Busca por Área**: Filtro por disciplina
- **Auto-Complete**: Sugestões em tempo real
- **Busca Fonética**: Encontra mesmo com erros de digitação
- **Histórico**: Últimas pesquisas

### 📝 **Gestão de Conteúdo**

- **Favoritos**: Marcar termos importantes
- **Notas Pessoais**: Adicionar anotações (flutter_quill)
- **Categorias**: Organizar em pastas personalizadas
- **Compartilhar**: Enviar definições por WhatsApp, email
- **Exportar**: PDF com termos favoritos

### 🔊 **Acessibilidade**

- **Síntese de Voz** (flutter_tts): Leitura de definições
- **Ajuste de Fonte**: Tamanho e tipo
- **Alto Contraste**: Modo de leitura facilitada
- **Modo Escuro**: Proteção visual

### 📊 **Estatísticas**

- Termos mais consultados
- Áreas mais estudadas
- Tempo de estudo
- Progresso pessoal

---

## 🏗️ Arquitetura

### Clean Architecture + Riverpod

```
lib/
├── core/
│   ├── di/                   # Dependency Injection
│   ├── router/               # GoRouter + navigation
│   ├── theme/                # Material Design + Dark mode
│   ├── database/             # Hive setup
│   └── tts/                  # Text-to-Speech service
│
├── features/
│   ├── dictionary/           # Dicionário principal
│   │   ├── data/
│   │   │   ├── datasources/  # JSON loading
│   │   │   ├── models/       # TermModel
│   │   │   └── repositories/
│   │   ├── domain/
│   │   │   ├── entities/     # TermEntity
│   │   │   ├── repositories/
│   │   │   └── usecases/     # Search, GetByArea, GetById
│   │   └── presentation/
│   │       ├── pages/        # Search, Detail, List
│   │       ├── providers/    # Riverpod state
│   │       └── widgets/
│   │
│   ├── favorites/            # Sistema de favoritos
│   ├── notes/                # Notas pessoais (Quill editor)
│   ├── categories/           # Organização customizada
│   ├── statistics/           # Estatísticas de uso
│   ├── settings/             # Configurações
│   │   ├── tts_settings/     # Config Text-to-Speech
│   │   ├── appearance/       # Tema, fonte
│   │   └── data_management/  # Backup, sync
│   │
│   ├── auth/                 # Autenticação Firebase
│   └── premium/              # Recursos Premium
│
└── assets/
    └── database/
        └── json/             # 12 pastas com JSONs
            ├── administracao/
            ├── agricultura/
            ├── arquitetura/
            ├── biologia/
            ├── direito/
            ├── economia/
            ├── fisica/
            ├── geografia/
            ├── informatica/
            ├── matematica/
            ├── medicina/
            └── quimica/
```

### 🎯 Stack Tecnológica

```yaml
# State Management
flutter_riverpod: ^2.6.1      # State management
riverpod_annotation: ^2.6.1   # Code generation

# Dependency Injection
get_it: ^8.0.2                # Service locator
injectable: ^2.5.1            # DI code generation

# Functional Programming
dartz: ^0.10.1                # Either<L,R>
equatable: ^2.0.7             # Value equality

# Immutability
freezed_annotation: ^2.4.1    # Immutable models

# Storage
hive: any                     # Local database
shared_preferences: any       # Simple storage

# Rich Text Editor
flutter_quill: ^11.0.0        # WYSIWYG editor para notas

# Text-to-Speech
flutter_tts: ^4.0.2           # Síntese de voz

# Firebase
firebase_core: any            # Core Firebase
cloud_firestore: any          # Sync (opcional)

# Premium
purchases_flutter: any        # RevenueCat
purchases_ui_flutter: ^9.8.0  # RevenueCat UI

# UI Components
skeletonizer: ^1.4.2          # Loading skeletons
flutter_staggered_grid_view: ^0.7.0  # Grid layouts

# Navigation
go_router: ^16.2.4            # Roteamento declarativo

# Localization
flutter_localization: ^0.2.1  # i18n
```

---

## 🚀 Como Usar

### Pré-requisitos

```bash
Flutter SDK: >=3.35.0
Dart SDK: >=3.9.0
```

### Instalação

```bash
# 1. Navegar até o diretório
cd apps/app-termostecnicos

# 2. Instalar dependências
flutter pub get

# 3. Gerar código (Riverpod, Injectable, Freezed, Hive)
dart run build_runner build --delete-conflicting-outputs

# 4. Executar
flutter run
```

### Build

```bash
# Android
flutter build apk --release

# iOS
flutter build ios --release
```

---

## 📊 Base de Dados

### Estrutura JSON

```json
{
  "terms": [
    {
      "id": "mat_001",
      "term": "Álgebra Linear",
      "definition": "Ramo da matemática que estuda vetores, espaços vetoriais, transformações lineares e sistemas de equações lineares.",
      "area": "matematica",
      "related_terms": ["vetor", "matriz", "transformacao_linear"],
      "examples": ["Sistema de equações", "Transformação de coordenadas"],
      "synonyms": ["Álgebra Vetorial"],
      "difficulty": "intermediario",
      "tags": ["matematica", "algebra", "vetores"]
    }
  ]
}
```

### Estatísticas da Base

| Área | Termos | Status |
|------|--------|--------|
| Matemática | ~1.200 | ✅ |
| Física | ~1.100 | ✅ |
| Química | ~1.000 | ✅ |
| Informática | ~1.300 | ✅ |
| Biologia | ~1.000 | ✅ |
| Medicina | ~1.200 | ✅ |
| Geografia | ~800 | ✅ |
| Direito | ~900 | ✅ |
| Economia | ~700 | ✅ |
| Administração | ~600 | ✅ |
| Arquitetura | ~500 | ✅ |
| Agricultura | ~700 | ✅ |
| **Total** | **~11.000** | ✅ |

---

## 💎 Recursos Premium

### 🆓 **Plano Free**
- 3 áreas desbloqueadas
- 50 favoritos
- Busca básica
- Anúncios

### ⭐ **Plano Premium**
- Todas as 12 áreas
- Favoritos ilimitados
- Notas pessoais ilimitadas
- Categorias personalizadas
- Síntese de voz (TTS)
- Exportação PDF
- Sincronização em nuvem
- Sem anúncios

---

## 🧪 Testes

```bash
# Unit tests
flutter test

# Widget tests
flutter test test/widgets/

# Integration tests
flutter test integration_test/
```

---

## 📈 Performance

### Otimizações

- **JSON Lazy Loading**: Áreas carregadas sob demanda
- **Full-Text Search**: Índice invertido em memória
- **Hive Caching**: Cache de termos favoritos
- **Pagination**: Lista virtualizada

### Métricas

| Métrica | Valor | Status |
|---------|-------|--------|
| App Size | ~25MB (com JSONs) | ✅ |
| Search Time | <50ms | ✅ |
| Startup | <2s | ✅ |
| Memory | <100MB | ✅ |

---

## 🔐 Privacidade

- **Dados Offline**: Funciona 100% offline
- **Sync Opcional**: Sincronização via Firebase (opt-in)
- **Sem Tracking**: Sem coleta de dados de uso
- **LGPD Compliant**: Privacidade respeitada

---

## 📱 Plataformas

- ✅ **Android** (API 21+)
- ✅ **iOS** (iOS 12+)
- ✅ **Web** (Suportado)

---

## 📄 Licença

Este projeto é propriedade de **Agrimind Soluções**.

---

## 📞 Suporte

- **Email**: suporte@termostecnicos.com
- **Documentação**: Monorepo `/CLAUDE.md`

---

<div align="center">

**📚 Termos Técnicos - Conhecimento técnico acessível 📚**

![Quality](https://img.shields.io/badge/Quality-Production-success?style=flat-square)
![Terms](https://img.shields.io/badge/Terms-11.000+-blue?style=flat-square)

</div>

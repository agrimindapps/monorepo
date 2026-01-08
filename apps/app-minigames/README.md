# 🎮 MiniGames - Collection of 13 Classic Games

<div align="center">

![Flutter](https://img.shields.io/badge/Flutter-3.24+-02569B?style=for-the-badge&logo=flutter)
![Dart](https://img.shields.io/badge/Dart-3.5.0+-0175C2?style=for-the-badge&logo=dart)
![Riverpod](https://img.shields.io/badge/State-Riverpod-blueviolet?style=for-the-badge)

**Aplicativo completo com 13 mini-jogos clássicos educativos e de entretenimento**

[Jogos](#-jogos-disponíveis) •
[Características](#-características) •
[Arquitetura](#-arquitetura) •
[Como Usar](#-como-usar)

</div>

---

## 🕹️ Visão Geral

**MiniGames** é uma coleção de 13 jogos clássicos desenvolvidos em Flutter, oferecendo entretenimento para todas as idades com suporte para mobile e desktop.

### 🎯 Objetivos

- **Entretenimento Casual**: Jogos rápidos para qualquer momento
- **Educação**: Jogos que estimulam lógica e raciocínio
- **Nostalgia**: Clássicos remasterizados
- **Cross-Platform**: Mesma experiência em todas plataformas

---

## 🎮 Jogos Disponíveis

### 🧩 **Puzzle & Lógica** (4 jogos)

#### 1. **2048**
- Puzzle numérico clássico
- Combine números para atingir 2048
- Sistema de pontuação
- Desfazer jogadas (Premium)

#### 2. **Sudoku**
- Múltiplos níveis de dificuldade
- Dicas inteligentes
- Validação em tempo real
- Timer e recordes

#### 3. **Campo Minado** (Minesweeper)
- Grids: 8x8, 16x16, 30x16
- Bandeiras para marcar minas
- Revelação cascata
- Estatísticas de vitórias

#### 4. **Memory** (Jogo da Memória)
- Temas variados
- 2, 4 ou 6 jogadores
- Modo tempo limitado
- Rankings locais

---

### 📝 **Palavras & Conhecimento** (4 jogos)

#### 5. **Caça-Palavra** (Word Search)
- Temas educativos
- Dificuldades variadas
- Dicas progressivas
- Editor de palavras customizadas

#### 6. **Soletrando** (Spelling Game)
- Palavras por categorias
- Narração de voz (TTS)
- Pontuação por acertos
- Modo educativo

#### 7. **Quiz** (Perguntas e Respostas)
- Múltiplas categorias
- Perguntas de múltipla escolha
- Ranking global
- Quiz diário

#### 8. **Quiz Imagem**
- Identifique objetos, animais, lugares
- Modo contra o relógio
- Compartilhar pontuação
- Conquistas

---

### 🚀 **Ação & Arcade** (4 jogos)

#### 9. **Snake** (Jogo da Cobrinha)
- Controles touch ou teclado
- Velocidade progressiva
- Power-ups especiais
- Modo infinito

#### 10. **Flappy Bird**
- Clone do clássico
- Física realista
- Dificuldade ajustável
- Leaderboard online

#### 11. **Ping Pong**
- Modo single player vs IA
- Modo multiplayer local
- Física de bola realista
- Dificuldades da IA

#### 12. **Tower** (Tower Defense)
- Construa torres defensivas
- 15 níveis progressivos
- Upgrade de torres
- Múltiplos tipos de inimigos

---

### 🎲 **Estratégia** (1 jogo)

#### 13. **Tic-Tac-Toe** (Jogo da Velha)
- Modo vs IA (fácil, médio, impossível)
- Modo 2 jogadores local
- Estatísticas de vitórias
- Variantes: 4x4, 5x5

---

## ✨ Características

### 🎨 **Interface Moderna**

- Design Material Design 3
- Animações fluidas e transições
- Tema claro e escuro
- UI responsiva (mobile, tablet, desktop)

### 🏆 **Sistema de Progressão**

- **Pontuação Global**: Sistema unificado
- **Achievements**: 50+ conquistas
- **Leaderboards**: Rankings por jogo (Firebase)
- **Estatísticas**: Tempo jogado, vitórias, derrotas
- **Níveis de Jogador**: Bronze, Prata, Ouro, Platina

### 💾 **Persistência**

- **Hive**: Saves locais, recordes, configurações
- **Firebase**: Sync de pontuações e rankings
- **Cloud Save**: Backup automático (Premium)

### 🎮 **Controles**

- **Touch**: Gestos otimizados para mobile
- **Teclado**: Suporte completo para desktop
- **Gamepad**: Suporte a controles (planejado)

### 🔊 **Áudio**

- Efeitos sonoros por jogo
- Música de fundo
- Volume ajustável
- Modo silencioso

---

## 🏗️ Arquitetura

### Clean Architecture + Riverpod (Migração)

```
lib/
├── core/
│   ├── config/           # Firebase, environment
│   ├── di/               # Dependency Injection (GetIt + Injectable)
│   ├── router/           # GoRouter + navigation
│   ├── theme/            # Theme providers (Riverpod)
│   ├── audio/            # Audio service
│   └── analytics/        # Firebase Analytics
│
├── features/
│   ├── games/            # Módulo de jogos (migração)
│   │   ├── common/       # Shared game logic
│   │   ├── puzzle_2048/
│   │   ├── sudoku/
│   │   ├── minesweeper/
│   │   ├── memory/
│   │   ├── word_search/
│   │   ├── spelling/
│   │   ├── quiz/
│   │   ├── quiz_image/
│   │   ├── snake/
│   │   ├── flappy_bird/
│   │   ├── ping_pong/
│   │   ├── tower_defense/
│   │   └── tic_tac_toe/
│   │
│   ├── leaderboard/      # Rankings
│   ├── achievements/     # Conquistas
│   ├── profile/          # Perfil do jogador
│   ├── settings/         # Configurações
│   └── auth/             # Autenticação
│
├── pages/                # Pages (legacy - migrar)
│   ├── game_*/           # Jogos individuais
│   ├── game_home.dart    # Menu de jogos
│   ├── mobile_page.dart
│   └── desktop_page.dart
│
├── models/               # Data models
├── services/             # Business services
├── widgets/              # Shared widgets
└── utils/                # Utilities
```

### 🎯 Stack Tecnológica

```yaml
# State Management
flutter_riverpod: ^2.6.1      # Migração de Provider → Riverpod
riverpod_annotation: ^2.6.1   # Code generation

# Dependency Injection
get_it: ^8.0.2                # Service locator
injectable: ^2.5.1            # DI code generation

# Storage
hive: any                     # Local storage
shared_preferences: any       # Settings

# Firebase
firebase_core: any            # Core Firebase
cloud_firestore: any          # Leaderboards & sync
firebase_auth: any            # Autenticação
firebase_analytics: any       # Analytics

# Navigation
go_router: ^16.2.4            # Roteamento declarativo

# Audio
audioplayers: any             # SFX e música

# Utilities
logger: ^2.4.0                # Logging
```

---

## 🚀 Como Usar

### Pré-requisitos

```bash
Flutter SDK: >=3.24.0
Dart SDK: >=3.5.0
```

### Instalação

```bash
# 1. Navegar até o diretório
cd apps/app-minigames

# 2. Instalar dependências
flutter pub get

# 3. Gerar código
dart run build_runner build --delete-conflicting-outputs

# 4. Executar
flutter run

# Para desktop
flutter run -d macos  # ou windows, linux
```

### Firebase Setup

1. Criar projeto no [Firebase Console](https://console.firebase.google.com/)
2. Habilitar Authentication, Firestore, Analytics
3. Adicionar configurações para Android/iOS/Web

---

## 🎯 Funcionalidades

### ✅ **Implementado**

- ✅ 13 jogos completos e funcionais
- ✅ Responsive (mobile + desktop)
- ✅ Dark/Light theme
- ✅ Saves locais (Hive)
- ✅ Navegação com GoRouter
- ✅ Audio service

### 🔄 **Em Desenvolvimento**

- 🔄 Leaderboards online (Firebase)
- 🔄 Sistema de conquistas
- 🔄 Multiplayer online (alguns jogos)
- 🔄 Migração completa para Riverpod
- 🔄 Clean Architecture em todos os jogos

### 📅 **Planejado**

- 📅 Modo torneio
- 📅 Chat entre jogadores
- 📅 Customização de avatares
- 📅 Gamepad support

---

## 📝 Status de Migração

### Arquitetura Legada → Clean Architecture

**Status Atual**: 30% migrado

- ✅ Core infrastructure setup
- ✅ DI com Injectable configurado
- ✅ Router com GoRouter
- 🔄 Migração de Provider → Riverpod (40%)
- 🔄 Refatoração para Clean Architecture (20%)

### Próximos Passos

1. Migrar timer-based theme para Riverpod
2. Criar feature modules por jogo
3. Implementar repository pattern
4. Adicionar testes unitários
5. Completar Firebase integration

---

## 🧪 Testes

```bash
# Unit tests (a implementar)
flutter test

# Widget tests
flutter test test/widgets/

# Integration tests
flutter test integration_test/
```

---

## 📱 Plataformas

- ✅ **Android** (API 21+)
- ✅ **iOS** (iOS 12+)
- ✅ **Web** (Chrome, Safari, Firefox)
- ✅ **Desktop** (Windows, macOS, Linux)

---

## 📄 Licença

Este projeto é propriedade de **Agrimind Soluções**.

---

## 📞 Suporte

- **Documentação**: Monorepo `/CLAUDE.md`
- **Issues**: GitHub Issues

---

<div align="center">

**🎮 MiniGames - 13 jogos clássicos em um único app 🎮**

![Status](https://img.shields.io/badge/Status-Active-success?style=flat-square)
![Migration](https://img.shields.io/badge/Migration-30%25-orange?style=flat-square)

</div>

---

## 📱 Responsividade Mobile

O app foi otimizado para proporcionar uma experiência fullscreen em dispositivos móveis:

### Desktop vs Mobile

| Aspecto | Desktop (≥800px) | Mobile (<800px) |
|---------|------------------|-----------------|
| Sidebar | Visível (240px) | Drawer (menu) |
| Padding | 24px | 8px |
| Game Width | Max 600px | Full width |
| Borders | Sim (16px radius) | Mínimas (8px) |
| Shadows | Sim | Não |
| Background | Pattern visível | Transparente |
| Header | Completo | Compacto |

### Documentação Adicional

- 📄 [KEYBOARD_CONTROLS.md](./KEYBOARD_CONTROLS.md) - Guia completo de controles
- 📊 [GAMES_INPUT_SUMMARY.md](./GAMES_INPUT_SUMMARY.md) - Resumo de inputs
- 📱 [MOBILE_RESPONSIVENESS.md](./MOBILE_RESPONSIVENESS.md) - Detalhes mobile


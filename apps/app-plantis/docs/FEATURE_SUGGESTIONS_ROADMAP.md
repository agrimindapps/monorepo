# 🌱 App Plantis - Sugestões de Novas Features

> **Documento de Análise e Roadmap**  
> Gerado em: 18/12/2024  
> Versão: 1.0

---

## 📊 Análise das Features Atuais

### **Entidades Existentes**

| Entidade | Campos Principais | Status |
|----------|-------------------|--------|
| **Plant** | name, species, spaceId, imageUrls, plantingDate, notes, config (watering, fertilizing, pruning, etc.), isFavorited | ✅ Completo |
| **PlantConfig** | wateringIntervalDays, fertilizingIntervalDays, pruningIntervalDays, lightRequirement, waterAmount, soilType, idealTemperature, idealHumidity | ✅ Completo |
| **Space** | name, description, lightCondition, humidity, averageTemperature | ✅ Básico |
| **Task** | title, description, plantId, type, status, priority, dueDate, isRecurring, recurringIntervalDays | ✅ Completo |
| **TaskHistory** | Histórico de tarefas executadas | ✅ Existe |

### **Páginas/Telas Existentes**

- ✅ **Plants List** - Lista de plantas com grid view
- ✅ **Plant Details** - Detalhes da planta com configurações
- ✅ **Plant Form** - Cadastro/edição de plantas
- ✅ **Tasks List** - Lista de tarefas pendentes/concluídas
- ✅ **Settings** - Configurações gerais
- ✅ **Notifications Settings** - Configurações de notificações
- ✅ **Backup Settings** - Backup de dados
- ✅ **Premium Subscription** - Assinatura premium
- ✅ **Data Export** - Exportação de dados
- ✅ **Device Management** - Gerenciamento de dispositivos
- ✅ **Auth Pages** - Login, registro, etc.
- ✅ **Legal Pages** - Termos, privacidade, etc.

### **Tipos de Tarefas Suportadas**

- 💧 Regar (watering)
- 🌿 Adubar (fertilizing)
- ✂️ Podar (pruning)
- 🪴 Replantar (repotting)
- 🧹 Limpar (cleaning)
- 💨 Pulverizar (spraying)
- ☀️ Colocar no Sol (sunlight)
- 🌑 Colocar na Sombra (shade)
- 🐛 Inspeção de Pragas (pestInspection)
- 📝 Personalizada (custom)

---

## 🚀 Sugestões de Novas Features

### **Categoria 1: Identificação e Conhecimento** 🔍

#### 1.1 **Identificação de Plantas por Foto (AI)**
**Prioridade:** ⭐⭐⭐⭐⭐ ALTA  
**Complexidade:** 🔧🔧🔧 MÉDIA  
**Monetização:** 💰💰💰 Premium

**Descrição:**
- Integração com API de identificação de plantas (Plant.id, PlantNet, Google Vision)
- Usuário tira foto da planta e recebe sugestões de espécie
- Auto-preenchimento de requisitos de cuidado baseado na espécie identificada

**Benefícios:**
- Reduz barreira de entrada para iniciantes
- Aumenta precisão das configurações de cuidado
- Feature diferencial competitiva

**Implementação Sugerida:**
```
Nova Feature: plant_identification/
├── data/
│   └── datasources/
│       └── plant_identification_api.dart (Plant.id ou similar)
├── domain/
│   ├── entities/
│   │   └── plant_identification_result.dart
│   └── usecases/
│       └── identify_plant_usecase.dart
└── presentation/
    ├── pages/
    │   └── plant_identification_page.dart
    └── widgets/
        └── identification_camera_widget.dart
```

---

#### 1.2 **Enciclopédia de Plantas**
**Prioridade:** ⭐⭐⭐⭐ ALTA  
**Complexidade:** 🔧🔧 BAIXA-MÉDIA  
**Monetização:** 💰 Free (atrai usuários) / 💰💰 Premium (conteúdo avançado)

**Descrição:**
- Base de dados local com informações de espécies populares
- Guias de cuidado detalhados por espécie
- Dicas sazonais (inverno/verão)
- Problemas comuns e soluções

**Estrutura de Dados Sugerida:**
```dart
class PlantEncyclopediaEntry {
  final String id;
  final String commonName;
  final String scientificName;
  final String family;
  final String origin;
  final String description;
  final LightRequirement lightRequirement;
  final WateringNeeds wateringNeeds;
  final TemperatureRange idealTemperature;
  final HumidityRange idealHumidity;
  final List<String> commonProblems;
  final List<String> careTips;
  final List<String> imageUrls;
  final Difficulty difficulty; // beginner, intermediate, advanced
  final bool isPetSafe;
  final List<String> tags;
}
```

---

### **Categoria 2: Monitoramento Avançado** 📈

#### 2.1 **Diário da Planta (Plant Journal)**
**Prioridade:** ⭐⭐⭐⭐⭐ ALTA  
**Complexidade:** 🔧🔧 BAIXA-MÉDIA  
**Monetização:** 💰💰 Premium

**Descrição:**
- Registro fotográfico do crescimento ao longo do tempo
- Timeline visual com fotos datadas
- Anotações sobre saúde, floração, problemas
- Comparação "antes e depois"
- Geração automática de time-lapse

**Nova Entidade:**
```dart
class PlantJournalEntry extends BaseSyncEntity {
  final String plantId;
  final DateTime date;
  final String? imageUrl;
  final String? notes;
  final PlantHealthStatus healthStatus; // healthy, recovering, sick, thriving
  final double? heightCm;
  final int? leafCount;
  final bool isFlowering;
  final bool isFruiting;
  final List<String> tags; // 'new_leaf', 'pest_found', 'repotted', etc.
}
```

**Benefícios:**
- Engajamento diário do usuário
- Dados valiosos para análise de padrões
- Conteúdo compartilhável em redes sociais

---

#### 2.2 **Dashboard de Saúde das Plantas**
**Prioridade:** ⭐⭐⭐⭐ ALTA  
**Complexidade:** 🔧🔧🔧 MÉDIA  
**Monetização:** 💰💰 Premium

**Descrição:**
- Visão geral de todas as plantas em um dashboard
- Indicadores de saúde por planta (baseado em tarefas em dia)
- Alertas de plantas negligenciadas
- Estatísticas: plantas saudáveis, em recuperação, precisando de atenção
- Gráficos de atividades de cuidado ao longo do tempo

**Widgets Sugeridos:**
- 🟢 Plantas em dia
- 🟡 Plantas precisando atenção
- 🔴 Plantas negligenciadas
- 📊 Gráfico de tarefas completadas (semana/mês)
- 🏆 Streak de dias cuidando das plantas

---

#### 2.3 **Integração com Sensores IoT**
**Prioridade:** ⭐⭐⭐ MÉDIA  
**Complexidade:** 🔧🔧🔧🔧 ALTA  
**Monetização:** 💰💰💰 Premium Plus

**Descrição:**
- Integração com sensores de umidade do solo (Bluetooth/WiFi)
- Monitoramento de temperatura ambiente
- Alertas automáticos baseados em dados reais
- Suporte a dispositivos populares (Xiaomi Flora, HHCC, etc.)

**Nota:** Feature avançada, considerar para versão futura.

---

### **Categoria 3: Gamificação e Engajamento** 🎮

#### 3.1 **Sistema de Conquistas e Badges**
**Prioridade:** ⭐⭐⭐⭐ ALTA  
**Complexidade:** 🔧🔧 BAIXA-MÉDIA  
**Monetização:** 💰 Free (aumenta retenção)

**Descrição:**
- Conquistas por marcos (primeira planta, 10 plantas, 100 tarefas, etc.)
- Badges especiais (Mestre da Rega, Guru do Adubo, etc.)
- Streaks diários/semanais
- Níveis de experiência do usuário

**Conquistas Sugeridas:**
```dart
enum Achievement {
  // Plantas
  firstPlant('Primeira Semente', 'Cadastrou sua primeira planta'),
  plantCollector10('Colecionador', 'Possui 10 plantas'),
  plantCollector25('Jardineiro', 'Possui 25 plantas'),
  plantCollector50('Botânico', 'Possui 50 plantas'),
  
  // Tarefas
  firstTask('Primeiro Cuidado', 'Completou sua primeira tarefa'),
  taskMaster100('Dedicado', 'Completou 100 tarefas'),
  taskMaster500('Mestre Jardineiro', 'Completou 500 tarefas'),
  
  // Streaks
  streak7('Semana Perfeita', '7 dias seguidos cuidando das plantas'),
  streak30('Mês Dedicado', '30 dias seguidos cuidando das plantas'),
  streak100('Compromisso Total', '100 dias seguidos'),
  
  // Especiais
  noPlantDeath('Guardião Verde', 'Nenhuma planta perdida em 6 meses'),
  allTasksOnTime('Pontualidade', 'Todas as tarefas no prazo por 1 mês'),
  nightOwl('Coruja Noturna', 'Completou tarefa após meia-noite'),
  earlyBird('Madrugador', 'Completou tarefa antes das 6h'),
}
```

---

#### 3.2 **Desafios Semanais/Mensais**
**Prioridade:** ⭐⭐⭐ MÉDIA  
**Complexidade:** 🔧🔧 BAIXA-MÉDIA  
**Monetização:** 💰 Free (aumenta engajamento)

**Descrição:**
- Desafios como "Complete todas as regas esta semana"
- Recompensas em pontos ou badges
- Ranking entre usuários (opcional, comunidade)

---

### **Categoria 4: Social e Comunidade** 👥

#### 4.1 **Compartilhamento Social**
**Prioridade:** ⭐⭐⭐ MÉDIA  
**Complexidade:** 🔧 BAIXA  
**Monetização:** 💰 Free (marketing orgânico)

**Descrição:**
- Compartilhar planta/progresso em redes sociais
- Cards bonitos gerados automaticamente
- "Minha coleção de plantas" compartilhável
- Stories de crescimento

---

#### 4.2 **Comunidade de Plantas (Futuro)**
**Prioridade:** ⭐⭐ BAIXA  
**Complexidade:** 🔧🔧🔧🔧🔧 MUITO ALTA  
**Monetização:** 💰💰💰 Premium

**Descrição:**
- Feed de fotos de plantas de outros usuários
- Perguntas e respostas sobre cuidados
- Troca/doação de mudas na região
- **Nota:** Feature complexa, considerar para versão muito futura ou app separado

---

### **Categoria 5: Praticidade e Automação** ⚡

#### 5.1 **Lembretes Inteligentes**
**Prioridade:** ⭐⭐⭐⭐⭐ ALTA  
**Complexidade:** 🔧🔧 BAIXA-MÉDIA  
**Monetização:** 💰💰 Premium

**Descrição:**
- Ajuste automático de frequência de rega baseado no clima
- Integração com API de clima para ajustar cuidados
- "Vai chover amanhã, adie a rega"
- "Onda de calor prevista, aumente a frequência"

**Integração Sugerida:**
- OpenWeatherMap API (gratuita até certo limite)
- Localização do usuário para clima local

---

#### 5.2 **Modo Férias**
**Prioridade:** ⭐⭐⭐⭐ ALTA  
**Complexidade:** 🔧 BAIXA  
**Monetização:** 💰 Free

**Descrição:**
- Usuário informa período de ausência
- App sugere preparação (rega extra antes de sair)
- Pausa notificações durante o período
- Checklist de retorno

---

#### 5.3 **Agrupamento por Cômodo/Local**
**Prioridade:** ⭐⭐⭐⭐ ALTA  
**Complexidade:** 🔧 BAIXA (já existe Space, expandir)  
**Monetização:** 💰 Free

**Descrição:**
- Expandir entidade Space atual
- Visualização de plantas por cômodo (sala, quarto, varanda)
- Ícones visuais por tipo de espaço
- Filtros rápidos na lista

**Melhorias na Entidade Space:**
```dart
class Space extends BaseSyncEntity {
  // ... campos existentes ...
  final SpaceType type; // indoor, outdoor, balcony, office, etc.
  final String? iconName; // ícone personalizado
  final String? color; // cor do card
  final int plantCount; // computed
}
```

---

#### 5.4 **Quick Actions (Ações Rápidas)**
**Prioridade:** ⭐⭐⭐⭐ ALTA  
**Complexidade:** 🔧 BAIXA  
**Monetização:** 💰 Free

**Descrição:**
- Botão "Reguei todas" para marcar múltiplas plantas
- Ações em lote por espaço
- Widget na home do celular para ação rápida
- Atalhos do iOS/Android

---

### **Categoria 6: Conteúdo Educacional** 📚

#### 6.1 **Dicas do Dia**
**Prioridade:** ⭐⭐⭐ MÉDIA  
**Complexidade:** 🔧 BAIXA  
**Monetização:** 💰 Free

**Descrição:**
- Card na home com dica diária de jardinagem
- Dicas sazonais (ex: "No inverno, reduza a rega")
- Curiosidades sobre plantas
- Rotativo, baseado em banco local

---

#### 6.2 **Guias de Problemas Comuns**
**Prioridade:** ⭐⭐⭐⭐ ALTA  
**Complexidade:** 🔧🔧 BAIXA-MÉDIA  
**Monetização:** 💰💰 Premium (diagnóstico avançado)

**Descrição:**
- "Folhas amarelando? Veja possíveis causas"
- Diagnóstico guiado por perguntas
- Fotos de exemplo de problemas
- Soluções sugeridas

**Estrutura:**
```dart
class PlantProblem {
  final String id;
  final String title; // "Folhas Amarelando"
  final String description;
  final List<String> possibleCauses;
  final List<String> symptoms;
  final List<String> solutions;
  final List<String> preventionTips;
  final List<String> imageUrls;
  final List<String> affectedPlantTypes;
}
```

---

### **Categoria 7: Monetização Adicional** 💰

#### 7.1 **Loja de Produtos (Afiliados)**
**Prioridade:** ⭐⭐ BAIXA  
**Complexidade:** 🔧🔧 BAIXA-MÉDIA  
**Monetização:** 💰💰💰 Receita de afiliados

**Descrição:**
- Recomendações de produtos (vasos, fertilizantes, ferramentas)
- Links de afiliados para Amazon, lojas de jardinagem
- Produtos recomendados baseados nas plantas do usuário

---

#### 7.2 **Consultoria com Especialistas (Marketplace)**
**Prioridade:** ⭐ MUITO BAIXA  
**Complexidade:** 🔧🔧🔧🔧🔧 MUITO ALTA  
**Monetização:** 💰💰💰 Comissão

**Nota:** Feature muito complexa, considerar apenas se houver demanda validada.

---

## 📋 Roadmap Sugerido

### **Fase 1 - Quick Wins (1-2 meses)**
Foco: Features de baixa complexidade com alto impacto

| Feature | Prioridade | Esforço | Impacto |
|---------|------------|---------|---------|
| Quick Actions (Ações Rápidas) | ⭐⭐⭐⭐ | 🔧 | Alto |
| Modo Férias | ⭐⭐⭐⭐ | 🔧 | Alto |
| Agrupamento por Cômodo (expandir Space) | ⭐⭐⭐⭐ | 🔧 | Alto |
| Dicas do Dia | ⭐⭐⭐ | 🔧 | Médio |
| Compartilhamento Social | ⭐⭐⭐ | 🔧 | Médio |

### **Fase 2 - Engajamento (2-3 meses)**
Foco: Aumentar retenção e uso diário

| Feature | Prioridade | Esforço | Impacto |
|---------|------------|---------|---------|
| Sistema de Conquistas/Badges | ⭐⭐⭐⭐ | 🔧🔧 | Alto |
| Diário da Planta (Journal) | ⭐⭐⭐⭐⭐ | 🔧🔧 | Muito Alto |
| Dashboard de Saúde | ⭐⭐⭐⭐ | 🔧🔧🔧 | Alto |
| Desafios Semanais | ⭐⭐⭐ | 🔧🔧 | Médio |

### **Fase 3 - Diferenciação (3-4 meses)**
Foco: Features premium e diferenciação competitiva

| Feature | Prioridade | Esforço | Impacto |
|---------|------------|---------|---------|
| Identificação de Plantas (AI) | ⭐⭐⭐⭐⭐ | 🔧🔧🔧 | Muito Alto |
| Enciclopédia de Plantas | ⭐⭐⭐⭐ | 🔧🔧 | Alto |
| Lembretes Inteligentes (Clima) | ⭐⭐⭐⭐⭐ | 🔧🔧 | Alto |
| Guias de Problemas | ⭐⭐⭐⭐ | 🔧🔧 | Alto |

### **Fase 4 - Avançado (6+ meses)**
Foco: Features de longo prazo

| Feature | Prioridade | Esforço | Impacto |
|---------|------------|---------|---------|
| Integração IoT | ⭐⭐⭐ | 🔧🔧🔧🔧 | Alto (nicho) |
| Loja de Afiliados | ⭐⭐ | 🔧🔧 | Médio |
| Comunidade | ⭐⭐ | 🔧🔧🔧🔧🔧 | Alto (mas complexo) |

---

## 🎯 Recomendação de Priorização

### **Top 5 Features para Implementar Primeiro:**

1. **🥇 Diário da Planta (Journal)** - Alto engajamento, diferencial competitivo, relativamente simples
2. **🥈 Identificação de Plantas (AI)** - Killer feature, atrai novos usuários, justifica premium
3. **🥉 Sistema de Conquistas** - Aumenta retenção drasticamente, baixo custo
4. **4️⃣ Dashboard de Saúde** - Visão útil, mostra valor do app
5. **5️⃣ Lembretes Inteligentes** - Praticidade real, diferencial premium

### **Features "Low-Hanging Fruit" (Implementação Rápida):**
- ✅ Quick Actions
- ✅ Modo Férias
- ✅ Dicas do Dia
- ✅ Compartilhamento Social
- ✅ Expandir Spaces com tipos e ícones

---

## 📊 Análise de Impacto no Modelo de Negócio

| Feature | Impacto Free | Impacto Premium | Retenção | Aquisição |
|---------|--------------|-----------------|----------|-----------|
| Identificação AI | - | ⭐⭐⭐⭐⭐ | ⭐⭐⭐ | ⭐⭐⭐⭐⭐ |
| Diário | ⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐⭐ |
| Conquistas | ⭐⭐⭐⭐⭐ | - | ⭐⭐⭐⭐⭐ | ⭐⭐ |
| Dashboard | ⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐⭐ |
| Clima | ⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐ |
| Enciclopédia | ⭐⭐⭐⭐ | ⭐⭐⭐ | ⭐⭐⭐ | ⭐⭐⭐⭐ |

---

## 🔧 Considerações Técnicas

### **APIs Externas Recomendadas:**

| API | Uso | Custo |
|-----|-----|-------|
| **Plant.id** | Identificação de plantas | Freemium (100 req/dia grátis) |
| **PlantNet** | Identificação alternativa | Gratuito (acadêmico) |
| **OpenWeatherMap** | Dados de clima | Freemium (60 req/min grátis) |
| **Unsplash** | Imagens de plantas | Gratuito |

### **Estrutura de Novas Features:**

Seguir padrão Clean Architecture existente:
```
lib/features/[feature_name]/
├── data/
│   ├── datasources/
│   ├── models/
│   └── repositories/
├── domain/
│   ├── entities/
│   ├── repositories/
│   └── usecases/
└── presentation/
    ├── pages/
    ├── providers/
    └── widgets/
```

---

## ✅ Próximos Passos

1. **Validar priorização** com stakeholders
2. **Estimar esforço detalhado** das features selecionadas
3. **Criar issues/cards** para cada feature aprovada
4. **Definir métricas de sucesso** para cada feature
5. **Iniciar implementação** da Fase 1

---

*Documento gerado para análise e discussão. Prioridades podem ser ajustadas baseado em feedback de usuários e métricas do app.*

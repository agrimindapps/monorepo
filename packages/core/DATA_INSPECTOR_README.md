# 🔍 Inspetor de Dados Unificado

Uma implementação unificada do Inspetor de Dados que combina os melhores elementos de interface dos três apps do monorepo.

## 🏆 Características Principais

### ✅ **Elementos Combinados**
- **Dashboard Overview** (app-gasometer) - Visão geral com estatísticas visuais
- **Gerenciamento Avançado de Hive** (app-receituagro) - Controle completo das boxes
- **SharedPreferences Aprimorado** (app-plantis) - Busca e filtragem em tempo real
- **Sistema de Exportação** (app-receituagro) - Export avançado com multiple formatos
- **Segurança Robusta** (app-plantis) - Proteção em builds de produção

### 🎨 **Sistema de Tema Flexível**
- Adaptação automática ao tema do app
- Tema desenvolvedor (escuro/teal)
- Cores personalizáveis por app
- Design tokens consistentes

## 🚀 Como Usar

### 1. **Implementação Básica**
```dart
import 'package:core/core.dart';

// Na sua página de configurações ou desenvolvimento
ElevatedButton(
  onPressed: () {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const UnifiedDataInspectorPage(
          appName: 'MeuApp',
        ),
      ),
    );
  },
  child: Text('Inspetor de Dados'),
)
```

### 2. **Com Tema Personalizado**
```dart
UnifiedDataInspectorPage(
  appName: 'ReceitaAgro',
  primaryColor: Colors.green,
  accentColor: Colors.lightGreen,
  customBoxes: [
    CustomBoxType(
      key: 'receituagro_preferences',
      displayName: 'Preferências',
      description: 'Configurações do usuário',
      module: 'ReceitaAgro',
    ),
    CustomBoxType(
      key: 'receituagro_cache',
      displayName: 'Cache',
      description: 'Dados em cache',
      module: 'ReceitaAgro',
    ),
  ],
)
```

### 3. **Com Tema Desenvolvedor**
```dart
UnifiedDataInspectorPage(
  appName: 'Plantis',
  theme: DataInspectorTheme.developer(
    primaryColor: Colors.teal,
    accentColor: Colors.tealAccent,
  ),
  showDevelopmentWarning: true, // Mostra aviso mesmo em debug
)
```

### 4. **Configuração Completa**
```dart
UnifiedDataInspectorPage(
  appName: 'GasoMeter',
  theme: DataInspectorTheme.custom(
    primaryColor: Colors.blue,
    brightness: Brightness.dark,
  ),
  customBoxes: [
    CustomBoxType(
      key: 'vehicles',
      displayName: 'Veículos',
      description: 'Dados dos veículos',
      module: 'GasoMeter',
    ),
  ],
  forceAllowInRelease: false, // NUNCA usar true em produção
  showDevelopmentWarning: true,
)
```

## 🛡️ Sistema de Segurança

### **Proteção em Produção**
```dart
// O SecurityGuard bloqueia automaticamente o acesso em release builds
SecurityGuard(
  appName: 'MeuApp',
  child: DataInspectorContent(),
  // forceAllow: true, // ⚠️ NUNCA usar em produção!
)
```

### **Aviso de Desenvolvimento**
```dart
DevelopmentAccessGuard(
  appName: 'MeuApp',
  child: DataInspectorContent(),
)
```

## 🎨 Personalização de Cores

### **Por App**
```dart
// Cores automáticas baseadas no app
final theme = DataInspectorTheme.fromContext(context);

// Cores personalizadas
final customTheme = DataInspectorTheme.custom(
  primaryColor: Colors.purple,
  backgroundColor: Colors.black,
  brightness: Brightness.dark,
);

// Tema desenvolvedor
final devTheme = DataInspectorTheme.developer(
  primaryColor: Colors.orange,
);
```

### **Cores por Módulo**
O sistema reconhece automaticamente as cores dos apps:
- **ReceitaAgro**: Verde (`Colors.green`)
- **Plantis**: Teal (`Colors.teal`)
- **GasoMeter**: Azul (`Colors.blue`)
- **PetiVeti**: Roxo (`Colors.purple`)
- **TaskoList**: Laranja (`Colors.orange`)
- **AgriHurbi**: Marrom (`Colors.brown`)

## 📊 Funcionalidades por Aba

### 🎯 **1. Visão Geral**
- Estatísticas visuais do sistema
- Cards informativos com métricas
- Ações rápidas (atualizar, exportar, limpar)
- Preview das boxes disponíveis
- Informações do sistema

### 📦 **2. Hive Boxes**
- Lista todas as boxes disponíveis
- Visualização de dados por box
- Estatísticas de registros
- Export individual por box
- Status de saúde das boxes

### ⚙️ **3. SharedPreferences**
- Busca em tempo real
- Filtros por tipo e valor
- Cópia para clipboard
- Remoção de chaves
- Export completo

### 📤 **4. Exportar**
- Export de boxes individuais
- Export completo do sistema
- Múltiplos formatos (JSON, CSV)
- Compartilhamento via sistema
- Histórico de exports

## 🔧 Migração dos Apps

### **app-receituagro**
```dart
// Antes
import 'features/settings/presentation/pages/data_inspector_page.dart';

// Depois  
import 'package:core/core.dart';

// Substituir por
UnifiedDataInspectorPage(
  appName: 'ReceitaAgro',
  primaryColor: Colors.green,
)
```

### **app-plantis** 
```dart
// Manter tema escuro característico
UnifiedDataInspectorPage(
  appName: 'Plantis',
  theme: DataInspectorTheme.developer(),
  showDevelopmentWarning: true,
)
```

### **app-gasometer**
```dart  
// Usar o dashboard overview
UnifiedDataInspectorPage(
  appName: 'GasoMeter',
  primaryColor: Colors.blue,
)
```

## 📈 Vantagens da Unificação

### ✅ **Consistência**
- Interface uniforme entre apps
- Mesmos padrões de UX/UI
- Comportamento previsível

### ⚡ **Manutenibilidade**
- Código centralizado no core
- Bugfixes beneficiam todos os apps
- Novas features automáticas

### 🎨 **Flexibilidade**
- Cores personalizáveis por app
- Temas adaptativos
- Configuração granular

### 🛡️ **Segurança**
- Proteção automática em produção
- Avisos de desenvolvimento
- Controle de acesso centralizado

## 🚦 Status de Implementação

- ✅ **Core Package**: Sistema de tema e estrutura base
- ✅ **Security Guard**: Proteção e avisos implementados  
- ✅ **Overview Tab**: Dashboard completo
- 🔄 **Hive Boxes Tab**: Em desenvolvimento
- 🔄 **SharedPrefs Tab**: Em desenvolvimento  
- 🔄 **Export Tab**: Em desenvolvimento
- ⏳ **Migração Apps**: Aguardando conclusão dos tabs

## 📞 Suporte

Para dúvidas ou problemas com o Inspetor de Dados Unificado, consulte:
- Código fonte: `packages/core/lib/src/presentation/data_inspector/`
- Exemplos: Este README
- Issues: GitHub Issues do monorepo
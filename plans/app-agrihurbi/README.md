# 🌾 AgriHurbi - Módulo de Gestão Agropecuária

## 📋 Índice

- [Visão Geral](#-visão-geral)
- [Funcionalidades](#-funcionalidades)
- [Arquitetura](#-arquitetura)
- [Estrutura do Projeto](#-estrutura-do-projeto)
- [Instalação e Configuração](#-instalação-e-configuração)
- [Como Usar](#-como-usar)
- [Guias de Desenvolvimento](#-guias-de-desenvolvimento)
- [Contribuindo](#-contribuindo)
- [Licença](#-licença)

## 🎯 Visão Geral

O **AgriHurbi** é um módulo completo de gestão agropecuária integrado ao ecossistema FNutriTuti. Desenvolvido especificamente para produtores rurais, profissionais da agricultura e pecuária, oferece ferramentas abrangentes para gestão de propriedades rurais, cálculos agronômicos e monitoramento meteorológico.

### 🎨 Características Principais

- **Interface Responsiva**: Adaptada para mobile, tablet e desktop
- **Gestão Offline**: Funciona sem conexão com sincronização automática
- **Tema Personalizado**: Sistema de cores voltado para agricultura
- **Calculadoras Especializadas**: Mais de 20 calculadoras agronômicas
- **Monitoramento Meteorológico**: Sistema completo de pluviometria

## ⚡ Funcionalidades

### 🐄 Gestão de Pecuária
- **Bovinos**: Cadastro completo, controle genealógico, histórico sanitário
- **Equinos**: Gestão de cavalos, éguas e potros
- **Monitoramento de Saúde**: Registro de vacinas, medicamentos e tratamentos
- **Relatórios**: Estatísticas de plantel e produtividade

### 🌱 Agricultura
- **Cultivos**: Gestão de plantações e safras
- **Implementos**: Controle de maquinário e equipamentos
- **Bulas**: Biblioteca digital de defensivos e fertilizantes
- **Rotação de Culturas**: Planejamento de rotação e sucessão

### 🧮 Calculadoras Especializadas

#### Balanço Nutricional
- Adubação orgânica
- Correção de acidez
- Micronutrientes
- NPK personalizado

#### Irrigação
- Necessidade hídrica das culturas
- Dimensionamento de sistemas
- Evapotranspiração
- Capacidade de campo

#### Pecuária
- Aproveitamento de carcaça
- Loteamento bovino
- Conversão alimentar
- Ganho de peso

#### Rendimento
- Estimativa de produção
- Cereais e grãos
- Leguminosas
- Análise de rentabilidade

### ⛈️ Ferramentas Meteorológicas
- **Pluviômetros**: Cadastro e gestão de estações
- **Medições**: Registro de precipitação
- **Estatísticas**: Análise de dados climáticos
- **Gráficos**: Visualização temporal de chuvas

### 📊 Recursos Adicionais
- **Notícias**: Feed atualizado do mercado agropecuário
- **Commodities**: Preços em tempo real (CEPEA)
- **Clima**: Previsão meteorológica integrada
- **Exportação**: Relatórios em PDF/Excel

## 🏗️ Arquitetura

O módulo segue a arquitetura **GetX** com separação clara de responsabilidades:

```
app-agrihurbi/
├── 📱 Presentation Layer
│   ├── pages/          # Telas da aplicação
│   ├── widgets/        # Componentes reutilizáveis
│   └── theme/          # Sistema de tema
├── 🎮 Controller Layer
│   └── controllers/    # Controladores GetX
├── 💾 Data Layer
│   ├── models/         # Modelos de dados
│   ├── repository/     # Repositórios
│   └── services/       # Serviços
└── 🔧 Infrastructure
    ├── constants/      # Constantes
    └── assets/         # Recursos estáticos
```

### 🎨 Sistema de Tema

O módulo utiliza um sistema de tema centralizado baseado no **AgrihurbiTheme**:

```dart
// Cores principais da agricultura
AgrihurbiTheme.agriculturaPrimary    // Verde principal
AgrihurbiTheme.agriculturaSecondary  // Verde escuro
AgrihurbiTheme.agriculturaSurface    // Verde claro

// Estilos de texto
AgrihurbiTheme.headingLarge
AgrihurbiTheme.bodyMedium
AgrihurbiTheme.labelSmall

// Componentes
AgrihurbiTheme.cardDecoration
AgrihurbiTheme.primaryButtonStyle
```

### 📊 State Management

Implementa uma abordagem híbrida de gerenciamento de estado:

- **UnifiedDataService**: Centralizador de dados
- **AgrihurbiStateManager**: Gerenciador de estado global
- **Controllers específicos**: Para cada feature

## 📁 Estrutura do Projeto

### 📱 Pages (Telas)

```
pages/
├── 🐄 bovinos/         # Gestão de bovinos
│   ├── cadastro/       # Cadastro de animais
│   ├── detalhes/       # Detalhes do animal
│   └── lista/          # Listagem do plantel
├── 🐴 equinos/         # Gestão de equinos
├── 🧮 calc/            # Calculadoras
│   ├── balanco_nutricional/
│   ├── irrigacao/
│   ├── pecuaria/
│   └── rendimento/
├── ⛈️ pluviometro/     # Sistema meteorológico
│   ├── medicoes_cadastro/
│   ├── medicoes_page/
│   ├── pluviometros_cadastro/
│   └── resultados_page/
└── 📄 outras páginas...
```

### 🎮 Controllers

```
controllers/
├── bovinos_controller.dart
├── enhanced_bovinos_controller.dart
├── equinos_controller.dart
├── medicoes_controller.dart
└── pluviometros_controller.dart
```

### 💾 Models & Repository

```
models/                 # Modelos de dados
├── bovino_class.dart
├── equino_class.dart
├── medicoes_models.dart
└── pluviometros_models.dart

repository/             # Acesso a dados
├── bovinos_repository.dart
├── medicoes_repository.dart
└── pluviometros_repository.dart
```

### 🔧 Services

```
services/
├── state_management/   # Gerenciamento de estado
├── interfaces/         # Contratos de serviços
├── error_handling/     # Tratamento de erros
├── bovino_upload_service.dart
├── weather_service.dart
├── commodity_service.dart
└── rss_service.dart
```

## 🚀 Instalação e Configuração

### Pré-requisitos

- Flutter SDK 3.24+
- Dart 3.4+
- GetX ^4.6.0
- Hive (banco local)
- Supabase (backend)

### Dependências Principais

```yaml
dependencies:
  get: ^4.6.0
  hive: ^2.2.3
  supabase_flutter: ^1.10.0
  cached_network_image: ^3.2.0
  image_picker: ^0.8.7
  pdf: ^3.10.0
  fl_chart: ^0.63.0
```

### Configuração

1. **Configure o Supabase**:
```dart
// constants/database_const.dart
class DatabaseConst {
  static const String supabaseUrl = 'YOUR_SUPABASE_URL';
  static const String supabaseKey = 'YOUR_SUPABASE_ANON_KEY';
}
```

2. **Initialize Hive**:
```dart
await AgrihurbiHiveService.initializeBoxes();
```

3. **Configure Theme**:
```dart
GetMaterialApp(
  theme: ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: AgrihurbiTheme.agriculturaPrimary,
    ),
  ),
);
```

## 📖 Como Usar

### Navegação Principal

O módulo utiliza um **BottomNavigationBar** com 4 seções:

1. **🌱 Agricultura**: Cultivos, implementos, bulas
2. **🐄 Pecuária**: Bovinos, equinos, saúde animal  
3. **🧮 Cálculos**: Calculadoras especializadas
4. **⛈️ Ferramentas**: Pluviometria, clima, notícias

### Exemplos de Uso

#### Cadastrar um Bovino

```dart
// Navegue para a página de cadastro
Get.toNamed('/bovinos/cadastro');

// Ou use o controller diretamente
final controller = Get.find<BovinosCadastroController>();
await controller.salvarBovino(bovinoData);
```

#### Registrar Medição de Chuva

```dart
final controller = Get.find<MedicoesCadastroController>();
await controller.salvarMedicao(
  pluviometroId: 'id_do_pluviometro',
  quantidade: 25.5,
  dataHora: DateTime.now(),
);
```

#### Calcular Adubação

```dart
final controller = Get.find<AdubacaoOrganicaController>();
final resultado = controller.calcularAdubacao(
  area: 10.0,
  cultura: 'Milho',
  tipoAdubo: 'Esterco Bovino',
);
```

## 🛠️ Guias de Desenvolvimento

### Adicionando Nova Calculadora

1. **Crie a estrutura**:
```
calc/nova_calculadora/
├── controller/
├── model/
├── widgets/
└── index.dart
```

2. **Estenda BaseCalculatorController**:
```dart
class NovaCalculadoraController extends BaseCalculatorController {
  @override
  void calcular() {
    // Implementar cálculo
  }
}
```

3. **Registre nas rotas**:
```dart
GetPage(
  name: '/calc/nova-calculadora',
  page: () => const NovaCalculadoraPage(),
  binding: NovaCalculadoraBinding(),
)
```

### Padrões de Código

#### Controllers
- Use GetX controllers com `.obs` para reatividade
- Implemente `onInit()` e `onClose()` 
- Faça dispose de recursos

#### Widgets
- Use `GetView<Controller>` para widgets com controller
- Aplique o `AgrihurbiTheme` consistentemente
- Implemente keys para listas

#### Repository
- Implemente interfaces para testabilidade
- Use Result pattern para tratamento de erros
- Cache dados localmente com Hive

### Boas Práticas

- **Responsividade**: Use `AgrihurbiTheme.isMobile(context)`
- **Performance**: Implemente lazy loading
- **Acessibilidade**: Adicione tooltips e semantics
- **Validação**: Use validators centralizados
- **Internacionalização**: Prepare para múltiplos idiomas

## 🤝 Contribuindo

### Como Contribuir

1. **Fork** o repositório
2. **Crie** uma branch para sua feature (`git checkout -b feature/AmazingFeature`)
3. **Commit** suas mudanças (`git commit -m 'Add AmazingFeature'`)
4. **Push** para a branch (`git push origin feature/AmazingFeature`)
5. **Abra** um Pull Request

### Diretrizes

- Siga os padrões de código existentes
- Adicione testes para novas funcionalidades
- Documente mudanças no CHANGELOG.md
- Mantenha commits pequenos e focados

### Reportando Issues

Use o template de issues para reportar:
- 🐛 **Bugs**: Descreva o problema e como reproduzir
- ✨ **Features**: Explique a funcionalidade desejada
- 📚 **Documentação**: Sugira melhorias na documentação

## 📊 Roadmap

### Próximas Versões

#### v2.1.0
- [ ] Sistema de backup automático
- [ ] Relatórios avançados em PDF
- [ ] Integração com GPS
- [ ] Modo offline completo

#### v2.2.0  
- [ ] IA para recomendações
- [ ] API pública
- [ ] Dashboard web
- [ ] Integração com drones

### Melhorias Contínuas
- Performance optimization
- UI/UX enhancements  
- Security updates
- New calculator types

## 📞 Suporte

### Canais de Suporte

- **Email**: suporte@fnutrituti.com.br
- **Documentation**: [Wiki do projeto]
- **Issues**: [GitHub Issues]
- **Discussions**: [GitHub Discussions]

### FAQ

**P: Como sincronizo dados offline?**
R: O app sincroniza automaticamente quando conecta. Use `UnifiedDataService.sync()` para forçar.

**P: Posso usar sem internet?**
R: Sim, todas as funcionalidades funcionam offline. Apenas notícias e preços precisam de conexão.

**P: Como backup meus dados?**
R: Vá em Configurações > Backup > Exportar Dados.

## 📜 Licença

Este projeto está licenciado sob a Licença MIT - veja o arquivo [LICENSE](../../../LICENSE) para detalhes.

## 🙏 Agradecimentos

- Equipe de desenvolvimento FNutriTuti
- Comunidade Flutter/GetX
- Produtores rurais que testaram a aplicação
- Contribuidores open source

---

**AgriHurbi** - Transformando a agricultura através da tecnologia 🌾

*Desenvolvido com ❤️ para o agronegócio brasileiro*
# Grow - Aplicativo de Cuidado de Plantas 🌱

## Descrição

O **Grow** é um aplicativo completo para cuidado e monitoramento de plantas, desenvolvido em Flutter com arquitetura modular avançada. Com o Grow, você nunca mais se esquecerá de regar suas plantas e poderá acompanhar seu crescimento de forma organizada e intuitiva.

## Arquitetura

O projeto segue uma arquitetura **MVC + Repository Pattern** com **GetX** para gerenciamento de estado, injeção de dependência e navegação:

- **GetX**: State management, dependency injection e routing
- **Hive**: Banco de dados local NoSQL com type adapters
- **Repository Pattern**: Abstração da camada de dados
- **Modular Architecture**: Organização por funcionalidades
- **Singleton Services**: Serviços globais e utilitários

## Funcionalidades Implementadas

### 🌿 Gerenciamento de Plantas
- **Cadastro completo**: Nome, espécie, local e configurações personalizadas
- **Espaços organizados**: Agrupe plantas por ambiente (casa, jardim, escritório)
- **Detalhes avançados**: Histórico completo de cuidados e observações
- **Busca e filtros**: Encontre plantas rapidamente

### 📅 Sistema de Tarefas Inteligente
- **Rega personalizada**: Frequência baseada no tipo de planta
- **Fertilização programada**: Lembretes sazonais automáticos
- **Cuidados especiais**: Poda, troca de vaso, inspeção de pragas
- **Estatísticas de cuidado**: Acompanhe sua consistência

### 📝 Monitoramento e Histórico
- **Comentários detalhados**: Registre observações sobre cada planta
- **Timeline de cuidados**: Histórico completo de todas as ações
- **Estados de crescimento**: Acompanhe fases de desenvolvimento
- **Integridade de dados**: Sistema automático de verificação e reparo

### 💎 Sistema Premium
- **RevenueCat Integration**: Gerenciamento de assinaturas
- **In-App Purchases**: Compras integradas
- **Funcionalidades exclusivas**: Recursos avançados para assinantes
- **Página promocional**: Landing page integrada

### 🔐 Autenticação e Perfil
- **Sistema de login**: Autenticação segura
- **Perfil personalizado**: Configurações do usuário
- **Sincronização em tempo real**: Dados sempre atualizados

## Estrutura Completa do Módulo

```
app-plantas/
├── app-page.dart                    # Entry point do módulo
├── constants/                       # Constantes globais
│   ├── in_app_purchase_const.dart
│   └── revenuecat_const.dart
├── controllers/                     # Controladores principais
│   ├── auth_controller.dart
│   ├── nova_planta_controller.dart
│   ├── plantas_controller.dart
│   └── realtime_plantas_controller.dart
├── database/                        # Modelos Hive com type adapters
│   ├── comentario_model.dart/.g.dart
│   ├── espaco_model.dart/.g.dart
│   ├── planta_config_model.dart/.g.dart
│   ├── planta_model.dart/.g.dart
│   └── tarefa_model.dart/.g.dart
├── extensions/                      # Extensões de modelos
│   └── planta_model_extensions.dart
├── models/                          # Modelos de dados simples
│   ├── subscription_model.dart
│   └── user_model.dart
├── pages/                          # Páginas organizadas por feature
│   ├── espacos_page/              # Gerenciamento de espaços
│   ├── login_page.dart
│   ├── minha_conta_page/          # Perfil e configurações
│   ├── minhas_plantas_page/       # Lista de plantas do usuário
│   ├── nova_tarefas_page/         # Criação de tarefas
│   ├── planta_cadastro/           # Formulários de cadastro
│   ├── planta_detalhes_page/      # Detalhes da planta
│   ├── planta_form_page/          # Formulário de planta
│   ├── politicas/                 # Termos e políticas
│   ├── premium_page/              # Funcionalidades premium
│   ├── promo_page/                # Página promocional
│   ├── settings/                  # Configurações
│   └── shared/                    # Componentes compartilhados
├── repository/                     # Camada de acesso a dados
│   ├── espaco_repository.dart
│   ├── planta_config_repository.dart
│   ├── planta_repository.dart
│   └── tarefa_repository.dart
├── services/                       # Serviços e lógica de negócio
│   ├── auth_service.dart
│   ├── data_integrity_service.dart
│   ├── plant_care_service.dart
│   ├── planta_service.dart
│   ├── plantas_hive_service.dart
│   ├── plants_service_manager.dart
│   ├── simple_task_service.dart
│   └── subscription_service.dart
├── utils/                          # Utilitários
│   └── data_integrity_repair.dart
└── widgets/                        # Widgets personalizados
    ├── custom_toggle_switch.dart
    └── dialog_cadastro_widget.dart
```

## Stack Tecnológico

### Core
- **Flutter 3.x**: Framework de desenvolvimento
- **Dart**: Linguagem de programação
- **GetX**: State management, navigation e dependency injection

### Persistência
- **Hive**: Banco de dados NoSQL local
- **Hive Generator**: Geração automática de type adapters
- **Build Runner**: Geração de código

### Monetização
- **RevenueCat**: Gerenciamento de assinaturas
- **In-App Purchase**: Compras integradas

### Arquitetura
- **Repository Pattern**: Abstração de dados
- **MVC Pattern**: Organização de código
- **Modular Architecture**: Separação por features
- **Singleton Pattern**: Serviços globais

## Setup e Desenvolvimento

### Pré-requisitos
1. **Flutter SDK** (versão 3.x ou superior)
2. **Dart SDK** (incluído com Flutter)
3. **Build Runner** para geração de código Hive

### Instalação
```bash
# 1. Instalar dependências
flutter pub get

# 2. Gerar adaptadores Hive
dart run build_runner build

# 3. Para desenvolvimento contínuo
dart run build_runner watch
```

### Configuração do Hive
O projeto utiliza Hive com type adapters gerados automaticamente:

```dart
// Modelos principais com annotations
@HiveType(typeId: 1)
class PlantaModel extends HiveObject {
  @HiveField(0) String? id;
  @HiveField(1) String nome;
  // ...
}
```

### Estrutura de Bindings GetX
Cada página possui seu próprio binding para injeção de dependência:

```dart
class MinhasPlantasBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => MinhasPlantasController());
  }
}
```

## Política de Cancelamento

- Assinatura renovada automaticamente
- Cancelamento disponível nas configurações do iTunes
- Deve ser cancelado com 24 horas de antecedência
- Gerenciamento via conta da App Store

## Padrões de Desenvolvimento

### Convenções de Código
- **Nomenclatura**: snake_case para arquivos, camelCase para variáveis
- **Organização**: Uma feature por pasta com bindings, controllers, views e widgets
- **Comentários**: Documentação em português para business logic
- **Type Safety**: Uso rigoroso de tipos do Dart

### Padrões de Arquitetura
```dart
// Controller
class MinhasPlantasController extends GetxController {
  final PlantaRepository _repository = Get.find();
  final RxList<PlantaModel> plantas = <PlantaModel>[].obs;
  
  @override
  void onInit() {
    super.onInit();
    carregarPlantas();
  }
}

// Repository
class PlantaRepository {
  final PlantasHiveService _hiveService = Get.find();
  
  Future<List<PlantaModel>> buscarTodas() async {
    return await _hiveService.getAllPlantas();
  }
}
```

### Testing e Build
```bash
# Verificar integridade do código
flutter analyze

# Executar testes
flutter test

# Build para produção
flutter build apk --release
flutter build ios --release
```

## Status do Desenvolvimento

✅ **Funcional**: Módulo em fase final de desenvolvimento com todas as funcionalidades principais implementadas.

### Recursos Implementados
- ✅ Sistema completo de CRUD para plantas
- ✅ Gerenciamento de espaços e categorização
- ✅ Sistema de tarefas e lembretes
- ✅ Autenticação e perfil de usuário
- ✅ Sistema premium com RevenueCat
- ✅ Persistência local com Hive
- ✅ Integridade e reparo de dados
- ✅ Interface responsiva e acessível

### Em Desenvolvimento
- 🔄 Notificações push
- 🔄 Sincronização em nuvem
- 🔄 Recursos premium adicionais

## Suporte

Para suporte e dúvidas sobre o aplicativo Grow, entre em contato através dos canais oficiais do projeto fNutriTuti.

---

*Mantenha suas plantas felizes e saudáveis com o Grow! 🌱*
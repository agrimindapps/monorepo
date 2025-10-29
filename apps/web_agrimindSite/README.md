# ReceituAgro Web

Site desenvolvido em Flutter Web para consulta e gerenciamento de defensivos agrícolas, promovendo o aplicativo mobile ReceituAgro.

## 📋 Sobre o Projeto

O ReceituAgro Web é uma plataforma que permite aos usuários:
- Consultar defensivos agrícolas e fitossanitários
- Buscar produtos por nome comum, técnico ou ingrediente ativo
- Visualizar detalhes completos dos produtos incluindo:
  - Informações de registro
  - Fabricante e formulação
  - Classe agronômica e ambiental
  - Modo de ação e toxicidade
  - Status de comercialização

## 🚀 Tecnologias Utilizadas

- **Flutter Web** - Framework principal
- **Firebase** - Analytics e configurações
- **Supabase** - Banco de dados e backend
- **GetX** - Gerenciamento de estado e navegação
- **Provider** - Gerenciamento de estado adicional

## 📱 Funcionalidades Principais

### Consulta de Defensivos
- Listagem completa de defensivos disponíveis
- Sistema de busca avançada (mínimo 3 caracteres)
- Filtros por diferentes critérios
- Visualização em grid responsivo

### Interface Responsiva
- Design adaptativo para diferentes tamanhos de tela
- Suporte a temas claro e escuro
- Interface otimizada para web

### Integração com Aplicativo Mobile
- Links para download nas lojas de aplicativos
- Promoção das funcionalidades premium
- Sistema de feedback e comentários

## 🏗️ Arquitetura do Projeto

```
lib/
├── app-site/              # Código específico do site
│   ├── classes/           # Modelos de dados
│   ├── const/             # Constantes e configurações
│   ├── core/              # Utilitários e serviços centrais
│   ├── pages/             # Páginas da aplicação
│   ├── repository/        # Camada de acesso a dados
│   └── services/          # Serviços de negócio
├── models/                # Modelos globais
├── pages/                 # Páginas compartilhadas
├── services/              # Serviços globais
├── themes/                # Configuração de temas
└── widgets/               # Componentes reutilizáveis
```

## 🛠️ Configuração do Ambiente

### Pré-requisitos
- Flutter SDK >=3.4.0
- Dart SDK >=3.4.0
- Conta Firebase configurada
- Conta Supabase configurada

### Instalação
1. Clone o repositório
```bash
git clone https://github.com/agrimindsolucoes/ReceituagroSite.git
cd ReceituagroSite
```

2. Instale as dependências
```bash
flutter pub get
```

3. Configure as variáveis de ambiente
- Configure Firebase em `lib/app-site/const/firebase_const.dart`
- Configure Supabase em `lib/services/supabase_service.dart`

4. Execute o projeto
```bash
flutter run -d chrome
```

## 📊 Principais Dependências

- `firebase_core` & `firebase_analytics` - Integração Firebase
- `supabase_flutter` - Backend e banco de dados
- `get` - Gerenciamento de estado e navegação
- `provider` - Gerenciamento de estado
- `flutter_staggered_grid_view` - Layout em grid
- `url_launcher` - Abertura de URLs externas
- `shared_preferences` - Armazenamento local
- `skeletonizer` - Loading states
- `google_fonts` - Tipografia

## 🔒 Segurança

- Logs seguros implementados
- Validação de formulários
- Cache inteligente para otimização
- Tratamento de erros robusto

## 📈 Analytics

O projeto integra Firebase Analytics para:
- Rastreamento de eventos de usuário
- Análise de performance
- Métricas de conversão

## 🤝 Contribuição

Para contribuir com o projeto:
1. Faça um fork do repositório
2. Crie uma branch para sua feature
3. Commit suas mudanças
4. Abra um Pull Request

## 📄 Licença

Este projeto está sob a licença especificada no arquivo LICENSE.

## 📱 Download do App Mobile

- [Google Play Store](link-para-play-store)
- [Apple App Store](link-para-app-store)

## 📞 Suporte

Para suporte técnico ou dúvidas sobre o uso da plataforma, entre em contato através dos canais oficiais do ReceituAgro.

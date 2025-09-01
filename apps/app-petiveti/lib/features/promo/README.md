# 📱 Página Promocional - PetiVeti

## 🎯 Visão Geral
A página promocional é a primeira tela que os usuários veem ao abrir o PetiVeti. Ela apresenta as funcionalidades do app e permite que os usuários façam pré-cadastro ou naveguem para o login.

## 🏗️ Arquitetura

### Clean Architecture + SOLID
```
features/promo/
├── domain/           # Regras de negócio
│   ├── entities/     # PromoContent, Feature, Testimonial, etc.
│   ├── repositories/ # Interfaces abstratas
│   └── usecases/     # Casos de uso específicos
├── data/             # Acesso a dados
│   ├── models/       # Modelos com serialização JSON
│   └── repositories/ # Implementações concretas
└── presentation/     # Interface do usuário
    ├── pages/        # Página principal
    ├── widgets/      # Componentes visuais
    ├── providers/    # Riverpod state management
    └── states/       # Estados da aplicação
```

## 🎨 Componentes UI

### PromoAppBar
- Header fixo com navegação responsiva
- Botão "Já tenho conta" para ir ao login
- Menu mobile para telas menores

### PromoHeroSection
- Seção principal com branding
- Botões de ação: "Pré-cadastro Gratuito" e "Já tenho conta"
- Status de lançamento

### PromoFeaturesSection
- Grade de funcionalidades com ícones
- Design responsivo (coluna no mobile, grid no desktop)

### PromoScreenshotsSection
- Carousel de screenshots do app
- Indicadores de navegação
- Placeholder enquanto não há imagens

### PromoTestimonialsSection
- Depoimentos de usuários
- Sistema de classificação por estrelas
- Avatares gerados automaticamente

### PromoFaqSection
- Perguntas frequentes expansíveis
- Animações suaves

### PromoFooterSection
- Informações de contato
- Links para redes sociais
- Botões para app stores
- Call-to-action final

### PromoPreRegistrationDialog
- Modal para coleta de email
- Validação de email
- Feedback de sucesso/erro

## 🔄 Fluxo de Navegação

### Entrada do App
1. **Usuário abre app** → `/promo` (página promocional)
2. **Usuário clica "Já tenho conta"** → `/login`
3. **Usuário logado acessa app** → `/` (redirecionamento automático)

### Estados de Usuário
- **Não autenticado**: Pode navegar entre `/promo`, `/login`, `/register`
- **Autenticado**: Redirecionado automaticamente para `/` (home)

## 📊 State Management (Riverpod)

### PromoProvider
```dart
- getPromoContent()       // Carrega dados promocionais
- submitPreRegistration() // Envia pré-cadastro
- trackEvent()           // Registra eventos de analytics
- toggleFAQ()           // Expande/colapsa FAQs
- changeScreenshot()    // Navega entre screenshots
```

### PromoState
```dart
- isLoading              // Estado de carregamento
- promoContent           // Dados promocionais
- preRegistrationSuccess // Sucesso no pré-cadastro
- showPreRegistrationDialog // Visibilidade do modal
- currentScreenshotIndex // Screenshot ativa
```

## 🎛️ Configurações

### Roteamento (GoRouter)
```dart
initialLocation: '/promo'  // Inicia pela página promocional

redirect: (context, state) => {
  // Se autenticado e na promo -> home
  // Se não autenticado e tentando acessar área protegida -> promo
}
```

### Dependency Injection
```dart
// Registrado em injection_container.dart
- PromoRepository        // Interface
- PromoRepositoryImpl    // Implementação
- GetPromoContent        // Use case
- SubmitPreRegistration  // Use case  
- TrackAnalytics        // Use case
```

## 📝 Conteúdo Promocional

### Dados Mock Incluídos
- **App Info**: Nome, versão, descrição, tagline
- **Features**: 4 funcionalidades principais com ícones
- **Testimonials**: 2 depoimentos de usuários
- **FAQ**: 3 perguntas frequentes
- **Screenshots**: 3 placeholders
- **Launch Info**: Status e contadores
- **Contact Info**: Emails, telefone, redes sociais

### Personalização
Para alterar o conteúdo, edite:
```dart
PromoContentModel.mock() // lib/features/promo/data/models/promo_content_model.dart
```

## 🚀 Funcionalidades

### ✅ Implementadas
- [x] Design responsivo (mobile/desktop)
- [x] Navegação suave entre seções
- [x] Pré-cadastro com validação de email
- [x] FAQ expansível
- [x] Carousel de screenshots
- [x] Analytics tracking (mock)
- [x] Integração com roteamento
- [x] Estado de loading

### 🔄 Para Implementar
- [ ] Integração com API real
- [ ] Imagens de screenshots reais
- [ ] Analytics com Firebase
- [ ] Internacionalização (i18n)
- [ ] Temas customizáveis
- [ ] Animações avançadas

## 🧪 Testing
```bash
# Análise estática
flutter analyze lib/features/promo/

# Build test
flutter build web --web-renderer canvaskit
flutter build apk --debug
```

## 📱 Experiência do Usuário

### Jornada Ideal
1. **Descoberta**: Usuário abre app e vê página promocional
2. **Exploração**: Navega pelas seções para conhecer funcionalidades
3. **Engajamento**: Preenche pré-cadastro ou vai direto para login
4. **Conversão**: Cria conta e começa a usar o app

### Métricas Trackadas
- `promo_login_clicked` - Clique no botão de login
- `promo_pre_register_clicked` - Clique no pré-cadastro
- `promo_store_clicked` - Clique nos links das lojas
- `promo_social_clicked` - Clique nas redes sociais

---

**Última atualização**: 29/08/2025  
**Status**: ✅ Concluído e pronto para desenvolvimento
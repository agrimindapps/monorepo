# Issues e Melhorias - Minha Conta Page

## 📋 Índice Geral

### 🔴 Complexidade ALTA (8 issues)
1. [REFACTOR] - Separar lógica de negócio do Controller
2. [REFACTOR] - Implementar padrão Repository para dados do usuário
3. [SECURITY] - Implementar validação e sanitização de URLs externas
4. [TODO] - Implementar sistema completo de autenticação Apple/Google
5. [REFACTOR] - Unificar gerenciamento de tema em controller único
6. [OPTIMIZE] - Otimizar renderização de widgets com muitas dependências
7. [TODO] - Implementar navegação para telas não implementadas
8. [REFACTOR] - Melhorar arquitetura de comunicação entre widgets

### 🟡 Complexidade MÉDIA (12 issues)  
9. [BUG] - Corrigir inconsistência no uso de design tokens
10. [STYLE] - Padronizar elevação de cards para tema escuro
11. [BUG] - Tratar fallback de imagem de avatar com erro
12. [FIXME] - Remover uso de métodos deprecated (cores e gradientes)
13. [OPTIMIZE] - Reduzir rebuilds desnecessários com GetX
14. [TODO] - Implementar feedback visual para ações de desenvolvimento
15. [STYLE] - Melhorar responsividade para telas pequenas
16. [BUG] - Corrigir formatação de datas para diferentes locales
17. [TODO] - Adicionar validação de conectividade para URLs
18. [STYLE] - Unificar estilo de botões e componentes
19. [BUG] - Tratar estados de erro em operações assíncronas
20. [OPTIMIZE] - Cachear dados de usuário e assinatura

### 🟢 Complexidade BAIXA (7 issues)
21. [STYLE] - Adicionar animações de transição para melhor UX
22. [TODO] - Implementar logs estruturados para debug
23. [STYLE] - Melhorar contraste de cores para acessibilidade
24. [NOTE] - Documentar constantes e uso correto de design tokens
25. [TEST] - Adicionar testes unitários para widgets customizados
26. [STYLE] - Padronizar spacing e padding usando design tokens
27. [TODO] - Adicionar tooltips informativos nos itens de menu

---

## 🔴 Complexidade ALTA

### 1. [REFACTOR] - Separar lógica de negócio do Controller

**Status:** 🔴 Pendente | **Execução:** Complexa | **Risco:** Médio | **Benefício:** Alto

**Descrição:** O MinhaContaController contém lógica de negócio complexa para geração 
de dados de teste e manipulação de repositórios que deveria estar em services 
dedicados. Isso viola princípios de responsabilidade única e dificulta manutenção.

**Prompt de Implementação:**

Refatore o MinhaContaController extraindo toda lógica de negócio para services 
especializados. Crie TestDataService para geração de dados de teste, 
DataCleanupService para limpeza de registros. Mantenha no controller apenas 
chamadas aos services e navegação. Implemente tratamento de erro robusto e 
loading states apropriados.

**Dependências:** controller/minha_conta_controller.dart, services (criar novos)

**Validação:** Controller deve ter menos de 200 linhas, métodos de negócio 
movidos para services, testes passando

---

### 2. [REFACTOR] - Implementar padrão Repository para dados do usuário

**Status:** 🔴 Pendente | **Execução:** Complexa | **Risco:** Alto | **Benefício:** Alto

**Descrição:** Acesso direto a repositórios de plantas, espaços e configurações 
no controller cria acoplamento forte e dificulta teste e manutenção. Falta 
abstração adequada para operações de dados do usuário.

**Prompt de Implementação:**

Crie UserDataRepository que abstraia todas operações relacionadas aos dados do 
usuário (plantas, espaços, configurações). Implemente interface clara com 
métodos para geração de dados de teste, limpeza, backup e sincronização. 
Injete via GetX e remova acesso direto aos repositórios do controller.

**Dependências:** Todos os repositórios atuais, controller, services

**Validação:** Controller não deve importar repositórios diretamente, 
operações funcionando através do UserDataRepository

---

### 3. [SECURITY] - Implementar validação e sanitização de URLs externas

**Status:** 🔴 Pendente | **Execução:** Moderada | **Risco:** Alto | **Benefício:** Alto

**Descrição:** URLs hardcoded para termos e políticas são abertas sem validação 
adequada, criando risco de redirecionamento malicioso. Falta whitelist de 
domínios confiáveis e validação de URL antes de abrir.

**Prompt de Implementação:**

Crie UrlValidationService com whitelist de domínios confiáveis. Implemente 
validação rigorosa de URLs antes de usar launchUrl. Adicione sanitização de 
parâmetros e verificação de protocolo seguro. Configure timeout para requisições 
e fallback para URLs inválidas. Adicione logs de segurança.

**Dependências:** controller/minha_conta_controller.dart, core/services (criar)

**Validação:** URLs validadas antes do launch, logs de tentativas de acesso, 
whitelist funcionando

---

### 4. [TODO] - Implementar sistema completo de autenticação Apple/Google

**Status:** 🔴 Pendente | **Execução:** Muito Complexa | **Risco:** Alto | **Benefício:** Alto

**Descrição:** Botão de login com Apple está com placeholder mostrando snackbar. 
Falta implementação completa de OAuth para Apple e Google, incluindo tratamento 
de tokens, refresh, e sincronização de dados.

**Prompt de Implementação:**

Implemente AuthService completo com suporte a Apple Sign In e Google Sign In. 
Configure SDKs nativos, trate fluxo OAuth completo, implemente renovação 
automática de tokens, sincronização de dados entre dispositivos. Adicione 
tratamento de erro robusto e fallbacks para problemas de conectividade.

**Dependências:** Várias - SDKs externos, services, models, configuração iOS/Android

**Validação:** Login funcionando com ambos provedores, sincronização ativa, 
tokens renovados automaticamente

---

### 5. [REFACTOR] - Unificar gerenciamento de tema em controller único

**Status:** 🔴 Pendente | **Execução:** Moderada | **Risco:** Médio | **Benefício:** Alto

**Descrição:** Código duplicado e confuso para alternância de tema, verificando 
se PlantasThemeController está registrado e caindo back para ThemeManager. 
Lógica inconsistente entre componentes.

**Prompt de Implementação:**

Refatore sistema de temas criando ThemeService único e consistente. Remova 
verificações condicionais de controllers registrados. Implemente padrão 
singleton para gerenciamento de tema. Sincronize estado entre todos os 
componentes automaticamente. Adicione persistência de preferência do usuário.

**Dependências:** controllers/theme_controller.dart, core/themes/manager.dart, 
todos os widgets que usam tema

**Validação:** Um único ponto de controle de tema, sem verificações condicionais, 
estado sincronizado globalmente

---

### 6. [OPTIMIZE] - Otimizar renderização de widgets com muitas dependências

**Status:** 🔴 Pendente | **Execução:** Complexa | **Risco:** Médio | **Benefício:** Alto

**Descrição:** UserProfileCardWidget e SubscriptionCardWidget fazem múltiplas 
chamadas GetX e têm muitas dependências, causando rebuilds desnecessários. 
Falta memoização e otimização de performance.

**Prompt de Implementação:**

Otimize widgets aplicando técnicas de memoização com const constructors onde 
possível. Implemente GetBuilder em vez de GetX onde estado não muda 
frequentemente. Separe partes estáticas em widgets const separados. Adicione 
debounce para operações custosas. Meça performance antes e depois.

**Dependências:** widgets/user_profile_card_widget.dart, 
widgets/subscription_card_widget.dart

**Validação:** Redução mensurável de rebuilds, performance melhorada, 
widgets otimizados

---

### 7. [TODO] - Implementar navegação para telas não implementadas

**Status:** 🔴 Pendente | **Execução:** Complexa | **Risco:** Baixo | **Benefício:** Alto

**Descrição:** Múltiplas opções do menu mostram apenas TODO ou snackbar 
informativo (notificações, App Store, perfil, configurações). Usuário fica 
frustrado com funcionalidades não funcionais.

**Prompt de Implementação:**

Implemente telas básicas para todas as opções de menu não funcionais. Crie 
NotificationsPage, ProfileEditPage, SettingsPage com funcionalidade mínima 
viável. Adicione navegação adequada e tratamento de estado. Implemente 
formulários básicos onde necessário com validação.

**Dependências:** Criar múltiplas páginas novas, atualizar rotas, controller

**Validação:** Todas opções de menu navegam para telas funcionais, não há mais 
TODOs ou snackbars de placeholder

---

### 8. [REFACTOR] - Melhorar arquitetura de comunicação entre widgets

**Status:** 🔴 Pendente | **Execução:** Complexa | **Risco:** Alto | **Benefício:** Alto

**Descrição:** Comunicação entre widgets parent-child através de callbacks 
diretos no DevelopmentSectionWidget. Falta padrão consistente para comunicação 
e gerenciamento de estado entre componentes.

**Prompt de Implementação:**

Implemente arquitetura de comunicação baseada em eventos ou streams para 
widgets. Crie EventBus ou use GetX streams para comunicação desacoplada. 
Refatore callbacks diretos para padrão observer. Implemente middleware para 
logging e debug de eventos entre widgets.

**Dependências:** Todos os widgets custom, controller, possível EventBus service

**Validação:** Widgets comunicam sem referências diretas, eventos logados, 
arquitetura mais limpa

---

## 🟡 Complexidade MÉDIA

### 9. [BUG] - Corrigir inconsistência no uso de design tokens

**Status:** 🔴 Pendente | **Execução:** Moderada | **Risco:** Baixo | **Benefício:** Médio

**Descrição:** MinhaContaConstants tem métodos para design tokens adaptativos mas 
ainda usa valores hardcoded em várias partes. Inconsistência entre usar design 
tokens e valores estáticos prejudica manutenção.

**Prompt de Implementação:**

Refatore todos os widgets para usar consistentemente os design tokens 
adaptativos. Remova valores hardcoded substituindo por chamadas aos métodos 
dimensoesAdaptaveis() e cores(context). Adicione validação para garantir uso 
correto dos tokens. Documente padrão de uso.

**Dependências:** constants/minha_conta_constants.dart, todos os widgets da página

**Validação:** Nenhum valor hardcoded, todos usando design tokens, 
documentação atualizada

---

### 10. [STYLE] - Padronizar elevação de cards para tema escuro

**Status:** 🔴 Pendente | **Execução:** Simples | **Risco:** Baixo | **Benefício:** Médio

**Descrição:** Cards têm elevação inconsistente entre tema claro e escuro. 
Alguns usam elevation 0 no escuro, outros elevation 2, criando aparência 
inconsistente e prejudicando hierarquia visual.

**Prompt de Implementação:**

Padronize elevação de todos os cards criando função helper no MinhaContaConstants 
que retorna elevação apropriada baseada no tema. Defina elevação 0 para tema 
escuro e 2 para claro consistentemente. Atualize todos os cards para usar a 
função helper.

**Dependências:** constants/minha_conta_constants.dart, todos os widgets com Card

**Validação:** Elevação consistente em todos os cards, aparência uniforme entre 
temas

---

### 11. [BUG] - Tratar fallback de imagem de avatar com erro

**Status:** 🔴 Pendente | **Execução:** Simples | **Risco:** Baixo | **Benefício:** Médio

**Descrição:** UserProfileCardWidget tem callback onBackgroundImageError vazio 
no CircleAvatar. Quando imagem de avatar falha ao carregar, não há feedback 
visual adequado para o usuário.

**Prompt de Implementação:**

Implemente fallback robusto para avatar com erro. Quando imagem falhar, 
substitua por avatar com iniciais. Adicione estado para controlar fallback e 
evitar loops de erro. Considere cache local para imagens de avatar e retry 
automático com backoff.

**Dependências:** widgets/user_profile_card_widget.dart

**Validação:** Avatar sempre mostra conteúdo válido mesmo com erro de imagem, 
sem crashes ou telas brancas

---

### 12. [FIXME] - Remover uso de métodos deprecated (cores e gradientes)

**Status:** 🔴 Pendente | **Execução:** Simples | **Risco:** Baixo | **Benefício:** Médio

**Descrição:** MinhaContaConstants tem métodos marcados como @deprecated 
(coresLegacy, gradientPremium) que ainda podem estar sendo usados. Código 
deprecated deve ser removido ou migrado.

**Prompt de Implementação:**

Faça busca global por uso dos métodos deprecated no projeto. Migre todas as 
referências para os métodos novos adaptativos. Remova completamente os métodos 
deprecated após confirmação que não são mais usados. Adicione teste para 
garantir que adaptação funciona em ambos os temas.

**Dependências:** constants/minha_conta_constants.dart, busca global no projeto

**Validação:** Métodos deprecated removidos, sem quebras, funcionalidade 
mantida

---

### 13. [OPTIMIZE] - Reduzir rebuilds desnecessários com GetX

**Status:** 🔴 Pendente | **Execução:** Moderada | **Risco:** Baixo | **Benefício:** Médio

**Descrição:** Uso excessivo de GetX reativo pode causar rebuilds desnecessários. 
Widgets como tema toggle rebuild toda interface quando poderiam ser mais 
granulares na observação de estado.

**Prompt de Implementação:**

Analise e otimize uso de GetX observables. Use GetBuilder onde estado muda 
pouco, mantenha GetX apenas para estado que muda frequentemente. Implemente 
ever() e workers onde apropriado. Adicione keys em widgets que fazem rebuild 
desnecessário. Meça performance antes e depois.

**Dependências:** Todos os widgets que usam GetX na página

**Validação:** Redução de rebuilds medida com Flutter Inspector, performance 
melhorada

---

### 14. [TODO] - Implementar feedback visual para ações de desenvolvimento

**Status:** 🔴 Pendente | **Execução:** Simples | **Risco:** Baixo | **Benefício:** Médio

**Descrição:** Botões de desenvolvimento (gerar dados, limpar registros) não 
mostram loading durante execução. Usuário não sabe se ação está sendo 
processada, especialmente para operações que podem demorar.

**Prompt de Implementação:**

Adicione loading states visuais para todas as ações de desenvolvimento. 
Implemente progress indicators nos botões durante execução. Desabilite botões 
durante processamento para evitar cliques duplos. Adicione feedback de sucesso 
ou erro mais detalhado com duração apropriada.

**Dependências:** widgets/development_section_widget.dart, controller

**Validação:** Loading visível durante operações, botões desabilitados 
apropriadamente, feedback claro

---

### 15. [STYLE] - Melhorar responsividade para telas pequenas

**Status:** 🔴 Pendente | **Execução:** Moderada | **Risco:** Baixo | **Benefício:** Médio

**Descrição:** Interface não adapta bem para telas pequenas. Textos podem ser 
cortados, botões ficam pequenos demais, spacing inadequado para dispositivos 
menores. Falta breakpoints responsivos.

**Prompt de Implementação:**

Implemente design responsivo usando MediaQuery para adaptar layout conforme 
tamanho da tela. Defina breakpoints apropriados e ajuste fontSizes, paddings e 
tamanhos de componentes. Teste em dispositivos pequenos reais. Adicione overflow 
handling adequado.

**Dependências:** Todos os widgets da página, constants para breakpoints

**Validação:** Interface funciona bem em telas pequenas (menos de 400px largura), 
textos legíveis, botões clicáveis

---

### 16. [BUG] - Corrigir formatação de datas para diferentes locales

**Status:** 🔴 Pendente | **Execução:** Simples | **Risco:** Baixo | **Benefício:** Médio

**Descrição:** Métodos _formatarDataCriacao e _formatarData usam formatação 
hardcoded não considerando locale do usuário. Datas podem aparecer em formato 
confuso para usuários de diferentes regiões.

**Prompt de Implementação:**

Implemente formatação de datas internacionalizada usando package intl. 
Configure formatação baseada no locale do dispositivo. Adicione fallback para 
locale padrão. Teste com diferentes locales para garantir formatação adequada. 
Considere fuso horário do usuário.

**Dependências:** widgets com formatação de data, package intl

**Validação:** Datas formatadas corretamente para diferentes locales, fuso 
horário respeitado

---

### 17. [TODO] - Adicionar validação de conectividade para URLs

**Status:** 🔴 Pendente | **Execução:** Simples | **Risco:** Baixo | **Benefício:** Médio

**Descrição:** Métodos navigateToTermos e navigateToPoliticas não verificam 
conectividade antes de tentar abrir URLs. Usuário pode ver erro confuso quando 
sem internet.

**Prompt de Implementação:**

Adicione verificação de conectividade antes de tentar abrir URLs externas. 
Use package connectivity_plus para verificar status da rede. Mostre mensagem 
amigável quando sem conexão. Implemente retry automático quando conectividade 
for restaurada.

**Dependências:** controller, package connectivity_plus

**Validação:** URLs só abrem com conexão, mensagem clara quando offline, retry 
funciona

---

### 18. [STYLE] - Unificar estilo de botões e componentes

**Status:** 🔴 Pendente | **Execução:** Moderada | **Risco:** Baixo | **Benefício:** Médio

**Descrição:** Botões e componentes têm estilos inconsistentes. ElevatedButton, 
PopupMenuButton, switches têm cores e bordas diferentes. Falta design system 
unificado.

**Prompt de Implementação:**

Crie theme data unificado para todos os componentes da página. Defina cores, 
bordas, elevações consistentes no tema do app. Remova estilos inline substituindo 
por theme. Documente design system criado. Teste em ambos os temas claro/escuro.

**Dependências:** Todos os widgets, theme configuration

**Validação:** Aparência consistente de todos os componentes, sem estilos 
inline, documentação criada

---

### 19. [BUG] - Tratar estados de erro em operações assíncronas

**Status:** 🔴 Pendente | **Execução:** Moderada | **Risco:** Médio | **Benefício:** Médio

**Descrição:** Operações async como gerarDadosDeTeste e limparTodosRegistros 
têm tratamento de erro básico. Falhas específicas (permissão, espaço, corrupção) 
não são tratadas adequadamente.

**Prompt de Implementação:**

Implemente tratamento de erro granular para operações async. Defina tipos de 
erro específicos (DatabaseError, PermissionError, StorageError). Adicione 
recovery automático onde possível. Implemente logging detalhado para debug. 
Mostre mensagens de erro específicas para cada situação.

**Dependências:** controller, services, models de erro customizados

**Validação:** Erros específicos tratados apropriadamente, recovery funciona, 
logs detalhados

---

### 20. [OPTIMIZE] - Cachear dados de usuário e assinatura

**Status:** 🔴 Pendente | **Execução:** Moderada | **Risco:** Baixo | **Benefício:** Médio

**Descrição:** Dados de usuário e assinatura são buscados sempre que página 
é aberta. Falta cache local para melhorar performance e experiência offline. 
GetX services podem estar fazendo requests desnecessários.

**Prompt de Implementação:**

Implemente sistema de cache para dados de usuário e assinatura. Use SharedPreferences 
ou Hive para persistência local. Adicione TTL para cache e invalidação inteligente. 
Implemente refresh pull-to-refresh. Configure cache strategy appropriada para 
cada tipo de dado.

**Dependências:** services, package para cache local

**Validação:** Dados carregam instantaneamente do cache, refresh funciona, 
cache invalida apropriadamente

---

## 🟢 Complexidade BAIXA

### 21. [STYLE] - Adicionar animações de transição para melhor UX

**Status:** 🔴 Pendente | **Execução:** Simples | **Risco:** Baixo | **Benefício:** Baixo

**Descrição:** Interface é funcional mas carece de micro-animações que tornam 
experiência mais fluida. Transições bruscas entre estados prejudicam percepção 
de qualidade.

**Prompt de Implementação:**

Adicione animações suaves para toggle de tema, mudanças de estado de loading, 
hover em botões. Use AnimatedContainer e AnimatedSwitcher onde apropriado. 
Configure durações consistentes baseadas nas constantes de animação já definidas. 
Mantenha animações sutis.

**Dependências:** Widgets que mudam estado, constants de animação

**Validação:** Transições suaves visíveis, durações apropriadas, não impacta 
performance

---

### 22. [TODO] - Implementar logs estruturados para debug

**Status:** 🔴 Pendente | **Execução:** Simples | **Risco:** Baixo | **Benefício:** Baixo

**Descrição:** Logs de debug são básicos usando apenas debugPrint. Falta 
sistema estruturado para rastreamento de eventos, erros e performance durante 
desenvolvimento.

**Prompt de Implementação:**

Implemente sistema de logging estruturado usando package logger. Configure 
níveis apropriados (debug, info, warning, error). Adicione contexto aos logs 
(timestamp, classe, método). Implemente filtros para produção. Configure output 
para file em desenvolvimento.

**Dependências:** Package logger, configuração de build

**Validação:** Logs estruturados visíveis durante debug, filtros funcionando, 
file output configurado

---

### 23. [STYLE] - Melhorar contraste de cores para acessibilidade

**Status:** 🔴 Pendente | **Execução:** Simples | **Risco:** Baixo | **Benefício:** Médio

**Descrição:** Algumas combinações de cores podem não atender padrões de 
acessibilidade WCAG. Textos secundários com opacity baixa podem ter contraste 
insuficiente, especialmente no tema escuro.

**Prompt de Implementação:**

Analise contraste de todas as combinações de cores usando ferramentas de 
acessibilidade. Ajuste valores de opacity e cores para atingir contraste 
mínimo WCAG AA. Teste com diferentes dispositivos e condições de iluminação. 
Documente paleta acessível.

**Dependências:** constants/minha_conta_constants.dart, ferramentas de análise

**Validação:** Contraste WCAG AA atingido, teste em condições reais, 
documentação criada

---

### 24. [NOTE] - Documentar constantes e uso correto de design tokens

**Status:** 🔴 Pendente | **Execução:** Simples | **Risco:** Baixo | **Benefício:** Baixo

**Descrição:** MinhaContaConstants é extenso mas falta documentação sobre quando 
usar cada método, especialmente diferença entre métodos estáticos e adaptativos. 
Desenvolvedores podem usar incorretamente.

**Prompt de Implementação:**

Adicione documentação detalhada em todas as seções de MinhaContaConstants. 
Explique quando usar métodos adaptativos vs estáticos. Crie exemplos de uso 
correto. Adicione warnings para métodos deprecated. Configure dartdoc para 
gerar documentação automaticamente.

**Dependências:** constants/minha_conta_constants.dart

**Validação:** Documentação clara em todos os métodos, exemplos funcionais, 
dartdoc gerado

---

### 25. [TEST] - Adicionar testes unitários para widgets customizados

**Status:** 🔴 Pendente | **Execução:** Moderada | **Risco:** Baixo | **Benefício:** Médio

**Descrição:** Widgets customizados como MenuItemWidget, UserProfileCardWidget 
e SubscriptionCardWidget não têm testes unitários. Mudanças podem quebrar 
funcionalidade sem detecção automática.

**Prompt de Implementação:**

Crie testes unitários abrangentes para todos os widgets customizados. Teste 
diferentes estados (loading, erro, sucesso), interações do usuário, e 
responsividade. Configure mocks para dependencies. Implemente golden tests 
para consistência visual.

**Dependências:** Criar arquivos de teste, mocks, golden files

**Validação:** Coverage alto nos widgets, testes passando, golden tests 
configurados

---

### 26. [STYLE] - Padronizar spacing e padding usando design tokens

**Status:** 🔴 Pendente | **Execução:** Simples | **Risco:** Baixo | **Benefício:** Baixo

**Descrição:** Alguns spacing e padding ainda usam valores hardcoded em vez 
dos EdgeInsets predefinidos em espacamentos. Inconsistência prejudica 
manutenção e design system.

**Prompt de Implementação:**

Substitua todos os padding e margin hardcoded pelos valores predefinidos em 
MinhaContaConstants.espacamentos. Adicione novos valores à constante se 
necessário. Configure lint rules para detectar valores hardcoded no futuro. 
Documente sistema de spacing.

**Dependências:** Todos os widgets da página, constants

**Validação:** Nenhum spacing hardcoded, lint rules configuradas, documentação 
atualizada

---

### 27. [TODO] - Adicionar tooltips informativos nos itens de menu

**Status:** 🔴 Pendente | **Execução:** Simples | **Risco:** Baixo | **Benefício:** Baixo

**Descrição:** Alguns itens de menu podem se beneficiar de tooltips explicativos, 
especialmente funcionalidades avançadas como backup, exportar dados, e 
ferramentas de desenvolvimento.

**Prompt de Implementação:**

Adicione Tooltip widgets informativos nos itens de menu que se beneficiariam 
de explicação adicional. Configure delay e duração apropriadas. Use linguagem 
clara e concisa. Teste em diferentes dispositivos para garantir que tooltips 
aparecem corretamente.

**Dependências:** widgets/menu_item_widget.dart, constants para textos

**Validação:** Tooltips aparecem adequadamente, textos claros, funciona em 
diferentes dispositivos

---

## 🔧 Comandos Rápidos

Para solicitar implementação específica, use:
- `Executar #[número]` - Para que a IA implemente uma issue específica
- `Detalhar #[número]` - Para obter prompt mais detalhado sobre implementação
- `Focar [complexidade]` - Para trabalhar apenas com issues de uma complexidade
- `Agrupar [tipo]` - Para executar todas as issues de um tipo
- `Validar #[número]` - Para que a IA revise implementação concluída

## 📊 Resumo de Priorização

### Crítico (implementar primeiro):
- Issues #1-8 (ALTA complexidade) - Refatoração arquitetural e segurança
- Issue #3 (SECURITY) - Validação de URLs crítica para segurança
- Issue #4 (TODO) - Autenticação para funcionalidade completa

### Importante (implementar em seguida):
- Issues #9-20 (MÉDIA complexidade) - Correções de bugs e otimizações
- Issue #11 (BUG) - Fallback de imagem crítico para UX
- Issue #19 (BUG) - Tratamento de erro para estabilidade

### Opcional (implementar quando possível):
- Issues #21-27 (BAIXA complexidade) - Melhorias de UX e manutenção
- Issue #25 (TEST) - Testes importantes para qualidade a longo prazo